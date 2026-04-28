#!/usr/bin/env node
// Validates all .agent files against the AgentScript live linter at
// https://git.soma.salesforce.com/pages/chatbots/module-agentscript/agents
//
// Usage:
//   npm run validate:agents
//   node bin/validate-agents.js [--files path1 path2 ...]

'use strict';

const { chromium } = require('playwright');
const { readFileSync, existsSync, mkdirSync } = require('fs');
const { resolve, relative } = require('path');
const { execSync } = require('child_process');

const VALIDATOR_URL =
    'https://git.soma.salesforce.com/pages/chatbots/module-agentscript/agents';
const PROFILE_DIR = resolve(process.env.HOME, '.agentscript-validator-session');
const REPO_ROOT = resolve(__dirname, '..');
const SETTLE_MS = 2500;

function findAgentFiles() {
    const out = execSync('find force-app -name "*.agent" | sort', {
        cwd: REPO_ROOT,
        encoding: 'utf8'
    });
    return out
        .trim()
        .split('\n')
        .filter(Boolean)
        .map((f) => resolve(REPO_ROOT, f));
}

const filesArgIdx = process.argv.indexOf('--files');
const agentFiles =
    filesArgIdx !== -1
        ? process.argv.slice(filesArgIdx + 1).map((f) => resolve(f))
        : findAgentFiles();

if (agentFiles.length === 0) {
    console.error('No .agent files found.');
    process.exit(1);
}

// Injected before any page script runs — captures Monaco no matter how it's bundled
const INIT_SCRIPT = `(function() {
  const capture = (v) => {
    if (!v) return;
    const api = v.editor ? v : (v.getModels ? { editor: v } : null);
    if (api) { window.__monaco__ = api; }
  };
  // Watch for window.monaco being set (common pattern)
  ['monaco', '_monaco', 'monacoEditor'].forEach(key => {
    let val;
    try {
      Object.defineProperty(window, key, {
        get() { return val; },
        set(v) { val = v; capture(v); },
        configurable: true,
      });
    } catch(e) {}
  });
  // Hook AMD require so we can pull it out after load
  const tryAMD = () => {
    if (typeof require === 'function') {
      try { require(['vs/editor/editor.main'], capture); } catch(e) {}
    }
  };
  document.addEventListener('DOMContentLoaded', tryAMD);
  setTimeout(tryAMD, 2000);
  setTimeout(tryAMD, 5000);
})();`;

async function scrapeIssuesDOM(page) {
    return page.evaluate(() => {
        // Find all buttons that contain an agentscript-lint span — those are issue rows
        const allButtons = document.querySelectorAll('button');
        const issues = [];
        allButtons.forEach((btn) => {
            const spans = btn.querySelectorAll('span');
            if (spans.length < 3) return;
            // Check if any span contains 'agentscript-lint' or lint-style rule text
            const ruleSpan = Array.from(spans).find(
                (s) =>
                    s.textContent.includes('agentscript-lint') ||
                    s.textContent.includes('-lint')
            );
            if (!ruleSpan) return;
            // spans[0] = dot, spans[1] = message text, ruleSpan = rule, last span = line:col
            const dotStyle = spans[0]
                ? spans[0].getAttribute('style') || ''
                : '';
            const message = spans[1] ? spans[1].textContent.trim() : '';
            const rule = ruleSpan.textContent.trim();
            const locSpan = spans[spans.length - 1];
            const loc =
                locSpan && /^\d+:\d+$/.test(locSpan.textContent.trim())
                    ? locSpan.textContent.trim()
                    : '';
            const severity = dotStyle.includes('warning')
                ? 'warning'
                : dotStyle.includes('error')
                  ? 'error'
                  : 'info';
            if (message) issues.push({ severity, message, rule, loc });
        });
        return issues;
    });
}

