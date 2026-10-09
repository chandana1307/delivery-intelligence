CREATE OR REPLACE VIEW analytics.ml_order_base AS
SELECT
    od.order_id,

    -- Timing
    od.order_purchase_timestamp,
    od.order_approved_at AS score_time,
    od.order_delivered_customer_date AS label_available_at,
    od.order_estimated_delivery_date,

    -- Customer geography
    od.customer_state,
    od.customer_zip_code_prefix,

    -- Order structure
    od.item_count,
    od.product_count,
    od.seller_count,

    -- Order value
    od.total_item_value,
    od.total_freight_value,
    od.total_order_value,

    -- Payment summary
    od.payment_record_count,
    od.payment_type_count,
    od.max_payment_installments,
    od.total_payment_value,

    -- Data availability flags
    od.has_item_record,
    od.has_payment_record,

    -- Time from purchase to approval
    CASE
        WHEN od.order_purchase_timestamp IS NOT NULL
         AND od.order_approved_at IS NOT NULL
        THEN
            EXTRACT(
                EPOCH FROM (
                    od.order_approved_at
                    - od.order_purchase_timestamp
                )
            ) / 3600.0
    END AS purchase_to_approval_hours,

    -- Promised delivery window as known at approval time
    CASE
        WHEN od.order_approved_at IS NOT NULL
         AND od.order_estimated_delivery_date IS NOT NULL
        THEN
            od.order_estimated_delivery_date::date
            - od.order_approved_at::date
    END AS promised_lead_days_approval,

    -- Target metadata
    od.eligible_for_late_label,
    od.late_delivery,

    -- Primary Stage 3 modeling population
    CASE
        WHEN od.eligible_for_late_label = TRUE
         AND od.order_approved_at IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS ml_eligible

FROM analytics.order_delivery od;