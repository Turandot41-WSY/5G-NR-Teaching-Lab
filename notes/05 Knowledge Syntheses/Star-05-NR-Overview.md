---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 5
title: NR Overview
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-05 — NR Overview

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

An LTE base station behaves like a lighthouse. Whether or not any ship is at sea, it sweeps its reference signals across every subframe, broadcasts its system information over the whole carrier, and sends its synchronisation signals every five milliseconds. That constant light let any phone estimate the channel at any moment, which was convenient. It also meant that an empty cell radiated all night, wasted energy, and shone into its neighbour's cell as interference.

NR behaves like a torch. It transmits the minimum needed to be found — a synchronisation block every twenty milliseconds by default, swept beam by beam — and everything else only when someone needs it. Reference signals travel inside the transmissions that carry data. System information beyond the minimum is fetched on request. An idle NR cell is nearly silent.

![[99 Attachments/5G/Concept Figures/STAR-05-NR-Overview-Concept.png|LTE and NR compared as a lighthouse and a torch]]

*Concept figure: LTE and NR compared as a lighthouse and a torch.*

This one decision — the textbook calls it ultra-lean design — is the root from which the rest of the chapter grows. If nothing is always on, nothing fixes the grid, so the subcarrier spacing can vary with the band. If nothing a phone must hear spans the whole carrier, the phone can sit in a narrow slice of it, which is the bandwidth part. If there are no cell-wide signals, every signal can be pointed at the device that needs it, which is beam-centric operation. And if resources are empty by default, some can be reserved for features nobody has invented yet, which is forward compatibility. The chapter presents these as a list of principles; read them as consequences of the torch.

The chapter then walks through the Release 15 design — waveform, frame structure, duplex, latency, scheduling, control, beams, initial access, and coexistence with LTE — and closes with the Release 16 additions that carried the same radio into industry, vehicles, unlicensed spectrum, relays, and positioning. Almost every later note in this course is a zoom into one item of that walk.

**The question this chapter answers.** Where does New Radio fit, and which design choices make it different from LTE?

!important[**The short answer.** NR is a configurable radio interface between the device and NG-RAN. Its flexible numerology, bandwidth parts, beam-centric operation, and lean reference-signal design let one framework serve very different spectrum and latency conditions.]

Names you will meet in this note: New Radio (NR), Next Generation Radio Access Network (NG-RAN), standalone (SA), non-standalone (NSA), subcarrier spacing (SCS), bandwidth part (BWP), synchronisation signal block (SSB), demodulation reference signal (DM-RS), channel state information reference signal (CSI-RS), control resource set (CORESET), Low-Density Parity-Check code (LDPC), transmission reception point (TRP), Integrated Access and Backhaul (IAB), listen before talk (LBT).

## 2. Where you are in 5G

Section 1 contrasted the lighthouse with the torch. The map below shows how much of the 5G system that one design decision touches: nearly every box in the radio.

![[99 Attachments/5G/Locator Maps/STAR-05-Where-You-Are-in-5G.png|Where Star 05 sits in the whole 5G system]]

*Locator: Where Star 5 sits in the whole 5G system.*

This chapter lights the device, the radio, and the link between them. It is the overview: the one note that touches every band of the map without going deep into any. The course index recommends starting here, and then taking the four heavy specifications — TS 38.300, 38.211, 38.331, and 38.401 — before returning to the book chapters in order.

The Knowledge Structure Map presents NR's six design principles, each paired with the limitation in LTE that motivated it. The mechanism diagram shows the same five configuration knobs set three different ways — a rural macro cell, an urban capacity layer, a millimetre-wave hotspot — to make the word "flexible" concrete.

![[99 Attachments/5G/Knowledge Maps/STAR-05-NR-Overview-Knowledge Structure Map.png|STAR-05 system-position map]]

