#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use DBI;

# Changelog:
#  20060825 - Added newlines and swapped a die(3) to an exit(3), thanks to 
#             a patch from Elan Euusamae.
#  20050304 - Skip the row count on InnoDB tables, because the SHOW TABLE 
#             STATUS is just an ESTIMATE that varies wildly. Broke the check 
#             for this out to its own subroutine to clean up compare_status().
#  20050303 - Correct master-port handling (I dont use this now as I get the 
#             master figured out from the slave by doing 'show slave status').
#           - Added the master and slave ports to the printed output (I run 
#             many slaves on a slave host, one for each master I am slaving 
#             from; sometimes I have separate masters on the same host so that 
#             each one can be stopped, started independantly with their own 
#             keycache).
#             Added an option --check-random-database", which looks at the 
#             slave and sees which databases are being replicated, randomly 
#             picks one of these and does a 'show table status' ot get back the 
#             row_count, and if it differes by more than 
#             'table-rows-diff-absolute-crit' it adds this to the status line. 
#             If your replication is good, then the number of row between the 
#             master and slave should be about the same, and the update time on 
#             each table within a replicated database should be about the same.
#             The 'about' is because the time difference in checking the 
#             slave and then the master, and the delay in replication in 
#             the other direction.
#           - If there are table differences in the random check, then 
#             show a warning.
#
#  20050217 - Fix a type in the comments
#           - Convert the Seconds_Behind_Master to hours and seconds if it 
#             is large
#
#  20040120 - Make it find the master automatically, so you only specify a slave
#           - Update the output to show second behind for MySQL 4.1 slaves
#           
#  20041102 - Support MySQl 4.1 Exec_master_log_pos -> Exec_Master_Log_Pos 
#             case change

our $VERSION=0.04;

# $Id: check_replication.pl 2159 2005-03-07 10:34:40Z jeb $

my $options = { 'slave-port' => 3306, 'slave' => 'slavehost', 'crit' => 0.5, 'warn' => 0.1 , 'slave-user' => 'repl', 'slave-pass' => 'password', 'debug' => 0, 'table-rows-diff-absolute-crit' => 10, 'table-rows-diff-absolute-warn' => 5};
GetOptions($options, "slave=s", "slave-user=s", "slave-pass=s", "master=s", "master-port=i", "master-user=s", "master-pass=s", "crit=s", "warn=s", "help", "slave-port=i", "debug=i", "version", "check-random-database", "table-rows-diff-absolute-crit=i", "table-rows-diff-absolute-warn=i");
my $max_binlog;

