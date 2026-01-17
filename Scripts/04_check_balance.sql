
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
SELECT * FROM check_balance_at_date(accounts_working.yorkshire_bank, 'yorkshire_bank', DATE '2021-11-30');


-- SELECT * FROM check_balance_at_date(accounts_working.ybs_access_saver, 'Access Saver Share Ann', DATE '2018-10-26');

SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2022-02-10')
UNION BY NAME 
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2022-03-30')
UNION BY NAME
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2022-10-13')
UNION BY NAME
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2022-07-29')
UNION BY NAME
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2023-02-16')
UNION BY NAME
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2021-05-04')
UNION BY NAME
SELECT * EXCLUDE(sum_credit, sum_debit) FROM check_balance_at_date(accounts_working.ybs_access_saver, 'ybs_access_saver', DATE '2021-11-11')
ORDER BY check_date DESC;
