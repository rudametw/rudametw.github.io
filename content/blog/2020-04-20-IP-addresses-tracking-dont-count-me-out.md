---
title: "Don't count me out: IP addresses still matter for tracking"
categories: [paper, privacy, tracking, web]
place: Taipei, Taiwan
paper: https://inria.hal.science/hal-02435622
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to The Web Conference 2020 (20–24 April 2020). -->

The IP address is the most basic identifier on the Internet, and the one everybody assumes is too volatile to track people with. We checked. It isn't.

<!--more-->

## What we looked at

We revisited IPv4 address unicity and reuse on real users, and found a startling potential for re-identification. For many people the address simply does not change very often. Others show **IP cycles**: an address at home, then a mobile one, then the office, then mobile again, then home — a pattern that is itself a signature.

## Why it matters

An identifier that stable opens the door to very simple tracking, and it complements browser fingerprinting and cookies rather than competing with them: when one signal is missing or blocked, the address fills the gap. Any honest threat model for web tracking has to keep counting the IP address in.

The paper came out of an ongoing collaboration with Martin Lopatka at Mozilla.

---

**Paper.** Vikas Mishra, Pierre Laperdrix, Antoine Vastel, Walter Rudametkin, Romain Rouvoy, Martin Lopatka. *Don't count me out: On the relevance of IP addresses in the tracking ecosystem.* The Web Conference 2020 (WWW), Taipei, Taiwan. CORE A*, acceptance rate 19%. [Paper on HAL](https://inria.hal.science/hal-02435622) · [All publications](/publications/)
