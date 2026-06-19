/*
==============================================================================
DDL Scripts : Create Gold views
==============================================================================
Script purpose:
    This script create viws for the gold layer in the data warehouse.
    The Gold layer represents the final dimensions and fact tables(Star Schema)

    Each view performs transformations and combines data from the silver layer
    to produce a clean , enriched and business-ready dataset

Usage :
    -These views can be queried directly for analytics and reporting
================================================================================
*/

--=============================================================================
--Create Dimension :gold.dim_customers
--=============================================================================
CREATE VIEW gold.dim_customers AS
select 
ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as firstname,
	ci.cst_lastname as lastname,
	la.cntry as country,
	ci.cst_material_status as marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen,'n/a')
	END AS gender,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		ci.cst_key = la.cid

--================================================
--Create Dimensions:Gold.dim_products
--================================================
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() over (ORDER BY pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id AS product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintainance,
	pn.prd_cost as cost,
	pn.prd_line product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_giv2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --FILTER OUT ALL HISTORIC DATA

select * 
from gold.dim_products
  
--=================================================
--Create Dimension : gold.facts_sales
--=================================================
CREATE VIEW gold.fact_sales as
SELECT 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details as sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
on  sd.sls_cust_id = cu.customer_id

