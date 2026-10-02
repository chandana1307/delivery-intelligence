\# \\ Delivery Intelligence



An e-commerce analytics project focused on orders that miss their

promised delivery dates.



The project will examine delivery performance across sellers and

regions, identify patterns associated with delays, and build a model

to estimate the risk of late delivery for new orders.



A dashboard will present the findings and predictions. An AI assistant

will help users explore order data and ask questions about delivery

performance.



\# \\ Business Problem



Repeated delivery delays can increase customer support workload,

lead to cancellations or compensation costs, and reduce customer trust.



The project aims to help an operations team identify recurring delivery

problems and decide where to investigate. Predictions will support

human decisions rather than automatically trigger operational actions.



\# \\ Key Questions



\- How often do orders miss their promised delivery dates?

\- How does delivery performance vary across sellers, regions, and time?

\- Which order characteristics are associated with a higher risk of delay?

\- How accurately can we identify at-risk orders before delivery?



\# \\ Planned Technology Stack



| Area | Tools | Purpose |

| --- | --- | --- |

| Data analysis | Python, pandas, Jupyter | Clean data and investigate delivery patterns |

| Database | PostgreSQL, SQL | Organize order data and calculate business metrics |

| Business reporting | Power BI | Create an accompanying delivery-performance report |

| Machine learning | scikit-learn, XGBoost | Build and compare delivery-risk models |

| Model interpretation | SHAP | Examine factors contributing to predictions |

| Experiment tracking | MLflow | Record model configurations and evaluation results |

| Backend | FastAPI, Pydantic | Serve analytics, predictions, and assistant requests |

| Web application | React, TypeScript | Build the dashboard and investigation interface |

| AI assistant | LLM API, tool calling, document retrieval | Query records and retrieve relevant operating procedures |

| Deployment | Docker, GCP Cloud Run, Cloud Storage | Package and host the application and model artifacts |

| Testing and automation | pytest, GitHub Actions | Check changes and automate development workflows |



\# \\ Dataset



\[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)



The analysis will use historical e-commerce records. The application

will replay historical orders to demonstrate how predictions could be

used as new orders arrive.

