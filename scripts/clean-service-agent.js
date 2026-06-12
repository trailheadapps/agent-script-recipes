#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PLACEHOLDER = '__AGENT_USER_PLACEHOLDER__';
const AGENT_USER_REGEX =
    /default_agent_user:\s*"(?!__AGENT_USER_PLACEHOLDER__).+"/g;
const REPLACEMENT = 'default_agent_user: "__AGENT_USER_PLACEHOLDER__"';

let agentFiles = process.argv;
agentFiles.splice(0, 2);
if (agentFiles.length === 0) {
    process.exit(0);
}

let restoredCount = 0;
for (const filePath of agentFiles) {
    let content = fs.readFileSync(filePath, 'utf8');

    if (AGENT_USER_REGEX.test(content)) {
        content = content.replace(AGENT_USER_REGEX, REPLACEMENT);
        fs.writeFileSync(filePath, content, 'utf8');
        execSync(`git add "${filePath}"`);
        console.log(`Restored placeholder in: ${filePath}`);
        restoredCount++;
    }
}

if (restoredCount > 0) {
    console.log(
        `\nRestored ${PLACEHOLDER} in ${restoredCount} file(s) before commit.`
    );
}