if (defined $options->{'help'}) {
        print <<FOO;
$0: check replication between MySQL database instances

 check_replication.pl [ --slave <host> ] [ --slave-pass <pass> ] 
 [ --slave-port <d> ] [ --slave-user <user> ] [ --master <host> ] 
 [ --master-pass <pass> ] [ --master-port <port> ] [ --master-user <user> ] 
 [ --crit <positions> ] [ --warn <positions> ] [ --check-random-database ]
 [ --table-rows-diff-absolute-crit <number> ]
 [ --table-rows-diff-absolute-warn <number> ]

  --slave <host>        - MySQL instance running as a slave server
  --slave-port <d>      - port for the slave
  --slave-user <user>   - Username with File/Process/Super privs
  --slave-pass <pass>   - Password for above user
  --master <host>       - MySQL instance running as server (override)
  --master-port <d>     - port for the master (override)
  --master-user <user>  - Username for master (override)
  --master-pass <pass>  - Password for master
  --crit <positions>    - Number of complete master binlogs for critical state
  --warn <positions>    - Number of complete master binlog for warning state
  --check-random-database - Select a random DB from the slave's list of 
                        databases and compare to the master's 
                        information for these (need SELECT priv)
  --table-rows-diff-absolute-crit <number> - If we do the check-random-database, 
                        then ensure that the change in row count between master 
                        and slave is below this threshold, and go critical if not
  --table-rows-diff-absolute-warn <number> - If we do the check-random-database, 
                        then ensure that the change in row count between master 
                        and slave is below this threshold, and go warning if not
  --help             - This help page


By default, you should use your configured replication user, as you will 
then only need to specify the user and password once, and this script will 
find the master from the slave's running configuration.

Critical and warning values are no measured as amount of a complete master 
sized binlog. If your master has the default 1GB binlog size, then specifying 
a warning value of 0.1 means that your will let the slave get 100MB out of 
sync before warning; you may want to set warning to 0.01, and critical at 0.1.

MySQL 3: GRANT File, Process on *.* TO repl\@192.168.0.% IDENTIFIED BY <pass>
MySQL 4: GRANT Super, Replication_client on *.* TO repl\@192.168.0.% IDE...

If you want to use the check-random-database option, then the user needs 
SELECT privileges on all replicated tables on the master and the slave.

Note: Any mysqldump tables (for backups) may lock large tables for a long 
time. If you dump from your slave for this, then your master will gallop 
away from your slave, and the difference will become large. The trick is to 
set crit above this differnce and warn below.

(c) 2005 Fotango. James Bromberger <jbromberger\@fotango.com>.
FOO
exit;
} elsif (defined $options->{version}) {
        printf "%s %s\n", $0, $VERSION;
        exit;
}

sub debug {
        my $level = shift;
        my $message = shift;
        return if $level > $options->{debug};
        my $caller = (caller(1))[3];
        print $caller . ":" . $message . "\n";
}

sub get_status {
        my $host = shift;
        my $port = shift;

        debug(1, "Connecting to slave $host:$port as user " . $options->{'slave-user'});
        my $dbh = DBI->connect("DBI:mysql:host=$host:port=$port", $options->{'slave-user'}, $options->{'slave-pass'});
        if (not $dbh) {
                print "UNKNOWN: cannot connect to $host\n";
                exit 3;
        }
        my $sql = "show variables";
        my $sth = $dbh->prepare($sql);
        if (not $sth) {
                print "UNKNOWN: cannot prepare $sql\n";
                exit 3;
        }
        debug(2, "Getting slave variables");
        my $res = $sth->execute;
        my $slave_data;
        while (my $ref = $sth->fetchrow_hashref) {
                $slave_data->{$ref->{'Variable_name'}} = $ref->{'Value'};
        }
        $sth->finish;
        $sql = "show slave status";
        $sth = $dbh->prepare($sql);
        if (not $sth) {
                print "UNKNOWN: cannot prepare $sql\n";
                exit 3;
        }
        debug(2, "Getting slave replication status");
        $res = $sth->execute();
        $slave_data->{replication} = $sth->fetchrow_hashref;
        $sth->finish;

        if (defined $options->{'check-random-database'}) {
                debug(2, "Checking status of a random replicate-do-db");
                my @replicated = split(',', $slave_data->{replication}->{Replicate_Do_DB});
                my $random_db = $replicated[int(rand() * scalar(@replicated))];

                if (defined $random_db) {
                        debug(3, "DBs being replicated are: " . join(', ', @replicated) . "; random choice is $random_db");
                        my $sql = "use $random_db";
                        $sth = $dbh->prepare($sql) || die "Cannot prepare: $!";
                        $res = $sth->execute();
                        $sth->finish;
                        $sql = 'show table status';
                        $sth = $dbh->prepare($sql);
                        $res = $sth->execute();
                        while (my $ref = $sth->fetchrow_hashref) {
                                $slave_data->{replication}->{table_status}->{$random_db}->{$ref->{Name}} = $ref;
                        }
                }
        }
        $dbh->disconnect;
        # Now connect to the master...
        $host = $options->{'master'} || $slave_data->{replication}->{Master_Host};
        $port = $options->{'master-port'} || $slave_data->{replication}->{Master_Port};
        my $user = $options->{'master-user'} || $slave_data->{replication}->{Master_User};
        my $pass = $options->{'master-pass'} || $options->{'slave-pass'};
        debug(1, "Connecting to master $host:$port as user $user");
        $dbh = DBI->connect("DBI:mysql:host=$host:port=$port", $user, $pass);

        if (not $dbh) {
                print "UNKNOWN: Cannot connect to master $host:$port\n";
                exit 3;
        }
        $sql = "show variables";
        $sth = $dbh->prepare($sql);
        debug(1, "Getting master variables");
        $res = $sth->execute;
        my $master_data;
        while (my $ref = $sth->fetchrow_hashref) {
                $master_data->{$ref->{'Variable_name'}} = $ref->{'Value'};
        }
        $sth->finish;
        $sql = "show master status";
        $sth = $dbh->prepare($sql);
        debug(2, "Getting master replication status");
        $res = $sth->execute;
        if (not $res) {
                print "UNKNOWN: Cannot get replication status (lack of privileges?)\n";
                exit 3;
        }
        $master_data->{replication} = $sth->fetchrow_hashref;
        $sth->finish;

        if (defined $options->{'check-random-database'}) {
                foreach my $database (keys(%{$slave_data->{replication}->{table_status}})) {
                        debug(3, "The master should check $database");
                        $sth = $dbh->prepare("use $database");
                        $sth->execute || die "Cannot use db";
                        $sth->finish;
                        $sth = $dbh->prepare('show table status');
                        $res = $sth->execute;
                        while (my $ref = $sth->fetchrow_hashref) {
                                $master_data->{replication}->{table_status}->{$database}->{$ref->{Name}} = $ref;
                        }
                }
        }
        $dbh->disconnect;

        #use Data::Dumper;
        #print Dumper($slave_data->{replication});
        #print Dumper($master_data->{replication});
        compare_status($master_data, $slave_data);
}

