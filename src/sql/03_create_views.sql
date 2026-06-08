
CREATE OR REPLACE VIEW accounts_working.vw_all_transactions AS
WITH cte AS (
(SELECT 'NW Flex Account' AS source_account, * FROM accounts_working.nationwide)
UNION ALL BY NAME
(SELECT 'YBS Access Saver Share Ann' AS source_account, * FROM accounts_working.ybs_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Closed Savings' AS source_account, * FROM accounts_working.ybs_closed_savings)
UNION ALL BY NAME
(SELECT 'YBS Funeral Expenses' AS source_account, * FROM accounts_working.ybs_funeral_expenses)
UNION ALL BY NAME
(SELECT 'YBS Triple Access Saver' AS source_account, * FROM accounts_working.ybs_triple_access_saver)
UNION ALL BY NAME
(SELECT 'YBS Two Year Fixed Rate ISA' AS source_account, * FROM accounts_working.ybs_two_year_frisa)
UNION ALL BY NAME
(SELECT 'YB Current Account' AS source_account, * FROM accounts_working.yorkshire_bank)
) 
SELECT 
    t.* EXCLUDE (transaction_id, ledger_balance),
    t1.account_holder AS payment_recipient,
FROM cte t
LEFT JOIN accounts_working.destination_accounts t1 ON format('INTERNAL TRF T{}', t1.account_number) = t.description
order by t.lineitem_date DESC
;


CREATE OR REPLACE VIEW accounts_working.vw_nationwide_daily_balance AS
WITH cte_date_buckets0 AS (
    SELECT
        t.lineitem_date AS lineitem_date,
        sum(t.credit) AS credit1, 
        sum(t.debit) AS debit1,
    FROM accounts_working.nationwide t
    GROUP BY lineitem_date
), cte_date_buckets AS (
    SELECT 
        t.lineitem_date, 
        ifnull(t.credit1, 0.0) AS credit,
        ifnull(t.debit1, 0.0) AS debit,
        credit-debit AS daily_credit_minus_debit,
    FROM cte_date_buckets0 t
    -- Nationwide starts from zero
)
SELECT 
    t.lineitem_date, 
    t.debit,
    t.credit,
    sum(t.daily_credit_minus_debit) OVER w AS balance
FROM cte_date_buckets t
WINDOW w AS (
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
ORDER BY t.lineitem_date ASC;


CREATE OR REPLACE VIEW accounts_working.vw_yorkshire_bank_daily_balance AS
WITH cte_date_buckets0 AS (
    SELECT
        t.lineitem_date AS lineitem_date,
        sum(t.credit) AS credit1, 
        sum(t.debit) AS debit1,
    FROM accounts_working.yorkshire_bank t
    GROUP BY lineitem_date
), cte_date_buckets AS (
    SELECT 
        t.lineitem_date, 
        ifnull(t.credit1, 0.0) AS credit,
        ifnull(t.debit1, 0.0) AS debit,
        credit-debit AS daily_credit_minus_debit,
    FROM cte_date_buckets0 t
), cte_with_balance0 AS (
    SELECT 
        t.lineitem_date, 
        t.debit,
        t.credit,
        sum(t.daily_credit_minus_debit) OVER w AS balance
    FROM cte_date_buckets t
    WINDOW w AS (
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
)
SELECT
    t.lineitem_date, 
    t.debit,
    t.credit,
    t.balance + 4439.50 AS balance
FROM cte_with_balance0 t
ORDER BY t.lineitem_date ASC;


--CREATE OR REPLACE TEMPORARY TABLE temp_report AS 
--SELECT * FROM accounts_working.vw_all_transactions ORDER BY transaction_date DESC, source_account ASC;
--
--COPY temp_report TO (getvariable('accounts_path') || 'all_transactions.xlsx') WITH (FORMAT xlsx, HEADER true);

