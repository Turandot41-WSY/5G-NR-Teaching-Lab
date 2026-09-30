---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 33
title: TS 38.321 — Medium Access Control
language: en
course_units:
- U05
- U10
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-33 — TS 38.321 Medium Access Control

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) — TS 38.321 V18.10.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Above MAC are queues of parcels from several senders, the logical channels. Below it are trucks of a size the scheduler chooses, the transport blocks. MAC is the clerk between them, and TS 38.321 is the clerk's manual. Think of the post-room clerk who fills every truck, asks for more, and keeps the ledgers.

![[99 Attachments/5G/Concept Figures/STAR-33-TS-38.321-Concept.png|TS 38.321 explained as the post-room clerk who fills every truck]]

*Concept figure: TS 38.321 explained as the post-room clerk who fills every truck.*

The clerk has six jobs. Fill the truck: when a grant arrives, serve the queues by priority but give each its promised minimum first, then note on the manifest what went in. Ask for trucks: raise one bit when a queue is not empty, report how much is waiting per group, say how much louder you could shout. Keep the retry ledger: up to sixteen parallel retry slots, each remembering whether the last truck arrived, where a flipped bit means new parcel and an unchanged bit means again. Knock and keep time: run the random-access conversation when there is no address yet, keep the timing alarm, and stop sending if it lapses. Sleep on a schedule: watch the noticeboard only in agreed windows, stay awake a while after activity, and sleep in short or long cycles. Pin notes to the manifest: the reports, the timing command, the activation of beams and grants, all as small headed blocks inside the truck.

What the clerk never decides is how big the truck is or when it comes; that is the scheduler, unspecified. MAC is the specified half of scheduling: the reports the scheduler may use and the rules for filling what it grants. The key fact to carry is that two MACs, one in the phone and one in the base station, must keep identical ledgers of retry slots, timers, and bearer identities without ever comparing them, and the manual is what keeps them in step.

**The question this chapter answers.** How does NR MAC turn logical-channel traffic, scheduling decisions, random access, HARQ state, timing alignment, power reports, discontinuous reception, bandwidth parts, and control elements into transport blocks while keeping the two MAC entities synchronised?

!important[**The short answer.** TS 38.321 defines the MAC entities and state machines between RLC logical channels and physical transport channels. Clause 4 defines architecture, services, and mappings. Clause 5 collects the procedures: random access, timing alignment, downlink and uplink HARQ, multiplexing and logical-channel prioritisation, scheduling request, buffer and power reporting, discontinuous reception, configured scheduling, bandwidth-part and secondary-cell operation, beam-failure support, and duplication control. Clause 6 defines the MAC PDU subheaders and control-element formats. MAC chooses and identifies protocol state; the physical layer carries the scheduled blocks and the feedback.]

Names you will meet in this note: buffer status report (BSR), bandwidth part (BWP), control element (CE), discontinuous reception (DRX), hybrid automatic repeat request (HARQ), logical-channel prioritisation (LCP), prioritised bit rate and bucket-size duration (PBR, BSD), logical-channel group (LCG), new-data indicator (NDI), protocol and service data unit (PDU, SDU), power-headroom report (PHR), scheduling request (SR), logical-channel identifier (LCID), uplink control information (UCI).

The clause map of this knowledge base (first-pass extraction) provides the navigation route; the fixed authority is [TS 38.321 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf). A reliable reading keeps four planes apart: official, configuration, implementation, and teaching.

## 2. Where you are in 5G

Section 1 put a clerk between queues and trucks. The map below shows where MAC sits in 5G: between the logical channels above and the transport blocks below, on both sides of the link.

![[99 Attachments/5G/Locator Maps/STAR-33-Where-You-Are-in-5G.png|Where Star 33 sits in the whole 5G system]]

*Locator: Where Star 33 sits in the whole 5G system.*

This chapter lights the MAC layer of the protocol stack in the specification band: the written form of the scheduler's inputs of Star 14, the HARQ loop of Star 13, the random-access state machine of Star 17, the timing alarm of Star 15, and the sleep schedule of Star 14's power-saving section. Above it is RLC, Star 34; below it are the physical-layer procedures of Stars 31 and 32; its configuration comes from RRC, Star 36.

