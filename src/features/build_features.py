import pandas as pd


TARGET_COLUMN = "late_delivery"

ID_COLUMNS = [
    "order_id",
]

METADATA_COLUMNS = [
    "score_time",
    "label_available_at",
    "eligible_for_late_label",
    "ml_eligible",
]

FORBIDDEN_FEATURES = [
    "late_delivery",
    "label_available_at",
    "order_delivered_customer_date",
    "order_delivered_carrier_date",
    "order_status",
    "delivery_days",
]


BASE_NUMERIC_FEATURES = [
    "promised_lead_days_approval",
    "purchase_to_approval_hours",
    "item_count",
    "product_count",
    "seller_count",
    "total_item_value",
    "total_freight_value",
    "total_order_value",
]

BASE_CATEGORICAL_FEATURES = [
    "customer_state",
]

BASE_BINARY_FEATURES = [
    "has_item_record",
]


def add_approval_time_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create calendar features using information available at order approval time.
    """

    result = df.copy()

    result["score_time"] = pd.to_datetime(result["score_time"])

    result["approval_hour"] = result["score_time"].dt.hour
    result["approval_day_of_week"] = result["score_time"].dt.dayofweek
    result["approval_month"] = result["score_time"].dt.month

    result["approval_weekend"] = (
        result["score_time"].dt.dayofweek >= 5
    ).astype(int)

    return result


def get_feature_columns():
    numeric_features = BASE_NUMERIC_FEATURES + [
        "approval_hour",
        "approval_day_of_week",
        "approval_month",
    ]

    categorical_features = BASE_CATEGORICAL_FEATURES

    binary_features = BASE_BINARY_FEATURES + [
        "approval_weekend",
    ]

    return numeric_features, categorical_features, binary_features


def build_feature_set_a(df: pd.DataFrame):
    """
    Build the initial approval-time static feature set.

    This deliberately excludes historical seller features.
    Those will be added later as Feature Set B.
    """

    data = add_approval_time_features(df)

    numeric_features, categorical_features, binary_features = (
        get_feature_columns()
    )

    feature_columns = (
        numeric_features
        + categorical_features
        + binary_features
    )

    leaked_columns = set(feature_columns).intersection(FORBIDDEN_FEATURES)

    if leaked_columns:
        raise ValueError(
            f"Leakage detected in model features: {sorted(leaked_columns)}"
        )

    X = data[feature_columns].copy()

    y = data[TARGET_COLUMN].astype(int).copy()

    return X, y, feature_columns