CREATE OR REPLACE TABLE `clicars-analytics-prod.curated_aramis_auto.customer_requests` AS (
  SELECT
      customer_id,
      LOWER(TRIM(type)) AS request_type,
      DATE(PARSE_DATETIME('%d/%m/%Y %H:%M', dt)) AS request_date,
      PARSE_DATETIME('%d/%m/%Y %H:%M', dt) AS request_datetime,
      LOWER(TRIM(vehicle_type)) AS vehicle_type,
      TRIM(product) AS product,
      CAST(price AS NUMERIC) AS price,
      CAST(trade_in AS BOOL) AS trade_in,
      CAST(sale AS BOOL) AS sale   

  FROM `clicars-analytics-prod.raw_aramis_auto.quotes_valuations`
)


