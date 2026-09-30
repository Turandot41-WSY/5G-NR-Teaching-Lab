---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 34
title: TS 38.322 — Radio Link Control
language: en
course_units:
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-34 — TS 38.322 Radio Link Control

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) — TS 38.322 V18.2.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

The truck below is never the size of the letter above. RLC cuts letters to fit, numbers the pieces, and, in one mode, asks by number for the pieces that never arrived. There are three ways to send a long letter, and each bearer picks one.

![[99 Attachments/5G/Concept Figures/STAR-34-TS-38.322-Concept.png|TS 38.322 explained as three ways to send a long letter]]

*Concept figure: TS 38.322 explained as three ways to send a long letter.*

Transparent mode does no cutting, no numbering, and no asking; it is for messages that fit whole and need no reply, broadcast and paging, and it promises nothing and adds nothing. Unacknowledged mode cuts and numbers the pieces so the receiver can rebuild the letter, but never asks for missing ones; it is for voice and video, where late is worse than lost, and it promises order but not delivery. Acknowledged mode cuts, numbers, and asks: the receiver reports which numbers it has and lacks, the sender resends those, and a window keeps them in step; it is for everything that must arrive, and it promises delivery at a cost in delay.

The asking works by polling. The sender sets a poll flag every so many pieces or bytes, or when it runs out of things to send; the receiver answers with a status, "I have everything up to number N, except these numbers, and of this one only bytes 0 to 511"; the sender resends exactly those. After too many resends of one piece it gives up and the whole link is declared failed; RLC never loses a piece quietly. This is not HARQ: HARQ, one layer down, repairs a truck within a millisecond with one bit and no numbers and is occasionally wrong, while RLC repairs letters within tens of milliseconds by number and is never wrong but slow. The fast loop catches almost everything and the slow loop catches what the fast one misheard; that division is Star 13, and this chapter is the slow loop's manual. The key fact to carry is that the mode is chosen per bearer and fixes what the layer above may assume, and that a window that fills stalls the sender however many trucks are offered.

**The question this chapter answers.** How does NR RLC segment and reassemble higher-layer data, preserve sequence context, choose transparent, unacknowledged, or acknowledged service, and repair residual losses without confusing its loop with MAC HARQ?

!important[**The short answer.** TS 38.322 defines the RLC entities and PDUs between PDCP and MAC. Transparent mode transfers data with minimal processing. Unacknowledged mode adds sequence numbering, segmentation and reassembly, reordering, and loss detection without retransmission. Acknowledged mode adds polling, status feedback, retransmission, and transmit and receive windows. Clause 4 defines the architecture, clauses 5.1 and 5.2 entity handling and data transfer, clause 5.3 the ARQ procedures, clause 6 the PDU formats, and clause 7 the variables, constants, timers, and parameters.]

Names you will meet in this note: transparent, unacknowledged, and acknowledged mode (TM, UM, AM), automatic repeat request (ARQ), hybrid ARQ (HARQ), protocol and service data unit (PDU, SDU), sequence number (SN), segment offset (SO), segmentation info (SI), status PDU, negative acknowledgement (NACK), Packet Data Convergence Protocol (PDCP).

The clause map of this knowledge base (first-pass extraction) provides the navigation route; the fixed authority is [TS 38.322 V18.2.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf). A reliable reading keeps four planes apart: official, configuration, implementation, and teaching.

## 2. Where you are in 5G

Section 1 cut letters to fit trucks. The map below shows where RLC sits in 5G: between PDCP and MAC, once per logical channel.

![[99 Attachments/5G/Locator Maps/STAR-34-Where-You-Are-in-5G.png|Where Star 34 sits in the whole 5G system]]

*Locator: Where Star 34 sits in the whole 5G system.*

This chapter lights the RLC layer of the protocol stack in the specification band: the written form of the slow, numbered retransmission loop of Star 13, sitting between PDCP, Star 35, above and MAC, Star 33, below, with its mode and timers configured by RRC, Star 36.

The Knowledge Structure Map draws the segmentation and recovery chain. The mechanism diagram traces one service data unit through it.

![[99 Attachments/5G/Knowledge Maps/STAR-34-TS-38.322-Knowledge Structure Map.png|STAR-34 system-position map]]

*Knowledge map: TS 38.322 — what each RLC mode does and does not promise.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-34-RLC-Segmentation-and-Recovery-Chain.png|Star 34 mechanism and handoff diagram]]

