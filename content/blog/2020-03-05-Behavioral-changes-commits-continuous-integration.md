---
title: "Does this commit change behaviour? Generating the test that tells you"
categories: [paper, software-testing, continuous-integration, software-engineering]
paper: https://inria.hal.science/hal-03121735
---
<!-- Hand-written 2026-09-12 from the author's summary in PROFILE/publications.rtf.
     Dated to the journal publication (Empirical Software Engineering, 5 March 2020). -->

Every commit in a continuous-integration pipeline raises the same question: did this change what the program *does*? Our Empirical Software Engineering article answers it by generating the unit test that exposes the difference.

<!--more-->

## The technique

Given a commit, we automatically search for inputs on which the program behaves differently before and after the change, and turn them into unit tests. A generated test that fails on one version and passes on the other is direct, executable evidence of a behavioural change at the granularity of a single commit.

## What we showed

Some of the generated tests were good enough to be accepted as-is as patches in real, open-source software. Beyond the immediate feedback to developers, this keeps the specification encoded in the test suite in step with the code: when behaviour changes, the developer sees it and acknowledges it rather than discovering it later. We see it as a first step toward automating a genuinely tedious part of a developer's job, with a benchmark others can build on.

---

**Paper.** Benjamin Danglot, Martin Monperrus, Walter Rudametkin, Benoit Baudry. *An approach and benchmark to detect behavioral changes of commits in continuous integration.* Empirical Software Engineering, 2020. Scimago Q1, impact factor 4.457. [Paper on HAL](https://inria.hal.science/hal-03121735) · [All publications](/publications/)
