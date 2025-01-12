#!/usr/bin/env bash

set -e

# Script variables
GITHUBORG=""
GITHUBREPO=""
LABELS=""
LABELCOUNT="0"

# Include shell helpers
source shell-helpers.sh

# Main functionality of the script
main() {
  echo_yellow "Deleting labels for the following organization and repository:"
  echo_yellow "${TAB}Organization: $GITHUBORG"
  echo_yellow "${TAB}Repository: $GITHUBREPO"

  # Populate labels
  get_labels

  # Check if there are any labels to delete
  if [ -z "${LABELS}" ]; then 
    echo_red "No labels found in repository ${GITHUBREPO}. Halting execution."
    exit 0
  fi

  echo_yellow "Found ${LABELCOUNT} labels to delete..."

  # Delete labels
  delete_labels

  echo_green "Labels deleted succesfully!"
}

# Gets and populates labels for a given repository
get_labels() {
  echo_yellow "Getting labels for repository..."

  # Git labels from github
  LABELS=$(curl -X GET --header "Authorization: token ${GITHUBTOKEN}" \
--header "Content-Type: application/json" \
"https://api.github.com/repos/${GITHUBORG}/${GITHUBREPO}/labels")

  # Store label count
  LABELCOUNT=$(echo $LABELS | jq '. | length')
}

# Deletes labels found for a specific repo
delete_labels() {
  echo_yellow "Deleting labels from repository..."

  while IFS= read -r LABELNAME; do
    echo_yellow "${TAB} Delete label: ${LABELNAME}..."

    # Remove spaces from label name
    LABELNAME=$(echo $LABELNAME | sed -e 's/ /%20/g')

    curl -X DELETE --header "Authorization: token ${GITHUBTOKEN}" \
      --header "Content-Type: application/json" \
      "https://api.github.com/repos/${GITHUBORG}/${GITHUBREPO}/labels/${LABELNAME}"
  done < <(echo $LABELS | jq -r 'keys[] as $k | (.[$k].name)')
}

# Function that outputs usage information
usage() {
  cat <<EOF

Usage: $(basename $0) <options>

Description

Options:
  -o (required)     The Github organization (or user) that the repository resides under
  -r (required)     The name of the repository
  -t                A Github personal token, used for authenticating API requests
  -h                Print this message and quit

EOF
  exit 0
}

# Function that verifies required input was passed in
verify_input() {
  echo sii $GITHUBORG
  echo sii $GITHUBREPO
  echo sii $GITHUBTOKEN
  # Verify required inputs are not empty
  [ ! -z "${GITHUBORG}" ] && [ ! -z "${GITHUBREPO}" ] && [ ! -z "${GITHUBTOKEN}" ]
}

# Parse input options
while getopts ":o:r:t:h" opt; do
  case "$opt" in
    o) GITHUBORG=$OPTARG;;
    r) GITHUBREPO=$OPTARG;;
    t) GITHUBTOKEN=$OPTARG;;
    h) usage;;
    \?) echo_red "Invalid option: -${OPTARG}." && usage;;
    :) die "Option -${OPTARG} requires an argument.";;
  esac
done

# Verify input
! verify_input && echo_red "Missing script options." && usage

# Execute main functionality
main