*Mechanism: TS 38.322 — segmentation, loss and byte-range repair.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.322 V18.2.0, clause 5, PDF page 13](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.322 V18.2.0, clause 5, PDF page 13, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [RLC overview](https://www.sharetechnote.com/html/5G/5G_RLC.html). The reproduced image is omitted from this distribution.

*Source excerpt: RLC overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_RLC.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> The map's "10s–100s ms" label is not a official acknowledged-mode delay range. RLC latency depends on configured timers, grant opportunities, HARQ behaviour, discontinuous reception, load, loss pattern, retransmission segmentation, and implementation. Inspect the clause 7 timer values and clause 5 triggers for the configured bearer.

**Searchable structure.** SDU → segmentation and numbering → PDU to MAC → receive window and reassembly → poll and status → retransmission or give-up → delivery to PDCP.

Read the map as a dependency graph: inputs arrive from configuration, grants, and the peer's status; the entity evaluates clause-defined state, produces a PDU, a status, or a state transition, and consumes feedback. 

## 3. Foundations and prerequisites

Section 2 placed the layer. Three foundations follow: units and segments, the three modes, and how RLC's repair differs from HARQ's.

### 3.1 SDUs, PDUs, and segmentation

The first foundation is what RLC receives, what it produces, and how the pieces are numbered.

RLC receives service data units from PDCP and builds protocol data units for MAC. A large unit may be segmented across several PDUs, and a retransmission may re-segment under the acknowledged-mode rules. The sequence number and segment offset let the receiver place bytes correctly, and reassembly delivers complete units rather than radio fragments.

> [!spec] 3GPP reality check
> The data PDU header with its segmentation-info, sequence-number, and segment-offset fields is [TS 38.322 V18.2.0, clause 6.2.2](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf); the sequence-number lengths are clause 7.1 and the RRC choice is TS 38.331's RLC-Config.

### 3.2 TM, UM, and AM service choices

Section 3.1 numbered the pieces. This section gives the three modes and what each does with them.

!important[Transparent mode minimises processing where headers and retransmission are unnecessary. Unacknowledged mode detects gaps and supports reordering and reassembly but does not retransmit. Acknowledged mode adds bidirectional behaviour: polling, status PDUs, retransmission buffers, and windows. The mode is configured per bearer; a packet does not change mode because one attempt failed.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [RLC page](https://www.sharetechnote.com/html/5G/5G_RLC.html) tabulates the three modes against the bearers that use them, which is the quickest way to see why signalling and data ride acknowledged mode while voice rides unacknowledged.

### 3.3 RLC ARQ versus MAC HARQ

Section 3.2 named a mode that retransmits. This section separates that repair from the faster one MAC already does.

!important[HARQ retries transport blocks quickly and combines soft information; acknowledged-mode RLC works on sequence and byte state after residual loss, with longer configurable feedback. One RLC PDU can cross several transport blocks and one block can carry several logical channels, so layer identity must be preserved in traces. When you read a radio log, first say which object, which entity and which state each row belongs to; control, data, feedback and retransmissions sit on neighbouring rows and are easy to mix up.]

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the mechanism from transmitter to receiver.

### 4.1 Transmit-side construction

The walk starts on the transmit side.

The transmitter accepts units, assigns sequence context where the mode requires, segments under the mode rules to fit the grant, and submits PDUs to MAC; acknowledged mode retains retransmittable data and state, and polling triggers request a status based on counters, buffer state, or a timer.

> [!spec] 3GPP reality check
> Polling by count of PDUs or bytes, on empty buffers, and on the poll-retransmit timer is [TS 38.322 V18.2.0, clause 5.3.1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf); acknowledged-mode transmission and the window it must respect are clause 5.2.3.1.

### 4.2 Receive-side reassembly

Section 4.1 sent segments. This section reassembles them.

The receiver places byte ranges in its window by sequence number and segmentation information, delivers complete units under the mode's ordering rules, handles duplicates and out-of-window data by procedure rather than passing them up, and holds reassembly state across gaps until timers or status logic advance the window.

### 4.3 STATUS and retransmission

Section 4.2 found gaps. This section reports them and retransmits.

A status PDU carries an acknowledgement boundary plus zero or more negative acknowledgements, each possibly with segment offsets or a range; the transmitter obtains retransmission opportunities through MAC while RLC decides which retained bytes remain outstanding.

> [!spec] 3GPP reality check
> The status PDU with its ACK_SN, NACK_SN, SOstart, SOend, and range fields is TS 38.322 clause 6.2.2.5, its triggering and the status-prohibit timer clause 5.3.4, and the retransmission count and the threshold that indicates failure to RRC clause 5.3.2.

### 4.4 Timers and latency boundary

The walk ends with the timers that bound all of the above, and what they mean for latency.

The poll-retransmit, reassembly, and status-prohibit timers regulate polling recovery, window progression, and feedback frequency; their values come from allowed sets, and observed delay also depends on grants, discontinuous reception, HARQ, load, losses, and implementation, so no universal acknowledged-mode latency exists. A six-column trace, each row citing its clause, keeps the account reproducible, and error handling belongs inside the mechanism because an expired timer or an out-of-window number changes the next legal action.

## 5. Worked example

Section 4 walked the mechanism. Section 5 builds one status report, a calculation you can redo by hand.

Assume an AM transmitter sent SN 100 as two byte segments [0,499] and [500,999], and the receiver obtained only the first segment. It also received complete SN 101. A teaching STATUS report sets ACK_SN to 102 and NACKs SN 100 with segment offsets 500 through 999.

**What we are working out.** The example derives the resource, buffer, or retransmission quantity needed to test the mechanism.

$$
\begin{aligned}
B_{\mathrm{SN100}}&=1000\ \mathrm{bytes},\\
B_{\mathrm{received}}&=500\ \mathrm{bytes},\\
B_{\mathrm{missing}}&=1000-500\\
&=500\ \mathrm{bytes},\\
\eta_{\mathrm{reTX}}&=\frac{500}{1000}=0.50.
\end{aligned}
$$

**Immediate guide.** The sequence numbers, byte ranges, and status construction are pedagogical. The 500-byte missing range demonstrates segment-specific retransmission efficiency: retransmitting only missing bytes can avoid repeating the already received half, subject to exact AM segmentation and PDU-format rules. ACK_SN and NACK semantics must be read from clauses 5.3 and 6; ACK_SN must not be interpreted as a generic TCP-style cumulative acknowledgment without those definitions.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $SN$ | 100 | modular integer | pedagogical input or derived result |
| $SO_start$ | 500 | byte offset | pedagogical input or derived result |
| $SO_end$ | 999 | byte offset | pedagogical input or derived result |
| $B_SN100$ | 1000 | bytes | pedagogical input or derived result |
| $B_missing$ | 500 | bytes | pedagogical input or derived result |
| $eta_reTX$ | 0.50 | dimensionless | pedagogical input or derived result |

**Sanity check.** Units cancel only where expected, the result remains within the stated resource or data bound, and no discrete standardized table is silently replaced by a continuous approximation. A limiting-case check sets the available resource or missing amount to zero: the selected or transmitted quantity must also become zero. This check catches sign, range, and layer errors before a trace is compared with equipment behavior.

The example deliberately stops after the stated result. A real system adds headers, control elements, reference signals, coding quantization, scheduling gaps, retransmissions, timers, capability limits, and measurement uncertainty. Each of those comes from its own clause of the standard, so look it up there rather than guessing it from this simple arithmetic.

## 6. The 3GPP protocol: which document, and what it says

The example built a report. This section names what each clause fixes and draws the header bits.

Clause 5 is the three modes' behaviour; clause 6 is the header bits that carry it. The figure draws the sequence-number lengths and segment offset, the window condition, the polling triggers, the status format, and the retransmission threshold that leads to radio-link failure, and sets each beside the bearer's RLC configuration line that sets it and the log line that shows it.

![[99 Attachments/5G/Protocol Figures/STAR-34-TS-38.322-Protocol.png|The three RLC modes, the numbering, window, polling, status and give-up rules of TS 38.322, and the configuration lines each becomes]]

*Protocol figure: The three RLC modes, the numbering, window, polling, status and give-up rules of TS 38.322, and the configuration lines each becomes.*

| Clause | Scope | What to read it for |
|---|---|---|
| 4 | RLC architecture, modes, entities, services, functions | which entity exists in each mode and what it offers upward |
| 5.1 | establishment, re-establishment, release | what survives a re-establishment and what PDCP must recover |
| 5.2 | mode-specific data transfer | what each branch promises about delivery, ordering, and duplication |
| 5.2.2 | UM transfer and reassembly | how a missing segment is detected and how long the receiver waits |
| 5.2.3 | AM transfer and the window | what advances the window, what stalls it |
| 5.3 | ARQ: polling, status, retransmission | when the receiver reports and what is resent |
| 6.2 | data PDU formats and segmentation fields | the sequence number and offset that rebuild an SDU |
| 6.3 | control PDU and STATUS fields | the acknowledgement boundary and the negative list |
| 7.1–7.4 | state variables, constants, timers, parameters | every value a configuration sets |

The official text is [TS 38.322 V18.2.0, official archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf).

!note[**When you build or run a demo.** Each bearer's RLC configuration is a mode and, for acknowledged mode, half a dozen numbers: the sequence-number length, which sets the window; the poll counts and the poll-retransmit timer, which set how often the receiver is asked; the reassembly and status-prohibit timers, which set how long it waits and how often it may answer; and the retransmission threshold, which decides when a hole becomes a failed link. A demo whose throughput collapses under loss usually has a full window, visible in the log as a transmitter with data and grants but nothing to send. A demo that drops the connection after a bad patch has hit the threshold. The RLC log prints each status as an acknowledgement number and a list of missing numbers with byte offsets, which is the asking made visible.]

Release 15 established the three modes, the header formats, and the ARQ procedures. Release 16 and Release 18 add duplication and sidelink branches while keeping the clause ownership; the fixed V18.2.0 text controls the exact conditions. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states procedures; the engineering pages decode captured headers.

ShareTechnote's [RLC page](https://www.sharetechnote.com/html/5G/5G_RLC.html) draws the three PDU headers bit by bit and decodes a captured status PDU into its acknowledgement and negative-acknowledgement fields, which is the picture that makes "asking by number and offset" concrete; its window diagrams show a stalled transmitter as a full window. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

The learning sequence is recorded in Course Alignment.

This Star aligns with course units [U11, U12, U13, U14]. It can be taught in three passes. The first pass names entities, channels, PDUs, and state variables. The second pass follows one success trace and one failure or retransmission trace. The third pass reads an exact clause and reconstructs a log table. Students should already understand the NR resource grid, control/data channels, coding, and protocol layering appropriate to the listed units.

A good assessment gives a trace with one deliberately ambiguous label. Students must replace it with the correct layer, object, identifier, and clause. They then recompute the worked example after changing one assumption and explain whether the standard or the implementation chooses the new behavior. This tests causal understanding rather than acronym recall.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 AM guarantees a fixed latency

!warning[AM provides a reliability procedure. Timers and scheduling create configuration- and load-dependent latency.]

### 9.2 UM has no sequence numbers

!warning[UM uses sequence context for reordering and reassembly even though it does not retransmit missing RLC data.]

### 9.3 ACK_SN means every byte below it was received

!warning[STATUS semantics include the reporting boundary and explicit NACKs/ranges. Interpret ACK_SN together with clause-defined window state and NACK fields.]

### 9.4 RLC retransmits transport blocks

!warning[MAC HARQ operates on transport blocks. RLC AM retains and retransmits RLC data/segments identified in its own sequence space.]

### 9.5 t-Reassembly is an end-to-end timeout

!warning[It controls RLC receive/reassembly progression under specified triggers. Application and transport timeouts are different layers.]

A final diagnostic rule applies to every confusion: ask “Which entity owns this state, which object is identified, what triggers the transition, and where is it carried?” If the answer mixes a MAC PDU with UCI, an RLC PDU with a transport block, or a scheduler policy with a receiver procedure, return to the clause map before continuing.

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. TS 38.322 V18.2.0 first-pass extraction — navigation and provenance route of this knowledge base.
2. [TS 38.322 V18.2.0 official archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) — official frozen artifact and clause authority.
3. Course Alignment — instructional placement.
- [ShareTechnote: 5G RLC](https://www.sharetechnote.com/html/5G/5G_RLC.html) — accessed 2026-08-03; engineering expression only.

All cited external links appear earlier in the explanatory body. The source note and course alignment are internal evidence, the official archive is official, ShareTechnote is engineering expression, and the ledger records reuse and correction decisions.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| AM | Acknowledged Mode | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| ARQ | Automatic repeat request | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| HARQ | Hybrid automatic repeat request | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| MAC | Medium Access Control | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| NACK | Negative acknowledgment | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| PDU | Protocol data unit | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| PDCP | Packet Data Convergence Protocol | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| RLC | Radio Link Control | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| SDU | Service data unit | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| SN | Sequence number | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| SO | Segment offset | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| STATUS PDU | RLC status control protocol data unit | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| TM | Transparent Mode | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| UE | User equipment | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| UM | Unacknowledged Mode | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.322](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit/domain | Role |
|---|---|---|---|
| $SN$ | RLC sequence number | modular integer | mechanism or worked example |
| $SO_start$ | first missing byte offset | byte | mechanism or worked example |
| $SO_end$ | last missing byte offset | byte | mechanism or worked example |
| $ACK_SN$ | STATUS reporting boundary | modular integer | mechanism or worked example |
| $B_SN100$ | size of example RLC data unit | byte | mechanism or worked example |
| $B_missing$ | missing byte count | byte | mechanism or worked example |
| $eta_reTX$ | missing fraction selected for retransmission | dimensionless | mechanism or worked example |
| $t_Reassembly$ | configured reassembly timer | s | mechanism or worked example |
