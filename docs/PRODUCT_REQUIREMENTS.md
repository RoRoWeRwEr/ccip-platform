# CCIP v1 Product Requirements

## Product outcome

CCIP v1 is a Saudi-focused, trustworthy, bilingual web product that enables a
guest to discover and compare credit cards, estimate annual value, and receive
an explainable recommendation. Registered users can save relevant work. Scoped
catalog administrators can maintain and publish catalog data without bypassing
the database authorization and approval model.

CCIP is an information and decision-support product, not a bank, lender,
financial adviser, open-banking aggregator, or regulator-approved service.

## Users and accessibility

- General Saudi consumers, approximately ages 25–70.
- Cashback users, travelers, loyalty enthusiasts, and users new to card
  comparison.
- Arabic and English are first-class. Arabic uses correct RTL layout; English
  uses LTR. Core functionality and meaning must be equivalent in both.
- The interface is mobile-first, keyboard accessible, screen-reader friendly,
  readable at 200% zoom, and designed for plain-language comprehension.

## Functional requirements

### Public discovery

- Guests can browse active/public Saudi banks and recommendation-eligible
  credit cards without signing in.
- Users can view card fees, benefits, rewards, eligibility, loyalty programs,
  merchants, official-source provenance, and published catalog information
  where data exists.
- Search and filters produce stable, shareable, reversible state.
- Every screen handles loading, empty, partial-data, and error states.

### Comparison and value calculation

- Users can compare multiple cards across consistent attributes.
- Monthly spending inputs are annualized and matched to applicable reward
  rules, exclusions, minimums, and caps.
- Rewards are converted to estimated SAR using fixed reference values;
  cashback uses SAR parity.
- MVP net value is annual reward value minus annual fee. Offers and benefits
  may be displayed but are excluded from monetary net value until a verified
  valuation method is implemented.
- Calculations expose assumptions and never emit NaN, Infinity, unsafe
  overflow, or corrupted negative monetary values.

### Recommendations

- Required inputs: spending profile and one goal—Cashback, Miles, or General
  Value. Current cards and bank/fee preferences are optional.
- Only active, public, recommendation-eligible, available cards are ranked.
- Results use deterministic net-value ranking with documented tie-breakers:
  reward value, lower annual fee, recommendation score, then card name.
- Each result includes annual reward value, annual fee, net value, score,
  confidence, top categories, reasons, and assumptions.
- Identical data and inputs produce identical results; no randomness is used.
- Target complete recommendation response is under two seconds under the v1
  catalog scale.

### Authentication and user features

- Guest functionality remains useful without authentication.
- Signup, login, logout, recovery, callbacks, and session refresh use Supabase
  Auth securely.
- Authenticated users can manage only their own profile, saved cards, saved
  comparisons, and recommendation history as permitted by existing RLS.
- Authentication failures do not leak whether unrelated users or records exist.

### Catalog administration

- Administration is unavailable to ordinary users.
- BANK administrators operate only on resources owned by or directly associated
  with their assigned bank. GLOBAL/platform administrators operate across all
  banks and shared catalog resources.
- GLOBAL assignment creation and all scope lifecycle operations remain limited
  to platform administrators.
- Provenance and merchant changes preserve auditability.
- Draft, review, final approval, scheduling, publication, suspension,
  unpublication, rollback, and history use the controlled migration `0048`
  functions and migration `0049` scope checks.
- The application never grants unrestricted browser access to service-role
  credentials or blanket direct writes to core catalog tables.

## Data and content requirements

- Catalog facts originate only from official bank, card, loyalty-program, or
  promotional sources.
- Publication state controls what is presented as current authoritative data.
- Monetary amounts are SAR unless explicitly labeled otherwise.
- Dates, numbers, currency, and language are localized without changing stored
  meaning.
- Missing data is shown as unknown/not provided; it is never invented.

## Non-functional requirements

- Type-safe application boundaries and validated environment configuration.
- Least privilege, RLS enforcement, secure session cookies, safe redirects,
  security headers, structured logs, request correlation, and non-sensitive
  error responses.
- Responsive behavior from 320px mobile widths through desktop.
- Automated unit, integration, E2E, accessibility, and database regression
  coverage proportionate to risk.
- Production builds are reproducible from the lockfile and pass CI.
- Critical public pages are SEO-indexable; authenticated/admin pages are not.

## Explicit v1 exclusions

- Open banking, bank-account aggregation, transaction ingestion/history,
  personal finance or budget tracking, automated lending decisions, payment
  initiation, native mobile applications, dynamic/AI reward valuation,
  portfolio optimization, and premium billing.
- Claims of SAMA, PDPL, or other regulatory approval.
- Unverified scraping or non-official catalog sources.

## Product acceptance journeys

1. A guest switches Arabic/English, chooses a persona, finds a Saudi card,
   inspects its details, and compares it with another card on mobile.
2. A guest enters spending and receives finite, explainable annual values and a
   deterministic recommendation.
3. A user signs in, saves cards/comparisons, and sees only their own history.
4. A BANK administrator changes only their bank's governed catalog resources;
   another bank and GLOBAL resources are denied.
5. Authorized reviewers complete the two-person publication workflow and the
   resulting history/audit records are visible to authorized administrators.
