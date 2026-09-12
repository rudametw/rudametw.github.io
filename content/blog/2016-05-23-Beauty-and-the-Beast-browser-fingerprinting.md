---
title: "Beauty and the Beast: how modern browsers give themselves away"
categories: [paper, fingerprinting, privacy, amiunique]
place: San Jose, USA
paper: https://inria.hal.science/hal-01285470v2
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to the S&P 2016 conference (23–25 May 2016). -->

Two years of fingerprints collected on [Am I Unique](https://amiunique.org), one question: how unique is *your* browser? The answer became our IEEE S&P 2016 paper — and, two years later, the [CNIL–Inria Privacy Protection Award](https://www.cnil.fr/fr/la-cnil-et-inria-decernent-le-prix-protection-de-la-vie-privee-2018).

<!--more-->

## Where the data comes from

We launched Am I Unique in 2014 to let people test their own browser and, with their consent, keep the fingerprint for research. The site has about three thousand visitors a day, and some four thousand people run our browser extensions, which send us their fingerprint several times a day. Over the years that adds up to millions of fingerprints — the dataset behind most of our privacy work, and the material we use to explain fingerprinting to a wider audience.

## What we found

- **Fingerprinting works, and HTML5 made it worse.** New features such as Canvas add measurable entropy and confirm the identification risk that earlier studies had raised.
- **Mobile devices are fingerprintable too.** That surprised us: phones are far less configurable than desktops. But the fragmentation and over-specialisation of the mobile ecosystem leave small differences that add up to unique devices.
- **What would help.** Using our dataset we simulated scenarios and trade-offs — from the then-imminent disappearance of the Flash plugin to the drastic option of blocking all JavaScript — to see which changes actually reduce uniqueness.

This paper established fingerprinting as the centre of my work on security and privacy; nearly everything that followed builds on this dataset.

---

**Paper.** Pierre Laperdrix, Walter Rudametkin, Benoit Baudry. *Beauty and the Beast: Diverting modern web browsers to build unique browser fingerprints.* 37th IEEE Symposium on Security and Privacy (S&P 2016), San Jose, USA, pp. 878–894. CORE A*, acceptance rate 13%. [Paper on HAL](https://inria.hal.science/hal-01285470v2) · [All publications](/publications/)
