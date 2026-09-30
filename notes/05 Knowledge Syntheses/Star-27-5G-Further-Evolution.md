---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 27
title: 5G Further Evolution
language: en
course_units: []
release_baseline: 18
---

# STAR-27 — 5G Further Evolution

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

5G is not one thing built in 2018. It is a release roughly every eighteen months, each adding to the last, and a phone from any year still finds its way around. Picture a city that keeps adding districts without tearing down the old ones.

![[99 Attachments/5G/Concept Figures/STAR-27-5G-Further-Evolution-Concept.png|5G's further evolution explained as a city that keeps adding districts]]

*Concept figure: 5G's further evolution explained as a city that keeps adding districts.*

Release 15, in 2018, is the old town: standalone and non-standalone NR, scalable numerology, beams, and the first RF and protocol baseline, on which everything else is built and from which nothing is removed. Release 16, in 2020, is the industrial quarter: factories, unlicensed spectrum, sidelink for cars, positioning, wireless backhaul, and TDD interference tools, the chapters 19 to 24 of the textbook. Release 17, in 2022, is the outskirts: satellites, cheaper devices, broadcast, bands above 52.6 GHz, coverage and power-saving work. Release 18, in 2024, calls itself 5G-Advanced: extended-reality traffic, network energy saving, smarter MIMO, mobile relays, repeaters, more positioning, and studies pointing at 6G.

The textbook's last chapter was written in February 2020, inside the second district, looking outward. That makes this chapter a case study in telling three kinds of claim apart. A forecast says what people intended to study at a date. A standard says a procedure was written down and frozen, which is what a Release 18 clause proves. A deployment says it runs in a real network on real phones, which needs operator evidence that no specification supplies. Most of the forecast became standard; scope, names, and timing moved; none of it proves what a given phone does. Nothing is torn down because a phone tells the network what it can do and the network uses only that. The key fact to carry is that a feature in a release means it may be used, never that it is; the capability the phone declares decides.

**The question this chapter answers.** How should the textbook's February-2020 outlook be read against the frozen Release 18 evidence, and what separates a forecast from a standard from a deployment?

!important[**The short answer.** The chapter anticipated operation beyond 52.6 GHz, backhaul enhancements, industrial and reduced-capability devices, more accurate positioning, non-terrestrial networks, public safety and sidelink, multicast and broadcast, MIMO, power saving, small data, and spectrum coexistence. Many became standardised across Releases 17 and 18, with scope, timing, and terminology changed; others remain implementation or deployment choices. The note tags every claim as forecast, standardised, or deployed, and supplies specification evidence only for the second.]

Names you will meet in this note: New Radio (NR), non-terrestrial network (NTN), reduced capability (RedCap), multicast and broadcast services (MBS), extended reality (XR), multiple-input multiple-output (MIMO), integrated access and backhaul (IAB), small-data transmission (SDT), ultra-reliable low-latency communication (URLLC), physical uplink shared channel (PUSCH).

## 2. Where you are in 5G

Section 1 described a city adding districts. The map below shows where evolution sits in 5G: the strip along the edge that keeps changing every other box.

![[99 Attachments/5G/Locator Maps/STAR-27-Where-You-Are-in-5G.png|Where Star 27 sits in the whole 5G system]]

*Locator: Where Star 27 sits in the whole 5G system.*

This chapter lights the evolution band that runs across the whole map: it is where Star 02's standardisation process produces successive releases, and where the Release 16 chapters of Stars 19 to 24 are placed in time next to what came after them. It is the bridge from the textbook, which ends in 2020, to the Release 18 specification notes of Stars 28 to 37.

The Knowledge Structure Map places the forecast topics on a release timeline and ends each at an explicit evidence state. The mechanism diagram traces the release-evolution chain.

![[99 Attachments/5G/Knowledge Maps/STAR-27-5G-Further-Evolution-Knowledge Structure Map.png|STAR-27 system-position map]]

*Knowledge map: Five themes across five releases, as a swimlane matrix.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-27-Release-Evolution-Chain.png|Star 27 mechanism and handoff diagram]]

