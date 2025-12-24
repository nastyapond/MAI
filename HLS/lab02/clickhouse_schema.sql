-- ClickHouse Tables for Reports

CREATE TABLE IF NOT EXISTS report_product_sales (
    product_id Int32,
    product_name String,
    category String,
    rating Float32,
    reviews Int32,
    total_quantity_sold Int64,
    total_revenue Float64,
    number_of_sales Int64,
    avg_unit_price Float64
) ENGINE = MergeTree() ORDER BY product_id;

CREATE TABLE IF NOT EXISTS report_customer_sales (
    customer_id Int32,
    customer_first_name String,
    customer_last_name String,
    customer_email String,
    customer_country String,
    customer_age Int32,
    total_purchase_amount Float64,
    number_of_purchases Int64,
    avg_check Float64
) ENGINE = MergeTree() ORDER BY customer_id;

CREATE TABLE IF NOT EXISTS report_time_sales (
    year Int32,
    month Int32,
    quarter Int32,
    month_name String,
    year_month String,
    total_revenue Float64,
    total_quantity_sold Int64,
    number_of_orders Int64,
    avg_order_size Float64
) ENGINE = MergeTree() ORDER BY (year, month);

CREATE TABLE IF NOT EXISTS report_store_sales (
    store_name String,
    city String,
    state String,
    country String,
    total_revenue Float64,
    total_quantity_sold Int64,
    number_of_sales Int64,
    avg_check Float64
) ENGINE = MergeTree() ORDER BY store_name;

CREATE TABLE IF NOT EXISTS report_supplier_sales (
    supplier_name String,
    country String,
    city String,
    total_revenue Float64,
    total_quantity_sold Int64,
    number_of_sales Int64,
    avg_product_price Float64
) ENGINE = MergeTree() ORDER BY supplier_name;

CREATE TABLE IF NOT EXISTS report_product_quality (
    product_id Int32,
    product_name String,
    category String,
    brand String,
    rating Float32,
    reviews Int32,
    total_quantity_sold Int64,
    total_revenue Float64,
    number_of_sales Int64
) ENGINE = MergeTree() ORDER BY product_id;
