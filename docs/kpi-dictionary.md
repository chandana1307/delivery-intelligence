# KPI Dictionary

## Late Delivery

**Definition**

A delivered order is classified as late when its actual customer delivery
calendar date is later than its estimated delivery calendar date.

**Formula**

Late Delivery =
actual delivery date > estimated delivery date

**Eligible population**

Orders where:

- `order_status = 'delivered'`
- actual customer delivery timestamp is available
- estimated delivery date is available

Canceled and unresolved orders are excluded from the late/on-time denominator
and reported separately.

---

## Late Delivery Rate

**Definition**

Percentage of eligible delivered orders that arrived after the estimated
delivery calendar date.

**Formula**

Late Delivery Rate =
Late Orders / Eligible Delivered Orders × 100

**Overall observed rate**

6,534 late orders out of 96,470 eligible delivered orders,
approximately 6.77%.

---

## Delivery Days

**Definition**

Calendar days between order purchase and actual customer delivery.

**Formula**

Delivery Days =
Actual Delivery Date - Purchase Date

Used only when an actual customer delivery date is available.

---

## Promised Lead Days

**Definition**

Calendar days between order purchase and the estimated delivery date.

**Formula**

Promised Lead Days =
Estimated Delivery Date - Purchase Date

---

## Monthly Late Delivery Rate

**Definition**

Late-delivery rate for orders grouped by purchase month.

The denominator is the number of eligible delivered orders purchased
during that month.

Sample counts should always be displayed with the rate.

---

## State Late Delivery Rate

**Definition**

Late-delivery rate grouped by customer state.

The metric is descriptive and should not be interpreted as evidence that
customer geography causes delivery delays.

Display eligible order count with the rate.

---

## Seller Count

**Definition**

Number of distinct sellers represented within an order.

Orders are categorized as:

- Single seller
- Multiple sellers
- No item record

---

## Seller Performance Deterioration

**Definition**

Change in a seller's late-delivery rate between two comparable time periods.

Current comparison:

- Prior period: February-April 2018
- Recent period: May-July 2018

**Formula**

Late Rate Change (percentage points) =
Recent Late Rate - Prior Late Rate

Positive values indicate worsening observed performance.

Only sellers with at least 20 eligible delivered orders in both periods
are included in the current comparison.

This metric is descriptive and identifies sellers for investigation;
it does not establish that a seller caused the delays.

---

## Overall Period Benchmark

For the seller-comparison periods:

| Period | Eligible Orders | Late Orders | Late Rate |
| --- | ---: | ---: | ---: |
| Prior | 20,356 | 2,560 | 12.58% |
| Recent | 19,001 | 722 | 3.80% |

Overall late-delivery performance improved by 8.78 percentage points between
the two periods.

Seller deterioration should therefore be interpreted in the context of this
broader marketplace improvement.