---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 4
title: 'LTE: An Overview'
language: en
course_units:
- U03
- U04
- U05
- U09
- U10
release_baseline: 18
---

# STAR-04 — LTE: An Overview

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

If you moved into a renovated house, you would want to know which walls were load-bearing before you started knocking things down. NR is a renovation of LTE. The foundation — OFDM, a shared channel that a scheduler hands out, fast retransmission with soft combining, a flat all-IP network, the layered protocol stack — was poured for 4G and never replaced. The walls were moved: things that were fixed numbers in LTE became configurable parameters in NR. And a new roof went on: beams, millimetre wave, new error-correcting codes, and the removal of signals that LTE transmitted constantly. To see what 5G actually changed, you have to see the house that was already standing.

![[99 Attachments/5G/Concept Figures/STAR-04-LTE-An-Overview-Concept.png|LTE and NR drawn as a house: foundation kept, walls moved, roof replaced]]

*Concept figure: LTE and NR drawn as one house in three layers: foundation kept, walls made adjustable, roof replaced.*

There is a second reason this chapter matters, and it is not historical. LTE is still on the air, and most 5G phones in use today connect through an LTE anchor with an NR carrier alongside — the non-standalone arrangement that let 5G launch years before the 5G core was ready. A phone showing "5G" in its status bar is very often running two radio stacks at once. So this chapter describes the system that 5G is still standing on.

The textbook chapter covers a lot of ground: the two duplex modes, the Release 8 radio design, the multi-antenna vocabulary, and the decade of releases that added carrier aggregation, small cells, machine-type communication, and vehicular links. Read it with one question in mind for every item: did NR keep this, make it configurable, or replace it? The figure above is the answer key.

**The question this chapter answers.** Which LTE design decisions became the baseline for modern scheduled packet radio, and which of them did NR retain or redesign?

!important[**The short answer.** LTE combined an all-IP architecture, frequency-domain scheduling, downlink OFDM, uplink DFT-precoded OFDM, fast HARQ, link adaptation, and MIMO. LTE-Advanced extended bandwidth and topology through carrier aggregation, relays, and small cells. NR retains the scheduled grid and the layered protocol logic but makes numerology, bandwidth parts, reference signals, control regions, and beam operation configurable.]

Names you will meet in this note: Long-Term Evolution (LTE), Evolved Packet Core (EPC), frequency division duplex (FDD), time division duplex (TDD), Orthogonal Frequency Division Multiplexing (OFDM), cell-specific reference signal (CRS), Hybrid Automatic Repeat Request (HARQ), Multiple-Input Multiple-Output (MIMO), carrier aggregation (CA), License-Assisted Access (LAA), Coordinated Multi-Point (CoMP), Evolved Node B (eNB).

## 2. Where you are in 5G

Section 1 described NR as a renovation of LTE. The map below shows where LTE sits in the 5G system: beside NR, sharing the same access network, which is why it earns a chapter of its own.

![[99 Attachments/5G/Locator Maps/STAR-04-Where-You-Are-in-5G.png|Where Star 04 sits in the whole 5G system]]

*Locator: Where Star 4 sits in the whole 5G system.*

This chapter lights the strip labelled "LTE alongside" in the top band: the older radio that still runs beside NR, and that most deployed 5G still anchors on. Star 18 returns to this box to explain the interworking options in detail; here the aim is to know LTE well enough to recognise it inside NR.

The Knowledge Structure Map draws LTE as a timeline of releases, each adding something the next one built on. The mechanism diagram sorts LTE's design decisions into three columns — kept unchanged, generalised into a parameter, replaced outright — which is the same sorting the house figure makes.

![[99 Attachments/5G/Knowledge Maps/STAR-04-LTE-An-Overview-Knowledge Structure Map.png|STAR-04 system-position map]]

*Knowledge map: The LTE releases and what each one added.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-04-LTE-to-NR-Inheritance-Chain.png|Star 04 mechanism and handoff diagram]]

