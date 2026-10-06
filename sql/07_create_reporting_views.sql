-- ============================================================
-- Delivery Intelligence
-- Reporting Views for Power BI
-- ============================================================


-- ============================================================
-- 1. Overall KPI summary
-- ============================================================

CREATE OR REPLACE VIEW analytics.kpi_overview AS
SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE eligible_for_late_label
    ) AS eligible_delivered_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = TRUE
    ) AS late_orders,

    COUNT(*) FILTER (
        WHERE late_delivery = FALSE
    ) AS on_time_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'canceled'
    ) AS canceled_orders,

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

FROM analytics.order_delivery;



-- ============================================================
-- 2. Monthly delivery performance
-- ============================================================

CREATE OR REPLACE VIEW analytics.monthly_delivery_performance AS
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

GROUP BY purchase_month;



-- ============================================================
-- 3. State delivery performance
-- ============================================================

CREATE OR REPLACE VIEW analytics.state_delivery_performance AS
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

GROUP BY customer_state;



-- ============================================================
-- 4. Seller structure performance
-- ============================================================

CREATE OR REPLACE VIEW analytics.seller_structure_performance AS
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

GROUP BY 1;



-- ============================================================
-- 5. Promised lead-time performance
-- ============================================================

CREATE OR REPLACE VIEW analytics.promised_lead_performance AS
SELECT
    CASE
        WHEN promised_lead_days <= 7 THEN '0-7 days'
        WHEN promised_lead_days <= 14 THEN '8-14 days'
        WHEN promised_lead_days <= 21 THEN '15-21 days'
        WHEN promised_lead_days <= 30 THEN '22-30 days'
        ELSE '31+ days'
    END AS promised_lead_band,

    MIN(promised_lead_days) AS band_sort_order,

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
        NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_days),
        2
    ) AS avg_actual_delivery_days

FROM analytics.order_delivery

WHERE eligible_for_late_label

GROUP BY 1;



-- ============================================================
-- 6. Seller deterioration
-- ============================================================

CREATE OR REPLACE VIEW analytics.seller_deterioration AS

WITH seller_orders AS (
    SELECT DISTINCT
        order_id,
        seller_id
    FROM raw.order_items
),

seller_delivery AS (
    SELECT
        so.seller_id,
        od.order_id,
        od.purchase_date,
        od.late_delivery,

        CASE
            WHEN od.purchase_date >= DATE '2018-02-01'
             AND od.purchase_date < DATE '2018-05-01'
                THEN 'Prior'

            WHEN od.purchase_date >= DATE '2018-05-01'
             AND od.purchase_date < DATE '2018-08-01'
                THEN 'Recent'
        END AS period

    FROM seller_orders so

    INNER JOIN analytics.order_delivery od
        ON so.order_id = od.order_id

    WHERE od.eligible_for_late_label
      AND od.purchase_date >= DATE '2018-02-01'
      AND od.purchase_date < DATE '2018-08-01'
),

seller_summary AS (
    SELECT
        seller_id,

        COUNT(*) FILTER (
            WHERE period = 'Prior'
        ) AS prior_orders,

        COUNT(*) FILTER (
            WHERE period = 'Prior'
              AND late_delivery = TRUE
        ) AS prior_late_orders,

        COUNT(*) FILTER (
            WHERE period = 'Recent'
        ) AS recent_orders,

        COUNT(*) FILTER (
            WHERE period = 'Recent'
              AND late_delivery = TRUE
        ) AS recent_late_orders

    FROM seller_delivery

    GROUP BY seller_id
)

SELECT
    seller_id,

    prior_orders,

    ROUND(
        100.0 * prior_late_orders
        / NULLIF(prior_orders, 0),
        2
    ) AS prior_late_rate_pct,

    recent_orders,

    ROUND(
        100.0 * recent_late_orders
        / NULLIF(recent_orders, 0),
        2
    ) AS recent_late_rate_pct,

    ROUND(
        (
            100.0 * recent_late_orders
            / NULLIF(recent_orders, 0)
        )
        -
        (
            100.0 * prior_late_orders
            / NULLIF(prior_orders, 0)
        ),
        2
    ) AS late_rate_change_pp

FROM seller_summary

WHERE prior_orders >= 20
  AND recent_orders >= 20;