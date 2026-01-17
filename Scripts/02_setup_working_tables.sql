
-- Macros and DDL...

CREATE SCHEMA IF NOT EXISTS accounts_working;

CREATE OR REPLACE MACRO gen_transaction_id(item_date, row_id) AS
    (date_part('year', item_date) * 10000000) + (date_part('month', item_date) * 100000) + (date_part('day', item_date) * 1000) +  row_id;

CREATE OR REPLACE MACRO gen_ybs_transaction_id(page_number, row_id) AS
    10000000 - (page_number * 100) - row_id;

CREATE OR REPLACE MACRO get_ybs_data(table_name) AS TABLE
SELECT 
    gen_ybs_transaction_id(t."Page", t."Row") AS transaction_id,
    t."Processed Date" AS lineitem_date,
    t."Method of Payment" AS description,
    abs(t."Withdrawals") AS debit,
    t."Receipts" AS credit,
    t."Ledger Balance" AS ledger_balance,
    t."Category" AS category,
    t."Comment" AS comment,  
    t."Page" AS statement_or_page_number, 
    t."Row" AS line_number,
FROM query_table(table_name::VARCHAR) t
WHERE t."Page" > 0 AND t."Row" > 0
ORDER BY transaction_id DESC;

CREATE OR REPLACE TABLE accounts_working.nationwide (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);

CREATE OR REPLACE TABLE accounts_working.yorkshire_bank (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);


CREATE OR REPLACE TABLE accounts_working.ybs_access_saver (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);


CREATE OR REPLACE TABLE accounts_working.ybs_closed_savings (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);



CREATE OR REPLACE TABLE accounts_working.ybs_funeral_expenses (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);


CREATE OR REPLACE TABLE accounts_working.ybs_triple_access_saver (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);

CREATE OR REPLACE TABLE accounts_working.ybs_two_year_frisa (
    transaction_id BIGINT NOT NULL,
    lineitem_date DATE NOT NULL,
    description TEXT NOT NULL,
    debit DECIMAL,
    credit DECIMAL,
    ledger_balance DECIMAL,
    category TEXT,
    comment TEXT,
    statement_or_page_number INTEGER,
    line_number INTEGER,
    PRIMARY KEY(transaction_id)
);


CREATE OR REPLACE TABLE accounts_working.account_summaries (
    account_number BIGINT NOT NULL,
    institution TEXT NOT NULL,
    account_name TEXT NOT NULL,
    starting_balance DECIMAL,
    final_balance DECIMAL,
    opening_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    comment TEXT,
    PRIMARY KEY(account_number)
);


CREATE OR REPLACE TABLE accounts_working.destination_accounts (
    account_number BIGINT NOT NULL,
    account_holder TEXT NOT NULL,
    comment TEXT,
    PRIMARY KEY(account_number)
);


-- Insert data...


INSERT INTO accounts_working.nationwide BY NAME
SELECT 
    gen_transaction_id(t."Date", t."Row") AS transaction_id,
    t."Date" AS lineitem_date,
    t."Description" AS description,
    t."Out" AS debit,
    t."In" AS credit,
    t."Balance" AS ledger_balance,
    t."Category" AS category,
    t."Comment" AS comment,  
    t."Statement" AS statement_or_page_number, 
    t."Row" AS line_number,
FROM accounts_landing.nationwide t
WHERE t."Statement" > 0 AND t."Row" > 0
ORDER BY transaction_id DESC;

INSERT INTO accounts_working.yorkshire_bank BY NAME
SELECT 
    gen_transaction_id(t."Date", t."Row") AS transaction_id,
    t."Date" AS lineitem_date,
    t."Description" AS description,
    t."Debits" AS debit,
    t."Credits" AS credit,
    t."Balance" AS ledger_balance,
    t."Category" AS category,
    t."Comment" AS comment,  
    t."Statement" AS statement_or_page_number, 
    t."Row" AS line_number,
FROM accounts_landing.yorkshire_bank t
WHERE t."Statement" > 0 AND t."Row" > 0
ORDER BY transaction_id DESC;

INSERT INTO accounts_working.ybs_access_saver BY NAME
SELECT * FROM get_ybs_data(accounts_landing.ybs_access_saver);

INSERT INTO accounts_working.ybs_closed_savings BY NAME
SELECT * FROM get_ybs_data(accounts_landing.ybs_closed_savings);

INSERT INTO accounts_working.ybs_funeral_expenses BY NAME
SELECT * FROM get_ybs_data(accounts_landing.ybs_funeral_expenses);

INSERT INTO accounts_working.ybs_triple_access_saver BY NAME
SELECT * FROM get_ybs_data(accounts_landing.ybs_triple_access_saver);

INSERT INTO accounts_working.ybs_two_year_frisa BY NAME
SELECT * FROM get_ybs_data(accounts_landing.ybs_two_year_frisa);



INSERT INTO accounts_working.account_summaries BY NAME
SELECT
    t."Account Number" AS account_number,
    t."Institution" AS institution,
    t."Account Name" AS account_name,
    t."Starting Balance" AS starting_balance,
    t."Final Balance" AS final_balance,
    t."Open Date" AS opening_date,
    t."Start Date" AS start_date,
    t."End Date" AS end_date,
    t."Comment" AS comment,
FROM accounts_landing.account_summaries t
WHERE t."Account Number" IS NOT NULL;


INSERT INTO accounts_working.destination_accounts BY NAME
SELECT
    t."Account Number" AS account_number,
    t."Account Holder" AS account_holder,
    t."Comment" AS comment,
FROM accounts_landing.destination_accounts t
WHERE t."Account Number" IS NOT NULL;


