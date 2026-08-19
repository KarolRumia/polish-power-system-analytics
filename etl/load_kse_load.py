import requests
import psycopg2
import time
from datetime import datetime, timedelta
from getpass import getpass

START_DATE = "2024-06-14"
END_DATE = "2026-06-30"

DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "polish_power_analytics"
DB_USER = "postgres"


password = getpass("PostgreSQL password: ")

conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=password
)

cursor = conn.cursor()

current_date = datetime.strptime(START_DATE, "%Y-%m-%d")
end_date = datetime.strptime(END_DATE, "%Y-%m-%d")

while current_date <= end_date:

    date_string = current_date.strftime("%Y-%m-%d")

    print(f"Loading {date_string}...")

    url = (
        "https://api.raporty.pse.pl/api/kse-load"
        f"?$filter=business_date%20eq%20%27{date_string}%27"
        "&$first=200"
    )

    rows = []

    while url:
        for attempt in range(5):
                try:
                    response = requests.get(url, timeout=30)
                    response.raise_for_status()
                    break
                except requests.RequestException as e:
                    print(f"Request failed: {e}")

                    if attempt == 4:
                        raise

                    print("Retrying in 5 seconds...")
                    time.sleep(5)

        data = response.json()

        rows.extend(data["value"])
        url = data.get("nextLink")

    for row in rows:

        cursor.execute(
            """
            INSERT INTO raw.kse_load (
                dtime,
                period,
                dtime_utc,
                load_fcst,
                period_utc,
                load_actual,
                business_date,
                publication_ts,
                publication_ts_utc
            )
            SELECT %s, %s, %s, %s, %s, %s, %s, %s, %s
            WHERE NOT EXISTS (
                SELECT 1
                FROM raw.kse_load
                WHERE dtime_utc = %s
            )
            """,
            (
                row.get("dtime"),
                row.get("period"),
                row.get("dtime_utc"),
                row.get("load_fcst"),
                row.get("period_utc"),
                row.get("load_actual"),
                row.get("business_date"),
                row.get("publication_ts"),
                row.get("publication_ts_utc"),
                row.get("dtime_utc")
            )
        )

    conn.commit()

    print(f"Loaded {len(rows)} rows")

    current_date += timedelta(days=1)

cursor.close()
conn.close()

print("Finished.")