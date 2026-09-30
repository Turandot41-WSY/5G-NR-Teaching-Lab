---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 17
title: Random Access
language: en
course_units:
- U09
- U10
release_baseline: 18
---

# STAR-17 — Random Access

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

After Star 16 a phone has listened its way to a cell identity, a frame clock, and the rules. It has never transmitted. It does not know how far away the cell is, so it does not know when its signal will arrive. It has no name in the cell. And it has no guarantee that another phone is not about to speak at the same instant. Random access is how a phone raises its hand in a crowded room when nobody knows its name yet.

![[99 Attachments/5G/Concept Figures/STAR-17-Random-Access-Concept.png|Random access explained as raising a hand in a crowded room with no name]]

*Concept figure: Random access explained as raising a hand in a crowded room with no name.*

The four messages each remove one unknown. First the phone makes one of 64 agreed sounds, a preamble, in an agreed window; not a name, just "someone, roughly here". The preamble is built so the cell can recognise it even when it arrives late. Second, the cell answers the sound itself: "whoever made sound 23, start twelve steps earlier, here is a temporary badge and a small slot". That removes the timing unknown. Third, the phone uses the slot to say a 48-bit random name. If two phones made sound 23, both received the same answer, and both speak now. Fourth, the cell repeats back the one name it decoded. The phone that hears its own name keeps the badge as its cell identity; the other hears a stranger's name and starts again. That removes the collision.

A two-step version merges the pairs: whistle and name in one breath, timing and echo in one reply. It saves a round trip at the risk of speaking before the timing is known, and falls back to four steps if it fails. Why not simply speak? Because anything longer than a preamble would arrive at an unknown time and collide with everyone. The cell must even reserve a guard time for the farthest possible phone. The key fact to carry is that the phone has no identity until the fourth message; the second is addressed to a sound, which is exactly why two phones can both believe it.

**The question this chapter answers.** How does an unscheduled UE obtain timing, identity context, and an uplink opportunity?

!important[**The short answer.** Random access converts uncertain arrival timing and incomplete UE identity into scheduled state. Four-step access separates preamble, response, scheduled identity transmission, and contention resolution; two-step access combines the first payload with the preamble and uses MsgB for response and resolution.]

Names you will meet in this note: physical random-access channel (PRACH), random-access response (RAR), random-access RNTI (RA-RNTI), temporary cell RNTI (TC-RNTI), cell RNTI (C-RNTI), contention-based and contention-free random access (CBRA, CFRA), RACH occasion (RO), PUSCH resource unit (PRU), timing advance (TA), Zadoff–Chu sequence (ZC).

## 2. Where you are in 5G

Section 1 left a phone that has listened but never transmitted. The map below shows where random access sits in 5G: the first uplink box, between cell search and the connected state.

![[99 Attachments/5G/Locator Maps/STAR-17-Where-You-Are-in-5G.png|Where Star 17 sits in the whole 5G system]]

*Locator: Where Star 17 sits in the whole 5G system.*

This chapter lights random access in the procedures band, directly after cell search. It consumes what Star 16 delivered, the cell identity and the SIB1 configuration, and produces what every later chapter assumes: a timing advance for Star 15's timing loop, a cell identity for Star 14's scheduler to address, and the first uplink grant. It is also the recovery path whenever timing is lost, and the tool beam-failure recovery in Star 12 reaches for.

The Knowledge Structure Map draws the procedure from the preamble to the resolved identity. The mechanism diagram is the four-step exchange as a sequence in time.

![[99 Attachments/5G/Knowledge Maps/STAR-17-Random-Access-Knowledge Structure Map.png|STAR-17 system-position map]]

*Knowledge map: Every trigger for random access, split by whether contention is possible.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-17-Four-Step-Random-Access.png|Four-step contention-based random-access sequence]]

*Mechanism: The random-access collision that steps three and four exist to settle.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: SSB and PRACH association → preamble transmission → RAR/Msg3 or MsgA/MsgB → contention resolution → scheduled UE context.


