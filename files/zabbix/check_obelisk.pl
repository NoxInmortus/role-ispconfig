#! /usr/bin/perl -w
#
# -=| obelisk.pl |=-
#
#  v.20090928 - JS
#
#

use Getopt::Std;
use strict;


#Globals variables
my $a_bin = "/usr/bin/sudo /usr/sbin/asterisk -rx";
my $a_command = "";

my @exten; my @state;
my $i = 0; my $x = 0; my $hints = 0;

my $number = 1;

my $zaptel = 0;

my $asterisk = my $version = `$a_bin 'core show version'`;
$asterisk =~s/^Asterisk ([0-9].[0-9]).[0-9]{1,2}.*/$1/;
$version =~s/^Asterisk [0-9].[0-9].([0-9]{1,2}).*/$1/;

if ( $asterisk == "1.4" ) {
	if ( $version <= 21 ) { $zaptel = 1; };
};


#Nagios variables
my $log = "";
my @output;
my $return = 3;



#Functions
sub syntax()
{
	if ( $zaptel == 1 ) {
		print(
			"\nSyntax:\t $0 [-h]\n"
			."       \t $0 [-c <command> [-n <meetme number>|<queue name>|<span number>] [-i] [-v]]\n"
			. ".....................................................................\n"
			. "\n"
			. "-h: Display the help\n"
			. "\n"
			. "\n"
			. "-c channels: Display the SIP channels status\n"
			. "\n"
			. "-c hints: Display incoming the Hints status\n"
			. "-c hints -i: Display incoming/outgoing Hints status (default is 'off')\n"
			. "  >>> -i inuse='on' : it's not compatible with Nagios <<<\n"
			. "\n"
			. "-c meetme [-n <meetme number>]: Display status on a specific meetme (default n=1)\n"
			. "\n"
			. "-c peers: Display the SIP peers status\n"
			. "\n"
			. "-c queue [-n <queue name>]: Display the SIP peers status\n"
			. "\n"
			. "-c span [-n <span number>]: Display status on a specific span (default n=1)\n"
			. "\n"
			. "-c zaptel: Display the status of the zaptel card\n"
			. "\n"
			. "-c <command> -v: Display 'on' verbose command (default is 'off')\n"
			. "  >>> -v verbose='on' : it's not compatible with Nagios <<<\n"
			. "\n"
			. "\n"
			. "-c version: Display the Asterisk version\n"
			. "\n"
			. ".....................................................................\n");
	} else {
		print(
			"\nSyntax:\t $0 [-h]\n"
			."       \t $0 [-c <command> [-n <meetme number>|<queue name>|<span number>] [-i] [-v]]\n"
			. ".....................................................................\n"
			. "\n"
			. "-h: Display the help\n"
			. "\n"
			. "\n"
			. "-c channels: Display the SIP channels status\n"
			. "\n"
			. "-c hints: Display incoming the Hints status\n"
			. "-c hints -i: Display incoming/outgoing Hints status (default is 'off')\n"
			. "  >>> -i inuse='on' : it's not compatible with Nagios <<<\n"
			. "\n"
			. "-c meetme [-n <meetme number>]: Display status on a specific meetme (default n=1)\n"
			. "\n"
			. "-c peers: Display the SIP peers status\n"
			. "\n"
			. "-c queue [-n <queue name>]: Display the SIP peers status\n"
			. "\n"
			. "-c span [-n <span number>]: Display status on a specific span (default n=1)\n"
			. "\n"
			. "-c dahdi : Display the status of the dahdi card\n"
			. "\n"
			. "-c <command> -v: Display 'on' verbose command (default is 'off')\n"
			. "  >>> -v verbose='on' : it's not compatible with Nagios <<<\n"
			. "\n"
			. "\n"
			. "-c version: Display the Asterisk version\n"
			. "\n"
			. ".....................................................................\n");
	};
};


sub command
{
	my (@args) = @_;
	$a_command = $args[0];
	
	foreach ( `$a_bin \"$a_command\"` ) {
		if ( /$args[1]/ ) {
			$log = $_;
			$output[0] = $log;

			if ( $log eq "" ) {
				$return=2;
			} else {
			 	$return=0;
		 	};
		};
	};
};


