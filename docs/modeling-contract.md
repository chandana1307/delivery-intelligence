# Delivery Risk Modeling Contract

## Prediction Objective

Estimate the risk that an order will be delivered after its promised delivery calendar date.

## Prediction Time

The model is intended to score an order at order approval time.

The source dataset contains final historical records rather than a complete event-by-event change history. Feature availability at approval time is therefore based on documented assumptions and conservative exclusions.

## Unit of Prediction

One prediction per order.

Order-item, product, seller, payment, and other one-to-many data must be aggregated before model training so that an order is not duplicated.

## Target

`late_delivery = 1` when the actual customer delivery calendar date is later than the estimated delivery calendar date.

`late_delivery = 0` when the eligible delivered order arrives on or before the estimated delivery calendar date.

## Modeling Population

The primary supervised-learning population contains orders that:

- were delivered
- have an observed actual customer delivery timestamp
- have an estimated delivery date
- have a usable order approval timestamp

Canceled and unresolved orders are excluded from the binary target population and reported separately.

## Leakage Rule

A feature may contain only information assumed to be available at or before the order approval timestamp.

Actual delivery timestamps, carrier events occurring after approval, reviews, final order status, and future outcomes are prohibited model features.

Historical performance features may use only outcomes known before the order being scored.

## Evaluation Strategy

Evaluation uses chronological time-based splits rather than a random train/test split.

The primary development split is based on the order approval timestamp:

- Training development period: orders approved before February 1, 2018
- Validation period: February 1, 2018 through April 30, 2018
- Final test period: May 1, 2018 through July 31, 2018
- Later holdout / replay period: August 1, 2018 onward where eligible outcomes are available

Observed modeling-population counts are:

| Period | Eligible Orders | Late Orders | Late Rate |
|---|---:|---:|---:|
| Training development | 50,613 | 2,852 | 5.63% |
| Validation | 20,258 | 2,556 | 12.62% |
| Final test | 19,081 | 718 | 3.76% |
| Later holdout | 6,504 | 408 | 6.27% |

The variation in late-delivery rates across periods demonstrates temporal distribution change and is one reason a random split is inappropriate.

Model architecture, features, hyperparameters, and operational thresholds will be selected using training and validation data only.

The May–July 2018 test period will remain untouched until model selection is complete.

Training eligibility also depends on label availability. An order may be used for training at a historical cutoff only when its delivery outcome was already known before that cutoff.

### Label Availability at Training Cutoffs

Orders are not eligible for model training merely because they were approved before a training cutoff. Their delivery outcome must also have been observed before that cutoff.

At the February 1, 2018 validation training cutoff:

- 50,613 ML-eligible orders had been approved
- 47,780 had delivery outcomes already known and may be used for training
- 2,833 had unresolved outcomes at the cutoff and are excluded from that training run

These unresolved historical orders may become eligible for later training runs after their outcomes are observed.

At the May 1, 2018 final-test training cutoff:

- 70,871 ML-eligible orders had been approved
- 68,304 had delivery outcomes already known and may be used for final retraining
- 2,567 had unresolved outcomes at the cutoff and are excluded from that training run

This preserves historical realism by preventing unresolved orders from contributing future outcome information to training.

## Business Use

Predictions are intended to rank orders for human operational review.

They do not automatically contact customers, penalize sellers, cancel orders, or trigger financial actions.