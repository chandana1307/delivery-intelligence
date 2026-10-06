CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.order_item_summary AS
SELECT
    order_id,
    COUNT(*) AS item_count,
    COUNT(DISTINCT product_id) AS product_count,
    COUNT(DISTINCT seller_id) AS seller_count,
    ROUND(SUM(price), 2) AS total_item_value,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(price + freight_value), 2) AS total_order_value
FROM raw.order_items
GROUP BY order_id;