# First analysis plan

## Source and acquisition

Official source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

Download through the official dataset page or its supported API. Check the current licence and any attribution or public-demo restrictions before redistributing records. Authentication requirements and downloadable files still need to be verified. Do not substitute an unattributed mirror.

Record dataset version, acquisition date, source URL, file sizes, SHA-256 checksums, licence text or reference, and required attribution. Keep original files under `data/raw/` and derived files under `data/processed/`; both are excluded from Git.

## Expected files to verify

- Orders
- Order items
- Customers
- Sellers
- Products
- Payments
- Reviews
- Geolocation
- Product category translations

Treat this inventory as provisional until the download is inspected.

## Audit checks

1. Identify each table's grain and keys, including the distinction between customer IDs used by orders and identifiers linking repeat customers.
2. Measure row counts, unique keys, duplicate keys, missing values, and unmatched foreign keys.
3. Inspect timestamp parsing, temporal coverage, ordering of lifecycle timestamps, and available timezone information.
4. Count delivered, cancelled, unavailable, and unresolved orders. Check outcome maturity near the dataset end.
5. Inspect promised dates and actual delivery timestamps before selecting calendar-date label semantics.
6. Check item counts, multiple sellers, multiple payments, and multiple reviews per order. Aggregate separately before joining.
7. Check unusual prices, freight charges, dimensions, and geographic coverage.
8. Assess whether historical seller rates can be computed with sufficient observations using only outcomes already known at prediction time.

## First SQL analysis

| Question | Required care |
| --- | --- |
| What proportion of eligible delivered orders arrived late each month? | Define the date grouping and denominator; report excluded orders |
| How does delivery duration vary by region? | Include sample sizes and distribution summaries, not only means |
| Which sellers show worsening performance? | Apply volume thresholds and compare equivalent windows |
| How do promised delivery windows relate to lateness? | Separate association from causal interpretation |
| How do multi-seller orders differ from single-seller orders? | Maintain one row per order |
| How do reviews vary with delivery performance? | Retrospective analysis only; reviews are unavailable to the approval-time model |

## Proposed feature availability register

For every candidate field, record its source, transformation, assumed availability time, missing-data handling, and justification.

Potential candidates, subject to verification: purchase/approval calendar features, promised lead time, item count, price and freight totals, product characteristics, buyer/seller geography, and historical seller performance.

Exclude actual delivery timestamps, future shipping events, reviews, final order status, and aggregates containing future outcomes from approval-time features. Some source fields may be updated after approval; document uncertainty or exclude them.

## Deliverables

- A machine-readable source manifest and quality summary.
- A human-readable report with the principal limitations.
- An order-level analytical view and KPI dictionary.
- Initial charts with evidence-backed observations.
- A decision on whether the proposed prediction point and target are supportable.