The Knowledge Structure Map draws the scheduling and multiplexing loop. The mechanism diagram traces one grant through it.

![[99 Attachments/5G/Knowledge Maps/STAR-33-TS-38.321-Knowledge Structure Map.png|STAR-33 system-position map]]

*Knowledge map: TS 38.321 — logical to transport channel mapping.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-33-MAC-Scheduling-and-Multiplexing-Loop.png|Star 33 mechanism and handoff diagram]]

*Mechanism: TS 38.321 — the uplink scheduling and multiplexing cycle.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.321 V18.10.0, clause 5, PDF page 19](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.321 V18.10.0, clause 5, PDF page 19, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [MAC overview](https://www.sharetechnote.com/html/5G/5G_MAC.html). The reproduced image is omitted from this distribution.

*Source excerpt: MAC overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_MAC.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> The Knowledge Structure Map labels "HARQ feedback" as if it were a MAC control element. It is not. HARQ acknowledgement is uplink control information carried on physical resources and interpreted across the MAC and physical-layer interaction; it never travels inside a MAC PDU. The body text and the cited clauses are authoritative.

**Searchable structure.** Logical channels → reports (SR, BSR, PHR) → grant → prioritisation and multiplexing → transport block and HARQ process → feedback → DRX and configuration timescales.

Read the map as a dependency graph: inputs arrive from configuration, scheduling, measurements, and buffers; the entity evaluates clause-defined state and triggers, produces a PDU, a report, or a state transition, and consumes feedback; and no single document holds the whole chain. 

## 3. Foundations and prerequisites

Section 2 placed the clerk. Three foundations follow: how channels map, how the document reads as state machines, and where MAC ends and the physical layer begins.

### 3.1 Service and channel mapping

The first foundation is the two kinds of channel the clerk works between.

MAC accepts data on logical channels and delivers transport blocks through transport channels. Logical-channel identity says what kind of data is carried; transport-channel identity says how it is carried over the radio. Multiplexing combines service data units and control elements under a grant; demultiplexing restores them at the receiver.

> [!spec] 3GPP reality check
> The mapping of logical channels to transport channels, and the MAC entity's services, are [TS 38.321 V18.10.0, clause 4](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf); the logical-channel identifiers that name each parcel inside a block are Tables 6.2.1-1 and 6.2.1-2.

### 3.2 State machines, triggers, and timers

Section 3.1 mapped channels. This section gives the way to read the whole document: as state machines with triggers and timers.

!important[TS 38.321 is best read as interacting state machines: a trigger sets pending state, a resource opportunity allows an action, a control element or indication updates the peer's state, and timers bound persistence. Random access, scheduling request, buffer and headroom reporting, discontinuous reception, timing alignment, HARQ, and bandwidth-part operation share the pattern with different variables.]

### 3.3 MAC/PHY boundary

Section 3.2 covered MAC's own state. This section draws its lower boundary.

MAC owns the HARQ entities and processes, logical-channel prioritisation, buffers, and control-element interpretation. The physical layer performs modulation, coding, transmission, measurement, and feedback transport. A physical feedback bit can change MAC state without becoming a control element, which is the correction to the map's label. When you read a radio log, first say which object, which entity and which state each row belongs to; control, data, feedback and retransmissions sit on neighbouring rows and are easy to mix up.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [MAC page](https://www.sharetechnote.com/html/5G/5G_MAC.html) draws a MAC PDU byte by byte with its subheaders and control elements, which is the picture that makes "headed parcels in one truck" concrete.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the procedures.

### 4.1 Random access and timing alignment

The walk starts with random access and the timing alignment it establishes.

Clause 5.1 coordinates preamble selection, transmission, response, contention resolution, and the two-step alternative; clause 5.2 maintains timing alignment afterwards. Random access provides the first uplink opportunity and the identity transition; it is not merely a preamble. Timer expiry changes which uplink transmissions remain permitted.

> [!spec] 3GPP reality check
> The random-access state machine is [TS 38.321 V18.10.0, clauses 5.1.1 to 5.1.6](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf); the alignment timer and what expires with it are clause 5.2; the timing-advance command control element is clause 6.1.3.4.

### 4.2 HARQ processes

Section 4.1 got the phone aligned. This section reads the HARQ processes.

!important[Clauses 5.3 and 5.4 define downlink and uplink HARQ at MAC: process identity, new-data indicator, retransmission state, and buffer management coordinate with grants and acknowledgements. The physical layer codes and combines; MAC owns the protocol state; and the acknowledgement travels as uplink control information.]

### 4.3 Scheduling evidence and multiplexing

Section 4.2 covered retransmission. This section covers what the phone tells the scheduler and how it fills a grant.

The scheduling request signals a need for uplink resources; the buffer-status report describes queued data per logical-channel group; the headroom report describes power feasibility. Under a grant, logical-channel prioritisation chooses which service data units and control elements fit. The standardised prioritisation inside a phone is not the proprietary scheduler across phones, though both make priority decisions.

> [!spec] 3GPP reality check
> Prioritisation with its priority, prioritised bit rate, and bucket-size duration is TS 38.321 clause 5.4.3.1; the request, buffer report, and headroom report are clauses 5.4.4, 5.4.5, and 5.4.6 with the buffer-size tables in clause 6.1.3.1.

### 4.4 Energy and configuration timescales

The walk ends with the slower timescales: energy and configuration.

Discontinuous reception controls when the phone monitors control, bandwidth-part operation limits active bandwidth, and configured scheduling moves some decisions from each slot into configuration; secondary-cell and beam-failure support add state. MAC thus joins fast HARQ reactions to slower configured behaviour. A useful derivation is a six-column trace, time, transmitter, receiver, object, state before, state after, each row citing its clause; error handling belongs inside the mechanism, since a missed message, an expired timer, or a failed check changes the next legal action.

> [!spec] 3GPP reality check
> Discontinuous reception with its on-duration, inactivity, and retransmission timers and its short and long cycles is TS 38.321 clause 5.7; configured grants and their timers are clause 5.8; bandwidth-part operation at MAC is clause 5.15.

## 5. Worked example

Section 4 walked the procedures. Section 5 fills one grant with the prioritisation rule, a calculation you can redo by hand.

Assume a pedagogical uplink grant with 1400 available payload bytes after subheaders. Logical channel A has priority over B, A has 900 bytes queued and 600 bytes currently allowed by its prioritized-bit-rate bucket, while B has 1000 bytes queued and 900 bytes allowed.

**What we are working out.** The example derives the resource, buffer, or retransmission quantity needed to test the mechanism.

$$
\begin{aligned}
G_0&=1400\ \mathrm{bytes},\\
x_A&=\min(900,600,G_0)=600\ \mathrm{bytes},\\
G_1&=1400-600=800\ \mathrm{bytes},\\
x_B&=\min(1000,900,G_1)=800\ \mathrm{bytes},\\
G_{\mathrm{unused}}&=1400-600-800=0\ \mathrm{bytes}.
\end{aligned}
$$

In this formula, $G_0$ is the initial grant capacity and $G_1$ is the capacity remaining after logical channel A. The grant size, queue sizes, bucket allowances, and simplified priority order are pedagogical. Real LCP follows clause 5.4.3, including configured priorities, prioritized bit rates, bucket-size durations, eligible logical channels, Bj updates, MAC CEs, and remaining-resource phases. The calculation shows grant accounting only; the ordered standardized procedure is what a real device runs.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $G_0$ | 1400 | bytes | pedagogical input or derived result |
| $Q_A$ | 900 | bytes | pedagogical input or derived result |
| $B_A$ | 600 | bytes | pedagogical input or derived result |
| $x_A$ | 600 | bytes | pedagogical input or derived result |
| $Q_B$ | 1000 | bytes | pedagogical input or derived result |
| $B_B$ | 900 | bytes | pedagogical input or derived result |
| $x_B$ | 800 | bytes | pedagogical input or derived result |

**Sanity check.** Units cancel only where expected, the result remains within the stated resource or data bound, and no discrete standardized table is silently replaced by a continuous approximation. A limiting-case check sets the available resource or missing amount to zero: the selected or transmitted quantity must also become zero. This check catches sign, range, and layer errors before a trace is compared with equipment behavior.

The example deliberately stops after the stated result. A real system adds headers, control elements, reference signals, coding quantization, scheduling gaps, retransmissions, timers, capability limits, and measurement uncertainty. Each of those comes from its own clause of the standard, so look it up there rather than guessing it from this simple arithmetic.

## 6. The 3GPP protocol: which document, and what it says

The example filled a grant. This section names what each clause fixes and draws the bucket, the sizes and the timers.

Clause 5 is the state machines; clause 6 is the bytes they exchange. The figure draws the token bucket and two rounds of prioritisation, the request and report sizes, the process count and new-data indicator, the sleep timers and cycles, and the subheader format, and sets each beside the cell-group configuration line that sets it and the log line that shows it running.

![[99 Attachments/5G/Protocol Figures/STAR-33-TS-38.321-Protocol.png|The MAC procedures of TS 38.321, the rules and sizes each fixes, and the configuration lines that set them]]

*Protocol figure: The MAC procedures of TS 38.321, the rules and sizes each fixes, and the configuration lines that set them.*

| Clause | Scope | What to read it for |
|---|---|---|
| 4 | MAC architecture, entities, services, channel mappings | which entities exist and how logical channels attach to transport channels |
| 5.1 | random access | the state machine with its timers and failure branches |
| 5.2 | maintenance of uplink time alignment | what starts and restarts the timer, and what stops on expiry |
| 5.3 | DL-SCH transfer and downlink HARQ | one process: what is stored, combined, and cleared |
| 5.4 | UL-SCH transfer and uplink HARQ | how a grant becomes a transmission, and who decides retransmission |
| 5.4.3 | logical-channel prioritisation | how one grant is divided, deterministically |
| 5.4.4–5.4.6 | scheduling request, buffer status, power headroom | the three reports, their triggers and timers |
| 5.7 | discontinuous reception | when the phone listens |
| 5.8 | configured scheduling | grants that need no request |
| 5.9–5.18 | secondary cells, bandwidth parts, duplication, beam failure, and other control | the slower state MAC also keeps |
| 6.1 | MAC PDU, subheader, and control-element formats | the bytes |

The official text is [TS 38.321 V18.10.0, official archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf).

!note[**When you build or run a demo.** The MAC configuration of a demo is a page of small numbers, and most uplink behaviour traces to them. Each logical channel's priority, prioritised bit rate, and bucket-size duration decide which traffic wins a small grant. The scheduling-request prohibit timer and maximum, and the periodic and retransmission timers of the buffer report, decide how quickly the scheduler learns that a phone has data. The discontinuous-reception on-duration, inactivity timer, and cycles decide whether a phone is even listening when a grant is sent, and a demo whose downlink stalls between bursts usually has a short inactivity timer. The MAC log prints each grant as the bytes given to each channel identifier, and the reports it carried, which is prioritisation and reporting made visible; the HARQ acknowledgement never appears there, because it is physical-layer feedback.]

Release 15 established the MAC entities, the procedures above, and the PDU formats. Release 16 and Release 18 add duplication over more legs, more HARQ processes, sidelink and reduced-capability branches, and small-data procedures while keeping the clause ownership; the fixed V18.10.0 text controls the exact conditions. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states procedures; the engineering pages decode real reports against the tables.

ShareTechnote's [MAC page](https://www.sharetechnote.com/html/5G/5G_MAC.html) draws the PDU with its subheaders and control elements, its [BSR page](https://www.sharetechnote.com/html/5G/5G_MAC_CE_BSR.html) decodes a real report against the size table, its [power saving and DRX page](https://www.sharetechnote.com/html/5G/5G_PowerSaving.html) puts the timers on a timeline, and its [RACH page](https://www.sharetechnote.com/html/5G/5G_RACH.html) follows the clause 5.1 state machine message by message. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

The learning sequence is recorded in Course Alignment.

This Star aligns with course units [U05, U10, U11, U12, U13, U14]. It can be taught in three passes. The first pass names entities, channels, PDUs, and state variables. The second pass follows one success trace and one failure or retransmission trace. The third pass reads an exact clause and reconstructs a log table. Students should already understand the NR resource grid, control/data channels, coding, and protocol layering appropriate to the listed units.

A good assessment gives a trace with one deliberately ambiguous label. Students must replace it with the correct layer, object, identifier, and clause. They then recompute the worked example after changing one assumption and explain whether the standard or the implementation chooses the new behavior. This tests causal understanding rather than acronym recall.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 HARQ belongs to PHY

!warning[MAC owns HARQ entities and process state; PHY supplies coding, soft combining, channels, and UCI transport.]

### 9.2 HARQ feedback is a MAC CE

!warning[ACK/NACK is UCI carried by the physical layer. MAC CEs are fields multiplexed inside MAC PDUs under clause 6 formats.]

### 9.3 BSR and SR are synonyms

!warning[SR signals that resources are needed. BSR quantifies buffered data when its reporting procedure provides an opportunity.]

### 9.4 LCP is the gNB scheduler

!warning[LCP fills one UE’s grant from logical channels. The gNB’s cross-UE scheduling objective remains implementation-specific.]

### 9.5 DRX means the UE is disconnected

!warning[DRX reduces control monitoring according to configured active and sleep periods while the RRC connection can remain established.]

A final diagnostic rule applies to every confusion: ask “Which entity owns this state, which object is identified, what triggers the transition, and where is it carried?” If the answer mixes a MAC PDU with UCI, an RLC PDU with a transport block, or a scheduler policy with a receiver procedure, return to the clause map before continuing.

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. TS 38.321 V18.10.0 first-pass extraction — navigation and provenance route of this knowledge base.
2. [TS 38.321 V18.10.0 official archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) — official frozen artifact and clause authority.
3. Course Alignment — instructional placement.
- [ShareTechnote: 5G MAC](https://www.sharetechnote.com/html/5G/5G_MAC.html) — accessed 2026-08-03; engineering expression only.
- [ShareTechnote: 5G MAC control elements](https://www.sharetechnote.com/html/5G/5G_MAC_CE.html) — accessed 2026-08-03; engineering expression only.
- [ShareTechnote: 5G HARQ](https://www.sharetechnote.com/html/5G/5G_HARQ.html) — accessed 2026-08-03; engineering expression only.
- [ShareTechnote: 5G buffer status report](https://www.sharetechnote.com/html/5G/5G_MAC_CE_BSR.html) — accessed 2026-08-03; engineering expression only.

All cited external links appear earlier in the explanatory body. The source note and course alignment are internal evidence, the official archive is official, ShareTechnote is engineering expression, and the ledger records reuse and correction decisions.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BSR | Buffer status report | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| BWP | Bandwidth part | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| CE | Control element | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| DRX | Discontinuous reception | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| gNB | next-generation NodeB | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| HARQ | Hybrid automatic repeat request | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| LCP | Logical-channel prioritization | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| MAC | Medium Access Control | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| NDI | New data indicator | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| PDU | Protocol data unit | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| PHR | Power headroom report | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| RLC | Radio Link Control | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| RRC | Radio Resource Control | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| SDU | Service data unit | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| SR | Scheduling request | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| UCI | Uplink Control Information | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| UE | User equipment | This abbreviation names a protocol object used in the mechanism. Its scope is limited by the cited specification. | Section 1; [official TS 38.321](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit/domain | Role |
|---|---|---|---|
| $G_0$ | initial grant payload capacity | byte | mechanism or worked example |
| $G_1$ | remaining grant capacity | byte | mechanism or worked example |
| $Q_i$ | queued bytes for logical channel i | byte | mechanism or worked example |
| $B_i$ | current prioritized-bit-rate bucket allowance | byte | mechanism or worked example |
| $x_i$ | bytes selected from logical channel i | byte | mechanism or worked example |
| $Bj$ | standardized LCP bucket state | byte | mechanism or worked example |
| $N_HARQ$ | HARQ process identity/count context | integer | mechanism or worked example |
