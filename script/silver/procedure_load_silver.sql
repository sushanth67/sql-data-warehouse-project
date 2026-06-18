/*
============================================================================
Stored Procedure:Load Silver Layer(Bronze-> Silver)
============================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract ,transform , Load ) process to 
popular the 'silver'schema tables from the 'bronze' schema
Acrions Performed:
  -Truncates silver tables
  -Insert transformed and cleansed data from bronze into silver tables
Parameters:
  None
  This stored procedure does not accept any parameters or return any values.

Usage Examples
 EXEC silver.load_silver
*/
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver as 
BEGIN
	DECLARE @start_time DATETIME ,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	print'========================================'
	PRINT'LOading silver Layer'
	print'========================================'

	print '---------------------------------------'
	print 'loading crm tables'
	print '---------------------------------------'
	SET @start_time = GETDATE();
	print 'truncating table'
	TRUNCATE TABLE silver.crm_cust_info;
	print 'inserting data into table'
	INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)
	select
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,--remove unwanted spaces
		TRIM(cst_lastname) AS cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 's' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_marital_status,--Normalize marital status value to readable format 

		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr,--Normalize gender value to readable format 
		cst_create_date
	from (--removing duplicates
		select 
			*, 
			Row_number() over (partition BY cst_id ORDER BY cst_create_date DESC) as flag_last
		from bronze.crm_cust_info
		where cst_id IS NOT NULL
	)t 
	where flag_last = 1
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	print 'truncating table'
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.crm_prd_info
	print 'inserting data into table'
	INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	select 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'other sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'  
	end AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) as prd_end_dt
	from bronze.crm_prd_info
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	print 'truncating table'
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.crm_sales_details
	print 'inserting data into table'
	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)

	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_ord_dt = 0 OR LEN(sls_ord_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ord_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales/NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price
	from bronze.crm_sales_details
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	print '---------------------------------------'
	print 'loading erp tables'
	print '---------------------------------------'
	print 'truncating table'
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_cust_az12
	print 'inserting data into table'
	INSERT INTO silver.erp_cust_az12
	(
	cid,
	bdate,
	gen
	)

	select 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
		 ELSE 'N/A'
	END AS gen
	from bronze.erp_cust_az12
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	print 'truncating table'
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_loc_a101
	print 'inserting data into table'
	INSERT INTO silver.erp_loc_a101
	(cid,cntry)
	select 
	REPLACE (cid,'-','') cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'GERMANY'
		 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE cntry
	END AS cntry
	FROM bronze.erp_loc_a101
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	print 'truncating table'
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_px_cat_giv2
	print 'inserting data into table'
	INSERT INTO silver.erp_px_cat_giv2
	(id,cat,subcat,maintainance)
	select 
	id,
	cat,
	subcat,
	maintainance
	from bronze.erp_px_cat_giv2
	SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

	SET @batch_end_time =GETDATE()
	PRINT '================================='
	PRINT 'LOADING SILVER LAYER IS COMPLETED'
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
	PRINT '================================='

END TRY
	BEGIN CATCH
		PRINT '=============================='
		PRINT 'ERROR OCCURED DURING BRINZE LAYER'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' +CAST(ERROR_NUMBER() AS NVARCHAR)
	END CATCH 
END
