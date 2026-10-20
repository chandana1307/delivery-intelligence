import pandas as pd

from src.features.build_seller_history import (
    build_order_seller_history_features,
)


def test_future_outcome_not_used_in_seller_history():

    data = pd.DataFrame(
        {
            "order_id": [
                "order_1",
                "order_2",
            ],

            "seller_id": [
                "seller_a",
                "seller_a",
            ],

            "score_time": pd.to_datetime(
                [
                    "2018-01-01",
                    "2018-01-10",
                ]
            ),

            "label_available_at": pd.to_datetime(
                [
                    "2018-01-15",
                    "2018-01-20",
                ]
            ),

            "late_delivery": [
                True,
                False,
            ],

            "ml_eligible": [
                True,
                True,
            ],
        }
    )

    features = (
        build_order_seller_history_features(
            data
        )
    )

    second_order = features[
        features[
            "order_id"
        ] == "order_2"
    ].iloc[0]

    assert (
        second_order[
            "seller_prior_orders_min"
        ]
        == 0
    )


def test_known_prior_outcome_is_used():

    data = pd.DataFrame(
        {
            "order_id": [
                "order_1",
                "order_2",
            ],

            "seller_id": [
                "seller_a",
                "seller_a",
            ],

            "score_time": pd.to_datetime(
                [
                    "2018-01-01",
                    "2018-01-20",
                ]
            ),

            "label_available_at": pd.to_datetime(
                [
                    "2018-01-10",
                    "2018-01-30",
                ]
            ),

            "late_delivery": [
                True,
                False,
            ],

            "ml_eligible": [
                True,
                True,
            ],
        }
    )

    features = (
        build_order_seller_history_features(
            data
        )
    )

    second_order = features[
        features[
            "order_id"
        ] == "order_2"
    ].iloc[0]

    assert (
        second_order[
            "seller_prior_orders_min"
        ]
        == 1
    )

    assert (
        second_order[
            "seller_prior_late_rate_max"
        ]
        == 1.0
    )