---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 32
title: TS 38.214 — Physical Layer Procedures for Data
language: en
course_units:
- U03
- U04
- U05
- U11
- U12
release_baseline: 18
---

# STAR-32 — TS 38.214 Physical Layer Procedures for Data

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) — TS 38.214 V18.10.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

A grant names a few small numbers. TS 38.214 is the set of tables and formulas that turn them into exactly how many bits a transport block holds and exactly where it sits, and it defines the reports that inform the next grant. Think of it as the recipe card for data.

![[99 Attachments/5G/Concept Figures/STAR-32-TS-38.214-Concept.png|TS 38.214 explained as the recipe card for data]]

*Concept figure: TS 38.214 explained as the recipe card for data.*

The recipe has four look-ups and one multiplication. A five-bit modulation-and-coding index is a row of one table that gives the modulation order and the code rate. A four-bit time-domain index is a row of another that gives the slot offset, the start symbol, and the length. A frequency field, one integer or a bitmap, gives the blocks. Then the phone counts the usable squares, symbols times twelve subcarriers minus the pilots, times the blocks, capped per block, and multiplies by rate, bits per point, and layers, rounding to a size the coder can cut cleanly. The size is a formula rather than a field because sending it would cost bits in every grant, while a table row costs five and both ends compute the same size, to the bit, every time.

The same document says how a phone reports what it can eat: a four-bit channel-quality index meaning the highest rate it could decode at ten percent error, a precoder index that says which direction, and a rank that says how many layers. The scheduler's choice of row is only as good as this report. The uplink is the mirror, with the same tables, a transform-precoding switch, and sounding in place of reporting, and processing-time tables say how soon a phone can decode a block or prepare one. The key fact to carry is that TS 38.214 fixes how a grant is interpreted, never which grant to send; two base stations reading the same tables can schedule completely differently.

**The question this chapter answers.** How does NR convert a scheduler's request for downlink or uplink data into a resource allocation, a modulation and coding choice, a transport-block size, a spatial transmission, a reference-signal arrangement, and a receiver procedure that both ends interpret identically?

!important[**The short answer.** TS 38.214 is the procedural bridge between the resource grid and an actual data transmission. Clause 4 establishes downlink power assumptions. Clause 5 governs PDSCH reception: resource allocation, MCS and transport-block interpretation, antenna-port and quasi-co-location behaviour, channel-state procedures, and processing-time conditions. Clause 6 provides the parallel PUSCH path with allocation, transform precoding, layers, reference-signal relationships, sounding, and timing. It composes decisions with TS 38.211, 38.212, 38.213, and higher-layer configuration, and defines no scheduling policy.]

Names you will meet in this note: channel-state information and its reference signal (CSI, CSI-RS), downlink control information (DCI), demodulation reference signal (DM-RS), modulation and coding scheme (MCS), physical downlink and uplink shared channel (PDSCH, PUSCH), physical resource block (PRB), phase-tracking reference signal (PT-RS), quasi co-location (QCL), sounding reference signal (SRS), transport-block size (TBS), channel-quality, precoding-matrix, and rank indicators (CQI, PMI, RI), start-and-length indicator value (SLIV), resource-indicator value (RIV).

The clause map of this knowledge base (first-pass extraction) provides the navigation route; the fixed authority is [TS 38.214 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf). A reliable reading keeps four planes apart: the official plane, what an entity shall or may do; the configuration plane, choices supplied by RRC or capability; the implementation plane, scheduling and architecture 3GPP does not mandate; and the teaching plane, simplified examples whose assumptions are printed.

## 2. Where you are in 5G

Section 1 turned a few small numbers into a block size. The map below shows where TS 38.214 sits in 5G: between the grant and the transport block, in both directions.

![[99 Attachments/5G/Locator Maps/STAR-32-Where-You-Are-in-5G.png|Where Star 32 sits in the whole 5G system]]

*Locator: Where Star 32 sits in the whole 5G system.*

This chapter lights the data-procedure document of the specification band: the written form of the channel-sounding reports of Star 08, the transport-block arithmetic of Star 09, and the interpretation of every grant Star 14's scheduler issues. It takes coded bits from TS 38.212, Star 30, places them through TS 38.211, Star 29, and shares its control boundary with TS 38.213, Star 31.