sub compare_table_rows {
        # The two arguments, 'master' and 'slave' are references to the hashes from the respective 
        # SHOW MASTER STATUS queries. Both must be present, or we return nothing. We compare each, 
        # avoiding deficiencies in InnoDB tables, looking only at the row counts. If the row_count 
        # difference exceeds our limit, we add it to our message string.
        my %args = @_;
        return unless defined $args{master};
        return unless defined $args{slave};

        my @messages;
        my $exit_level = 0;
        foreach my $database (keys %{$args{slave}}) {
                foreach my $table (keys %{$args{slave}->{$database}}) {
                        debug(4, "Checking $database.$table");
                        if ((defined($args{slave}->{$database}->{$table}->{Engine}) && $args{slave}->{$database}->{$table}->{Engine} eq 'InnoDB')|| (defined($args{slave}->{$database}->{$table}->{Type}) && $args{slave}->{$database}->{$table}->{Type} eq 'InnoDB')) {
                                # We can't rely on InnoDB's row count from 'SHOW TABLE STATUS' since it is an approximation
                                # For MySQL 4.1.10 and below, we cant even get an Update_time, since this is NULL!
                                # The only thing we /could/ do is reconnect and do a SELECT COUNT(*) FROM TABLE, but 
                                # we can't be bothered! Humph.
                                debug(5, "Skipping check on InnoDB table $database.$table");
                        } else {
                                if (defined($args{slave}->{$database}->{$table}->{Rows}) && defined ($args{master}->{$database}->{$table}->{Rows})) {
                                        my $row_diff = abs($args{slave}->{$database}->{$table}->{Rows} - $args{master}->{$database}->{$table}->{Rows});
                                        if (abs($row_diff) > $options->{'table-rows-diff-absolute-crit'}) {
                                                push @messages, "$database.$table $row_diff";
                                                $exit_level = 2;
                                        } elsif (abs($row_diff) > $options->{'table-rows-diff-absolute-warn'})  {
                                                push @messages, "$database.$table $row_diff";
                                                $exit_level = 1 unless $exit_level == 2;
                                        }
                                } else {
                                        debug(2, "$database.$table has now row count on slave!") unless defined($args{slave}->{$database}->{$table}->{Rows});
                                        debug(2, "$database.$table has now row count on master!") unless defined($args{master}->{$database}->{$table}->{Rows});
                                }
                        }
                }
        }
        return ($exit_level, join(', ', @messages));
}

