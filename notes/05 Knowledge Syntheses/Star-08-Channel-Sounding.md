---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 8
title: Channel Sounding
language: en
course_units:
- U06
- U07
- U08
release_baseline: 18
---

# STAR-08 — Channel Sounding

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

An optician cannot look at the world through your eyes. So she shows you something she knows exactly — a chart of letters in known sizes — and asks what you can read. From your answer she infers the state of your eye and chooses a lens. A base station is in the optician's position. It cannot see the radio channel between itself and a phone; it can only transmit something both sides know in advance and ask the phone what arrived. The chart is a reference signal. The answer is a channel-state report. The lens is the modulation, the number of streams, and the precoder that the scheduler chooses next.

![[99 Attachments/5G/Concept Figures/STAR-08-Channel-Sounding-Concept.png|Channel sounding explained as an eye test]]

*Concept figure: Channel sounding explained as an eye test.*

The downlink chart is the CSI-RS, sent on up to thirty-two antenna ports so that the phone can report on each direction separately. The report is a small set of indices — a channel-quality indicator that says how much data the channel can bear, a precoding-matrix indicator that says which spatial pattern would work best, and a rank indicator that says how many streams the channel can keep apart. On the uplink the roles reverse: the phone transmits a sounding reference signal, and the base station measures it directly, with no report needed because the measurement is already where the scheduler sits. In time-division duplex, where both directions share one frequency, the uplink measurement predicts the downlink, and the report can be skipped altogether.

Why does a whole chapter go on this? Because every adaptive decision in NR — how fast to send, in which beam, with how many streams — is only as good as the channel knowledge behind it, and that knowledge is always a little stale. The chart was read a few milliseconds ago and the channel has moved since. This chapter is about buying the freshest, most detailed knowledge for the least overhead. LTE solved it by transmitting a chart constantly; NR configures one per device and sends it only as often as that device needs.

**The question this chapter answers.** How does NR turn configured reference signals into channel observations, reports, and scheduling decisions without confusing the signal with the estimate?

!important[**The short answer.** The base station transmits CSI-RS for downlink observation and can configure CSI-IM for interference observation; the device derives quantities and reports selected channel-state information. The device transmits SRS so the base station can observe the uplink. These resources support beam, rank, precoder, and modulation decisions, but the standard keeps signal mapping, measurement definitions, reporting procedures, and scheduler implementation in separate places.]

Names you will meet in this note: channel state information (CSI), channel state information reference signal (CSI-RS), interference measurement resource (CSI-IM), zero-power CSI-RS (ZP-CSI-RS), sounding reference signal (SRS), tracking reference signal (TRS), channel-quality indicator (CQI), precoding-matrix indicator (PMI), rank indicator (RI), reference-signal received power (RSRP), code/frequency/time division multiplexing (CDM/FDM/TDM), bandwidth part (BWP), quasi co-location (QCL).

## 2. Where you are in 5G

Section 1 turned channel sounding into an eye test. The map below shows where the test happens in 5G: reference signals in both directions, feeding the beam and scheduling decisions of later chapters.

![[99 Attachments/5G/Locator Maps/STAR-08-Where-You-Are-in-5G.png|Where Star 08 sits in the whole 5G system]]

*Locator: Where Star 8 sits in the whole 5G system.*

This chapter lights channel sounding in the procedures band. It sits between the reference signals the physical layer defines (Star 29) and the decisions that use them — scheduling (Star 14), multi-antenna transmission (Star 11), and beam management (Star 12). Nothing in those chapters works without the reports this one produces.

The Knowledge Structure Map splits the sounding signals by direction, with the reciprocity bridge between them and the note that it collapses in FDD. The mechanism diagram draws the loop as a loop — configure, transmit and measure, report, schedule — and the two clocks that race in it: how long the loop takes, and how long the channel stays true.

![[99 Attachments/5G/Knowledge Maps/STAR-08-Channel-Sounding-Knowledge Structure Map.png|STAR-08 system-position map]]

*Knowledge map: The downlink and uplink sounding signals, split by direction.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-08-Channel-Sounding-Feedback-Loop.png|Star 08 mechanism and handoff diagram]]

*Mechanism: The channel-sounding loop and the two clocks that race in it.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 8.1 Downlink Channel Sounding — CSI-RS → 8.2 Downlink Measurements and Reporting → 8.3 Uplink Channel Sounding — SRS.