*Mechanism: What NR kept from LTE, what it generalised, and what it replaced.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: LTE: An Overview → Frequency Division Duplex (FDD) → Time Division Duplex (TDD) → Summary Comparison Table → LTE Background and Evolution.


## 3. The textbook road

Section 2 placed LTE beside NR on the map. The road below walks through the LTE chapter in the book's order, so that the load-bearing walls of Section 1 appear one at a time.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 LTE: An Overview

The road starts where the book does: what LTE was designed for, and the three radio choices it made that NR kept.

LTE, standardised in 3GPP Release 8 and first deployed in 2009, was the first mobile system designed from the start for packet data only. There is no circuit-switched voice in it; a phone call is an IP flow like any other. Its radio made three choices that every later system kept: OFDM as the waveform, a single shared channel that a scheduler allocates every millisecond, and fast retransmission in which a failed transmission is kept and combined with the retry rather than discarded. The rest of the chapter is about how those choices were made and how they grew.

> [!book] Book expansion
> Chapter 4 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 39–56, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00004-0)) is written as a bridge: it describes LTE only as far as is needed to understand NR's departures from it.

> [!spec] 3GPP reality check
> LTE's own overview is [TS 36.300 V18.8.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/36_series/36.300/36300-i80.zip), which is still maintained in Release 18. The numbering is deliberate: 36.300 is to LTE what 38.300 is to NR, and every LTE document has an NR twin with the same last three digits.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [LTE handbook](https://www.sharetechnote.com/html/Handbook_LTE.html) covers the same ground from a practitioner's side, and its pages on LTE frame structure are the quickest way to see what the fixed 15 kHz, 1 ms design looked like on the air.

### 3.2 Frequency Division Duplex (FDD)

Section 3.1 named the three inherited choices. The next two sections look at a fourth thing LTE handed down, the two ways of separating uplink from downlink, starting with separation in frequency.

#### 3.2.1 Principle

In frequency division duplex, uplink and downlink use separate frequency bands and transmit at the same time. LTE Band 1 is the classic example: the phone transmits between 1920 and 1980 MHz while the base station transmits between 2110 and 2170 MHz, and the two never collide because they are 190 MHz apart.

```plain text
       ↑ UL Frequency Band (e.g., 1920–1980 MHz)
       |_______________________|
                ↑↑↑↑
       |_______________________|
       ↓ DL Frequency Band (e.g., 2110–2170 MHz)

       ←──► Both directions active at the same time
```

#### 3.2.2 Characteristics

| Feature | Description |
| --- | --- |
| Duplex separation | Fixed guard band between UL and DL (to avoid interference). |
| Simultaneous transmission | DL & UL can occur at the same time. |
| Requires | **Two separate RF chains or duplex filters.** |
| Latency | Low (no switching time needed). |
| Bandwidth flexibility | Limited — uplink and downlink must occupy paired spectrum. |
| Example LTE Band | Band 1 (UL: 1920–1980 MHz, DL: 2110–2170 MHz). |

The price of simultaneity is hardware: a device needs a duplex filter that keeps its own transmitter out of its own receiver, and that filter is designed for one band pair.

#### 3.2.3 Advantages

FDD suits traffic that flows both ways at once — voice, real-time control, anything symmetric. The fixed frequency separation makes it robust against interference between the directions, and it is the mode most 2G, 3G, and 4G macro networks were built on, so the ecosystem is mature.

#### 3.2.4 Disadvantages

It needs paired spectrum, which is scarce and expensive, and when traffic is asymmetric — far more downlink than uplink, as with video — half of that paired spectrum sits underused.

#### 3.2.5 Typical Use Scenarios

| Scenario | Reason |
| --- | --- |
| Wide-area macro cells (rural/suburban) | Stable, balanced DL/UL traffic. |
| Licensed bands (below 3 GHz) | Paired spectrum availability. |
| Voice and control-dominated networks | Low-latency simultaneous transmission. |

