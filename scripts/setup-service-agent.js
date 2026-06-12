#!/usr/bin/env node

'use strict';

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const PROJECT_DIR = path.resolve(__dirname, '..');
const PLACEHOLDER = '__AGENT_USER_PLACEHOLDER__';

function parseArgs() {
    const args = process.argv.slice(2);
    let targetOrg = null;

    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--target-org' && args[i + 1]) {
            targetOrg = args[i + 1];
            i++;
        }
    }

    return { targetOrg };
}

function findAgentFiles(dir) {
    const results = [];

    function walk(currentDir) {
        const entries = fs.readdirSync(currentDir, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
                walk(fullPath);
            } else if (entry.name.endsWith('.agent')) {
                results.push(fullPath);
            }
        }
    }

    walk(dir);
    return results;
}

function log(msg) {
    process.stderr.write(msg + '\n');
}

function createAgentUser(targetOrg) {
    const orgFlag = targetOrg ? ` -o ${targetOrg}` : '';
    const cmd = `sf org create agent-user${orgFlag} --json`;

    log(`Running: ${cmd}`);

    try {
        const output = execSync(cmd, {
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        const result = JSON.parse(output);

        if (result.status !== 0) {
            console.error('Failed to create agent user:', result.message);
            process.exit(1);
        }

        return result.result.username;
    } catch (error) {
        console.error('Error creating agent user:', error.message);
        process.exit(1);
    }
}

function replacePlaceholders(username) {
    const agentFiles = findAgentFiles(PROJECT_DIR);
    if (agentFiles.length === 0) {
        console.error(`No .agent files found in ${PROJECT_DIR}`);
        process.exit(0);
    }

    let replacedCount = 0;

    for (const filePath of agentFiles) {
        let content = fs.readFileSync(filePath, 'utf8');

        if (content.includes(PLACEHOLDER)) {
            content = content.replace(PLACEHOLDER, username);
            fs.writeFileSync(filePath, content, 'utf8');
            log(`Updated: ${path.basename(filePath)}`);
            replacedCount++;
        }
    }

    if (replacedCount === 0) {
        log(
            `Warning: No files contained the placeholder "${PLACEHOLDER}". They may have already been replaced.`
        );
    } else {
        log(
            `\nReplaced placeholder in ${replacedCount} file(s) with agent user: ${username}`
        );
        log(
            '\nReminder: The pre-commit hook will restore the placeholder automatically.'
        );
    }
}

const { targetOrg } = parseArgs();
const username = createAgentUser(targetOrg);
replacePlaceholders(username);

process.stdout.write(username);