## 3. The textbook road

Section 2 placed random access at the first transmission. The road below walks through the chapter in the book's order: the four-step procedure, the two-step variant, timing and guard, a full sequence, the reader's questions, then the whole access flow end to end.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **17.1 Random-Access Procedures**

The road begins with what random access must deliver, timing, a first uplink resource and an identity, and the two ways of getting them.

!important[Random access gives a phone three things: uplink timing alignment, its first uplink resources, and a cell identity, the C-RNTI, for later scheduling. It comes in two kinds. Contention-based access lets many phones compete with preambles drawn from a common pool. Contention-free access reserves one preamble for one phone, as in handover or beam-failure recovery, so that no collision is possible.]

#### 3.1.1 **17.1.1 Four-Step Contention-Based Random Access**

!important[Message 1 is the preamble, sent on an uplink RACH occasion. Message 2 is the random-access response, in which the base station returns a timing advance, a temporary identity, and an uplink grant. Message 3 uses that grant to send the phone's identity or request. Message 4 is contention resolution, a downlink message addressed with the temporary identity that confirms which phone succeeded. Figure 17.1 shows the four steps.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 17.1 shows the four steps.*

> [!book] Book expansion
> Four-step access delays the first identity-bearing payload until the base station has detected a preamble and issued a grant, separating coarse timing acquisition from identity resolution. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 17, pp. 349–370, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).

> [!spec] 3GPP reality check
> The MAC state machine is [TS 38.321 V18.10.0, clauses 5.1.1–5.1.6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); PRACH generation is defined separately in TS 38.211.

External source: [TS 38.321 V18.10.0, clause 5.1, PDF page 20](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip). The reproduced image is omitted from this distribution.

*Source excerpt: 3GPP TS 38.321 V18.10.0, clause 5.1, PDF p. 20, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), accessed 2026-08-04.*

