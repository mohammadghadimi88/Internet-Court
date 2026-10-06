# Internet Court — Private Alpha

A social judgment game: two sides, one verdict, a judge reputation.

## What works now
- Responsive case feed and courtroom
- Three-way voting: Guilty / Innocent / Both
- Local demo mode when Supabase is not configured
- Supabase Alpha mode with email magic-link authentication
- Server-side `cast_vote()` RPC for one-vote-per-user enforcement
- Case creation for authenticated users
- Case reporting flow
- Shareable case URLs with Web Share / clipboard fallback
- PWA shell and offline cache

## Enable real backend
1. Create a Supabase project.
2. Run `supabase/001_initial_schema.sql` in the SQL editor.
3. Open `src/config.js`.
4. Set `supabaseUrl` and the public `supabaseAnonKey`.
5. Keep the service-role key out of the browser.
6. Leave `demoMode: false`.
7. Deploy the folder to GitHub Pages or another static host.

The app automatically falls back to local demo data if the two Supabase values are empty.

## Product principle
AI is infrastructure, not the product. The product is the network of cases, votes, reputation and social return loops.

## Before public launch
Add server-side reputation calculations, moderator roles, abuse/rate limits, stronger content moderation, privacy/terms pages, backups, analytics with a privacy decision, and proper social preview cards.

## Deploy on GitHub Pages

The repository includes `.github/workflows/deploy-pages.yml`. After pushing to `main` or `master`, enable GitHub Pages with **GitHub Actions** as the source. The workflow publishes the repository root automatically.

For Live Alpha, configure the Supabase project first, then set the public URL and anon key in `src/config.js` before pushing. Also add the final GitHub Pages URL to Supabase Authentication → URL Configuration → Redirect URLs.

## Supabase checklist

- Run `supabase/001_initial_schema.sql` once in the SQL Editor.
- Enable Email authentication / Magic Link.
- Add the GitHub Pages URL to allowed redirect URLs.
- Use only the browser-safe `anon` key in `src/config.js`.
- Never commit a service-role key.
- Test: sign in → create case → vote → refresh → verify vote remains → report case.

## Launch

See `docs/LAUNCH_CHECKLIST.md` for the exact Supabase, GitHub Pages, and alpha-test sequence.
See `docs/ABUSE_MODEL.md` for moderation and anti-abuse priorities.

## Latest Alpha hardening
- Server-side vote/case/report rate limits.
- Controlled RPCs for voting, case creation, and reports.
- Moderator table and moderation audit log.
- Protected `#/admin` moderation queue.
- Moderator-only case close/remove actions.
- Direct browser updates to case status and reputation fields restricted.

See `docs/MODERATION_RUNBOOK.md` for first-moderator setup and the alpha abuse model.
