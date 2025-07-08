CREATE TABLE amazon_products (
    product_id VARCHAR(50),
    product_name VARCHAR(500),
    category VARCHAR(500),
    discounted_price VARCHAR(20),
    actual_price VARCHAR(20),
    discount_percentage VARCHAR(20),
    rating VARCHAR(10),
    rating_count VARCHAR(20),
    about_product TEXT,
    user_id VARCHAR(1000),
    user_name VARCHAR(200),
    review_id VARCHAR(500),
    review_title VARCHAR(1000),
    review_content TEXT,
    img_link VARCHAR(500),
    product_link VARCHAR(500)
);

select *from amazon_products;


-------------------------Problems-----------------------------

------------------Query 01. Basic product listing
select product_id, product_name, discounted_price, rating
from amazon_products
order by rating desc
limit 10;


------------------Query 02. Product with highest discount
Select product_name, discounted_price, actual_price, discount_percentage
from amazon_products
order by cast(replace(discount_percentage , '%', '') as numeric) desc
limit 10;

--------------------Query 03. average rating by category
SELECT 
    category,
    ROUND(AVG(CAST(rating AS NUMERIC)), 2) AS avg_rating
FROM amazon_products
GROUP BY category
ORDER BY avg_rating DESC;

----------------- query 04. Count of product by category
Select  
category ,
count(*) as product_count
from amazon_products
group by category
order by product_count desc;


--------------------Query 05. most reviewed product
Select  product_name,
rating_count
from amazon_products
where rating_count != '0'
order by CAST( replace(rating_count, ',', '') as Integer) desc
limit 10;

--------------Query 06. Product with no discount
Select product_name, discounted_price, actual_price
from amazon_products
where discounted_price=actual_price;

----------------- Query 07. Best rated product
SELECT product_name, rating, rating_count
FROM amazon_products
WHERE CAST(rating AS NUMERIC) >= 4.5
ORDER BY CAST(rating_count AS INTEGER) DESC;

------------- Query 08. Product with missing ratings
Select product_name , rating , rating_count
from amazon_products
where rating = '0' or rating is NULL;

----------------Query 09. average discount percentage
select round(avg(cast(replace(discount_percentage, '%','')as numeric)),2) as avg_discount
from amazon_products
where discount_percentage != '0%';

-------------------Query 10. Product with the longest description
Select product_name, length(about_product) as description_length
from amazon_products
order by description_length desc
limit 10;


------------------- Query 11. Top 5 categories by Average Discount
select category,
round(avg(cast(replace(discounted_price , '%','' )as numeric)),2) as avg_discount
from amazon_products
group by category
order by avg_discount desc
limit 5;


-------------Query 12. COunt 0f Product with no reviews
SELECT COUNT(*) AS no_review_products
FROM amazon_products
WHERE rating_count = '0' OR rating_count IS NULL;


---------------Query13. Product with most user review
Select product_name, user_name, review_content
from amazon_products
where review_content IS NOT NULL
order by LENGTH(review_content) desc
limit 10;


------------------- Query 15. Product with shortest name

SELECT product_name, LENGTH(product_name) AS name_length
FROM amazon_products
ORDER BY name_length ASC
LIMIT 10; 

--------------- Query 16. product with missing Images

select product_name, img_link
from amazon_products
where img_link IS NULL or img_link = '';


----------------******** Query 17. Most common words in Product name
SELECT 
    word,
    COUNT(*) AS frequency
FROM (
    SELECT regexp_split_to_table(LOWER(product_name), '\s+') AS word
    FROM amazon_products
) AS words
WHERE LENGTH(word) > 3
GROUP BY word
ORDER BY frequency DESC
LIMIT 20;

--------------Query 18. Product with short reviews but High zratings

SELECT 
    product_name,
    rating,
    LENGTH(review_content) AS review_length,
    review_content
FROM amazon_products
WHERE 
    review_content IS NOT NULL
    AND LENGTH(review_content) < 20
    AND CAST(rating AS NUMERIC) = 5
ORDER BY rating DESC;

----------- query 19. Product with durable mentioned in review