sub hints 
{
	$a_command='core show hints';

	my @show_hints = `$a_bin \"$a_command\"`;
	my @show_inuse = `$a_bin \"sip show inuse\"`;
	my @show_peers = `$a_bin \"sip show peers\"`;
	
	my $nbHold = 0; my $nbIdle = 0; my $nbInUse = 0; my $nbRing = 0; my $nbUnav = 0;

	foreach my $value ( grep(/SIP\/[0-9]{4,5}/,@show_hints) ) {
		$exten[$i] = $value;
		$exten[$i] =~s/.*SIP\/([0-9]{4,5}).*\n/$1/;

		$state[$i] = $value;
		$state[$i] =~s/.*State:([A-Za-z]{1,}).*\n/$1/;

		my @numero = grep(/^$exten[$i].*/,@show_peers);
		$numero[0] =~s/^[0-9]{4,5}\/([A-Za-z_]{1,}-{0,1}[A-Za-z_]{1,}).*\n/$1/;


		if ( $state[$i] eq "Idle" ) {
			if ( $zaptel == 1 ) {
				my @status = grep(/^$exten[$i].[[:space:]]{1,}[0-9]{1,}[[:space:]]{1,}[0-9]{1,}/,@show_inuse);
				$status[0] =~s/^$exten[$i].[[:space:]]{1,}.([0-9]{1,}).[[:space:]]{1,}.[0-9]{1,}.[[:space:]]{1,}\n/$1/;
				if ( $status[0] == 1 ) {
					$state[$i] = "InUse";
					$nbInUse++;
				} else {
					$nbIdle++;
				};
			} else {
				my @status = grep(/^$exten[$i].[[:space:]]{1,}[0-9]{1,}\/[0-9]{1,}\/[0-9]{1,}.*/,@show_inuse);
				$status[0] =~s/^$exten[$i].[[:space:]]{1,}([0-9]{1,})\/[0-9]{1,}\/[0-9]{1,}.*/$1/;
				if ( $status[0] >= 1 ) {
					$state[$i] = "InUse";
					$nbInUse++;
				} else {
					$nbIdle++;
				};
			};
		} elsif ( $state[$i] eq "InUse" ) {
			$nbInUse++;
		} elsif ( $state[$i] eq "Hold" ) {
			$nbHold++;
		} elsif ( $state[$i] eq "Ringing" ) {
			$nbRing++;
		} elsif ( $state[$i] eq "Unavailable" ) {
			$nbUnav++;
		};

		$exten[$i] = $exten[$i] . "/" . $numero[0]; 

		$i++;
	};

	$output[0] = $nbInUse . " SIP inuse, " . $nbHold . " SIP hold, " . $nbRing . " SIP ringing, " . $nbIdle . " SIP idle, " . $nbUnav . " SIP unavailable \n";
	$return = 0;
};


sub queue
{
	if ( $number eq 1 ) {
		$a_command='queue show';
	} else {
		$a_command='queue show '.$number;
	};

	my @show_queue = `$a_bin \"$a_command\"`;

	foreach my $value ( grep(/strategy/,@show_queue) ) {
		$output[$i] = $value;
		$i++;
	}

};


sub meetme
{
	&command('meetme list '.$number, 'users.*.*conference');

	if ( $return == 3 ) {
		&command('meetme list '.$number, '^No.*');
	};
};


sub zaptel
{
	my $log_ok = "";
	my $log_alarm = "";
	my $log_no = "";
	
	$log = "";
	&command('zap show status', 'Span '.$number.'[[:space:]]{1,}OK');
	$log_ok = $log;
	
	$log = "";
	&command('zap show status', 'Span '.$number.'[[:space:]]{1,}ALARM');
	$log_alarm = $log;
	
	$log = "";
	&command('zap show status', 'Span '.$number.'[[:space:]]{1,}UNCONFIGUR');
	$log_no = $log;

	if ( $log_ok ne ""  &&  $log_alarm eq ""  &&  $log_no eq "" ) {
		$return = 0;
		$output[0] = "Span " . $number . "		: OK\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm ne ""  &&  $log_no eq "" ) {
		$return = 2;
		$output[0] = "Span " . $number . "		: ALARM\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm eq ""  &&  $log_no ne "" ) {
		$return = 1;
		$output[0] = "Span " . $number . "		: UNCONFIGURED\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm eq ""  &&  $log_no eq "" ) {
		$return = 3;
		$output[0] = "Span " . $number . "		: UNKWON\n";
	};
};


