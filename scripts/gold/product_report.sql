CREATE VIEW gold.report_products AS
WITH base_query AS (
SELECT
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL)
,
product_aggregation AS (

SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_order,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sale,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
	product_name,
	category,
	subcategory,
	cost
)

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_order,
	DATEDIFF(MONTH, last_sale_order, GETDATE()) AS recency_in_months,
	CASE 
		WHEN total_sale > 5000 THEN 'High-Performance'
		WHEN total_sale >= 10000 THEN 'Mid-Range'
		ELSE 'Low-performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_customers,
	total_sale,
	total_quantity,
	avg_selling_price,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sale / total_orders
	END AS avg_order_revenue,
	CASE
		WHEN lifespan = 0 THEN total_sale
		ELSE total_sale / lifespan
	END AS avg_monthly_revenue
FROM product_aggregation

SELECT * FROM gold.report_products
