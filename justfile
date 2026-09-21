
duckoutfile := "./output/accounts_sb.duckdb"
output := "./output"

db statements_path: 
    duckdb {{duckoutfile}} -c "load excel;" \
        -c "set variable statements_path = '{{statements_path}}';" \
        -c ".read './src/sql/01_import_statements.sql'" \
        -c ".read './src/sql/02_setup_working_tables.sql'" \
        -c ".read './src/sql/03_create_views.sql'" \
        -c ".read './src/sql/04_check_balance.sql'" \
        -c "COPY accounts_working.vw_all_transactions TO '{{output}}/all_transactions.xlsx' WITH (FORMAT xlsx, HEADER true);" \
        -c "COPY accounts_working.vw_gift_summaries TO '{{output}}/gift_summaries_report.xlsx' WITH (FORMAT xlsx, HEADER true);" \
        -c "COPY accounts_working.vw_gifts TO '{{output}}/gifts_report.xlsx' WITH (FORMAT xlsx, HEADER true);" \
        -c "COPY accounts_working.vw_charity_donations TO '{{output}}/charity_donations_report.xlsx' WITH (FORMAT xlsx, HEADER true);" \
        -c "COPY accounts_working.vw_cheque_unknown TO '{{output}}/cheque_unknown_report.xlsx' WITH (FORMAT xlsx, HEADER true);"
