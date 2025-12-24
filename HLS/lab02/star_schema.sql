CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER,
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_age INTEGER,
    customer_email VARCHAR(255),
    customer_country VARCHAR(100),
    customer_postal_code VARCHAR(20),
    customer_pet_type VARCHAR(50),
    customer_pet_name VARCHAR(100),
    customer_pet_breed VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10,2),
    weight DECIMAL(10,2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3,1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE,
    pet_category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_key SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    location VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_key SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    contact VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_key SERIAL PRIMARY KEY,
    seller_id INTEGER,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day INTEGER,
    month INTEGER,
    year INTEGER,
    quarter INTEGER,
    day_of_week INTEGER,
    month_name VARCHAR(20),
    year_month VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_key SERIAL PRIMARY KEY,
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    product_key INTEGER REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),
    supplier_key INTEGER REFERENCES dim_supplier(supplier_key),
    seller_key INTEGER REFERENCES dim_seller(seller_key),
    date_key INTEGER REFERENCES dim_date(date_key),
    quantity INTEGER,
    total_price DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_store ON fact_sales(store_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_supplier ON fact_sales(supplier_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_seller ON fact_sales(seller_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON fact_sales(date_key);
