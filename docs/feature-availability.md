# Feature Availability Register

The delivery-risk model is intended to score an order at order approval time.

Because the public dataset contains final historical records rather than a complete event-by-event history, some field availability must be treated as an explicit assumption. When availability is uncertain, the feature should be excluded or documented conservatively.

| Feature / Field | Source | Assumed Availability | Modeling Decision | Reason |
|---|---|---|---|---|
| order_purchase_timestamp | Orders | Before approval | Include derived features | Known when the order is placed |
| order_approved_at | Orders | Prediction time | Include derived features | Defines the score time |
| order_estimated_delivery_date | Orders | By approval | Include | Required to calculate promised lead time |
| promised_lead_days | Derived | By approval | Include | Derived from estimated delivery date and approval time |
| customer_state | Customers | Before approval | Include | Shipping destination assumed known when order is placed |
| customer_zip_code_prefix | Customers | Before approval | Candidate | May provide geographic information; evaluate usefulness |
| item_count | Order Items | By approval | Include | Order contents assumed known at approval |
| product_count | Order Items | By approval | Include | Order contents assumed known at approval |
| seller_count | Order Items | By approval | Include | Seller structure assumed known at approval |
| total_item_value | Order Items | By approval | Include | Purchase value assumed known at approval |
| total_freight_value | Order Items | By approval | Candidate | Include only under documented assumption that freight is known at approval |
| product_category | Products | By approval | Include | Product information associated with purchased items |
| product_weight / dimensions | Products | By approval | Candidate | Product attributes may help explain delivery complexity |
| payment_type | Payments | By approval | Candidate | Use only if payment information is confirmed available by approval |
| payment_installments | Payments | By approval | Candidate | Same availability assumption as payment type |
| payment_value | Payments | By approval | Candidate | Evaluate only if consistent with approval-time availability |
| seller historical order count | Historical outcomes | Before current score time | Include | Must use only prior outcomes already known before the current order is scored |
| seller historical late rate | Historical outcomes | Before current score time | Include | Must be calculated without future outcomes |
| seller historical average delivery time | Historical outcomes | Before current score time | Candidate | Must use only completed prior orders |
| seller history available flag | Derived | Before current score time | Include | Distinguishes new/cold-start sellers |
| category historical late rate | Historical outcomes | Before current score time | Candidate | Add only after seller-history features are validated |
| customer-state historical late rate | Historical outcomes | Before current score time | Candidate | Add only if it improves validation performance |
| order_delivered_customer_date | Orders | After approval | Exclude | Future outcome information |
| order_delivered_carrier_date | Orders | Usually after approval | Exclude | Future logistics event |
| order_status | Orders | Final record may reflect future events | Exclude | Final status creates leakage |
| delivery_days | Derived | After delivery | Exclude | Requires the future delivery outcome |
| late_delivery | Derived | After delivery | Target only | This is the prediction target |
| review_score | Reviews | After delivery | Exclude | Post-delivery information |
| review_comment_title | Reviews | After delivery | Exclude | Post-delivery information |
| review_comment_message | Reviews | After delivery | Exclude | Post-delivery information |

## Leakage Rule

No feature may use information that becomes available after the order approval timestamp.

Historical aggregate features must satisfy:

`historical_label_available_at < current_order_score_time`

It is not sufficient for a previous order to have been approved earlier; its delivery outcome must already have been known.

## Cold-Start Handling

Orders from sellers without prior eligible delivered history should not be dropped.

For those orders:

- prior seller order count = 0
- prior seller late rate = missing
- seller history available flag = 0

Missing historical rates will be handled within the preprocessing pipeline.