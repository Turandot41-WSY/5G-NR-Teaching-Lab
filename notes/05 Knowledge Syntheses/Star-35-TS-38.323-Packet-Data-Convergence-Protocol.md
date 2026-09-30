---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 35
title: TS 38.323 Packet Data Convergence Protocol
language: en
course_units:
- U03–U14 cross-layer reference
release_baseline: 18
---

# STAR-35 — TS 38.323 Packet Data Convergence Protocol

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) — TS 38.323 V18.5.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Below PDCP, packets are cut up, resent, sent down two roads at once, and handed between towers. PDCP is the envelope that keeps each packet itself through all of that: numbered, sealed, and put back in order at the far end.

![[99 Attachments/5G/Concept Figures/STAR-35-TS-38.323-Concept.png|TS 38.323 explained as the envelope that survives the journey]]

*Concept figure: TS 38.323 explained as the envelope that survives the journey.*

Six things happen to one packet. It is stamped with a running count, far larger than the 12 or 18 bits written on the envelope; the rest is implied and both ends keep it. Its headers are squeezed, since IP and transport headers barely change from packet to packet. It is sealed: the contents are ciphered and, where configured, a 32-bit seal proves nobody altered them, with the count as part of the key. A road is chosen: one RLC leg normally, two for a split bearer, copies on up to four for duplication, a new tower's leg at handover. At the far end the count is rebuilt from the short number and the receiver's window, so that near the top of the space a small number means "wrapped". Then the packet is unsealed and checked with the rebuilt count, duplicates and stale ones are dropped, and the rest are held until the gap fills or a timer says stop waiting.

This is the third of three loops with three timescales. HARQ repairs a truck in a millisecond; RLC repairs a letter by number in tens of milliseconds; PDCP repairs nothing routinely. It keeps identity across reordering, duplication, and handover, and resends only when told to recover. A count gap, a duplicate, or a reordering timer points here; a failed block or a missing numbered piece points one or two layers down. And a wrong count looks like an attack: the seal is computed over the full count, so if the receiver infers the wrong upper part, every bit arrived correctly and the check still fails. That is why the two ends' counts must stay in step through every handover and re-establishment. The key fact to carry is one bearer, one PDCP entity, one count; security and ordering both hang from it, which makes it the continuity key of the whole stack.

**The question this chapter answers.** How does PDCP preserve packet identity, ordering, and security context while data crosses a radio stack that segments, retransmits, splits, and hands over beneath it, and when does it retransmit anything itself?

!important[**The short answer.** PDCP receives each service data unit from RRC or SDAP, assigns a COUNT, applies configured compression, integrity, and ciphering, writes the short sequence number, routes the PDU to one or more RLC entities, and at the receiver rebuilds the COUNT, verifies and deciphers, removes duplicates, and reorders under a timer. HARQ and acknowledged-mode RLC provide routine retransmission below it; PDCP resubmits only under specified recovery, re-establishment, mobility, or duplication contexts.]

Names you will meet in this note: Packet Data Convergence Protocol (PDCP), Service Data Adaptation Protocol (SDAP), service and protocol data unit (SDU, PDU), data and signalling radio bearer (DRB, SRB), sequence number (SN), hyper frame number (HFN), COUNT, robust header compression (ROHC), Ethernet and uplink data compression (EHC, UDC), message authentication code for integrity (MAC-I), first missing COUNT (FMC), dual active protocol stack (DAPS).

The clause map of this knowledge base (first-pass extraction) provides the navigation route; the fixed authority is [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf).

## 2. Where you are in 5G

Section 1 made PDCP the envelope that keeps a packet itself. The map below shows where it sits in 5G: the highest radio layer, above RLC, just below the core's flows.

![[99 Attachments/5G/Locator Maps/STAR-35-Where-You-Are-in-5G.png|Where Star 35 sits in the whole 5G system]]

*Locator: Where Star 35 sits in the whole 5G system.*

This chapter lights the PDCP layer of the protocol stack in the specification band: the written form of the recovery layer of Star 13, the split and duplicated bearers of Stars 18 and 20, and the security that Star 06 introduced. Above it are SDAP and RRC, Star 36; below it is RLC, Star 34; its configuration is an RRC information element.

