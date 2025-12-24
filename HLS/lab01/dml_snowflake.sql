CREATE OR REPLACE FUNCTION parse_date(date_str VARCHAR) RETURNS DATE AS $$
BEGIN
    BEGIN
        RETURN TO_DATE(date_str, 'MM/DD/YYYY');
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            RETURN TO_DATE(date_str, 'M/D/YYYY');
        EXCEPTION WHEN OTHERS THEN
            RETURN NULL;
        END;
    END;
END;
$$ LANGUAGE plpgsql;

INSERT INTO dim_country (country_name)
SELECT DISTINCT country FROM (
    SELECT TRIM(customer_country) as country FROM mock_data WHERE customer_country IS NOT NULL AND TRIM(customer_country) != ''
    UNION
    SELECT TRIM(seller_country) FROM mock_data WHERE seller_country IS NOT NULL AND TRIM(seller_country) != ''
    UNION
    SELECT TRIM(supplier_country) FROM mock_data WHERE supplier_country IS NOT NULL AND TRIM(supplier_country) != ''
    UNION
    SELECT TRIM(store_country) FROM mock_data WHERE store_country IS NOT NULL AND TRIM(store_country) != ''
) countries
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_customer (customer_first_name, customer_last_name, customer_age, customer_email, country_id, customer_postal_code)
SELECT DISTINCT ON (TRIM(customer_first_name), TRIM(customer_last_name), TRIM(customer_email))
    TRIM(customer_first_name),
    TRIM(customer_last_name),
    customer_age,
    TRIM(customer_email),
    c.country_id,
    TRIM(customer_postal_code)
FROM mock_data m
LEFT JOIN dim_country c ON TRIM(m.customer_country) = c.country_name
WHERE m.customer_first_name IS NOT NULL
ON CONFLICT (customer_first_name, customer_last_name, customer_email) DO NOTHING;

INSERT INTO dim_pet_breed (breed_name)
SELECT DISTINCT TRIM(customer_pet_breed) 
FROM mock_data 
WHERE customer_pet_breed IS NOT NULL AND TRIM(customer_pet_breed) != ''
ON CONFLICT (breed_name) DO NOTHING;

INSERT INTO dim_pet (pet_name, pet_type, pet_breed_id, pet_category, customer_id)
SELECT DISTINCT
    TRIM(m.customer_pet_name),
    TRIM(m.customer_pet_type),
    pb.pet_breed_id,
    TRIM(m.pet_category),
    c.customer_id
FROM mock_data m
LEFT JOIN dim_pet_breed pb ON TRIM(m.customer_pet_breed) = pb.breed_name
LEFT JOIN dim_customer c ON TRIM(m.customer_first_name) = c.customer_first_name 
    AND TRIM(m.customer_last_name) = c.customer_last_name 
    AND TRIM(m.customer_email) = c.customer_email
WHERE m.customer_pet_name IS NOT NULL;

INSERT INTO dim_seller (seller_first_name, seller_last_name, seller_email, country_id, seller_postal_code)
SELECT DISTINCT ON (TRIM(seller_first_name), TRIM(seller_last_name), TRIM(seller_email))
    TRIM(seller_first_name),
    TRIM(seller_last_name),
    TRIM(seller_email),
    c.country_id,
    TRIM(seller_postal_code)
FROM mock_data m
LEFT JOIN dim_country c ON TRIM(m.seller_country) = c.country_name
WHERE m.seller_first_name IS NOT NULL
ON CONFLICT (seller_first_name, seller_last_name, seller_email) DO NOTHING;

INSERT INTO dim_supplier (supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, country_id)
SELECT DISTINCT ON (TRIM(supplier_name), TRIM(supplier_email))
    TRIM(supplier_name),
    TRIM(supplier_contact),
    TRIM(supplier_email),
    TRIM(supplier_phone),
    TRIM(supplier_address),
    TRIM(supplier_city),
    c.country_id
