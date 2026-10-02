# Project brief

## Objective

Help an operations analyst or manager answer three questions:

1. Where is delivery performance deteriorating?
2. Which orders should the team review within its available daily capacity?
3. What do the records and operating procedures say about a specific order or seller?

The project targets analyst and AI engineering roles, with practical ML supporting the workflow.

## Product scope

### Operations dashboard

Define delivery KPIs with explicit populations, time windows, and denominators. Support filters for seller, geography, category, and date. Show sample sizes with comparisons. Avoid interpreting differences between sellers as causal effects.

### Delivery-risk review queue

The initial proposed score time is order approval. This is provisional until the audit establishes field coverage and defensible availability assumptions. The public dataset contains final records, not a complete historical change log; document which fields are assumed to exist at approval time.

Proposed label: actual customer delivery occurs after the promised delivery calendar date. Verify timestamp semantics before implementing; do not assume that a midnight promise timestamp is an exact midnight deadline.

For the first model, delivered orders with a valid promise and outcome supply observed binary labels. Cancelled and unresolved orders must be reported separately, never silently treated as on-time. Explain that evaluating only delivered orders limits the claims we can make about all incoming orders.

Build one prediction per order. Aggregate item and seller information without multiplying orders across one-to-many joins. Seller performance features must use outcomes known strictly before the score time.

At evaluation time, compare the model with a simple operational rule and a basic statistical model. Rank within daily review capacity; report precision at K, recall at K, PR-AUC, calibration, and sample counts. Choose thresholds on validation data and reserve an untouched later test period. Only labels available by each simulated training cutoff may enter that training run.

### AI investigations

The assistant should call typed, read-only functions for order lookup, seller metrics, and high-risk order retrieval. SQL or application code calculates numerical answers. The assistant explains returned results and links supporting records.

Document retrieval is for clearly labelled demo operating procedures. Those procedures are authored for this project, not represented as Olist's actual policies. The assistant must distinguish observed facts, model predictions, and suggested review actions.

Evaluate numerical correctness, tool arguments, retrieval relevance, citations, unsupported answers, latency, and usage cost. Restrict tool access to the demo's intended data; include tests for instructions embedded in retrieved content.

## Realistic operation

Replay historical orders chronologically. Simulate information becoming available at the appropriate event times. Reveal delivery outcomes only when their timestamps are reached. Expose replay time and distinguish completed replay runs from live external data ingestion.

## Initial boundaries

- Human review suggestions only; no real customer messages, purchases, or seller actions.
- Practical tabular modelling; model complexity must earn its place through evaluation.
- No invented claims of reduced delays or financial savings.
- Public demo access and eligible services must be checked against university GCP account restrictions.

## Success criteria

1. An unfamiliar visitor can complete the main demo workflow using a public URL.
2. Data processing and evaluation are reproducible with documented setup steps.
3. Dashboard figures reconcile with defined SQL metrics and their denominators.
4. Model results include baselines, time-based evaluation, segment analysis, and limitations. A model that fails to beat a baseline is reported honestly.
5. Assistant quality is measured on a versioned question set that includes unanswerable questions.
6. Deployment includes logs, meaningful tests, spending controls, and a plan for credit expiry.

## Confirmed constraints and open decisions

Confirmed: Python, SQL, and ML experience; analyst and AI engineering career focus; quality prioritized over a short deadline; unused university GCP credits reported to expire after one year.

To verify before provisioning: credit balance, exact expiry date, service eligibility, permissions, public hosting policy, and affordable operation after credits expire.
