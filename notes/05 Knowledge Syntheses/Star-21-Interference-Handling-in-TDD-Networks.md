---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 21
title: Interference Handling in TDD Networks
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-21 — Interference Handling in TDD Networks

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

In TDD everyone shares one frequency and takes turns: the tower speaks, then listens, then speaks. The turns only work if every neighbour, near and far, is on the same beat. This chapter is about the two ways a neighbour can talk over you when the beat slips, one from three hundred kilometres away and one from the next desk.

![[99 Attachments/5G/Concept Figures/STAR-21-Interference-Handling-in-TDD-Networks-Concept.png|Interference handling in TDD networks explained as two ways a neighbour talks over you]]

*Concept figure: Interference handling in TDD networks explained as two ways a neighbour talks over you.*

The echo from far away is remote interference. On some evenings a layer of warm air over cool ground or sea becomes a whispering gallery, an atmospheric duct, and a tower's downlink rides it 150 to 400 km with almost no loss. It arrives half a millisecond to more than a millisecond late, long after the guard gap, exactly when a distant tower has turned round to listen for its own weak phones. The victim hears a loud smear at the start of its uplink that fades over the slot, the signature of a far-away downlink rather than local noise. The fix is a conversation between towers: the victim broadcasts "I am being hurt" in a signal built to be heard through the duct, the aggressor answers over the air or reports upward, and one of them widens the gap.

The next desk is cross-link interference. In an open-plan office of small cells, dynamic TDD lets each cell pick its own turn, so one cell downloads while its neighbour uploads. A phone uploading in one cell may sit a metre from a phone downloading in the next, and phone-to-phone interference has no tower in the middle to plan for it. The fix is measurement and coordination: phones measure how loudly they hear each other's sounding signals, and towers tell each other which slots are fixed in direction and which are flexible, so that sensitive traffic goes where the neighbour has promised.

FDD never had either problem, because uplink and downlink sit on different frequencies. TDD gives that up to gain unpaired spectrum, asymmetric traffic, and channel reciprocity for beamforming. This chapter is the price. The key fact to carry is that both tools are network-to-network: phones only measure, and the decisions travel between towers, through the duct or over the wired Xn link.

**The question this chapter answers.** Why does sharing a frequency in time create interference paths that paired spectrum never has, and how does NR detect and manage them at two very different ranges?

!important[**The short answer.** In TDD a base station's downlink can land in another base station's uplink, and a device's uplink in another device's downlink. Remote interference arises when atmospheric ducting carries a distant downlink far beyond the guard period; NR handles it with a purpose-built reference signal exchanged between victim and aggressor and a widened guard. Cross-link interference arises when dynamic TDD lets neighbouring cells choose opposite directions; NR handles it with device-side SRS measurements and exchange of intended slot directions over Xn.]

Names you will meet in this note: remote interference management (RIM), cross-link interference (CLI), RIM reference signal (RIM-RS), sounding reference signal received power (SRS-RSRP), received signal strength indicator (RSSI), operations, administration and maintenance (OAM), Xn interface, guard period (GP).

## 2. Where you are in 5G

Section 1 described neighbours talking over you in a TDD network. The map below shows where the two problems sit in 5G: between cells, at the boundary the grid of Star 07 never showed.

![[99 Attachments/5G/Locator Maps/STAR-21-Where-You-Are-in-5G.png|Where Star 21 sits in the whole 5G system]]

*Locator: Where Star 21 sits in the whole 5G system.*

This chapter lights interference handling in the procedures band, next to the dynamic TDD decisions of Star 14 and the slot formats of Star 07. It uses the sounding signal of Star 08 as a measurement and the Xn interface of Star 06 as a channel between towers. It is a Release 16 chapter, placed among the others in Star 27.

The Knowledge Structure Map draws remote and cross-link interference at their different ranges. The mechanism diagram is the detect, signal, and mitigate loop.

![[99 Attachments/5G/Knowledge Maps/STAR-21-Interference-Handling-in-TDD-Networks-Knowledge Structure Map.png|STAR-21 system-position map]]

*Knowledge map: Cross-link interference between two TDD cells drawn as four radio paths.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-21-TDD-Interference-Mitigation-Loop.png|Star 21 mechanism and handoff diagram]]

*Mechanism: Two TDD slot patterns overlaid, and the four responses to where they disagree.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Introduction → 21.1 Remote Interference Management (RIM).


## 3. The textbook road

