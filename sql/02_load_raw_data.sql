TRUNCATE TABLE
    raw.customers,
    raw.geolocation,
    raw.orders,
    raw.order_items,
    raw.order_payments,
    raw.order_reviews,
    raw.products,
    raw.sellers,
    raw.product_category_translation;

\copy raw.customers FROM 'data/raw/olist/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.geolocation FROM 'data/raw/olist/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.orders FROM 'data/raw/olist/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.order_items FROM 'data/raw/olist/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.order_payments FROM 'data/raw/olist/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.order_reviews FROM 'data/raw/olist/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.products FROM 'data/raw/olist/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.sellers FROM 'data/raw/olist/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy raw.product_category_translation FROM 'data/raw/olist/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');