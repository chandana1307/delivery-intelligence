CREATE OR REPLACE VIEW analytics.ml_order_seller_history_source AS
SELECT
    mos.order_id,
    mos.seller_id,

    mob.score_time,
    mob.label_available_at,
    mob.late_delivery,
    mob.ml_eligible

FROM analytics.order_seller_bridge mos

INNER JOIN analytics.ml_order_base mob
    ON mos.order_id = mob.order_id;