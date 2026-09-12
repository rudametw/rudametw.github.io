---
title: "DrawnApart: telling identical GPUs apart from a web page"
categories: [paper, fingerprinting, side-channels, privacy]
place: San Diego, USA
paper: https://inria.hal.science/hal-03526240v1
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to the NDSS 2022 conference (24–28 April 2022). -->

Two computers bought on the same day, same model, same software. Can a web page tell them apart? With DrawnApart, yes — by timing how their graphics cards draw.

<!--more-->

## The idea

Every browser exposes WebGL to unprivileged JavaScript. DrawnApart pushes carefully chosen elementary arithmetic operations through the WebGL pipeline and measures how long each takes. Minute manufacturing differences between GPUs — even between two *identical* models — show up in those timings as a raw trace that characterises the device. A fast deep-learning pipeline cleans and denoises the traces so that a new one can be matched against known devices in a realistic setting.

## Why it matters

Earlier techniques could recognise a *family* of GPUs; DrawnApart is the first to discriminate between otherwise identical ones. Plugged into [FP-Stalker](/blog/posts/2018.05.21/FP-Stalker-tracking-fingerprint-evolutions.html), our fingerprint-linking algorithm from S&P 2018, it improves tracking accuracy by more than 66%. The broader lesson is uncomfortable: side-channel attacks from unprivileged JavaScript are a real threat to users' privacy, not a laboratory curiosity.

## Behind the paper

DrawnApart took two years of data collection and analysis. It was our first collaboration with Ben-Gurion University of the Negev and the University of Adelaide, and the first paper of my PhD student Naif Mehanna, co-first author with Tomer Laor. A journal version with spoofing detection appeared in [ACM Transactions on Privacy and Security](https://inria.hal.science/hal-05701262v1) in 2026, and there is an [explainer on the Am I Unique blog](https://blog.amiunique.org/an-explicative-article-on-drawnapart-a-gpu-fingerprinting-technique/).

---

**Paper.** Tomer Laor\*, Naif Mehanna\*, Antonin Durey, Vitaly Dyadyuk, Pierre Laperdrix, Clémentine Maurice, Yossi Oren, Romain Rouvoy, Walter Rudametkin, Yuval Yarom. *DrawnApart: A Device Identification Technique based on Remote GPU Fingerprinting.* NDSS 2022, San Diego, USA. \*Co-first authors. CORE A*. [Paper on HAL](https://inria.hal.science/hal-03526240v1) · [All publications](/publications/)
