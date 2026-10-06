# Internet Court — Supabase setup status

The live frontend uses the Supabase project configured in `src/config.js`.

## Applied database layers

1. Core tables: profiles, cases, follows.
2. RLS policies for profiles, cases, follows.
3. votes and reports tables with RLS.
4. Secure RPCs:
   - get_case_vote_counts
   - cast_vote
   - create_case
   - submit_report
   - is_moderator
   - moderator_list_reports
   - moderator_set_case_status
   - moderator_resolve_report
5. Auth trigger creates a profile automatically when a new Supabase Auth user is created.
6. Function privileges were restricted:
   - anonymous users cannot cast votes, create cases, submit reports, or access moderation RPCs.
   - authenticated users can use those protected RPCs.
   - anonymous users can only request aggregate vote counts.

## Important

The small `_internet_court_bootstrap_check` table is retained as a harmless test artifact and has no API privileges. The `user_roles` table is also locked down; moderator rows must be assigned deliberately.

Before public launch, complete:
- configure/verify Supabase Auth email provider and redirect URL;
- create the first moderator role for a real user;
- run an end-to-end authenticated test: sign in → create case → vote → report;
- enable GitHub Pages if the repository has not already enabled Pages deployment;
- verify the deployed URL on a phone.

Do not put a Supabase service-role/secret key in the frontend repository.
