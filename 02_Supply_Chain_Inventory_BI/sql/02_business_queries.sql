-- 1. On-time rate among RECEIVED purchase orders only
SELECT ROUND(100.0*SUM(CASE WHEN days_late=0 THEN 1 ELSE 0 END)/COUNT(*),1) AS on_time_rate_pct,
       ROUND(AVG(actual_lead_days),1) AS avg_actual_lead_days
FROM fact_purchase_orders WHERE status='Received';

-- 2. Supplier service-level scorecard
SELECT s.supplier_name,COUNT(*) AS received_orders,
       ROUND(100.0*AVG(CASE WHEN po.days_late=0 THEN 1.0 ELSE 0.0 END),1) AS on_time_pct,
       ROUND(100.0*SUM(po.qty_received)/NULLIF(SUM(po.qty_ordered),0),1) AS unit_fill_pct,
       ROUND(AVG(po.actual_lead_days),1) AS avg_lead_days
FROM fact_purchase_orders po JOIN dim_suppliers s ON s.supplier_id=po.supplier_id
WHERE po.status='Received' GROUP BY s.supplier_id ORDER BY on_time_pct DESC;

-- 3. Inventory risk at latest stock snapshot PER SKU
WITH latest AS (
 SELECT i.*,ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY week_start DESC) AS rn
 FROM fact_inventory_weekly i
)
SELECT p.product_name, l.stock_on_hand,l.reorder_point,l.inventory_value,
       CASE WHEN l.stockout=1 THEN 'Stockout' WHEN l.below_reorder=1 THEN 'Below reorder' ELSE 'Healthy' END AS stock_health
FROM latest l JOIN dim_products p ON p.product_id=l.product_id
WHERE rn=1 ORDER BY l.below_reorder DESC,l.stock_on_hand ASC;

-- 4. Weekly demand fill rate by month
SELECT month,ROUND(100.0*SUM(weekly_units_fulfilled)/NULLIF(SUM(weekly_units_demanded),0),1) AS demand_fill_pct,
       SUM(stockout) AS stockout_sku_weeks
FROM fact_inventory_weekly GROUP BY month ORDER BY month;

-- 5. Monthly inventory value, using the LAST available weekly snapshot
WITH ranked AS (
 SELECT *,ROW_NUMBER() OVER(PARTITION BY month,product_id ORDER BY week_start DESC) AS rn
 FROM fact_inventory_weekly
)
SELECT month,ROUND(SUM(inventory_value),2) AS month_end_inventory_value,
       SUM(below_reorder) AS sku_below_reorder
FROM ranked WHERE rn=1 GROUP BY month ORDER BY month;
