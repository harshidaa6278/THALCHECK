# ThalCheck — Thalassemia / IDA Screening Prototype

A single-file web app matching your project brief: Screen 1 collects patient
details, Screen 2 collects CBC values, Screen 3 auto-calculates discriminant
indices and gives a screening suggestion.

## Files
- `index.html` — the entire app (HTML + CSS + JS, no build step, no external
  dependencies or internet connection required). Open it directly in any
  browser, or host it on any web server.

## What it calculates

CBC inputs: **Hb, RBC, MCV, MCH, MCHC, RDW**.

Six published discriminant indices are computed automatically:

| Index | Formula | Suggests Thalassemia when |
|---|---|---|
| Mentzer | MCV / RBC | < 13 |
| Shine & Lal | MCV² × MCH / 100 | < 1530 |
| Srivastava | MCH / RBC | < 3.8 |
| Green & King | MCV² × RDW / (Hb × 100) | < 72 |
| Ehsani | MCV − (10 × RBC) | < 13 |
| Sirdah | MCV − RDW − (3 × Hb) | < 0 |

The final on-screen verdict is a **majority vote** across the six indices
(≥4/6 agreeing in one direction), with an "Indeterminate" result when they
split evenly. If Hb and MCV are both in the normal range, it reports "no
microcytic anemia pattern" instead of forcing a verdict.

**Important — these cutoffs are literature-standard values, not a diagnosis.**
Every published study on these indices agrees no single index is 100%
sensitive/specific, which is exactly why your deck's own roadmap calls for
HPLC integration and multicenter validation later. Keep the "Not a
diagnosis" disclaimer on the results screen — a college MLT project
presenting unvalidated automatic diagnoses would be a problem in review.

## Running it
Just double-click `index.html`, or for a shareable link, upload it to any
static host (GitHub Pages, Netlify, Vercel, or your college server) — it's a
single file with zero dependencies.

## Turning this into an Android app (for your roadmap's later phase)
You don't need to rewrite anything in Java/Kotlin. Once it's hosted at a
URL, wrap it with one of these (all free/low-cost, common for student
projects):
- **PWABuilder** (pwabuilder.com) — paste your hosted URL, generates a
  signed `.apk`/`.aab` directly from the web app.
- **Capacitor** (capacitorjs.com) — wraps this exact HTML/JS/CSS in a real
  Android project if you need native features (camera for the HPLC OCR
  scan mentioned in your deck, cloud sync, etc. later).
- **Bubblewrap / Trusted Web Activity** — Google's official tool for
  turning a PWA into a Play Store-ready APK.

## Extending toward your full deck
This build covers Phase 1 of your roadmap ("Prototype: Basic app with CBC
input → auto index calculation"). Natural next additions, in order:
1. HbA2/HbF input fields once HPLC values are available, to refine the
   verdict (your deck's Phase 2).
2. A results history (needs a backend or a database like Firebase —
   currently each screening is a fresh session, nothing is stored).
3. PDF/Excel export of the report.
4. OCR for scanned HPLC reports, and the AI-driven interpretation layer —
   both are meaningfully bigger builds and worth scoping as separate
   milestones.

## Sources for the formulas
Mentzer (1973), Shine & Lal (1977), Srivastava (1973), Green & King (1989),
Ehsani et al. (2009), Sirdah et al. (2008) — these are the same indices
cross-referenced in recent comparative studies, e.g. Laboratory Medicine
(Oxford Academic, 2017) and Scientific Reports (Nature, 2019), both of
which discuss all six indices used here.
