#!/bin/bash

# Simple GitHub Project Creation Script
# Creates just the project without all the issues (for manual issue creation)

set -e

REPO_OWNER="himesh13"
REPO_NAME="aarvee-crm-atomic"
PROJECT_TITLE="Aarvee CRM Feature Roadmap"

echo "Creating GitHub Project: $PROJECT_TITLE"

# Check if gh CLI is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "Please run: gh auth login"
    exit 1
fi

# Create the project
PROJECT_URL=$(gh project create \
    --owner "$REPO_OWNER" \
    --title "$PROJECT_TITLE" \
    --format json 2>&1)

if [[ $PROJECT_URL == *"number"* ]]; then
    PROJECT_NUMBER=$(echo "$PROJECT_URL" | jq -r '.number')
    echo "✅ Project created successfully!"
    echo ""
    echo "Project Number: $PROJECT_NUMBER"
    echo "View at: https://github.com/users/$REPO_OWNER/projects/$PROJECT_NUMBER"
    echo ""
    echo "Next steps:"
    echo "1. Customize the project views (Board, Table, etc.)"
    echo "2. Run ./scripts/create-github-project.sh to create all issues"
    echo "   OR create issues manually from FEATURE_TASKS.md"
else
    echo "❌ Failed to create project"
    echo "$PROJECT_URL"
    exit 1
fi