(async () => {
    console.log(`Validating ${agentFiles.length} file(s)...\n`);

    if (!existsSync(PROFILE_DIR)) mkdirSync(PROFILE_DIR, { recursive: true });

    const browser = await chromium.launchPersistentContext(PROFILE_DIR, {
        headless: false,
        viewport: { width: 1400, height: 900 }
    });

    await browser.grantPermissions(['clipboard-read', 'clipboard-write']);
    await browser.addInitScript(INIT_SCRIPT);

    const page = await browser.newPage();
    await page.goto(VALIDATOR_URL, { waitUntil: 'networkidle' });

    if (page.url().includes('/login')) {
        console.log(
            '⚠️  Not logged in — please log in in the browser window...'
        );
        await page.waitForURL((url) => !url.includes('/login'), {
            timeout: 120_000
        });
        await page.waitForLoadState('networkidle');
    }

    console.log(
        '⏸  Browser is open. Click the "New Agent" button (top right) to open the editor...'
    );
    await page.waitForSelector('.monaco-editor', { timeout: 120_000 });
    await page.waitForTimeout(1500);

    // Try AMD require as last resort after editor is visible
    await page.evaluate(
        () =>
            new Promise((resolve) => {
                if (window.__monaco__) {
                    resolve();
                    return;
                }
                if (typeof require === 'function') {
                    try {
                        require(['vs/editor/editor.main'], (m) => {
                            if (m)
                                window.__monaco__ = m.editor
                                    ? m
                                    : { editor: m };
                            resolve();
                        });
                        setTimeout(resolve, 3000);
                        return;
                    } catch (e) {}
                }
                resolve();
            })
    );

    const apiInfo = await page.evaluate(() => {
        const m = window.__monaco__;
        if (!m) return { found: false };
        const e = m.editor;
        return {
            found: true,
            modelsCount: e.getModels ? e.getModels().length : '?',
            editorsCount: e.getEditors ? e.getEditors().length : '?',
            hasMarkers: typeof e.getModelMarkers === 'function'
        };
    });
    console.log('Monaco API:', JSON.stringify(apiInfo), '\n');

    const results = [];
    let consecutiveSkips = 0;

    for (const filePath of agentFiles) {
        const relPath = relative(REPO_ROOT, filePath);
        const content = readFileSync(filePath, 'utf8');
        process.stdout.write(`  ${relPath} ... `);

        // Try Monaco model/editor API first
        const setMethod = await page.evaluate((text) => {
            const m = window.__monaco__ && window.__monaco__.editor;
            if (m) {
                const models = m.getModels ? m.getModels() : [];
                if (models.length > 0) {
                    models[0].setValue(text);
                    return 'model-api';
                }
                const editors = m.getEditors ? m.getEditors() : [];
                if (editors.length > 0) {
                    editors[0].setValue(text);
                    return 'editor-api';
                }
            }
            return 'clipboard';
        }, content);

        if (setMethod === 'clipboard') {
            await page.evaluate(
                (text) => navigator.clipboard.writeText(text),
                content
            );
            await page.locator('.monaco-editor').first().click({ force: true });
            await page.waitForTimeout(200);
            await page.keyboard.press('Meta+a');
            await page.waitForTimeout(200);
            await page.keyboard.press('Meta+v');
        }

        // Wait for issues panel to stabilize after paste.
        // Strategy: wait a fixed 1.5s for validation to run, then poll until
        // the count is unchanged for 3 consecutive reads spaced 500ms apart.
        await page.waitForTimeout(1500);
        let stableCount = -1;
        let stableRuns = 0;
        for (let i = 0; i < 24; i++) {
            await page.waitForTimeout(500);
            const count = await page.evaluate(() => {
                const buttons = document.querySelectorAll('button');
                return Array.from(buttons).filter((btn) =>
                    Array.from(btn.querySelectorAll('span')).some((s) =>
                        s.textContent.includes('-lint')
                    )
                ).length;
            });
            if (count === stableCount) {
                stableRuns++;
                if (stableRuns >= 3) break;
            } else {
                stableCount = count;
                stableRuns = 0;
            }
        }

        // Readback verification
        const actualContent = await page.evaluate(() => {
            const m = window.__monaco__ && window.__monaco__.editor;
            if (!m) return null;
            const models = m.getModels ? m.getModels() : [];
            if (models.length > 0) return models[0].getValue();
            const editors = m.getEditors ? m.getEditors() : [];
            return editors.length > 0 ? editors[0].getValue() : null;
        });

        // Verify paste landed: check that visible lines have substantial content (> 100 chars total).
        // Monaco virtualizes the viewport so we can't check specific lines, but an empty/failed paste
        // would produce very little visible text.
        const visibleCharCount = await page.evaluate(() => {
            const lines = document.querySelectorAll(
                '.monaco-editor .view-line'
            );
            return Array.from(lines).reduce(
                (n, l) => n + l.textContent.length,
                0
            );
        });

        if (visibleCharCount < 100 && actualContent === null) {
            console.log(
                `⚠️  SKIP (paste may have failed — only ${visibleCharCount} chars visible)`
            );
            results.push({ file: relPath, markers: [], skipped: true });
            consecutiveSkips++;
            if (consecutiveSkips >= 3) {
                console.log('\n❌ Aborting: 3 consecutive paste failures.');
                break;
            }
            continue;
        }
        consecutiveSkips = 0;

        // Try Monaco marker API, fall back to DOM scraping
        let markers = null;
        if (actualContent !== null && actualContent.trim() === content.trim()) {
            markers = await page.evaluate(() => {
                const m = window.__monaco__ && window.__monaco__.editor;
                if (!m || !m.getModelMarkers) return null;
                return m.getModelMarkers({}).map((mk) => ({
                    severity:
                        mk.severity === 8
                            ? 'error'
                            : mk.severity === 4
                              ? 'warning'
                              : 'info',
                    message: mk.message,
                    line: mk.startLineNumber,
                    col: mk.startColumn
                }));
            });
        }

        if (markers === null) {
            // DOM scraping fallback
            const domIssues = await scrapeIssuesDOM(page);
            const errors = domIssues.filter(
                (i) => i.severity === 'error'
            ).length;
            const warns = domIssues.filter(
                (i) => i.severity === 'warning'
            ).length;
            if (domIssues.length === 0) {
                console.log('✅ clean');
            } else {
                const parts = [];
                if (errors) parts.push(`${errors} error(s)`);
                if (warns) parts.push(`${warns} warning(s)`);
                console.log(`❌ ${parts.join(', ')}`);
                for (const issue of domIssues) {
                    const icon = issue.severity === 'error' ? '  ✗' : '  ⚠';
                    console.log(
                        `${icon} [${issue.loc}] ${issue.message}  (${issue.rule})`
                    );
                }
            }
            results.push({ file: relPath, markers: domIssues, skipped: false });
            continue;
        }

        const errors = markers.filter((m) => m.severity === 'error').length;
        const warns = markers.filter((m) => m.severity === 'warning').length;

        if (errors === 0 && warns === 0) {
            console.log('✅ clean');
        } else {
            const parts = [];
            if (errors) parts.push(`${errors} error(s)`);
            if (warns) parts.push(`${warns} warning(s)`);
            console.log(`❌ ${parts.join(', ')}`);
            for (const mk of markers) {
                const icon = mk.severity === 'error' ? '  ✗' : '  ⚠';
                console.log(`${icon} [${mk.line}:${mk.col}] ${mk.message}`);
            }
        }

        results.push({ file: relPath, markers, skipped: false });
    }

    await browser.close();

    const skipped = results.filter((r) => r.skipped);
    const validated = results.filter((r) => !r.skipped);
    const totalErrors = validated.reduce(
        (n, r) => n + r.markers.filter((m) => m.severity === 'error').length,
        0
    );
    const totalWarnings = validated.reduce(
        (n, r) =>
            n +
            r.markers.filter(
                (m) => m.severity === 'warning' || m.severity === 'info'
            ).length,
        0
    );
    const cleanFiles = validated.filter((r) => r.markers.length === 0).length;

    console.log('\n─────────────────────────────────────────');
    console.log(
        `Validated ${validated.length} file(s): ${cleanFiles} clean, ${validated.length - cleanFiles} with issues`
    );
    if (skipped.length > 0) {
        console.log(`Skipped ${skipped.length} file(s):`);
        for (const s of skipped) console.log(`  ⚠️  ${s.file}`);
    }
    if (totalErrors > 0) console.log(`Total errors:   ${totalErrors}`);
    if (totalWarnings > 0) console.log(`Total warnings: ${totalWarnings}`);
    if (skipped.length === 0 && totalErrors === 0 && totalWarnings === 0)
        console.log('All files passed validation ✅');

    process.exit(skipped.length > 0 || totalErrors > 0 ? 1 : 0);
})();
