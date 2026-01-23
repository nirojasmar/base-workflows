# Set up Base Action

This composite action performs the foundational setup required for most CI/CD workflows in this repository. It handles repository checkout, ensures pull requests are up to date, and authenticates with Google Cloud and Google Artifact Registry (GAR).

## Purpose

- **Environment Preparation**: Sets up the runner by checking out the source code.
- **Quality Gate**: Verifies that Pull Request branches are not behind their target base branch, preventing integration issues.
- **Cloud Authentication**: Seamlessly authenticates with GCP using Workload Identity Federation (Keyless).
- **Registry Access**: Configures Docker to authenticate with Google Artifact Registry for pushing or pulling images.

## Inputs

| Name | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `gcp_workload_identity_provider` | The full identifier of the GCP Workload Identity Provider. | Yes | - |
| `gcp_service_account` | The GCP Service Account email to impersonate. | Yes | - |
| `registry_host` | The Docker Registry Host (e.g., `us-central1-docker.pkg.dev`). | Yes | - |

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Set up base
        uses: ./.github/actions/setup-base
        with:
          gcp_workload_identity_provider: ${{ secrets.GCP_WID_PROVIDER }}
          gcp_service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          registry_host: 'us-central1-docker.pkg.dev'
```

## Steps performed

1. **Checkout**: Checks out the repository with `fetch-depth: 0` to ensure git history is available (important for versioning).
2. **Branch Verification**: On `pull_request` events, it ensures the current HEAD is not behind the base branch.
3. **GCP Auth**: Uses `google-github-actions/auth` to authenticate.
4. **GAR Login**: Uses `docker/login-action` to authenticate Docker with the specified registry host.
