#!/bin/bash
# Check postgres replication status delay

DELAY=$(su - postgres -c "psql -A -t -c\"SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() -pg_last_xact_replay_timestamp())::INTEGER END;\"")

echo $DELAY
