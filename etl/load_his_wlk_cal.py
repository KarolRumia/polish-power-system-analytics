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
        "https://api.raporty.pse.pl/api/his-wlk-cal"
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
            INSERT INTO raw.his_wlk_cal (
                dtime,
                dtime_utc,
                business_date,
                demand,
                pv,
                wi,
                swm_p,
                swm_np,
                publication_ts_utc
            )
            SELECT %s, %s, %s, %s, %s, %s, %s, %s, %s
            WHERE NOT EXISTS (
                SELECT 1
                FROM raw.his_wlk_cal
                WHERE dtime_utc = %s
            )
            """,
            (
                row.get("dtime"),
                row.get("dtime_utc"),
                row.get("business_date"),
                row.get("demand"),
                row.get("pv"),
                row.get("wi"),
                row.get("swm_p"),
                row.get("swm_np"),
                row.get("publication_ts_utc"),
                row.get("dtime_utc")
            )
        )

    conn.commit()

    print(f"Processed {len(rows)} rows")

    current_date += timedelta(days=1)

cursor.close()
conn.close()

print("Finished.")