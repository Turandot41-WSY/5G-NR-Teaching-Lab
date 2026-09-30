---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 12
title: Beam Management
language: en
course_units:
- U06
- U07
- U08
release_baseline: 18
---

# STAR-12 — Beam Management

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Imagine finding one person in a dark stadium with a torch. Above 6 GHz a cell is not a floodlight; it is a torch, and every procedure in this chapter is a step in the story of pointing it, narrowing it, and reacting when someone walks behind a pillar.

![[99 Attachments/5G/Concept Figures/STAR-12-Beam-Management-Concept.png|Beam management told as finding someone in a dark stadium with a torch]]

*Concept figure: Beam management told as finding someone in a dark stadium with a torch.*

First, sweep. The torch sweeps the whole stand in a fixed pattern, and whoever is looking shouts back which sweep lit them. That is initial access: the burst of synchronisation blocks, one per direction, and the phone reporting the best one. Then narrow: aim a tighter torch at that patch of seats, try a few neighbouring angles, and ask again which was brightest — the network refining its transmit beam. Then the person turns to face you: keep the torch still while they turn their head to find the angle that sees it best — the phone refining its receive beam, while the network learns nothing at all. And then the pillar. They step behind one and the light is gone. They do not panic at the first flicker; a hand, a bus, a turn of the wrist all block a millimetre-wave beam for a few milliseconds, and recovering on every flicker would mean recovering constantly and carrying nothing. So they count. When the count is reached they look for any other torch above a threshold, and shout on a channel reserved for exactly this.

Two things about the story are not obvious. Nobody ever says "beam seven". The network says "receive this channel the way you received that reference signal", and the beam is inherited from a signal the phone already measured; that is a TCI state. And the whole thing is not a feature layered on top of the radio. At millimetre wave the array gain *is* the link budget — lose the beam and you lose thirty decibels, so keeping the torch pointed is the precondition for the radio working at all, and it runs continuously for as long as the connection lasts.

**The question this chapter answers.** How do a base station and a device discover a usable directional link, refine it for scheduled channels, keep it aligned as conditions change, and recover when the active beam becomes unreliable?

!important[**The short answer.** NR beam management is a repeated loop of beam sweeping, measurement, reporting or selection, activation, tracking, failure detection, candidate-beam search, and recovery. During initial access the device measures synchronisation-block candidates and selects a cell and a block-associated random-access occasion. After connection, configured CSI-RS and SRS resources provide finer or task-specific observations. The network uses reports and measurements to choose the spatial assumptions for every channel and reference signal.]

Names you will meet in this note: synchronisation signal block (SSB), transmission configuration indication (TCI), quasi co-location (QCL), Layer-1 reference-signal received power (L1-RSRP), beam failure detection and recovery (BFD, BFR), beam failure instance (BFI), Physical Random-Access Channel (PRACH), transmission reception point (TRP), control resource set (CORESET), spatial filter.

## 2. Where you are in 5G

Section 1 pointed a torch at one person in a dark stadium. The map below shows where beam management sits in 5G: on top of the sounding of Star 08 and the antennas of Star 11, feeding every transmission above 6 GHz.

![[99 Attachments/5G/Locator Maps/STAR-12-Where-You-Are-in-5G.png|Where Star 12 sits in the whole 5G system]]

*Locator: Where Star 12 sits in the whole 5G system.*

This chapter lights beam management in the procedures band and antennas in the foundations. It runs on the arrays of Star 11, the measurements of Star 08, and the synchronisation blocks of Star 16; its failure-recovery request reuses the random access of Star 17; and the millimetre-wave hardware that makes it necessary is Star 26.

The Knowledge Structure Map draws coverage as a fan of directions with the serving beam lit, beside the three refinement procedures. The mechanism diagram draws beam failure as a timeline of a counter and a timer, with the recovery request and response.

![[99 Attachments/5G/Knowledge Maps/STAR-12-Beam-Management-Knowledge Structure Map.png|STAR-12 system-position map]]

