INSTALL rusty_sheet FROM community;
LOAD rusty_sheet;

CREATE SCHEMA IF NOT EXISTS accounts_landing;

-- Needs variable `accounts_path` setting e.g.
-- SET VARIABLE accounts_path = '/home/___/___/___/';

CREATE OR REPLACE TABLE accounts_landing.ybs_access_saver AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'ybs_access_saver_share_ann.ods', 
    sheet = 'statements_transcript',
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.ybs_closed_savings AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'ybs_closed_savings.ods', 
    sheet = 'statements_transcript',
    header = true
);

CREATE OR REPLACE TABLE accounts_landing.ybs_funeral_expenses AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'ybs_funeral_expenses.ods', 
    sheet = 'statements_transcript',
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.ybs_triple_access_saver AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'ybs_triple_access_saver.ods', 
    sheet = 'statements_transcript',
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.ybs_two_year_frisa AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'ybs_2_year_fixed_rate_isa.ods', 
    sheet = 'statements_transcript',
    header = true
);

CREATE OR REPLACE TABLE accounts_landing.nationwide AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'nationwide.ods', 
    sheet = 'statements_transcript',
    header = true
);


CREATE OR REPLACE TABLE accounts_landing.yorkshire_bank AS
SELECT * 
FROM read_sheet(
    getvariable('accounts_path') || 'yorkshire_bank.ods', 
    sheet = 'statements_transcript',
    header = true
);

