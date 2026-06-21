CREATE OR REPLACE TABLE `clicars-analytics-prod.curated_aramis_auto.customer` AS (
  SELECT
    customer_id
    , TRIM(name) AS name
    , gender
    , CAST(phone_number AS STRING) AS phone_number
    , LOWER(TRIM(email)) AS email
    , PARSE_DATE('%d/%m/%Y', date_of_birth) AS date_of_birth
    , DATE_DIFF(CURRENT_DATE(), PARSE_DATE('%d/%m/%Y', date_of_birth),year) as age
  FROM `clicars-analytics-prod.raw_aramis_auto.customer_account`
)


