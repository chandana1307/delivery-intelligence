import pandas as pd


TARGET_COLUMN = "late_delivery"

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


SELLER_HISTORY_FEATURES = [
    "seller_prior_orders_min",
    "seller_prior_orders_mean",
    "seller_prior_orders_max",
    "seller_prior_late_rate_mean",
    "seller_prior_late_rate_max",
    "seller_history_available_share",
]


def add_approval_time_features(
    df: pd.DataFrame,
) -> pd.DataFrame:

    result = df.copy()

    result["score_time"] = pd.to_datetime(
        result["score_time"]
    )

    result["approval_hour"] = (
        result["score_time"].dt.hour
    )

    result["approval_day_of_week"] = (
        result["score_time"].dt.dayofweek
    )

    result["approval_month"] = (
        result["score_time"].dt.month
    )

    result["approval_weekend"] = (
        result["score_time"].dt.dayofweek >= 5
    ).astype(int)

    return result


def get_feature_columns(
    feature_set="A",
):

    numeric_features = (
        BASE_NUMERIC_FEATURES
        + [
            "approval_hour",
            "approval_day_of_week",
            "approval_month",
        ]
    )

    if feature_set.upper() == "B":
        numeric_features = (
            numeric_features
            + SELLER_HISTORY_FEATURES
        )

    categorical_features = (
        BASE_CATEGORICAL_FEATURES
    )

    binary_features = (
        BASE_BINARY_FEATURES
        + ["approval_weekend"]
    )

    return (
        numeric_features,
        categorical_features,
        binary_features,
    )


def _build_features(
    data,
    feature_set,
):
    (
        numeric_features,
        categorical_features,
        binary_features,
    ) = get_feature_columns(feature_set)

    feature_columns = (
        numeric_features
        + categorical_features
        + binary_features
    )

    leaked_columns = (
        set(feature_columns)
        .intersection(FORBIDDEN_FEATURES)
    )

    if leaked_columns:
        raise ValueError(
            "Leakage detected: "
            f"{sorted(leaked_columns)}"
        )

    X = data[feature_columns].copy()

    y = (
        data[TARGET_COLUMN]
        .astype(int)
        .copy()
    )

    return X, y, feature_columns


def build_feature_set_a(
    df: pd.DataFrame,
):
    data = add_approval_time_features(df)

    return _build_features(
        data,
        "A",
    )


def build_feature_set_b(
    df: pd.DataFrame,
    seller_history_features: pd.DataFrame,
):
    data = add_approval_time_features(df)

    data = data.merge(
        seller_history_features,
        on="order_id",
        how="left",
        validate="one_to_one",
    )

    return _build_features(
        data,
        "B",
    )