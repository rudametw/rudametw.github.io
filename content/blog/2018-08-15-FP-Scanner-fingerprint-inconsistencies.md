---
title: "FP-Scanner: when anti-fingerprinting tools make you more unique"
categories: [paper, fingerprinting, privacy, countermeasures]
place: Baltimore, USA
paper: https://inria.hal.science/hal-01820197v1
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to USENIX Security 2018 (15–17 August 2018). -->

Install an extension that lies about your browser and you should be harder to fingerprint. We tested the popular defences. Most of them do the opposite.

<!--more-->

## The problem with lying

A browser fingerprint is made of dozens of attributes that are supposed to agree with each other: the user agent, the platform, the rendering engine, the fonts, what Canvas and WebGL draw. Tools that spoof some of these attributes leave the others untouched — and the inconsistencies are themselves detectable. FP-Scanner looks for exactly those contradictions.

## What we found

- We could detect the use of every defence we studied. Detection alone adds entropy: "runs anti-fingerprinting tool X" is one more distinguishing fact.
- In the worst cases the tools were severely counterproductive — the artefacts they introduce could be exploited to identify the device *uniquely*.
- Most defences against fingerprinting, however popular, were not effective.

FP-Scanner shaped what came next. It motivated our use of fingerprints for *authentication* — if inconsistencies betray spoofing, they can also flag an impostor — and laid the groundwork for FP-Tester (automated testing of fingerprinting defences) and FP-Crawlers (bot detection).

---

**Paper.** Antoine Vastel, Pierre Laperdrix, Walter Rudametkin, Romain Rouvoy. *FP-Scanner: The Privacy Implications of Browser Fingerprint Inconsistencies.* 27th USENIX Security Symposium, Baltimore, USA, pp. 135–150. CORE A*, acceptance rate 19%. [Paper on HAL](https://inria.hal.science/hal-01820197v1) · [All publications](/publications/)