> [!engineering] ShareTechnote engineering view
> The [RACH page](https://www.sharetechnote.com/html/5G/5G_RACH.html) follows Msg1 through Msg4 as a receiver-visible sequence, with the fields of each message decoded.

External source: [RACH overall-procedure overview](https://www.sharetechnote.com/html/5G/5G_RACH.html). The reproduced image is omitted from this distribution.

*Source excerpt: ShareTechnote, [5G/NR RACH](https://www.sharetechnote.com/html/5G/5G_RACH.html), overall-procedure overview, accessed 2026-08-04.*

#### 3.1.2 **17.1.2 Guard Time Before PRACH Reception**

Before receiving preambles the base station leaves a guard time to absorb propagation-delay uncertainty, since it knows neither each phone's distance nor how many will transmit. The guard must cover the round trip from the farthest expected phone:

$$
T_{guard} \ge 2R_{cell,max}/c
$$

For a 5 km macro cell that is roughly 70 µs. The scheduler therefore reserves extra time around each RACH occasion so that near and far preambles do not overlap what follows, as Figure 17.2 shows. The guard time is not part of the specifications but a consequence of scheduling restrictions, so different guard times can be provided for different cell sizes.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The scheduler therefore reserves extra time around each RACH occasion so that near and far preambles do not overlap what follows, as Figure 17.2 shows.*

#### 3.1.3 **17.1.3 Mapping Between SSBs and RACH Occasions**

Each SS block is linked to one or more RACH occasions, which define where a phone that heard that block may send its preamble. The mapping arrives by RRC in the common RACH configuration, telling the phone which block indices correspond to which occasions and the time and frequency offsets between them. Figure 17.5 shows the idea.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 17.5 shows the idea.*

Once a phone has decoded a block it knows which occasions are its own and when to transmit. In practice it sends the preamble in the same beam direction it received the block, so that the base station can infer from the occasion which beam the phone is in.

> [!book] Book expansion
> The block-to-occasion association lets beam-domain discovery lead to a matching access opportunity; it does not mean one block permanently owns one PRACH resource under every configuration. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 17, pp. 349–370, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).

> [!spec] 3GPP reality check
> Preamble generation is [TS 38.211 V18.9.0, clause 6.3.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the physical procedures and the block-to-occasion association are TS 38.213 clause 8.1.

> [!engineering] ShareTechnote engineering view
> The [RACH page](https://www.sharetechnote.com/html/5G/5G_RACH.html) draws RACH occasions on a slot grid for several configuration indices, which is the quickest way to see what a configured index means in time.

#### 3.1.4 **17.1.4 RACH Occasions and Beam Correspondence**

A RACH occasion is the time and frequency window for preamble transmission, a preamble reception period. Mapping blocks to occasions keeps uplink and downlink beams aligned and puts each phone's preamble in the slot that belongs to the block it heard. When a preamble arrives, the base station already knows which beam it corresponds to and can choose its receive beam and timing reference.

#### 3.1.5 17.1.5 Preamble Power Control and Power Ramping

The phone sets its first preamble power from the downlink path loss it measured and a target received power the network configured. If no response arrives within the window, it assumes the preamble was not heard, most likely because it was too quiet, and sends it again with more power. The ramp continues until a response arrives, a maximum number of attempts is reached, or the maximum transmit power is hit.

> [!book] Book expansion
> Power ramping is an attempt-level loop: estimate path loss, apply the configured target and step, transmit, and adjust only when the procedure calls for another attempt. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 17, pp. 349–370, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).

> [!spec] 3GPP reality check
> Preamble selection and transmission are TS 38.321 V18.10.0, clauses 5.1.2–5.1.3; the preamble power itself is TS 38.213 V18.8.0, clause 7.4.

> [!engineering] ShareTechnote engineering view
> The [power-control page](https://www.sharetechnote.com/html/5G/5G_PowerControl.html) separates the configured preamble target from the closed-loop control of scheduled channels, which are often confused.

#### 3.1.6 **17.1.6 Random-Access Response and RA-RNTI**

The response carries a timing advance, an uplink grant for message 3, and a temporary identity. It is addressed with an RA-RNTI computed from the occasion's time and frequency index, so the RA-RNTI identifies the preamble's slot.

> [!book] Book expansion
> A response matches the detected preamble context and supplies timing, a grant, and a temporary identity; contention is not resolved merely because several phones can decode the same response. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 17, pp. 349–370, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).

> [!spec] 3GPP reality check
> Response reception is TS 38.321 V18.10.0, clause 5.1.4, and the MAC subPDU structure of the response is clause 6.2.3; TS 38.213 V18.8.0, clause 8.2 anchors the physical response and message 3 procedures.

> [!engineering] ShareTechnote engineering view
> The [RACH page](https://www.sharetechnote.com/html/5G/5G_RACH.html) decodes a captured response byte by byte, showing where the timing advance, grant, and temporary identity sit.

#### 3.1.7 **Two UEs with Same RA-RNTI and RAR — How Are They Distinguished?**

!note[Suppose two phones choose the same preamble in the same occasion. They share the RA-RNTI and receive the identical response. Both send message 3 on the identical grant, but each message 3 carries its own identity: an existing C-RNTI for a phone re-establishing a connection, or a 48-bit random identity in a MAC control element for a new one; in two-step access the identity travels in the message A payload. Usually only one transmission decodes cleanly. The base station sends message 4 addressed with the temporary identity and containing the identity it decoded; only the phone whose identity matches adopts the C-RNTI, and the other times out and restarts. Message 3's identity is what lets the base station tell apart phones that shared a response.]

#### 3.1.8 **17.1.7 Message 3 – UE Identity Transmission**

Before data can flow, the phone needs a unique identity in the cell, the C-RNTI, unless it already has one. In the third step it uses the grant from the response to send, on the shared channel, either its existing C-RNTI, or a 48-bit random identity for initial access, together with a small RRC or MAC payload such as a setup request. The purpose is to identify itself for contention resolution. If two phones sent the same preamble and got the same response, both now send different message 3 payloads; the base station decodes one or both, and message 4 names the winner.

#### 3.1.9 **17.1.8 Contention Resolution and TC-RNTI Promotion**

Message 4 is sent on the shared channel scrambled with the temporary identity from the response. A phone that finds its own identifier inside concludes that it has won, and its temporary identity becomes its permanent C-RNTI for all later scheduling.

### 3.2 **17.2 Two-Step Random Access**

Section 3.1 took four messages. This section merges them into two for latency and unlicensed bands, and shows what is traded away.

To cut latency and signalling, NR also defines two-step access, aimed at low-latency services and unlicensed bands. Message A is the preamble and a shared-channel payload sent together; message B is the response and contention resolution in one downlink message. If message B does not arrive, the phone falls back to four steps.

#### 3.2.1 **17.2.1 Mapping of RACH Slots to PRU Sets**

In two-step access each RACH occasion is paired with a PUSCH resource unit for the message A payload. An offset tells the phone when to send the payload relative to the preamble, and the phone learns the pairing from the RACH configuration tied to the block it decoded. Both parts are uplink and sequential; the block provides the timing anchor. Figure 17.8 shows the relationship.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 17.8 shows the relationship.*

#### 3.2.2 The Fully Clarification of SSB, RACH, PRU

The chain has three links. First, the phone learns the mapping from RRC configuration tied to the block: each block index is linked to occasions, a preamble format, a preamble count, and, for two-step access, the offset to the payload resource. Second, from block to occasion: the phone computes the occasion start as the block end plus the configured offset and sends its preamble there; the RA-RNTI later derives from that occasion's index. Third, from occasion to payload: in two-step access the configuration says which resource unit belongs to the occasion, with no grant needed; in four-step access the message 3 resource is not pre-mapped and comes from the response.

| Access type | When the UE learns the PUSCH resource | How it is linked |
| --- | --- | --- |
| Two-step | on decoding the SSB, from configuration | SSB → RACH occasion → fixed PRU via the offset |
| Four-step | on receiving the response | the response carries the grant for message 3 |

| Mapping | Stage | Purpose |
| --- | --- | --- |
| SSB → RACH | downlink to uplink | which PRACH resources belong to the block the UE detected |
| RACH → PUSCH | uplink to uplink | which payload resource belongs to the PRACH the UE used, in two-step access |

The first mapping is about how access starts; the second is about where the next message goes.

> [!important] 💡
> **Intuitive picture**
> 1. UE detects SSB #i → "I can access via RACH occasion #i."
> 2. It knows: RACH slot #i ⇔ PUSCH (PRU #i + the configured offset).
> 3. Sends its preamble at the right moment.
> 4. gNB listens on that mapped PUSCH window for message A (two-step) or sends the response for message 3 (four-step).

#### 3.2.3 **17.2.2 Message A Composition**

Message A combines a preamble for detection with a shared-channel payload that may hold a connection request, the phone's identity, and a small data payload for low-latency use. The base station decodes both parts. If the payload fails, it may send a fallback response that returns the phone to the four-step path.

> [!book] Book expansion
> Two-step access pre-associates a payload with the preamble part of message A, saving a turnaround when reception succeeds and costing receiver work before a per-phone grant exists. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 17, pp. 349–370, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).

> [!spec] 3GPP reality check
> Message A and B MAC behaviour is [TS 38.321 V18.10.0, clauses 5.1.2a–5.1.4a](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); the physical behaviour is TS 38.213 V18.8.0, clauses 8.1A–8.2A.

> [!engineering] ShareTechnote engineering view
> The [two-step RACH page](https://www.sharetechnote.com/html/5G/5G_RACH_2step.html) distinguishes the message A payload resources from the response-scheduled message 3 path.

### 3.3 **17.3 Uplink Timing and Guard Control**

Both procedures start with a preamble. This section shows what else the preamble gives the base station: the propagation delay and the first timing advance.

The preamble also lets the base station estimate propagation delay and issue the first timing-advance command in the response, aligning the phone's uplink inside the cyclic prefix. Combined with the periodic corrections of Star 15 in connected mode, this keeps the uplink synchronised for as long as the connection lasts.

### 3.4 **17.4 Practical Example – Full Access Sequence**

Sections 3.1 to 3.3 described the steps one at a time. The table below runs the full sequence as one example, with the two-step version beside it.

| Step | Direction | Message | Main purpose | Key parameters |
| --- | --- | --- | --- | --- |
| 1 | UL | PRACH preamble | announce an access attempt | preamble index, RACH occasion |
| 2 | DL | random-access response | timing advance, grant, TC-RNTI | RA-RNTI addressing |
| 3 | UL | PUSCH (message 3) | identify the UE, send the RRC request | 48-bit identity or C-RNTI |
| 4 | DL | contention resolution | confirm the successful UE | scrambled with the TC-RNTI |

In the two-step version steps 1 and 3 merge into message A, and steps 2 and 4 into message B.

### 3.5 **17.5 Key Insights and Q&A Integration**

The sequence raises the questions a first-time reader asks. This section answers them in one table.

| Topic | Conceptual clarification |
| --- | --- |
| Guard time | needed because the gNB does not know UE distance; the scheduler reserves about twice the propagation delay |
| SSB → RACH mapping | configured by RRC; a UE that decoded a block knows which occasion and beam to use |
| RA-RNTI | identifies the occasion; colliding UEs share it until contention resolution |
| TC-RNTI | temporary identity from the response; promoted to C-RNTI after contention resolution |
| RACH ↔ PRU mapping | logical, sequential, via the configured offset; both uplink; the block is the timing reference |
| Message 3 | carries the identity and the request; colliding UEs are told apart by their identity fields |

### 3.6 End-to-End Cell Access Flow — from SSB Detection to Random Access Completion

The road ends by joining this chapter to the previous one: the whole flow from detecting the block to completing access, in one figure.

> [!warning] Missing figure
> One figure of the author's Chapter 17 notes, an uplink synchronization illustration, could not be retrieved and is not reproduced here.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*> > The following `image-05.png` is a separate image from the next source block and stands on its own.*

Read together with Star 16, the path is one story: the phone finds a block, reads the MIB and SIB1, chooses the occasion that belongs to the block it heard, sends a preamble, receives timing and a temporary identity, asserts a name, and is confirmed. Cell search and random access are the two halves of initial access.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: the preamble in one, the procedure in another, and the mapping of blocks to occasions in a third.

The preamble is TS 38.211: the Zadoff–Chu sequences, their lengths, and the formats. The procedure is TS 38.321: preamble selection, power ramping, the response window, the response's fields, and contention resolution. TS 38.213 maps blocks to occasions and sets the preamble power. TS 38.331 holds every constant in the common RACH configuration. The figure draws the numbers a demo's random access depends on: 64 preambles and their lengths, the preamble power and its ramp, the RA-RNTI formula, the response fields, and the 48-bit identity echoed in message 4.

![[99 Attachments/5G/Protocol Figures/STAR-17-Random-Access-Protocol.png|The random-access preamble, response and contention resolution, with their clauses and configured values]]

*Protocol figure: The random-access preamble, response and contention resolution, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 6.3.3 | PRACH preamble sequences, formats, and mapping |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 7.4; 8 | preamble power and the physical random-access procedure |
| TS 38.321 | V18.10.0, [38321-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.1; 6.2.3 | the MAC state machine and the response PDU |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | RACH-ConfigCommon | every configured value of the procedure |

!note[**When you build or run a demo.** The PRACH configuration index is one number that fixes the preamble format and when occasions occur, and it must match the cell's duplex pattern or the occasions land on downlink symbols. The zero-correlation-zone setting fixes how large a cell the preambles can serve, and a demo that works on the bench but fails across a car park usually has it too small. The target received power and the ramping step decide how many attempts a phone needs, and the response window decides how long it waits for each. The base-station log prints the preamble index, the measured timing advance, the response, message 3, and the contention-resolution result on one line per attempt, and reading it is the fastest way to see where an access failed.]

Release 15 established four-step access, the preamble formats, and the block-to-occasion mapping. Release 16 added two-step access, whose behaviour post-dates the original baseline. Release 18 keeps both with corrections and feature-specific branches. Release summaries are checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the pieces; the trace below strings them together as one access attempt.

> [!note] End-to-end trace
> SSB and PRACH association → preamble transmission → RAR/Msg3 or MsgA/MsgB → contention resolution → scheduled UE context.

Read each arrow as a handoff from one step to the next. Configuration constrains the available choices; the transmitter acts; the receiver measures or decodes; the result enables the next scheduled step.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** U09–U10: use this chapter after cell search and system information; random access begins only after the UE has decoded the access configuration.

!warning[**RA-RNTI is not a permanent UE identity.** It addresses a response context derived from the PRACH occasion. Later identity content and contention-resolution rules distinguish contenders.]

!warning[**Timing advance is not propagation delay alone.** The command aligns uplink arrival and includes network quantization and scheduling conventions. A geometry-only round-trip calculation is therefore only intuition.]

!warning[**Two-step does not overlap PRACH and PUSCH.** MsgA logically combines preamble and payload with a configured association. The PRACH and PUSCH resources remain separately defined physical resources.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 17, pp. 349–370, DOI [10.1016/B978-0-12-822320-8.00017-9](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).
2. 3GPP, *TS 38.211 V18.9.0: NR; Physical Channels and Modulation*, clauses 6.3.3 and 6.4.4, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
3. 3GPP, *TS 38.213 V18.8.0: NR; Physical Layer Procedures for Control*, clause 8, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
4. 3GPP, *TS 38.321 V18.10.0: NR; Medium Access Control Protocol Specification*, clauses 5.1 and 6.1.5, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).
5. 3GPP, *TS 38.331 V18.10.0: NR; Radio Resource Control Protocol Specification*, clause 6.3.2 and `RACH-ConfigCommon` family, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).
6. ShareTechnote, [RACH](https://www.sharetechnote.com/html/5G/5G_RACH.html) and [Two-step RACH](https://www.sharetechnote.com/html/5G/5G_RACH_2step.html), accessed 2026-08-03.
7. Chapter 17 notes of this knowledge base (the author's reading notes, dated 2026-08-03); one figure of those notes could not be retrieved and is not reproduced here.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | Primary clause |
| --- | --- | --- |
| C-RNTI | Cell radio network temporary identifier | TS 38.321 V18.10.0, clause 7.1 |
| gNB | next generation NodeB | TS 38.300 V18.10.0, clause 4.3 |
| PRACH | Physical random access channel | TS 38.211 V18.9.0, clause 6.3.3 |
| PUSCH | Physical uplink shared channel | TS 38.211 V18.9.0, clause 6.3.1 |
| RA-RNTI | Random access radio network temporary identifier | TS 38.321 V18.10.0, clause 5.1.4 |
| RAR | Random access response | TS 38.321 V18.10.0, clause 6.1.5 |
| RRC | Radio resource control | TS 38.331 V18.10.0, clauses 4–5 |
| SSB | Synchronization signal and PBCH block | TS 38.211 V18.9.0, clause 7.4.3 |
| TC-RNTI | Temporary cell radio network temporary identifier | TS 38.321 V18.10.0, clause 5.1.5 |
| UE | User equipment | TS 38.300 V18.10.0, clause 4 |

Controlled two-sentence definitions are in [[5G Abbreviation Database]].

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $R$ | Assumed cell radius | metres |
| $c$ | Propagation speed used in the example | metres per second |
| $T_{one}$ | One-way geometric propagation delay | seconds |
| $T_{RTT}$ | Geometric round-trip propagation delay | seconds |
| $I_A$, $I_B$ | Illustrative UE contention-resolution identities | 48-bit identity values in the stated CCCH case |
