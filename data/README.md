# Data handling

Dataset files have not been downloaded yet.

Use the official [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Verify and record licence and attribution requirements before using data in a public demo.

- `raw/`: original downloaded files, preserved unchanged.
- `processed/`: reproducible derived tables.
- `manifests/`: version, provenance, checksums, and acquisition metadata. Do not include credentials or signed download URLs.

Raw data, processed records, database files, trained artifacts, and credentials do not belong in Git. The licence and provenance manifest should be versioned once verified.

See [the first analysis plan](../docs/first-analysis.md) for acquisition and validation steps.