*Knowledge map: The six NR design principles and the problem each one solves.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-05-NR-Flexibility-Chain.png|NR flexibility chain: carrier, BWP, numerology, control, beams, and access]]

*Mechanism: One NR framework configured for three different deployments.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: LTE comparison → Release 15 design principles → waveform and frame flexibility → control, beams, and access → Release 16/17 evolution.


## 3. The textbook road

Section 2 lit most of the radio boxes at once. The road below walks through the overview chapter in the book's order: the comparison with 4G, the Release 15 design, then what Release 16 added.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 Comparison with 4G

The road starts with the book's long comparison table. This section reads it for you and shows that the differences cluster in three places.

The table is long, but the differences cluster in three places: flexibility (numerology, scheduling interval, control region, bandwidth), beams (from optional to central), and the removal of always-on signals. Everything else — the waveform, the shared channel, the retransmission scheme — is inherited.

| Aspect | LTE (4G) | NR (5G) |
| --- | --- | --- |
| Standardization Start | 3GPP Rel-8 (2008) | 3GPP Rel-15 (2016 Study → 2018 spec release) |
| Core Network | Evolved Packet Core (EPC) | 5G Core Network (5GC) or EPC (non-SA mode) |
| Deployment Mode | Standalone LTE only | **Standalone (SA) and Non-Standalone (NSA)** |
| Target Use Cases | eMBB (broadband only) | eMBB + URLLC + mMTC |
| Spectrum Range | \< 6 GHz (≤ 20 MHz BW) | 0.4–52.6 GHz (≤ 400 MHz BW; Rel-17 \> 52 GHz) |
| Duplex Modes | FDD / TDD (separate frame structures) | Unified FDD & TDD structure + Dynamic TDD |
| Numerology | Fixed 15 kHz SCS | Flexible 15–240 kHz SCS (μ = 0–4) |
| Latency | ≈ 10–20 ms | \< 1 ms (URLLC support) |
| Waveform | OFDM (DL) + DFT-s-OFDM (UL) | OFDM both DL & UL + optional DFT-s-OFDM (UL) |
| Reference Signals | Always-on Cell-specific RS (CRS, CSI-RS) | On-demand DMRS & CSI-RS → Ultra-Lean |
| MIMO Capability | Up to 8×8 DL / 4×4 UL | Massive MIMO (Up to 8 DL / 4 UL layers Rel-15; Multi-TRP Rel-16) |
| Beamforming | Optional digital only | **Full beam-centric (analog + hybrid + digital)** |
| Scheduling | Dynamic per TTI (1 ms) | Flexible slot or mini-slot (\< 1 ms) |
| Control Channel | Fixed control region (1–3 OFDM symbols) | Configurable CORESET + beamformed PDCCH |
| Forward Compatibility | Limited (Release tied) | Reserved resources + blank symbols for future use |
| Energy Efficiency | Always-on signals → wasteful | **Ultra-Lean Design minimizes idle transmission** |

The two deployment modes deserve their own table, because they determine what a demo needs. In non-standalone mode an LTE cell carries the signalling and an NR carrier adds data; in standalone mode NR does everything against a 5G core.

| Mode | Full Name | Architecture | Control Plane | User Plane |
| --- | --- | --- | --- | --- |
| **NSA (Non-Standalone)** | NR depends on LTE | LTE + 5G NR jointly used | LTE (EPC) handles signaling, mobility, paging | 5G NR carries user data |
| **SA (Standalone)** | NR only (true 5G) | Pure 5G NR + 5G Core (5GC) | NR gNB + 5GC handle all functions | NR for both signaling and data |

*Table continued — panel 2 of 2.*

| Mode | Example Scenario |
| --- | --- |
| **NSA (Non-Standalone)** | Operator upgrades LTE eNBs with NR carriers for higher data rate (“boost pipe”) |
| **SA (Standalone)** | New 5G network with its own core (e.g., private 5G campus network) |

### 3.2 NR Release 15