> [!spec] 3GPP reality check
> LTE's frame structure type 1 (FDD) is defined in [TS 36.211 V18.0.2, clause 4](https://www.3gpp.org/ftp/Specs/archive/36_series/36.211/36211-i02.zip); NR replaced the separate frame types with one structure, defined in TS 38.211 clause 4.3.

### 3.3 Time Division Duplex (TDD)

FDD separated the directions in frequency. This section separates them in time instead and asks what the switching costs.

#### 3.3.1 Principle

In time division duplex, both directions share one frequency band and take turns. A pattern of subframes — some downlink, some uplink — repeats, and a guard interval at each switch covers the propagation delay.

```matlab
Time → | DL | DL | UL | DL | UL | ...
         ↑↑↑ same frequency band ↑↑↑
```

#### 3.3.2 Characteristics

| Feature | Description |
| --- | --- |
| Frequency usage | One shared frequency for both directions. |
| Time split | Configurable ratio (e.g., 6 DL : 4 UL subframes). |
| Synchronization | Strict timing coordination needed (especially in neighboring cells). |
| Switching gap | Guard period inserted between DL and UL to avoid overlap. |

#### 3.3.3 Advantages

TDD makes unpaired spectrum usable, which matters because most spectrum above 3 GHz is unpaired. It can give more time to the heavier direction, and because both directions use the same frequency, a channel measured on the uplink predicts the downlink — reciprocity, which is what makes massive MIMO practical. It also simplifies small cells and private networks, where one radio chain serves both directions.

#### 3.3.4 Disadvantages

Nothing happens in both directions at once, so switching adds delay. The guard period is time not used for data. And neighbouring cells must agree on the pattern and be synchronised to it, because a cell transmitting downlink while its neighbour receives uplink creates cross-link interference that FDD never sees.

#### 3.3.5 Typical Use Scenarios

| Scenario | Reason |
| --- | --- |
| Hotspots / small cells | Highly asymmetric DL-heavy traffic. |
| Unpaired or shared spectrum (e.g., 3.5 GHz, 5 GHz LAA) | Spectrum flexibility. |
| **Massive MIMO & beamforming** | Channel reciprocity simplifies CSI estimation. |
| Local 5G, private industrial networks | Easy dynamic reconfiguration of DL/UL ratio. |

