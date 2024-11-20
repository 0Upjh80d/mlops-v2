# Deployment Guide using Azure DevOps

## Table of Contents

- [Prerequisites](#prerequisites)
- [Steps to Deploy](#steps-to-deploy)
- [Clone and Configure the MLOps V2 Solution Accelerator](#clone-and-configure-the-mlops-v2-solution-accelerator)
- [Create and Configure a New Machine Learning Project Repository](#create-and-configure-a-new-machine-learning-project-repository)
  - [Creating the project repository](#creating-the-project-repository)
  - [Setting project permissions](#setting-project-permissions)
  - [Initializing the new Machine Learning project repository](#initializing-the-new-machine-learning-project-repository)
  - [Project Parameters](#project-parameters)
  - [Create and Configure Service Principals and Connections](#create-and-configure-service-principals-and-connections)
  - [Create Service Connections](#create-service-connections)
  - [Create Azure DevOps Environment](#create-azure-devops-environment)
- [Deploy and Execute Azure Machine Learning Pipelines](#deploy-and-execute-azure-machine-learning-pipelines)
  - [Deploy Azure Machine Learning Infrastructure](#deploy-azure-machine-learning-infrastructure)
  - [Deploy Azure Machine Learning Model Training Pipeline](#deploy-azure-machine-learning-model-training-pipeline)
  - [Deploy Azure Machine Learning Model Deployment Pipeline](#deploy-azure-machine-learning-model-deployment-pipeline)
- [File Structure](#file-structure)
- [Next Steps](#next-steps)

This document will guide you through using the MLOps V2 project generator to deploy a single-environment (`Prod`) demo project using only Azure DevOps to host source repositories and pipelines. See notes at the end for guidance on multi-environment MLOps and adapting the pattern to your use case.

## Prerequisites <a id="prerequisites"></a>

- One or more Azure subscription(s) based on whether you are deploying production only or development and production environments

> [!IMPORTANT]
> As mentioned in the Prerequisites at the beginning [here](../../README.md#prerequisites), if you plan to use either a Free/Trial or similar learning purpose subscriptions, they might pose **Usage + quotas** limitations in the default Azure region being used for deployment. Please read provided instructions carefully to succeessfully execute this deployment.

- An Azure DevOps Organization
- Ability to create Azure service principals to access/create Azure resources from Azure DevOps
- If using Terraform to create and manage infrastructure from Azure DevOps, install the [Terraform extension for Azure DevOps](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks).

## Steps to Deploy <a id="steps-to-deploy"></a>

1. [Clone and Configure the MLOps V2 Solution Accelerator](#clone-and-configure-the-mlops-v2-solution-accelerator): Create a copy of the MLOps V2 Solution Accelerator in your organization that can be used to bootstrap new Machine Learning projects.

2. [Create and Configure a New Machine Learning Project Repository](#create-and-configure-a-new-machine-learning-project-repository): Use the solution accelerator to create a new Machine Learning project according to your scenario and environments and configure it for deployment.

3. [Deploy and Execute Azure Machine Learning Pipelines](#deploy-and-execute-azure-machine-learning-pipelines): Run Azure DevOps pipelines in your new project to deploy Azure Machine Learning infrastructure, deploy and run a training pipeline, and a deployment pipeline.

## Clone and Configure the MLOps V2 Solution Accelerator <a id="clone-and-configure-the-mlops-v2-solution-accelerator"></a>

This section guides you through creating an Azure DevOps project to contain the MLOps repositories and your Machine Learning projects, importing the MLOps repositories, and configuring the project with permissions to create new pipelines in the Machine Learning projects you generate.

Below are the three repositories that you will import. They each serve a different purpose and together make up the MLOPs V2 Solution Accelerator. They will used as a "project factory" to help you bootstrap new Machine Learning projects customized for your Machine Learning scenario, preferred Azure Machine Learning interface, CI/CD platform, and infrastructure provider.

| Repository                                                                      | Role                                                                                                                                       |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [Azure/mlops-v2](https://github.com/Azure/mlops-v2)                             | The parent MLOps V2 repository. This contains project creation scripts and pipelines and MLOps V2 documentation                            |
| [Azure/mlops-project-template](https://github.com/Azure/mlops-project-template) | This repository contains templates for the supported Machine Learning scenarios and their associated Machine Learning and CI/CD pipelines. |
| [Azure/mlops-templates](https://github.com/Azure/mlops-templates)               | This repository contains Azure Machine Learning interface helpers and infrastructure deployment templates.                                 |

---

1. Navigate to [Azure DevOps](https://go.microsoft.com/fwlink/?LinkId=2014676&githubsi=true&clcid=0x409&WebUserId=2ecdcbf9a1ae497d934540f4edce2b7d) and the organization where you want to create the project. [Create a new organization](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops) for your project, if needed.

2. Create a new project named `mlops-v2`.

   ![image](images/ado-create-project.png)

3. Import the MLOps V2 repositories.

   In your new `mlops-v2` project, select the **Repos** section on the left side. The default repo, `mlops-v2`, is empty.

   Under **Import a repository**, select **Import** and enter https://github.com/Azure/mlops-v2 into the **Clone URL** field. Click **Import** at the bottom of the page.

   ![image](images/ado-import.png)

   At the top of the page, open the **Repos** drop-down and repeat the import for the following repositories:

   - [Azure/mlops-project-template](https://github.com/Azure/mlops-project-template)
   - [Azure/mlops-templates](https://github.com/Azure/mlops-templates)

   ![image](images/ado-import-mlops-templates.png)

   When done, you should see [all three MLOps V2 repositories](../structure/README.md#repositories) in your project.

   ![image](images/ado-all-mlops-repos.png)

> [!IMPORTANT]
> Azure DevOps may not import the three MLOps V2 repositories with the default branch set to `main`. If not, select **Branches** under the **Repos** section on the left and [reset the default branch](https://learn.microsoft.com/en-us/azure/devops/repos/git/change-default-branch?view=azure-devops) to `main` for each of the three imported repositories.

4. Lastly, you will grant the MLOps Solution Accelerator permission to create new pipelines in the Machine Learning projects you will create. In your `mlops-v2` project, select the **Pipelines** section on the left side. Select the three vertical dots next to **Create Pipeline** and select **Manage Security**.

   ![image](images/ado-manage-security.png)

   Select the **<project-name> Build Service** account for your project under the **Users** section. Change the permission for **Edit build pipeline** to **Allow**.

   ![image](images/ado-add-pipelines-security.png)

   You are done cloning and configuring the MLOps V2 Solution Accelerator. Next, you will create a new Machine Learning project using the accelerator templates.

## Create and Configure a New Machine Learning Project Repository <a id="create-and-configure-a-new-machine-learning-project-repository"></a>

In this section, you will create your Machine Learning project repository, set permissions to allow the solution accelerator to interact with your project, and create service principals so your Azure pipelines can interact with Azure Machine Learning.

### Creating the project repository <a id="creating-the-project-repository"></a>

1. Open the **Repos** drop-down once more and select **New repository**.

   Create a new repository for your Machine Learning project.

   In this example, the repository is named `taxi-fare-regression`. The MLOps V2 templates will be used to populate this repository based on your choices for Machine Learning scenario, Azure Machine Learning interface, and infrastructure provider.

   Leave **Add a README** selected to initialize the repository with a `main`

   ![image](images/ado-create-demo-project-repo.png)

   You should now have your `taxi-fare-regression` repository and [all three MLOps V2 repositories](../structure/README.md#repositories) in your Azure DevOps project.

   ![image](images/ado-all-repos.png)

### Setting project permissions <a id="setting-project-permissions"></a>

2. Next, set access permissions on your Machine Learning project repository. Open the **Project settings** at the bottom of the left hand navigation pane.

   Under the **Repos** section, select **Repositories**.

   - Select the `taxi-fare-regression` repository.
   - Select the **Security tab**.
   - Under **User permissions**, select the **<project-name> Build Service** account for your project under the **Users** section.
   - Change the permissions for **Contribute** and **Create branch** to **Allow**.

   ![image](images/ado-permissions-repo.png)

### Initializing the new Machine Learning project repository <a id="initializing-the-new-machine-learning-project-repository"></a>

In this step, you will run an Azure DevOps pipeline, `initialise-project`, that will prompt you for the properties of the Machine Learning project you want to build including the Machine Learning scenario (classical, computer vision, or natural language processing), the interface you will use to interface with Azure Machine Learning (CLI or SDK), and the CI/CD tool and infrastructure provider your organization uses. When run, the pipeline will populate the empty repository you created in the previous steps with the correct elements of the template repositories to build your project.

3. Open the **Pipelines** section again and select **Create Pipeline** in the center of the page.

   ![image](images/ado-create-pipeline.png)

   - Select **Azure Repos Git**
   - Select the `mlops-v2` repository
   - Select **Existing Azure Pipelines YAML file**
   - Ensure the selected branch is `main`
   - Select the `initialise-project.yml` file in the `.azuredevops/` directory in the Path drop-down
   - Click **Continue**

   On the pipeline review page, drop-down the **Run** menu and select **Save** the pipeline before running it.

   ![image](images/ado-save-pipeline.png)

   Now select **Run pipeline**.

   ![image](images/ado-run-sparepipeline.png)

   This action will run an Azure DevOps pipeline that prompts you for some parameters of your project. You can select the Machine Learning scenario, the interface the Machine Learning pipelines will use to interact with Azure Machine Learning, and the Infrastructure-as-Code provider for your organization. Below shows the [parameter selection](#project-parameters) panel followed by explanations of each option:

   ![image](images/ado-parameters-pipeline.png)

### Project Parameters <a id="project-parameters"></a>

- **Azure DevOps Project Name**: This is the name of the Azure DevOps project you are running the pipeline from. In this case, `mlops-v2`.
- **New Project Repository Name**: The name of your new project repository created in step 1. In this example, `taxi-fare-regression`.
- **MLOps Project Template's repo**: Name of the MLOps project template repository you imported previously. The default is `mlops-project-template`. Leave as default.
- **Machine Learning Project type**:

  - Choose `classical` for a regression or classification project.
  - Choose `cv` for a computer vision project.
  - Choose `nlp` for natural language projects.

- **MLOps Interface**: Select the interface to the Azure Machine Learning platform, either CLI or SDK.

  - Choose `aml-cli-v2` for the Azure Machine Learning CLI v2 interface. This is supported for all Machine Learning project types.
  - Choose `python-sdk-v1` to use the Azure Machine Learning python SDK v1 for training and deployment of your model. This is supported for Classical and CV project types.
  - Choose `python-sdk-v2` to use the Azure Machine Learning python SDK v2 for training and deployment of your model. This is supported for Classical and NLP project types.
  - Choose `rai-aml-cli-v2` to use the Responsible AI CLI tools for training and deployment of your model. This is supported only for Classical project types at this time.

- **Infrastructure Provider**: Choose the provider to use to deploy Azure infrastructure for your project.
  - Choose `Bicep` to deploy using Azure Bicep templates.
  - Choose `Terraform` to use Terraform based templates.

4. After selecting the parameters, click **Run** at the bottom of the panel.

   The first run of the pipeline will prompt you to grant access to the repositories you created.

   ![image](images/ado-pipeline-permissions.png)

   Click **View** to see the permissions waiting for review.

   ![image](images/ado-pipeline-permit.png)

   For each of the repositories, click **Permit** waiting for review.

   The pipeline run should take a few minutes. When the pipeline run is complete and successful, go back to **Repos** and look at the contents of your Machine Learning project repository, `taxi-fare-regression`. The solution accelerator has populated the project repository according to your configuration selections.

   ![image](images/ado-new-mlrepo.png)

   The structure of the project repository is as follows:

   | File                    | Purpose                                                                                                                                    |
   | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
   | `data/`                 | Sample data for the example project.                                                                                                       |
   | `data-science/`         | Contains Python code for the Data Science workflow.                                                                                        |
   | `infrastructure/`       | IaC code for deploying the Azure Machine Learning infrastructure.                                                                          |
   | `mlops/`                | Azure DevOps pipelines and Azure Machine Learning pipelines for orchestrating deployment of infrastructure and Machine Learning workflows. |
   | `config-infra-dev.yml`  | Configuration file to define dev environment resources.                                                                                    |
   | `config-infra-prod.yml` | Configuration file to define production environment resources.                                                                             |

### Create and Configure Service Principals and Connections <a id="create-and-configure-service-principals-and-connections"></a>

For Azure DevOps pipelines to create Azure Machine Learning infrastructure and deploy and execute Azure Machine Learning pipelines, it is necessary to create an Azure service principal for each Azure Machine Learning environment (`Dev` and/or `Prod`) and configure Azure DevOps service connections using those service principals. These service princiapls can be created using one of the two methods below:

<details>
<summary>Create Service Principal from Azure Cloud Shell</summary>

1. Launch the [Azure Cloud Shell](https://shell.azure.com/). If this the first time you have launched the cloud shell, you will be required to create a storage account for the cloud shell.

2. If prompted, choose **Bash** as the environment used in the Cloud Shell. You can also change environments in the drop-down on the top navigation bar

   <p align="center">
   <img src="images/cloud-shell.png" alt="Open Azure Cloud Shell"/>
   </p>

3. Copy the bash commands below to your computer and update the `projectName`, `subscriptionId`, and `environment` variables with the values for your project. If you are creating both a `Dev` and `Prod` environment you will need to run this script once for each environment, creating a service principal for each. This command will also grant the `Contributor` role to the service principal in the subscription provided. This is required for Azure DevOps to properly deploy resources to that subscription.

   ```bash
   projectName="<project-name>"
   roleName="Contributor"
   subscriptionId="<subscription-id>"
   environment="<environment>" # Dev or Prod (first letter should be capitalized)
   servicePrincipalName="Azure-ARM-${environment}-${projectName}"
   # Verify the ID of the active subscription
   echo "Using subscription ID $subscriptionId"
   echo "Creating SP for RBAC with name $servicePrincipalName, with role $roleName and in scopes /subscriptions/$subscriptionId"
   az ad sp create-for-rbac --name $servicePrincipalName --role $roleName --scopes /subscriptions/$subscriptionId
   echo "Please ensure that the information created here is properly saved for future use."
   ```

4. Copy your edited commmands into the Azure Shell and run them (<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>v</kbd>).

   <p align="center">
   <img src="./images/cloud-shell-logs.png" alt="Azure Cloud Shell Logs"/>
   </p>

5. After running these commands you will be presented with information related to the service principal. Save this information to a safe location, it will be used later in the demo to configure Azure DevOps.

   ```json
   {
     "appId": "<application-id>",
     "displayName": "Azure-ARM-{environment}-{projectName}",
     "password": "<password>",
     "tenant": "<tenant-id>"
   }
   ```

6. Repeat **step 3** if you are creating service principals for `Dev` and `Prod` environments.

7. Close the Cloud Shell once the service principals are created.

</details>

<details>
<summary>Create Service Principal from the Azure Portal</summary>

1. Navigate to [Azure App Registrations](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade/quickStartType~/null/sourceType/Microsoft_AAD_IAM).

2. Select **New registration**.

   <p align="center">
   <img src="images/service-principal-setup.png" alt="Service Principal registration"/>
   </p>

3. Go through the process of creating a Service Principle (SP) selecting **Accounts in any organizational directory (Any Azure AD directory - Multitenant)** and name it `Azure-ARM-Dev-{projectName}`. Once created, repeat and create a new SP named `Azure-ARM-Prod-{projectName}`. Please replace `{projectName}` with the name of your project so that the service principal can be uniquely identified.

4. Go to **Certificates & Secrets** and add for each SP **New client secret**, then store the value and secret seperately.

5. To assign the necessary permissions to these principals, select your respective [subscription](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade?) and go to **Access control (IAM)**. Select **+ Add** then select **Add role assigment**.

   <p align="center">
   <img src="images/iam.png" alt="Access control"/>
   </p>

6. Select `Contributor` and add members selecting **+ Select members**. Add the member `Azure-ARM-Dev-{projectName}` as create before.

   <p align="center">
   <img src="images/contributor.png" alt="Service Principal Contributor"/>
   </p>

7. Repeat the steps above if you are creating service principals for `Dev` and `Prod` environments.
</details>

### Create Service Connections <a id="create-service-connections"></a>

5. Back in Azure DevOps, select **Project Settings** at the bottom left of the project page and select **Service connections**.

   Select **Create service connection**:

   - For service, select **Azure Resource Manager** and **Next**.
   - For authentication method, select **Service principal (manual)** and **Next**.

   Complete the new service connection configuration using the information from yout tenant, subscription, and the service principal you create for production.

   ![image](images/ado-service-principal-manual.png)

   Name this service connection `Azure-ARM-Prod`. Check **Grant access permission to all pipelines**. and click **Verify and save**.

### Create Azure DevOps Environment <a id="create-azure-devops-environment"></a>

6. The pipelines in each branch of your Machine Learning project repository will depend on an Azure DevOps environment. These environments should be created before deployment.

   To create the production environment, select **Pipeline** in the left menu and **Environments**. Select **New environment**.

   ![image](images/ado-new-env.png)

   Name the new environment `prod` and click **Create**. The environment will initially be empty and indicate "Never deployed" but this status will update after the first deployment.

   The configuration of your new Machine Learning project repository is complete and you are ready to deploy your Azure Machine Learning infrastructure and deploy Machine Learning training and model deployment pipelines in the next section.

## Deploy and Execute Azure Machine Learning Pipelines <a id="deploy-and-execute-azure-machine-learning-pipelines"></a>

Now that your Machine Learning project is created, this last section will guide you through executing Azure DevOps pipelines created for you that will first deploy Azure Machine Learning infrastructure for your project then deploy a model training pipeline followed by a model deployment pipeline.

Each pipeline may have different roles associated with its deployment and management. For example, infrastructure by your IT team, model training by your Data Scientists and Machine Learning Engineers, and model deployment by Machine Learning Engineers. Likewise, depending on the environments and project branches you have created, you may deploy infrastructure for both development and production Azure Machine Learning infrastructure, with Data Scientists developing the training pipeline in the `dev` environment and branch and, when the model is acceptable, opening a pull request to the `main` branch to merge updates and run the model deployment pipeline in the `prod` environment.

Depending on the options you chose when initializing the project, you should have one infrastructure deployment pipeline, one model training pipeline, and one or two model deployment pipelines in your Machine Learning project. Model deployment options are online-endpoint for near real-time scoring and batch-endpoint for batch scoring. To see all pipelines in your project, select the **Pipelines** section from the left navigation menu, then **Pipelines**, then the **All** tab. For the example project in this guide, you should see:

![image](images/ado-view-all-pipelines.png)

### Deploy Azure Machine Learning Infrastructure <a id="deploy-azure-machine-learning-infrastructure"></a>

The first task for your Machine Learning project is to deploy Azure Machine Learning infrastructure in which to develop your Machine Learning code, define your datasets, define your Machine Learning pipelines, train models, and deploy your models in production. This pipeline deployment is typically managed by your IT group responsible for ensuring that the subscription is able to create the infrastructure needed. The infrastructure is created by executing the Azure DevOps `deploy-infra` pipeline. Before doing this, you will customize environment files that define unique Azure resource groups and Azure Machine Learning Workspaces for your project.

To do this, go back to **Repos** and your Machine Learning project repository, in this example, `taxi-fare-regression`. You will see two files in the root directory, `config-infra-prod.yml` and `config-infra-dev.yml`.

![image](images/ado-new-mlrepo.png)

> [!IMPORTANT]
> The `config-infra-prod.yml` and `config-infra-dev.yml` files use default region as `eastus` to deploy resource group and Azure Machine Learning Workspace. If you are using Free/Trial or similar learning purpose subscriptions, you must do one of the following:
>
> 1. If you decide to use `eastus` region, ensure that your subscription(s) have a quota/limit of up to 20 vCPUs for **Standard DSv2 Family vCPUs**. Visit Subscription page in Azure Portal as show below to validate this.
>    ![image](images/subscription_quota.png)
>
> 2. If not, you should change it to a region where **Standard DSv2 Family vCPUs** has a quota/limit of up to 20 vCPUs.
> 3. You may also choose to change the region and compute type being used for deployment. To do this you have to change region in `config-infra-prod.yml` and `config-infra-dev.yml`, and additionally search for `STANDARD_DS3_V2` in below listed DevOps pipeline files and change this with a compute type that would work for your setup.
>
> - `deploy-model-training-pipeline.yml`
> - `deploy-batch-endpoint-pipeline.yml`
> - `online-deployment.yml`

Making sure you are in the `main` branch, click on `config-infra-prod.yml` to open it.

Under the **Global** section, you will see properties for `namespace`, `postfix`, and `location`.

```yml
# Prod environment
variables:
  # Global
  ap_vm_image: ubuntu-latest

  namespace: mlopsv2 # Note: A namespace with many characters will cause storage account creation to fail due to storage account names having a limit of 24 characters.
  postfix: 0001
  location: eastus
  environment: prod
  enable_aml_computecluster: true
```

The two properties `namespace` and `postfix` will be used to construct a unique name for your Azure resource group, Azure Machine Learning workspace, and associated resources. The naming convention for your resource group will be `rg-<namespace>-<postfix>prod`. The name of the Azure Machine Learning workspace will be `mlw-<namespace>-<postfix>prod`. The location property will be the Azure region into which to provision these resources.

Edit `config-infra-prod.yml` to set the variables for your environment. You can clone the repository, edit the file, and push/PR to make the change or select **Edit** in the upper right of the screen to edit the file within Azure DevOps. If editing in place, change `namespace`, `postfix`, and `location` to your preferences and click **Commit**.

If the `enable_aml_computecluster` property is set to `true`, the infrastructure deployment pipeline will pre-create Azure Machine Learning compute clusters for your training. In the case of CV or NLP scenarios, it will create both CPU-based and GPU-based compute clusters so ensure that your subscription has GPU compute available.

Now you are ready to run the infrastructure deployment pipeline. Open the **Pipelines** section again and select **New pipeline** in the upper right of the page.

![image](images/ado-create-pipeline.png)

- Select **Azure Repos Git**
- Select the `taxi-fare-regression` repository
- Select **Existing Azure Pipelines YAML file**
- Ensure the selected branch is `main`
- Select the `bicep-ado-deploy-infra.yml` file in the `infrastructure/pipelines/` directory Path drop-down
- Click **Continue**

Now you will see the pipeline details.

![image](images/ado-infra-pipeline-details.png)

Click **Run** to execute the pipeline. This will take a few minutes to finish. When complete, you can view the pipeline jobs and tasks by selecting **Pipelines** then `taxi-fare-regression` under **Recently run pipelines**.

![image](images/ado-infra-pipeline-view.png)

The pipeline should create the following artifacts which you can view in your Azure subscription:

- Resource Group for your Workspace
- Azure Machine Learning Workspace and associated resources including Storage Account, Container Registry, Application Insights, and Keyvault
- Inside the workspace, an `AmlCompute` cluster will be created

Your Azure Machine Learning infrastructure is now deployed and you are ready to deploy an Machine Learning model training pipeline.

### Deploy Azure Machine Learning Model Training Pipeline <a id="deploy-azure-machine-learning-model-training-pipeline"></a>

The solution accelerator includes code and data for a sample end-to-end machine learning pipeline which trains a linear regression model to predict taxi fares in NYC. The pipeline is made up of multiple steps for data preparation, training, model evaluation, and model registration. Sample pipelines and workflows for the Computer Vision and NLP scenarios will have different steps.

In this section you will execute an Azure DevOps pipeline that will create and run an Azure Machine Learning pipeline. Together, they perform the following steps:

- Connect to the Azure Machine Learning Workspace created by the infrastructure deployment.
- Create a compute cluster for training in the workspace (refer to section below to create compute instances with or without managed identity).
- Register the training dataset in the workspace.
- Prepare data for training.
- Registers a custom python environment with the packages required for this model.
- Train a linear regression model to predict taxi fares.
- Evaluate the model on the test dataset against the performance of any previously-registered models.
- If the new model performs better, register the model as an MLflow model in the workspace for later deployment.

<details>
<summary><strong>Create Compute Instances with System-Assigned/User-Assigned/No Managed Identity</strong></summary>
<br>

In order to create a compute instance with or without managed identity, you can leverage the [`mlops-templates/templates/python-sdk-v2/create-compute-instance.yml`](https://github.com/Azure/mlops-templates/blob/main/templates/python-sdk-v2/create-compute-instance.yml) located within the `mlops-templates` repository.

If you want to create a compute instance **without a managed identity** reference, you can add the following snippet with your own parameters to the `deploy-model-training-pipeline.yml` pipeline definition:

```yaml
- template: templates/python-sdk-v2/create-compute-instance.yml@mlops-templates
  parameters:
    instance_name: compute-instance-a
    size: Standard_DS3_v2
    location: canadacentral
    description: compute instance a
```

In order to create a **system-assigned managed identity** and assign it your compute instance during creation, the above snippet can be adjusted as follows:

```yaml
- template: templates/python-sdk-v2/create-compute-instance.yml@mlops-templates
  parameters:
    instance_name: compute-instance-a
    size: Standard_DS3_v2
    location: canadacentral
    description: compute instance a
    identity_type: SystemAssigned
```

Lastly, to leverage a **user-assigned managed identity** for your compute, the following snippet can be used and adjusted as needed:

```yaml
- template: templates/python-sdk-v2/create-compute-instance.yml@mlops-templates
  parameters:
    instance_name: compute-instance-a
    size: Standard_DS3_v2
    location: canadacentral
    description: compute instance a
    identity_type: UserAssigned
    user_assigned_identity: e12c9326-0618-4036-a0a7-ad3bb396dc97
```

</details>

To deploy the model training pipeline, open the **Pipelines** section again and select **New pipeline** in the upper right of the page:

- Select **Azure Repos Git**
- Select the `taxi-fare-regression` repository
- Select **Existing Azure Pipelines YAML file**
- Ensure the selected branch is `main`
- Select the `deploy-model-training-pipeline.yml` file in the `mlops/devops-pipelines/` directory in the Path drop-down
- Click **Continue**

Next you can see the pipeline details.

![image](images/ado-training-pipeline-details.png)

Click **Run** to execute the pipeline. This will take several minutes to finish.

> [!IMPORTANT]
>
> - It is noted that, with Free/Trial and other learning purpose susbscriptions pipeline execution might take up to 90 minutes.
> - In case, your model training pipeline execution in DevOps fails after running for a long period of time, but you have validated that a model is registered in Model Registry, it confirms that your model training is Azure Machine Learning was successful.
> - This issue with longer running pipelines in Azure DevOps has been reported and is being tracked by product teams.

When completed, you can view the pipeline jobs and tasks by selecting **Pipelines** then `taxi-fare-regression` under **Recently run pipelines**. The pipeline run will be tagged `deploy-model-training-pipeline`. Drill down into the pipeline run to see the `DeployTrainingPipeline` job. Click on the job to see pipeline run details.

![image](images/ado-training-pipeline-run.png)

Now you can open your Azure Machine Learning Workspace to see the training run artifacts. Open a browser to https://ml.azure.com and login with your Azure account. You should see your Azure Machine Learning Workspace under the Workspaces tab on the left. Your workspace name will have a name built from the options you chose in the `config-infra-prod.yml` file with the format `mlw-(namespace)-(postfix)(environment)`. For example, `mlw-mlopsv2-0001prod`. Click on your workspace. You will be presented with the Azure Machine Learning Studio home page for the workspace showing your training pipeline jobs under **Recent jobs**.

![image](images/ado-aml-recent-jobs.png)

You can now explore the artifacts of the pipeline run from the workspace navigation menus on the left:

- Select **Data** to see and explore the registered `taxi-data` Data asset.
- Select **Jobs** to see and explore the `prod_taxi_fare_train_main` Experiment.
- Select **Pipelines** to see and explore the `prod_taxi_fare_run` pipeline run.
- Select **Environments then Custom environments** to see the custom `taxi-train-env` environment registered by the pipeline.
- Select **Models** to see the `taxi-model` registered by the training pipeline.
- Select **Compute** then **Compute clusters** to see the `cpu-cluster` created by the training pipeline.

This section demonstrated end-to-end model training in Azure DevOps/Azure Machine Learning pipelines, creating all necessary assets as part of the pipeline. With a trained model registered in the Azure Machine Learning workspace, the next section will guide you through deploying the model to as either a real-time endpoint or batch scoring endpoint.

### Deploy Azure Machine Learning Model Deployment Pipeline <a id="deploy-azure-machine-learning-model-deployment-pipeline"></a>

In this section you will execute an Azure DevOps pipeline that will create and run an Azure Machine Learning pipeline that deploys your trained model to an endpoint. This can be a online managed (real-time) endpoint called by an application to score new data or a batch managed endpoint to score larger blocks of new data. In this example, there are two sample model deployment pipelines provided, one for online endpoint and one for batch endpoint. You can deploy one or the other or both.

For each type of endpoint, the deployment steps are essentially the same:

- Connect to the Azure Machine Learning Workspace created by the infrastructure deployment.
- Create a new compute cluster (batch managed endpoint only).
- Create an endpoint in Azure Machine Learning for the model deployment.
- Create a deployment of the trained model on the new endpoint.
- Update traffic allocation for the endpoint.
- Test the deployment with sample data.

For batch managed endpoint deployments, a new compute cluster is created to process batch scoring requests. For online managed endpoints, the compute to process requests is managed by Azure Machine Learning.

To deploy the model deployment pipeline, open the **Pipelines** section again and select **New pipeline** in the upper right of the page

- Select **Azure Repos Git**
- Select the `taxi-fare-regression` repository
- Select **Existing Azure Pipelines YAML file**
- Ensure the selected branch is `main`
- Select `deploy-online-endpoint-pipeline.yml` or `deploy-batch-endpoint-pipeline.yml` in the `mlops/devops-pipelines/` directory in the Path drop-down depending on your choice
- Click **Continue**

Again, from the pipeline details path, click **Run** to execute the pipeline. This will take several minutes to finish. When complete, you can view the pipeline jobs and tasks by selecting **Pipelines** then `taxi-fare-regression` under **Recently run pipelines**. The pipeline run will be tagged `deploy-online-endpoint-pipeline` or `deploy-batch-endpoint-pipeline`. Drill down into the pipeline run to see the `DeployOnlineEndpoint` or `DeployBatchEndpoint` job and click on the job to see pipeline run details.

Once the deployment pipeline execution is complete, open your Azure Machine Learning workspace to see the deployed endpoints. Select **Endpoints** from the workspace navigation menu on the left. By default, you will see a list of deployed online endpoints. If you chose to deploy the sample online endpoint pipeline, you should see your `taxi-online-(namespace)(postfix)prod` endpoint.

![image](images/ado-online-endpoint.png)

Click on this endpoint instance to explore the details of the online endpoint model deployment.

If you deployed the batch managed endpoint, select **Batch endpoints** on the **Endpoints** page to see your `taxi-batch-(namespace)(postfix)prod` endpoint. Click on this endpoint instance to explore the details of the batch endpoint model deployment.

![image](images/ado-batch-endpoint.png)

For the batch endpoint, you can also select **Compute** and **Compute clusters** to see the cluster created to support batch request processing.

This section demonstrated use of a pipeline to deploy a trained model to a managed online or managed batch endpoint in Azure Machine Learning.

The single-environment deployment of this MLOps solution accelerator is complete. See the next section for information on adapting this pattern to your use case and broader MLOps practices.

## File Structure <a id="file-structure"></a>

To adapt this pattern to your use case and code, a guide to modifying files and pipelines in the Machine Learning project repository is below:

- `data/`: In the `data/` directory, you can place your data to be registered with Azure Machine Learning. A `data.yml` file describing the dataset is used by the training pipeline in `/mlops/azureml/train/` and should be modified as needed for your data. Likewise, the training pipeline should be modified to refer to your dataset.

- `data-science/`:

  - `src/`: In this directory you will modify, add, or remove code for your Data Science workflow.

  - `environment/`: In this directory, modify `train-conda.yml` to define the Python environment required by your model training.

- `infrastructure/`: This directory contains the infrastructure template and infrastructure pipeline for your Azure Machine Learning environment. In general, it should not need modification but review by your IT and verification you can create the defined resources is recommended.

- `mlops/azureml/`:

  - `train/`: This directory contains the Azure Machine Learning YAML definitions for your dataset (`data.yml`), your Python environment (`train-env.yml`), and the Azure Machine Learning training pipeline itself (`pipeline.yml`). Modify these as necessary to correctly refer to your data, environment, and Python code steps as needed.

  - `deploy/`:

    - `batch/` and `online/`: These directories contain the YAML definitions and Azure Machine Learning pipelines for deployment of your model endpoints. Modify these as needed for your endpoint and model type.

- `devops-pipelines/`: This directory contains the Azure DevOps pipeline definitions for deployment of Azure Machine Learning model training and endpoint pipelines. In general, these should need minimal changes except for updating references to data and training pipelines.

## Next Steps <a id="next-steps"></a>

This guide illustrated using Azure DevOps pipelines and Azure Machine Learning pipelines to adopt training automation, deployment, and repeatability for your Data Science workflow for a single Azure Machine Learning environment. Follow on MLOps practices may include the following:

- By default, the Azure DevOps pipelines in this accelerator do not execute unless manually triggered. This is to avoid unnecesary automatic runs during initial deployment of the accelerator. However, you may want to modify the pipelines to enhance automation. A few examples:

  - Modify the deployed [Azure Machine Learning model training pipeline to run on a schedule](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-schedule-pipeline-job?view=azureml-api-2&tabs=cliv2).
  - Modify the manual trigger on the [Azure DevOps deploy-model-training-pipeline to trigger on a schedule](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers?view=azure-devops&tabs=yaml).
  - Modify the Azure DevOps model deployment pipeline to [trigger upon successful completion of the model training pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/pipeline-triggers?view=azure-devops) instead of a manual trigger.

- Trunk-based development using development and test/staging branches in Azure DevOps. Development and Production environments are typically separated. You may create an additional `dev` branch in your project repository and deploy a development Azure Machine Learning environment from that. when code and model development in that environment is satisfactory, code and pipeline changes can be merged into the `main` branch and updates deployed to `Prod`. A `config-infra-dev.yml` example is provided in the project repository. To create this environment, repeat the steps in this guide from a `dev` branch in your Machine Learning project repository. Note that you should create a matching `dev` pipeline environment in Azure DevOps and new Azure service principal for an `Azure-ARM-Dev` service connection.

- Future work on this MLOps solution accelerator will include:

  - Integration of the [Azure Machine Learning registries](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-manage-registries?view=azureml-api-2&tabs=cli) allowing you to register models and other artifacts from your development environment then deploying them in production directly.

  - Azure Machine Learning data drift monitoring.

  - Integrated feature store.

  - Deployment of secured Azure Machine Learning environments in a Virtual Network.

For questions, please [submit an issue](https://github.com/0Upjh80d/mlops-v2/issues).
