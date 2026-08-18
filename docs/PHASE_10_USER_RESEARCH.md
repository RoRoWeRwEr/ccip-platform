# Phase 10 Moderated Arabic/English User Research

Operationalize this protocol with the linked
[professional testing plan](08-testing/PROFESSIONAL_TESTING_PLAN.md),
[tester-access workflow](08-testing/TESTER_ACCESS_WORKFLOW.md),
[NDA checklist](08-testing/NDA_REQUIREMENTS_CHECKLIST.md),
[consent process](08-testing/CONSENT_PROCESS.md), and
[feedback template](08-testing/FEEDBACK_TEMPLATE.md). This protocol remains
authoritative for the moderator script, scoring formula, and acceptance
thresholds.

## Method and participant safety

Run moderated sessions only against protected private staging with synthetic
cards and invented spending scenarios. Do not ask for or record real income,
cards, spending, debts, bank documents, credentials, or other personal or
financial data. Obtain informed research consent, permit withdrawal, minimize
participant metadata, and keep consent/recordings outside the repository in an
owner-approved restricted system.

Recommended directional sample: at least ten participants, with at least five
primarily Arabic sessions and five primarily English sessions. Include a mix
of first-card, cashback/rewards, and travel-oriented familiarity. This is not a
statistically representative population claim.

## Roles and preparation

- Owner/product lead: approves sample, incentive/cost, consent text, storage,
  retention, and acceptance or remediation decisions.
- Moderator: conducts the script without coaching and records observations.
- Native-language reviewer: confirms script and disclaimer equivalence.
- Accessibility participant/reviewer: performs manual screen-reader and
  assistive-technology checks; automation cannot substitute for this evidence.
- Analyst: aggregates de-identified scores by language and cohort.

Before recruitment, counsel/privacy review must approve participant notice,
consent, incentive, recording, storage, access, and deletion arrangements.

## Standard moderator script — English

Read: “This is a private test of a decision-support website using fictional
cards. It is not a bank, financial advice, an application, or a promise of
eligibility or savings. Please use only the fictional scenario we provide and
do not enter real financial or personal information. We are testing the
website, not you. You may stop at any time.”

Ask before starting: “Do you consent to participate under the research notice,
and, separately, do you consent to any approved recording?” Record yes/no in
the restricted research system, never in this repository.

Give the participant a synthetic scenario, then say:

1. “Find a card suitable for the scenario and explain what source/date makes
   the information trustworthy.”
2. “Compare two cards and explain the most important tradeoff.”
3. “Use the calculator and explain annual reward, annual fee, net value, and
   one assumption or limitation.”
4. “Use recommendations and explain why the first result ranked first, its
   confidence/context, and whether it guarantees eligibility or savings.”
5. “Show how you would report a factual problem or identify stale data.”
6. “What was confusing, missing, or less trustworthy?”

Do not correct during a scored task. After scoring, probe neutrally: “What did
you expect?” and “What information led you to that conclusion?”

## نص المشرف القياسي — العربية

اقرأ: «هذا اختبار خاص لموقع يدعم اتخاذ القرار ويستخدم بطاقات افتراضية. الموقع
ليس بنكاً ولا يقدم مشورة مالية أو طلباً ائتمانياً، ولا يضمن الأهلية أو التوفير.
استخدم السيناريو الافتراضي المقدم فقط، ولا تُدخل أي معلومات شخصية أو مالية
حقيقية. نحن نختبر الموقع وليس أنت، ويمكنك التوقف في أي وقت.»

اسأل قبل البدء: «هل توافق على المشاركة وفق إشعار البحث؟ وهل توافق بشكل منفصل
على أي تسجيل معتمد؟» تُحفظ الإجابة في نظام البحث المقيّد، وليس في هذا المستودع.

قدّم سيناريو افتراضياً ثم اطلب:

1. «اعثر على بطاقة مناسبة للسيناريو واشرح ما الذي يجعل المصدر والتاريخ
   موثوقين.»
2. «قارن بين بطاقتين واشرح أهم مفاضلة بينهما.»
3. «استخدم الحاسبة واشرح المكافأة السنوية والرسوم السنوية والقيمة الصافية
   وافتراضاً أو قيداً واحداً.»
4. «استخدم التوصيات واشرح سبب تصدر النتيجة الأولى وسياق الثقة، وهل تضمن
   الأهلية أو التوفير؟»
5. «وضّح كيف ستبلغ عن معلومة خاطئة أو تعرف أن البيانات قديمة.»
6. «ما الذي كان مربكاً أو ناقصاً أو أقل موثوقية؟»

لا تصحح للمشارك أثناء المهمة المقيمة. بعد تسجيل النتيجة اسأل بحياد: «ماذا
كنت تتوقع؟» و«ما المعلومة التي أوصلتك إلى هذا الاستنتاج؟»

## Per-participant scoring sheet

Score each critical task `1` only when completed without facilitator
correction; otherwise score `0`. Notes must be de-identified.

| Participant code | Primary language | Cohort | Discovery | Comparison | Explanation | Provenance/date understood | No-guarantee understood | Material issue | Evidence reference |
|---|---|---|---:|---:|---:|---:|---:|---|---|
| Pending | Pending | Pending | 0 | 0 | 0 | 0 | 0 | Pending | Restricted reference pending |

Required calculations:

- participant critical-task pass = `Discovery × Comparison × Explanation`;
- overall task completion = passing participants / all participants;
- report the same rate separately for Arabic and English;
- report provenance/date and no-guarantee comprehension separately; and
- cross-tab material findings by language, persona, income-band scenario,
  bank, network, and reward type without collecting real participant finance
  data.

## Manual accessibility sheet

| Check | Arabic | English | Browser/assistive technology | Finding | Severity | Retest |
|---|---|---|---|---|---|---|
| Keyboard-only critical journeys | Pending | Pending | Pending | Pending | Pending | Pending |
| Screen-reader names/order/status | Pending | Pending | Pending | Pending | Pending | Pending |
| Focus visibility and recovery | Pending | Pending | Pending | Pending | Pending | Pending |
| 200% zoom and reflow | Pending | Pending | Pending | Pending | Pending | Pending |
| RTL/LTR meaning and order | Pending | Pending | Pending | Pending | Pending | Pending |
| 320px mobile journey | Pending | Pending | Pending | Pending | Pending | Pending |

## Acceptance criteria

- At least 90% of all moderated participants complete discovery, comparison,
  and explanation tasks without correction.
- Arabic and English results are separately recorded; each language must meet
  the 90% threshold or have a Blocking remediation and retest.
- No material bilingual meaning mismatch, guaranteed-outcome misunderstanding,
  unexplained cohort exclusion, or discriminatory ranking defect remains.
- Every recommendation observed exposes the required inputs, effective
  context, annual reward, annual fee, net-value method, assumptions,
  limitations, and deterministic reasons.
- Manual keyboard, screen-reader, focus, zoom, RTL/LTR, and mobile evidence has
  no unresolved Blocking finding.
- Findings have an owner, severity, resolution, and dated retest evidence.

Blank sheets, facilitator-corrected completion, and automated tests alone do
not satisfy this gate.
