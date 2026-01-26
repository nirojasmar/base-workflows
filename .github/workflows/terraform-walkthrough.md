# Terraform GCP Reusable Workflow Walkthrough

This guide explains how to use the reusable Terraform workflow provided in this repository to automate your Infrastructure as Code (IaC) deployments on Google Cloud Platform.

## Overview

The workflow (`terraform-gcp.yml`) performs the following steps:
1.  **Plan**: initializes Terraform and generates a plan.
2.  **Scan**: Runs Checkov to scan infrastructure code for security misconfigurations.
3.  **Apply**: Applies the Terraform plan to the target environment (after manual approval if configured in the GitHub Environment).

## Prerequisites

### 1. Google Cloud Setup
You must have Workload Identity Federation set up in your GCP project to allow GitHub Actions to authenticate.

*   Create a Workload Identity Pool and Provider.
*   Create a Service Account.
*   Bind the Service Account to the Workload Identity Principal (your GitHub repo).

### 2. GitHub Secrets
Ensure the caller repository has the following secrets configured (or passed from an environment):

*   `GCP_WORKLOAD_IDENTITY_PROVIDER`: The full identifier of your Workload Identity Provider.
    *   Example: `projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider`
*   `GCP_SERVICE_ACCOUNT`: The email of the Service Account to impersonate.
    *   Example: `my-service-account@my-project.iam.gserviceaccount.com`

## Usage

Create a workflow file in your repository (e.g., `.github/workflows/infra-deploy.yml`) and use the `workflow_call` trigger to reference the reusable workflow.

### Example: Basic Usage

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [ main ]

jobs:
  deploy-dev:
    uses: nirojasmar/base-workflows/.github/workflows/terraform-gcp.yml@main
    with:
      environment: 'dev'
      working_directory: './terraform/dev'
      tf_version: '1.5.0'
    secrets:
      GCP_WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
      GCP_SERVICE_ACCOUNT: ${{ secrets.GCP_SERVICE_ACCOUNT }}
```

### Example: With tfvars File

```yaml
name: Deploy Production

on:
  release:
    types: [published]

jobs:
  deploy-prod:
    uses: nirojasmar/base-workflows/.github/workflows/terraform-gcp.yml@main
    with:
      environment: 'production'
      working_directory: './terraform'
      tf_vars_file: 'prod.tfvars'
    secrets:
      GCP_WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.PROD_GCP_WORKLOAD_IDENTITY_PROVIDER }}
      GCP_SERVICE_ACCOUNT: ${{ secrets.PROD_GCP_SERVICE_ACCOUNT }}
```

## Workflow Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `environment` | The GitHub Environment name (e.g., dev, prod). Used for deployment protection rules. | **Yes** | N/A |
| `working_directory` | Directory containing the Terraform configuration (main.tf). | No | `.` |
| `tf_version` | Terraform version to install. | No | `latest` |
| `tf_vars_file` | Path to a `.tfvars` file (relative to working_directory). | No | N/A |

## Workflow Secrets

| Secret | Description | Required |
| :--- | :--- | :--- |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | GCP Workload Identity Provider resource name. | **Yes** |
| `GCP_SERVICE_ACCOUNT` | GCP Service Account email address. | **Yes** |

## Security Scanning

The workflow automatically runs **Checkov** to scan your Terraform files. If critical misconfigurations are found, the `scan` job may fail (depending on Checkov configuration), preventing the `apply` step.
