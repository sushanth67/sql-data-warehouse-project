/*
================================================================================================
stored Procedure:load bronze layer(source -> bronze)
================================================================================================
script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions :
	-Truncate teh bronze tables before loading data.
	-uses the 'BULK INSERT' command to load data from csv fies to bronze tables.

Parameters:
	none.
  this stored proedure doesnot accept any parameters or return any values.

Usage Examples:
	EXEC bronze.load_bronze;
*/

EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME ,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	print'========================================'
	PRINT'LOading Bronze Layer'
	print'========================================'
		
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

		SET @start_time = GETDATE();
		print 'truncating table'
		truncate table bronze.crm_prd_info
		bulk insert bronze.crm_prd_info
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)
		SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		SET @start_time = GETDATE();
		print 'truncating table'
		truncate table bronze.crm_sales_details
		bulk insert bronze.crm_sales_details
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)
		SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		
		print '---------------------------------------'
		print 'loading erp tables'
		print '---------------------------------------'
		SET @start_time = GETDATE();
		print 'truncating table'
		truncate table bronze.erp_cust_az12
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)
		SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		SET @start_time = GETDATE();
		print 'truncating table'
		truncate table bronze.erp_loc_a101
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)
		SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		SET @start_time = GETDATE();
		print 'truncating table'
		truncate table bronze.erp_px_cat_giv2
		bulk insert bronze.erp_px_cat_giv2
		from 'C:\Users\Sushanthshulikere\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			FIRSTROW = 2,
			Fieldterminator = ',',
			tABLOCK
		)
		SET @end_time = GETDATE();
	print '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		
	SET @batch_end_time =GETDATE()
	PRINT '================================='
	PRINT 'LOADING BRONZE LAYER IS COMPLETED'
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
