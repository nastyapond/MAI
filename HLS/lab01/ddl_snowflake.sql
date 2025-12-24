CREATE TABLE IF NOT EXISTS dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id SERIAL PRIMARY KEY,
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_age INTEGER,
    customer_email VARCHAR(255),
    country_id INTEGER REFERENCES dim_country(country_id),
    customer_postal_code VARCHAR(20),
    UNIQUE(customer_first_name, customer_last_name, customer_email)
);

CREATE TABLE IF NOT EXISTS dim_pet_breed (
    pet_breed_id SERIAL PRIMARY KEY,
    breed_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_name VARCHAR(100),
    pet_type VARCHAR(50),
    pet_breed_id INTEGER REFERENCES dim_pet_breed(pet_breed_id),
    pet_category VARCHAR(100),
    customer_id INTEGER REFERENCES dim_customer(customer_id)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id SERIAL PRIMARY KEY,
    seller_first_name VARCHAR(100),
    seller_last_name VARCHAR(100),
    seller_email VARCHAR(255),
    country_id INTEGER REFERENCES dim_country(country_id),
    seller_postal_code VARCHAR(20),
    UNIQUE(seller_first_name, seller_last_name, seller_email)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_contact VARCHAR(255),
    supplier_email VARCHAR(255),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(255),
    supplier_city VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id),
    UNIQUE(supplier_name, supplier_email)
);

CREATE TABLE IF NOT EXISTS dim_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INTEGER REFERENCES dim_product_category(category_id),
    brand_id INTEGER REFERENCES dim_brand(brand_id),
    supplier_id INTEGER REFERENCES dim_supplier(supplier_id),
    product_price DECIMAL(10,2),
    product_weight DECIMAL(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating DECIMAL(3,1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    store_location VARCHAR(255),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    country_id INTEGER REFERENCES dim_country(country_id),
    store_phone VARCHAR(50),
    store_email VARCHAR(255),
    UNIQUE(store_name, store_city, store_location)
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    quarter INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    month_name VARCHAR(20),
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id INTEGER REFERENCES dim_store(store_id),
    date_id INTEGER REFERENCES dim_date(date_id),
    sale_quantity INTEGER,
    sale_total_price DECIMAL(10,2),
    product_quantity INTEGER
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_seller ON fact_sales(seller_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON fact_sales(date_id);
CREATE INDEX IF NOT EXISTS idx_dim_customer_country ON dim_customer(country_id);
CREATE INDEX IF NOT EXISTS idx_dim_seller_country ON dim_seller(country_id);
CREATE INDEX IF NOT EXISTS idx_dim_supplier_country ON dim_supplier(country_id);
CREATE INDEX IF NOT EXISTS idx_dim_store_country ON dim_store(country_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_category ON dim_product(category_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_brand ON dim_product(brand_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_supplier ON dim_product(supplier_id);
CREATE INDEX IF NOT EXISTS idx_dim_pet_breed ON dim_pet(pet_breed_id);
CREATE INDEX IF NOT EXISTS idx_dim_pet_customer ON dim_pet(customer_id);
