#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const SERVICE_AGENT_DIR = path.resolve(__dirname, '..', 'force-app-service');
const PLACEHOLDER = '__AGENT_USER_PLACEHOLDER__';
const AGENT_USER_REGEX =
    /default_agent_user:\s*"(?!__AGENT_USER_PLACEHOLDER__).+"/g;
const REPLACEMENT = 'default_agent_user: "__AGENT_USER_PLACEHOLDER__"';

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

if (!fs.existsSync(SERVICE_AGENT_DIR)) {
    process.exit(0);
}

const agentFiles = findAgentFiles(SERVICE_AGENT_DIR);
let restoredCount = 0;

for (const filePath of agentFiles) {
    let content = fs.readFileSync(filePath, 'utf8');

    if (AGENT_USER_REGEX.test(content)) {
        content = content.replace(AGENT_USER_REGEX, REPLACEMENT);
        fs.writeFileSync(filePath, content, 'utf8');
        execSync(`git add "${filePath}"`);
        const relativePath = path.relative(SERVICE_AGENT_DIR, filePath);
        console.log(`Restored placeholder in: ${relativePath}`);
        restoredCount++;
    }
}

if (restoredCount > 0) {
    console.log(
        `\nRestored ${PLACEHOLDER} in ${restoredCount} file(s) before commit.`
    );
}
