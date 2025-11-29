# Databricks-Cost-Monitoring-Queries

## 📝 Description

Optimize your Databricks serverless deployments with our comprehensive cost monitoring queries. This repository provides ready-to-use queries designed to give you deep insights into your Databricks serverless costs, allowing you to efficiently manage resources and minimize expenses. Gain granular visibility into your spending and ensure optimal utilization of Databricks' serverless capabilities.

## 📁 Project Structure

```
.
├── databricks-apps.sql => to track the databricks apps cost usage
├── foundation-model-endpoints.sql => to check the accumulated cost for the foundational models
├── model-serving-endpoints.sql => other model endpoint serving costs
├── model-token-usage.sql => gives the count of tokens i/o used 
├── sql-warehouse.sql => accumulated cost for the sql warehouse computes
└── vector-search.sql => accumulated cost for the vector search
```
*Note: Few calculations mentioned here are based on the date price which was available in databricks, it might be subject to change on days. please check the queries in your workspace and deploy it to production if its working still.

## 👥 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/AllAboutAzure/Databricks-Cost-Monitoring-Queries.git`
3. **Create** a new branch: `git checkout -b feature/your-feature`
4. **Commit** your changes: `git commit -am 'Add some feature'`
5. **Push** to your branch: `git push origin feature/your-feature`
6. **Open** a pull request