## 3. The textbook road

Section 2 placed sounding between the grid and the decisions that use it. The road below walks through the chapter in the book's order: the downlink signal, what is measured and reported, then the uplink counterpart.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base, including the author's own questions and their answers, which are kept as callouts. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 8.1 Downlink Channel Sounding — CSI-RS

The road starts with the chart itself: the downlink reference signal the phone measures, and why NR made it carry the whole load.

LTE originally relied on an always-on cell-specific reference signal, and added CSI-RS in Release 10 as a more flexible complement. NR dropped the always-on signal entirely — only the synchronisation block is always present — and made CSI-RS carry the whole load: detailed channel sounding, beam management, and mobility measurement.

#### 3.1.1 8.1.1 Basic CSI-RS Structure

A configured CSI-RS may include up to 32 antenna ports, each representing a distinct channel to be sounded. NR configures CSI-RS per device, though several devices may share one resource if they are configured identically. Thirty-two ports is what makes it possible to sound a large array or a set of beams in one measurement.

> [!important] 💡
> **“CSI-RS is configured per device, and multi-port CSI-RS supports many antennas/beamformed channels.”**
> NR configures **CSI-RS per device**; a configured CSI-RS can include **up to 32 antenna ports**, **each “port” representing a distinct channel to be sounded.** Multiple UEs may still share an identically configured CSI-RS. This is exactly to support many spatial dimensions (large arrays, beams).

The simplest case is a single port. Figure 8.1 shows it occupying one resource element in a resource block per slot, placed so that it avoids the control region, the data channel's own reference signal, and the synchronisation block.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.1 shows it occupying one resource element in a resource block per slot, placed so that it avoids the control region, the data channel's own reference signal, and the synchronisation block.*

With more ports, the ports have to be told apart. Three tools do it: code division, where ports share the same resource elements under orthogonal patterns; frequency division, where they sit on different subcarriers; and time division, where they sit in different symbols. Figure 8.2 shows the code-division options and Figure 8.3 a two-port signal using the plus-and-minus-one patterns.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.2 shows the code-division options and Figure 8.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.4 compares three ways of building an eight-port signal: two-fold code division with four-fold frequency division in one symbol; two-fold code, two-fold frequency, and two-fold time division across two symbols; or four-fold code with two-fold frequency division.*

Figure 8.4 compares three ways of building an eight-port signal: two-fold code division with four-fold frequency division in one symbol; two-fold code, two-fold frequency, and two-fold time division across two symbols; or four-fold code with two-fold frequency division. Port numbers are assigned code first, then frequency, then time, so in the middle case ports 0 to 3 and 4 to 7 are separated in time.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.4 compares three ways of building an eight-port signal: two-fold code division with four-fold frequency division in one symbol; two-fold code, two-fold frequency, and two-fold time division across two symbols; or four-fold code with two-fold frequency division.*

> [!important] 💡
> **“For multiple CSI-RS, FDM & TDM separate them (like Fig. 8.4 middle). CDM makes them distinguishable ‘spatially’ so ports don’t interfere.”**
> **Judgement: Mostly correct (add nuance).**
> **FDM/TDM** indeed separate per-port CSI-RS in frequency/time (see the **middle** 8-port structure in **Fig. 8.4**). **CDM** provides **orthogonality on the same REs** via different **orthogonal code patterns**, so **receivers can separate ports even when they overlap in time/frequency.** Think of CDM as orthogonalization in the **code** domain; it enables *spatial* channel separation because each **antenna port** carries a different code, but it’s not “beam separation” per se (that’s handled by FDM/TDM and the actual transmit beams).

Figure 8.5 scales the idea to 32 ports with eight-fold code and four-fold frequency division; note that ports separated in frequency or time need not sit on consecutive subcarriers or symbols.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.5 scales the idea to 32 ports with eight-fold code and four-fold frequency division; note that ports separated in frequency or time need not sit on consecutive subcarriers or symbols.*

#### 3.1.2 8.1.2 Frequency-Domain Structure of CSI-RS Configurations

A CSI-RS belongs to a bandwidth part and uses its numerology. It can span the whole part or a subset of it, and its density can be one — every resource block — or one half, every other block, which is not allowed for four-, eight-, or twelve-port signals. A special density of three subcarriers per block exists for the tracking reference signal described below. Density is the trade between how well the channel is measured and how many resources the measurement consumes.

