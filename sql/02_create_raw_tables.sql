-- Raw layer tables.
-- Source values are stored mostly as TEXT to preserve the API response
-- and avoid ingestion failures caused by unexpected formats.

CREATE TABLE IF NOT EXISTS raw.kse_load (
    raw_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dtime TEXT,
    period TEXT,
    dtime_utc TEXT,
    load_fcst TEXT,
    period_utc TEXT,
    load_actual TEXT,
    business_date TEXT,
    publication_ts TEXT,
    publication_ts_utc TEXT,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.his_wlk_cal (
    raw_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dtime TEXT,
    dtime_utc TEXT,
    business_date TEXT,
    demand TEXT,
    pv TEXT,
    wi TEXT,
    swm_p TEXT,
    swm_np TEXT,
    publication_ts_utc TEXT,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);