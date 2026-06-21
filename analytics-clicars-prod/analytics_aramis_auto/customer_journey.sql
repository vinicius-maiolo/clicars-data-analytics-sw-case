CREATE OR REPLACE VIEW `clicars-analytics-prod.analytics_aramis_auto.customer_journey` AS (

  SELECT
      c.customer_id
      , c.gender  
      , c.age
      , cr.request_type
      , COUNT(DISTINCT cr.request_datetime) AS quotes
      , SUM(CASE 
              WHEN cr.sale = true 
              THEN 1 
              ELSE 0 
            END) AS purchases
      , SUM(CASE 
              WHEN cr.trade_in = true 
              THEN 1 
              ELSE 0 
            END) AS tradeins
      , AVG(cr.price) AS avg_price
      , COUNT(DISTINCT wn.session_id) AS sessions
      , COUNT(wn.page_name) AS pages
      , COUNT(distinct wn.page_name) AS distinct_pages
      , SUM(CASE 
            WHEN ic.contact_type = 'email' 
            THEN 1 
          END) total_inbound_mails
      , SUM(CASE 
            WHEN ic.contact_type = 'call' 
            THEN 1 
          END) total_inbound_calls

  FROM `clicars-analytics-prod.curated_aramis_auto.customer` c

  LEFT JOIN `clicars-analytics-prod.curated_aramis_auto.customer_requests` cr
  ON c.customer_id = cr.customer_id

  LEFT JOIN `clicars-analytics-prod.curated_aramis_auto.inbound_contacts` ic
  ON CAST(c.phone_number AS STRING)  = ic.phone_number
  OR c.email = ic.email

  LEFT JOIN `clicars-analytics-prod.curated_aramis_auto.customer_web_navigation` wn
  ON c.customer_id = wn.customer_id

  GROUP BY 1,2,3,4
)

