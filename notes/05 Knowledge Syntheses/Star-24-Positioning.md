---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 24
title: Positioning
language: en
course_units: []
release_baseline: 18
---

# STAR-24 — Positioning

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

GPS does not work indoors, and a warehouse robot or a factory tool needs to be found to within a metre. So the network itself becomes the constellation. Picture three lighthouses and a stopwatch: base stations flash, the phone times the flashes, and a server turns the times into a place.

![[99 Attachments/5G/Concept Figures/STAR-24-Positioning-Concept.png|Positioning explained as three lighthouses and a stopwatch]]

*Concept figure: Positioning explained as three lighthouses and a stopwatch.*

Each base station flashes a signal built for timing rather than data. The phone cannot know when a flash left, only the gap between arrivals, and each gap describes a curve of possible places; two curves cross at the phone. A sharp arrival time needs a wide signal, since 100 MHz of bandwidth resolves about ten nanoseconds, about three metres, so the flash spreads over a comb of subcarriers whose offset hops symbol by symbol and samples the whole band. The nearest lighthouse must sometimes go dark: its flash would drown a distant one, so stations take turns under a muting pattern, leaving silence in which the phone can hear a faint, far flash, and a far flash is what makes the curves cross at a good angle.

The same trick works backwards. The phone flashes a wide sounding signal and several stations time its arrival. Either way the radio only produces observables: arrival-time differences, round-trip times, angles, powers. A location server above the radio turns them into a position; the base station never does. The key fact to carry is that positioning is a measurement service, and accuracy is bought with bandwidth and geometry.

**The question this chapter answers.** GNSS already locates a device outdoors. What does NR add indoors, and how does a network turn radio measurements into a position?

!important[**The short answer.** NR positioning is a measurement service. The network configures reference signals built for timing rather than data, PRS downlink and SRS uplink, and a location function collects arrival-time, angle, and power observations from several sites. The radio interface supplies the observables; the position is computed above it.]

Names you will meet in this note: positioning reference signal (PRS), sounding reference signal (SRS), reference signal time difference (RSTD), round-trip time (RTT), angle of arrival and departure (AoA, AoD), time difference of arrival (TDOA), location management function (LMF), LTE positioning protocol (LPP), NR positioning protocol A (NRPPa), transmission-reception point (TRP).

## 2. Where you are in 5G

Section 1 turned base stations into lighthouses with a stopwatch. The map below shows where positioning sits in 5G: reference signals in both directions feeding a location server outside the radio.

![[99 Attachments/5G/Locator Maps/STAR-24-Where-You-Are-in-5G.png|Where Star 24 sits in the whole 5G system]]

*Locator: Where Star 24 sits in the whole 5G system.*

This chapter lights positioning as a service that spans the radio and the core. Its downlink signal is a cousin of the reference signals of Star 08, its uplink signal is the sounding signal of the same chapter, and its arithmetic uses the timing advance of Star 15. The location function lives in the core of Star 05, and the beams it uses for angles are Star 12's. It is a Release 16 chapter, placed among the others in Star 27.

The Knowledge Structure Map draws the measurement chain from reference signal to position. The mechanism diagram traces one request through phone, stations, and server.

![[99 Attachments/5G/Knowledge Maps/STAR-24-Positioning-Knowledge Structure Map.png|STAR-24 system-position map]]

*Knowledge map: The NR positioning methods sorted on a quadrant.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-24-NR-Positioning-Measurement-Chain.png|Star 24 mechanism and handoff diagram]]

*Mechanism: Multi-round-trip-time positioning drawn as three intersecting circles.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Introduction → 24.1 Downlink-Based Positioning → 24.2 Uplink-Based Positioning.


## 3. The textbook road

Section 2 placed positioning. The road below walks through the chapter in the book's order: the architecture and methods, then the downlink signal and the uplink signal.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Introduction**

The road begins with why the network must position at all, and the server and methods it uses.

