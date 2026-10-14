# Power BI build guide — Supply Chain & Inventory BI

**100% synthetic data.** Currency is illustrative LKR.

1. Import four CSVs and rename `Dim_Suppliers`, `Dim_Products`, `Fact_Purchase_Orders`, `Fact_Inventory_Weekly`.
2. Relationships (single-direction): `Dim_Suppliers[supplier_id]`→`Dim_Products[supplier_id]` (1:*); `Dim_Products[product_id]`→`Fact_Purchase_Orders[product_id]` (1:*); `Dim_Products[product_id]`→`Fact_Inventory_Weekly[product_id]` (1:*). Do **not** directly relate suppliers to POs as well; that creates a second filter path.
3. Set `week_start`, `order_date`, `expected_date`, and `received_date` as Date; quantities and flags as Whole Number.
4. Add each measure separately from `Measures.dax`.
5. **Page 1: Procurement performance:** On-Time Delivery %, Supplier Fill Rate %, Avg Lead Days, supplier on-time bar chart, supplier-by-delay table. Use `status = Received` for delivery metrics.
6. **Page 2: Inventory health:** Latest-week date slicer (single-select), SKU stock on hand and reorder point, Inventory Value (Selected Week), stockout count and below-reorder heatmap, demand fill % by month.
7. **Important:** inventory is a **snapshot fact**. Never SUM `inventory_value` over multiple weeks to report ending inventory; filter to a single week or use a last-snapshot measure.
8. Business action example: prioritize low-stock SKUs supplied by vendors with weak on-time rates.

**Definitions:** On-Time % = received POs with received_date ≤ expected_date / all received POs. Supplier unit fill = received units / ordered units among received POs. Demand Fill = units fulfilled / units demanded. A Stockout SKU-Week is a specific SKU with ending stock zero in a specific week.
