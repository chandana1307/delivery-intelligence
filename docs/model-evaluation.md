# Delivery Risk Model Evaluation

## Objective

The prediction system ranks orders by the risk that the customer's
actual delivery calendar date will occur after the promised delivery
calendar date.

The prediction is generated at order approval time.

The intended use is decision support for a human review queue.
The model does not automatically contact customers, sellers, or carriers.

## Modeling Population

The analytics-eligible population contains 96,470 delivered orders with
valid observed and promised delivery dates.

For approval-time modeling:

- 14 orders were excluded because approval time was missing.
- 61 orders were excluded because recorded customer delivery occurred
  at or before approval time.

The final ML-eligible population contains:

- 96,395 orders
- 6,533 late deliveries

The excluded records remain in the source and analytics layers.

## Leakage Controls

Features are restricted to information considered available at order
approval time.

Post-outcome information is excluded, including:

- Actual customer delivery timestamp
- Carrier delivery timestamp
- Final order status
- Delivery duration
- Customer reviews
- Target label

Historical seller outcomes were engineered separately and were permitted
only when:

historical label availability time < current order approval time

This prevents future seller outcomes from leaking into earlier orders.

## Temporal Evaluation Design

The data was evaluated chronologically rather than using a random split.

### Validation

Validation period:

February 1, 2018 through April 30, 2018

Validation population:

- 20,241 orders
- 2,556 late deliveries
- 12.63% late rate

Training data available at the validation cutoff:

- 47,770 orders with outcomes known by February 1, 2018

### Final Test

Final untouched test period:

May 1, 2018 through July 31, 2018

Test population:

- 19,055 orders
- 718 late deliveries
- 3.77% late rate

Final training population:

- 68,277 orders with outcomes known by May 1, 2018
- 4,947 late deliveries
- 7.25% late rate

The final test period was not used for feature selection, hyperparameter
tuning, or model selection.

## Baselines and Candidate Models

The following approaches were evaluated:

1. Dummy prevalence baseline
2. Promised lead-time operational rule
3. Logistic Regression using Feature Set A
4. Logistic Regression using Feature Set B
5. Balanced Logistic Regression
6. XGBoost using Feature Set A
7. XGBoost using Feature Set B
8. Small validation-only XGBoost tuning round

Feature Set B added leakage-safe historical seller-performance features.

These seller-history features did not improve overall validation ranking
performance.

XGBoost also underperformed the simpler Logistic Regression model.

## Selected Model

Final selected model:

- Logistic Regression
- Feature Set A
- No class weighting
- max_iter = 2000
- random_state = 42

Average Precision was used as the primary model-selection metric.

Daily Top 25 orders was selected as the primary operational review
capacity.

## Validation Performance

Selected model validation performance:

- Average Precision: 0.2296
- ROC-AUC: 0.6651
- Brier Score: 0.1185

Daily Top 10:

- Precision: 28.60%
- Recall: 9.62%
- Lift: 2.27x

Daily Top 25:

- Precision: 29.67%
- Recall: 24.96%
- Lift: 2.35x

Daily Top 50:

- Precision: 26.02%
- Recall: 43.78%
- Lift: 2.06x

## Calibration

Validation Expected Calibration Error was approximately 10.15 percentage
points.

The highest predicted-risk decile had:

- Mean model score: 6.56%
- Observed late-delivery rate: 29.35%

The model output is therefore interpreted as a relative risk score rather
than an exact probability of late delivery.

## Final Untouched Test Performance

Final test:

- 19,055 orders
- 718 late deliveries
- 3.77% late rate

Overall model performance:

- Average Precision: 0.0840
- ROC-AUC: 0.7038
- Brier Score: 0.0375

Daily Top 10:

- Precision: 9.57%
- Recall: 11.98%
- Lift: 2.54x

Daily Top 25:

- Precision: 8.15%
- Recall: 25.35%
- Lift: 2.16x

Daily Top 50:

- Precision: 6.75%
- Recall: 41.92%
- Lift: 1.79x

The lower test-period Average Precision and absolute precision reflect the
substantially lower late-delivery prevalence during the test period.

Despite this prevalence shift, the Top-25 review queue had a late-delivery
rate 2.16 times the overall test-period rate and captured 25.35% of all
late deliveries.

## Operational Interpretation

The model is intended to prioritize a limited daily review queue.

At a capacity of 25 orders per approval day, the model concentrates
higher-risk orders into the review queue while requiring review of only
a fraction of daily orders.

The score should be used for prioritization rather than interpreted as
a calibrated probability.

## Explainability

Because the selected model is Logistic Regression, model coefficients
provide direct global information about which transformed features push
the risk score upward or downward.

The coefficient report is generated in:

reports/logistic_feature_importance.csv

Coefficient direction should be interpreted as model association rather
than evidence of causality.

## Error Analysis

Operational errors are evaluated relative to the Top-25-per-day review
policy.

False positives are on-time orders included in the review queue.

False negatives are late orders not selected for review.

Examples are exported to:

- reports/top_false_positives.csv
- reports/top_false_negatives.csv

These examples support investigation of patterns the current feature set
does not capture.

## Segment Evaluation

Final-test performance is evaluated across:

- Customer state
- Promised lead-time band
- Single-seller versus multi-seller orders

Results are stored under reports/.

Segment metrics must be interpreted together with sample sizes because
small segments can produce unstable performance estimates.

## Limitations

The project uses historical final-state records rather than a complete
production event stream.

Availability assumptions are documented and post-outcome fields are
excluded from model features.

The supervised target includes only orders with observable delivered
outcomes.

Canceled and unresolved orders are outside the binary late-delivery
target.

Delivery patterns and late-delivery prevalence vary over time.

Model associations are not causal.

No claim is made that deployment of this model would directly reduce
delivery delays or generate a specific amount of business savings.

## Recommended Use

Use the model to rank orders for analyst or operations-team review.

Do not use the model for fully automated customer, seller, payment, or
fulfillment actions without additional validation, governance, and
operational controls.