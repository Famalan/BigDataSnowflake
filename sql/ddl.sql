CREATE TABLE IF NOT EXISTS dim_countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product_brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_product_materials (
    material_id SERIAL PRIMARY KEY,
    material_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_pet_breeds (
    breed_id SERIAL PRIMARY KEY,
    breed_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_pet_categories (
    pet_category_id SERIAL PRIMARY KEY,
    pet_category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_time (
    time_id SERIAL PRIMARY KEY,
    date_value DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(255),
    country_id INTEGER REFERENCES dim_countries(country_id),
    postal_code VARCHAR(20),
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed_id INTEGER REFERENCES dim_pet_breeds(breed_id)
);

CREATE TABLE IF NOT EXISTS dim_sellers (
    seller_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    country_id INTEGER REFERENCES dim_countries(country_id),
    postal_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dim_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INTEGER REFERENCES dim_product_categories(category_id),
    price DECIMAL(10,2),
    weight DECIMAL(10,2),
    color VARCHAR(50),
    size VARCHAR(20),
    brand_id INTEGER REFERENCES dim_product_brands(brand_id),
    material_id INTEGER REFERENCES dim_product_materials(material_id),
    description TEXT,
    rating DECIMAL(3,2),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE IF NOT EXISTS dim_stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    location VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country_id INTEGER REFERENCES dim_countries(country_id),
    phone VARCHAR(50),
    email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    city VARCHAR(100),
    country_id INTEGER REFERENCES dim_countries(country_id)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES dim_customers(customer_id),
    seller_id INTEGER REFERENCES dim_sellers(seller_id),
    product_id INTEGER REFERENCES dim_products(product_id),
    store_id INTEGER REFERENCES dim_stores(store_id),
    supplier_id INTEGER REFERENCES dim_suppliers(supplier_id),
    time_id INTEGER REFERENCES dim_time(time_id),
    pet_category_id INTEGER REFERENCES dim_pet_categories(pet_category_id),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    product_quantity_available INTEGER,
    sale_date DATE
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_seller ON fact_sales(seller_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_supplier ON fact_sales(supplier_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_time ON fact_sales(time_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_pet_category ON fact_sales(pet_category_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON fact_sales(sale_date);

CREATE INDEX IF NOT EXISTS idx_fact_sales_time_product ON fact_sales(time_id, product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_time ON fact_sales(customer_id, time_id);
CREATE INDEX IF NOT EXISTS idx_dim_time_date ON dim_time(date_value);