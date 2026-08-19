-- Data quality checks for staging tables.

-- 1. Date range and row count
SELECT
    MIN(business_date) AS min_date,
    MAX(business_date) AS max_date,
    COUNT(*) AS row_count
FROM staging.kse_load;


-- 2. NULL check
SELECT
    COUNT(*) FILTER (WHERE forecast_load_mw IS NULL) AS null_forecast,
    COUNT(*) FILTER (WHERE actual_load_mw IS NULL) AS null_actual
FROM staging.kse_load;


-- 3. Duplicate 15-minute periods
SELECT
    period_end_utc,
    COUNT(*) AS duplicate_count
FROM staging.kse_load
GROUP BY period_end_utc
HAVING COUNT(*) > 1
ORDER BY period_end_utc;


-- 4. Missing 15-minute periods
WITH periods AS (
    SELECT
        period_end_utc,
        LAG(period_end_utc)
            OVER (ORDER BY period_end_utc) AS previous_period_end_utc
    FROM staging.kse_load
)
SELECT
    period_end_utc,
    previous_period_end_utc,
    period_end_utc - previous_period_end_utc AS period_gap
FROM periods
WHERE previous_period_end_utc IS NOT NULL
  AND period_end_utc - previous_period_end_utc <> INTERVAL '15 minutes'
ORDER BY period_end_utc;


-- 5. Check whether actual demand agrees between both PSE datasets
SELECT
    COUNT(*) AS mismatched_periods
FROM staging.kse_load k
JOIN staging.his_wlk_cal h
    ON k.period_end_utc = h.period_end_utc
WHERE ABS(k.actual_load_mw - h.demand_mw) > 0.001;


-- 6. Basic range checks
SELECT
    MIN(actual_load_mw) AS min_demand_mw,
    MAX(actual_load_mw) AS max_demand_mw,
    MIN(forecast_load_mw) AS min_forecast_mw,
    MAX(forecast_load_mw) AS max_forecast_mw
FROM staging.kse_load;