---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 30
title: TS 38.212 Multiplexing and Channel Coding
language: en
course_units:
- U03–U05 and U11–U14
release_baseline: 18
---

# STAR-30 — TS 38.212 Multiplexing and Channel Coding

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf) — TS 38.212 V18.8.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

TS 38.212 takes the bits a layer above wants sent and prepares them for a channel that will damage some of them. Nothing here is a symbol yet; it is bits in, more bits out. Picture wrapping a parcel for a rough journey.

![[99 Attachments/5G/Concept Figures/STAR-30-TS-38.212-Concept.png|TS 38.212 explained as wrapping a parcel for a rough journey]]

*Concept figure: TS 38.212 explained as wrapping a parcel for a rough journey.*

First, add a check digit: a 24-bit cyclic redundancy check on the whole block, so the receiver can tell correct from wrong with near certainty. Second, cut into pieces: a block bigger than 8448 bits is split into equal code blocks, each with its own check, so the decoder works on pieces it can hold. Third, add padding that helps: LDPC codes for data and polar codes for control weave in redundancy so that missing or damaged bits can be reconstructed. Fourth, trim to the box: rate matching picks exactly as many coded bits as the allocation holds, and a later retry sends a different window of them. Fifth, let a note ride along: control information can be multiplexed onto the data channel within a fixed budget, so the receiver can pull it back out. Sixth, hand over the bits: the result is a bit sequence and no more; modulation, layers, ports, and squares belong to TS 38.211.

Why two codes? Data blocks are long and arrive constantly, and LDPC decodes them fast in parallel. Control messages are short and must not fail, and polar codes are best at short lengths. The tiniest payloads, one or two feedback bits, use repetition or a simplex code. Why is a retry not a repeat? The encoder makes about three times as many bits as the box holds; the first attempt sends one window, a retry sends a different window, a redundancy version, so two damaged copies add up to more than either. That is Star 13's soft combining. The key fact to carry is that the check digit detects, the code corrects, and rate matching decides which coded bits are actually sent; they fail in different ways.

**The question this chapter answers.** How does TS 38.212 turn information bits into coded sequences of exactly the length an NR physical-channel allocation needs?

!important[**The short answer.** Clause 5 defines reusable tools: CRC, segmentation, LDPC and polar coding, short-block codes, and rate matching. Clause 6 applies them to uplink transport and control, clause 7 to the broadcast channel, downlink shared and paging transport, and control information, and clause 8 to sidelink. Shared and paging channels use LDPC; the broadcast channel and control information use polar codes; uplink control selects short-block or polar processing by payload. TS 38.212 ends at coded, multiplexed bits, before TS 38.211 modulates and maps them.]

Names you will meet in this note: transport block (TB), code block (CB), cyclic redundancy check (CRC), low-density parity-check (LDPC), base graph (BG), lifting size ($Z_c$), broadcast channel (BCH), downlink and uplink shared channel (DL-SCH, UL-SCH), paging channel (PCH), downlink and uplink control information (DCI, UCI), hybrid automatic repeat request (HARQ), redundancy version (RV), channel-state information (CSI), scheduling request (SR).

This note teaches the fixed clause map of this knowledge base and 3GPP [TS 38.212 V18.8.0](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf). The extraction is a navigation aid; the official file is official, and the course manifest records its hash and retrieval date.

## 2. Where you are in 5G

Section 1 wrapped a parcel for a rough journey. The map below shows where TS 38.212 sits in 5G: between the bits of MAC and the symbols of TS 38.211.

![[99 Attachments/5G/Locator Maps/STAR-30-Where-You-Are-in-5G.png|Where Star 30 sits in the whole 5G system]]

*Locator: Where Star 30 sits in the whole 5G system.*

This chapter lights the coding document of the specification band: the written form of the transport-channel processing of Star 09 and the redundancy versions that Star 13's retransmissions rely on. It sits between MAC, Star 33, which hands it transport blocks, and TS 38.211, Star 29, which takes its bits, with the procedures of Stars 31 and 32 deciding the lengths.

The Knowledge Structure Map draws the coding ownership chain. The mechanism diagram traces one payload from information bits to coded bits.

![[99 Attachments/5G/Knowledge Maps/STAR-30-TS-38.212-Knowledge Structure Map.png|STAR-30 system-position map]]

