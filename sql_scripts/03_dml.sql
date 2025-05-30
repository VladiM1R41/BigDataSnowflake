INSERT INTO dim_country (country_name)
SELECT DISTINCT customer_country FROM mock_data
UNION
SELECT DISTINCT seller_country FROM mock_data
UNION
SELECT DISTINCT store_country FROM mock_data
UNION
SELECT DISTINCT supplier_country FROM mock_data;


INSERT INTO dim_city (city_name)
SELECT DISTINCT store_city FROM mock_data
UNION
SELECT DISTINCT supplier_city FROM mock_data;


INSERT INTO dim_pet_type (type_name)
SELECT DISTINCT customer_pet_type FROM mock_data;


INSERT INTO dim_pet_breed (breed_name)
SELECT DISTINCT customer_pet_breed FROM mock_data;


INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category FROM mock_data;


INSERT INTO dim_color (color_name)
SELECT DISTINCT product_color FROM mock_data;

INSERT INTO dim_size (size_name)
SELECT DISTINCT product_size FROM mock_data;


INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand FROM mock_data;


INSERT INTO dim_material (material_name)
SELECT DISTINCT product_material FROM mock_data;



INSERT INTO dim_pet (pet_name, pet_type_id, pet_breed_id, pet_category_id)
SELECT DISTINCT
    m.customer_pet_name,
    pt.pet_type_id,
    pb.pet_breed_id,
    pc.pet_category_id
FROM mock_data m
JOIN dim_pet_type pt ON m.customer_pet_type = pt.type_name
JOIN dim_pet_breed pb ON m.customer_pet_breed = pb.breed_name
JOIN dim_pet_category pc ON m.pet_category = pc.category_name;

INSERT INTO dim_customer (
    first_name, last_name, age, email, 
    country_id, postal_code, pet_id
)
SELECT DISTINCT
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code,
    p.pet_id
FROM mock_data m
JOIN dim_country c ON m.customer_country = c.country_name
JOIN dim_pet p ON m.customer_pet_name = p.pet_name;


INSERT INTO dim_seller (
    first_name, last_name, email, 
    country_id, postal_code
)
SELECT DISTINCT
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM mock_data m
JOIN dim_country c ON m.seller_country = c.country_name;


INSERT INTO dim_supplier (
    name, contact, email, phone, address, 
    city_id, country_id
)
SELECT DISTINCT ON (m.supplier_email)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    ct.city_id,
    c.country_id
FROM mock_data m
JOIN dim_country c ON m.supplier_country = c.country_name
LEFT JOIN dim_city ct ON m.supplier_city = ct.city_name;


INSERT INTO dim_store (
    name, location, city_id, state, 
    country_id, phone, email
)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    ct.city_id,
    m.store_state,
    c.country_id,
    m.store_phone,
    m.store_email
FROM mock_data m
JOIN dim_country c ON m.store_country = c.country_name
LEFT JOIN dim_city ct ON m.store_city = ct.city_name;


INSERT INTO dim_product (
    name, category, price, weight, 
    color_id, size_id, brand_id, material_id,
    description, rating, reviews, release_date, expiry_date,
    supplier_id
)
SELECT DISTINCT
    m.product_name,
    m.product_category,
    m.product_price,
    m.product_weight,
    col.color_id,
    siz.size_id,
    b.brand_id,
    mat.material_id,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date,
    supp.supplier_id
FROM mock_data m
JOIN dim_color col ON m.product_color = col.color_name
JOIN dim_size siz ON m.product_size = siz.size_name
JOIN dim_brand b ON m.product_brand = b.brand_name
JOIN dim_material mat ON m.product_material = mat.material_name
JOIN dim_supplier supp ON m.supplier_email = supp.email;


INSERT INTO fact_sales (
    sale_date, quantity, total_price, 
    customer_id, seller_id, store_id, product_id
)
SELECT
    m.sale_date,
    m.sale_quantity,
    m.sale_total_price,
    c.customer_id,
    s.seller_id,
    st.store_id,
    p.product_id
FROM mock_data m
JOIN dim_customer c ON m.customer_email = c.email
JOIN dim_seller s ON m.seller_email = s.email
JOIN dim_store st 
    ON m.store_name = st.name 
    AND m.store_location = st.location
JOIN dim_product p 
    ON m.product_name = p.name 
    AND m.product_price = p.price;