!important[GNSS is the standard for outdoor positioning but has no coverage indoors. Release 16 extends NR positioning to meet the accuracy that indoor logistics and manufacturing require. The architecture rests on a location server that collects measurements and capabilities and computes positions. The methods include observed time difference of arrival, which needs tight time synchronisation between base stations, along with round-trip time, angle of arrival, and received power. Figure 24.1 shows the two directions: downlink, where the phone measures reference signals from several base stations and reports time differences; and uplink, where the phone transmits and several base stations measure arrival.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.1 shows the two directions: downlink, where the phone measures reference signals from several base stations and reports time differences; and uplink, where the phone transmits and several base stations measure arrival.*

#### 3.1.1 **24.1 Downlink-Based Positioning**

!important[NR introduces the positioning reference signal for accurate timing. It is organised in a hierarchy: positioning frequency layers by carrier and numerology, resource sets that gather all beams from one site, and resources that are one beam each. Figure 24.2 shows the hierarchy, which lets the network tell apart measurements from different sites and beams.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.2 shows the hierarchy, which lets the network tell apart measurements from different sites and beams.*

Figure 24.3 shows the signal's shape: a comb, say every sixth subcarrier, whose offset changes across symbols in a permuted order such as 0, 3, 1, 4, 2, 5, so that the whole band is sampled within one resource.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.3 shows the signal's shape: a comb, say every sixth subcarrier, whose offset changes across symbols in a permuted order such as 0, 3, 1, 4, 2, 5, so that the whole band is sampled within one resource.*

Figure 24.4 shows how resources repeat in time to improve accuracy, either sweeping beams then repeating or repeating each beam then sweeping.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.4 shows how resources repeat in time to improve accuracy, either sweeping beams then repeating or repeating each beam then sweeping.*

Figure 24.5 shows muting: a bitmap under which the local base station switches its signal off, creating a silence in which the phone can hear the quieter signal from a distant site, the near-far problem solved by turns.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.5 shows muting: a bitmap under which the local base station switches its signal off, creating a silence in which the phone can hear the quieter signal from a distant site, the near-far problem solved by turns.*

Three measurements result. PRS-RSRP is the received power, used for fingerprinting. The reference signal time difference is the timing gap between two base stations, the input to trilateration. The receive-minus-transmit time difference is the phone's half of a round-trip estimate.

> [!book] Book expansion
> The textbook presents PRS as a measurement-enabling signal whose wide bandwidth, repetition, beam resources, and muting are chosen for timing observability rather than user-data delivery. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 24, pp. 479–485, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00024-6).

> [!spec] 3GPP reality check
> The positioning roles and procedures are [TS 38.305 V18.8.0, clauses 4–8](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip); the PRS sequence, comb, and muting are TS 38.211 clause 7.4.1.7; the three downlink measurements are TS 38.215 clauses 5.1.28 to 5.1.30.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [positioning page](https://www.sharetechnote.com/html/5G/5G_Positioning.html) draws the PRS comb on a resource grid and lists the LPP messages by which the server configures it, which is where a demo's configuration actually lives.

#### 3.1.2 **24.2 Uplink-Based Positioning**

Uplink positioning uses the sounding reference signal, in a form more robust than the one used for channel estimation. Base stations measure relative time of arrival, angle of arrival, and received power. Figure 24.6 compares the Release 15 sounding signal with the positioning one, which borrows the same permuted staggered comb as the downlink signal to sharpen timing.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 24.6 compares the Release 15 sounding signal with the positioning one, which borrows the same permuted staggered comb as the downlink signal to sharpen timing.*

> [!important] 💡
> ### **Analytical Conclusion: PRS vs. Normal NR Signals**
> **Issue:** how does the positioning reference signal differ from normal NR signals (CSI-RS, DMRS) on the resource grid?
> **Analysis:** it is distinct in three ways, all designed for time-of-arrival accuracy rather than demodulation.
> 1. **Permuted staggered comb.** Normal signals use standard combs that shift linearly or stay fixed. PRS uses a permuted staggered comb (Figure 24.3): the offset hops in a random-looking order (0, 3, 1, 4, 2, 5). This lets the receiver resolve timing paths even if it cannot coherently combine all symbols, and samples the frequency domain uniformly to prevent aliasing in the time-domain profile.
> 2. **Bandwidth and BWP independence.** Normal signals are confined to the active bandwidth part. PRS is defined independently of bandwidth parts and can be wider than the active one, up to 272 resource blocks, because timing accuracy is proportional to bandwidth.
> 3. **Puncturing and muting.** Data is normally rate-matched around reference signals. PRS is punctured into data, so legacy devices that do not know it see a little noise and carry on; and PRS uses explicit muting patterns (Figure 24.5), because hearing a distant whisper requires the local shout to stop.

> [!book] Book expansion
> Uplink positioning reverses the direction without changing the estimation problem: the phone transmits a known wideband reference, several reception points observe it, and a location function combines the measurements. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 24, pp. 479–485, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00024-6).

> [!spec] 3GPP reality check
> The positioning sounding signal is [TS 38.211 V18.9.0, clause 6.4.1.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the uplink measurements are TS 38.215 clauses 5.2.2 to 5.2.7; the procedure is TS 38.305, and the two answer different questions.

> [!engineering] ShareTechnote engineering view
> The [positioning page](https://www.sharetechnote.com/html/5G/5G_Positioning.html) traces which node transmits and which nodes measure in each method, which is the table to keep beside the methods clause.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names three documents that answer three questions: what is transmitted, what is measured, and how the server uses it.

Three documents answer three questions. TS 38.211 says what is transmitted: the comb, symbol count, sequence, and muting of the positioning reference signal, and the positioning form of the sounding signal. TS 38.215 says what is measured: the downlink observables of received power, time difference, and receive-minus-transmit time, and their uplink mirrors. TS 38.305 says how measurements become a position: the methods and the roles of phone, base station, and location function, with LPP and NRPPa as the protocols between them. The figure draws the signal's shape, the bandwidth-to-resolution rule, the time-difference and round-trip observables, the muting bitmap, and the server's role.

![[99 Attachments/5G/Protocol Figures/STAR-24-Positioning-Protocol.png|The positioning reference signals, the measurements they yield, and the methods that turn them into a position, with their clauses and configured values]]

*Protocol figure: The positioning reference signals, the measurements they yield, and the methods that turn them into a position, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 7.4.1.7; 6.4.1.4 | downlink PRS and uplink positioning SRS |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 5.1.6.5; 6.2.1.4 | PRS reception and positioning-SRS procedures |
| TS 38.215 | V18.5.0, [38215-i50.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) | 5.1.28–5.1.30; 5.2.2–5.2.7 | downlink and uplink positioning measurements |
| TS 38.305 | V18.8.0, [38305-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip) | 4.3; 5–7 | positioning methods, architecture, and procedures |
| TS 37.355 | V18.8.0, [37355-i80.zip](https://www.3gpp.org/ftp/Specs/archive/37_series/37.355/37355-i80.zip) | 5 | LPP procedures between server and phone |

!note[**When you build or run a demo.** A positioning demo needs at least three sites with synchronised clocks, a phone, and a location function, and the clock synchronisation between sites is the first thing that limits accuracy, since a nanosecond of clock error is thirty centimetres. Each site's reference signal is a comb density, a symbol count, a period, and a muting bitmap, and a demo where one site is never heard usually has no muting. The phone reports time differences over LPP; the sites report their measurements over NRPPa; the fix and its error bound come from the server, and the base-station log never contains a position. Open-source stacks are beginning to add PRS; a full demo usually pairs a radio stack with a separate location function.]

Release 15 supported location through cell identity and older mechanisms; the native PRS and SRS framework is Release 16. Release 17 improved accuracy, integrity, and operation, and Release 18 adds bandwidth aggregation and other enhancements. The fixed versions describe standardised scope. Release summaries are checked against TS 21.916 and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the measurements; this trace turns a 30 ns arrival-time difference into a path-length difference you can check.

**What we are working out.** Difference between UE path lengths to two PRS sites for a 30 ns arrival-time difference.

**Worked numerical example.** Convert a relative delay into its first-order geometric range-difference constraint.

Assume propagation speed equal to the speed of light in free space. If one PRS arrives 30 ns later than the reference PRS, the first-order path-length difference is:

$$
\begin{aligned}
\Delta d &= c\,\Delta t \\
&= (3.00\times10^8\ \mathrm{m/s})(30\times10^{-9}\ \mathrm{s}) \\
&= 9.00\ \mathrm{m}.
\end{aligned}
$$

Here $\Delta d$ is the path-length difference in metres, $c$ is propagation speed in metres per second, and $\Delta t$ is relative arrival time in seconds or nanoseconds.

This result does not say the UE is 9 m from either site. It says the two measured path lengths differ by about 9 m, placing the UE on a geometric locus. At least additional independent measurements or constraints are needed to select a position. A reflected path can bias the timing by more than the nominal resolution, and site clocks or calibration can add error. The value is illustrative; the measurement definitions and resource behavior come from TS 38.215 and TS 38.211, while the geometry is elementary propagation.

**Sanity check.** Radio travels approximately 0.3 m per nanosecond, so 30 ns corresponding to about 9 m is dimensionally and physically plausible.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $\Delta d$ | Difference between two path lengths | 9.00 | m | Derived geometric constraint |
| $c$ | Approximate radio propagation speed | $3.00\times10^8$ | m/s | Physical constant approximation |
| $\Delta t$ | Measured relative arrival time | 30 | ns | Assumed illustration |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** Course Alignment gives Chapter 24 no direct current unit. It can serve as an application after reference signals, OFDM resource mapping, measurement, and antenna-array concepts. The strongest exercise compares PRS, CSI-RS, and DM-RS by purpose and asks which errors wider bandwidth does and does not reduce.

An advanced lab can turn simulated RSTD values into hyperbolas and then perturb one path with non-line-of-sight bias. This links physical-layer resolution to estimator integrity without inventing a new course mapping.

> “How does the Positioning Reference Signal (PRS) differ from normal NR signals (like CSI-RS or DMRS) on the resource grid?”

!warning[PRS has positioning-specific resource configuration, patterns, occasions, repetition, and muting so multiple sites can be measured for timing, power, or angle observables. CSI-RS is primarily configured for channel-state information, beam management, and related radio measurements. DM-RS is tied to coherent demodulation of a data/control transmission. They can occupy resource elements on the same NR grid, but their purposes, associations, sequences, and collision rules differ.]

!warning[PRS does not grant unlimited reception beyond a bandwidth part or device capability. Supported bandwidth, configured frequency layers, gaps, aggregation, and hopping determine observation. “PRS always overwrites data” is also unsafe: mapping conflicts are resolved by the applicable rules, which can include not mapping, puncturing, or rate matching under configuration. Finally, greater effective bandwidth sharpens delay resolution but cannot alone guarantee accuracy; geometry, clocks, calibration, multipath, and the estimator remain decisive.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 24, pp. 479–485, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00024-6).
2. 3GPP TS 21.916 V16.2.0, clause 14.3. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
3. 3GPP TS 38.211 V18.9.0, clauses 7.4.1.7 and 6.4.1.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
4. 3GPP TS 38.214 V18.10.0, clauses 5.1.6.5 and 6.2.1.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
5. 3GPP TS 38.215 V18.5.0, clauses 5.1.28–5.1.30 and 5.2.2–5.2.7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip).
6. 3GPP TS 38.305 V18.8.0, clauses 4.3 and 5–7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip).
7. 3GPP TS 37.355 V18.8.0, clause 5. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/37_series/37.355/37355-i80.zip).
8. 3GPP TS 21.918 V18.0.0, clause 9.2. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
9. ShareTechnote, “5G Positioning” and “5G PRS,” accessed 2026-08-03. [Positioning](https://www.sharetechnote.com/html/5G/5G_Positioning.html); [PRS](https://www.sharetechnote.com/html/5G/5G_PRS.html).
10. Course Alignment, local course crosswalk, accessed 2026-08-03.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| AoA | Angle of Arrival | Direction observable at a receiving antenna array. | Section 1; [TS 38.305](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip) |
| CSI-RS | Channel-State-Information Reference Signal | Downlink reference signal for channel/beam measurements. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| DM-RS | Demodulation Reference Signal | Reference signal associated with coherent demodulation. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| LMF | Location Management Function | Network function coordinating positioning. | Section 1; [TS 38.305](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip) |
| LPP | LTE Positioning Protocol | Positioning assistance and information protocol used by NR positioning. | Section 1; [TS 37.355](https://www.3gpp.org/ftp/Specs/archive/37_series/37.355/37355-i80.zip) |
| PRS | Positioning Reference Signal | Downlink signal optimized for positioning measurements. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| RSTD | Reference Signal Time Difference | Relative arrival-time measurement between PRS sources. | Section 1; [TS 38.215](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) |
| RTT | Round-Trip Time | Bidirectional timing observable. | Section 1; [TS 38.305](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip) |
| SRS | Sounding Reference Signal | Uplink signal configured for positioning measurements. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| UE | User Equipment | Positioning target and/or measurement entity. | Section 1; [TS 38.305](https://www.3gpp.org/ftp/Specs/archive/38_series/38.305/38305-i80.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $\Delta d$ | Difference between two propagation path lengths | m |
| $c$ | Approximate radio propagation speed | m/s |
| $\Delta t$ | Relative arrival-time measurement | s or ns |
| ns | Nanosecond | $10^{-9}$ s |
| m | Metre | SI length unit |
