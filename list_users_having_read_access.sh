#!/bin/bash
set -euo pipefail

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and Personal Access token (ensure these are exported beforehand)
USERNAME="${username:-}"
TOKEN="${token:-}"

helper() {
  expected_cmd_args=2

  if [ "$#" -ne "$expected_cmd_args" ]; then
    echo "Please execute the script with required cmd args" >&2
    echo "Usage: $0 OWNER_NAME REPO_NAME" >&2
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Install jq and retry." >&2
    exit 1
  fi

  if [ -z "$TOKEN" ]; then
    echo "Error: token is not set. Export token before running." >&2
    echo "Example: export token=\"ghp_xxx\"" >&2
    exit 1
  fi
}

# ✅ Validate arguments and dependencies BEFORE using $1/$2
helper "$@"

# User and Repository Information
REPO_OWNER="$1"
REPO_NAME="$2"

# Function to make a GET request to the GitHub API
github_api_get() {
  local endpoint="$1"
  local url="${API_URL}/${endpoint}"

  # ✅ Modern auth (recommended)
  curl -s \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$url"

  # If you prefer old-style basic auth, uncomment below and comment the curl above:
  # curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
list_users_with_read_access() {
  local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

  # "At least read" (anyone with pull):
  local collaborators
  collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

  # If you want strictly "read-only", use this instead:
  # collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true and .permissions.push == false and .permissions.admin == false) | .login')"

  if [[ -z "$collaborators" ]]; then
    echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
  else
    echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
    echo "$collaborators"
  fi
}

# Main Script
echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
