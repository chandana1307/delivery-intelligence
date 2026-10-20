import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL


load_dotenv()

connection_url = URL.create(
    drivername="postgresql+psycopg2",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    database=os.getenv("DB_NAME"),
)

engine = create_engine(connection_url)

query = """
SELECT *
FROM analytics.ml_order_base;
"""

df = pd.read_sql(query, engine)

print("Database connection successful.")
print(f"Rows: {len(df):,}")
print(f"Columns: {len(df.columns)}")
print(f"Unique orders: {df['order_id'].nunique():,}")
print()
print(df.head())
print("\n--- Modeling Population Validation ---")

print(
    "Analytics eligible:",
    int(df["eligible_for_late_label"].fillna(False).sum())
)

print(
    "ML eligible:",
    int(df["ml_eligible"].fillna(False).sum())
)

print(
    "ML late orders:",
    int(
        (
            df["ml_eligible"].eq(True)
            & df["late_delivery"].eq(True)
        ).sum()
    )
)

ml_df = df[df["ml_eligible"] == True].copy()

print(
    "ML late rate:",
    round(100 * ml_df["late_delivery"].mean(), 2),
    "%"
)

print(
    "Missing score_time in ML population:",
    ml_df["score_time"].isna().sum()
)

print(
    "Duplicate order IDs in ML population:",
    ml_df["order_id"].duplicated().sum()
)
print("\n--- Temporal Split Validation ---")

# Ensure timestamps are true datetime columns
datetime_columns = [
    "order_purchase_timestamp",
    "score_time",
    "label_available_at",
    "order_estimated_delivery_date",
]

for column in datetime_columns:
    df[column] = pd.to_datetime(df[column])

ml_df = df[df["ml_eligible"].eq(True)].copy()

VALIDATION_START = pd.Timestamp("2018-02-01")
TEST_START = pd.Timestamp("2018-05-01")
HOLDOUT_START = pd.Timestamp("2018-08-01")


# Training data available as of February 1, 2018
train_validation_cutoff = ml_df[
    (ml_df["score_time"] < VALIDATION_START)
    & (ml_df["label_available_at"] < VALIDATION_START)
].copy()


# Validation orders
validation_df = ml_df[
    (ml_df["score_time"] >= VALIDATION_START)
    & (ml_df["score_time"] < TEST_START)
].copy()


# Final retraining data available as of May 1, 2018
train_test_cutoff = ml_df[
    (ml_df["score_time"] < TEST_START)
    & (ml_df["label_available_at"] < TEST_START)
].copy()


# Final untouched test period
test_df = ml_df[
    (ml_df["score_time"] >= TEST_START)
    & (ml_df["score_time"] < HOLDOUT_START)
].copy()


# Later holdout / replay period
holdout_df = ml_df[
    ml_df["score_time"] >= HOLDOUT_START
].copy()


def print_split_summary(name, data):
    late_orders = data["late_delivery"].eq(True).sum()
    late_rate = 100 * late_orders / len(data)

    print(
        f"{name}: "
        f"{len(data):,} orders | "
        f"{late_orders:,} late | "
        f"{late_rate:.2f}% late"
    )


print_split_summary(
    "Training available at validation cutoff",
    train_validation_cutoff,
)

print_split_summary(
    "Validation",
    validation_df,
)

print_split_summary(
    "Training available at test cutoff",
    train_test_cutoff,
)

print_split_summary(
    "Test",
    test_df,
)

print_split_summary(
    "Later holdout",
    holdout_df,
)
from features.build_features import build_feature_set_a


print("\n--- Feature Set A Validation ---")

X_train, y_train, feature_columns = build_feature_set_a(
    train_validation_cutoff
)

print("Training feature rows:", len(X_train))
print("Training target rows:", len(y_train))
print("Number of features:", len(feature_columns))

print("\nFeature columns:")
for feature in feature_columns:
    print("-", feature)

print("\nTarget distribution:")
print(y_train.value_counts())

print("\nMissing values by feature:")
print(
    X_train.isna()
    .sum()
    .sort_values(ascending=False)
)