---
id: B-188
tags: [code, workflow, gotcha, reference]
scope: any project needing real browser-interaction verification (scroll, click, drag) of a locally-running web app
hook: install puppeteer-core (not full puppeteer) pointed at the system's existing Chrome via executablePath — real scripted interaction verification with zero browser download
---

# puppeteer-core against an existing Chrome install — real interaction verification

`headless Chrome --screenshot` (the CLI flag) only captures ONE static moment — it cannot scroll,
click, or drag first. Any claim like "scroll-driven camera works" or "this button's hover state looks
right" needs actual scripted interaction, not another single-frame screenshot presented as proof.

**Fix:** don't install full `puppeteer` (bundles its own ~200MB Chromium download, slow, redundant
when a real Chrome already exists on the machine). Install `puppeteer-core` instead
(`npm install --no-save puppeteer-core` inside the target project — `--no-save` keeps package.json/
lockfile clean if this is a one-off verification):

```js
import puppeteer from 'puppeteer-core'
const browser = await puppeteer.launch({
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  headless: true,
  args: ['--enable-unsafe-swiftshader', '--hide-scrollbars'], // needed for WebGL/R3F content
  defaultViewport: { width: 1440, height: 900 },
})
const page = await browser.newPage()
page.on('pageerror', (err) => consoleErrors.push(String(err)))
await page.goto('http://localhost:PORT/', { waitUntil: 'networkidle0' })
// then real interaction: page.evaluate(() => window.scrollTo(0, X)),
// page.mouse.move/click, page.click(selector), etc. — screenshot after each step.
```

**Why `--enable-unsafe-swiftshader`:** matters for any WebGL/Three.js/R3F content — without it,
headless Chrome's `--disable-gpu` (or headless mode's default) silently returns
`canvas.getContext('webgl') === null`, and a screenshot of the resulting CSS fallback can look
deceptively correct. Confirm the real context succeeded rather than trusting a plausible-looking
screenshot.

**How to apply:** whenever a task involves proving a scroll-linked, hover-linked, or click-linked
behavior actually works (not just that the page loads), reach for this instead of a single
`--screenshot` CLI call. Cache check before reinstalling: `ls ~/.cache/puppeteer` /
`~/Library/Caches/ms-playwright` — a browser cache may already exist on the machine.