*Knowledge map: Beam sweeping drawn as directions, with the three refinement procedures.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-12-Beam-Management-Loop.png|Star 12 mechanism and handoff diagram]]

*Mechanism: Beam failure detection and recovery as a counter and a timer.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Content → Initial Beam Establishment → Downlink Transmitter-Side Beam Adjustment → Downlink Receiver-Side Beam Adjustment → Uplink Beam Adjustment.


## 3. The textbook road

Section 2 placed beam management. The road below walks through the chapter in the book's order: establishing a beam, adjusting it on each side, indicating it, and recovering when it fails.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

The chapter covers the lifecycle of a beam pair — initial establishment, adjustment, and recovery — and closes with transmission from more than one point at once.

### 3.1 Content

The road begins with the trade that defines the chapter: directivity buys range and costs alignment.

!important[Directivity buys range and costs alignment. A narrow beam reaches further than a wide one for the same power, and points at a smaller patch of the world; if either end moves, or something moves between them, the patch is empty. Everything that follows manages that trade.]

> [!book] Book expansion
> Chapter 12 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 263–273, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00012-X)) is short because the machinery is elsewhere: the signals are Chapter 8, the arrays Chapter 11, and the access Chapter 16. This chapter is about the loop that ties them together.

> [!spec] 3GPP reality check
> The procedures are split: beam failure detection is [TS 38.321 V18.10.0, clause 5.17](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), recovery is TS 38.213 clause 6, reporting is TS 38.214 clause 5.2.1.4.2, and the naming of beams is TS 38.214 clause 5.1.5.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [beam management page](https://www.sharetechnote.com/html/5G/5G_Phy_BeamManagement.html) uses the P1, P2, P3 labels from the study report, which the specification never does; they are useful shorthand as long as you know they are not clause names.

### 3.2 **Initial Beam Establishment**

Section 3.1 stated the trade; this section makes the first beam, during initial access, before anything has been measured.

In initial access the "spatial filter" the textbook speaks of is the precoding — the beamforming weights applied to the array. The filter used for the random-access transmission is expected to be reused for the uplink transmissions that follow, so that the beam direction stays consistent from the first message onward. Figure 12.1 shows the sweep.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 12.1 shows the sweep.*

The control channel and the random-access channel often share a spatial filter, because they are quasi co-located through the same TCI state. The data channel may use a different one, configured by RRC, which gives the network freedom to point data more precisely than control.

> [!important] 💡
> > The “spatial filter” is the precoding scheme. The RACH and PDCCH can share the same precoding via TCI states, while PDSCH precoding is configured by the RRC layer.

> [!spec] 3GPP reality check
> The synchronisation burst and the number of blocks a cell may sweep — four, eight, or sixty-four by band — are [TS 38.213 V18.8.0, clause 4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); the link from a block to a random-access occasion is clause 8.1.

### 3.3 **Downlink Transmitter-Side Beam Adjustment**

The first beam is a guess. This section refines it on the network side: the phone measures several candidates and reports the best.

In transmitter-side adjustment the phone measures signal strength on several CSI-RS or synchronisation blocks, each representing a candidate downlink beam, and reports the best of them. Figure 12.2 shows the sweep of candidates.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 12.2 shows the sweep of candidates.*

A phone reports up to four reference signals in one report. The limit is not the phone's antennas; it is the report format and the signalling budget, which is why it is a fixed number in the specification rather than a capability.

> [!important] 💡
> The “four reference signals” limit arises from reporting design constraints (L1-RSRP report format and signaling capacity).

> [!spec] 3GPP reality check
> The report — up to four beams, one absolute received power in seven bits and the rest as four-bit differences — is [TS 38.214 V18.10.0, clause 5.2.1.4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).

### 3.4 **Downlink Receiver-Side Beam Adjustment**

Section 3.3 adjusted the transmit beam. This section holds it still and lets the phone adjust its own receive beam.

Receiver-side adjustment optimises the phone's own receive beam while the network holds its transmit beam still. Figure 12.3 shows it. The repetition flag in the reference-signal resource set is what tells the phone that all the signals in the set were transmitted with the same spatial filter, so that any difference it measures is due to its own receive beam and nothing else.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 12.3 shows it.*

> [!important] 💡
> The beam indication tells the UE which beam is used for transmission (via TCI), whereas the repetition flag ensures that a set of reference signals were transmitted with the same beam (for receiver-side measurement stability).

### 3.5 **Uplink Beam Adjustment**

Sections 3.3 and 3.4 were downlink. This section mirrors them for the uplink, with the roles swapped.

Uplink adjustment mirrors the downlink with the roles swapped: the base station evaluates the phone's transmit beams from the sounding reference signals it sends, and either reports the results or configures refinement. Downlink receiver-side adjustment is phone-driven; uplink adjustment is network-driven, from SRS.

> [!important] 💡
> Downlink receiver-side adjustment is UE-driven (UE refines its receive beam),
> **Uplink beam adjustment is network-driven**, using **SRS feedback** from the UE to **select the best uplink transmit beam.**

### 3.6 **Beam Indication and TCI**

The adjusted beams must be named so that a transmission can refer to one. This section explains the TCI state, which is how a beam is communicated.

!important[A beam is communicated as a TCI state, each of which links a reference signal — a CSI-RS or a synchronisation block — to a beam direction. A beam indication tells the phone which state, and therefore which beam, a control or data transmission uses. The repetition flag, by contrast, does not indicate a beam; it says that the signals in a set share one.]

> [!important] 💡
> Difference:
> - **Beam indication (TCI)** = identifies **which beam** is used for data/control.
> - **Repetition flag** = indicates **consistency of beam usage** within a measurement resource set.

#### 3.6.1 **L1-RSRP in Beam Management**

!note[Layer-one received power on a CSI-RS or synchronisation block is the measurement every beam decision rests on. It is fast and coarse on purpose: it ranks candidate beams in adjustment, it triggers failure detection when it drops below threshold, and it identifies replacements in recovery. A beam decision that arrives late is worthless, so the measurement is designed for speed over precision.]

> [!important] 💡
> Purpose: L1-RSRP provides the fundamental real-time measurement basis for beam quality evaluation and selection in both downlink and uplink procedures.

#### 3.6.2 **Beam Recovery and Multi-TRP Transmission**

Beam failure recovery restores connectivity through a new beam, using contention-free random access. It has four steps: the phone detects that the beam has failed; it identifies a candidate — a new beam pair — through which the link could be restored; it transmits a recovery request; and the network responds. The request goes on a resource reserved for it, so it does not contend, and the response arrives in a search space the phone monitors only while recovering.

Multi-point transmission serves one phone from several geographically separate transmission points at once. Figure 12.5 shows the two architectures: a single DCI controlling both points, which assumes tight alignment, and separate DCIs with independent control and feedback per point, which allows more freedom.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 12.5 shows the two architectures: a single DCI controlling both points, which assumes tight alignment, and separate DCIs with independent control and feedback per point, which allows more freedom.*

> [!spec] 3GPP reality check
> Detection — the counter, the timer, and the maximum count between one and ten — is [TS 38.321 V18.10.0, clause 5.17](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); the candidate threshold, the dedicated random-access resource, and the response window are TS 38.213 clause 6.

### 3.7 **Beam Management**

The road ends by asking whose job all of this is, and shows that three layers share it.

Beam management is not one layer's job. The physical layer forms beams and measures received power; MAC counts failure instances and carries the recovery; RRC configures the TCI states, the thresholds, and the resources. Through establishment, adjustment, recovery, and multi-point operation, the three layers keep both directions aligned, and that alignment is the backbone of millimetre-wave performance.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the four documents over which beam management is spread.

Beam management is spread over four documents. The burst that is swept, and the recovery procedure, are TS 38.213. The report of the best beams, and the TCI states that name them, are TS 38.214. The counter that decides a beam has failed is TS 38.321, because it is a MAC procedure. And the thresholds, the candidate list, and the reserved resource are configured in TS 38.331. The figure shows the numbers, because a millimetre-wave demo fails on one of them.

![[99 Attachments/5G/Protocol Figures/STAR-12-Beam-Management-Protocol.png|The four documents that define beam sweeping, reporting, naming, failure and recovery]]

*Protocol figure: The four documents that define beam sweeping, reporting, naming, failure and recovery.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.1; 6; 8 | synchronisation burst, beam-recovery request and response, random access |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 5.1.5; 5.2.1.4.2; 6.1.1 | TCI states and QCL, L1-RSRP reporting, uplink spatial behaviour |
| TS 38.321 | V18.10.0, [38321-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.17 | beam failure detection: the counter and the timer |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 5.3; 6.3.2 information elements | TCI, CSI-RS, SRS, QCL, and beam-failure configuration |

!note[**When you build or run a demo.** A millimetre-wave demo lives or dies on a few configuration lines. Which of the possible synchronisation blocks the cell actually transmits is one bitmap; a phone can only be found in a direction that is swept. The TCI states in play are a list, and every data channel must point at one of them. The failure counter's maximum and its timer are two values, and setting the maximum to one turns every flicker into a recovery. The candidate threshold decides how good a replacement must be before the phone will shout for it. And the log shows a beam switch as a change of synchronisation-block index with the received power beside it; a phone that switches every few hundred milliseconds is at the edge of two beams, and the answer is usually a wider beam.]

Release 15 already used synchronisation-block sweeping, CSI-RS and SRS refinement, TCI states, and beam-failure recovery. Release 16 added multi-point transmission and enhanced beam management; Release 17 and 18 unify TCI signalling across channels. When an older tutorial names a field, verify its current conditions in the Release 18 clauses above. Release descriptions are cross-checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the procedures; this trace applies one switching policy to three measured candidates so that you can see when a beam changes.

Assume a UE measures three CSI-RS candidates after configured filtering. Their L1-RSRP values are $-92$, $-87$, and $-89$ dBm for candidates A, B, and C. The current beam is A. A pedagogical switching policy requires a candidate to exceed the serving beam by a 3 dB margin. This margin is not a universal 3GPP beam-switch command; it is an explicit teaching assumption.

**What we are working out.** The improvement of the strongest candidate over the serving beam and the resulting local switch decision.

$$
\begin{aligned}
P_{\max}
&=\max(-92,-87,-89)\ \mathrm{dBm}\\
&=-87\ \mathrm{dBm},\\
\Delta P
&=P_{\max}-P_A\\
&=(-87\ \mathrm{dBm})-(-92\ \mathrm{dBm})\\
&=5\ \mathrm{dB},\\
5\ \mathrm{dB}&>3\ \mathrm{dB}\quad\Rightarrow\quad\text{select candidate B under the assumed rule.}
\end{aligned}
$$

In this formula, $P_A$, $P_B$, and $P_C$ are filtered L1-RSRP measurements in dBm. Subtracting two logarithmic power levels produces a difference in dB. $P_{\max}$ is the best measured candidate, and $\Delta P$ is its improvement over the serving candidate. The three measurements and the 3 dB margin are pedagogical assumptions. The standards plane defines measurement, reporting, and configured procedure behavior; it does not prescribe this universal vendor-independent selection formula. The reference plane is TS 38.215 for measurement definitions and TS 38.214/38.331 for reporting and configuration.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $P_A$ | -92 | dBm | assumed filtered measurement |
| $P_B$ | -87 | dBm | assumed filtered measurement |
| $P_C$ | -89 | dBm | assumed filtered measurement |
| $P_{\max}$ | -87 | dBm | derived maximum |
| $\Delta P$ | 5 | dB | derived improvement |
| $M$ | 3 | dB | pedagogical hysteresis margin |

Without the margin, any tiny measurement lead could trigger a switch. With a margin, B must be meaningfully better than A. A real implementation also considers time-to-trigger, control reliability, candidate validity, mobility state, and whether the relevant channel can be activated on that candidate. During beam-failure recovery, the configured candidate and request procedure govern behavior.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star supports U06, U07, and U08. U06 provides OFDM resources and reference-signal placement; U07 explains path loss, fading, Doppler, and measurement uncertainty; U08 turns antenna arrays into directional gain and spatial control. Beam management is where those units meet operationally: reference signals sample a changing spatial channel, and signaling turns those samples into usable reception assumptions.

A good classroom exercise is to ask students to label every arrow in the map as measurement, report, configuration, activation, transmission, or recovery. If an arrow can only be labeled “the beam changes,” the causal interface has not yet been understood.

!warning[**“TCI is the precoder matrix”.**

TCI communicates reference-signal and QCL relationships used for reception assumptions. It does not reveal the gNB’s complex element weights. A TCI state may correspond to an operational beam, but the mathematical precoder remains an implementation object unless separately represented by a standardized codebook context.]

!warning[**“PDCCH and PRACH always share one TCI beam”.**

PRACH transmission can be associated with an SSB or configured recovery candidate, while PDCCH monitoring follows control-resource and QCL/TCI configuration. The two may align in a deployment, yet the standards mechanisms and directions are distinct.]

!warning[**“RRC alone chooses every PDSCH beam”.**

RRC supplies configuration, while MAC CE activation and DCI indication may control active or indicated TCI state according to the supported mode. Reducing the chain to RRC alone hides the timescale separation.]

!warning[**“The strongest sample is always selected immediately”.**

Measurements are filtered and procedures include thresholds, configured candidate sets, reporting opportunities, and response timing. Implementations also manage switching cost and ping-pong. The strongest instantaneous sample is only one input.]

!warning[**“Beam failure recovery is a beam switch”.**

Recovery includes detection, candidate evaluation, a recovery request, and a network response. Calling it a switch omits the access-like control transaction required after the previous spatial path is no longer dependable.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-12-Beam-Management|Chapter 12]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00012-X)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_Phy_BeamManagement.html)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_QCL.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_BeamFailureRecovery.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BFR | Beam failure recovery | staged recovery after beam failure declaration. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| CSI | Channel state information | measured/reported channel evidence. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| CSI-RS | CSI reference signal | connected-mode downlink measurement resource. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| DCI | Downlink control information | dynamic scheduling and state indication. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| gNB | next-generation NodeB | NR base station. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| L1-RSRP | Layer-1 reference-signal received power | beam-level physical-layer measurement. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MAC CE | Medium Access Control control element | activation/control signaling at MAC. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MIB | Master information block | essential information decoded from PBCH. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PBCH | Physical broadcast channel | channel within the SSB. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PDCCH | Physical downlink control channel | downlink scheduling/control channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PRACH | Physical random-access channel | uplink random-access preamble channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| QCL | Quasi-co-location | permitted shared channel-property assumption. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| RRC | Radio Resource Control | configuration and connection-control protocol. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SRS | Sounding reference signal | uplink spatial/channel sounding resource. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SSB | Synchronization signal/PBCH block | initial synchronization and beam candidate block. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| TCI | Transmission configuration indication | configured QCL/reference relationship state. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| UE | User equipment | NR terminal. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $P_A,P_B,P_C$ | filtered candidate L1-RSRP values | dBm |
| $P_{\max}$ | strongest measured candidate power | dBm |
| $\Delta P$ | candidate improvement over serving beam | dB |
| $M$ | assumed switching margin | dB |
| $T_\mathrm{filter}$ | conceptual measurement-filter timescale | s or configured interval |
| $i_\mathrm{SSB}$ | SSB candidate index | integer |
| $i_\mathrm{CSI-RS}$ | CSI-RS candidate index | integer |
