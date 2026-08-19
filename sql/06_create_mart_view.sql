-- Analytics-ready view used as the main Power BI data source.
-- Combines forecast, actual demand, renewable generation
-- and 15-minute demand ramp metrics.

CREATE OR REPLACE VIEW mart.v_power_system_analysis AS

WITH base AS (
    SELECT
        k.period_end_utc,
        k.business_date,
        k.forecast_load_mw,
        k.actual_load_mw,

        k.actual_load_mw - k.forecast_load_mw
            AS forecast_error_mw,

        ABS(k.actual_load_mw - k.forecast_load_mw)
            AS absolute_forecast_error_mw,

        h.pv_mw,
        h.wind_mw,

        h.pv_mw + h.wind_mw
            AS renewable_generation_mw,

        k.local_dtime_raw,

        LAG(k.period_end_utc)
            OVER (ORDER BY k.period_end_utc)
            AS previous_period_end_utc,

        LAG(k.actual_load_mw)
            OVER (ORDER BY k.period_end_utc)
            AS previous_actual_load_mw

    FROM staging.kse_load k

    LEFT JOIN staging.his_wlk_cal h
        ON k.period_end_utc = h.period_end_utc
)

SELECT
    period_end_utc,
    business_date,
    forecast_load_mw,
    actual_load_mw,
    forecast_error_mw,
    absolute_forecast_error_mw,
    pv_mw,
    wind_mw,
    renewable_generation_mw,
    local_dtime_raw,

    CASE
        WHEN period_end_utc - previous_period_end_utc
             = INTERVAL '15 minutes'
        THEN actual_load_mw - previous_actual_load_mw
    END AS ramp_mw,

    CASE
        WHEN period_end_utc - previous_period_end_utc
             = INTERVAL '15 minutes'
        THEN ABS(actual_load_mw - previous_actual_load_mw)
    END AS absolute_ramp_mw

FROM base;