Section 2 placed the problem between cells. The road below walks through the chapter in the book's order: the two interference paths, then remote interference and its management, then cross-link interference.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Introduction**

The road begins with why TDD has interference paths that FDD never has.

NR supports both FDD and TDD. In FDD uplink and downlink use separate frequencies; in TDD they share one frequency and are separated in time, which creates two interference paths FDD never has. Downlink-to-uplink interference is one base station's transmission landing in another's reception. Uplink-to-downlink interference is one device's transmission landing in another device's reception. Figure 21.1 shows both, base station to base station on the left and device to device on the right.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.1 shows both, base station to base station on the left and device to device on the right.*

In wide-area networks base stations stand high with line-of-sight paths between them, and a high-power downlink can drown a weak uplink in a neighbouring cell. The standard defence is to synchronise uplink and downlink slots across the whole network so that everyone transmits at the same time. Release 16 adds tools for two cases that defence cannot cover: remote interference management for large cells and cross-link interference mitigation for small ones.

> [!book] Book expansion
> Chapter 21 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 433–442, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00021-0)) treats the two problems as separate because they are: one is a propagation phenomenon at hundreds of kilometres, the other a scheduling choice at metres.

> [!spec] 3GPP reality check
> The Release 16 work on both is summarised in [TS 21.916 V16.2.0, clause 19.1.12](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip); the system-level description is TS 38.300.

### 3.2 **21.1 Remote Interference Management (RIM)**

Section 3.1 named two paths. This section follows the stranger one: interference that arrives from base stations hundreds of kilometres away.

!important[Remote interference comes from very distant base stations, usually through atmospheric ducts that act as waveguides and carry downlink signals 150 to 400 km with little attenuation. A normal guard period of a few hundred microseconds cannot absorb delays of 0.5 to 1.3 ms. Figure 21.2 shows a duct carrying the aggressor's signal far beyond its normal range into the victim's uplink period.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.2 shows a duct carrying the aggressor's signal far beyond its normal range into the victim's uplink period.*

Figure 21.3 shows that the interference is not constant: it is strongest at the start of the uplink and decays over the slot, a profile that tells the victim the source is distant rather than local.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.3 shows that the interference is not constant: it is strongest at the start of the uplink and decays over the slot, a profile that tells the victim the source is distant rather than local.*

Figure 21.4 shows the two remedies: the aggressor stops transmitting earlier, a downlink back-off, or the victim starts listening later, an uplink back-off. Both widen the guard.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.4 shows the two remedies: the aggressor stops transmitting earlier, a downlink back-off, or the victim starts listening later, an uplink back-off.*

#### 3.2.1 **21.1.1 Centralized and Distributed Interference Handling**

The network must detect the duct and apply a remedy. Three frameworks exist, one centralised and two distributed. In the centralised framework the victim detects interference and sends a reference signal, RIM-RS type 1; the aggressor hears it, reports to a central operations system, and that system decides. Figure 21.5 shows the flow.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.5 shows the flow.*

In the distributed frameworks the aggressor decides on its own when it detects the victim's signal.

> [!important] 💡
> **Distributed Interference Handling & Xn Interface**
> > Statement 1: How can I understand the Xn interface, is this not in the physical layer? When no ducting, how does the signal reach the victim?
> **Analysis:** you are correct that the Xn interface is not in the physical layer. It is the logical backhaul connection between base stations, usually wired fibre or Ethernet.
> - **When ducting exists:** the radio path is open. The victim transmits RIM-RS type 1 over the air and the aggressor hears it via the duct.
> - **When ducting disappears:** the radio path is broken and the aggressor stops hearing the RIM-RS over the air.
> - **How does the gNB reply if the duct is gone?** It does not need the radio path. It uses the Xn interface: the aggressor sends a message over the network saying "I stopped hearing your signal". The victim receives it by wire, knows the duct is gone, and stops transmitting. It addresses the message to the victim's cell identity, which was encoded in the RIM-RS it previously heard.
> > Statement 2: What's the difference between the two distributed schemes, over-the-air signalling and backhaul signalling?
> **Analysis:** the difference is how the aggressor tells the victim that it has seen the signal, or that the signal is gone.
> 1. **Over-the-air:** the aggressor transmits RIM-RS type 2 back through the duct. If the duct breaks, the victim stops hearing type 2 and knows to stop.
> 2. **Backhaul:** the aggressor sends a data packet over Xn. This does not rely on the duct being open for the return trip.

Figure 21.6 shows the over-the-air variant, the aggressor replying with RIM-RS type 2 through the duct.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.6 shows the over-the-air variant, the aggressor replying with RIM-RS type 2 through the duct.*

Figure 21.7 shows the backhaul variant, the aggressor replying over Xn.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.7 shows the backhaul variant, the aggressor replying over Xn.*

#### 3.2.2 **21.1.2 RIM Reference Signals**

Two signals make it work. Type 1 is sent by the victim and says "I am suffering interference", and can indicate how many symbols are affected. Type 2 is sent by the aggressor and says "I hear you; the duct exists". Figure 21.8 shows the structure: two identical OFDM symbols back to back, which acts as a very long cyclic prefix, so that the receiver detects the signal even without being synchronised to the transmitter.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.8 shows the structure: two identical OFDM symbols back to back, which acts as a very long cyclic prefix, so that the receiver detects the signal even without being synchronised to the transmitter.*

> [!book] Book expansion
> The textbook reads the waveform as a message in a procedure, victim detection, aggressor identification, coordination, rather than as an isolated pattern. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 21, pp. 433–442, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00021-0).