FROM mock_data m
LEFT JOIN dim_country c ON TRIM(m.supplier_country) = c.country_name
WHERE m.supplier_name IS NOT NULL
ON CONFLICT (supplier_name, supplier_email) DO NOTHING;

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT TRIM(product_brand) 
FROM mock_data 
WHERE product_brand IS NOT NULL AND TRIM(product_brand) != ''
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT TRIM(product_category) 
FROM mock_data 
WHERE product_category IS NOT NULL AND TRIM(product_category) != ''
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_store (store_name, store_location, store_city, store_state, country_id, store_phone, store_email)
SELECT DISTINCT ON (TRIM(store_name), TRIM(store_city), TRIM(store_location))
    TRIM(store_name),
    TRIM(store_location),
    TRIM(store_city),
    TRIM(store_state),
    c.country_id,
    TRIM(store_phone),
    TRIM(store_email)
FROM mock_data m
LEFT JOIN dim_country c ON TRIM(m.store_country) = c.country_name
WHERE m.store_name IS NOT NULL
ON CONFLICT (store_name, store_city, store_location) DO NOTHING;

INSERT INTO dim_date (full_date, year, month, day, quarter, day_of_week, day_name, month_name, is_weekend)
SELECT DISTINCT
    parsed_date,
    EXTRACT(YEAR FROM parsed_date)::INTEGER,
    EXTRACT(MONTH FROM parsed_date)::INTEGER,
    EXTRACT(DAY FROM parsed_date)::INTEGER,
    EXTRACT(QUARTER FROM parsed_date)::INTEGER,
    EXTRACT(DOW FROM parsed_date)::INTEGER,
    TO_CHAR(parsed_date, 'Day'),
    TO_CHAR(parsed_date, 'Month'),
    CASE WHEN EXTRACT(DOW FROM parsed_date) IN (0, 6) THEN TRUE ELSE FALSE END
FROM (
    SELECT parse_date(sale_date) as parsed_date
    FROM mock_data
    WHERE sale_date IS NOT NULL
) dates
WHERE parsed_date IS NOT NULL
ON CONFLICT (full_date) DO NOTHING;

INSERT INTO dim_product (
    product_name, category_id, brand_id, supplier_id, 
    product_price, product_weight, product_color, product_size, 
    product_material, product_description, product_rating, product_reviews,
    product_release_date, product_expiry_date
)
SELECT DISTINCT ON (TRIM(m.product_name), pc.category_id, b.brand_id)
    TRIM(m.product_name),
    pc.category_id,
    b.brand_id,
    s.supplier_id,
    m.product_price,
    m.product_weight,
    TRIM(m.product_color),
    TRIM(m.product_size),
    TRIM(m.product_material),
    m.product_description,
    m.product_rating,
    m.product_reviews,
    parse_date(m.product_release_date),
    parse_date(m.product_expiry_date)
FROM mock_data m
LEFT JOIN dim_product_category pc ON TRIM(m.product_category) = pc.category_name
LEFT JOIN dim_brand b ON TRIM(m.product_brand) = b.brand_name
LEFT JOIN dim_supplier s ON TRIM(m.supplier_name) = s.supplier_name AND TRIM(m.supplier_email) = s.supplier_email
WHERE m.product_name IS NOT NULL;

INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, date_id, sale_quantity, sale_total_price, product_quantity)
SELECT 
    c.customer_id,
    se.seller_id,
    p.product_id,
    st.store_id,
    d.date_id,
    m.sale_quantity,
    m.sale_total_price,
    m.product_quantity
FROM mock_data m
LEFT JOIN dim_customer c ON TRIM(m.customer_first_name) = c.customer_first_name 
    AND TRIM(m.customer_last_name) = c.customer_last_name 
    AND TRIM(m.customer_email) = c.customer_email
LEFT JOIN dim_seller se ON TRIM(m.seller_first_name) = se.seller_first_name 
    AND TRIM(m.seller_last_name) = se.seller_last_name 
    AND TRIM(m.seller_email) = se.seller_email
LEFT JOIN dim_product_category pc ON TRIM(m.product_category) = pc.category_name
LEFT JOIN dim_brand b ON TRIM(m.product_brand) = b.brand_name
LEFT JOIN dim_product p ON TRIM(m.product_name) = p.product_name 
    AND pc.category_id = p.category_id 
    AND b.brand_id = p.brand_id
LEFT JOIN dim_store st ON TRIM(m.store_name) = st.store_name 
    AND TRIM(m.store_city) = st.store_city 
    AND TRIM(m.store_location) = st.store_location
LEFT JOIN dim_date d ON parse_date(m.sale_date) = d.full_date;
