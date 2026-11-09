# Contributing to LibreUni

Thank you for helping make university-level education free. This guide covers local setup, the build, and the quality checks. Content and style rules live in [`docs/RULES.md`](docs/RULES.md).

## 1. Prerequisites

- [Node.js](https://nodejs.org/) 20 or newer
- npm (bundled with Node.js)

## 2. Install dependencies

```bash
npm ci
```

## 3. Build every workspace

```bash
npm run build:all
```

## 4. Quality checks

Install the Playwright Chromium browser once:

```bash
npm run test:install
```

Then run the full quality gate:

```bash
npm test
```

`npm test` builds the apps, runs the Playwright e2e tests, creates the UX report, and runs Lighthouse CI. See [`docs/TESTING.md`](docs/TESTING.md) for narrower commands and report locations.

## 5. Contribution flow

1. Branch from `main`.
2. Keep the diff focused on a single change.
3. Run `npm run build:all` and make sure it passes.
4. Open a pull request against `LibreUni/LibreUni`.
