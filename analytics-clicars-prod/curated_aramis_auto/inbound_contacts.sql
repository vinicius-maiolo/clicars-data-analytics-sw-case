CREATE OR REPLACE TABLE `curated_aramis_auto.inbound_contacts` as (
  SELECT
    REPLACE(CAST(phone_number AS STRING), '.0', '') AS phone_number 
    , LOWER(TRIM(e_email)) as email
    , LOWER(TRIM(type)) AS contact_type
    , DATE(PARSE_DATETIME('%d/%m/%Y %H:%M', date)) AS contact_date
    , PARSE_DATETIME('%d/%m/%Y %H:%M', date) AS contact_datetime
    
  FROM `raw_aramis_auto.mails_incoming_calls`
)