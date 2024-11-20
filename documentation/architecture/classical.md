# Azure Machine Learning Classical ML Architecture

## Table of Contents

- [1. Data Estate](#1-data-estate)
- [2. Administration & Setup](#2-administration--setup)
- [3. Model Development (Inner Loop)](#3-model-development-inner-loop)
- [4. Azure Machine Learning Registries](#4-azure-machine-learning-registries)
- [5. Model Deployment (Outer Loop)](#5-model-deployment-outer-loop)
- [6. Staging & Test](#6-staging--test)
- [7. Production Deployment](#7-production-deployment)
- [8. Monitoring](#8-monitoring)
- [9. Data & Model Monitoring — Events and Actions](#9-data--model-monitoring--events-and-actions)
- [10. Infrastructure Monitoring — Events and Actions](#10-infrastructure-monitoring--events-and-actions)

Below is the MLOps v2 architecture for a Classical Machine Learning scenario on tabular data using Azure Machine Learning along with explanation of the main elements and details.

![Azure Machine Learning Classical Machine Learning Architecture](media/azureml-classicalml-architecture.png)

## 1. Data Estate <a id="1-data-estate"></a>

This element illustrates the organization data estate and potential data sources and targets for a Data Science project. Data Engineers would be the primary owners of this element of the MLOps v2 lifecycle. The Azure data platforms in this diagram are neither exhaustive nor prescriptive. However, data sources and targets that represent recommended best practices based on customer use case are shown.

## 2. Administration & Setup <a id="2-administration--setup"></a>

This element is the first step in the MLOps v2 Accelerator deployment. It consists of all tasks related to creation and management of resources and roles associated with the project. These can include but may not be limited to:

- Creation of project source code repositories.
- Creation of Azure Machine Learning Workspaces for the project using Bicep, ARM, or Terraform.
- Creation/modification of Data Sets and Compute Resources used for model development and deployment.
- Definition of project team users, their roles, and access controls to other resources.
- Creation of CI/CD (Continuous Integration and Continuous Delivery) pipelines
- Creation of Monitors for collection and notification of model and infrastructure metrics.

Personas associated with this phase are primarily the Infrastructure Team but may also include all of Data Engineers, Machine Learning Engineers, and Data Scientists.

## 3. Model Development (Inner Loop) <a id="3-model-development-inner-loop"></a>

The inner loop element consists of your iterative Data Science workflow performed within a dedicated, secure Azure Machine Learning Workspace. A typical workflow is illustrated here from data ingestion, EDA (Exploratory Data Analysis), experimentation, model development and evaluation, to registration of a candidate model for production. This modular element as implemented in the MLOps v2 accelerator is agnostic and adaptable to the process your Data Science team may use to develop models.

Personas associated with this phase include Data Scientists and ML Engineers.

## 4. Azure Machine Learning Registries <a id="4-azure-machine-learning-registries"></a>

When the Data Science team has developed a model that is a candidate for deploying to production, the model can be registered in the Azure Machine Learning Workspace registry. Continuous Integration (CI) pipelines triggered either automatically by model registration and/or gated human-in-the-loop approval promote the model and any other model dependencies to the [Model Deployment](#5-model-deployment-outer-loop) phase.

Personas associated with this stage are typically ML Engineers.

## 5. Model Deployment (Outer Loop) <a id="5-model-deployment-outer-loop"></a>

The Model Deployment or outer loop phase consists of pre-production staging and testing, production deployment, and monitoring of both model/data and infrastructure. Continuous Deployment (CD) pipelines manage the promotion of the model and related assets through production, monitoring, and potential retraining as criteria appropriate to your organization and use case are satisfied.

Personas associated with this phase are primarily ML Engineers.

## 6. Staging & Test <a id="6-staging--test"></a>

The Staging & Test phase can vary with customer practices but typically includes operations such as retraining and testing of the model candidate on production data, test deployments for endpoint performance, data quality checks, unit testing, and Responsible AI checks for model and data bias. This phase takes place in one or more dedicated, secure Azure Machine Learning Workspaces.

## 7. Production Deployment <a id="7-production-deployment"></a>

After a model passes the [Staging & Test](#6-staging--test) phase, the model can be promoted to production via a human-in-the-loop gated approvals. Model deployment options include a Batch Managed Endpoint for batch scenarios or, for online, near-realtime scenarios, either an Online Managed Endpoint or to Kubernetes Services via Azure Arc. Production typically takes place in one or more dedicated, secure Azure Machine Learning Workspaces.

## 8. Monitoring <a id="8-monitoring"></a>

Monitoring in staging/test and production enables you to collect metrics and act on changes in performance degradation of the model, data, and infrastructure. Model and data monitoring may include checking for model and data drift, model performance on new data, and Responsible AI issues. Infrastructure monitoring can watch for issues with endpoint response time, problems with deployment compute capacity, or network issues.

## 9. Data & Model Monitoring — Events and Actions <a id="9-data--model-monitoring--events-and-actions"></a>

Based on the monitoring criteria for model and data concerns such as metric thresholds or schedules, automated triggers and notifications can implement appropriate actions to take. This may be regularly scheduled automated retraining of the model on newer production data and a loop back to [Staging & Test](#6-staging--test) for pre-production evaluation or it may be due to triggers on model or data issues that require a loop back to the [Model Development](#3-model-development-inner-loop) phase where Data Scientists can investigate and potentially develop a new model.

## 10. Infrastructure Monitoring — Events and Actions <a id="10-infrastructure-monitoring--events-and-actions"></a>

Based on monitoring criteria for infrastructure concerns such as endpoint response lag or insufficient compute for the deployment, automated triggers and notifications can implement appropriate actions to take. This triggers a loop back to the [Administration & Setup](#2-administration--setup) phase where the Infrastructure Team can investigate and potentially reconfigure environment compute and network resources.
