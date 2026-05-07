@echo OFF
cd %CD%/..

rem Set parameters
set ORG_ALIAS=agent-script-recipes

@echo:
echo Installing Agent Script Recipes scratch org (%ORG_ALIAS%)
@echo:

rem Install script
echo Cleaning previous scratch org...
cmd.exe /c sf org delete scratch -p -o %ORG_ALIAS% 2>NUL
@echo:

echo Creating scratch org...
cmd.exe /c sf org create scratch -f config/project-scratch-def.json -a %ORG_ALIAS% -d -y 30
call :checkForError
@echo:

echo Assigning Manage Prompt Templates permission set...
cmd.exe /c sf org assign permset -n EinsteinGPTPromptTemplateManager
call :checkForError
@echo:

echo Deploying employee agent recipes...
cmd.exe /c sf project deploy start --source-dir force-app
call :checkForError
@echo:

echo Assigning permission sets...
cmd.exe /c sf org assign permset -n Agent_Script_Recipes_Data
call :checkForError
@echo:
cmd.exe /c sf org assign permset -n Agent_Script_Recipes_App
call :checkForError
@echo:

echo Importing sample data...
cmd.exe /c sf data tree import -p data/data-plan.json
call :checkForError
@echo:

echo Creating agent user for service agent...
cmd.exe /c node bin/setup-service-agent.js
call :checkForError
@echo:

echo Assigning base permission set to agent user...
for /f "tokens=*" %%a in ('node -e "const fs=require(\"fs\"),p=require(\"path\");const f=fs.readFileSync(p.resolve(\"force-app-service/customerServiceAgent/aiAuthoringBundles/CustomerServiceAgent/CustomerServiceAgent.agent\"),\"utf8\");const m=f.match(/default_agent_user:\s*\"([^_][^\"]+)\"/);if(m)process.stdout.write(m[1])"') do set AGENT_USER=%%a
cmd.exe /c sf org assign permset -n Agent_Script_Recipes_Data --on-behalf-of %AGENT_USER%
call :checkForError
@echo:

echo Deploying service agent recipes...
cmd.exe /c sf project deploy start --source-dir force-app-service
call :checkForError
@echo:

echo Assigning service agent permission set...
cmd.exe /c sf org assign permset -n Customer_Service_Agent_Data --on-behalf-of %AGENT_USER%
call :checkForError
@echo:

rem Report install success if no error
@echo:
if ["%errorlevel%"]==["0"] (
  echo Installation completed.
  @echo:
  cmd.exe /c sf org open -p lightning/n/standard-AgentforceStudio
)

:: ======== FN ======
GOTO :EOF

rem Display error if the install has failed
:checkForError
if NOT ["%errorlevel%"]==["0"] (
    echo Installation failed.
    exit /b %errorlevel%
)