> [!engineering] ShareTechnote engineering view
> The [LTE handbook](https://www.sharetechnote.com/html/Handbook_LTE.html) tabulates the seven LTE TDD uplink–downlink configurations; compare them with NR's freely configurable pattern in Star 21 to see what "made configurable" means in practice.

### 3.4 Summary Comparison Table

Sections 3.2 and 3.3 described FDD and TDD one at a time. The table below puts them side by side, property by property.

| Property | **FDD** | **TDD** |
| --- | --- | --- |
| Duplex separation | Frequency | Time |
| UL/DL simultaneity | ✅ Yes | ❌ No |
| Spectrum type | Paired | Unpaired |
| Flexibility (DL/UL ratio) | Fixed | Dynamic |
| Guard type | Frequency guard band | Time guard interval |
| Channel reciprocity | No | Yes (same frequency) |
| Synchronization demand | Low | High |
| Typical band | Sub-3 GHz | 3–6 GHz, mmWave |
| Traffic pattern best suited | Symmetric | Asymmetric (DL-dominant) |
| Typical use | Wide-area LTE, 4G | 5G NR, small cells, industrial networks |

### 3.5 LTE Background and Evolution

Duplexing was fixed in Release 8. This section follows LTE through the nine releases that came after, each one an answer to a problem found in the field.

LTE did not arrive finished. Over nine releases it acquired carrier aggregation, relays, coordinated multi-point transmission, dual connectivity, small-cell features, narrowband IoT, vehicular links, and shortened transmission intervals — each one an answer to a problem the previous release had discovered in the field. Figure 4.1 shows the timeline; the table gives the headline of each release.

| Release | Year Completed | Key Name | Major Features |
| --- | --- | --- | --- |
| 8 | 2009 | Basic LTE | OFDM, 15 kHz subcarrier spacing, EPC core, FDD/TDD support |
| 9 | 2010 | – | Positioning, MBMS, minor MIMO improvements |
| 10 | 2011 | LTE-Advanced | Carrier Aggregation (5×20 MHz), MIMO up to 8×8, Relay, ICIC |
| 11 | 2012 | LTE-A Enh. | CoMP (Coordinated Multi-Point), advanced control channels |
| 12 | 2014 | – | Dual Connectivity, Small Cells, D2D, Dynamic TDD |
| 13 | 2015 | LTE-Advanced Pro (“4.5 G”) | NB-IoT, LAA, enhanced MIMO, CA 32 carriers |
| 14 | 2017 | – | V2X, broadcast enhancements, make-before-break handover |
| 15 | 2018 | – | sTTI (low latency), aerial communication support |
| 16 | 2019 | – | massive MIMO uplink support, enhanced mobility (DAPS) |

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*| CoMP (Coordinated Multi-Point), advanced control channels | | 12 | 2014 | – | Dual Connectivity, Small Cells, D2D, Dynamic TDD | | 13 | 2015 | LTE-Advanced Pro (“4.5 G”) | NB-IoT, LAA, enhanced MIMO, CA 32 carriers | | 14 | 2017 | – | V2X, broadcast enhancements, make-before-break handover | | 15 | 2018 | – | sTTI (low latency), aerial communication support | | 16 | 2019 | – | massive MIMO uplink support, enhanced mobility (DAPS) |.*

Notice how many NR features appear here first in LTE form: dual connectivity, dynamic TDD, device-to-device links, shortened intervals. NR generalised them; it rarely invented them.

### 3.6 LTE Basic Radio Access (Rel-8)

Section 3.5 showed how much changed after Release 8. This section returns to the Release 8 design itself, because its fixed numbers are exactly what NR later made variable.

!important[The Release 8 design is worth memorising as a set of fixed numbers, because each of them is exactly what NR later made variable.]

| Aspect | Design Choice / Value | Purpose |
| --- | --- | --- |
| Waveform | OFDM (DL), DFT-precoded OFDM (UL) | Multipath resilience / low PAPR for UE |
| Subcarrier spacing | 15 kHz | Balance between delay spread & mobility |
| Frame structure | 10 ms frame = 10 × 1 ms subframes | Scheduler granularity |
| Duplex modes | FDD & TDD | Spectrum flexibility |
| Bandwidth options | 1.4 – 20 MHz | Adapt to available spectrum |
| Reference signals | Cell-specific RS | Channel estimation, sync, mobility measurements |
| Scheduler | Per-1 ms subframe (PDCCH/PUCCH) | Channel-aware dynamic allocation |
| Error control | Turbo code + Hybrid ARQ | Fast retransmission |

One entry deserves a second look: the cell-specific reference signal. LTE transmitted it in every subframe of every cell, whether or not anyone was listening, so that any device could estimate the channel at any moment. That convenience cost energy and caused interference between cells, and removing it is the single change NR is most defined by.

### 3.7 Multi-Antenna Scheme (Transmission Layer & MIMO)

One of those fixed numbers was the number of antenna layers. This section explains layers, ports and antennas, the three words that NR's multi-antenna chapters assume you already keep apart.

#### 3.7.1 3.1 Concepts

!important[Three words are routinely confused: layer, port, and antenna. A layer is an independent data stream. An antenna is hardware. A port is a logical identity in between — a channel that the device is told it may assume. The precoder is the matrix that maps layers onto antennas, and the rank is how many layers are active at once.]

| Term | Description |
| --- | --- |
| **Transmission Layer** (N_L) | Independent data stream in **spatial multiplexing**. **Each layer is precoded and mapped onto physical antennas**. |
| **Antenna Ports / Elements (N_A)** | Physical transmit antennas used to form beams or multiplex layers. |
| **Rank (r)** | Number of active layers (r ≤ N_A). Chosen by network based on CSI. |
| **Precoder Matrix (W_\{N_A × N_L\})** | **Maps each layer to antennas.** Network selects from codebook (feedback from UE). |
| **Closed-Loop MIMO** | UE reports Channel State Information (CSI); **BS updates precoder accordingly.** |
| **Open-Loop MIMO** | No CSI feedback; uses fixed codebook. Robust but lower throughput. |
| **Beamforming** (rank 1) | Precoder reduces to a vector; maximizes SNR toward UE. |

Why does the network keep updating the precoder? Because the precoder is what maps layers onto antennas, and the best mapping depends on the channel, which changes as the device moves. Closed-loop operation is the device telling the network which mapping currently works.

#### 3.7.2 3.2 Evolution of MIMO

| Release | Downlink | Uplink | Notable Enhancements |
| --- | --- | --- | --- |
| 8 | Up to 4 Tx (2 layers common) | 1 layer | Closed-loop 2×2 MIMO |
| 10 | 8 Tx / 8 layers | 4 layers | Carrier Aggregation + beamforming |
| 13–16 | Full-Dimension MIMO (2D arrays) | Spatial multiplexing +beamforming | Massive MIMO & CoMP introduced |

#### 3.7.3 3.3 Equation View

$$
\mathbf{y} = \mathbf{H}\mathbf{W}\mathbf{x} + \mathbf{n}
$$

Here $\mathbf{x}$ is the layer vector of length $N_L$, $\mathbf{W}$ the $N_A \times N_L$ precoding matrix, $\mathbf{H}$ the $N_R \times N_A$ channel matrix, and $\mathbf{y}$ what the device receives. When $N_L > 1$ the streams are multiplexed spatially; when $N_L = 1$, $\mathbf{W}$ collapses to a vector and the operation is beamforming. The equation is the same one NR uses, and the CoMP schemes — coordinated beamforming, dynamic point selection, joint transmission — are the same equation applied across several base stations at once.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The equation is the same one NR uses, and the CoMP schemes — coordinated beamforming, dynamic point selection, joint transmission — are the same equation applied across several base stations at once.*

#### 3.7.4 4. Spectrum Flexibility

| Mechanism | Purpose | Description / Example Figure |
| --- | --- | --- |
| **Carrier Aggregation (CA)** | Combine multiple component carriers (≤ 32) | Up to 640 MHz bandwidth ( Fig 4.3 ) |
| **License-Assisted Access (LAA)** | Use unlicensed 5 GHz with licensed anchor | Fair sharing via Listen-Before-Talk ( Fig 4.4 ) |

Carrier aggregation was LTE's answer to a 20 MHz per-carrier limit: bond several carriers and schedule each. License-assisted access took the same idea into unlicensed 5 GHz spectrum with a licensed carrier as anchor. NR kept both and, with bandwidth parts, added a way to be flexible inside a carrier as well as across them.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*NR kept both and, with bandwidth parts, added a way to be flexible inside a carrier as well as across them.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*NR kept both and, with bandwidth parts, added a way to be flexible inside a carrier as well as across them.*

#### 3.7.5 Network Densification and Small Cells

| Enhancement | Description | Key Benefit |
| --- | --- | --- |
| Relaying | **Low-power relay node wirelessly linked to donor cell** ( Fig 4.6 ) | Coverage extension w/ backward compatibility |
| Heterogeneous Deployment | Mix macro + pico cells ( Fig 4.7 ) | High capacity via layered coverage |
| Small-Cell On/Off | Cells muted when idle | Reduced interference & energy saving |
| Dual Connectivity | Simultaneous links to two eNBs ( Fig 4.8 ) | User plane aggregation over non-ideal backhaul |
| Dynamic TDD (eIMTA) | Flexible UL/DL split | Better traffic adaptation for local cells |

Adding cells is the oldest way to add capacity, and every entry in this table is a problem that adding cells created: relays for backhaul, heterogeneous layers for coverage, on/off for interference, dual connectivity for aggregation across sites, and dynamic TDD for local traffic. NR's integrated access and backhaul (Star 22) and its dual-connectivity options (Star 18) descend directly from these.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*NR's integrated access and backhaul (Star 22) and its dual-connectivity options (Star 18) descend directly from these.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*NR's integrated access and backhaul (Star 22) and its dual-connectivity options (Star 18) descend directly from these.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*NR's integrated access and backhaul (Star 22) and its dual-connectivity options (Star 18) descend directly from these.*

#### 3.7.6 Device Enhancements

Later releases began to specify what a receiver could do as well as what a transmitter must send. Improved receiver types were defined beyond the minimum, and Release 12 added network-assisted interference cancellation, in which the network tells a device about an interfering cell so the device can cancel it. Receiver capability became a standardised assumption rather than a vendor's private matter.

#### 3.7.7 New Scenarios and Services

| Scenario | Introduced | Description |
| --- | --- | --- |
| **eMTC / NB-IoT** | Rel-12/13 | Low-power machine communication (sub-1 MHz NB) |
| **URLLC / sTTI** | Rel-15 | 1 ms TTI → few symbols; for automation & control |
| **D2D & V2X** | Rel-12–14 | Direct PC5 link for safety / public safety / platooning ( Figs 4.9–4.10 ) |
| **Aerial (UAV)** | Rel-15 | Channel model & interference control for drones |
| **MBMS / eMBMS** | Rel-9 → 14 | Single-freq broadcast / SC-PTM / LTE broadcast |

This table is where LTE's single-design assumption began to strain. Machine-type devices wanted narrower channels and longer battery life than a broadband design offered; control applications wanted shorter intervals than a 1 ms subframe; vehicles wanted to talk to each other directly. Each was bolted on. NR was designed with all three in view from the start.

#### 3.7.8 LTE Key Performance Summary

| Metric | Downlink | Uplink |
| --- | --- | --- |
| Peak Rate (Rel-8) | 150 Mbit/s (20 MHz, 2×2 MIMO) | 75 Mbit/s |
| Peak Rate (Rel-13) | 25 Gbit/s (640 MHz, 8×8, 256-QAM) | 1.5 Gbit/s |
| Round-Trip Latency | ≈ 8 ms (H-ARQ) | – |
| End-to-End Latency | ≈ 10 ms (typical) | – |

Read the conditions in brackets before the numbers. A 25 Gbit/s peak rate needs 640 MHz of aggregated spectrum, eight layers, and 256QAM at once; no phone has ever seen it. The 150 Mbit/s of Release 8 on 20 MHz with two layers is the number that describes what LTE actually delivered.

#### 3.7.9 Takeaways for 5G Context

LTE is the foundation of NR in three specific ways. The 15 kHz subcarrier spacing survives as the base of NR's family, which is what lets the two share spectrum. The reference-signal concept survives, made on-demand. And the MIMO principles — layers, precoders, feedback — survive unchanged. Many Release 15 and 16 features bridge the two systems, and LTE remains inside 5G through the non-standalone mode in which an LTE cell anchors an NR carrier.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the specifications. Every LTE document has an NR twin with the same last three digits, and reading them in pairs is the quickest way to see what changed.

Every LTE specification has an NR counterpart with the same last three digits: 36.211 and 38.211 both describe physical channels, 36.213 and 38.213 both describe control procedures, and so on. Reading them in pairs is the fastest way to see what changed, because the paragraphs that differ are exactly the design changes this chapter is about. The figure sets the pairs side by side with the constants that became parameters, and ends with the arrangement in which both radios run at once.

![[99 Attachments/5G/Protocol Figures/STAR-04-LTE-An-Overview-Protocol.png|The LTE specifications paired with their NR counterparts, and the constants that became parameters]]

*Protocol figure: The LTE specifications paired with their NR counterparts, and the constants that became parameters.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| LTE overall architecture | [TS 36.300 V18.8.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/36_series/36.300/36300-i80.zip) | The LTE twin of TS 38.300; still maintained in Release 18. |
| LTE physical channels | [TS 36.211 V18.0.2, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/36_series/36.211/36211-i02.zip) | The fixed 15 kHz, 1 ms grid and the cell-specific reference signal. |
| LTE coding | [TS 36.212 V18.1.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/36_series/36.212/36212-i10.zip) | Turbo coding, which NR replaced with LDPC and Polar codes. |
| LTE procedures | [TS 36.213 V18.3.0, clauses 7–8](https://www.3gpp.org/ftp/Specs/archive/36_series/36.213/36213-i30.zip) | Scheduling and HARQ timing as fixed values, which NR made signalled. |

!note[**When you build or run a demo.** The first 5G most people ran was non-standalone: an LTE base station anchoring the connection and an NR carrier alongside for data, defined in TS 37.340 as option 3. A demo of that arrangement needs both stacks configured, and the LTE side uses its own frequency numbering — the EARFCN of TS 36.101 clause 5.7.3, which converts to a frequency by a formula that is the ancestor of NR's ARFCN. If you ever wonder why a phone shows "5G" while its signalling runs over LTE, that is the arrangement, and TS 37.340 clause 4.1 is where it is drawn. A standalone NR demo, by contrast, needs no LTE at all, and its configuration file will not contain a single 36-series parameter.]

LTE Release 8 established the basic scheduled radio; later LTE releases added carrier aggregation, enhanced MIMO, dual connectivity, machine-type features, and coexistence mechanisms; and Release 18 still maintains the LTE specifications and their interworking with NR. The historical comparison is therefore LTE Release 8 → LTE-Advanced → NR Release 15 and 16 → Release 18 coexistence. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The specifications above give the numbers; this trace uses a few of them in one calculation that you can redo by hand.

**Worked numerical example.**

Estimate the nominal subcarrier span of fifty LTE resource blocks. This is a grid calculation.

**What we are working out.** Nominal occupied subcarrier span of a 50-PRB LTE allocation, in megahertz, measured at the resource-grid.

$$
\begin{aligned}
B_{grid} &= N_{PRB}N_{sc}\Delta f \\ &= (50)(12)(15\ \mathrm{kHz}) \\ &= 9.00\ \mathrm{MHz}
\end{aligned}
$$

Where:

- $B_{grid}$ = 9.00 MHz, calculated (local resource count); it belongs to the scheduled subcarrier grid.
- $N_{PRB}$ = 50 PRB, assumed (illustrative allocation); it belongs to the scheduler allocation.
- $N_{sc}$ = 12 subcarriers/PRB, reported (TS 36.211 clause 6); it belongs to the LTE PRB.
- $\Delta f$ = 15 kHz, reported (TS 36.211 clause 6); it belongs to the LTE subcarrier grid.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $B_{grid}$ | 9.00 MHz | calculated | local resource count | scheduled subcarrier grid |
| $N_{PRB}$ | 50 PRB | assumed | illustrative allocation | scheduler allocation |
| $N_{sc}$ | 12 subcarriers/PRB | reported | TS 36.211 clause 6 | LTE PRB |
| $\Delta f$ | 15 kHz | reported | TS 36.211 clause 6 | LTE subcarrier grid |

PRB is a count, so the product has units of kilohertz. The standardized value twelve counts subcarriers per PRB; it is not a fitting constant. Dividing 9000 kHz by 1000 kHz/MHz gives 9.00 MHz. Guard bands, reference/control occupancy, coding, and scheduling frequency remain outside this span.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. Course alignment and common confusions

The trace closed the technical part. This section says where the chapter sits in the Saar course, then lists the sentences students most often get wrong about LTE.

**Course alignment.** This note supports U03–U05 as the comparison baseline for NR structure and U09–U10 for acquisition/access continuity. Use it to name the inherited abstraction before studying the NR redesign. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

!warning[**“SC-FDMA is not OFDM”.**

LTE uplink applies DFT spreading before OFDM modulation; it remains an OFDM-family waveform with a different envelope property. The fix is to name the waveform family before contrasting envelope properties.]

!warning[**“A PRB is user payload”.**

A PRB is resource geometry. Signals, control, coding, and scheduling determine payload. The fix is to separate resource geometry from the payload it can be made to carry.]

!warning[**“MIMO layers equal antennas”.**

Layers are data streams; antenna ports and physical antennas describe different objects. The fix is to keep layers, antenna ports, and physical antennas as three distinct objects.]

!warning[**“HARQ guarantees delivery”.**

HARQ improves reliability within limits. Repeated failure still reaches higher-layer handling. The fix is to state the retry limit before treating retransmission as a guarantee.]

!warning[**“NR discarded LTE”.**

NR retains major abstractions while redesigning fixed timing, signals, control, and beam use. The fix is to say which abstraction was kept and which was redesigned.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 4, pp. 39–56, 2021, DOI [chapter 4](https://doi.org/10.1016/B978-0-12-822320-8.00004-0).
2. Chapter 4 notes of this knowledge base (the author's reading notes).
4. 3GPP, *TS 36.300 V18.8.0, clauses 4–6*, [LTE overall architecture](https://www.3gpp.org/ftp/Specs/archive/36_series/36.300/36300-i80.zip).
5. 3GPP, *TS 36.211 V18.0.2, clauses 5–6*, [LTE physical channels](https://www.3gpp.org/ftp/Specs/archive/36_series/36.211/36211-i02.zip).
6. 3GPP, *TS 36.212 V18.1.0, clauses 5–6*, [LTE coding](https://www.3gpp.org/ftp/Specs/archive/36_series/36.212/36212-i10.zip).
7. 3GPP, *TS 36.213 V18.3.0, clauses 7–8*, [LTE procedures](https://www.3gpp.org/ftp/Specs/archive/36_series/36.213/36213-i30.zip).
8. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
9. ShareTechnote, [LTE handbook](https://www.sharetechnote.com/html/Handbook_LTE.html), accessed 2026-08-03.
10. Saar University 5G course alignment.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| LTE | Long Term Evolution | Section 1; fixed specification set in Section 6 |
| E-UTRA | Evolved Universal Terrestrial Radio Access | Section 1; fixed specification set in Section 6 |
| E-UTRAN | Evolved Universal Terrestrial Radio Access Network | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| eNB | evolved NodeB | Section 1; fixed specification set in Section 6 |
| OFDMA | Orthogonal Frequency Division Multiple Access | Section 1; fixed specification set in Section 6 |
| SC-FDMA | Single-Carrier Frequency Division Multiple Access | Section 1; fixed specification set in Section 6 |
| MIMO | Multiple-Input Multiple-Output | Section 1; fixed specification set in Section 6 |
| HARQ | Hybrid Automatic Repeat Request | Section 1; fixed specification set in Section 6 |
| FDD | Frequency Division Duplex | Section 1; fixed specification set in Section 6 |
| TDD | Time Division Duplex | Section 1; fixed specification set in Section 6 |
| CA | Carrier Aggregation | Section 1; fixed specification set in Section 6 |
| NR | New Radio | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $B_{grid}$ | Nominal grid span | MHz |
| $N_{PRB}$ | Allocated physical resource blocks | count |
| $N_{sc}$ | Subcarriers per PRB | subcarriers/PRB |
| $\Delta f$ | Subcarrier spacing | kHz |

The symbols mean what they mean in this note; another note may use the same letter for something else.
