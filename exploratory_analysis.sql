--==========================================
--        EXPLORATORY DATA ANALYSIS
--==========================================

--================================================================
--1. What are the top 5 meals with the highest total revenue?
--================================================================

SELECT
	TOP 5
	mi.meal_id,
	category,
	cuisine,
	SUM(checkout_price * num_orders) AS [Revenue]
FROM weekly_orders wo 
JOIN meal_info mi ON wo.meal_id = mi.meal_id
GROUP BY mi.meal_id, category, cuisine
ORDER BY [Revenue] DESC;


SELECT
	category,
	SUM([Revenue]) OVER (PARTITION BY category ORDER BY [Revenue] DESC) AS [Cummulative revenue]
FROM
	(SELECT
		category,
		SUM(checkout_price * num_orders) AS [Revenue]
	FROM weekly_orders wo 
	JOIN meal_info mi ON wo.meal_id = mi.meal_id
	GROUP BY category
	) AS SUB;

--========================================================================
-- 2. Which week recorded the highest total order volume in the dataset? 
--========================================================================
SELECT
	week,
	SUM(num_orders) AS [Total Order],
	COUNT(num_orders) AS [Frequecy of order]
FROM weekly_orders
GROUP BY week
ORDER BY [Total Order] DESC;


SELECT
	week,
	SUM(num_orders) AS [Total Order],
	COUNT(num_orders) AS [Frequecy of order]
FROM weekly_orders
GROUP BY week
ORDER BY [Frequecy of order] DESC;


/*Attempt to group data by months were avoided due to absence of year information*/
SELECT
	DATENAME(MONTH, week),
	SUM(num_orders) AS [Total Order],
	COUNT(num_orders) AS [Frequecy of order]
FROM weekly_orders
GROUP BY DATENAME(MONTH, week)
ORDER BY [Total Order] DESC;

--=================================================================================================
--3. Which region is most efficient in terms of delivery operations (orders per operational area)? 
--=================================================================================================
SELECT 
	ci.center_type,
	SUM(wo.num_orders) AS [Total Orders],
	SUM (ci.op_area) AS [Total Area],
	CAST(SUM(wo.num_orders) AS float) / SUM(op_area) AS [Orders Per Area]
FROM 
	center_info ci
JOIN 
	weekly_orders wo ON ci.center_id = wo.center_id
GROUP BY 
	ci.center_type
ORDER BY
	[Orders Per Area] DESC;


SELECT 
	ci.center_id,
	ci.center_type,
	SUM(wo.num_orders) AS [Total Orders],
	SUM (ci.op_area) AS [Total Area],
	CAST(SUM(wo.num_orders) AS float) / SUM(op_area) AS [Orders Per Area]
FROM 
	center_info ci
JOIN 
	weekly_orders wo ON ci.center_id = wo.center_id
GROUP BY 
	ci.center_id, ci.center_type
ORDER BY
	[Orders Per Area] DESC;

-- =========================================
--        Effciency Score for Region
-- =========================================
SELECT
	center_type,
	[Orders Per Area] * [Total Orders] AS [Efficiency score]
FROM
	(SELECT 
	ci.center_type,
	SUM(wo.num_orders) AS [Total Orders],
	SUM (ci.op_area) AS [Total Area],
	CAST(SUM(wo.num_orders) AS float) / SUM(op_area) AS [Orders Per Area]
FROM 
	center_info ci
JOIN 
	weekly_orders wo ON ci.center_id = wo.center_id
GROUP BY 
	ci.center_type) AS SUB

ORDER BY 
	[Efficiency score] DESC;


--===========================================================================================
--4. Which meal categories and cuisines had the highest number of orders? 
--===========================================================================================

SELECT 
	cuisine,
	SUM(num_orders) AS [Total Number of Orders],
	COUNT(num_orders) AS [Order Frequency]
FROM 
	weekly_orders wo
JOIN
	meal_info mi ON wo.meal_id = mi.meal_id
GROUP BY 
	cuisine
ORDER BY SUM(num_orders) DESC;


SELECT 
	category,
	SUM(num_orders) AS [Total Number of Orders],
	COUNT(num_orders) [Order Frequency]
FROM 
	weekly_orders wo
JOIN
	meal_info mi ON wo.meal_id = mi.meal_id
GROUP BY 
	category
ORDER BY SUM(num_orders) DESC;


--===================================================================================
-- 5. Do promotional campaigns (emailer or homepage features) result in more orders? 
--===================================================================================

SELECT
	emailer_for_promotion,
	SUM(num_orders) AS [Total Orders],
	COUNT(num_orders) AS [Frequency of orders],
	AVG(num_orders * 1.0) AS [Avg Orders Per Entry]
FROM
	weekly_orders
GROUP BY
	emailer_for_promotion;


SELECT
	homepage_featured,
	SUM(num_orders) AS [Total Orders],
	COUNT(num_orders) AS [Frequency of orders],
	AVG(num_orders * 1.0) AS [Avg Orders Per Week]
FROM
	weekly_orders
GROUP BY
		homepage_featured;


SELECT
	[Promo Type],
	AVG(base_price - checkout_price) AS [AVG Discount]
FROM (
	SELECT
		base_price,
		checkout_price,
	    CASE
			WHEN emailer_for_promotion = 1 THEN 'Email Promo'
			WHEN homepage_featured = 1 THEN 'Homepage Featured'
			ELSE 'No Promo'
		END AS [Promo Type]
	FROM weekly_orders
	WHERE (base_price - checkout_price) >= 0
) AS SUB
GROUP BY [Promo Type];


--=============================================
-- Data Aggregation Query for Excel Dashboard
--=============================================

SELECT
	wo.weekly_order_id,
	wo.week,
	wo.center_id,
	ci.center_type,
	ci.city_code,
	ci.region_code,
	ci.op_area,
	wo.meal_id,
	mi.category,
	mi.cuisine,
	wo.checkout_price,
	wo.base_price,
	wo.emailer_for_promotion,
	wo.homepage_featured,
	wo.num_orders,
	(wo.base_price - wo.checkout_price) AS discount_per_meal,
	(wo.num_orders * (wo.base_price - wo.checkout_price)) AS total_discount
FROM	
	weekly_orders wo
JOIN
	meal_info mi ON wo.meal_id = mi.meal_id
JOIN
	center_info ci ON wo.center_id = ci.center_id


	