The Knowledge Structure Map draws the protection and delivery path. The mechanism diagram traces one packet through it.

![[99 Attachments/5G/Knowledge Maps/STAR-35-TS-38.323-Knowledge Structure Map.png|STAR-35 system-position map]]

*Knowledge map: TS 38.323 — the COUNT value and what depends on it.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-35-PDCP-Protection-and-Delivery-Path.png|Star 35 mechanism and handoff diagram]]

*Mechanism: TS 38.323 — the PDCP transmit order and its inverse.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.323 V18.5.0, clause 5, PDF page 15](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.323 V18.5.0, clause 5, PDF page 15, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [PDCP overview](https://www.sharetechnote.com/html/5G/5G_PDCP.html). The reproduced image is omitted from this distribution.

*Source excerpt: PDCP overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_PDCP.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> The map's right-hand panel is not official. The authoritative order is **5.2 data transfer and reordering**, **5.3 SDU discard**, **5.4 status reporting**, and **5.5 data recovery**. "Retransmission / duplication support" is too broad: routine fast retransmission belongs to HARQ and RLC; PDCP resubmission occurs only in specified recovery, re-establishment, mobility, or duplication contexts.

> [!note] Searchable structure
> SDU → COUNT and protection → lower path(s) → reorder and deduplicate → delivery.



## 3. Foundations and prerequisites

Section 2 placed the envelope. Four foundations follow: one entity per bearer, the counter behind the sequence number, the order of compression and security, and the three recovery loops.

### 3.1 Necessary background: one bearer, one PDCP entity

The first foundation is how many envelopes a phone keeps open at once.

A data radio bearer carries user traffic and a signalling radio bearer carries control; except for SRB0, each bearer has one PDCP entity, in the control or user plane according to the bearer, so a phone holds several entities with independent state. One entity need not mean one lower path: a split bearer, duplication, or a dual active protocol stack associates it with several RLC entities, and routing and duplication happen at PDCP because it is the first layer above the alternate paths that still owns one packet sequence. Two lower transmissions with the same PDCP identity are not two application packets.

> [!spec] 3GPP reality check
> The entity-to-bearer associations, including the multi-leg cases, are [TS 38.323 V18.5.0, clause 4.2](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf); the bearer's PDCP parameters are the PDCP-Config information element of TS 38.331.

### 3.2 Sequence number, Hyper Frame Number (HFN), and COUNT

Section 3.1 gave each entity its state. This section explains the counter at the heart of that state.

!important[The header carries a finite sequence number while security and ordering use a larger COUNT whose upper part, the hyper frame number, is not carried. The receiver combines its state with the received number to infer the frame number and obtain the receive COUNT. Wraparound forces this: with 12 bits, header values repeat after 4096, so the receiver compares the incoming number with the number part of the delivery state and a half-space window; a very small number arriving near the top of the space belongs to the next frame number, a very large one arriving near zero to the preceding. Clause 5.2.2.1 gives the rules. `RX_NEXT` is the next COUNT after the highest received, `RX_DELIV` the first not yet delivered, and `RX_REORD` the boundary of the running reordering timer; they are protocol state.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [PDCP page](https://www.sharetechnote.com/html/5G/5G_PDCP.html) draws COUNT as the concatenation of hyper frame number and sequence number and steps through a wrap with real numbers, which is the picture behind the half-window rule.

### 3.3 Compression and security have an order

Section 3.2 fixed the counter. This section shows what is done to a packet, and in which order.

Header compression uses ROHC or Ethernet header compression, and uplink payload compression where configured; integrity and ciphering are separate operations whose availability depends on bearer type and configuration, so "PDCP always applies both" is unsafe. On transmission PDCP associates COUNT, compresses, protects, writes the number, increments state, and submits; on reception it rebuilds COUNT before deciphering and verifying, because the cryptography depends on that value, so a wrong COUNT appears as a security failure even when every bit arrived.

> [!spec] 3GPP reality check
> Ciphering and integrity are TS 38.323 clauses 5.8 and 5.9, with the algorithms NEA0 to NEA3 and NIA0 to NIA3 and their inputs COUNT, bearer, and direction defined in TS 33.501 clause 6; header compression is clause 5.7.

### 3.4 Three recovery loops, three time scales

The last foundation places PDCP among the repair loops below it.

!important[HARQ reacts quickly at the MAC and physical boundary with feedback and soft combining; acknowledged-mode RLC provides ARQ over its PDUs and unacknowledged mode omits it; neither changes the identity of the upper packet. PDCP preserves continuity across reordering, duplication, mobility, re-establishment, path switching, or requested recovery; clause 5.5 allows retransmission of PDCP PDUs for acknowledged-mode bearers on request, a bounded procedure rather than a third loop, and clause 5.1.2 says what is retransmitted at re-establishment. The rule: name the failed object first; a failed transport block points to HARQ, a missing RLC PDU to RLC, a COUNT gap, duplicate, timer, or recovery request to PDCP.]

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clause 5.1 establishes and changes the entity

The walk starts with clause 5.1: how an entity is created, changed and re-established.

Establishment creates the entity and its state; release discards transmit material and handles stored receive units; suspend stops reordering, delivers what it can, and resets selected state; reconfiguration changes features without casually resetting continuity state. Re-establishment is more involved because protected, compressed, numbered packets may be in flight: clause 5.1.2 distinguishes signalling bearers, unacknowledged and acknowledged data bearers, whether the entity was suspended, whether delivery was confirmed, and whether compression context continues, and it can resubmit or retransmit in ascending COUNT order only for the named cases. An implementation must therefore log the trigger and bearer mode beside "PDCP retransmission".

### 4.2 Clause 5.2.1 builds and routes a transmitted PDU

Section 4.1 created the entity. This section reads clause 5.2.1, which builds and routes a transmitted unit.

On arrival a discard timer starts; PDCP associates the COUNT of `TX_NEXT`, compresses, protects, sets the header number to the COUNT modulo the number space, increments, and submits. The submission branch follows the associations: one RLC entity, several for split transmission or duplication, an indirect path through a relay adaptation entity, or source and target legs in a dual stack; a threshold may steer split routing without changing identity. The transmitter should keep prematurely submitted PDUs and the number gap between paths small, since path imbalance becomes receiver reordering delay.

> [!spec] 3GPP reality check
> The transmit procedure and the routing branches are [TS 38.323 V18.5.0, clause 5.2.1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf); the primary path and split threshold are the moreThanOneRLC fields of TS 38.331's PDCP-Config; duplication activation is clause 5.11.

### 4.3 Clause 5.2.2 reconstructs, validates, and orders reception

Section 4.2 transmitted. This section reads clause 5.2.2, which reconstructs, validates and orders on reception.

The receiver derives the received COUNT from the number and `RX_DELIV`, deciphers and verifies with it, indicates and discards on integrity failure, and discards packets older than the delivery state or already received. An accepted unit enters the buffer; `RX_NEXT` advances when the COUNT reaches the current boundary; with out-of-order delivery configured eligible data is delivered at once, otherwise the consecutive run from `RX_DELIV` is delivered and the timer stopped when the gap closes. If a gap remains and no timer runs, `RX_REORD` takes `RX_NEXT` and the reordering timer starts; on expiry clause 5.2.2.2 releases stored data below the boundary and any newly consecutive run, then may restart for a later gap. The timer bounds waiting; it asks no sender for retransmission.

> [!spec] 3GPP reality check
> The COUNT reconstruction with its half-space window is clause 5.2.2.1, the reordering timer's actions on expiry clause 5.2.2.2, and its allowed values, up to three seconds, are the t-Reordering field of TS 38.331.

### 4.4 Clauses 5.3, 5.4, and 5.5 solve different loss questions

Section 4.3 received. This section reads clauses 5.3 to 5.5, which answer three different questions about loss.

Clause 5.3 says when a unit is no longer worth retaining: confirmation by a status report permits discard, and expiry of the discard timer, or the low-importance variant, discards the unit and its PDU, possibly a whole PDU set, with an indication to lower layers if already submitted; discard can open a number gap and lengthen reordering. Clause 5.4 defines status reporting: the first missing COUNT and a bitmap of received and missing positions, which the transmitter reads as delivery knowledge. Clause 5.5 defines recovery narrowly: for an acknowledged-mode bearer, on request from upper layers, the transmitter retransmits previously submitted PDUs of re-established or released RLC entities whose delivery was not confirmed, in ascending COUNT order through the clause 5.2.1 procedure; ordinary repair of a noisy link stays with HARQ and RLC.

### 4.5 Clauses 5.6–7 complete the layer

The walk ends with clauses 5.6 to 7, which complete the layer.

Clause 5.6 defines data-volume calculation; clauses 5.7 to 5.9 header compression, ciphering, and integrity; clause 5.10 unknown or erroneous PDUs; clause 5.11 duplication with activation and duplicate discard; later clauses Ethernet compression, uplink switching, uplink compression, delay-status volume, and number-gap reporting, all on the same identity and state foundation. Clause 6 defines the data PDU with 12-bit and 18-bit number headers and the control PDUs for status, compression feedback, uplink-compression feedback, and gap reporting, with their fields; clause 7 collects state variables, constants, and timers. The complete mechanism is not "add a header" but upper unit, persistent COUNT, configured transformation and protection, lower-path selection, receive reconstruction, duplicate and order decision, and upper delivery or bounded discard.

## 5. Worked example

Section 4 walked the clauses. Section 5 reconstructs one COUNT, a calculation you can redo by hand.

### 5.1 Worked numerical example

The example below follows the half-window rule step by step.

Assume a receiver uses a permitted 12-bit PDCP SN format. Its next undelivered COUNT is 4094, whose HFN part is zero and SN part is 4094. It receives a PDU carrying SN 1. The received value is below the lower half-window boundary, so clause 5.2.2.1 selects the next HFN.

**What we are working out.** `RCVD_COUNT`, a dimensionless PDCP packet identity at the receiving entity before deciphering, integrity verification, duplicate checking, and delivery.

$$
\begin{aligned}
\mathrm{RCVD\_COUNT}
&=\left(\left\lfloor\frac{\mathrm{RX\_DELIV}}{2^{L_{\mathrm{SN}}}}\right\rfloor+1\right)2^{L_{\mathrm{SN}}}+\mathrm{RCVD\_SN}\\
&=\left(\left\lfloor\frac{4094}{2^{12}}\right\rfloor+1\right)2^{12}+1\\
&=(0+1)(4096)+1\\
&=4097.
\end{aligned}
$$

Where:

- $\mathrm{RCVD\_COUNT}$ is the reconstructed receive identity: 4097, dimensionless, calculated (the equality chain using TS 38.323 clause 5.2.2.1); it belongs to the receiving PDCP entity.
- $\mathrm{RX\_DELIV}$ is the first COUNT not yet delivered or treated as discarded: 4094, dimensionless, assumed (the instructional receiver state); it belongs to the same entity before this PDU arrives.
- $L_{\mathrm{SN}}$ is the configured header SN length: 12 bit, reported (the applicable 12-bit Data PDU format in TS 38.323 clause 6.2.2); it belongs to the PDCP header.
- $\mathrm{RCVD\_SN}$ is the SN carried by the received PDU: 1, dimensionless, assumed (the instructional received header); it belongs to the incoming PDCP Data PDU.
- The literal 1 added to the HFN term means “next hyper frame” for the already-established wrap branch. The factor $2^{L_{\mathrm{SN}}}$ converts an HFN step into one full SN space; for 12 bits it equals 4096.

#### 5.1.1 Variable-value table

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $\mathrm{RCVD\_COUNT}$ | 4097, dimensionless | calculated | local equality chain; clause 5.2.2.1 | receiving PDCP entity |
| $\mathrm{RX\_DELIV}$ | 4094, dimensionless | assumed | instructional receiver state | receiving PDCP entity |
| $L_{\mathrm{SN}}$ | 12 bit | reported direct input | clause 6.2.2 permitted header format | PDCP Data PDU header |
| $\mathrm{RCVD\_SN}$ | 1, dimensionless | assumed | instructional received header | incoming PDCP Data PDU |

**Dimensional and sanity check.** The result is exact, so no rounding is used. The bit count appears only as an exponent length; COUNT and SN values themselves are dimensionless integers. The calculation establishes packet identity. With `RX_DELIV` still at 4094, packets 4094, 4095, and 4096 determine whether 4097 can be delivered in sequence. The PDU can remain buffered while `t-Reordering` manages the gap.

As a boundary check, an implementation that treats received SN 1 as COUNT 1 would classify a fresh packet as ancient and discard it. An implementation that always adds one HFN would misclassify ordinary out-of-order packets away from wrap. The half-space branch in clause 5.2.2.1 avoids both errors as long as transmitter and receiver state remain synchronized.

## 6. The 3GPP protocol: which document, and what it says

The example reconstructed a counter. This section names what each clause fixes and draws the envelope.

Clause 5.2 is the envelope; clauses 5.3 to 5.5 are when to drop, report, and recover. The figure draws the COUNT from hyper frame number and sequence number, the half-window reconstruction, the reordering timer, the integrity and ciphering inputs, and discard against recovery, and sets each beside the PDCP configuration line that sets it and the log line that shows it.

![[99 Attachments/5G/Protocol Figures/STAR-35-TS-38.323-Protocol.png|The PDCP count, its reconstruction, the reordering timer, the security functions and the discard and recovery rules of TS 38.323, with the configuration lines each becomes]]

*Protocol figure: The PDCP count, its reconstruction, the reordering timer, the security functions and the discard and recovery rules of TS 38.323, with the configuration lines each becomes.*

The first-pass extraction of this knowledge base supplies a compact navigation route; the clauses themselves hold the rules.

| Clause | Authoritative scope | Read when asking | Boundary |
|---|---|---|---|
| 4 | architecture, services, functions | where is the entity and what can it do? | configuration comes from RRC |
| 5.1 | entity handling | what survives establishment, suspend, release, or re-establishment? | the trigger comes from upper layers |
| 5.2 | data transfer and reordering | how is COUNT assigned, reconstructed, buffered, and delivered? | lower layers move the PDU |
| 5.3 | SDU discard | when does stale or confirmed data leave storage? | discard is not recovery |
| 5.4 | status reporting | which COUNTs are missing or received? | report knowledge is not generic ARQ |
| 5.5 | data recovery | when may AM-DRB PDCP PDUs be retransmitted? | only on the specified request or context |
| 5.6–5.16 | volume, compression, security, duplication, switching, reports | which optional or evolved function applies? | check configuration and bearer type |
| 6–7 | formats, fields, state, constants, timers | how is the wire object interpreted? | a format does not define its trigger |

!note[**When you build or run a demo.** Each bearer's PDCP configuration is a sequence-number size, a discard timer, a reordering timer, a compression profile list, and the security flags; the algorithms themselves arrive in the security-mode command. A demo whose throughput stalls in bursts after a loss has a long reordering timer holding packets back; one whose packets vanish under load has a short discard timer. A demo whose phone reports integrity failures on every packet after a handover has lost count synchronisation. The PDCP log prints each received number, the state it was compared against, the reconstructed COUNT, the integrity result, and what was delivered, which is the envelope read back step by step; and a duplicate in the log is a copy on a second leg until the trigger proves otherwise.]

The original PDCP foundation is still recognisable: one bearer-specific entity, sequence identity, ciphering and integrity, header compression, duplicate handling, reordering, and delivery. V18.5.0 adds a broader surface accumulated through later releases: dual-stack handling, wider duplication and multipath, Ethernet and uplink compression, multicast bearers, PDU-set and priority-sensitive discard, delay-status volume, and gap reporting. This is a teaching delta; for migration work compare the frozen older and newer texts. The invariant survived: COUNT remains the continuity key, and new paths and modes add state to preserve or reset without turning PDCP into the scheduler, the HARQ loop, or the RLC entity. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states procedures; the engineering pages draw the headers and work a counter with numbers.

ShareTechnote's [PDCP page](https://www.sharetechnote.com/html/5G/5G_PDCP.html) draws the data and control PDU headers and works a COUNT reconstruction with numbers, and its [radio protocol stack page](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html) places PDCP above RLC and below RRC and SDAP; together they give the reader the picture of the envelope and where it is opened. They do not replace release-specific state rules.

For a packet-ordering fault, start with a trace row containing bearer, direction, sequence number, inferred COUNT, RLC leg, cipher and integrity result, duplicate status, `RX_DELIV`, `RX_NEXT`, `RX_REORD`, and timer state, and compare the first row where the two ends diverge: if COUNT differs, inspect wrap and re-establishment; if COUNT agrees but the packet is missing, inspect lower-layer delivery and routing; if both agree but delivery stalls, inspect the gap and the timer. For mobility or duplication, add source and target cell and primary and secondary leg, and do not call two copies two retransmissions until the trigger proves it.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

In the Saar University 5G course alignment, this Star follows radio-interface architecture and Layer-2 foundations. It is especially useful after the RLC and MAC Stars because the learner can now distinguish segmentation and ARQ below from packet continuity, protection, and reordering above. It also prepares the RRC and NG-RAN architecture Stars: RRC configures PDCP behavior, while a split gNB places user-plane PDCP in the CU-UP rather than the DU.

A useful lab exercise sends numbered packets over two paths with different delay. The learner records arrival order, duplicates, inferred COUNT, and delivery order. A second pass removes a packet and lets the timer expire. The exercise should not simulate an invented PDCP ACK loop; it should expose buffering and delivery decisions while RLC/HARQ behavior remains a separately configured lower-layer condition.

For exam review, answer four questions in order: Which bearer and entity? Which COUNT and state? Which clause trigger? Which lower path? This route is short enough to use under time pressure and precise enough to prevent layer confusion.

## 9. Common confusions

The sentences in the table below are the misreadings this chapter is meant to prevent, each with its fix and a question that exposes it.

| Confusion | Correct reading | Diagnostic question |
|---|---|---|
| PDCP is another ARQ layer | Routine repair is HARQ/RLC; PDCP recovery is explicitly triggered. | Which clause and upper-layer request caused resubmission? |
| SN equals COUNT | SN is the finite header part; COUNT includes inferred HFN state. | What were `RX_DELIV` and SN length at arrival? |
| Reordering requests missing packets | The timer bounds waiting and delivery; status/recovery are separate. | Did a status or recovery trigger occur? |
| Duplicate means retransmission | Duplication can create copies on multiple legs at one COUNT. | Were two lower entities active for the bearer? |
| Cipher failure proves bad keys | A wrong COUNT can select the wrong security input. | Did both peers reconstruct the same COUNT? |
| Discard means radio loss | A timer, priority rule, PDU-set rule, or confirmation can discard data. | Which clause-5.3 condition fired? |

The supplied figure's clause panel illustrates why these distinctions matter. It moves reordering into 5.3, discard into 5.4, and status into 5.5, but those labels conflict with the actual V18.5.0 contents. The body table is authoritative: 5.2 transfer/reordering, 5.3 discard, 5.4 status, 5.5 recovery.

!warning[Security language needs the same care. PDCP supports ciphering and integrity functions, but applicability depends on bearer and configuration. Logging “security enabled” without algorithm, key context, direction, bearer, and COUNT leaves the result uninterpretable.]

!warning[Finally, packet order is not arrival order. Multiple paths, retransmissions below PDCP, radio variation, and scheduling can change arrival time. PDCP uses identity and state to decide duplicate removal and delivery. Out-of-order delivery is an explicit configuration.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.323 V18.5.0: Packet Data Convergence Protocol*, [official PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf).
2. Clause map of this knowledge base.
4. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm).
5. ShareTechnote, [5G radio protocol stack architecture](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html), accessed 2026-08-03.
6. Saar University 5G course alignment.

The clause map of this knowledge base is a navigation aid. The official archive remains official and the manifest fixes its retrieval provenance.

## 11. Abbreviation index

The canonical course vocabulary is maintained in [[5G Abbreviation Database|the 5G abbreviation database]]. The table also follows the cross-domain registry format documented in [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| PDCP | Packet Data Convergence Protocol | PDCP preserves packet identity, ordering, and configured protection above RLC. It supports continuity across multiple lower paths and mobility contexts. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| SDU | Service Data Unit | An SDU is the higher-layer object delivered to PDCP. PDCP associates it with COUNT before creating a PDU. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| PDU | Protocol Data Unit | A PDU is the peer-facing object PDCP submits to a lower path. Its header can carry the finite SN used for receive reconstruction. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| RRC | Radio Resource Control | RRC configures PDCP entities and triggers selected lifecycle procedures. It does not execute the PDCP data-transfer state machine. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| SDAP | Service Data Adaptation Protocol | SDAP provides user-plane SDUs above PDCP. It maps quality-of-service flows to data radio bearers. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| RLC | Radio Link Control | RLC transfers PDCP PDUs below the convergence layer. Its acknowledged mode owns ordinary ARQ retransmission. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| DRB | Data Radio Bearer | A DRB carries user-plane traffic through a bearer-specific PDCP entity. Its mode and path associations select applicable procedures. | Section 3.1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| SRB | Signalling Radio Bearer | An SRB carries control-plane signaling. Its PDCP handling differs from a DRB in several lifecycle and protection branches. | Section 3.1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| SN | Sequence Number | The SN is the finite packet number carried in a PDCP header. The receiver combines it with HFN state to reconstruct COUNT. | Section 3.2; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| HFN | Hyper Frame Number | The HFN is the more-significant part of COUNT inferred from receiver state. It disambiguates repeated SN values after wrap. | Section 3.2; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| ROHC | Robust Header Compression | ROHC compresses supported network and transport headers when configured. Its context handling matters during re-establishment. | Section 3.3; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| EHC | Ethernet Header Compression | EHC compresses supported Ethernet headers when configured. It has separate configuration and feedback handling from ROHC. | Section 3.3; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| UDC | Uplink Data Compression | UDC compresses configured uplink data using its defined protocol and state. Its buffer handling matters during re-establishment. | Section 3.3; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| HARQ | Hybrid Automatic Repeat Request | HARQ is the fast lower-layer retransmission and combining loop. It repairs transport delivery without changing PDCP packet identity. | Section 1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| AM | Acknowledged Mode | AM is the RLC mode with status and ARQ behavior. PDCP data recovery can refer to PDUs previously submitted to AM RLC entities. | Section 3.4; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| UM | Unacknowledged Mode | UM is the RLC mode without acknowledged retransmission. PDCP still supplies ordering and continuity functions above it. | Section 3.4; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| DAPS | Dual Active Protocol Stack | DAPS maintains source and target protocol resources during supported mobility handling. PDCP preserves separate configured functions while maintaining packet continuity. | Section 3.1; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| FMC | First Missing COUNT | FMC identifies the first missing receive COUNT in a PDCP status report. Bitmap positions after it communicate received and missing data. | Section 4.4; [TS 38.323 V18.5.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain | Role and convention |
|---|---|---|---|
| $\mathrm{RCVD\_COUNT}$ | Reconstructed COUNT for the received PDU | dimensionless integer | Security, duplicate, ordering, and delivery identity. |
| $\mathrm{RX\_DELIV}$ | First COUNT not yet delivered or treated as discarded | dimensionless integer | Receiver delivery boundary before arrival. |
| $L_{\mathrm{SN}}$ | Configured PDCP SN length | bit | Defines the finite header-number space. |
| $\mathrm{RCVD\_SN}$ | SN read from the received PDU | dimensionless integer | Header input to COUNT reconstruction. |
| $\mathrm{RX\_NEXT}$ | One greater than the highest received COUNT | dimensionless integer | Upper receive-state boundary. |
| $\mathrm{RX\_REORD}$ | COUNT boundary captured for reordering | dimensionless integer | Timer-associated delivery boundary. |
| $t\text{-Reordering}$ | PDCP reordering timer | configured time | Bounds waiting for a receive gap. |

No symbol in this table represents radio quality or a retransmission attempt. Each symbol belongs to the receiving PDCP entity unless the row says otherwise.