*Mechanism: The 3GPP release pipeline as an overlapping Gantt chart.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.300 V18.10.0, clause 18, PDF page 234](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.300 V18.10.0, clause 18, PDF page 234, [official 3GPP archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [Release 18 overview](https://www.sharetechnote.com/html/5G/5G_Release18.html). The reproduced image is omitted from this distribution.

*Source excerpt: Release 18 overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_Release18.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

**Searchable structure.** Rel-15 foundation → Rel-16 verticals → Rel-17 scale-out → Rel-18 5G-Advanced → NTN, RedCap, sidelink, positioning, MBS/XR → forecast or standardised evidence state.

Release 15 provides the foundation: standalone and non-standalone access, scalable numerology, beam-oriented operation, and the first RF and protocol baseline. Release 16 expands vertical capabilities. Release 17 scales outward through non-terrestrial networks, reduced-capability devices, broadcast, wider-frequency work, and coverage. Release 18 begins 5G-Advanced and deepens rather than discards the platform. The branches are many-to-many: non-terrestrial networks begin in Release 17 and are enhanced in 18; reduced capability likewise; sidelink and positioning begin earlier and gain later enhancements; broadcast is standardised in 17 while extended-reality optimisation becomes prominent in 18. A solid evidence path means an exact clause exists; it does not assert deployment.

 The map separates the textbook's forecast status from the frozen Release 18 clauses so that hindsight does not rewrite the 2020 narrative.

## 3. Foundations and prerequisites

Section 2 placed evolution beside the system. Three foundations follow: what a release is, why a feature in the standard is not a feature in every phone, and how forecast, standard and deployment differ.

### 3.1 What a 3GPP release means

The first foundation is the word "release" itself.

!important[A release freezes a coordinated set of specifications at defined milestones. Features arrive through studies, work items, change requests, and updates across radio, protocol, architecture, security, testing, and management groups. A release label on one document does not prove end-to-end support; the specifications, capabilities, bands, conformance tests, and implementations must all align. Release descriptions such as TS 21.915, 21.916, and 21.918 summarise the work; official behaviour lives in the detailed specifications such as TS 38.213.]

> [!book] Book expansion
> Chapter 27 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 551–557, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00027-1)) is deliberately dated February 2020; its value is that it records the engineering agenda before the outcomes were settled.

### 3.2 Evolution without universal activation

A release adds features; this section explains why a phone need not implement them all.

!important[NR is designed for capability negotiation. A basic phone need not implement satellite access, high-precision positioning, sidelink relay, or extended-reality optimisation because the network runs a Release 18 core. Bands, device categories, duplexing, subscriptions, regulation, and deployment choices select practical subsets. "5G-Advanced" names the release family beginning with Release 18; it is not evidence that every Release 18 function is active anywhere.]

> [!spec] 3GPP reality check
> The mechanism that makes this true is the capability exchange of [TS 38.331 V18.10.0, clause 5.6.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip), with the capability definitions in TS 38.306; a network configures only what the UE-NR-Capability declares.

### 3.3 Forecast, standard, and deployment

Sections 3.1 and 3.2 were about the standard. This section separates what was forecast, what was standardised and what was deployed.

A forecast states intended directions at a date. Standardised evidence shows that procedures and requirements were specified. Deployment evidence needs operator documentation, certification, measurements, or market data. The three diverge: a predicted feature may be renamed; a standardised feature may be optional; a deployed feature may use part of the standardised scope.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [Release 17](https://www.sharetechnote.com/html/5G/5G_Release17.html) and [Release 18](https://www.sharetechnote.com/html/5G/5G_Release18.html) pages are the quickest way to see each release as a feature list with the work-item names that the 3GPP summaries use.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 follows the evolution themes one by one.

### 4.1 Spectrum and radio reach

The first theme is reach: higher frequencies and non-terrestrial links.

The forecast considered operation beyond 52.6 GHz. Higher-frequency work extends bandwidth but intensifies phase noise, propagation, blockage, antenna, power, and test challenges, the problems of Star 26 made worse. Later releases also improve coverage through repeaters, beam management, multiple transmission points, and RF updates; spectrum expansion creates the opportunity and coverage work makes it usable. Non-terrestrial networks change the geometry: large delay, Doppler, moving beams, feeder and service links, and intermittent visibility require timing and frequency compensation, assistance information, and adapted procedures. Standardisation does not remove the physics; it makes phones and networks interpret it consistently.

> [!spec] 3GPP reality check
> The non-terrestrial timing rule, a common and a UE-specific timing advance added to the ordinary one, is [TS 38.213 V18.8.0, clause 4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip), with the satellite ephemeris and common delay broadcast through the NTN configuration of TS 38.331.

### 4.2 Device and traffic diversity

Section 4.1 stretched the radio outward. This section turns to the devices and traffic at its ends.

Reduced-capability devices need less bandwidth, fewer antennas, lower complexity, and lower cost than full mobile broadband while keeping NR connectivity; they are neither LTE-M renamed nor a universal low-power mode, and capability signalling lets one operate inside a defined envelope. Industrial work improves latency, reliability, time-sensitive communication, and deterministic service. Small-data transmission lets a device with a brief payload skip the connection setup, including uplink from the inactive state. Power-saving work refines wake-up, paging, measurement, and scheduling, and the mechanisms target different energy components rather than one battery-life claim.

> [!spec] 3GPP reality check
> Reduced-capability procedures are TS 38.213 clause 17 with the envelope in TS 38.306; small-data transmission is TS 38.300 clause 18 and TS 38.213 clause 19.

### 4.3 Sidelink, public safety, and broadcast

Section 4.2 covered devices. This section covers links that bypass the tower and deliveries to many phones at once.

Sidelink gives peers direct communication with network-scheduled or autonomous resource selection, and later work adds relay and coverage useful to public safety; authentication and service policy remain higher-layer concerns, and a relay feature alone does not make a trusted mission-critical system. Multicast and broadcast deliver common content to many phones without duplicating unicast streams, with their own scheduling, feedback, mobility, and continuity choices. Extended-reality enhancements address bursty traffic with latency, pose-update, and rendering constraints; the application name does not replace radio measurements and scheduling.

> [!spec] 3GPP reality check
> Multicast and broadcast procedures, group-addressed downlink with optional per-UE feedback, are TS 38.213 clause 18; the Release 18 sidelink and positioning enhancements are TS 21.918 clauses 9.3, 9.4, and 9.2.

### 4.4 Positioning, MIMO, IAB, and flexible infrastructure

The road ends with positioning, antennas, backhaul and repeaters, and the resources the themes compete for.

Positioning evolves through richer reference-signal opportunities, accuracy and integrity work, sidelink positioning, and bandwidth and frequency-layer enhancements. MIMO evolution coordinates more panels, transmission points, beams, and channel information while controlling feedback and power. IAB evolves from fixed multi-hop backhaul toward topology and mobile-relay cases. Network-controlled repeaters add an infrastructure point whose gain and timing must be managed so that interference is not amplified blindly. TS 38.213 clauses 17 to 20 give concrete Release 18 examples for reduced capability, broadcast, inactive-state uplink, and repeaters, and TS 21.918 supplies the broader evidence.

!note[These families compete for resources. A reduced-complexity device cannot support the widest carrier or richest feedback; a satellite terminal trades link margin and tracking against power; extended-reality scheduling trades freshness against retransmission delay; broadcast trades individual adaptation against group efficiency. Release evolution is not a monotonic addition of capability to every endpoint but an expansion of the profiles an interoperable system can negotiate.]

## 5. Worked example

Section 4.1 mentioned satellites. Section 5 computes the round trip that makes them different.

**What we are working out.** Idealized propagation round trip from Earth to a geostationary satellite altitude and back.

**Worked numerical example.** Use a vertical two-leg geometric path to establish a latency scale before adding system delays.

Assume a vertical path to altitude 35,786 km and ignore slant range, atmosphere, routing, processing, scheduling, and retransmission. Using the exact defined speed of light for the approximation:

$$
\begin{aligned}
T_{\mathrm{RT}} &= \frac{2h}{c} \\
&= \frac{2(35{,}786{,}000\ \mathrm{m})}{299{,}792{,}458\ \mathrm{m/s}} \\
&= 0.2387\ \mathrm{s} \\
&= 238.7\ \mathrm{ms}.
\end{aligned}
$$

Here $T_{\mathrm{RT}}$ is propagation round-trip time in seconds or milliseconds, $h$ is satellite altitude in metres, $c$ is speed of light in metres per second, and ms means milliseconds.

This is only an Earth–satellite–Earth geometric leg. An end-to-end path can include additional ground/satellite legs and processing, so application round-trip time may be larger. A low-Earth-orbit satellite has much less propagation delay but moves rapidly relative to the user, producing changing Doppler, delay, and visibility. The example shows why ordinary terrestrial timing assumptions cannot simply be copied into NTN; it does not represent a universal NTN latency.

**Sanity check.** A single 35,786 km leg takes about 119 ms at light speed, so two such legs giving about 239 ms is consistent.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $T_{\mathrm{RT}}$ | Idealized Earth–satellite–Earth propagation time | 238.7 | ms | Derived geometry |
| $h$ | Assumed geostationary altitude | 35,786,000 | m | Standard orbital-height approximation |
| $c$ | Speed of light in vacuum | 299,792,458 | m/s | Defined physical constant |

## 6. The 3GPP protocol: which document, and what it says

The example used physics. This section names the release descriptions and the four Release 18 clauses that show what a forecast looks like once written down.

The release descriptions say what was added; the procedure clauses say how. TS 21.915, 21.916, and 21.918 are the tables of contents of three releases. Four Release 18 clauses of TS 38.213 show what a forecast looks like once written down: reduced-capability procedures, broadcast, small data from the inactive state, and repeaters, with the non-terrestrial timing rule in clause 4.2. And one information element decides which of them a phone ever uses: the capability it declares. The figure sets each beside the value it fixes and the configuration line it becomes.

![[99 Attachments/5G/Protocol Figures/STAR-27-5G-Further-Evolution-Protocol.png|The release descriptions, four Release 18 procedure clauses, and the capability negotiation that decides which features a phone uses]]

*Protocol figure: The release descriptions, four Release 18 procedure clauses, and the capability negotiation that decides which features a phone uses.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 21.915 | V15.0.0, [21915-f00.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip) | 5.5.4 | the Release 15 radio-access foundation |
| TS 21.916 | V16.2.0, [21916-g20.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) | 5; 8.4; 14; 19.1 | URLLC, sidelink, positioning, IAB and RF expansion |
| TS 21.918 | V18.0.0, [21918-i00.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | 4–6; 9; 12; 14; 23; 27.3 | NTN, device and traffic, sidelink and positioning, MIMO and RF, mobile IAB |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.2; 17–20 | NTN timing; RedCap, MBS, inactive-state PUSCH, and repeater procedures |
| TS 38.331 / TS 38.306 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 5.6.1; capability IEs | the capability exchange that decides what is used |

!note[**When you build or run a demo.** The first line of any Release 17 or 18 demo is the phone's capability, printed in the base-station log when it connects; a feature the phone does not declare will never appear, whatever the network is configured to offer. A reduced-capability demo is a bandwidth cap and a receive-branch count. A satellite demo is a broadcast common timing advance, a scheduling offset, and an ephemeris, and the timing-advance values in the log are hundreds of times larger than in a terrestrial cell. A broadcast demo is a group identity shared by several phones. A small-data demo is a threshold on data volume below which a phone in the inactive state transmits on a standing grant without connecting. Open-source stacks implement these unevenly; the capability line tells you which parts of the city exist for the phone in front of you.]

Release 15 created the platform. Release 16 added the vertical enhancements of chapters 20 to 25. Chapter 27 forecast Release 17 from 2020. By the frozen Release 18 baseline many predicted families have detailed clauses and continued enhancements, and the delta is evidence of cumulative maturation. The textbook remains a primary source for intent; the archives are primary sources for standardised scope. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The release descriptions are long; the engineering pages give each release as a feature list.

The ShareTechnote [Release 17](https://www.sharetechnote.com/html/5G/5G_Release17.html), [Release 18](https://www.sharetechnote.com/html/5G/5G_Release18.html), [NR Light/RedCap](https://www.sharetechnote.com/html/5G/5G_NR_Light.html), and [NTN](https://www.sharetechnote.com/html/5G/5G_NTN.html) pages are feature indexes that translate release vocabulary into protocol questions and configuration fields, and the RedCap and NTN pages in particular show the capability bits and the timing values a log will contain. Official status, exact inclusion, and conditional behaviour must be checked in the fixed 3GPP versions above.

A practical reading method assigns each statement one tag: forecast, study, official clause, capability option, implementation, or deployment observation. A sentence that cannot be tagged is probably blending evidence planes.

## 8. Course alignment

With the themes and the pages in place, this section positions the chapter in the course.

Course Alignment gives Chapter 27 no direct unit because it spans the whole platform. It is best used as a closing synthesis after the mapped chapters: students revisit spectrum/RF, physical layer, procedures, and architecture, then classify each evolution theme by its underlying constraint.

A final exercise can give the 2020 forecast list and ask for a 2026 evidence table with columns for release of introduction, Rel-18 enhancement, exact clause, implementation dependence, and deployment evidence. The task teaches standards historiography rather than memorizing marketing labels.

## 9. Common confusions

The four sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

!warning[First, Chapter 27 did not describe completed Rel-17 specifications. It described likely directions as of February 2020. The faithful reading preserves future tense where appropriate and then adds a separate current evidence layer. Editing the forecast into present tense would erase valuable history.]

!warning[Second, release origin and current clause version are different metadata. A feature can originate in Rel-16, be enhanced in Rel-17/18, and still appear in a V18 specification. Calling it a “Rel-18 feature” without this distinction creates false chronology.]

!warning[Third, standardization is not prevalence. NTN, RedCap, MBS, sidelink relays, positioning, XR, and mobile IAB require compatible networks, UEs, bands, regulation, and business cases. The current archive proves that specifications exist. Commercial adoption needs a separate, time-sensitive evidence search.]

!warning[Finally, 5G-Advanced does not replace the NR foundation. It names continued evolution beginning with Rel-18. Backward compatibility, capability signaling, and optional feature sets let networks introduce enhancements gradually.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 27, pp. 551–557, 2021; outlook dated February 2020. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00027-1).
2. 3GPP TS 21.915 V15.0.0, clause 5.5.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip).
3. 3GPP TS 21.916 V16.2.0, clauses 5, 8.4, 14, and 19.1. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
4. 3GPP TS 21.918 V18.0.0, clauses 4–6, 9, 12, 14, 23, and 27.3. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
5. 3GPP TS 38.213 V18.8.0, clauses 17–20. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
6. ShareTechnote, “Release 17,” “Release 18,” “NR Light,” and “NTN,” accessed 2026-08-03. [Rel-17](https://www.sharetechnote.com/html/5G/5G_Release17.html); [Rel-18](https://www.sharetechnote.com/html/5G/5G_Release18.html); [RedCap](https://www.sharetechnote.com/html/5G/5G_NR_Light.html); [NTN](https://www.sharetechnote.com/html/5G/5G_NTN.html).
7. Course Alignment, local course crosswalk, accessed 2026-08-03.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| IAB | Integrated Access and Backhaul | NR access plus wireless multi-hop backhaul. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| MBS | Multicast and Broadcast Services | Group-oriented content delivery in NR. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MIMO | Multiple-Input Multiple-Output | Multi-antenna transmission and reception. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| NR | New Radio | 3GPP 5G radio-access technology. | Section 1; [TS 21.915](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip) |
| NTN | Non-Terrestrial Network | NR access through satellite or airborne platforms. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| PUSCH | Physical Uplink Shared Channel | Scheduled uplink data channel, including evolved small-data uses. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| RedCap | Reduced Capability | Reduced-complexity NR device profile. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| RF | Radio Frequency | Spectrum and radio-hardware requirement domain. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| UE | User Equipment | Terminal whose negotiated capabilities select features. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| URLLC | Ultra-Reliable and Low-Latency Communication | Service family for stringent delay and delivery reliability. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |
| XR | Extended Reality | Immersive application family with burst and latency constraints. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $T_{\mathrm{RT}}$ | Idealized Earth–satellite–Earth propagation time | s or ms |
| $h$ | Satellite altitude in the simplified vertical model | m or km |
| $c$ | Speed of light in vacuum | m/s |
| ms | Millisecond | $10^{-3}$ s |
| km | Kilometre | $10^3$ m |
