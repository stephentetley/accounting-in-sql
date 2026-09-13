
create schema if not exists accounts_landing;

-- Needs variable `statements_path` setting e.g.
-- SET VARIABLE statements_path = '/home/___/___/___/';

create or replace macro date_from_varchar_num(str) as 
    strptime(excel_text(try_cast((str :: varchar) as double), 'dd/mm/yyyy'), '%d/%m/%Y')
;




-- columns={'Withdrawals': 'DECIMAL', 'Receipts': 'DECIMAL', 'Ledger Balance': 'DECIMAL'},
create or replace MACRO read_ybs_sheet(xlsx_file) as table
with cte1_raw as (
    select * 
    from read_xlsx(
            xlsx_file :: varchar, 
            sheet = 'statements_transcript', 
            all_varchar = true, 
            header = true)
), cte2_typed as (
    select * replace(
                try_cast("Page" as integer) as "Page",
                try_cast("Row" as integer) as "Row",
                date_from_varchar_num("Transaction Date") as "Transaction Date",
                date_from_varchar_num("Processed Date") as "Processed Date",
                try_cast("Applicable Int Rate" as decimal) as "Applicable Int Rate",
                try_cast("Receipts" as decimal) as "Receipts",
                try_cast("Withdrawals" as decimal) as "Withdrawals",
                try_cast("Ledger Balance" as decimal) as "Ledger Balance",
                try_cast("Interest After Tans" as decimal) as "Interest After Tans",
                try_cast("Internal TRF" as integer) as "Internal TRF")
    from cte1_raw
) 
select * from cte2_typed;


.print "ybs_access_saver"
create or replace table accounts_landing.ybs_access_saver as
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_access_saver_share_ann.xlsx');

.print "ybs_closed_savings"
create or replace table accounts_landing.ybs_closed_savings as
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_closed_savings.xlsx');

.print "ybs_funeral_expenses"
create or replace table accounts_landing.ybs_funeral_expenses as
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_funeral_expenses.xlsx');

.print "ybs_triple_access_saver"
create or replace table accounts_landing.ybs_triple_access_saver as
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_triple_access_saver.xlsx');

.print "ybs_two_year_frisa"
create or replace table accounts_landing.ybs_two_year_frisa as
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_2_year_fixed_rate_isa.xlsx');


-- columns={'Out': 'DECIMAL', 'In': 'DECIMAL', 'Balance': 'DECIMAL'},
.print "nationwide_current_account"
create or replace table accounts_landing.nationwide as
with cte1_raw as (
    select * 
    from read_xlsx(
            getvariable('statements_path') || 'nationwide_current_account.xlsx', 
            sheet = 'statements_transcript',
            all_varchar = true,
            header = true)
), cte2_typed as (
    select * replace(
                try_cast("Statement" as integer) as "Statement",
                try_cast("Row" as integer) as "Row",
                date_from_varchar_num("Date") as "Date",
                try_cast("Out" as decimal) as "Out",
                try_cast("In" as decimal) as "In",
                try_cast("Balance" as decimal) as "Balance")
    from cte1_raw
)
select * from cte2_typed;

.print "yorkshire_bank_current_account"
-- columns={'Debits': 'DECIMAL', 'Credits': 'DECIMAL', 'Balance': 'DECIMAL'},
create or replace table accounts_landing.yorkshire_bank as
with cte1_raw as (
    select * 
    from read_xlsx(
            getvariable('statements_path') || 'yorkshire_bank_current_account.xlsx', 
            sheet = 'statements_transcript',
            all_varchar = true, 
            header = true)
), cte2_typed as (
    select * replace(
                try_cast("Statement" as integer) as "Statement",
                try_cast("Row" as integer) as "Row",
                date_from_varchar_num("Date") as "Date",
                try_cast("Debits" as decimal) as "Debits",
                try_cast("Credits" as decimal) as "Credits",
                try_cast("Balance" as decimal) as "Balance")
    from cte1_raw
)
select * from cte2_typed;



.print "account_summaries"
-- columns={'Final Balance': 'DECIMAL'},
create or replace table accounts_landing.account_summaries as
with cte1_raw as (
    select * 
    from read_xlsx(
            getvariable('statements_path') || 'account_summaries.xlsx', 
            sheet = 'Account_summaries',
            all_varchar = true, 
            header = true)
), cte2_typed as (
    select * replace(
                try_cast("Account Number" as integer) as "Account Number",
                try_cast("Starting Balance" as decimal) as "Starting Balance",
                try_cast("Final Balance" as decimal) as "Final Balance",
                date_from_varchar_num("Open Date") as "Open Date",
                date_from_varchar_num("Start Date") as "Start Date",
                date_from_varchar_num("End Date") as "End Date")
    from cte1_raw
)
select * from cte2_typed;


.print "destination_accounts"
-- columns={'Final Balance': 'DECIMAL'},
create or replace table accounts_landing.destination_accounts as
with cte1_raw as (
    select * 
    from read_xlsx(
            getvariable('statements_path') || 'account_summaries.xlsx', 
            sheet = 'Destination_accounts',
            all_varchar = true, 
            header = true)
), cte2_typed as (
    select * replace(
                try_cast("Account Number" as integer) as "Account Number")
    from cte1_raw
)
select * from cte2_typed;




