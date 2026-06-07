#!/bin/bash

# Make sure to run this as a dot script...

if ! { [ -n "$1" ] && [ -n "$2" ]; } ; then
    echo "Supply he folder path to Excel files as as param 1"
    echo "Supply the output database name as param 2"
    return 1 
fi

if [ ! -d "$1" ]; then
    echo "Folder $1 does not exist."
    return 1 
fi


if [[ ! -z "${ACCOUNTS_SQL}" ]]; then

duckdb $2 <<EOF

set variable accounts_path = '$1';

.read '$ACCOUNTS_SQL/src/sql/01_import_statements.sql'
.read '$ACCOUNTS_SQL/src/sql/02_setup_working_tables.sql'
.read '$ACCOUNTS_SQL/src/sql/03_create_views.sql'
.read '$ACCOUNTS_SQL/src/sql/04_check_balance.sql'

EOF
    echo "Created $2"
else
    echo "Must set the env var ACCOUNTS_SQL"
fi


