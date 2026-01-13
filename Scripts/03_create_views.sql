

CREATE OR REPLACE VIEW accounts_working.vw_all_transactions AS
(SELECT 'Nationwide' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.nationwide)
UNION ALL BY NAME
(SELECT 'YBS Access Saver' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.ybs_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Closed Savings' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.ybs_closed_savings)
UNION ALL BY NAME
(SELECT 'YBS Funeral Expenses' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.ybs_funeral_expenses)
UNION ALL BY NAME
(SELECT 'YBS Triple Access Saver' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.ybs_triple_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Two Year Fixed-Rate ISA' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.ybs_two_year_frisa)
UNION ALL BY NAME
(SELECT 'Yorkshire Bank' AS source_account, * EXCLUDE (transaction_id) FROM accounts_working.yorkshire_bank)
;


SELECT * FROM accounts_working.vw_all_transactions
ORDER BY transaction_date DESC;