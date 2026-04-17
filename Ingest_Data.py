import os
import glob
import pandas as pd
from sqlalchemy import create_engine

# --- Configuration ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "ehr_pipeline",
    "user": "postgres",
    "password": "#1Bassman"
}

DATA_DIR = "synthea/output/csv"

# --- Create SQLAlchemy engine (safe for special chars in password) ---
engine = create_engine(
    "postgresql+psycopg2://",
    connect_args={
        "host": DB_CONFIG["host"],
        "port": DB_CONFIG["port"],
        "dbname": DB_CONFIG["database"],
        "user": DB_CONFIG["user"],
        "password": DB_CONFIG["password"]
    }
)

def upload_csv_files(data_dir, engine, chunksize=10000):
    csv_files = glob.glob(os.path.join(data_dir, "*.csv"))

    if not csv_files:
        print("No CSV files found!")
        return

    for filepath in csv_files:
        table_name = os.path.splitext(os.path.basename(filepath))[0].lower()
        print(f"Uploading: {filepath} → table: {table_name}")

        try:
            for i, chunk in enumerate(pd.read_csv(filepath, chunksize=chunksize, low_memory=False)):
                chunk.columns = [c.lower().replace(" ", "_") for c in chunk.columns]

                if_exists = "replace" if i == 0 else "append"
                chunk.to_sql(
                    name=table_name,
                    con=engine,
                    if_exists=if_exists,
                    index=False,
                    method="multi"
                )

            print(f"  ✓ Done: {table_name}")

        except Exception as e:
            print(f"  ✗ Failed {table_name}: {e}")

if __name__ == "__main__":
    upload_csv_files(DATA_DIR, engine)
    print("\nAll done!")