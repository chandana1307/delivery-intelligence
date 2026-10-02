# Milestones

Proceed by acceptance checks rather than calendar deadlines.

| Stage | Deliverable | Acceptance check |
| --- | --- | --- |
| 1. Data audit | Source manifest, licence record, schema inventory, quality report | Files are traceable; keys, missingness, time coverage, and major limitations are documented |
| 2. Analytics | PostgreSQL model, KPI dictionary, SQL analysis, initial charts | Order totals reconcile across joins; metric definitions and findings can be reproduced |
| 3. Prediction | Baselines, feature pipeline, candidate model, evaluation report | Field availability is documented; training labels respect cutoffs; test period remains untouched during tuning |
| 4. Usable application | Dashboard, order detail pages, risk queue, API | Main workflow works end to end; important calculations and endpoints have meaningful tests |
| 5. AI assistant | Record tools, procedure retrieval, answer evaluation | Answers are checked against records; unsupported questions are handled; citations and tool calls are measured |
| 6. Deployment and replay | Public GCP demo, replay worker, logs, monitoring | Replay respects event time; restart behaviour is understood; account access and costs are checked |
| 7. Portfolio release | README, architecture diagram, case study, demo video | A fresh setup is documented and results support every public claim |

## First working session

1. Verify a local Python runtime and select the project environment.
2. Acquire the official dataset and record download date, version, licence, and checksums.
3. Generate a schema and data-quality report before modelling.
4. Settle the prediction point and label semantics using that evidence.
5. Implement the order-level analysis and first business metrics.

## Deployment strategy

Develop locally, deploy a working slice, then add the assistant and replay. Configure Cloud Run conservatively and measure usage. Ordinary budget alerts are notifications, not a spending cap. Choose the database and AI service after checking the credit balance and grant coverage.

Keep application code and model artifacts portable so the demo can be moved or reduced in scope when credits expire.
