---
title: "FP-Stalker: how long can a browser fingerprint follow you?"
categories: [paper, fingerprinting, privacy, machine-learning]
place: San Francisco, USA
paper: https://inria.hal.science/hal-01652021v1
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to the S&P 2018 conference (21–23 May 2018). -->

A fingerprint that is unique today is not necessarily useful to a tracker tomorrow: browsers update, fonts get installed, screens change. FP-Stalker asks the question that matters — can the *same* device be recognised again after its fingerprint has changed?

<!--more-->

## Unicity is not linkability

Four years of Am I Unique data let us separate two things that are often confused. **Unicity** is whether a fingerprint stands out at a given moment. **Linkability** is whether successive fingerprints of the same device can be chained over time. We built two linking algorithms — a rule-based one and one based on machine learning. The learned one was more effective; the rule-based one was faster.

## What the data says

- About **26%** of the devices in our dataset had fingerprints so distinctive that we could follow them for the *entire* duration of the study.
- Paradoxically, these look like privacy-conscious users: browsers configured against cookies and other trackers, which introduces subtleties that set them apart from everyone else.
- About **20%** were hard or impossible to track — unique at any given instant, but too close to many similar devices to be re-identified over time.
- On average we followed a device for **55 days** using nothing but its browser fingerprint.

FP-Stalker became a building block for later work, including [DrawnApart](/blog/posts/2022.04.24/DrawnApart-GPU-fingerprinting.html), where it links GPU traces to devices.

---

**Paper.** Antoine Vastel, Pierre Laperdrix, Walter Rudametkin, Romain Rouvoy. *FP-Stalker: Tracking Browser Fingerprint Evolutions.* 39th IEEE Symposium on Security and Privacy (S&P 2018), San Francisco, USA, pp. 728–741. CORE A*, acceptance rate 11%. [Paper on HAL](https://inria.hal.science/hal-01652021v1) · [All publications](/publications/)
