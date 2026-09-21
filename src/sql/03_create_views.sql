
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
    coalesce(t1.account_holder, t.comment) AS payment_recipient,
FROM cte t
LEFT JOIN accounts_working.destination_accounts t1 ON format('INTERNAL TRF T{}', t1.account_number) = t.description
order by t.lineitem_date DESC
;


CREATE OR REPLACE VIEW accounts_working.vw_gifts AS
select 
    strftime(t.lineitem_date, '%d/%m/%Y') as "Date",
    t.description as "Transaction Description",
    format('{:.2f}', t.debit) as "Amount",
    t.payment_recipient as "Recipient",
    t.source_account as "Account Name",
    t.statement_or_page_number as "Statement Number",
    t.line_number as "Line Number",
    t.comment as "Comment",
    t.category as "Category",
from accounts_working.vw_all_transactions t 
where t.category = 'Gift to Family / Friends'
order by t.lineitem_date desc;

CREATE OR REPLACE VIEW accounts_working.vw_charity_donations AS
select
    strftime(t.lineitem_date, '%d/%m/%Y') as "Date",
    t.description as "Transaction Description",
    format('{:.2f}', t.debit) as "Amount",
    t.payment_recipient as "Recipient",
    t.source_account as "Account Name",
    t.statement_or_page_number as "Statement Number",
    t.line_number as "Line Number",
    t.comment as "Comment",
    t.category as "Category",
from accounts_working.vw_all_transactions t 
where t.category = 'Charity Donation'
order by t.lineitem_date desc;

CREATE OR REPLACE VIEW accounts_working.vw_cheque_unknown AS
select
    strftime(t.lineitem_date, '%d/%m/%Y') as "Date",
    t.description as "Transaction Description",
    format('{:.2f}', t.debit) as "Amount",
    t.payment_recipient as "Recipient",
    t.source_account as "Account Name",
    t.statement_or_page_number as "Statement Number",
    t.line_number as "Line Number",
    t.comment as "Comment",
    t.category as "Category",
from accounts_working.vw_all_transactions t 
where t.category = 'Cheque Unknown'
order by t.lineitem_date desc;

-- Summaries - order not needed
CREATE OR REPLACE VIEW accounts_working.vw_gift_summaries AS
select 'All gifts' as category, sum(t.debit) as total from accounts_working.vw_all_transactions t where t.category in ('Gift to Family / Friends', 'Charity Donation')
union all by name
select 'Gift to Family / Friends' as category, sum(t.debit) as total from accounts_working.vw_all_transactions t where t.category = 'Gift to Family / Friends'
union all by name
select 'Charity Donation' as category, sum(t.debit) as total from accounts_working.vw_all_transactions t where t.category = 'Charity Donation'
union all by name
select 'Cheque Unknown - not added to [All Gifts]' as category, sum(t.debit) as total from accounts_working.vw_all_transactions t where t.category = 'Cheque Unknown';





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

