INSERT INTO dim_countries (country_name)
SELECT DISTINCT customer_country FROM mock_data WHERE customer_country IS NOT NULL AND customer_country != ''
UNION
SELECT DISTINCT seller_country FROM mock_data WHERE seller_country IS NOT NULL AND seller_country != ''
UNION
SELECT DISTINCT store_country FROM mock_data WHERE store_country IS NOT NULL AND store_country != ''
UNION
SELECT DISTINCT supplier_country FROM mock_data WHERE supplier_country IS NOT NULL AND supplier_country != ''
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO dim_product_categories (category_name)
SELECT DISTINCT product_category 
FROM mock_data 
WHERE product_category IS NOT NULL AND product_category != ''
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_product_brands (brand_name)
SELECT DISTINCT product_brand 
FROM mock_data 
WHERE product_brand IS NOT NULL AND product_brand != ''
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO dim_product_materials (material_name)
SELECT DISTINCT product_material 
FROM mock_data 
WHERE product_material IS NOT NULL AND product_material != ''
ON CONFLICT (material_name) DO NOTHING;

INSERT INTO dim_pet_breeds (breed_name)
SELECT DISTINCT customer_pet_breed 
FROM mock_data 
WHERE customer_pet_breed IS NOT NULL AND customer_pet_breed != ''
ON CONFLICT (breed_name) DO NOTHING;

INSERT INTO dim_pet_categories (pet_category_name)
SELECT DISTINCT pet_category 
FROM mock_data 
WHERE pet_category IS NOT NULL AND pet_category != ''
ON CONFLICT (pet_category_name) DO NOTHING;

INSERT INTO dim_time (date_value, year, quarter, month, month_name, day, day_of_week, day_name, is_weekend)
SELECT DISTINCT 
    sale_date,
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(DAY FROM sale_date),
    EXTRACT(DOW FROM sale_date),
    TO_CHAR(sale_date, 'Day'),
    EXTRACT(DOW FROM sale_date) IN (0, 6)
FROM mock_data 
WHERE sale_date IS NOT NULL
UNION
SELECT DISTINCT 
    product_release_date,
    EXTRACT(YEAR FROM product_release_date),
    EXTRACT(QUARTER FROM product_release_date),
    EXTRACT(MONTH FROM product_release_date),
    TO_CHAR(product_release_date, 'Month'),
    EXTRACT(DAY FROM product_release_date),
    EXTRACT(DOW FROM product_release_date),
    TO_CHAR(product_release_date, 'Day'),
    EXTRACT(DOW FROM product_release_date) IN (0, 6)
FROM mock_data 
WHERE product_release_date IS NOT NULL
UNION
SELECT DISTINCT 
    product_expiry_date,
    EXTRACT(YEAR FROM product_expiry_date),
    EXTRACT(QUARTER FROM product_expiry_date),
    EXTRACT(MONTH FROM product_expiry_date),
    TO_CHAR(product_expiry_date, 'Month'),
    EXTRACT(DAY FROM product_expiry_date),
    EXTRACT(DOW FROM product_expiry_date),
    TO_CHAR(product_expiry_date, 'Day'),
    EXTRACT(DOW FROM product_expiry_date) IN (0, 6)
FROM mock_data 
WHERE product_expiry_date IS NOT NULL;

INSERT INTO dim_customers (customer_id, first_name, last_name, age, email, country_id, postal_code, pet_type, pet_name, pet_breed_id)
SELECT DISTINCT 
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code,
    m.customer_pet_type,
    m.customer_pet_name,
    pb.breed_id
FROM mock_data m
LEFT JOIN dim_countries c ON c.country_name = m.customer_country
LEFT JOIN dim_pet_breeds pb ON pb.breed_name = m.customer_pet_breed
WHERE m.sale_customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dim_sellers (seller_id, first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT 
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM mock_data m
LEFT JOIN dim_countries c ON c.country_name = m.seller_country
WHERE m.sale_seller_id IS NOT NULL
ON CONFLICT (seller_id) DO NOTHING;

INSERT INTO dim_products (product_id, product_name, category_id, price, weight, color, size, brand_id, material_id, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT 
    m.sale_product_id,
    m.product_name,
    pc.category_id,
    m.product_price,
    m.product_weight,
    m.product_color,
    m.product_size,
    pb.brand_id,
    pm.material_id,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date
FROM mock_data m
LEFT JOIN dim_product_categories pc ON pc.category_name = m.product_category
LEFT JOIN dim_product_brands pb ON pb.brand_name = m.product_brand
LEFT JOIN dim_product_materials pm ON pm.material_name = m.product_material
WHERE m.sale_product_id IS NOT NULL
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dim_stores (store_name, location, city, state, country_id, phone, email)
SELECT DISTINCT 
    m.store_name,
    m.store_location,
    m.store_city,
    m.store_state,
    c.country_id,
    m.store_phone,
    m.store_email
FROM mock_data m
LEFT JOIN dim_countries c ON c.country_name = m.store_country
WHERE m.store_name IS NOT NULL;

INSERT INTO dim_suppliers (supplier_name, contact_person, email, phone, address, city, country_id)
SELECT DISTINCT 
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    m.supplier_city,
    c.country_id
FROM mock_data m
LEFT JOIN dim_countries c ON c.country_name = m.supplier_country
WHERE m.supplier_name IS NOT NULL;

INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, supplier_id, time_id, pet_category_id, quantity, unit_price, total_price, product_quantity_available, sale_date)
SELECT 
    m.sale_customer_id,
    m.sale_seller_id,
    m.sale_product_id,
    s.store_id,
    sup.supplier_id,
    t.time_id,
    pc.pet_category_id,
    m.sale_quantity,
    m.product_price,
    m.sale_total_price,
    m.product_quantity,
    m.sale_date
FROM mock_data m
LEFT JOIN dim_stores s ON s.store_name = m.store_name 
    AND s.city = m.store_city 
    AND s.phone = m.store_phone
LEFT JOIN dim_suppliers sup ON sup.supplier_name = m.supplier_name 
    AND sup.contact_person = m.supplier_contact
LEFT JOIN dim_time t ON t.date_value = m.sale_date
LEFT JOIN dim_pet_categories pc ON pc.pet_category_name = m.pet_category
WHERE m.sale_customer_id IS NOT NULL 
    AND m.sale_seller_id IS NOT NULL 
    AND m.sale_product_id IS NOT NULL;