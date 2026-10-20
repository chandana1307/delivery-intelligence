# Delivery Risk Model Selection

## Selected Model

The selected validation-stage model is:

- Model: Logistic Regression
- Feature set: Feature Set A
- Class weighting: None
- Maximum iterations: 2000
- Random state: 42
- Prediction time: Order approval
- Primary selection metric: Average Precision
- Operational review capacity: Top 25 orders per approval day

## Validation Results

Validation period:

- February 1, 2018 through April 30, 2018
- 20,241 orders
- 2,556 late deliveries
- Late-delivery rate: 12.63%

Selected model performance:

- Average Precision: 0.2296
- ROC-AUC: 0.6651
- Brier Score: 0.1185

Daily review performance:

- Top 10 precision: 28.60%
- Top 10 recall: 9.62%
- Top 10 lift: 2.27x

- Top 25 precision: 29.67%
- Top 25 recall: 24.96%
- Top 25 lift: 2.35x

- Top 50 precision: 26.02%
- Top 50 recall: 43.78%
- Top 50 lift: 2.06x

## Model Comparison

Feature Set B added leakage-safe historical seller performance features.
It did not improve overall validation ranking compared with Feature Set A.

XGBoost models and a small validation-only tuning round were also evaluated.
The best tuned XGBoost candidate remained below Logistic Regression in
Average Precision and operational queue performance.

Balanced Logistic Regression also performed below the standard Logistic
Regression model.

The simpler Logistic Regression model was therefore retained.

## Calibration

The selected model is not well calibrated across the validation period.

Expected Calibration Error:

- 10.15 percentage points

The highest predicted-risk decile had:

- Mean model score: 6.56%
- Observed late-delivery rate: 29.35%

Because the project's primary use case is ranking orders for human review,
the raw model output will be treated as a relative risk score rather than
an exact probability of late delivery.

No claim should be made that a score of X% represents an X% probability
of late delivery.

## Final-Test Freeze

The following decisions are frozen before final-test evaluation:

- Logistic Regression
- Feature Set A
- No class weighting
- max_iter = 2000
- random_state = 42
- Average Precision as primary ranking metric
- Daily Top 25 as the primary operational capacity
- Top 10 and Top 50 reported as sensitivity checks
- Raw output interpreted as a risk score rather than a calibrated probability

The May-July 2018 final test period has not been used for model selection
or tuning.

## Final Untouched Test Results

After all model, feature, and operational-capacity decisions were frozen,
the selected Logistic Regression model was retrained using only outcomes
known by May 1, 2018.

Final training population:

- 68,277 orders
- 4,947 late deliveries
- Late rate: 7.25%

Untouched test period:

- May 1, 2018 through July 31, 2018
- 19,055 orders
- 718 late deliveries
- Late rate: 3.77%

Final test performance:

- Average Precision: 0.0840
- ROC-AUC: 0.7038
- Brier Score: 0.0375

Daily Top-10 review:

- Precision: 9.57%
- Recall: 11.98%
- Lift: 2.54x

Daily Top-25 review:

- Precision: 8.15%
- Recall: 25.35%
- Lift: 2.16x

Daily Top-50 review:

- Precision: 6.75%
- Recall: 41.92%
- Lift: 1.79x

The final test period had a substantially lower late-delivery prevalence
than the validation period (3.77% versus 12.63%). Therefore, absolute
precision and Average Precision decreased.

However, the selected model continued to meaningfully rank higher-risk
orders. At the primary operational capacity of 25 orders per day, the
review queue had a late-delivery rate 2.16 times the overall test-period
rate and captured 25.35% of all late deliveries.

The final test results will not be used for additional model tuning or
feature selection.