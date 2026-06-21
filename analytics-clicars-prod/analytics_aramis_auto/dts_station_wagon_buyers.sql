CREATE OR REPLACE VIEW analytics_aramis_auto.dts_station_wagon_buyers AS (

WITH customer_requests AS (
  SELECT
    cr.customer_id
  , cr.request_type
  , cr.request_date
  , cr.request_datetime
  , cr.vehicle_type
  , cr.product
  , cr.price
  , cr.trade_in
  , cr.sale
  , c.gender
  , c.age
  , ROW_NUMBER() OVER (
      PARTITION BY cr.customer_id
      ORDER BY cr.request_datetime DESC
    ) AS most_recent_request
  FROM `clicars-analytics-prod.curated_aramis_auto.customer_requests`  cr
  LEFT JOIN `curated_aramis_auto.customer` c
    ON c.customer_id = cr.customer_id
)

, base_customer_features as (
  SELECT
  customer_id,
  gender,
  age,
  CASE WHEN LOGICAL_OR(vehicle_type='nv') is true THEN 1 ELSE 0 END AS searched_nv,
  CASE WHEN LOGICAL_OR(vehicle_type='uv') is true THEN 1 ELSE 0 END AS searched_uv,


  CASE WHEN LOGICAL_OR(product='Station_wagon') is true THEN 1 ELSE 0 END AS searched_station_wagon,
  CASE WHEN LOGICAL_OR(product='SUV') is true THEN 1 ELSE 0 END AS searched_suv,
  CASE WHEN LOGICAL_OR(product='Family_car') is true THEN 1 ELSE 0 END AS searched_family_car,
  CASE WHEN LOGICAL_OR(product='City_car') is true THEN 1 ELSE 0 END AS searched_city_car,
  CASE WHEN LOGICAL_OR(product='Compact_city_car') is true THEN 1 ELSE 0 END AS searched_compact_city_car,
  CASE WHEN LOGICAL_OR(product='Hatchback') is true THEN 1 ELSE 0 END AS searched_hatchback,
  CASE WHEN LOGICAL_OR(product='MPV') is true THEN 1 ELSE 0 END AS searched_mpv,
  COUNTIF(product='Station_wagon') AS station_wagon_requests,
  COUNTIF(product='SUV') AS suv_requests,
  COUNTIF(product='Family_car') AS family_car_requests,
  COUNTIF(product='City_car') AS city_car_requests,
  COUNTIF(product='Compact_city_car') AS compact_city_car_requests,
  COUNTIF(product='Hatchback') AS hatchback_requests,
  COUNTIF(product='MPV') AS mpv_requests,
  MIN(request_date) AS first_contact,
  MAX(request_date) AS last_contact,
  DATE_DIFF(MAX(request_date), MIN(request_date), DAY) AS first_to_last_contact,
  COUNT(DISTINCT CASE WHEN request_type = 'valuation' THEN request_datetime END) AS total_valuation_requests,
  COUNT(DISTINCT CASE WHEN request_type = 'quote' THEN request_datetime END) AS total_quote_requests,
  COUNT(request_datetime) AS total_requests,
  LOGICAL_OR(sale) AS has_sale,
  MAX(
    CASE
      WHEN most_recent_request = 1
           AND sale = TRUE
           AND product = 'Station_wagon'
      THEN 1
      ELSE 0
    END
  ) AS last_request_is_station_wagon_sale
  , MAX(
    CASE
      WHEN sale = TRUE
           AND product = 'Station_wagon'
      THEN 1
      ELSE 0
    END
  ) AS bought_station_wagon

FROM customer_requests
GROUP BY customer_id, gender, age
)

, base_session_info as (
  SELECT 
  customer_id
  , count(distinct session_id) as sessions
  , count(distinct page_name) as total_pages
  , string_agg(DISTINCT page_name, ", ") as distinct_pages
  , string_agg(DISTINCT page_category, ", ") as distinct_page_categories
   FROM `clicars-analytics-prod.curated_aramis_auto.customer_web_navigation` 
group by 1 order by 2 desc
)

, dts_station_wagon_buyers as (
  SELECT
    bcf.customer_id
  , bcf.gender
  , bcf.age
  , searched_nv
  , searched_uv
  , searched_station_wagon
  , searched_suv
  , searched_family_car
  , searched_city_car
  , searched_compact_city_car
  , searched_hatchback
  , searched_mpv
  , station_wagon_requests
  , suv_requests
  , family_car_requests
  , city_car_requests
  , compact_city_car_requests
  , hatchback_requests
  , mpv_requests
  , bcf.first_contact
  , bcf.last_contact
  , bcf.first_to_last_contact
  , bcf.has_sale
  , bcf.bought_station_wagon AS station_wagon_buyer
  , bcf.last_request_is_station_wagon_sale
  , bcf.total_quote_requests
  , bcf.total_valuation_requests
  , bcf.total_requests
  , sessions
  , total_pages
  , distinct_pages
  , distinct_page_categories
FROM base_customer_features bcf

LEFT JOIN base_session_info bsi
  ON bcf.customer_id = bsi.customer_id
)


SELECT
    customer_id
  , gender
  , age
  , searched_nv
  , searched_uv
  , searched_station_wagon
  , searched_suv
  , searched_family_car
  , searched_city_car
  , searched_compact_city_car
  , searched_hatchback
  , searched_mpv
  , station_wagon_requests
  , suv_requests
  , family_car_requests
  , city_car_requests
  , compact_city_car_requests
  , hatchback_requests
  , mpv_requests
  , first_contact
  , last_contact
  , first_to_last_contact
  , has_sale
  , station_wagon_buyer 
  , last_request_is_station_wagon_sale
  , total_quote_requests
  , total_valuation_requests
  , total_requests
  , sessions
  , total_pages
  , distinct_pages
  , distinct_page_categories

FROM dts_station_wagon_buyers

WHERE 1=1
    AND has_sale is false 
    AND (
    searched_station_wagon = 1 or
    searched_family_car = 1 or
    searched_suv = 1 or
    searched_nv = 1 or
    searched_mpv = 1 or
    searched_uv = 1) 
    AND age > 44
    AND total_quote_requests > 3
    AND total_valuation_requests < 1
    AND sessions >= 7
  )
