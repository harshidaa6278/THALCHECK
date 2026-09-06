# ThalCheck — Thalassemia / IDA Screening Prototype

A single-file web application upgraded for medical research decision-support:
- **Screen 1**: Patient details (Name, Age, Sex, Email, Place).
- **Screen 2**: CBC parameters (Hb, RBC, MCV, MCH, RDW, HCT / PCV) with strict validation against invalid values and division by zero.
- **Screen 3**: Automated calculation of 11 published discriminant indices, individual cutoff evaluation, fixed weighted voting, weighted screening score breakdown, and final classification.

---

## Files
- `index.html` — The entire screening application (HTML + CSS + JS, no external libraries, client-side offline calculation).
- `manifest.json` — Web App Manifest configured for standalone PWA installation.
- `sw.js` — Service Worker caching all assets for complete offline capability.
- `icon-192.png`, `icon-512.png`, `icon.svg` — PWA and mobile icons.
- `README.md` — Project documentation and mathematical reference.

---

## The 11 Discriminant Indices & Formulas

| # | Index | Formula | Cut-off (THAL vs. IDA) | Research Weight |
|---|---|---|---|:---:|
| 1 | **England & Fraser** | `MCV − RBC − (5 × Hb) − 3.4` | `< 0.0` $\rightarrow$ THAL, $\ge 0.0$ $\rightarrow$ IDA | **3** |
| 2 | **Green & King** | `(MCV² × RDW) / (Hb × 100)` | `< 65.0` $\rightarrow$ THAL, $\ge 65.0$ $\rightarrow$ IDA | **3** |
| 3 | **Mentzer** | `MCV / RBC` | `< 13.0` $\rightarrow$ THAL, $\ge 13.0$ $\rightarrow$ IDA | **2** |
| 4 | **Shine & Lal** | `MCV² × MCH × 0.01` | `< 1530.0` $\rightarrow$ THAL, $\ge 1530.0$ $\rightarrow$ IDA | **2** |
| 5 | **Ricerca** | `RDW / RBC` | `< 4.4` $\rightarrow$ THAL, $\ge 4.4$ $\rightarrow$ IDA | **1** |
| 6 | **Srivastava** | `MCH / RBC` | `< 3.8` $\rightarrow$ THAL, $\ge 3.8$ $\rightarrow$ IDA | **1** |
| 7 | **Ehsani** | `MCV − (10 × RBC)` | `< 15.0` $\rightarrow$ THAL, $\ge 15.0$ $\rightarrow$ IDA | **1** |
| 8 | **Sirdah** | `MCV − RBC − (3 × Hb)` | `< 27.0` $\rightarrow$ THAL, $\ge 27.0$ $\rightarrow$ IDA | **1** |
| 9 | **Bordbar** | `MCV − MCH` | `< 4.76` $\rightarrow$ THAL, $\ge 4.76$ $\rightarrow$ IDA | **2** |
| 10 | **RDW Index** | `(RDW × MCV) / RBC` | `< 220.0` $\rightarrow$ THAL, $\ge 220.0$ $\rightarrow$ IDA | **2** |
| 11 | **Logit Model** | Logistic Regression (see below) | `Probability > 0.5` $\rightarrow$ THAL, $\le 0.5$ $\rightarrow$ IDA | **1** |

### Logit Model Formula:
$$\text{Logit} = 7.4146 + (0.1154 \times \text{HCT}) - (0.1764 \times \text{MCV}) + (0.0745 \times \text{MCH}) - (0.0529 \times \text{RDW})$$
$$\text{Probability of Thalassemia} = \frac{1}{1 + e^{-\text{Logit}}}$$

The model's probability is reported separately as an individual model vote (Weight = 1).

---

## Weighted Voting System

$$\text{Total Weight} = 3 + 3 + 2 + 2 + 1 + 1 + 1 + 1 + 2 + 2 + 1 = 19$$

For each index vote:
- If vote = **THALASSAEMIA**: `THAL_WEIGHTED_SCORE += weight`
- If vote = **IDA**: `IDA_WEIGHTED_SCORE += weight`

$$\text{THAL\_PERCENT} = \left(\frac{\text{THAL\_WEIGHTED\_SCORE}}{19}\right) \times 100$$
$$\text{IDA\_PERCENT} = \left(\frac{\text{IDA\_WEIGHTED\_SCORE}}{19}\right) \times 100$$

---

## Final Screening Classification

- **$\text{THAL\_PERCENT} \ge 70.0\%$**: **Likely Thalassemia Trait**
- **$40.0\% \le \text{THAL\_PERCENT} < 70.0\%$**: **Indeterminate**  
  *Actionable Recommendation:* **"Recommend HPLC for further confirmation."**
- **$\text{THAL\_PERCENT} < 40.0\%$**: **Likely IDA**

> **Important Terminology**: The score is presented as a **"Weighted Screening Score"**, representing weighted consensus among published discriminant indices, not a clinically validated probability.

---

## PWA & Mobile Installation
- **Offline operation**: Caching via `sw.js` ensures all 11 mathematical calculations run fully client-side without an internet connection.
- **Installable PWA**: Compatible with modern desktop and mobile browsers (Chrome, Edge, Safari, Firefox).
- **Packaging ready**: Ready for packaging as an Android APK (using Bubblewrap / Capacitor / PWABuilder) or iOS app.

---

## Medical Disclaimer
*This application is intended for educational and research screening purposes only. It is not a substitute for clinical diagnosis. Results should be interpreted by a qualified healthcare professional, and confirmatory testing such as HPLC may be required.*
