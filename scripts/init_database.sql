-- Database & Schema Initialization
-- ============================================================
-- Creates the data warehouse database and defines the
-- schemas required for staging, transformation, and analytics.
--
-- Purpose:
-- - Initialize the data warehouse database
-- - Create logical schemas for data organization

CREATE DATABASE DataWareHouse;

USE DataWareHouse;

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
