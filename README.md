# Azure MLOps (v2) Solution Accelerator

![Header](media/mlopsheader.jpg)

## Table of Contents

- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Documentation](#documentation)
- [Contributing](#contributing)

Welcome to the MLOps (v2) solution accelerator repository! This project is intended to serve as the starting point for MLOps implementation in Azure.

MLOps is a set of repeatable, automated, and collaborative workflows with best practices that empower teams of ML professionals to quickly and easily get their machine learning models deployed into production. You can learn more about MLOps here:

- [MLOps with Azure Machine Learning](https://azure.microsoft.com/services/machine-learning/mlops/#features)
- [Cloud Adoption Framework Guidance](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/ai-machine-learning-mlops)
- [How: Machine Learning Operations](https://docs.microsoft.com/azure/machine-learning/concept-model-management-and-deployment)

## Project Overview <a name="project-overview"></a>

The solution accelerator provides a modular end-to-end approach for MLOps in Azure based on pattern architectures. As each organization is unique, solutions will often need to be customized to fit the organization's needs.

The solution accelerator goals are:

- Simplicity
- Modularity
- Repeatability & Security
- Collaboration
- Enterprise readiness

It accomplishes these goals with a template-based approach for end-to-end data science, driving operational efficiency at each stage. You should be able to get up and running with the solution accelerator in a few hours.

## Prerequisites <a name="prerequisites"></a>

1. An Azure subscription. If you don't have an Azure subscription, [create a free account](https://azure.microsoft.com/en-us/free/machine-learning/search/?OCID=AIDcmm5edswduu_SEM_822a7351b5b21e0f1ffe102c9ca9e99f:G:s&ef_id=822a7351b5b21e0f1ffe102c9ca9e99f:G:s&msclkid=822a7351b5b21e0f1ffe102c9ca9e99f) before you begin.

> [!IMPORTANT]
> If you use either a Free/Trial, or similar learning purpose subscriptions like Visual Studio Premium with MSDN, some provisioning tasks might not run as expected due to limitations imposed on **Usage + quotas** on your subscription. To help you succeed, we have provided specific instructions before provisioning throughout the guide, and you are highly advised to read those instructions carefully.

2. For Azure DevOps-based deployments and projects:

   - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) with `azure-devops` extension.
   - [Terraform extension for Azure DevOps](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks) if you are using Terraform to spin up the infrastructure.

3. For GitHub-based deployments and projects:

   - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
   - [GitHub client](https://cli.github.com/)

4. Git bash, WSL, or another shell script editor on your local machine

## Documentation <a id="documentation"></a>

1. [Solution Accelerator Concepts and Structure](documentation/structure/README.md) — Philosophy and Organization.
2. [Architectural Patterns](documentation/architecture/README.md) — Supported Machine Learning Patterns.
3. [Accelerator Deployment Guides](documentation/deployguides/README.md) — How to deploy and use the solution accelerator with Azure DevOps or GitHub.
4. Quickstarts — Precreated project scenarios for demos/POCs. [Azure DevOps ADO Quickstart](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-setup-mlops-azureml?tabs=azure-shell).
5. YouTube Videos: [Deploy MLOps on Azure in Less Than an Hour](https://www.youtube.com/watch?v=5yPDkWCMmtk) and [AI Show](https://www.youtube.com/watch?v=xaW_A0sV6PU).

## Contributing <a id="contributing"></a>

This project welcomes contributions and suggestions. To learn more visit the contributing section, see [CONTRIBUTING.md](CONTRIBUTING.md) for details.
