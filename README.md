# Agent Script Recipes

[![CI](https://github.com/trailheadapps/agent-script-recipes/actions/workflows/ci.yml/badge.svg)](https://github.com/trailheadapps/agent-script-recipes/actions/workflows/ci.yml)

A collection of easy-to-digest [Agent Script](https://developer.salesforce.com/docs/einstein/genai/guide/agent-script.html) examples. Each recipe demonstrates how to build a specific agent behaviour in the fewest lines of script possible while following best practices. From "Hello World" interactions to sophisticated agent transitions, there's a recipe for that!

> [!IMPORTANT]
> The new Agentforce Builder is a beta service that is subject to the Beta Services Terms at [Agreements - Salesforce.com](https://www.salesforce.com/company/legal/) or your written Unified Pilot Agreement, and applicable terms in the [Product Terms Directory](https://ptd.salesforce.com/?_ga=2.247987783.1372150065.1709219475-629000709.1639001992). Use of this beta service consumes usage types per the [Agentforce and Generative AI Usage and Billing documentation](https://help.salesforce.com/s/articleView?id=ai.generative_ai_usage.htm) and is at the Customer's sole discretion.

## Table of contents

- [Prerequisites](#prerequisites)

- [Installing the app using a Developer Edition Org](#installing-the-app-using-a-developer-edition-org)

- [Optional installation instructions](#optional-installation-instructions)

## Prerequisites

Make sure to review the following prerequisites before installing the app.

### Salesforce CLI Version

> [!IMPORTANT]
> This project requires Salesforce CLI with version `2.113.6` or greater.

[Install the Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) or, check that your installed CLI version is greater than `2.113.6` by running `sf -v` in a terminal.

If you need to [update the Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_update_cli.htm), either run `sf update` or `npm install --global @salesforce/cli` depending on how you installed the CLI.

### Feature Activation

1. **Einstein:** Enable Einstein in your org. From **Setup**, search for **Einstein Setup** in Quick Find. Click on that entry and turn on the **Einstein** toggle.

1. **Agentforce:** Enable Agentforce in your org. From **Setup**, search for **Agentforce** in Quick Find. Click on **Agentforce Agents**, and turn on the **Agentforce** toggle.

### User Permissions

**Prompt Template Manager:** Assign yourself the `Prompt Template Manager` permission set. You can either do this from **Setup** or with the Salesforce CLI by running this command:

```bash
sf org assign permset -n EinsteinGPTPromptTemplateManager
```

## Installing the app using a Developer Edition Org

If you don't have an org yet, you can sign up for a free [Developer Edition Org](https://developer.salesforce.com/signup).

> [!IMPORTANT]
> Make sure to start from a brand-new environment to avoid conflicts with previous work you may have done.

1. Clone this repository:

    ```bash
    git clone https://github.com/trailheadapps/agent-script-recipes
    cd agent-script-recipes
    ```

1. Authorize your Developer Edition org and provide it with an alias (**agent-script-recipes** in the command below):

    ```bash
    sf org login web -s -a agent-script-recipes
    ```

1. Deploy the app to your org:

    ```bash
    sf project deploy start -d force-app
    ```

1. Assign the `Agent_Script_Recipes_Data` and `Agent_Script_Recipes_App` permission sets to the default user:

    ```bash
    sf org assign permset -n Agent_Script_Recipes_Data
    sf org assign permset -n Agent_Script_Recipes_App
    ```

1. Import some sample data:

    ```bash
    sf data import tree --plan data/data-plan.json
    ```

1. Open your org with the **Agentforce Studio** app displayed:

    ```bash
    sf org open -p "/lightning/n/standard-AgentforceStudio"
    ```

> [!TIP]
> **Agentforce Studio** can be reached from the App Launcher. From there, click **View All** then select the **Agentforce Studio** app.

**Post installation:** when working with the recipes, assign the **Agent Script Recipes Data** permission set to your agent user to avoid access issues.

## Optional Installation Instructions

This repository contains several files that are relevant if you want to integrate modern web development tools into your Salesforce development processes or into your continuous integration/continuous deployment processes.

### Code formatting

[Prettier](https://prettier.io/) is a code formatter used to ensure consistent formatting across your code base. To use Prettier with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) from the Visual Studio Code Marketplace. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files are provided as part of this repository to control the behavior of the Prettier formatter.

### Code linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. To use ESLint with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-lwc) from the Visual Studio Code Marketplace. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lightning Web Components development.

### Pre-commit hook

This repository also comes with a [package.json](./package.json) file that makes it easy to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

To set up the formatting and linting pre-commit hook:

1. Install [Node.js](https://nodejs.org) if you haven't already done so
1. Run `npm install` in your project's root folder to install the ESLint and Prettier modules (Note: Mac users should verify that Xcode command line tools are installed before running this command.)

Prettier and ESLint will now run automatically every time you commit changes. The commit will fail if linting errors are detected. You can also run the formatting and linting from the command line using the following commands (check out [package.json](./package.json) for the full list):

```bash
npm run lint
npm run prettier
```
