-- ============================================================
-- Delivery Intelligence
-- Dashboard Semantic Model
-- ============================================================


-- ------------------------------------------------------------
-- Seller bridge
-- One row per order + seller combination
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.order_seller_bridge AS
SELECT DISTINCT
    oi.order_id,
    oi.seller_id,
    s.seller_city,
    s.seller_state
FROM raw.order_items oi

LEFT JOIN raw.sellers s
    ON oi.seller_id = s.seller_id;


-- ------------------------------------------------------------
-- Product category bridge
-- One row per order + category combination
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.order_category_bridge AS
SELECT DISTINCT
    oi.order_id,

    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category

FROM raw.order_items oi

LEFT JOIN raw.products p
    ON oi.product_id = p.product_id

LEFT JOIN raw.product_category_translation pct
    ON p.product_category_name = pct.product_category_name;


-- ------------------------------------------------------------
-- Seller-period marketplace benchmark
-- Uses the same periods as seller deterioration analysis
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.seller_period_benchmark AS
SELECT
    CASE
        WHEN purchase_date >= DATE '2018-02-01'
         AND purchase_date < DATE '2018-05-01'
            THEN 'Prior'

        WHEN purchase_date >= DATE '2018-05-01'
         AND purchase_date < DATE '2018-08-01'
            THEN 'Recent'
    END AS period,

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
    ) AS late_rate_pct

FROM analytics.order_delivery

WHERE eligible_for_late_label
  AND purchase_date >= DATE '2018-02-01'
  AND purchase_date < DATE '2018-08-01'

GROUP BY 1;