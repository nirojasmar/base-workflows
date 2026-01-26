# Terraform Destroy Reusable Workflow Walkthrough

This guide explains how to use the reusable Terraform Destroy workflow provided in this repository to safely tear down infrastructure on Google Cloud Platform.

## Overview

The workflow (`terraform-destroy.yml`) performs the following steps:
1.  **Plan Destroy**: Initializes Terraform and generates a destruction plan (`terraform plan -destroy`).
2.  **Destroy**: Applies the destruction plan (`terraform apply`) to the target environment (after manual approval if configured in the GitHub Environment).

**⚠️ WARNING:** This workflow will PERMANENTLY DELETE infrastructure resources. Ensure you have proper GitHub Environment protection rules (e.g., manual reviewers) enabled to prevent accidental deletion.

## Prerequisites

### 1. Google Cloud Setup
(Same as the deployment workflow)
*   Workload Identity Federation set up.
*   Service Account with permissions to delete the resources.

### 2. GitHub Secrets
Ensure the caller repository has the following secrets:

*   `GCP_WORKLOAD_IDENTITY_PROVIDER`
*   `GCP_SERVICE_ACCOUNT`

## Usage

Create a workflow file in your repository (e.g., `.github/workflows/infra-destroy.yml`). You might want to trigger this manually (`workflow_dispatch`) rather than on push events.

### Example: Manual Trigger

```yaml
name: Destroy Infrastructure

on:
  workflow_dispatch:
    inputs:
      confirmation:
        description: 'Type "DESTROY" to confirm'
        required: true
        default: 'NO'

jobs:
  destroy-dev:
    if: inputs.confirmation == 'DESTROY'
    uses: nirojasmar/base-workflows/.github/workflows/terraform-destroy.yml@main
    with:
      environment: 'dev'
      working_directory: './terraform/dev'
      tf_version: '1.5.0'
    secrets:
      GCP_WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
      GCP_SERVICE_ACCOUNT: ${{ secrets.GCP_SERVICE_ACCOUNT }}
```

## Workflow Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `environment` | The GitHub Environment name. Critical for requiring manual approval before destruction. | **Yes** | N/A |
| `working_directory` | Directory containing the Terraform configuration. | No | `.` |
| `tf_version` | Terraform version to install. | No | `latest` |
| `tf_vars_file` | Path to a `.tfvars` file. | No | N/A |

## Workflow Secrets

| Secret | Description | Required |
| :--- | :--- | :--- |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | GCP Workload Identity Provider resource name. | **Yes** |
| `GCP_SERVICE_ACCOUNT` | GCP Service Account email address. | **Yes** |
