-- ============================================================
-- Delivery Intelligence
-- Seller Performance Analysis
-- ============================================================

-- Business question:
-- Which sellers show worsening late-delivery performance
-- between two comparable three-month periods?
--
-- Prior period:  2018-02-01 through 2018-04-30
-- Recent period: 2018-05-01 through 2018-07-31
--
-- Only sellers with at least 20 eligible delivered orders
-- in BOTH periods are included.


WITH seller_orders AS (

    -- One record per seller per order.
    -- DISTINCT prevents multiple items from the same seller
    -- within one order from counting the order multiple times.

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
             AND od.purchase_date <  DATE '2018-05-01'
                THEN 'Prior'

            WHEN od.purchase_date >= DATE '2018-05-01'
             AND od.purchase_date <  DATE '2018-08-01'
                THEN 'Recent'
        END AS period

    FROM seller_orders so

    INNER JOIN analytics.order_delivery od
        ON so.order_id = od.order_id

    WHERE od.eligible_for_late_label
      AND od.purchase_date >= DATE '2018-02-01'
      AND od.purchase_date <  DATE '2018-08-01'
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
  AND recent_orders >= 20

ORDER BY late_rate_change_pp DESC;

-- ============================================================
-- Overall delivery performance for the same comparison periods
-- ============================================================

SELECT
    CASE
        WHEN purchase_date >= DATE '2018-02-01'
         AND purchase_date <  DATE '2018-05-01'
            THEN 'Prior'

        WHEN purchase_date >= DATE '2018-05-01'
         AND purchase_date <  DATE '2018-08-01'
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
  AND purchase_date <  DATE '2018-08-01'

GROUP BY 1

ORDER BY MIN(purchase_date);