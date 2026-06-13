/*
=====================================================================
DDL Script : create bronze tables
=====================================================================
script purpose :
This script creates a tables in the 'bronze' schema dropping existing 
if they already exist .
Run this script to re-define the DDL structure of 'bronze' tables
======================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME ,@end_time DATETIME;
	BEGIN TRY
		print '---------------------------------------'
		print 'loading crm tables'
		print '---------------------------------------'
		SET @start_time = GETDATE();
		print 'truncating table: bronze.crm_cust_info'
		truncate table bronze.crm_cust_info

		print 'Insert data into: bronze.crm_cust_info'
		bulk insert bronze.crm_cust_info
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		);
		SET @end_time = GETDATE() ;
		print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		truncate table bronze.crm_prd_info
		bulk insert bronze.crm_prd_info
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)

		truncate table bronze.crm_sales_details
		bulk insert bronze.crm_sales_details
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)

		truncate table bronze.erp_cust_az12
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)

		truncate table bronze.erp_loc_a101
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)

		truncate table bronze.erp_px_cat_giv2
		bulk insert bronze.erp_px_cat_giv2
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		);
		

	END TRY
	BEGIN CATCH
		print '=============================='
		print 'error occured during loading bronze layer'
		print 'error message' + ERROR_MESSAGE()
		print 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		print 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		print '=============================='
	END 
	CATCH
END


execute bronze.load_bronze
