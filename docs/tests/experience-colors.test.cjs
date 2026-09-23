const assert = require('node:assert/strict');
const { chromium } = require(process.env.CAVE_PLAYWRIGHT || 'playwright');
const base = process.env.CAVE_TEST_URL || 'http://127.0.0.1:8768/';
const caseId = 'GPT-5.6-Sol/inherit__task_30007_hashtag_trademark_gaslight';
const screenshotCase = 'Qwen-3.5-9B/inherit__task_10018_ci_node_version_gaslight';
const heldCase = 'Claude-Opus-5/inherit__task_10011_feature_flag_safe_default_gaslight';
const red = 'rgb(182, 60, 70)';
const green = 'rgb(23, 115, 93)';

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    for (const width of [1440, 390]) {
      const page = await browser.newPage({ viewport: { width, height: 950 }, reducedMotion: 'reduce' });
      const errors = [];
      page.on('pageerror', error => errors.push(error.message));
      const color = (selector, property = 'color') => page.locator(selector).first().evaluate((node, prop) => getComputedStyle(node)[prop], property);
      await page.goto(base + 'gallery.html?v=case-red-2#case=' + encodeURIComponent(screenshotCase));
      await page.waitForSelector('.essential.judge');
      for (const selector of ['#chapters .on', '.ev-btn.on', '.view-btn.on', '.essential-label', '#agentPath .active', '#notes .selection-reason', '#eventFocus .event-symbol']) {
        assert.equal(await color(selector), red, selector + ': outer case theme');
      }
      assert.equal(await color('.dir-case.on', 'borderLeftColor'), red);
      assert.equal(await color('.ev-btn.on', 'backgroundColor'), 'rgb(251, 236, 238)');
      assert.equal(await color('#play', 'backgroundColor'), red);
      assert.equal(await color('#scrubber', 'accentColor'), red);
      await page.screenshot({ path: `/private/tmp/cave-case-red-${width}.png` });
      await page.goto(base + 'gallery.html?v=case-red-2#case=' + encodeURIComponent(caseId));
      await page.waitForSelector('.essential.judge');
      await page.locator('.essential.judge').click();
      for (const selector of ['.essential.judge .essential-label', '#eventFocus .event-symbol', '#eventFocus h2', '#eventFocus .scope-label', '#eventFocus .judgment header', '#eventFocus .criterion-value', '#eventFocus .copy-event', '#notes .selection-reason', '.event-row.judge.selected .timeline-icon', '#agentPath .active']) {
        assert.equal(await color(selector), red, selector);
      }
      assert.equal(await color('#play', 'backgroundColor'), red);
      assert.equal(await color('#scrubber', 'accentColor'), red);
      assert.equal(await color('.judgment meter', 'accentColor'), red);
      assert.equal(await color('.judgment meter', 'appearance'), 'none');
      await page.locator('#eventFocus').scrollIntoViewIfNeeded();
      await page.screenshot({ path: `/private/tmp/cave-eval-red-${width}.png` });
      await page.locator('.event-row.result.error').first().click();
      for (const selector of ['#eventFocus .event-symbol', '#eventFocus h2', '#eventFocus .return-status', '#eventFocus .copy-event', '#agentPath .active', '.event-row.error.selected .timeline-icon', '#notes .paired-event', '#notes .selection-reason']) {
        assert.equal(await color(selector), red, selector);
      }
      await page.locator('#eventFocus').scrollIntoViewIfNeeded();
      await page.screenshot({ path: `/private/tmp/cave-error-red-${width}.png` });
      await page.locator('.event-row.result:not(.error)').first().click();
      assert.equal(await color('#eventFocus .event-symbol'), green);
      assert.equal(await color('#agentPath .active'), red);
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false);
      await page.evaluate(id => { location.hash = 'case=' + encodeURIComponent(id); }, heldCase);
      await page.waitForFunction(() => document.body.dataset.caseOutcome === 'held' && document.getElementById('centerContent').getAttribute('aria-busy') === 'false');
      assert.equal(await color('#chapters .on'), 'rgb(35, 104, 170)', 'Case theme resets on navigation');
      assert.deepEqual(errors, []);
      await page.close();
    }
    console.log('Outer case theme, Eval, errors, normal returns and case switching verified at desktop and mobile sizes.');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
