# clicars-data-analytics-sw-case

# Clicars — Station Wagon Targeting Case

Data Analyst use case: identifying which customer segments to prioritize to accelerate
station wagon inventory turnover, using real customer data.

## Business problem

Station wagon stock is aging. Marketing's first move — email and phone outreach to
customers who had already requested a station wagon quote — wasn't enough to move it on
its own. This project answers, with data instead of assumptions:

> **Which customer segments should we prioritize to sell the station wagon inventory as
> fast as possible?**

## Data

All analysis runs on a real extract of **4,121 engaged customers** from
`clicars-analytics-prod`, built from three source tables in BigQuery:

<img width="1018" height="354" alt="image" src="https://github.com/user-attachments/assets/a9c0d5ff-f7d6-427a-b0b8-893325e527aa" />

| Table | Layer | Content |
|---|---|---|
| `raw_aramis_auto.quotes_valuations` | Raw | Quote and trade-in valuation requests |
| `raw_aramis_auto.mails_incoming_calls` | Raw | Mails and Phone Calls from Customers |
| `raw_aramis_auto.customer_account` | Raw | Customer demographics |
| `raw_aramis_auto.navigation` | Raw | Website session/page activity |
| `curated_aramis_auto.customer_requests` | Curated | Cleaned, joined request log |
| `curated_aramis_auto.inbound_contacts` | Curated | Mails and Phone Calls from Customers |
| `curated_aramis_auto.customer` | Curated | All customers and related data |
| `curated_aramis_auto.customer_web_navigation` | Curated | Cleaned navigation log |
| `analytics_aramis_auto.dts_station_wagon_buyers` | Analytics | Final customer-level feature table used for modeling |

Of the 4,121 customers: **104 bought a station wagon** (2.52%), 289 bought a different
vehicle, and 3,728 never converted.

## Approach

1. **Data modeling (SQL / BigQuery)** — join requests, demographics, and navigation into
   one row per customer, with engineered features: search flags by vehicle category,
   request counts by type, quote vs. valuation volume, session activity, and the
   `station_wagon_buyer` target label.
2. **Propensity scoring** — apply the model to the customers who never bought a wagon,
   to rank and prioritize outreach to the highest-propensity, never-targeted prospects.

## Key findings

**1. Conversion rises sharply with age.**  88-89% of buyers are 44+. This is the strongest
demographic lever and the second-strongest factor in the controlled model.

**2. Quote-request volume is the strongest behavioral signal.** SW Buyers request a median
of 7 quotes before purchase vs. 2 for the rest of the base.

**3. Buyers search broadly, not narrowly.** Station wagon buyers also search SUV (60%),
family car (66%), and MPV (50%) at 1.9–2.6x the rate of non-buyers — they're actively
cross-shopping practical body styles, not arriving at wagons through a closed niche.

**4. Heavy trade-in shoppers convert *less*, not more.** Buyers request well under 1
valuation on average, vs. 2.82 for non-buyers (an 8x gap) — and this is the strongest
negative effect in the controlled model. Combined with the high quote volume,
this points to a likely second-car or additional-vehicle buyer profile, not someone
replacing and trading in their primary car. **Don't lead outreach with a trade-in
offer for this audience.**

Gender showed no meaningful difference in conversion and was not used as a targeting
variable.

## From findings to a target list

```sql

FROM dts_station_wagon_buyers
WHERE 1=1
  AND has_sale is false
  AND station_wagon_buyer = 0
  AND (
    searched_station_wagon = 1 or
    searched_family_car   = 1 or
    searched_suv          = 1 or
    searched_nv            = 1 or
    searched_mpv           = 1 or
    searched_uv             = 1
  )
  AND age > 44
  AND total_quote_requests > 3
  AND total_valuation_requests < 1
  AND sessions >= 7
```

Applied to the 3,970 customers who never bought a station wagon, this returns **562
prospects** — customers who look like the buyer profile above (older, high quote
intent, low trade-in activity, broad practical-vehicle interest) but were never
included in the original outreach.

## Recommendation
1. **Prioritize the 562** — age 44+, high prior quote volume, ranked by behavior, not guessed.
2. **Lead with quote-relevant offers, not trade-in** — save buyback messaging for a separate campaign aimed at the (different) heavy-valuation segment.
3. **Re-score periodically** — as new requests and navigation data come in, refresh the ranked list rather than treating it as static.



## Tools
BigQuery (SQL) for data modeling · Python for ETL · Excel for
statistical analysis · Google Colab for the executable notebook.
