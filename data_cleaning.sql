--USE meal_delivery_capstone;

ALTER TABLE weekly_orders
ADD CONSTRAINT fk_weekly_orders_meal_id
FOREIGN KEY (meal_id)
REFERENCES meal_info(meal_id);


ALTER TABLE weekly_orders
ADD CONSTRAINT fk_weekly_orders_center_info
FOREIGN KEY (center_id)
REFERENCES center_info(center_id);

-- SQL DATA CLEANING CHECKLIST FOR CAPSTONE

-- ===========================================
--		TABLE 1
-- ===========================================

-- 1. Check for NULL Values in important columns

SELECT
	COUNT(*) AS [Total rows],
	COUNT(meal_id) AS [Meal count],
	COUNT(center_id) AS [Center count],
	COUNT(num_orders) AS [Order count]
FROM 
	weekly_orders;

SELECT 
	COUNT(*) AS [Total rows],
	COUNT(week) AS [Week count],
	COUNT(checkout_price) AS [Checkout count], 
	COUNT(base_price) AS [Base price count],
	COUNT(emailer_for_promotion) AS [Emailer count],
	COUNT(homepage_featured) AS [Homepage count]
FROM
	weekly_orders;

-- 2. Check for Duplicates 

SELECT 
	COUNT(*)
FROM weekly_orders;

SELECT 
	COUNT(DISTINCT(weekly_order_id))
FROM weekly_orders;

SELECT
	center_id,
	meal_id,
	week,
	COUNT(*)
FROM 
	weekly_orders
GROUP BY center_id, meal_id, week
HAVING COUNT(*) > 1;

--3. Spot invalid negative values
SELECT *
FROM weekly_orders
WHERE num_orders < 0;

SELECT *
FROM weekly_orders
WHERE checkout_price < 0 
	AND base_price < 0;

-- 4. Check for logical Inconsistency
SELECT 
	*
FROM weekly_orders wo
WHERE checkout_price < base_price;

--During data cleaning, 229,687 records were found where checkout_price < base_price. 
--This does not necessarily indicate bad data but suggests a potential area for 
--business analysis (e.g., promotions, discounts, or operational loss).

SELECT 
	*
FROM weekly_orders
WHERE emailer_for_promotion NOT IN (0, 1)
	OR homepage_featured NOT IN (0, 1);

-- These columns contain only expected binary values


-- ===========================================
--		TABLE 2
-- ===========================================
-- 1. Check for NULL Values in important columns
SELECT
	COUNT(*) AS [Total row count],
	COUNT(category) AS [Category count],
	COUNT(cuisine) AS [Cuisine count]
FROM meal_info;

-- 2. Check for duplicates

SELECT 
	COUNT(*)
FROM meal_info;

SELECT 
	COUNT(DISTINCT(meal_id))
FROM meal_info;

SELECT 
	meal_id,
	category,
	cuisine,
	COUNT(*) AS [Count]
FROM meal_info
GROUP BY meal_id, category, cuisine
HAVING COUNT(*) > 1;

-- 3. Trim Whitespaces

-- Check for leading and trailing spaces
SELECT 
	DISTINCT 
	CONCAT('[',category,']') AS Original_Cat,
	CONCAT('[',TRIM(category),']') AS Trimmed,
	CONCAT('[',cuisine,']') AS Original_Cui,
	CONCAT('[',TRIM(cuisine),']') AS Trimmed
FROM 
	meal_info
WHERE	
	category <> TRIM(category) 
	OR cuisine <> TRIM(cuisine);
	
SELECT 
	DISTINCT
	category,
	LEN(category) AS Cat_Len,
	LEN(TRIM(category)) AS Trim_Cat_Len,
	cuisine,
	LEN(cuisine) AS cui_Len,
	LEN(TRIM(cuisine)) AS Trim_Cui_Len
FROM meal_info;

-- Check for multiple internal spaces
SELECT 
	DISTINCT
	category,
	cuisine
FROM
	meal_info
WHERE
	category LIKE '%  %'
	OR cuisine LIKE '%  %';

-- 4. CHECK FOR INCONSISTENT FORMATTING
SELECT 
	DISTINCT category
FROM meal_info
ORDER BY category;

SELECT 
	DISTINCT cuisine
FROM meal_info
ORDER BY cuisine;

-- ===========================================
--		TABLE 3
-- ===========================================

-- 1. Check for Nulls
SELECT 
	COUNT(*) AS [Total rows],
	COUNT(city_code) AS [City code],
	COUNT(region_code) AS [region code],
	COUNT(center_type) AS [Center type],
	COUNT(op_area) AS [op_area]
FROM center_info;

-- 2. Check for duplicates
SELECT 
	COUNT(*) AS [Total rows], 
	COUNT(DISTINCT center_id) AS [Distinct Count]
FROM center_info;

-- 3. Check for whitespaces and inconsistencies
SELECT 
	DISTINCT
	CONCAT('[',center_type,']')
FROM center_info;

-- 4. Check for illogical cases and invalids
SELECT 
	*
FROM center_info
WHERE op_area <= 0;

SELECT 
	DISTINCT
	city_code,
	region_code 
FROM center_info;


