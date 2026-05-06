#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

# Set parameters
ORG_ALIAS="agent-script-recipes"

echo ""
echo "Installing Agent Script Recipes scratch org ($ORG_ALIAS)"
echo ""

# Install script
echo "Cleaning previous scratch org..."
sf org delete scratch -p -o $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sf org create scratch -f config/project-scratch-def.json -a $ORG_ALIAS -d -y 30 && \
echo "" && \

echo "Assigning Manage Prompt Templates permission set..."
sf org assign permset -n EinsteinGPTPromptTemplateManager && \
echo "" && \

echo "Deploying employee agent recipes..." && \
sf project deploy start --source-dir force-app && \
echo "" && \

echo "Assigning Agent Script permission sets..." && \
sf org assign permset -n Agent_Script_Recipes_Data && \
sf org assign permset -n Agent_Script_Recipes_App && \
echo "" && \

echo "Importing sample data..." && \
sf data import tree --plan data/data-plan.json && \
echo "" && \

echo "Creating agent user for service agent..." && \
node bin/setup-service-agent.js && \
echo "" && \

echo "Assigning permission set to agent user..." && \
agent_user=$(grep -oP 'default_agent_user:\s*"\K[^"]+' force-app-service/aiAuthoringBundles/CustomerServiceAgent/CustomerServiceAgent.agent) && \
sf org assign permset -n Agent_Script_Recipes_Data --on-behalf-of "$agent_user" && \
echo "" && \

echo "Deploying service agent recipes..." && \
sf project deploy start --source-dir force-app-service && \
echo "" && \

echo "Opening org..." && \
sf org open -p lightning/n/standard-AgentforceStudio && \
echo ""

EXIT_CODE="$?"
echo ""

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
else
    echo "Installation failed."
fi
exit $EXIT_CODE