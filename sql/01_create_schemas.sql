-- Creates database layers used in the project:
-- raw -> source data
-- staging -> cleaned and typed data
-- mart -> analytics-ready data for Power BI

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;