> [!spec] 3GPP reality check
> The RIM reference signal's sequence and mapping are [TS 38.211 V18.9.0, clause 7.4.1.6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the frameworks and the Xn messages are TS 38.300 clause 16 and TS 38.423.

#### 3.2.3 **21.1.3 Resources for RIM-RS**

The time, frequency, and sequence of a RIM-RS derive from a triplet of indices, so that thousands of cells can transmit without colliding, and the cell identity is implicitly encoded in the choice. Figure 21.9 shows the triplet mapping to time, frequency, and sequence.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.9 shows the triplet mapping to time, frequency, and sequence.*

#### 3.2.4 **21.2 Crosslink Interference (CLI)**

!important[Cross-link interference belongs to small-cell networks with dynamic TDD, where one cell may choose to download while its neighbour uploads.]

> [!important] 💡
> **Crosslink Interference Mechanisms**
> > Statement 3: How do they deal with the inter-cell interference and what mechanism do they use?
> **Analysis:** a device transmitting uplink in cell A may be very close to a device receiving downlink in cell B. Release 16 uses two mechanisms to handle it without forcing everyone onto the same schedule:
> 1. **Device-side measurement (SRS-RSRP):** the network asks the victim device to listen for the aggressor device by measuring the power of its sounding reference signal. If device A hears device B loudly, the network knows they are close and should not schedule conflicting uplink and downlink slots for them.
> 2. **Inter-cell coordination (Xn):** base stations divide their slots into fixed ("I promise this is uplink", safe for critical data) and flexible ("I might switch this", for non-critical data). By exchanging this, schedulers place sensitive data in fixed slots to avoid surprises.

#### 3.2.5 **21.2.1 Device-Side Interference Measurements**

The standard extends the received-power and signal-strength measurements to the sounding reference signal, so a device can measure interference arriving directly from other devices and give the scheduler a picture of the local environment. Figure 21.10 shows one device sounding while a neighbour measures its strength and reports it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 21.10 shows one device sounding while a neighbour measures its strength and reports it.*

#### 3.2.6 **21.2.2 Inter-Cell Coordination**

Base stations coordinate over Xn by classifying resources as fixed, with a guaranteed direction, or flexible, subject to change. A neighbour then avoids scheduling a sensitive downlink reception during a slot the other cell has marked as fixed uplink.

> [!spec] 3GPP reality check
> The two cross-link measurements, SRS-RSRP and CLI-RSSI, are [TS 38.215 V18.5.0, clauses 5.1.19 and 5.1.20](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip), configured through the CLI measurement objects of TS 38.331; the intended TDD configuration exchanged between neighbours is an Xn information element in TS 38.423.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [TDD configuration page](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html) shows the slot patterns neighbouring cells must agree on, which is the input to both fixed-flexible coordination and remote-interference planning.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: a reference signal and a framework for remote interference, two measurements and a message for cross-link interference.

Remote interference is a reference signal in TS 38.211 and a framework in TS 38.300 and the Xn protocol. Cross-link interference is two measurements in TS 38.215, their configuration in TS 38.331, and an intended-configuration message over Xn. The figure draws the duct delay against the guard, the two-symbol signal that acts as a long cyclic prefix, the index triplet that names the sender, the SRS-RSRP definition, and the fixed-versus-flexible exchange, with the configuration lines each becomes.

