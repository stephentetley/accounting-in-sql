
duckoutfile := "./output/accounts_sb.duckdb"
all_transactions_report := "./output/all_transactions.xlsx"

db statements_path: 
    duckdb {{duckoutfile}} -c "load excel;" \
        -c "set variable statements_path = '{{statements_path}}';" \
        -c ".read './src/sql/01_import_statements.sql'" \
        -c ".read './src/sql/02_setup_working_tables.sql'" \
        -c ".read './src/sql/03_create_views.sql'" \
        -c ".read './src/sql/04_check_balance.sql'" \
        -c "COPY accounts_working.vw_all_transactions TO '{{all_transactions_report}}' WITH (FORMAT xlsx, HEADER true);"