#### 3.1.3 8.1.3 Time-Domain Property of CSI-RS Configurations

In time a CSI-RS can be periodic, transmitted every N-th slot with a slot offset, for N between 4 and 640; semi-persistent, with the same periodicity but switched on and off by a MAC control element; or aperiodic, fired once when a DCI triggers it. Strictly the time behaviour is a property of the resource set rather than the individual signal. Figure 8.6 shows periodicity and offset.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.6 shows periodicity and offset.*

#### 3.1.4 8.1.4 CSI-IM — Resources for Interference Measurements

Sometimes what needs measuring is not the signal but the interference. A CSI-IM resource — one of two four-element layouts — is left blank in the serving cell while neighbouring cells carry normal traffic, so whatever the device receives there is interference from outside. Figure 8.7 shows the two layouts. Its time behaviour mirrors CSI-RS, and inside the serving cell it is configured as a zero-power CSI-RS so that the device knows the data channel is rate-matched around it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.7 shows the two layouts.*

> [!important] 💡
> **“CSI-IM vs. ZP-CSI-RS: CSI-IM is blank in serving cell but not in neighbors, so UE can estimate inter-cell interference; inside the cell it’s configured as ZP-CSI-RS.”**
> **Judgement: Correct.**
> That’s exactly how CSI-IM is used. **Fig. 8.7** shows the CSI-IM structures; **the home cell should transmit nothing there, and UEs measure interference from neighbor activity.** In the serving cell these are **ZP-CSI-RS resources**, so PDSCH is rate-matched around them.

#### 3.1.5 8.1.5 Zero-Power CSI-RS (ZP-CSI-RS)

A zero-power CSI-RS has the same structure as a normal one but carries no signal for this device; its purpose is to tell the device where not to expect data, so that the data channel can be mapped around the hole. Despite the name, something else may be transmitted there — another device's CSI-RS, for instance — so the device must not assume true silence.

#### 3.1.6 8.1.6 CSI-RS Resource Sets

Resources are grouped into sets. A device can be configured with several non-zero-power CSI-RS resource sets, each referencing one or more CSI-RS — or synchronisation blocks, for mobility and beam management. Semi-persistent sets are activated and deactivated as a whole by a MAC control element; aperiodic sets are triggered as a whole by DCI. CSI-IM resources are grouped the same way. Grouping is what lets one command switch an entire measurement configuration.

#### 3.1.7 8.1.7 Tracking Reference Signal — TRS

!note[A receiver's clock drifts in both frequency and time, and without an always-on signal it needs something regular to track against. The tracking reference signal is not a new signal type but a resource set of periodic CSI-RS configured for the purpose: four single-port signals at density three across two consecutive slots, repeating every 10, 20, 40, or 80 ms. Figure 8.8 shows it. The four-symbol separation within a slot sets how large a frequency error can be tracked; the four-subcarrier separation sets the timing error. A single-slot variant with two signals also exists, and the overhead is far below LTE's cell-specific reference signal.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.8 shows it.*

#### 3.1.8 8.1.8 Mapping to Physical Antennas

!important[A CSI-RS port is not an antenna. Between the port and the physical antennas sits a spatial filter, F — a precoder or beamformer that the device never sees — and there may be more antennas than ports. What the device sounds is therefore the effective channel after F. Figure 8.9 shows the mapping; Figure 8.10 shows two CSI-RS mapped through different filters — different beams — from the same array, so that the device perceives two different channels. Two signals count as the same port only if they pass through the same filter to the same antennas.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.9 shows the mapping; Figure 8.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.9 shows the mapping; Figure 8.*

> [!important] 💡
> **“Mapping to Physical Antennas: F is the precoder? Precoding is like spatial multiplexing? How to understand ‘the channel being sounded based on a CSI-RS is often not the actual physical radio channel.’”**
> **Judgement: Correct intuition (clarified).**
> **F** is a **spatial filter/linear transformation** (often a **precoder/beamformer**) applied **before** mapping ports to the physical antennas. Because of F, the UE sounds the **effective** channel (after precoding/beamforming). Different CSI-RS may use different F (beams), so the UE observes different channels even from the same array (see Fig. 8.9/8.10). Spatial multiplexing then happens when multiple transmission layers are mapped via a precoder to antenna ports — and the UE’s CSI (CQI/RI/PMI) steers that choice.

> [!book] Book expansion
> Chapter 8 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 147–164, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00008-8)) is where the book explains why NR could drop the always-on reference: because a per-device, configurable CSI-RS does everything the cell-specific one did, at a fraction of the cost.

