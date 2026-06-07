
CREATE OR REPLACE MACRO check_balance_at_date(table_name, account_name, check_date) AS TABLE
WITH cte1 AS (
    SELECT 
        sum(t.credit) AS t_credit, 
        sum(t.debit) AS t_debit,
    FROM query_table(table_name :: VARCHAR) t
    WHERE t.lineitem_date <= (check_date :: DATE)
), cte2 AS (
    SELECT max(t.starting_balance) AS start
    FROM accounts_working.account_summaries t 
    WHERE t.account_name = (account_name :: VARCHAR)
)
SELECT 
    check_date AS check_date,
    (account_name :: VARCHAR) AS account_name,
    ifnull(t2.start, 0) + ifnull(t1.t_credit, 0) - ifnull(t1.t_debit, 0) AS balance_check,
    ifnull(t1.t_credit, 0) as sum_credit,
    ifnull(t1.t_debit, 0) AS sum_debit,
FROM cte1 t1, cte2 t2;

CREATE OR REPLACE VIEW accounts_working.vw_final_balances AS
SELECT * FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2025-07-09')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2025-10-02')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.ybs_closed_savings, 'ybs_closed_savings', DATE '2020-11-03')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.ybs_funeral_expenses, 'ybs_funeral_expenses', DATE '2025-10-02')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.ybs_triple_access_saver, 'ybs_triple_access_saver', DATE '2025-10-02')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.ybs_two_year_frisa, 'ybs_two_year_frisa', DATE '2025-10-02')
UNION BY NAME
SELECT * FROM check_balance_at_date(accounts_working.yorkshire_bank, 'yorkshire_bank', DATE '2021-12-02');


CREATE OR REPLACE VIEW accounts_working.vw_final_balance_checks AS
SELECT 
    t.account_name AS account_name,
    t.end_date AS end_date,
    t.final_balance AS final_balance,
    t1.balance_check AS final_balance_check,
    if(final_balance=final_balance_check, NULL, 'Error: mismatch') AS check_match,
FROM accounts_working.account_summaries t
JOIN accounts_working.vw_final_balances t1 ON t1.account_name = t.account_name
ORDER BY account_name;

SELECT * FROM accounts_working.vw_final_balance_checks;




--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2021-12-09')
--UNION BY NAME 
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2022-03-09')
--UNION BY NAME
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2022-04-12')
--UNION BY NAME
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2022-05-12')
--UNION BY NAME
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2023-05-03')
--UNION BY NAME
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2025-03-23')
--UNION BY NAME
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2025-03-31')
--ORDER BY check_date DESC;

--
--CREATE OR REPLACE MACRO gen_nationwide_year(yearnum) AS TABLE 
--WITH cte AS 
--    SELECT make_date(2021, t.mon, 1) as statement_date FROM generate_series(1,12,1) t(mon)
--)
--SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.nationwide, 'nationwide', DATE '2021-12-09')
--
--

--WITH cte_date_buckets0 AS (
--    SELECT
--        t.lineitem_date AS lineitem_date,
--        sum(t.credit) AS credit1, 
--        sum(t.debit) AS debit1,
--    FROM accounts_working.nationwide t
--    GROUP BY lineitem_date
--), cte_date_buckets AS (
--    SELECT 
--        t.lineitem_date, 
--        ifnull(t.credit1, 0.0) AS credit,
--        ifnull(t.debit1, 0.0) AS debit,
--        credit-debit AS daily_credit_minus_debit,
--    FROM cte_date_buckets0 t
--    -- Nationwide starts from zero
--)
--SELECT 
--    t.lineitem_date, 
--    t.debit AS "out",
--    t.credit AS "in",
--    sum(t.daily_credit_minus_debit) OVER w AS balance
--FROM cte_date_buckets t
--WINDOW w AS (
--    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--)
--ORDER BY t.lineitem_date ASC;

CREATE OR REPLACE VIEW accounts_working.vw_nationwide_check_balances AS
WITH cte_statement_balances AS (
    SELECT 
        t.lineitem_date,
        any_value(t.ledger_balance) AS balance,
    FROM accounts_working.nationwide t
    GROUP BY ALL
    ORDER BY t.lineitem_date DESC
)
SELECT 
    t.lineitem_date AS "date",  
    t.balance AS statement_balance,
    t1.balance AS summed_balance,
    if(statement_balance != summed_balance, 'Error: mistatch', NULL) AS check_balance,
FROM cte_statement_balances t
JOIN accounts_working.vw_nationwide_daily_balance t1 ON t1.lineitem_date = t.lineitem_date 
ORDER BY "date" ASC;

WITH cte_statement_balances AS (
    SELECT 
        t.lineitem_date,
        any_value(t.ledger_balance) AS balance,
    FROM accounts_working.yorkshire_bank t
    GROUP BY ALL
    ORDER BY t.lineitem_date DESC
)
SELECT 
    t.lineitem_date AS "date",  
    t.balance AS statement_balance,
    t1.balance AS summed_balance,
    if(statement_balance != summed_balance, 'Error: mistatch', NULL) AS check_balance,
FROM cte_statement_balances t
JOIN accounts_working.vw_yorkshire_bank_daily_balance t1 ON t1.lineitem_date = t.lineitem_date 
ORDER BY "date" ASC;

