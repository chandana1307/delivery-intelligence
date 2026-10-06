# Data Audit Findings

## Dataset overview

The audit covers the nine CSV files from the Brazilian E-Commerce Public Dataset by Olist.

The orders table contains 99,441 orders covering purchases from
2016-09-04 through 2018-10-17.

## Table structure and relationships

### Orders
- 99,441 rows
- 99,441 unique `order_id` values
- Grain: one row per order
- Primary key: `order_id`

### Customers
- 99,441 rows
- 99,441 unique `customer_id` values
- 96,096 unique `customer_unique_id` values
- Every order has a matching customer record
- `customer_unique_id` should be used when identifying repeat customers

### Order items
- 112,650 rows
- 98,666 unique orders
- Grain: one row per item within an order
- Natural key: (`order_id`, `order_item_id`)
- Maximum of 21 items in one order
- 9,803 orders contain more than one item
- 775 orders have no item records
- Orders without item records consist of unavailable, canceled, created,
  invoiced, or shipped orders; none are delivered

### Sellers within orders
- 97,388 orders contain one seller
- 1,219 orders contain two sellers
- 54 orders contain three sellers
- 3 orders contain four sellers
- 2 orders contain five sellers
- 1,278 orders contain more than one seller

Because multi-seller orders exist, seller information must be aggregated
before joining to an order-level analytical dataset.

### Payments
- 103,886 payment rows
- 99,440 unique orders
- 2,961 orders contain multiple payment rows
- Maximum of 29 payment rows for one order
- One delivered order has no payment record

### Products
- 32,951 rows
- `product_id` is unique
- 610 products are missing category and related descriptive attributes
- 2 products are missing physical dimension/weight fields

### Reviews
- 99,224 review rows
- 98,673 unique orders
- 547 orders contain multiple review rows
- Maximum of 3 review rows for one order
- Review title and message fields contain substantial missingness
- Reviews are retrospective information and are not eligible for an
  approval-time delivery-risk model

### Sellers
- 3,095 sellers
- `seller_id` is unique
- All seller IDs referenced by order items match a seller record

### Geolocation
- 1,000,163 rows
- 261,831 exact duplicate rows
- 19,015 unique ZIP-code prefixes
- Most ZIP-code prefixes occur multiple times
- Maximum of 1,146 geolocation rows for a single ZIP prefix

The raw geolocation table should not be joined directly to the order-level
dataset. A representative or aggregated geographic record must first be
created for each ZIP-code prefix.

## Order status

Order status counts:

- Delivered: 96,478
- Shipped: 1,107
- Canceled: 625
- Unavailable: 609
- Invoiced: 314
- Processing: 301
- Created: 5
- Approved: 2

Canceled and unresolved orders should be reported separately rather than
automatically classified as on-time deliveries.

## Timestamp quality

Missing timestamp counts:

- `order_purchase_timestamp`: 0
- `order_approved_at`: 160
- `order_delivered_carrier_date`: 1,783
- `order_delivered_customer_date`: 2,965
- `order_estimated_delivery_date`: 0

Lifecycle ordering checks identified:

- 1,359 records where carrier handoff occurs before recorded approval
- 23 records where customer delivery occurs before recorded carrier handoff
- No records where approval occurs before purchase

These anomalies indicate that the event timestamps should not be assumed to
form a perfectly ordered operational event log.

## Proposed late-delivery label

There are 96,478 delivered orders.

Of these:
- 96,470 have both an actual customer-delivery timestamp and an estimated
  delivery date
- 8 delivered orders are missing the actual delivery timestamp
- All estimated delivery timestamps occur at exactly midnight

Because estimated delivery timestamps appear to represent calendar dates
rather than exact midnight deadlines, the proposed label is:

`late = actual delivery calendar date > estimated delivery calendar date`

Using this definition:

- Eligible delivered orders: 96,470
- Late orders: 6,534
- Late-delivery rate: approximately 6.77%

This label should initially be evaluated only on delivered orders with both
required timestamps. Canceled and unresolved orders remain separate.

## Dataset-end maturity

Orders near the end of the dataset include delivered, canceled, shipped,
invoiced, and unavailable records.

This means some late-period orders may not have reached a final observable
delivery outcome by the dataset cutoff. Time-based model evaluation must
therefore account for label maturity when defining training cutoffs.

## Proposed prediction point

The initial proposed prediction point is order approval.

This remains an assumption because the public Olist dataset is a final
historical snapshot and does not provide a complete field-level change log.
Feature availability must therefore be explicitly documented.

## Feature availability register

| Information | Approval-time model | Reason |
| --- | --- | --- |
| Purchase timestamp | Yes | Occurs before approval |
| Approval timestamp | Yes | Defines the proposed score time |
| Estimated delivery date | Assumed yes | Required to determine promised delivery window; availability assumption must be documented |
| Order item count | Assumed yes | Derived from order contents expected to exist by approval |
| Price total | Assumed yes | Derived from order-item information |
| Freight total | Assumed yes | Derived from order-item information |
| Product attributes | Assumed yes | Static product information |
| Customer geography | Assumed yes | Associated with the order/customer record |
| Seller geography | Assumed yes | Static seller information |
| Historical seller performance | Yes, with temporal controls | Only outcomes known strictly before the current order's score time may be used |
| Carrier delivery timestamp | No | Future event |
| Customer delivery timestamp | No | Future event and part of the target |
| Final order status | No | Contains future outcome information |
| Review score/comments | No | Created after the order and delivery process |

## Key modelling constraint

The final analytical and prediction dataset must maintain one row per order.

Order items, sellers, payments, reviews, and geolocation must therefore be
aggregated or transformed before they are joined to the order-level dataset.