The Knowledge Structure Map draws the data-channel procedure chain. The mechanism diagram traces one grant to one delivered block.

![[99 Attachments/5G/Knowledge Maps/STAR-32-TS-38.214-Knowledge Structure Map.png|STAR-32 system-position map]]

*Knowledge map: TS 38.214 — the downlink and uplink data procedures compared.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-32-TS-38.214-Data-Channel-Procedure-Chain.png|Star 32 mechanism and handoff diagram]]

*Mechanism: TS 38.214 transport-block-size derivation, worked end to end.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.214 V18.10.0, clause 5, PDF page 11](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.214 V18.10.0, clause 5, PDF page 11, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [PDSCH overview](https://www.sharetechnote.com/html/5G/5G_PDSCH.html). The reproduced image is omitted from this distribution.

*Source excerpt: PDSCH overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_PDSCH.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

**Searchable structure.** Grant fields → allocation interpretation → MCS and transport-block size → reference-signal and spatial assumptions → decode and feedback → channel-state report → next grant.

Read the map as a dependency graph rather than a replacement for the specification: inputs arrive from configuration, scheduling, measurements, and buffers; the target entity evaluates clause-defined state, produces a transmission, a report, or a state transition, and consumes feedback; and no single document contains the whole chain. 

## 3. Foundations and prerequisites

Section 2 placed the document. Three foundations follow: the contract around a transport block, how allocation relates to rate, and what the measurements and spatial assumptions are for.

### 3.1 The contract around a transport block

The first foundation is what a transport block depends on.

A transport block begins as a MAC delivery object, but its physical realisation depends on scheduled resources, modulation and coding, layers, reference signals, and coding rules. TS 38.214 tells the phone how to interpret the scheduling-dependent choices; TS 38.212 supplies coding and the size machinery, TS 38.211 modulation and mapping, TS 38.213 control and timing. Reading one document alone creates false certainty.

> [!spec] 3GPP reality check
> The transport-block size is [TS 38.214 V18.10.0, clause 5.1.3.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) for the downlink and 6.1.4.2 for the uplink; the segmentation it must be cut into is TS 38.212 clause 5.2.2.

### 3.2 Resource allocation and rate

Section 3.1 listed the dependencies. This section separates the two that are most often confused: allocation and rate.

!important[A block allocation describes frequency; a time-domain assignment describes symbols and slot relation. The modulation-and-coding index selects a modulation order and code rate family; the effective rate also depends on reference-signal overhead, reserved resources, layers, retransmissions, and the discrete block construction. A scheduler may request an aggressive index, but the receiver follows the configured tables.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [PDSCH page](https://www.sharetechnote.com/html/5G/5G_PDSCH.html) works a transport-block size by hand from a real grant, which is the quickest way to see each term of the formula take a value.

### 3.3 Measurements and spatial assumptions

Section 3.2 covered resources. This section covers the measurements that inform the next grant.

Channel-state reporting provides evidence for link adaptation; demodulation reference signals enable demodulation of the scheduled channel; channel-state signals, sounding, antenna ports, rank, and quasi-co-location assumptions each have a role, coordinated procedurally without exposing a vendor's beamforming. When you read a radio log, first say which object, which entity and which state each row belongs to; control, data, feedback and retransmissions sit on neighbouring rows and are easy to mix up.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the procedures.

### 4.1 Downlink data procedure

The walk starts with the downlink data procedure.

The base station selects an allocation, a modulation-and-coding index, a HARQ context, a redundancy version, layers, and spatial assumptions; the control message and the configuration give the phone what it needs to determine resources and decode; the phone forms the expected reference-signal context, demodulates, rate-recovers, and decodes; the check result feeds the acknowledgement procedure of MAC and TS 38.213.

> [!spec] 3GPP reality check
> The time-domain rows with their slot offset, start, and length are [TS 38.214 V18.10.0, clause 5.1.2.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) and the frequency allocation types are clause 5.1.2.2; the modulation-and-coding tables are clause 5.1.3.1.

### 4.2 Transport-block and rate interpretation

Section 4.1 scheduled a block. This section computes its size.

!important[Clause 5.1.3 connects the index with modulation order and target code rate; the size procedure counts usable resource elements per block, capped, multiplies by blocks, rate, order, and layers, and quantises to a table entry or to a multiple that segments cleanly, with the coding coordinated with TS 38.212. A simple product of blocks, symbols, bits, layers, and rate is a sanity estimate only.]

### 4.3 Uplink data procedure

Sections 4.1 and 4.2 were downlink. This section reads the uplink procedure and what the phone must satisfy before transmitting.

For the uplink, the grant or configured grant determines resources, index, process, transform-precoding condition, layers, and reference-signal behaviour; codebook or non-codebook operation and sounding configuration bound the transmission; and the phone must also satisfy the power and timing conditions of TS 38.213, since a grant does not make an allocation physically realisable.

> [!spec] 3GPP reality check
> The uplink allocation, index, and size are clauses 6.1.2 to 6.1.4; codebook and non-codebook precoding are clause 6.1.1; the sounding procedures are clause 6.2; and the preparation time a phone needs before transmitting is Table 6.4-1.

### 4.4 Feedback and scheduler boundary

The walk ends at the boundary the document never crosses: the scheduler's decision.

Channel-state reports, acknowledgement outcomes, sounding, and received quality inform future scheduling, but TS 38.214 prescribes no utility function; it specifies procedures under given configuration and scheduling decisions, which is why the standard makes interoperable choices possible while the implementation decides when and for whom to use them. A good way to work through any procedure is a small table with six columns: time, transmitter, receiver, object, state before, state after, with the clause each row comes from. Error handling belongs inside the mechanism: a missed control message, an invalid grant, an expired timer, a failed check, or an unavailable resource changes the next legal action, and the note separates required transitions from scheduling choices.

> [!spec] 3GPP reality check
> Channel-state reporting, with the channel-quality definition at ten percent block error and the report quantities, is clause 5.2.2; the processing time before a decoded block can be acknowledged is Table 5.3-1.

## 5. Worked example

Section 4 walked the procedures. Section 5 estimates one block size, a calculation you can redo by hand.

Assume an intentionally simplified PDSCH estimate with 50 PRBs, 12 subcarriers per PRB, 10 usable data symbols after overhead, QPSK with 2 bits per symbol, nominal code-rate factor 0.50, and two layers.

**What we are working out.** The example derives the resource, buffer, or retransmission quantity needed to test the mechanism.

$$
\begin{aligned}
N_{\mathrm{RE}}&=50\times12\times10=6000\ \mathrm{RE},\\
N_{\mathrm{coded\ payload}}&=6000\times2\times0.50\times2\\
&=12000\ \mathrm{bits},\\
R_{\mathrm{slot}}&=\frac{12000\ \mathrm{bits}}{0.5\ \mathrm{ms}}=24\ \mathrm{Mbit/s}.
\end{aligned}
$$

**Immediate guide.** The calculation estimates payload-bearing coded information before the exact standardized TBS procedure. Fifty PRBs, ten data symbols, code rate, two layers, and the 0.5 ms slot are pedagogical assumptions. Real operation subtracts configured DM-RS, PT-RS, control/reserved REs and applies the discrete TBS algorithm and capability limits. The result is a dimensional sanity check; clause 5.1.3 and TS 38.212 give the exact value.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $N_PRB$ | 50 | PRB | pedagogical input or derived result |
| $N_sym$ | 10 | OFDM symbols | pedagogical input or derived result |
| $Q_m$ | 2 | bit/RE/layer | pedagogical input or derived result |
| $R$ | 0.50 | dimensionless | pedagogical input or derived result |
| $v$ | 2 | layers | pedagogical input or derived result |
| $R_slot$ | 24 | Mbit/s | pedagogical input or derived result |

**Sanity check.** Units cancel only where expected, the result remains within the stated resource or data bound, and no discrete standardized table is silently replaced by a continuous approximation. A limiting-case check sets the available resource or missing amount to zero: the selected or transmitted quantity must also become zero. This check catches sign, range, and layer errors before a trace is compared with equipment behavior.

The example deliberately stops after the stated result. A real system adds headers, control elements, reference signals, coding quantization, scheduling gaps, retransmissions, timers, capability limits, and measurement uncertainty. Each of those comes from its own clause of the standard, so look it up there rather than guessing it from this simple arithmetic.

## 6. The 3GPP protocol: which document, and what it says

The example estimated. This section names the clauses that compute exactly, and draws their encodings and formulas.

Clause 5 is the downlink recipe, clause 6 the uplink, and both end in a block size. The figure draws the start-and-length and resource-indicator encodings, a modulation-and-coding table row, the transport-block-size formula, the channel-quality definition, and the decode and preparation times, and sets each beside the configuration line that selects it and the log line that shows it evaluated.

![[99 Attachments/5G/Protocol Figures/STAR-32-TS-38.214-Protocol.png|The allocation fields, the modulation-and-coding tables, the transport-block-size formula, channel-state reporting and processing times of TS 38.214, with the configuration lines each becomes]]

*Protocol figure: The allocation fields, the modulation-and-coding tables, the transport-block-size formula, channel-state reporting and processing times of TS 38.214, with the configuration lines each becomes.*

| Clause | Scope | What to read it for |
|---|---|---|
| 4 | downlink power allocation and receiver assumptions | the power relationships that turn a measurement into a decoding decision |
| 5.1 | PDSCH reception and the general downlink data procedure | the order of operations from grant to delivered block |
| 5.1.2 | PDSCH resource allocation interpretation | how allocation type and bandwidth-part size change what identical bits mean |
| 5.1.3 | MCS, modulation order, target code rate, redundancy version, TBS | the arithmetic from an index to a block size; no term may be assumed |
| 5.1.4 | PRB bundling | where the receiver may assume the precoder constant |
| 5.1.5 | antenna ports and quasi-co-location | what a device may infer about one signal from another |
| 5.2 | CSI configuration, measurement, and reporting | what was measured, what assumed, and when the report was valid |
| 5.3 | PDSCH processing time | the floor under the acknowledgement delay |
| 6.1 | PUSCH transmission procedure | what the grant fixes and what the device still chooses |
| 6.1.1 | PUSCH precoding, layers, and spatial operation | who decides the precoder in codebook and non-codebook modes |
| 6.1.2–6.1.4 | uplink allocation, MCS, and transport-block interpretation | the uplink mirror of clause 5.1 |
| 6.2 | SRS procedures | how the network learns the uplink channel |
| 6.4 | PUSCH preparation time | the floor under the grant-to-transmission delay |

The official text is [TS 38.214 V18.10.0, official archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf).

!note[**When you build or run a demo.** Throughput in a demo is this document evaluated once per slot. The modulation-and-coding table selected in the configuration caps the modulation order; the time-domain allocation list is the set of rows a grant may name, and a list with only short rows caps throughput before the radio is involved; the allocation type decides whether the frequency field is one integer or a bitmap. The channel-state report's period and quantities decide how quickly the scheduler notices a change, and a demo whose rate collapses when someone walks past has a slow or absent report. The physical-layer log prints the index, the modulation order, the rate, the blocks, the symbols, the layers, and the resulting block size on one line, and the block-size formula is the check that the log agrees with the configuration. What the log never prints is why the scheduler chose that row, which the standard leaves to the implementation.]

Release 15 established the allocation types, the modulation-and-coding tables, the size calculation, channel-state reporting, and the processing-time tables. Release 16 and Release 18 added tables for higher modulation and lower spectral efficiency, repetition types, multi-point and multi-panel operation, and reduced-capability branches while preserving the chain; the fixed V18.10.0 text controls the exact conditions. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states formulas; the engineering pages work them on captured grants.

ShareTechnote's [PDSCH page](https://www.sharetechnote.com/html/5G/5G_PDSCH.html) and [PUSCH page](https://www.sharetechnote.com/html/5G/5G_PUSCH.html) each end with a worked transport-block-size calculation from a captured grant, its [MCS page](https://www.sharetechnote.com/html/5G/5G_MCS_TBS_CodeRate.html) lays out the modulation and coding scheme tables and the transport block size procedure step by step, and its [CSI page](https://www.sharetechnote.com/html/5G/5G_CSI_Report.html) decodes a real report. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

The learning sequence is recorded in Course Alignment.

This Star aligns with course units [U03, U04, U05, U11, U12]. It can be taught in three passes. The first pass names entities, channels, PDUs, and state variables. The second pass follows one success trace and one failure or retransmission trace. The third pass reads an exact clause and reconstructs a log table. Students should already understand the NR resource grid, control/data channels, coding, and protocol layering appropriate to the listed units.

A good assessment gives a trace with one deliberately ambiguous label. Students must replace it with the correct layer, object, identifier, and clause. They then recompute the worked example after changing one assumption and explain whether the standard or the implementation chooses the new behavior. This tests causal understanding rather than acronym recall.

## 9. Common confusions

The four sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 MCS uniquely determines throughput

!warning[MCS is one input. Allocation, overhead, layers, TBS quantization, retransmissions, power limitation, and scheduling gaps change delivered throughput.]

### 9.2 TS 38.214 contains the whole PHY

!warning[It is a procedures document. Mapping is in TS 38.211, coding in TS 38.212, control/timing in TS 38.213, measurements in TS 38.215, and configuration in TS 38.331.]

### 9.3 A grant guarantees transmission success

!warning[A grant defines an opportunity and parameters. Channel access, power, timing, interference, channel estimation, and decoder outcome remain decisive.]

### 9.4 CSI is the effective channel used for decoding

!warning[CSI supports adaptation and reporting; scheduled DM-RS supports effective-channel demodulation. Their resources and purposes differ.]

A final diagnostic rule applies to every confusion: ask “Which entity owns this state, which object is identified, what triggers the transition, and where is it carried?” If the answer mixes a MAC PDU with UCI, an RLC PDU with a transport block, or a scheduler policy with a receiver procedure, return to the clause map before continuing.

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. TS 38.214 V18.10.0 first-pass extraction — navigation and provenance route of this knowledge base.
2. [TS 38.214 V18.10.0 official archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) — official frozen artifact and clause authority.
3. Course Alignment — instructional placement.
- [ShareTechnote: 5G PDSCH](https://www.sharetechnote.com/html/5G/5G_PDSCH.html) — accessed 2026-08-03; engineering expression only.
- [ShareTechnote: 5G PUSCH](https://www.sharetechnote.com/html/5G/5G_PUSCH.html) — accessed 2026-08-03; engineering expression only.
- [ShareTechnote: 5G MCS, TBS, and code rate](https://www.sharetechnote.com/html/5G/5G_MCS_TBS_CodeRate.html) — accessed 2026-08-03; engineering expression only.

All cited external links appear earlier in the explanatory body. The source note and course alignment are internal evidence, the official archive is official, ShareTechnote is engineering expression, and the ledger records reuse and correction decisions.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| CSI | Channel state information | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| CSI-RS | CSI reference signal | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| DCI | Downlink control information | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| DM-RS | Demodulation reference signal | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| gNB | next-generation NodeB | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| HARQ | Hybrid automatic repeat request | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| MCS | Modulation and coding scheme | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| PDSCH | Physical downlink shared channel | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| PRB | Physical resource block | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| PT-RS | Phase-tracking reference signal | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| PUSCH | Physical uplink shared channel | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| QCL | Quasi-co-location | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| SRS | Sounding reference signal | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| TBS | Transport block size | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| UE | User equipment | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.214](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit/domain | Role |
|---|---|---|---|
| $N_PRB$ | number of allocated physical resource blocks | count | mechanism or worked example |
| $N_sym$ | usable data symbols | count | mechanism or worked example |
| $Q_m$ | modulation order in bits per symbol | bit/RE/layer | mechanism or worked example |
| $R$ | teaching code-rate factor | dimensionless | mechanism or worked example |
| $v$ | transmission layers | count | mechanism or worked example |
| $N_RE$ | estimated payload resource elements | RE | mechanism or worked example |
| $R_slot$ | estimated slot payload rate | bit/s | mechanism or worked example |