sub compare_status {
        my ($master, $slave) = @_;


        # Step one; are the SQL slave thread and the IO slave thread running (critical if not)
        if (lc($slave->{replication}->{'Slave_SQL_Running'}) ne lc('yes')) {
                print "CRITICAL: Slave SQL not running\n";
                exit 2;
        }
        if (lc($slave->{replication}->{'Slave_IO_Running'}) ne lc('yes')) {
                print "CRITICAL: Slave IO not running\n";
                exit 2;
        }

        # Step two; compare the positions between the master and slave

        # Pattern match the BINLOG number...
        $master->{replication}->{'File_No'} = $1 if ($master->{replication}->{'File'} =~ /(\d+)$/);
        $slave->{replication}->{'File_No'} = $1 if ($slave->{replication}->{'Relay_Master_Log_File'} =~ /(\d+)$/);

        # Get the slave position it is executing, being careful of the 
        # key name change in MySQL 4.1 (case change)
        $slave->{replication}->{'Position'} = $slave->{replication}->{'Exec_Master_Log_Pos'} || $slave->{replication}->{'Exec_Master_log_pos'};
        #use Data::Dumper;
        #debug(4, Dumper($slave->{replication}));

        debug(3, " Master: " . $master->{replication}->{'File'} . ":" . $master->{replication}->{'Position'});
        debug(3, " Slave:  " . $slave->{replication}->{'Master_Log_File'} . ":" . $slave->{replication}->{'Position'});

        my $diff = $master->{replication}->{'File_No'} - $slave->{replication}->{'File_No'} + (($master->{replication}->{'Position'} - $slave->{replication}->{'Position'}) / $slave->{max_binlog_size});

        debug(1, "diff: $diff ");


        # Compare the table status if we have them
        my ($exit_level, $table_diff_message) = compare_table_rows(master => $master->{replication}->{table_status}, slave => $slave->{replication}->{table_status});

        my $time_diff = "";
        if (defined $slave->{'replication'}->{Seconds_Behind_Master}) {
                if ($slave->{'replication'}->{Seconds_Behind_Master}> 3600) {
                        $time_diff = int($slave->{'replication'}->{Seconds_Behind_Master} / 3600) . "h " . ($slave->{'replication'}->{Seconds_Behind_Master} % 3600) . " secs";
                } else {
                        $time_diff = $slave->{'replication'}->{Seconds_Behind_Master} . " secs";
                }
        }

        my $state = sprintf "%.3f diff", $diff;
        $state.= ", $time_diff" if defined($slave->{'replication'}->{Seconds_Behind_Master});
        $state.= ", " .  ($options->{'master'} || $slave->{replication}->{Master_Host}) . ":" . ($options->{'master-port'} || $slave->{replication}->{Master_Port}) .  " (" . $master->{version} . ") -> " . $options->{slave} . ":" . $options->{'slave-port'} . " (" . $slave->{version} . ")";
        $state.= " " . $table_diff_message if $table_diff_message;
        $state.= "\n";

        if ($diff >= $options->{'crit'}) {
                print "CRITICAL: $state\n";
                exit 2;
        } elsif ($diff >= $options->{'warn'} || $table_diff_message) {
                print "WARN: $state\n";
                exit 1;
        }
        print "OK: $state\n";
        exit 0;
}

get_status($options->{'slave'}, $options->{'slave-port'});