![[99 Attachments/5G/Protocol Figures/STAR-21-Interference-Handling-in-TDD-Networks-Protocol.png|The remote-interference reference signal and the cross-link measurements, with their clauses and configured values]]

*Protocol figure: The remote-interference reference signal and the cross-link measurements, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 7.4.1.6 | RIM reference-signal sequence and resources |
| TS 38.215 | V18.5.0, [38215-i50.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) | 5.1.19–5.1.20 | SRS-RSRP and CLI-RSSI measurements |
| TS 38.300 | V18.10.0, [38300-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | 4.3.2; 16 | Xn interface and the RIM frameworks |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | MeasObjectCLI | cross-link measurement configuration |
| TS 21.916 | V16.2.0, [21916-g20.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) | 19.1.12 | Release 16 introduction of CLI and RIM |

!note[**When you build or run a demo.** Neither mechanism appears in a single-cell demo, and both need two base stations that can talk to each other. Cross-link interference is the more reachable: two cells with different slot patterns, a measurement object pointing at a neighbour's sounding signal, and the report in the log show the effect directly, and the intended-configuration message is what an Xn-capable stack exchanges. Remote interference needs a duct, which no laboratory supplies; what a demo can show is the reference signal's two-symbol structure and how its resources encode a set identity. The TDD pattern itself, the same in every cell of a network, is the one configuration line that prevents most of what this chapter describes.]

Release 15 provided the TDD framework, flexible symbols, measurements, and the inter-node architecture; the targeted remote and cross-link package is Release 16. Release 18 retains the clauses in an evolved baseline, and not every deployment activates either tool or uses dynamic TDD. Release summaries are checked against TS 21.916 and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix the signals; this trace computes how long a ducted path of 300 km delays a signal, and why a normal guard period cannot absorb it.

**What we are working out.** One-way propagation delay for a 300 km ducted radio path.

**Worked numerical example.** Apply a first-order distance-over-speed estimate to expose the unusual delay scale.

Assume a path length of 300 km and approximate radio propagation by the speed of light in free space. This is a first order delay calculation.

$$
\begin{aligned}
\tau &= \frac{d}{c} \\
&= \frac{300{,}000\ \mathrm{m}}{3.00\times10^8\ \mathrm{m/s}} \\
&= 1.00\times10^{-3}\ \mathrm{s} \\
&= 1.00\ \mathrm{ms}.
\end{aligned}
$$

Here $\tau$ is one-way propagation delay in seconds or milliseconds, $d$ is path length in metres, $c$ is approximate propagation speed in metres per second, and ms means milliseconds.

A downlink edge arriving roughly one millisecond late can overlap an uplink interval even when the aggressor's local downlink has already ended. Extending every local guard to cover this rare distance would consume substantial capacity. RIM instead detects the condition and coordinates affected cells while it persists. Real delay depends on path geometry and refractive index, and harmful overlap also depends on numerology, symbol allocation, transmitter power, antenna patterns, and receiver filtering.

**Sanity check.** Radio travels about 300 km in one millisecond, so the computed order of magnitude is physically consistent.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $\tau$ | One-way propagation delay | 1.00 | ms | Derived first-order estimate |
| $d$ | Assumed ducted path length | 300,000 | m | Illustrative assumption |
| $c$ | Approximate propagation speed | $3.00\times10^8$ | m/s | Physical constant approximation |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** Course Alignment maps Chapter 21 to U03–U05. It supports teaching about numerology and slot timing, physical signals and measurements, and scheduler/resource behavior. The best integration point is a case study after students can read a TDD pattern: first identify direction mismatch, then distinguish the gNB-to-gNB and UE-to-UE cases, and finally assign each observation to the radio or backhaul plane.

An effective exercise presents a trace containing a delayed interference burst, a RIM-RS indication, an Xn message, and a scheduling change. Students must order causal events and explain which evidence survives after the atmospheric path disappears.

> “How can I understand the Xn interface, is this not in the physical layer? When no ducting, how signal transmit to victim?”

Xn is a logical inter-gNB interface carried by transport; it is not a physical-layer radio link between the towers. The unwanted downlink and RIM-RS use the air and require a propagation path. When the duct disappears, that radio coupling may disappear, while Xn communication can continue over the operator's transport network.

> “What’s the difference between these two distributed interference management? The over-the-air signaling and the backhaul signaling?”

Over-the-air signaling observes or reports the actual radio environment and can work across an unexpected coupling path. Backhaul signaling exchanges patterns, measurements, identities, or decisions between network nodes. The first depends on radio reception; the second depends on transport connectivity. A robust design uses each for the evidence it can carry.

> “How they deal with the inter-cell interference and what’s the mechanism they’ve used.”

They measure coupling or interference, report it, coordinate across gNBs where needed, and change the scheduler's direction, time, frequency, or power decisions. RIM-RS, SRS-RSRP, and CLI-RSSI expose conditions; the scheduler performs mitigation. Ordinary interference cancellation at a receiver may still help, but it is not the distributed coordination mechanism defined by these clauses.

### 6.1 Supplement: cellular reuse and the older interference budget

The confusions above are new to TDD. Co-channel interference is as old as cellular; this supplement gives the handout's reuse geometry and the ratio it buys.

!warning[Cross-link interference is new; co-channel interference is as old as cellular. The handout's geometry gives the reuse distance and the S/I it buys.]

![[99 Attachments/5G/Supplement Figures/STAR-21-Saar-Cellular-Reuse.png|Cellular reuse geometry, cluster size and signal-to-interference]]

*Supplement figure: Cellular reuse geometry: hexagonal clusters of seven cells with the reuse distance marked, formula boxes for cluster size, reuse distance and signal-to-interference, and three panels on hexagons, channel assignment and capacity levers.*
*Figure 6.1 — Seven-cell clusters, the reuse distance D = √(3N)·R, and S/I ≈ 3N²/2 for a path-loss exponent of 4.*

| Cluster size N | Q = D/R | S/I (n = 4) |
|---|---|---|
| 3 | 3.0 | 11.3 dB |
| 4 | 3.5 | 13.8 dB |
| 7 | 4.6 | 18.7 dB |
| 12 | 6.0 | 23.3 dB |

- Larger N buys S/I and costs spectrum per cell; cell splitting and three-sector sites buy capacity without changing N.

Source: Supplementary material, *Cellular networks* (handout).

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 21, pp. 433–442, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00021-0).
2. 3GPP TS 21.916 V16.2.0, clause 19.1.12. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
3. 3GPP TS 38.211 V18.9.0, clauses 5.3.3 and 7.4.1.6.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
4. 3GPP TS 38.214 V18.10.0, clause 5.1.6.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
5. 3GPP TS 38.215 V18.5.0, clauses 5.1.19–5.1.20. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip).
6. 3GPP TS 38.300 V18.10.0, clause 4.3.2. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
7. ShareTechnote, “5G TDD UL/DL Configuration Common” and “Release 16,” accessed 2026-08-03. [TDD page](https://www.sharetechnote.com/html/5G/5G_tdd_UL_DL_configurationCommon.html); [Rel-16 page](https://www.sharetechnote.com/html/5G/5G_Release16.html).
8. Course Alignment, local course crosswalk, accessed 2026-08-03.
9. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| CLI | Cross-Link Interference | Interference caused by opposing link directions. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |
| CLI-RSSI | Cross-Link Interference Received Signal Strength Indicator | Received-power measurement for CLI assessment. | Section 1; [TS 38.215](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) |
| gNB | Next Generation Node B | NR base station. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| NG-RAN | Next Generation Radio Access Network | 5G radio-access network. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| OAM | Operations, Administration, and Maintenance | Network policy and management plane. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| RIM | Remote Interference Management | Coordination for long-range remote interference. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |
| RIM-RS | Remote Interference Management Reference Signal | Over-the-air signal used in RIM. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| SRS | Sounding Reference Signal | Uplink reference signal used for channel/CLI observation. | Section 1; [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) |
| SRS-RSRP | Sounding Reference Signal Reference Signal Received Power | Received power measured on SRS. | Section 1; [TS 38.215](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) |
| TDD | Time-Division Duplex | Duplexing by alternating downlink and uplink in time. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |
| UE | User Equipment | Radio endpoint participating in CLI measurement or service. | Section 1; [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) |
| Xn | Logical interface between NG-RAN nodes | An interface between nodes carried over transport. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $\tau$ | One-way radio propagation delay | s or ms |
| $d$ | Propagation-path length | m or km |
| $c$ | Approximate speed of light in free space | m/s |
| km | Kilometre | $10^3$ m |
| ms | Millisecond | $10^{-3}$ s |