SELECT product_name, review_content
FROM amazon_products
WHERE LOWER(review_content) LIKE '%durable%';


------------- Query 20. Review titles containing the word "excellent"
SELECT product_name, review_title
FROM amazon_products
WHERE LOWER(review_title) LIKE '%excellent%';


------------- Query 21. Sentiment analysis on reviews(positive/negative)
SELECT 
    product_name,
    review_content,
    CASE 
        WHEN review_content LIKE '%good%' OR review_content LIKE '%great%' OR review_content LIKE '%excellent%' THEN 'Positive'
        WHEN review_content LIKE '%bad%' OR review_content LIKE '%poor%' OR review_content LIKE '%issue%' THEN 'Negative'
        ELSE 'Neutral'
    END AS sentiment
FROM amazon_products
WHERE review_content IS NOT NULL
LIMIT 20;


------------------- Query 22. User Review Engagement (Most Active Users)


SELECT 
    user_name,
    COUNT(*) AS reviews_posted,
    AVG(LENGTH(review_content)) AS avg_review_length
FROM amazon_products
WHERE user_name IS NOT NULL
GROUP BY user_name
ORDER BY reviews_posted DESC
LIMIT 10;



------------ Query 23. Producs with the longest and shortest Description
SELECT 
    product_name,
    LENGTH(about_product) AS description_length,
    CASE 
        WHEN LENGTH(about_product) > (SELECT AVG(LENGTH(about_product)) FROM amazon_products) THEN 'Long'
        ELSE 'Short'
    END AS description_type
FROM amazon_products
ORDER BY description_length DESC
LIMIT 10;



----------------- Query 24. Product with the most frequent keywords in reviews

WITH review_words AS (
    SELECT 
        product_name,
        regexp_split_to_table(LOWER(review_content), '\s+') AS word
    FROM amazon_products
    WHERE review_content IS NOT NULL
)
SELECT 
    product_name,
    word,
    COUNT(*) AS frequency
FROM review_words
WHERE LENGTH(word) > 3
GROUP BY product_name, word
ORDER BY frequency DESC
LIMIT 20;


------------------Query 25. Users who reviewed Multiple products
SELECT 
    user_name,
    COUNT(DISTINCT product_id) AS products_reviewed,
    STRING_AGG(product_name, ', ') AS reviewed_products
FROM amazon_products
WHERE user_name IS NOT NULL
GROUP BY user_name
HAVING COUNT(DISTINCT product_id) > 1
ORDER BY products_reviewed DESC
LIMIT 10;


----------------- query26. Products with most frequent compliant

SELECT 
    product_name,
    COUNT(*) AS complaint_count
FROM amazon_products
WHERE LOWER(review_content) LIKE '%problem%' 
   OR LOWER(review_content) LIKE '%issue%' 
   OR LOWER(review_content) LIKE '%broken%'
GROUP BY product_name
ORDER BY complaint_count DESC
LIMIT 10;


--------------- Query 27. Products with the Longest Review-to-Description Ratio
SELECT 
    product_name,
    LENGTH(review_content) AS review_length,
    LENGTH(about_product) AS description_length,
    (LENGTH(review_content)::FLOAT / NULLIF(LENGTH(about_product), 0)) AS review_desc_ratio
FROM amazon_products
WHERE review_content IS NOT NULL AND about_product IS NOT NULL
ORDER BY review_desc_ratio DESC
LIMIT 10;


--------------- Query 28. User name who reviewed most

SELECT UNNEST(STRING_TO_ARRAY(user_name, ',')) AS individual_user,
       COUNT(*) AS review_count
FROM amazon_products
GROUP BY individual_user
ORDER BY review_count DESC
LIMIT 10;

----------------- Query 29. Products with over 50000 reviews
SELECT product_name, rating_count
FROM amazon_products
WHERE CAST(REPLACE(rating_count, ',', '') AS INT) > 50000;


-------------- Query 30. TOp 20 most common categories-------

SELECT category, COUNT(*) AS count
FROM amazon_products
GROUP BY category
ORDER BY count DESC
LIMIT 20;






