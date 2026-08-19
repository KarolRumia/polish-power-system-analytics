-- Transform raw KSE load data into typed staging table.

INSERT INTO staging.kse_load (
    period_end_utc,
    local_dtime_raw,
    business_date,
    forecast_load_mw,
    actual_load_mw,
    published_at_utc,
    source_raw_id
)
SELECT
    CAST(dtime_utc AS timestamp) AT TIME ZONE 'UTC' AS period_end_utc,
    dtime AS local_dtime_raw,
    business_date::date AS business_date,
    REPLACE(load_fcst, ',', '.')::numeric(12,3) AS forecast_load_mw,
    REPLACE(load_actual, ',', '.')::numeric(12,3) AS actual_load_mw,
    CAST(publication_ts_utc AS timestamp) AT TIME ZONE 'UTC' AS published_at_utc,
    raw_id
FROM raw.kse_load
ON CONFLICT (period_end_utc) DO NOTHING;

-- Transform raw system generation data into typed staging table.

INSERT INTO staging.his_wlk_cal (
    period_end_utc,
    business_date,
    demand_mw,
    pv_mw,
    wind_mw,
    swm_parallel_mw,
    swm_non_parallel_mw,
    published_at_utc,
    source_raw_id
)
SELECT
    CAST(dtime_utc AS timestamp) AT TIME ZONE 'UTC' AS period_end_utc,
    business_date::date AS business_date,
    REPLACE(demand, ',', '.')::numeric(12,3) AS demand_mw,
    REPLACE(pv, ',', '.')::numeric(12,3) AS pv_mw,
    REPLACE(wi, ',', '.')::numeric(12,3) AS wind_mw,
    REPLACE(swm_p, ',', '.')::numeric(12,3) AS swm_parallel_mw,
    REPLACE(swm_np, ',', '.')::numeric(12,3) AS swm_non_parallel_mw,
    CAST(publication_ts_utc AS timestamp) AT TIME ZONE 'UTC' AS published_at_utc,
    raw_id
FROM raw.his_wlk_cal
ON CONFLICT (period_end_utc) DO NOTHING;