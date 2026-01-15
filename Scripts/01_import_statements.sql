INSTALL rusty_sheet FROM community;
LOAD rusty_sheet;

CREATE SCHEMA IF NOT EXISTS accounts_landing;

-- Needs variable `accounts_path` setting e.g.
-- SET VARIABLE accounts_path = '/home/___/___/___/';


CREATE OR REPLACE MACRO read_ybs_sheet(xlsx_file) AS TABLE
SELECT * 
FROM read_sheet(
    xlsx_file :: VARCHAR,
    sheet = 'statements_transcript',
    columns={'Withdrawals': 'DECIMAL', 'Receipts': 'DECIMAL', 'Ledger Balance': 'DECIMAL'},
    header = true
);

CREATE OR REPLACE TABLE accounts_landing.ybs_access_saver AS
SELECT * FROM read_ybs_sheet(getvariable('accounts_path') || 'ybs_access_saver_share_ann.ods');

CREATE OR REPLACE TABLE accounts_landing.ybs_closed_savings AS
SELECT * FROM read_ybs_sheet(getvariable('accounts_path') || 'ybs_closed_savings.ods');

CREATE OR REPLACE TABLE accounts_landing.ybs_funeral_expenses AS
SELECT * FROM read_ybs_sheet(getvariable('accounts_path') || 'ybs_funeral_expenses.ods');

CREATE OR REPLACE TABLE accounts_landing.ybs_triple_access_saver AS
SELECT * FROM read_ybs_sheet(getvariable('accounts_path') || 'ybs_triple_access_saver.ods');

CREATE OR REPLACE TABLE accounts_landing.ybs_two_year_frisa AS
SELECT * FROM read_ybs_sheet(getvariable('accounts_path') || 'ybs_2_year_fixed_rate_isa.ods');


CREATE OR REPLACE TABLE accounts_landing.nationwide AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'nationwide.ods', 
    sheet = 'statements_transcript',
    columns={'Out': 'DECIMAL', 'In': 'DECIMAL', 'Balance': 'DECIMAL'},
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.yorkshire_bank AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'yorkshire_bank.ods', 
    sheet = 'statements_transcript',
    columns={'Debits': 'DECIMAL', 'Credits': 'DECIMAL', 'Balance': 'DECIMAL'},
    header = true
);




CREATE OR REPLACE TABLE accounts_landing.account_summaries AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'account_summaries.ods', 
    sheet = 'Account_summaries',
    columns={'Final Balance': 'DECIMAL'},
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.destination_accounts AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'account_summaries.ods', 
    sheet = 'Destination_accounts',
    columns={'Final Balance': 'DECIMAL'},
    header = true
);



