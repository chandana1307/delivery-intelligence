# Delivery Intelligence — Analytics Findings

## Overall Delivery Performance

The dataset contains 99,441 orders. Of these, 96,470 delivered orders are eligible for the late-delivery metric because both the actual and estimated delivery dates are available.

Among eligible delivered orders, 6,534 were delivered after the estimated delivery date, resulting in an observed late-delivery rate of approximately 6.77%.

## Delivery Performance Over Time

Late-delivery performance varied substantially across months.

Some of the earliest months contain very small numbers of eligible orders, which can produce extreme rates. For this reason, the Power BI monthly trend excludes months with fewer than 20 eligible delivered orders.

The dashboard should therefore be interpreted using both the observed late rate and the number of eligible orders supporting that rate.

## Geographic Variation

Late-delivery rates differed across customer states.

For example, Alabama (AL) showed an observed late-delivery rate of approximately 21.41%, while several larger-volume states had substantially lower rates.

These geographic comparisons are descriptive and should not be interpreted as evidence that customer location directly caused delivery delays.

## Promised Delivery Window

The relationship between promised lead time and late delivery was not linear.

Orders with a promised delivery window of 0–7 days had the highest observed late rate at approximately 16.90%.

Longer promised windows did not consistently correspond to higher late-delivery rates, suggesting that promised lead time should be evaluated together with other order, seller, product, and geographic characteristics.

## Seller Structure

Single-seller orders had an observed late-delivery rate of approximately 6.85%.

Orders containing multiple sellers had a lower observed late-delivery rate of approximately 1.02%.

This difference is an observed association only and does not establish that seller structure caused the difference in delivery performance.

## Seller Performance Change

Marketplace-wide late-delivery performance improved substantially between the two comparison periods.

- Prior period: February–April 2018
- Recent period: May–July 2018
- Prior late-delivery rate: approximately 12.58%
- Recent late-delivery rate: approximately 3.80%

Despite the overall improvement, several sellers with at least 20 eligible delivered orders in both periods showed worsening individual late-delivery rates.

These sellers are useful candidates for operational investigation, but the analysis does not establish that the sellers themselves caused the delays.

## Dashboard

The Power BI dashboard contains three analytical pages:

1. Delivery Performance Overview
2. Segments & Geography
3. Seller Performance Review

The dashboard supports filtering by purchase date, customer state, product category, and seller where appropriate.

Late-delivery metrics use eligible delivered orders as the denominator, while canceled and unresolved orders remain separate from the on-time/late classification.