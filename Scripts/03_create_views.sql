LOAD Excel;

CREATE OR REPLACE VIEW accounts_working.vw_all_transactions AS
WITH cte AS (
(SELECT 'Nationwide' AS source_account, * FROM accounts_working.nationwide)
UNION ALL BY NAME
(SELECT 'YBS Access Saver' AS source_account, * FROM accounts_working.ybs_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Closed Savings' AS source_account, * FROM accounts_working.ybs_closed_savings)
UNION ALL BY NAME
(SELECT 'YBS Funeral Expenses' AS source_account, * FROM accounts_working.ybs_funeral_expenses)
UNION ALL BY NAME
(SELECT 'YBS Triple Access Saver' AS source_account, * FROM accounts_working.ybs_triple_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Two Year Fixed-Rate ISA' AS source_account, * FROM accounts_working.ybs_two_year_frisa)
UNION ALL BY NAME
(SELECT 'Yorkshire Bank' AS source_account, * FROM accounts_working.yorkshire_bank)
) 
SELECT 
    t.* EXCLUDE (transaction_id, ledger_balance),
    t1.account_holder AS payment_recipient,
FROM cte t
LEFT JOIN accounts_working.destination_accounts t1 ON format('INTERNAL TRF T{}', t1.account_number) = t.description
;




--CREATE OR REPLACE TEMPORARY TABLE temp_report AS 
--SELECT * FROM accounts_working.vw_all_transactions ORDER BY transaction_date DESC, source_account ASC;
--
--COPY temp_report TO (getvariable('accounts_path') || 'all_transactions.xlsx') WITH (FORMAT xlsx, HEADER true);

