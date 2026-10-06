-- ============================================================
-- Delivery Intelligence
-- Core Business KPI Queries
-- ============================================================


-- ============================================================
-- KPI 1: Monthly late-delivery rate
--
-- Business question:
-- How has delivery performance changed over time?
--
-- Denominator:
-- Delivered orders with both an observed customer delivery date
-- and an estimated delivery date.
-- ============================================================

SELECT
    purchase_month,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE eligible_for_late_label
    ) AS eligible_delivered_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = TRUE
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE late_delivery = TRUE
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE eligible_for_late_label
            ),
            0
        ),
        2
    ) AS late_rate_pct

FROM analytics.order_delivery

GROUP BY purchase_month

ORDER BY purchase_month;



-- ============================================================
-- KPI 2: Delivery performance by customer state
--
-- Business question:
-- How does delivery performance vary geographically?
--
-- Both average and median delivery duration are shown because
-- unusually slow deliveries can pull the average upward.
-- ============================================================

SELECT
    customer_state,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE eligible_for_late_label
    ) AS eligible_delivered_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = TRUE
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE late_delivery = TRUE
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE eligible_for_late_label
            ),
            0
        ),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days) FILTER (
            WHERE eligible_for_late_label
        ),
        2
    ) AS avg_delivery_days,

    ROUND(
        (
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY delivery_days
            )
            FILTER (
                WHERE eligible_for_late_label
            )
        )::numeric,
        2
    ) AS median_delivery_days

FROM analytics.order_delivery

GROUP BY customer_state

ORDER BY late_rate_pct DESC;



-- ============================================================
-- KPI 3: Single-seller vs multi-seller delivery performance
--
-- Business question:
-- Do orders involving multiple sellers show different
-- historical delivery performance from single-seller orders?
--
-- This is an association only, not evidence of causation.
-- ============================================================

SELECT
    CASE
        WHEN seller_count = 1 THEN 'Single seller'
        WHEN seller_count > 1 THEN 'Multiple sellers'
        ELSE 'No item record'
    END AS seller_structure,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE eligible_for_late_label
    ) AS eligible_delivered_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = TRUE
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE late_delivery = TRUE
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE eligible_for_late_label
            ),
            0
        ),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days) FILTER (
            WHERE eligible_for_late_label
        ),
        2
    ) AS avg_delivery_days

FROM analytics.order_delivery

GROUP BY 1

ORDER BY 1;



-- ============================================================
-- KPI 4: Promised lead time vs delivery performance
--
-- Business question:
-- How is the promised delivery window associated with
-- late-delivery performance?
-- ============================================================

SELECT
    CASE
        WHEN promised_lead_days <= 7
            THEN '0-7 days'

        WHEN promised_lead_days <= 14
            THEN '8-14 days'

        WHEN promised_lead_days <= 21
            THEN '15-21 days'

        WHEN promised_lead_days <= 30
            THEN '22-30 days'

        ELSE '31+ days'
    END AS promised_lead_band,

    COUNT(*) AS eligible_delivered_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = TRUE
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE late_delivery = TRUE
        )
        /
        NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days),
        2
    ) AS avg_actual_delivery_days

FROM analytics.order_delivery

WHERE eligible_for_late_label

GROUP BY 1

ORDER BY MIN(promised_lead_days);