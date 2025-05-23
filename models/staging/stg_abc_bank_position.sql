WITH
src_data as (
    SELECT
    ACCOUNTID         as ACCOUNT_CODE     -- TEXT
    , SYMBOL            as SECURITY_CODE    -- TEXT
    , DESCRIPTION       as SECURITY_NAME    -- TEXT
    , EXCHANGE          as EXCHANGE_CODE    -- TEXT
    , REPORT_DATE       as REPORT_DATE      -- DATE
    , QUANTITY          as QUANTITY         -- NUMBER
    , COST_BASE         as COST_BASE        -- NUMBER
    , POSITION_VALUE    as POSITION_VALUE   -- NUMBER
    , CURRENCY          as CURRENCY_CODE    -- TEXT
    , 'SOURCE_DATA.ABC_BANK_POSITION' as RECORD_SOURCE
FROM {{ source('abc_bank', 'ABC_BANK_POSITION') }}
),
-- we do not need a default record cause this is a fact table, that´s mean we have a table listings the events that happened or describing the state of a system and not descriptive information about an entity in that way we do not
-- need a default record.

-- the last part of our stg model is the hashed CTE
hashed as (
    SELECT 
        concat_ws('|', ACCOUNT_CODE, SECURITY_CODE) as POSITION_HKEY,
        concat_ws('|', ACCOUNT_CODE, SECURITY_CODE,
            SECURITY_NAME, EXCHANGE_CODE, REPORT_DATE,
            QUANTITY, COST_BASE, POSITION_VALUE, CURRENCY_CODE)
            as POSITION_HDIFF,
            *,
            '{{ run_started_at }}' as LOAD_TS_UTC
    FROM src_data

)

SELECT * FROM hashed