The three clusters of Section 3.1 all belong to Release 15. This section says what Release 15 is: the first complete NR, which everything later extends.

Release 15, frozen in 2018, is the first complete NR: everything a device and a base station need to find each other, connect, and carry data, in both standalone and non-standalone form. Everything in later releases extends it; nothing replaces it. The principles that follow are Release 15's, and the Release 16 section later in the chapter is best read as "what was added on top".

### 3.3 Core Design Principles in NR Release 15

Release 15 was built on principles before features. This section names the three that the book states; the torch of Section 1 is one of them.

!important[The textbook names three principles. Operation at higher frequencies: from below 1 GHz to 52.6 GHz in Release 15, with carriers up to 400 MHz wide and beamforming to make up for the path loss. Ultra-lean design: no always-on signals, so that an idle cell costs little energy and causes little interference, and dense deployments stay clean. Forward compatibility: time–frequency resources kept configurable, so that later features can be added without breaking devices already in the field.]

#### 3.3.1 Ultra-Lean Design — Detailed Explanation

| Concept | LTE Approach | 5G NR Ultra-Lean Approach |
| --- | --- | --- |
| **Always-On Signals** | Cell-specific RS (CRS) always transmitted for channel estimation and mobility | No cell-specific RS; **only user-specific DMRS/CSI-RS when data exist** |
| **System Broadcast** | System Information Blocks (SIBs) broadcast **periodically on entire bandwidth** | Minimal System Info in PBCH + **on-demand retrieval of remaining SIBs** |
| **Synchronization Signals** | PSS/SSS every 5 ms | **SSB (Sync Signal Block) every 20 ms (default) + beam sweeping** |
| **Impact on Energy** | Idle cells transmit ≈ constant power | Idle cells → minimal transmission → improved energy efficiency |
| **Impact on Interference** | Inter-cell reference interference persistent | DMRS/CSI-RS localized to scheduled UEs → lower interference |
| **Implementation Example** | CRS pattern (4 RE per RB per OFDM symbol) | Dynamic DMRS mapping (UE-specific precoding reference) |

The results are higher network energy efficiency, better spectral reuse where cells are dense, and — less obviously — the precondition for beam-centric operation and dynamic TDD, neither of which is possible while a cell-wide signal has to be on the air in every subframe.

> [!book] Book expansion
> The textbook presents high-frequency operation, ultra-lean transmission, and forward compatibility as coupled choices: flexible resources are valuable only if persistent signals do not occupy them permanently. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 5, pp. 57–78, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00005-2).

> [!spec] 3GPP reality check
> The system role is summarised in [TS 38.300 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip); the transmitted time–frequency structure is fixed separately by TS 38.211, and the synchronisation-block periodicities that make ultra-lean concrete are in TS 38.213 clause 4.1.

External source: [TS 38.300 V18.10.0, clause 4.1, PDF page 24](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip). The reproduced image is omitted from this distribution.

*Source excerpt: 3GPP TS 38.300 V18.10.0, clause 4.1, PDF p. 24, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip), accessed 2026-08-04. Retained for course review.*

> [!engineering] ShareTechnote engineering view
> The [NR numerology page](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html) is useful for seeing how one frame contains shorter slots as subcarrier spacing increases.

External source: [Definition of numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html). The reproduced image is omitted from this distribution.

*Source excerpt: ShareTechnote, [5G/NR Numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html), “Definition of Numerology,” accessed 2026-08-04.*

### 3.4 5.1.4 Transmission Scheme, Bandwidth Parts & Frame Structure

The principles are abstract; the waveform is where they first become concrete. This section describes the transmission scheme, the bandwidth parts and the frame structure that the lean design allows.

