CREATE OR REPLACE TABLE `clicars-analytics-prod.curated_aramis_auto.customer_web_navigation` AS (
    SELECT
        session_id
        , id_customer AS customer_id
        , PARSE_DATETIME('%d/%m/%Y %H:%M', dt) AS navigation_datetime
        , DATE(PARSE_DATETIME('%d/%m/%Y %H:%M', dt)) AS navigation_date
        , TRIM(url) AS url
        , LOWER(TRIM(page_name)) AS page_name
        , CASE
            WHEN LOWER(page_name) LIKE '%faq%' THEN 'FAQ'
            WHEN LOWER(page_name) LIKE '%homepage%' THEN 'Home'
            WHEN LOWER(page_name) LIKE '%product%' THEN 'Product'
            WHEN LOWER(page_name) LIKE '%quote%' THEN 'Quote'
            WHEN LOWER(page_name) LIKE '%search%' THEN 'Search'
            WHEN LOWER(page_name) LIKE '%trade_in%' THEN 'Trade-In'
            ELSE 'other'
          END AS page_category

    FROM `clicars-analytics-prod.raw_aramis_auto.navigation`
)