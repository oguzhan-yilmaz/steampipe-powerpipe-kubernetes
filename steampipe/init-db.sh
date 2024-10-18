#!/bin/bash

SQL_DIR="/home/steampipe/initdb-sql-scripts"
if ls "$SQL_DIR"/*.sql 1> /dev/null 2>&1; then
    # Check if the directory exists
    echo "[init-db.sh] Starting DB Initialization as there are .sql scripts in ~/initdb-sql-scripts directory"

    while true; do  # Loop until the exit code of healthcheck.sh is 0
        bash healthcheck.sh > /dev/null
        exit_code=$?

        if [ $exit_code -eq 0 ]; then  # Check if the exit code is 0
            echo "[init-db.sh] steampipe service is up and running. Starting to initialize the db."
            break
        else
            echo "[init-db.sh] Waiting (10 secs) until steampipe service is up and running..."
            sleep 10
        fi
    done

    echo "[init-db.sh] Running SQL scripts:"
        for sql_file in "$SQL_DIR"/*.sql; do
            if [ -e "$sql_file" ]; then # Check if there are any .sql files
                echo "[init-db.sh]   Processing file: $sql_file"
                psql -f "$sql_file"
            fi
        done
else
    echo "[init-db.sh] Skipping Db Initialization as $SQL_DIR directory does not have .sql scripts."
fi