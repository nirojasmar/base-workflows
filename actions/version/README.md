# Get Version Action

This composite action calculates the semantic version of the project based on git tags and commit messages. It leverages the `paulhatch/semantic-version` action to determine the next version number.

## Purpose

- **Automated Versioning**: Calculates the next semantic version (`major.minor.patch`) automatically.
- **Convention Based**: Supports version bumps via commit message patterns (e.g., matching `(MAJOR)` or `(MINOR)`).
- **Consistency**: Ensures that all build artifacts share a consistent versioning scheme.

## Outputs

| Name | Description |
| :--- | :--- |
| `version` | The calculated version string (e.g., `1.2.3`). |
| `version_tag` | The version with the `v` prefix (e.g., `v1.2.3`). |

## Configuration Details

The action is configured with the following defaults:
- **Tag Prefix**: `v`
- **Major Pattern**: `(MAJOR)` in commit messages.
- **Minor Pattern**: `(MINOR)` in commit messages.
- **Format**: `${major}.${minor}.${patch}`

## Usage

```yaml
jobs:
  versioning:
    runs-on: ubuntu-latest
    steps:
      - name: Calculate Version
        id: get_version
        uses: ./.github/actions/version

      - name: Use Version
        run: echo "The version is ${{ steps.get_version.outputs.version }}"
```

## How it works

The action scans the git history from the last tag matching the `v*` pattern. 
- If a commit contains `(MAJOR)`, the major version is incremented.
- If a commit contains `(MINOR)`, the minor version is incremented.
- Otherwise, the patch version is incremented for every change in the current path.