*Knowledge map: TS 38.212 — how payload class and size select a channel code.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-30-TS-38.212-Coding-Ownership-Chain.png|Star 30 mechanism and handoff diagram]]

*Mechanism: TS 38.212 coding ownership: shared tools serving two directions.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.212 V18.8.0, clause 5, PDF page 11](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.212 V18.8.0, clause 5, PDF page 11, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [Channel-coding overview](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html). The reproduced image is omitted from this distribution.

*Source excerpt: Channel-coding overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> Treat the map sidebar as schematic. The official clause ownership is: **clause 5 = general coding**, **clause 6 = uplink**, **clause 7 = downlink and DCI**. **DL-SCH, UL-SCH, and PCH use LDPC; BCH and DCI use polar; UCI selects short-block or polar processing by payload and carriage.** The body clause map is authoritative.

> [!note] Searchable structure
> Information payload → CRC and segmentation → LDPC, polar, or short-block family → rate matching and multiplexing → coded bits for physical mapping.

Read the map as a routing diagram: a box is an owned concept or transformation, an arrow a handoff. When a trace diverges, walk one arrow upstream and compare the exact input object, configuration, release, and integer. 

## 3. Foundations and prerequisites

Section 2 placed the document. Five foundations follow: how the payload type picks the branch, why CRC and code are separate, why the mother code differs from what is sent, what multiplexing preserves, and where the bits go next.

### 3.1 Payload type chooses the processing branch

The first foundation is that there is no universal code: the payload type picks the branch.

Transport data, broadcast information, downlink control, and uplink control have different lengths, latencies, and decoder constraints, and TS 38.212 applies no universal code. The first debugging field is payload or channel type.

> [!spec] 3GPP reality check
> The mapping from each transport channel and control type to its coding branch is the entry table of [TS 38.212 V18.8.0, clause 4](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf); the branches themselves are clauses 6 and 7.

### 3.2 CRC and code are separate protections

Whatever the branch, two protections apply. This section keeps them apart.

!important[A CRC supports detection and decoder selection; the code adds redundancy for correction. A transport-block CRC protects the reconstructed block, and code-block CRCs protect the segments. Passing a parity check or iterative convergence does not replace the final CRC decision.]

### 3.3 Mother code and scheduled sequence differ

Section 3.2 separated detection from correction. This section separates the code from the sequence that is actually sent.

!important[Encoding creates an internal coded structure; rate matching selects, punctures, shortens, or repeats bits to produce the scheduled length, and the redundancy version moves the selection window. The received length is not the mother-code length.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [LDPC page](https://www.sharetechnote.com/html/5G/5G_LDPC.html) draws the circular buffer with the four redundancy-version start points marked, which is the picture that makes "a different window" concrete.

### 3.4 Multiplexing preserves semantic streams

Section 3.3 was about one stream. This section is about several streams sharing one allocation.

Uplink data may share an allocation with acknowledgements, channel-state reports, and other control. The standard computes budgets and interleaves the streams so the receiver can reverse them; multiplexing is controlled combination.

### 3.5 TS 38.212 hands bits to TS 38.211

The last foundation is the handoff: where TS 38.212 stops and TS 38.211 begins.

After coding, rate matching, concatenation, and multiplexing the result is a bit sequence. Modulation, layer mapping, antenna ports, reference signals, and resource mapping belong to TS 38.211 and the procedures of TS 38.213 and 38.214.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clause 5 supplies general coding tools

The walk starts with clause 5, the toolbox.

Clause 5 covers CRC calculation, code-block segmentation, LDPC coding and rate matching, polar coding and rate matching, small-block methods, and concatenation. They are reusable functions; clauses 6 to 8 decide which applies to a named information type with which parameters.

> [!spec] 3GPP reality check
> CRC polynomials are [TS 38.212 V18.8.0, clause 5.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf); segmentation and base-graph selection are clause 5.2.2; LDPC encoding and lifting sizes are clause 5.3.2 with rate matching in 5.4.2; polar encoding is clause 5.3.1 with rate matching in 5.4.1.

### 4.2 Clause 6 owns uplink processing

Section 4.1 listed the tools. This section reads clause 6, which applies them to the uplink.

Uplink shared-channel processing attaches the transport-block CRC, segments when required, selects a base graph and lifting size, encodes, rate-matches, and concatenates. Uplink control processing selects small-payload coding or polar processing and maps or multiplexes control bits for the control channel or onto the data channel.

### 4.3 Clause 7 separates three downlink families

Section 4.2 covered the uplink. This section reads clause 7, where the downlink splits into three families.

The broadcast channel uses polar coding. The downlink shared and paging channels follow the LDPC chain. Downlink control appends a CRC masked by the addressee's identity, uses polar coding, rate-matches, and produces a sequence for the control channel. "Downlink coding" as one phrase hides three branches.

### 4.4 HARQ changes the representation and keeps the information

Section 4.3 named the families. This section asks what a retransmission changes and what it keeps.

A retransmission of the same block may use a different redundancy version. TS 38.212 owns version-dependent rate matching and recovery and the construction of control fields; it does not own HARQ state. TS 38.321 owns the process and the new-data indicator, and TS 38.213 and 38.214 the procedures. The receiver interprets the indicator, the process identifier, and the version together without assigning all three to one document.

### 4.5 UCI selection is payload dependent

Section 4.4 covered data. This section covers uplink control, whose coding depends on its length.

Very short control payloads use short-block procedures; larger ones use polar coding, with the threshold and construction depending on the clause and on whether the information rides on the control channel or is multiplexed with data. "UCI uses polar" is incomplete.

> [!spec] 3GPP reality check
> The uplink control branches and the multiplexing budget on the data channel, with its β offsets, are TS 38.212 clauses 6.3.1 to 6.3.2; the β values are configured through TS 38.331 BetaOffsets.

### 4.6 Length ledgers prevent implementation drift

The walk ends with the habit that prevents implementation drift: a table of lengths.

!note[Record the information length, CRC length, post-CRC length, code-block count, filler bits, base graph or polar parameters, rate-matched length, modulation order, layers, and total bit count, and at every handoff verify that transmitter and receiver derived the same integer. Mirror the ledger on the receive side before processing samples: a decoder that infers a different block count or length is solving a different problem and cannot be repaired with more iterations, so comparing integers before soft values separates configuration failure from channel failure. Log the branch predicate as data, so that later release comparisons stay reliable. For HARQ, record the process, the new-data indicator, the version, soft-buffer occupancy, attempts, and the final CRC result, because rate recovery must place received soft bits into the same mother-code coordinates as earlier attempts. For multiplexed control, compare each stream's information length, coded length, placement, and its own check before judging the combined outcome.]

## 5. Worked example

Section 4 walked the clauses. Section 5 runs one small calculation through them.

### 5.1 Worked numerical example

The example below is deliberately small: one calculation that shows how a number in this document is traced to its clause.

The example is intentionally small. It demonstrates local traceability and does not claim to reproduce a complete conformance vector.

**What we are working out.** Instructional effective coded-bit ratio after a 24-bit TB CRC is attached to a 10,000-bit payload and mapped into a 14,400-bit allocation.

$$
\begin{aligned}
R_{eff} &= \frac{A+L_{TBCRC}}{G} \\ &= \frac{10000\ \mathrm{bit}+24\ \mathrm{bit}}{14400\ \mathrm{bit}} \\ &= 0.696
\end{aligned}
$$

Where:

- $R_{eff}$ = 0.696, calculated (local ratio); it belongs to the coded-bit allocation.
- $A$ = 10000 bit, assumed (illustrative TB payload); it belongs to the MAC-to-PHY transport block.
- $L_{TBCRC}$ = 24 bit, reported (TS 38.212 clauses 6.2.1/7.2.1); it belongs to the transport-block CRC.
- $G$ = 14400 bit, assumed (illustrative allocation input); it belongs to the rate-matched output budget.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $R_{eff}$ | 0.696 | calculated | local ratio | coded-bit allocation |
| $A$ | 10000 bit | assumed | illustrative TB payload | MAC-to-PHY transport block |
| $L_{TBCRC}$ | 24 bit | reported | TS 38.212 clauses 6.2.1/7.2.1 | transport-block CRC |
| $G$ | 14400 bit | assumed | illustrative allocation input | rate-matched output budget |

The displayed result is rounded only after the local substitution. Bits cancel, so the ratio is dimensionless. The 24-bit term is the cited TB-CRC length for the applicable shared-channel example. This proxy does not replace base-graph selection, segmentation, filler bits, per-CB rate matching, modulation, layers, or decoder-performance evidence.

The engineering check asks whether all operands share the declared boundary and whether an omitted cap, branch, state, overhead, or companion procedure could change the decision. If so, the next step is to restore that term rather than add false precision.

The ratio also needs a direction-of-change interpretation. Holding the payload fixed while increasing G lowers the proxy and provides more coded-bit positions for the scheduled transmission, but it consumes more radio resources. Holding G fixed while increasing A raises the proxy and leaves less redundancy. Neither direction alone predicts block error rate because the LDPC base graph, lifting, filler pattern, rate-matching selection, modulation, layer mapping, channel estimate, and decoder implementation also matter. The ratio is an accounting diagnostic; matched BLER evidence answers the reliability question.

The numerator deliberately includes the TB CRC because those bits enter the shared-channel coding chain. It does not include every internal overhead bit: segmentation can add CB CRCs, and the selected coding structure can contain filler or parity positions that do not represent new information. The denominator is the rate-matched output budget G. Converting a resource allocation into G requires modulation order, layer count, and channel-specific resource exclusions from the companion PHY procedures.

A receiver check can now be stated without another equation. Confirm that both ends use the same A, CRC rule, segmentation outcome, code family, and G; confirm that the selected RV is placed into the expected circular-buffer coordinates; and only then interpret decoder convergence and CRC outcome. If the integers disagree, repair configuration or procedure handling. If they agree and the CRC still fails, investigate channel estimation, soft-demodulation scaling, interference, decoder performance, or insufficient redundancy.

## 6. The 3GPP protocol: which document, and what it says

The example used one chain. This section names which clause fixes each number and draws the equations.

Clause 5 is the toolbox; clauses 6 and 7 say which tool each payload gets. The figure draws the CRC lengths and the identity hidden in the control CRC, the base-graph rule and code-block count, the mother-code lengths of LDPC and polar coding, the redundancy-version start positions in the circular buffer, and the share of an allocation given to multiplexed feedback, and sets each beside the configuration line or log line it becomes.

![[99 Attachments/5G/Protocol Figures/STAR-30-TS-38.212-Protocol.png|The coding chain of TS 38.212: check, segment, encode, rate-match and multiplex, with the clauses, thresholds and the configuration lines each becomes]]

*Protocol figure: The coding chain of TS 38.212: check, segment, encode, rate-match and multiplex, with the clauses, thresholds and the configuration lines each becomes.*

| Clause | Fixed V18.8.0 scope | Reader question |
|---|---|---|
| 4 | mapping of transport and control information to physical channels | which branch does this payload take? |
| 5 | general coding: CRC, segmentation, LDPC, polar, short-block, rate matching | which tool, with which parameters? |
| 6 | uplink: UL-SCH plus UCI construction, coding, multiplexing | what does the UE encode, and how does control ride along? |
| 7 | downlink: BCH, DL-SCH and PCH, DCI construction and coding | what does the gNB encode, and how is a grant addressed? |
| 8 | sidelink transport and control-information processing | what changes between UEs? |

The official text is [TS 38.212 V18.8.0, official archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf).

!note[**When you build or run a demo.** Almost nothing in this document is configured directly; it is derived. The modulation-and-coding table chosen in the configuration fixes the code rate, which with the block size chooses the base graph and the segmentation. The redundancy-version sequence for retransmissions is one line. The β offsets that decide how much of a data allocation feedback may take are two or three lines. Everything else appears in the physical-layer log: a transport block's size, its code-block count, its base graph and lifting size, the redundancy version of each attempt, and the rate-matched length. A demo whose phone decodes nothing while the radio looks healthy has, more often than not, a transmitter and a receiver disagreeing on one of those integers.]

Release 15 established the LDPC, polar, short-block, and multiplexing framework. Release 16 and Release 18 add information types, lengths, tables, sidelink, and newer feature paths while keeping the clause ownership; the fixed V18.8.0 text controls the exact branches, and a Release 15 tutorial that omits later formats must not be used to reassign coding families. Release 18 is a family of coordinated versions; a later corrective version is recorded as a clause-level delta. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states rules; the engineering pages draw the chain.

ShareTechnote's [channel coding](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html) page draws the chain of this chapter as a block diagram with the branch for each payload, its [LDPC](https://www.sharetechnote.com/html/5G/5G_LDPC.html) page shows a base graph and the circular buffer with the redundancy-version start points, its [polar coding](https://www.sharetechnote.com/html/5G/5G_PolarCoding.html) page walks a small example by hand, and its [UCI](https://www.sharetechnote.com/html/5G/5G_UCI.html) page shows what multiplexed feedback looks like inside a data allocation. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

This note supports U03–U05 and U11–U14. Before class, review binary representation, decibels, probability, protocol layering, and the relevant resource-grid concepts. During class, use Section 4 to locate ownership, Section 5 to audit one calculation, and Section 6 to navigate the fixed specification. Afterwards, connect the clause to a configuration or trace. The maintained course crosswalk remains unchanged.

This Star is a protocol map. It becomes useful when a student asks which document owns a statement, what representation crosses a boundary, or why two apparently similar terms have different test procedures.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “Clause 5 is uplink coding”

!warning[Clause 5 is the general toolbox. Clause 6 is uplink; clause 7 is downlink/DCI. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.2 “All NR data and control use LDPC”

!warning[UL/DL-SCH and PCH use LDPC; BCH/DCI use Polar; UCI selects short-block or Polar. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.3 “Rate matching is channel coding”

!warning[It adapts a coded structure to the scheduled length and RV. It does not create the mother code. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.4 “Scrambling and coding are the same”

!warning[Coding adds controlled redundancy. Scrambling changes bit appearance and belongs later in the physical-channel chain. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.5 “TS 38.212 maps constellation symbols”

!warning[It produces coded/multiplexed bits. TS 38.211 owns modulation and resource mapping. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.212 V18.8.0: Multiplexing and Channel Coding*, [official PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf).
2. Clause map of this knowledge base.
4. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm).
5. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
6. ShareTechnote, [channel coding](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html), accessed 2026-08-03.
7. ShareTechnote, [LDPC](https://www.sharetechnote.com/html/5G/5G_LDPC.html), accessed 2026-08-03.
8. ShareTechnote, [Polar coding](https://www.sharetechnote.com/html/5G/5G_PolarCoding.html), accessed 2026-08-03.
9. ShareTechnote, [UCI](https://www.sharetechnote.com/html/5G/5G_UCI.html), accessed 2026-08-03.
10. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; TS 38.212 V18.8.0 |
| TB | Transport Block | Section 1; TS 38.212 V18.8.0 |
| CB | Code Block | Section 1; TS 38.212 V18.8.0 |
| CRC | Cyclic Redundancy Check | Section 1; TS 38.212 V18.8.0 |
| LDPC | Low-Density Parity-Check | Section 1; TS 38.212 V18.8.0 |
| BCH | Broadcast Channel | Section 1; TS 38.212 V18.8.0 |
| DL-SCH | Downlink Shared Channel | Section 1; TS 38.212 V18.8.0 |
| UL-SCH | Uplink Shared Channel | Section 1; TS 38.212 V18.8.0 |
| PCH | Paging Channel | Section 1; TS 38.212 V18.8.0 |
| DCI | Downlink Control Information | Section 1; TS 38.212 V18.8.0 |
| UCI | Uplink Control Information | Section 1; TS 38.212 V18.8.0 |
| HARQ | Hybrid Automatic Repeat Request | Section 1; TS 38.212 V18.8.0 |
| RV | Redundancy Version | Section 1; TS 38.212 V18.8.0 |
| ACK | Acknowledgement | Section 1; TS 38.212 V18.8.0 |
| CSI | Channel State Information | Section 1; TS 38.212 V18.8.0 |
| SR | Scheduling Request | Section 1; TS 38.212 V18.8.0 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $R_{eff}$ | Instructional post-TB-CRC ratio | dimensionless |
| $A$ | Transport-block payload length | bit |
| $L_{TBCRC}$ | TB CRC length | bit |
| $G$ | Rate-matched coded-bit budget | bit |

The symbols mean what they mean in this note; another note may use the same letter for something else.