sub dahdi
{
	my $log_ok = "";
	my $log_alarm = "";
	my $log_no = "";
	
	$log = "";
	&command('dahdi show status', 'Span '.$number.'[[:space:]]{1,}OK');
	$log_ok = $log;
	
	$log = "";
	&command('dahdi show status', 'Span '.$number.'[[:space:]]{1,}ALARM');
	$log_alarm = $log;
	
	$log = "";
	&command('dahdi show status', 'Span '.$number.'[[:space:]]{1,}UNCONFIGUR');
	$log_no = $log;

	if ( $log_ok ne ""  &&  $log_alarm eq ""  &&  $log_no eq "" ) {
		$return = 0;
		$output[0] = "Span " . $number . "		: OK\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm ne ""  &&  $log_no eq "" ) {
		$return = 2;
		$output[0] = "Span " . $number . "		: ALARM\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm eq ""  &&  $log_no ne "" ) {
		$return = 1;
		$output[0] = "Span " . $number . "		: UNCONFIGURED\n";
	} elsif ( $log_ok eq ""  &&  $log_alarm eq ""  &&  $log_no eq "" ) {
		$return = 3;
		$output[0] = "Span " . $number . "		: UNKWON\n";
	};
};



#Execute the asterisk command and analyse the result
use vars qw( %opts);
getopts("hc:n:vi", \%opts) or (syntax() and exit($return));

for my $option ( keys %opts ) {
	my $command = $opts{$option};

	if ( $option eq "c" ) {
		if ( $zaptel == 1  &&   $command eq "channels" ) {
			&command('sip show channels', 'SIP channel');
		} elsif ( $zaptel == 0  &&   $command eq "channels" ) {
			&command('sip show channels', 'SIP dialogs');
		} elsif ( $command eq "hints" ) {
			&hints();
			$hints = 1;
		} elsif ( $command eq "meetme" ) {
			&meetme();
		} elsif ( $command eq "peers" ) {
			&command('sip show peers', 'sip peers');
		} elsif ( $command eq "queue" ) {
			&queue();
		} elsif ( $zaptel == 1  &&  ( $command eq "zaptel"  ||  $command eq "span" ) ) {
			&command('zap show status', 'Description');
			if ( $log eq "" ) {
	      $output[0] = "Zaptel card		: NO\n";
			} elsif ( $command eq "span" ) {
				&zaptel();
			} elsif ( $command eq "zaptel" ) {
				$output[0] = "Zaptel card		: OK\n";
			};
		} elsif ( $zaptel == 0  && ( $command eq "dahdi"  ||  $command eq "span" ) ) {
			&command('dahdi show status', 'Description');
			if ( $log eq "" ) {
	      $output[0] = "Dahdi card		: NO\n";
			} elsif ( $command eq "span" ) {
				&dahdi();
			} elsif ( $command eq "dahdi" ) {
				$output[0] = "Dahdi card		: OK\n";
			};
		} elsif ( $command eq "version" ) {
			&command('core show version', 'Asterisk');
		} else {
			syntax();
	    exit($return);
		};
	} elsif ( $option eq "i" ) {
		if ( $hints == 1 ) {
			print "SIP/Username	: State\n";
			for ( $x=0; $x<$i; $x++ ) {
				print $exten[$x] . "	: " . $state[$x], "\n";
			};
			print $output[0];
			exit($return);
		} else {
			syntax();
			exit($return);
		};
	} elsif ( $option eq "n" ) {
		$number = $command;
	} elsif ( $option eq "v" ) {
		system $a_bin." \"".$a_command."\"";
		exit($return);
	} else {
		syntax();
		exit($return);
	};
};



# Print the output on STDOUT
if ( $output[0] eq "" ) {
	syntax();
  exit($return);
} else {
	foreach my $value ( @output ) {
		print $value;
	};
};


# Nagios Return Codes
# OK = 0 / Warning = 1 / Critical = 2 / Unknown = 3 
exit($return);
