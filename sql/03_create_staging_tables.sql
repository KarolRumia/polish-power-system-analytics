-- Staging layer tables.
-- Data is cleaned, typed and prepared for analytical use.

CREATE TABLE IF NOT EXISTS staging.kse_load (
    period_end_utc TIMESTAMPTZ PRIMARY KEY,
    local_dtime_raw TEXT,
    business_date DATE NOT NULL,
    forecast_load_mw NUMERIC(12,3),
    actual_load_mw NUMERIC(12,3),
    published_at_utc TIMESTAMPTZ,
    source_raw_id BIGINT NOT NULL,
    transformed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.his_wlk_cal (
    period_end_utc TIMESTAMPTZ PRIMARY KEY,
    business_date DATE NOT NULL,
    demand_mw NUMERIC(12,3),
    pv_mw NUMERIC(12,3),
    wind_mw NUMERIC(12,3),
    swm_parallel_mw NUMERIC(12,3),
    swm_non_parallel_mw NUMERIC(12,3),
    published_at_utc TIMESTAMPTZ,
    source_raw_id BIGINT NOT NULL,
    transformed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);