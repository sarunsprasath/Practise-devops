
#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and Personal Access token (ensure these are exported beforehand)
USERNAME=${username:-}
TOKEN=${token:-}

# Before running, export your credentials (or adjust the script to use Bearer header):
#export username="your-github-username"
#export token="ghp_your_pat_or_fine_grained_token"

#./list_read_users.sh OWNER REPO


# User and Repository Information
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
  local endpoint="$1"
  local url="${API_URL}/${endpoint}"

  # Send a GET request to the GitHub API with authentication
  curl -s -u "${USERNAME}:${TOKEN}" "$url"

#Use Bearer header auth (modern style)
#Replace the curl -s -u "${USERNAME}:${TOKEN}" "$url" line with:

#curl -s \
 # -H "Authorization: Bearer ${TOKEN}" \
 # -H "Accept: application/vnd.github+json" \
 # -H "X-GitHub-Api-Version: 2022-11-28" \
 # "$url"

}

# Function to list users with read access to the repository
function list_users_with_read_access {
  local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

  # Fetch the list of collaborators on the repository
  # "At least read" (anyone with pull):
  collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

  # If you want strictly "read-only", replace the jq filter with:
  # jq -r '.[] | select(.permissions.pull == true and .permissions.push == false and .permissions.admin == false) | .login'

  # Display the list of collaborators with read access
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