> [!spec] 3GPP reality check
> The CSI-RS structure — ports, densities, code-division patterns, and the table of allowed configurations — is [TS 38.211 V18.9.0, clause 7.4.1.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the resource sets and their time behaviour are configured through TS 38.331's CSI-MeasConfig.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [CSI-RS page](https://www.sharetechnote.com/html/5G/5G_CSI_RS.html) draws every row of the configuration table as a resource-block picture, which is the easiest way to see what "8×CDM + 4×FDM" looks like on the grid.

### 3.2 8.2 Downlink Measurements and Reporting

Section 3.1 described what is transmitted. This section asks what the phone does with it: which quantities it measures and how it reports them.

!important[A report configuration says what to measure, where to measure it — on CSI-RS or on synchronisation blocks — and how and when to report. The quantities include the channel-quality indicator, the rank indicator, and the precoding-matrix indicator, or a received power for beam and mobility purposes. Report type and resource type are coupled: Table 8.1 gives the allowed combinations of periodic, semi-persistent, and aperiodic reporting against the three resource types, and a periodic report, for instance, can only be based on periodic resources.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Report type and resource type are coupled: Table 8.1 gives the allowed combinations of periodic, semi-persistent, and aperiodic reporting against the three resource types, and a periodic report, for instance, can only be based on periodic resources.*

> [!spec] 3GPP reality check
> The reporting procedure, the quantities, the tables that turn a CQI index into a modulation and code rate, and the allowed report–resource combinations are all in [TS 38.214 V18.10.0, clause 5.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); the measurement quantities themselves are defined in TS 38.215 clause 5.1.

> [!engineering] ShareTechnote engineering view
> The [CSI report page](https://www.sharetechnote.com/html/5G/5G_CSI_Report.html) shows what a report looks like when it arrives in a base-station log, which makes the abstract indices concrete.

### 3.3 8.3 Uplink Channel Sounding — SRS

Sections 3.1 and 3.2 sounded the downlink. This section turns the test around: the phone transmits a known signal and the base station measures.

The sounding reference signal is the uplink counterpart of CSI-RS, and can also serve as a quasi-co-location reference. But it is a smaller instrument, structurally different and limited to four antenna ports, and it is designed for a low cubic metric so that the phone's power amplifier stays efficient.

#### 3.3.1 8.3.1/8.3.2 SRS Sequences (Zadoff–Chu) & Multi-Port SRS

SRS is built on Zadoff–Chu sequences, and supports at most four ports against CSI-RS's 32. The asymmetry is a fact about phones: fewer transmit chains, fewer antennas, and tighter power and size limits.

> [!important] 💡
> **“SRS supports fewer antenna ports than CSI-RS because UE MIMO is smaller than gNB?”**
> **Judgement: Correct (and explicitly stated).**
> The chapter states **SRS is limited to max 4 antenna ports** whereas **CSI-RS supports up to 32**. This aligns with practical constraints: UEs have fewer TX chains/antennas and stricter PA/size limits, especially in uplink.

When an SRS has more than one port, the ports share the same resource elements and the same base sequence, and are separated by different phase rotations — which, as Figure 8.13 shows, is equivalent to a cyclic shift in the time domain.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*When an SRS has more than one port, the ports share the same resource elements and the same base sequence, and are separated by different phase rotations — which, as Figure 8.13 shows, is equivalent to a cyclic shift in the time domain.*

#### 3.3.2 8.3.3 Time-Domain Structure of SRS

An SRS spans one, two, or four OFDM symbols, normally within the last six of a slot, so that it stays out of the way of the data it informs; Release 16 allows it anywhere in the slot for positioning and unlicensed operation. A comb of two or four means transmitting on every second or fourth subcarrier, which is what lets several devices sound at once. Figure 8.11 shows the basic structure and Figure 8.12 the frequency multiplexing of several signals on different comb offsets.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.11 shows the basic structure and Figure 8.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 8.11 shows the basic structure and Figure 8.*

#### 3.3.3 8.3.4 SRS Resource Sets

As with CSI-RS, periodic, semi-persistent, and aperiodic behaviour is a property of the resource set, and an aperiodic set is triggered by a two-bit field in the uplink or downlink DCI that selects one of three configured sets. The mirror-image configuration keeps one mental model for both directions.

#### 3.3.4 8.3.5 Mapping to Physical Antennas

SRS ports map to the phone's antennas through a filter of their own, often one per antenna panel at millimetre wave, so that different panels present different filters. Figures 8.14 and 8.15 show it. The base station can sound the uplink, choose the precoder it wants the phone to use, and expect the phone to apply that precoder through the same filter — the same beam and panel — it used for the sounding.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The base station can sound the uplink, choose the precoder it wants the phone to use, and expect the phone to apply that precoder through the same filter — the same beam and panel — it used for the sounding.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The base station can sound the uplink, choose the precoder it wants the phone to use, and expect the phone to apply that precoder through the same filter — the same beam and panel — it used for the sounding.*

> [!spec] 3GPP reality check
> The SRS sequence, its combs, symbols, and port mapping are [TS 38.211 V18.9.0, clause 6.4.1.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); when the device transmits it is TS 38.214 clause 6.2.

> [!engineering] ShareTechnote engineering view
> The [SRS page](https://www.sharetechnote.com/html/5G/5G_SRS.html) works through comb, cyclic shift, and symbol placement with concrete RRC parameter names, which is what you will need when configuring one.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section says which of four documents owns the signal, the measurement, the report and the configuration, because knowing that is most of the skill.

Channel sounding is split across four documents, and knowing which is which is most of the skill. The signal — what is transmitted, on which resource elements, with which pattern — is TS 38.211. What is measured from it, and how those quantities are defined, is TS 38.215. How the device reports, in which form and when, is TS 38.214. And the configuration that ties them together — which resources exist, which reports are wanted, what triggers them — is TS 38.331. The figure lays them out with the numbers each one fixes.

![[99 Attachments/5G/Protocol Figures/STAR-08-Channel-Sounding-Protocol.png|The four documents that split channel sounding between signal, measurement, report and configuration]]

*Protocol figure: The four documents that split channel sounding between signal, measurement, report and configuration.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| CSI-RS and SRS mapping | [TS 38.211 V18.9.0, clauses 6.4.1.4 and 7.4.1.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | The signals themselves: ports, densities, combs, sequences, and where they sit on the grid. |
| CSI procedures | [TS 38.214 V18.10.0, clause 5.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | Reporting: quantities, CQI tables, allowed report–resource combinations, timing. |
| SRS procedures | [TS 38.214 V18.10.0, clause 6.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | When and how the device transmits its sounding signal. |
| Measurements | [TS 38.215 V18.5.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) | The definitions of received power, quality, and signal-to-interference ratio. |

!note[**When you build or run a demo.** In an open-source gNB the sounding configuration is a block of RRC parameters: a CSI-RS resource with its period in slots, its offset, its port count and density; a report configuration naming the quantities wanted; and an SRS configuration with its comb and port count. Each of those keys is a field in TS 38.331, and each value is constrained by a table in TS 38.211 or 38.214 — a period must be one of the allowed values, a density of one half is not allowed with four ports. The result appears in the log as a line of indices, CQI and RI and PMI, and the scheduler turns the CQI into a modulation and code rate through the table in TS 38.214 clause 5.2.2.1. If throughput is low, the first thing to check is whether the reported CQI is low, and then whether the CSI-RS is sent often enough for a moving device.]

Release 15 provided the CSI-RS and SRS framework; later releases expand ports, reporting, multi-point transmission, positioning, mobility, and beam-management uses. The loop stays the same — signal, observation, report, decision — but the inventory of resources and reports is release-dependent. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents split the process; this trace runs one measurement through it end to end with numbers you can check.

**Worked numerical example.**

Combine three subband quality estimates with explicit scheduler weights to show how an effective indicator depends on the aggregation rule.

**What we are working out.** Weighted effective linear channel-quality ratio for one report, dimensionless, measured at the configured CSI resource-set.

$$
\begin{aligned}
\gamma_{eff} &= \frac{\sum_k w_k\gamma_k}{\sum_k w_k} \\ &= \frac{(1)(4)+(2)(2)+(1)(1)}{1+2+1} \\ &= 2.25
\end{aligned}
$$

Where:

- $\gamma_{eff}$ = 2.25, calculated (weighted arithmetic mean); it belongs to the CSI resource set.
- $w_k$ = 1, 2, 1, assumed (illustrative scheduler weights); it belongs to the three subbands.
- $\gamma_k$ = 4, 2, 1, measured (illustrative linear estimates); it belongs to the three subbands.
- $k$ = 1 to 3, assumed (subband index); it belongs to the CSI resource set.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $\gamma_{eff}$ | 2.25 | calculated | weighted arithmetic mean | CSI resource set |
| $w_k$ | 1, 2, 1 | assumed | illustrative scheduler weights | three subbands |
| $\gamma_k$ | 4, 2, 1 | measured | illustrative linear estimates | three subbands |
| $k$ | 1 to 3 | assumed | subband index | CSI resource set |

The numerator and denominator are dimensionless weighted sums, so the result is dimensionless. This arithmetic mean is pedagogical and is not the official CQI mapping. A real receiver uses configured measurements, implementation algorithms, codebook assumptions, and reporting rules.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about sounding.

**Course alignment.** This is the primary sounding reference for U06–U08. Students should identify the transmitted resource, measured quantity, report field, and scheduling action in separate columns before discussing beamforming. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

!warning[**“CSI-RS is the channel estimate”.**

CSI-RS is a transmitted reference resource; the receiver derives an estimate from received samples. The fix is to separate the transmitted reference from the estimate a receiver derives from it.]

!warning[**“CQI is measured SNR”.**

CQI is a quantized recommendation under receiver assumptions. The fix is to read a reported index as a recommendation under stated assumptions.]

!warning[**“Zero-power means no function”.**

Muted resources create an observation opportunity for interference or rate matching. The fix is to ask what a muted resource makes observable, rather than treating it as wasted.]

!warning[**“SRS carries user data”.**

SRS is a known reference signal. The fix is to keep reference signals and payload channels in separate categories.]

!warning[**“TDD guarantees perfect reciprocity”.**

Hardware chains need calibration, and the channel must remain coherent across the inference interval. The fix is to state the calibration and coherence assumptions before relying on reciprocity.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 8, pp. 147–164, 2021, DOI [chapter 8](https://doi.org/10.1016/B978-0-12-822320-8.00008-8).
2. Chapter 8 notes of this knowledge base (the author's reading notes).
4. 3GPP, *TS 38.211 V18.9.0, clauses 6.4.1.4 and 7.4.1.5*, [CSI-RS and SRS mapping](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
5. 3GPP, *TS 38.214 V18.10.0, clause 5.2*, [CSI procedures](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
6. 3GPP, *TS 38.215 V18.5.0, clauses 5–6*, [Measurements](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip).
7. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
8. ShareTechnote, [CSI-RS](https://www.sharetechnote.com/html/5G/5G_CSI_RS.html), accessed 2026-08-03.
9. ShareTechnote, [CSI report](https://www.sharetechnote.com/html/5G/5G_CSI_Report.html), accessed 2026-08-03.
10. ShareTechnote, [reference signals](https://www.sharetechnote.com/html/5G/5G_Phy_ReferenceSignal.html), accessed 2026-08-03.
11. Saar University 5G course alignment.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| gNB | next generation NodeB | Section 1; fixed specification set in Section 6 |
| CSI | Channel State Information | Section 1; fixed specification set in Section 6 |
| CSI-RS | Channel State Information Reference Signal | Section 1; fixed specification set in Section 6 |
| CSI-IM | Channel State Information Interference Measurement | Section 1; fixed specification set in Section 6 |
| SRS | Sounding Reference Signal | Section 1; fixed specification set in Section 6 |
| TRS | Tracking Reference Signal | Section 1; fixed specification set in Section 6 |
| CQI | Channel Quality Indicator | Section 1; fixed specification set in Section 6 |
| PMI | Precoding Matrix Indicator | Section 1; fixed specification set in Section 6 |
| RI | Rank Indicator | Section 1; fixed specification set in Section 6 |
| MCS | Modulation and Coding Scheme | Section 1; fixed specification set in Section 6 |
| RRC | Radio Resource Control | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $\gamma_{eff}$ | Illustrative effective quality ratio | dimensionless |
| $w_k$ | Weight for subband k | dimensionless |
| $\gamma_k$ | Linear quality estimate for subband k | dimensionless |
| $k$ | Subband index | count |

The symbols mean what they mean in this note; another note may use the same letter for something else.
