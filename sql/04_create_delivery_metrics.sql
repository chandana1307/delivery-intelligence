CREATE OR REPLACE VIEW analytics.order_delivery AS
SELECT
    ob.*,

    ob.order_purchase_timestamp::date AS purchase_date,

    DATE_TRUNC(
        'month',
        ob.order_purchase_timestamp
    )::date AS purchase_month,

    CASE
        WHEN ob.order_delivered_customer_date IS NOT NULL
        THEN
            ob.order_delivered_customer_date::date
            - ob.order_purchase_timestamp::date
    END AS delivery_days,

    ob.order_estimated_delivery_date::date
        - ob.order_purchase_timestamp::date
        AS promised_lead_days,

    CASE
        WHEN ob.order_status = 'delivered'
         AND ob.order_delivered_customer_date IS NOT NULL
         AND ob.order_estimated_delivery_date IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS eligible_for_late_label,

    CASE
        WHEN ob.order_status = 'delivered'
         AND ob.order_delivered_customer_date IS NOT NULL
         AND ob.order_estimated_delivery_date IS NOT NULL
        THEN
            ob.order_delivered_customer_date::date
            >
            ob.order_estimated_delivery_date::date
        ELSE NULL
    END AS late_delivery

FROM analytics.order_base ob;