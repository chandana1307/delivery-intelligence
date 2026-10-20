import numpy as np
import pandas as pd


def build_order_seller_history_features(
    seller_source: pd.DataFrame,
) -> pd.DataFrame:
    """
    Build seller-history features as they would have been known
    at each order's approval time.

    Only outcomes with:
        label_available_at < current_order_score_time
    are allowed.
    """

    df = seller_source.copy()

    df["score_time"] = pd.to_datetime(df["score_time"])
    df["label_available_at"] = pd.to_datetime(
        df["label_available_at"]
    )

    df = df[df["ml_eligible"].eq(True)].copy()

    df["late_int"] = df["late_delivery"].astype(int)

    # Build historical event arrays once for every seller.
    seller_histories = {}

    for seller_id, group in df.groupby(
        "seller_id",
        sort=False,
    ):
        group = group.sort_values(
            "label_available_at"
        )

        event_times = group[
            "label_available_at"
        ].to_numpy(dtype="datetime64[ns]")

        late_values = group[
            "late_int"
        ].to_numpy(dtype=np.int64)

        cumulative_late = np.cumsum(late_values)

        seller_histories[seller_id] = (
            event_times,
            cumulative_late,
        )

    seller_feature_rows = []

    # Calculate what history was known at each order's score time.
    for seller_id, current_orders in df.groupby(
        "seller_id",
        sort=False,
    ):
        current_orders = current_orders.copy()

        event_times, cumulative_late = (
            seller_histories[seller_id]
        )

        score_times = current_orders[
            "score_time"
        ].to_numpy(dtype="datetime64[ns]")

        # side="left" means only label times STRICTLY
        # before score_time are counted.
        prior_count = np.searchsorted(
            event_times,
            score_times,
            side="left",
        )

        prior_late = np.zeros(
            len(current_orders),
            dtype=np.int64,
        )

        has_history = prior_count > 0

        prior_late[has_history] = (
            cumulative_late[
                prior_count[has_history] - 1
            ]
        )

        prior_rate = np.full(
            len(current_orders),
            np.nan,
            dtype=float,
        )

        prior_rate[has_history] = (
            prior_late[has_history]
            / prior_count[has_history]
        )

        current_orders[
            "seller_prior_orders"
        ] = prior_count

        current_orders[
            "seller_prior_late_orders"
        ] = prior_late

        current_orders[
            "seller_prior_late_rate"
        ] = prior_rate

        current_orders[
            "seller_history_available"
        ] = has_history.astype(int)

        seller_feature_rows.append(
            current_orders[
                [
                    "order_id",
                    "seller_id",
                    "seller_prior_orders",
                    "seller_prior_late_orders",
                    "seller_prior_late_rate",
                    "seller_history_available",
                ]
            ]
        )

    seller_level = pd.concat(
        seller_feature_rows,
        ignore_index=True,
    )

    # Multi-seller orders must return to ONE ROW PER ORDER.
    order_level = (
        seller_level
        .groupby(
            "order_id",
            as_index=False,
        )
        .agg(
            seller_prior_orders_min=(
                "seller_prior_orders",
                "min",
            ),
            seller_prior_orders_mean=(
                "seller_prior_orders",
                "mean",
            ),
            seller_prior_orders_max=(
                "seller_prior_orders",
                "max",
            ),
            seller_prior_late_rate_mean=(
                "seller_prior_late_rate",
                "mean",
            ),
            seller_prior_late_rate_max=(
                "seller_prior_late_rate",
                "max",
            ),
            seller_history_available_share=(
                "seller_history_available",
                "mean",
            ),
        )
    )

    return order_level