INSTALL rusty_sheet FROM community;
LOAD rusty_sheet;

CREATE SCHEMA IF NOT EXISTS accounts_landing;

-- Needs variable `statements_path` setting e.g.
-- SET VARIABLE statements_path = '/home/___/___/___/';


CREATE OR REPLACE MACRO read_ybs_sheet(xlsx_file) AS TABLE
SELECT * 
FROM read_sheet(
    xlsx_file :: VARCHAR,
    sheet = 'statements_transcript',
    columns={'Withdrawals': 'DECIMAL', 'Receipts': 'DECIMAL', 'Ledger Balance': 'DECIMAL'},
    header = true
);

CREATE OR REPLACE TABLE accounts_landing.ybs_access_saver AS
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_access_saver_share_ann.xlsx');

CREATE OR REPLACE TABLE accounts_landing.ybs_closed_savings AS
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_closed_savings.xlsx');

CREATE OR REPLACE TABLE accounts_landing.ybs_funeral_expenses AS
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_funeral_expenses.xlsx');

CREATE OR REPLACE TABLE accounts_landing.ybs_triple_access_saver AS
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_triple_access_saver.xlsx');

CREATE OR REPLACE TABLE accounts_landing.ybs_two_year_frisa AS
SELECT * FROM read_ybs_sheet(getvariable('statements_path') || 'ybs_2_year_fixed_rate_isa.xlsx');


CREATE OR REPLACE TABLE accounts_landing.nationwide AS
SELECT * 
FROM read_sheet(
    getvariable('statements_path') || 'nationwide_current_account.xlsx', 
    sheet = 'statements_transcript',
    columns={'Out': 'DECIMAL', 'In': 'DECIMAL', 'Balance': 'DECIMAL'},
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.yorkshire_bank AS
SELECT * 
FROM read_sheet(
    getvariable('statements_path') || 'yorkshire_bank_current_account.xlsx', 
    sheet = 'statements_transcript',
    columns={'Debits': 'DECIMAL', 'Credits': 'DECIMAL', 'Balance': 'DECIMAL'},
    header = true
);




CREATE OR REPLACE TABLE accounts_landing.account_summaries AS
SELECT * 
FROM read_sheet(
    getvariable('statements_path') || 'account_summaries.xlsx', 
    sheet = 'Account_summaries',
    columns={'Final Balance': 'DECIMAL'},
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.destination_accounts AS
SELECT * 
FROM read_sheet(
    getvariable('statements_path') || 'account_summaries.xlsx', 
    sheet = 'Destination_accounts',
    columns={'Final Balance': 'DECIMAL'},
    header = true
);



