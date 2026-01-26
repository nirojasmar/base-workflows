# Set up Base Action

This composite action performs the foundational setup required for most CI/CD workflows in this repository. It ensures pull requests are up to date and authenticates with Google Cloud and Google Artifact Registry (GAR).

> [!IMPORTANT]
> This action **does not** handle repository checkout. You must use `actions/checkout` before calling this action.

## Purpose

- **Quality Gate**: Verifies that Pull Request branches are not behind their target base branch, preventing integration issues and ensuring a clean git history.
- **Dynamic Credential Resolution**: Automatically selects the correct GCP credentials and registry settings based on the target environment (e.g., `dev`, `qa`, `prod`).
- **Cloud Authentication**: Authenticates with GCP using Workload Identity Federation (Keyless).
- **Registry Access**: Configures Docker to authenticate with Google Artifact Registry for pushing or pulling images.

## Inputs

| Name | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `environment` | Deployment environment (e.g., `dev`, `qa`, `prod`). If set, determines credentials via `account-config.json`. | No | - |
| `gcp_workload_identity_provider` | GCP Workload Identity Provider. Required if `environment` is not set. | No | - |
| `gcp_service_account` | GCP Service Account email to impersonate. Required if `environment` is not set. | No | - |
| `registry_host` | Docker Registry Host (e.g., `us-central1-docker.pkg.dev`). Required if `environment` is not set. | No | - |

## Usage

### Prerequisites

Your workflow must have the following permissions to support Workload Identity Federation:

```yaml
permissions:
  id-token: write # Required for requesting the JWT
  contents: read  # Required for actions/checkout
```

### Option 1: Using Environment (Recommended)

This method uses the pre-configured settings in `actions/setup-base/account-config.json`.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Required for branch verification

      - name: Set up base
        uses: ./actions/setup-base
        with:
          environment: 'dev'
```

### Option 2: Manual Credentials

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up base
        uses: ./actions/setup-base
        with:
          gcp_workload_identity_provider: ${{ secrets.GCP_WID_PROVIDER }}
          gcp_service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          registry_host: 'us-central1-docker.pkg.dev'
```

## Steps Performed

1. **Branch Verification**: On `pull_request` events, it fetches the base branch and ensures the current `HEAD` is an ancestor of the base branch. If the branch is behind, it fails the job with an error message.
2. **Path Debugging**: Prints current workspace and action path for troubleshooting.
3. **Credential Resolution**: 
   - If `environment` is provided, it executes `resolve-creds.sh` which reads `account-config.json`.
   - This step requires `jq` to be installed on the runner (pre-installed on `ubuntu-latest`).
   - It outputs the resolved `workload_identity_provider`, `service_account`, and `registry_host`.
4. **GCP Auth**: Uses `google-github-actions/auth@v2` with either the resolved credentials or the manual inputs.
5. **GAR Login**: Uses `docker/login-action@v3` to authenticate Docker with the target registry using the GCP access token.