The waveform is OFDM in both directions, with DFT-precoded OFDM as an uplink option for devices that need a lower peak-to-average ratio. The subcarrier spacing scales from 15 to 240 kHz. A bandwidth part lets a device listen to only a portion of the carrier, which saves power. The frame is 10 ms of ten 1 ms subframes; each slot holds 14 symbols, so the slot shrinks as the spacing grows; and a transmission may occupy only part of a slot, which is what serves low latency and listen-before-talk. Figure 5.2 shows the two frequency ranges with their spacings; Figure 5.3 shows the slot durations and a mini-slot not aligned to a slot boundary.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.2 shows the two frequency ranges with their spacings; Figure 5.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.2 shows the two frequency ranges with their spacings; Figure 5.*

> [!book] Book expansion
> A bandwidth part is an operating window within a wider carrier. It lets the scheduler keep a capable device on a narrow active bandwidth until traffic or measurement needs justify a switch. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 5, pp. 57–78, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00005-2).

> [!spec] 3GPP reality check
> Subcarrier spacing, frames, slots, and resource grids are defined by [TS 38.211 V18.9.0, clauses 4.2–4.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); bandwidth-part procedures are in TS 38.213 V18.8.0, clause 12, and configured by RRC.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [bandwidth-part walkthrough](https://www.sharetechnote.com/html/5G/5G_CarrrierBandwidthPart.html) gives a practical view of carrier bandwidth, configured parts, and the currently active one.

### 3.5 5.1.5 Duplex Schemes (Fig. 5.4 – Spectrum vs Duplex Mode)

Section 3.4 fixed the grid. This section asks which direction each part of the grid serves, and why one frame structure works for both FDD and TDD.

FDD serves the paired bands below about 3 GHz and TDD the unpaired bands above, and NR uses one frame structure for both. In TDD the direction can change slot by slot — dynamic TDD — which lets a small cell follow rapid changes in traffic, while a macro cell may keep a static pattern to limit interference with neighbours. Figure 5.4 shows spectrum against duplex mode.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.4 shows spectrum against duplex mode.*

### 3.6 5.1.6 Low-Latency Support

With the grid and the duplex mode set, this section shows the four mechanisms that make a transmission across that grid fast.

!important[Four mechanisms shorten the same path. Reference signals and control are placed at the front of a transmission, so decoding can begin at once. Mini-slots let a transmission start without waiting for the next slot boundary. HARQ feedback can return within a slot. And the MAC and RLC layers were reworked for faster processing. Star 20 shows the resulting budget.]

### 3.7 5.1.7 Scheduling and Data Transmission

Low latency needs a scheduler that can act quickly. This section describes how scheduling, coding and retransmission were tightened compared with LTE.

Scheduling is channel-dependent and dynamic, as in LTE, but at finer granularity. Data is coded with LDPC, which is cheaper to decode than Turbo codes at high rates. HARQ uses incremental redundancy, and can retransmit a group of code blocks rather than a whole transport block. And the uplink can be transmitted on a configured grant without waiting for a request, which removes a round trip for latency-critical traffic.

### 3.8 5.1.8 Control Channels

A scheduler's decisions travel over control channels. This section shows where NR put them and why they can be beamformed.

The downlink control channel lives in a configurable control resource set rather than LTE's fixed first symbols, so it can occupy part of the bandwidth and can be beamformed. The uplink control channel has several formats for fast acknowledgement and channel-state feedback. Control blocks use Polar and Reed–Muller codes, which suit short blocks better than LDPC.

### 3.9 5.1.9 Beam-Centric Design & Multi-Antenna Transmission

Control channels that can be beamformed presume beams. This section makes beams central: how NR forms them, measures them and follows them.

Figure 5.5 shows narrow beams swept across several directions. NR supports massive and full-dimension MIMO with analogue, digital, and hybrid beamforming; channel state can come from downlink reference signals or, in TDD, from uplink sounding via reciprocity. Release 15 allows up to eight downlink and four uplink layers per device; Release 16 adds transmission from multiple points. A phase-tracking reference signal handles the phase noise that becomes significant at high frequencies.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.5 shows narrow beams swept across several directions.*

### 3.10 5.1.10 Initial Access

Beams leave a problem open: how does a device find a cell whose transmissions are narrow? This section answers with the synchronisation block and the sparser raster.

!note[A device finds a cell through the synchronisation signal block — primary and secondary synchronisation signals plus the broadcast channel — transmitted every 20 ms by default rather than LTE's 5 ms, on a sparser frequency raster to shorten the search. Because coverage above 6 GHz is a set of directions, the block is swept beam by beam, and random access is swept the same way. Figure 5.6, though placed here, shows LTE/NR coexistence and belongs with Section 3.11.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.6, though placed here, shows LTE/NR coexistence and belongs with Section 3.*

> [!book] Book expansion
> Initial access is a dependency chain: detect a block, obtain minimum system information, locate the configured random-access resource, and only then request a scheduled context. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 5, pp. 57–78, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00005-2).

> [!spec] 3GPP reality check
> SS/PBCH transmission is in TS 38.211 V18.9.0, clause 7.4.3; cell-search and random-access procedures are in [TS 38.213 V18.8.0, clauses 4 and 8](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

> [!engineering] ShareTechnote engineering view
> The [cell-search page](https://www.sharetechnote.com/html/5G/5G_CellSearch.html) connects beam-swept block detection to the later access configuration.

### 3.11 5.1.11 Interworking and LTE Coexistence

A found cell is rarely alone; LTE is usually next door. This section explains how NR was designed to live alongside it.

NR was designed to arrive alongside LTE. It supports dual connectivity and carrier aggregation with LTE, a supplementary uplink on an LTE band, and shares the 15 kHz numerology so that the two can be deployed in the same spectrum. Reserved resources let NR avoid the positions LTE's always-on signals occupy.

### 3.12 NR Release 16

Sections 3.2 to 3.11 covered Release 15. This section opens Release 16, which carried the same radio into places it had not been designed for.

Release 16, frozen in 2020, carried the Release 15 radio into places it had not been designed for: factories, vehicles, unlicensed spectrum, wireless backhaul, and indoor positioning. It did so without revisiting the principles above, which is the best evidence that they were the right ones.

### 3.13 Evolution in Release 16 Highlights

The table below lists the Release 16 additions before the following sections take them one by one.

| Enhancement Area | Key Improvements |
| --- | --- |
| Multi-Antenna | New CSI codebooks + multi-TRP support for reliability |
| Carrier Aggregation | Faster activation and cross-numerology scheduling |
| Mobility | Conditional handover + Dual Active Protocol Stack (DAPS) |
| Power Saving | Wake-up signals + cross-slot scheduling + cell dormancy |
| Interference | CLI / RIM measurement and dynamic mitigation |
| Integrated Access & Backhaul (IAB) | Wireless backhaul for small cells |
| Unlicensed Spectrum | NR-U (standalone and license-assisted) |
| Verticals | ITS (V2X), Industrial IoT, URLLC enhancements |
| Positioning | PRS and SRS-based ranging for sub-meter accuracy |

> [!book] Book expansion
> The Release 16 list is not one protocol feature. Each item extends a different owner — physical layer, MAC, RRC, architecture, positioning, or sidelink — while preserving the Release 15 radio framework. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 5, pp. 57–78, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00005-2).

> [!spec] 3GPP reality check
> The frozen teaching baseline is TS 38.300 V18.10.0, clauses 4–6, plus the feature-owning specifications listed in Section 4; Release 18 corrections take precedence over the book-era wording.

> [!engineering] ShareTechnote engineering view
> The [Release 16 overview](https://www.sharetechnote.com/html/5G/5G_Release16.html) is an engineering index: use it to find each item before following it into its owning specification.

### 3.14 5.2.1 Multi-Antenna Enhancements

The first addition refines what Section 3.9 introduced: finer channel-state feedback, faster beam recovery and reception from two points at once.

New channel-state codebooks give the network finer feedback, beam recovery is faster, and a device can receive from two transmission points at once, which raises reliability for the traffic that needs it most.

### 3.15 5.2.2 Carrier Aggregation & Dual Connectivity Enhancements

Section 3.14 improved the antennas; this section improves how carriers are added and activated.

Secondary cells activate faster, so bursty traffic gets extra carriers sooner; a device can report early measurements from the inactive state; and one carrier can schedule another even when their numerologies differ.

### 3.16 5.2.3 Mobility Enhancements

More carriers and more beams make handover more frequent. This section shows the two additions that shorten the interruption.

Two additions reduce the interruption at handover. A dual active protocol stack keeps the old cell's connection alive until the new one works — make before break. Conditional handover lets the device execute a prepared handover on its own when a condition is met, without waiting for a command that might not get through.

### 3.17 5.2.4 Device Power Saving Enhancements

Everything above spends energy in the device. This section collects the Release 16 tools for saving it.

Cross-slot scheduling lets a device sleep between reading a grant and receiving the data it grants. Wake-up signals and dormant cell states let it skip monitoring entirely, and the device can suggest the settings that would save it the most.

### 3.18 5.2.5 Crosslink Interference (CLI) & Remote Interference Management (Fig. 5.7)

Section 3.5 mentioned that dynamic TDD lets a cell change direction slot by slot. This section shows the two interference problems that creates and the Release 16 tools for both.

Dynamic TDD created two interference problems, and Release 16 added the tools for both. Cross-link interference measurement detects a neighbour's downlink landing in this cell's uplink. Remote interference management handles the same effect over very long distances, when atmospheric ducting carries a base station's downlink hundreds of kilometres into another's uplink. Figure 5.7 shows both; Star 21 covers them in depth.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.7 shows both; Star 21 covers them in depth.*

### 3.19 5.2.6 Integrated Access and Backhaul (IAB) (Fig. 5.8)

Interference management assumes every base station has a wired backhaul. This section removes that assumption with integrated access and backhaul.

An IAB node is a base station without fibre: it serves its own devices and relays their traffic over an NR link to a parent node, and through it to a donor that does have fibre. Figure 5.8 shows a multi-hop chain.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.8 shows a multi-hop chain.*

#### 3.19.1 Problem it addresses

Every small cell needs two links: an access link to its devices, and a backhaul link to the core. Running fibre to every millimetre-wave small cell in a dense city — or to a temporary one at a stadium or a disaster site — is slow and expensive, and often the reason a site does not get built.

#### 3.19.2 IAB Solution

IAB lets the same NR radio carry both the access traffic and the backhaul traffic, so part of the spectrum becomes a wireless mesh between base stations. Because NR already split the base station into a central unit and distributed units, an IAB node is essentially a distributed unit whose link to the central unit happens to be wireless; very little new architecture was needed. Star 22 takes this up.

### 3.20 5.2.7 NR in Unlicensed Spectra (Fig. 5.9)

Sections 3.14 to 3.19 stayed in licensed spectrum. This section takes NR into the unlicensed 5 and 6 GHz bands, where the medium has to be shared.

NR can run in the 5 and 6 GHz unlicensed bands, either assisted by a licensed carrier or standalone, using listen-before-talk to share fairly with Wi-Fi. Figure 5.9 shows the arrangement; Star 19 covers the channel-access procedure.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.9 shows the arrangement; Star 19 covers the channel-access procedure.*

#### 3.20.1 5.2.8 Intelligent Transportation Systems (V2X) (Fig. 5.10)

Vehicles need to talk to each other directly, with or without a network in range, and the uplink cannot do that. The NR sidelink provides it, with unicast, groupcast, and broadcast, and with the device choosing its own resources when out of coverage. Figure 5.10 shows the cases; Star 23 covers the mechanism.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.10 shows the cases; Star 23 covers the mechanism.*

### 3.21 5.2.9 Industrial IoT and URLLC Enhancements

Unlicensed operation serves best-effort traffic; factories need the opposite. This section lists the Release 16 additions for bounded latency under load.

Factory automation, smart grids, and remote driving need bounded latency under load. Release 16 added support for time-sensitive networking, uplink pre-emption so an urgent transmission can interrupt an ordinary one, and power boosting for high-priority flows. Star 20 covers the budget.

### 3.22 5.2.10 Positioning (Fig. 5.11)

The last Release 16 addition uses the radio for something other than communication: knowing where the device is.

A downlink positioning reference signal gives the device times of arrival from several cells; an extended uplink sounding signal gives the network angles and times of arrival from the device. Combined, they reach sub-metre accuracy indoors, where satellite positioning fails. Figure 5.11 shows the signals; Star 24 covers the methods.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 5.11 shows the signals; Star 24 covers the methods.*

## 4. The 3GPP protocol: which document, and what it says

The road ended with the Release 16 features. This section names the specification that introduces every other document in the 38 series, TS 38.300, and says what to open next.

TS 38.300 is the map of the whole radio: it introduces every other document in the 38 series and is the right place to start reading. It carries few numbers of its own, but the documents it points to carry the ones that turn this chapter's principles into facts — the synchronisation-block periods that make ultra-lean concrete, the number of beams a burst may sweep, the mini-slot lengths that make low latency possible, and the limit of four bandwidth parts with one active. The figure lays them out with the configuration lines they become.

![[99 Attachments/5G/Protocol Figures/STAR-05-NR-Overview-Protocol.png|The overview specification's clauses and the numbers that make NR's design principles concrete]]

*Protocol figure: The overview specification's clauses and the numbers that make NR's design principles concrete.*

| Behavior | Owner | Trigger/input | Frozen Rel-18 locator | Book-era → Rel-18 note |
| --- | --- | --- | --- | --- |
| NR/NG-RAN role | UE and NG-RAN | service and deployment configuration | TS 38.300 V18.10.0, clauses 4–6 | Rel-18 consolidates later architecture and feature corrections |
| Numerology and grid | UE and gNB PHY | carrier/BWP configuration | TS 38.211 V18.9.0, clauses 4.2–4.4 | same scalable grid principle, later additions and corrections |
| Bandwidth-part operation | UE and gNB | RRC configuration plus control procedure | TS 38.213 V18.8.0, clause 12 | expanded power-saving and switching behavior |
| Initial access | UE and gNB | SS/PBCH detection and access configuration | TS 38.211 V18.9.0, clause 7.4.3; TS 38.213 V18.8.0, clauses 4 and 8 | two-step access and later feature interactions are included |

!note[**When you build or run a demo.** The first ten lines of an open-source gNB configuration are this chapter. The synchronisation-block period is the ultra-lean principle as a number, and TS 38.331 names it ssb-periodicityServingCell. Which beams of the burst are actually transmitted is ssb-PositionsInBurst, and the maximum is set per band in TS 38.213 clause 4.1. The subcarrier spacing is TS 38.211 clause 4.2. The initial bandwidth part and up to three more are TS 38.331's BWP-Downlink, with exactly one active. The TDD pattern is TS 38.213 clause 11.1. A standalone demo also needs a 5G core; a non-standalone one needs an LTE anchor instead, and the difference between those two files is the difference between the two rows of the deployment-mode table above.]

The table is a navigation layer; the cited clauses hold the rules. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents above define the pieces. The trace below strings them together in the order a device meets them.

> [!note] End-to-end trace
> LTE comparison → Release 15 design principles → waveform and frame flexibility → control, beams, and access → Release 16/17 evolution.

Read each arrow as a handoff from one step to the next. Configuration constrains the available choices; the transmitter acts; the receiver measures or decodes; the result enables the next scheduled step.

## 6. Course alignment and common confusions

The trace closed the chapter's technical part. This section places it in the course and lists the three sentences students most often get wrong about NR.

**Course alignment.** U03–U05: use this chapter as the NR system overview before the resource-grid, coding, scheduling, and interference units.

!warning[**Flexible does not mean arbitrary.** The network chooses among standardized numerologies, bandwidth parts, and patterns; a UE does not invent its own grid.]

!warning[**Ultra-lean does not mean signal-free.** NR still needs synchronization, broadcast, reference, and control signals. It reduces persistent cell-wide transmission and makes many signals configurable or demand-driven.]

!warning[**Release evolution is cumulative.** A Release 18 implementation includes corrections and extensions beyond the book's Release 15/16 narrative. The exact supported feature set still depends on UE and network capability signaling.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 5, pp. 57–78, DOI [10.1016/B978-0-12-822320-8.00005-2](https://doi.org/10.1016/B978-0-12-822320-8.00005-2).
2. 3GPP, *TS 38.300 V18.10.0: NR; NR and NG-RAN Overall Description*, clauses 4–6, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
3. 3GPP, *TS 38.211 V18.9.0: NR; Physical Channels and Modulation*, clauses 4–7, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
4. 3GPP, *TS 38.212 V18.8.0: NR; Multiplexing and Channel Coding*, clauses 5–7, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
5. 3GPP, *TS 38.213 V18.8.0: NR; Physical Layer Procedures for Control*, clause 12, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
6. 3GPP, *TS 22.261 V18.19.0: Service Requirements for the 5G System*, clause 6, [official archive](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip).
7. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18), accessed 2026-08-03.
8. ShareTechnote, [Numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html), [Bandwidth Part](https://www.sharetechnote.com/html/5G/5G_CarrrierBandwidthPart.html), and [Frame Structure](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html), accessed 2026-08-03.
9. Chapter 5 notes of this knowledge base (the author's reading notes, dated 2026-08-03).

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | Primary clause |
| --- | --- | --- |
| 5GC | 5G Core network | TS 23.501 V18.12.0, clause 4 |
| BWP | Bandwidth part | TS 38.211 V18.9.0, clause 4.4.5 |
| CSI-RS | Channel state information reference signal | TS 38.211 V18.9.0, clause 7.4.1.5 |
| DM-RS | Demodulation reference signal | TS 38.211 V18.9.0, clauses 6.4.1 and 7.4.1 |
| NG-RAN | Next Generation Radio Access Network | TS 38.300 V18.10.0, clause 4 |
| NR | New Radio | TS 38.300 V18.10.0, clause 4 |
| PRB | Physical resource block | TS 38.211 V18.9.0, clause 4.4.4.1 |
| SA | Standalone | TS 23.501 V18.12.0, clause 4.2 |
| SCS | Subcarrier spacing | TS 38.211 V18.9.0, clause 4.2 |
| SSB | Synchronization signal and PBCH block | TS 38.211 V18.9.0, clause 7.4.3 |
| UE | User equipment | TS 38.300 V18.10.0, clause 4 |
| URLLC | Ultra-reliable and low-latency communications | TS 22.261 V18.19.0, clause 6.7 |

The controlled explanations and cross-note usage are in [[5G Abbreviation Database]].

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $\Delta f$ | Subcarrier spacing | kHz or Hz |
| $\mu$ | NR numerology index | Non-negative integer allowed by context |
| $T_u$ | Useful OFDM symbol duration, excluding cyclic prefix | seconds |
| $T_{slot}$ | Nominal slot duration for the stated numerology | milliseconds |
| $N_{PRB}$ | Number of physical resource blocks | count |
| $B_{occ}$ | Calculated subcarrier span, excluding guards | Hz |
| $T_{4sym}$ | Approximate duration of four symbols in the worked example | milliseconds |
