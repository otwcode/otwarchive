# Playwright text snapshot checks

These tests capture [aria snapshots](https://playwright.dev/docs/aria-snapshots)
(the page's accessibility tree: roles plus visible text, stored as YAML) of
selected pages and fail with a readable text diff when the rendered text
changes. A green check means the visible text of the covered pages is
unchanged; a red one shows exactly what changed. This is useful for any
refactor that should not change what the user sees, i18n extractions being
the first use case: with the text verified, review can focus on key names
and interpolation.

## Running locally

The tests run against a test server seeded with `db:otwseed`, the same data
CI uses. Snapshots taken against a development database would only match
your machine. Start the server and run the tests:

```sh
docker compose run --rm -p 3001:3000 test bash -c \
  "bundle exec rake db:otwseed && \
   bundle exec rails runner 'script/playwright_prepare.rb' && \
   bundle exec rails server -p 3000 -b 0.0.0.0"
```

```sh
npm install
npx playwright install chromium
PLAYWRIGHT_BASE_URL=http://localhost:3001 PLAYWRIGHT_PASSWORD=testuser \
  npm run test:playwright
```

## When a test fails

- If the text change is unintentional, you found a regression.
- If it is intentional, regenerate the baselines and commit the updated
  `.aria.yml` files, so the diff documents the change in the pull request.

With the seeded test server from the section above running:

```sh
PLAYWRIGHT_BASE_URL=http://localhost:3001 PLAYWRIGHT_PASSWORD=testuser \
  npm run test:playwright:update
```

Review regenerated baselines before committing: auto-generated regexes for
dynamic content (dates, counts) can be too literal and may need widening.
