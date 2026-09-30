---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 13
title: Retransmission Protocols
language: en
course_units:
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-13 — Retransmission Protocols

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

A conversation in a noisy room needs three different ways of asking for a repeat. There is the instant "sorry?" — you half-heard the word, you keep what you got, the speaker says it again a little differently, and the two halves add up to the whole. There is the read-back at a pause — you go through your numbered notes and ask for the lines you never received, which is slower but catches gaps the instant loop never noticed. And there is what happens when you change rooms mid-conversation — the host resends anything that was still in flight from the old room. NR does all three. The instant loop is HARQ, in the MAC layer, working in milliseconds. The read-back is the acknowledged mode of RLC, working in tens of milliseconds. The change of rooms is PDCP's recovery at handover.

![[99 Attachments/5G/Concept Figures/STAR-13-Retransmission-Protocols-Concept.png|The three retransmission loops explained as three ways to ask for a repeat]]

*Concept figure: The three retransmission loops explained as three ways to ask for a repeat.*

Why not one perfect loop? Because speed and certainty pull in opposite directions. A loop fast enough to repair a block within a millisecond has to be simple — one bit of feedback, no sequence numbers — and simple loops are occasionally wrong: the one bit is misheard, and a block vanishes without anyone noticing. A loop with sequence numbers notices the gap, but only at the next pause. And neither can see across a change of base station; only the layer that survives the change can. So NR stacks all three, and this chapter is really about the boundaries between them: what each promises, and the exact case each hands upward.

The fact to carry through the chapter is that a failed transmission is evidence. HARQ keeps it. The receiver stores the soft values from the attempt that failed and adds the next attempt to them, and each retransmission brings different coded bits rather than a copy — which is why two attempts that each fail can succeed together. Everything else in the chapter follows from that.

**The question this chapter answers.** If channel coding can correct errors and HARQ can retransmit failed blocks, why does NR also need RLC acknowledged mode and PDCP recovery functions?

!important[**The short answer.** The mechanisms operate on different objects, timescales, and failure scopes. Physical-layer coding makes one attempt robust. HARQ, a MAC protocol realised with physical channels, quickly supplies new redundancy for a transport block while the receiver keeps its soft information. RLC acknowledged mode repairs residual missing PDUs over a longer window by sequence number. PDCP numbers, reorders, and recovers across mobility, but is not the ordinary radio-link retransmission layer.]

Names you will meet in this note: Hybrid Automatic Repeat Request (HARQ), Automatic Repeat Request (ARQ), incremental redundancy (IR), chase combining, redundancy version (RV), new-data indicator (NDI), code-block group (CBG), code-block-group transmission and flush indicators (CBGTI, CBGFI), downlink assignment index (DAI), log-likelihood ratio (LLR), Radio Link Control (RLC), transparent, unacknowledged and acknowledged mode (TM, UM, AM), Packet Data Convergence Protocol (PDCP).

## 2. Where you are in 5G

Section 1 found three ways of asking for a repeat in a noisy room. The map below shows where the three loops sit in 5G: MAC, RLC and PDCP, one above the other.

![[99 Attachments/5G/Locator Maps/STAR-13-Where-You-Are-in-5G.png|Where Star 13 sits in the whole 5G system]]

*Locator: Where Star 13 sits in the whole 5G system.*

This chapter lights retransmission in the procedures band and the MAC, RLC, and PDCP layers of the stack. HARQ reuses the redundancy versions defined in Star 09 and the acknowledgement channel of Star 10; RLC and PDCP are covered specification by specification in Stars 34 and 35. The scheduler of Star 14 is what decides when a retransmission goes.

The Knowledge Structure Map sets HARQ and RLC ARQ side by side on speed, recovery method, feedback cost, and weakness, and names the one case that justifies keeping both. The mechanism diagram draws soft combining as accumulating redundancy across three attempts against a decode threshold.

![[99 Attachments/5G/Knowledge Maps/STAR-13-Retransmission-Protocols-Knowledge Structure Map.png|STAR-13 system-position map]]

*Knowledge map: HARQ and RLC ARQ compared, and why both are kept.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-13-HARQ-Retransmission-Loop.png|Star 13 mechanism and handoff diagram]]

*Mechanism: HARQ soft combining shown as accumulating redundancy.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 13.1 Hybrid-ARQ with Soft Combining → 13.1.2 Downlink Hybrid-ARQ → 13.2 Radio Link Control (RLC) → 13.3 PDCP (Packet Data Convergence Protocol).


## 3. The textbook road

Section 2 placed the three loops. The road below walks through the chapter in the book's order: HARQ with soft combining, its downlink form, then RLC, then PDCP.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

Three layers retransmit, and the order in which they act is the point. MAC's HARQ retransmits immediately, with soft combining. RLC's ARQ acts after HARQ has failed, restoring reliable delivery per logical channel. PDCP acts at handover or across two connections.

> [!important] 💡
> - **MAC HARQ retransmission** occurs **immediately (microseconds to milliseconds) and uses soft combining.**
> - **RLC retransmission** is a higher-layer process that **occurs after HARQ failure**, ensuring reliability across logical channels.
> - **URLLC usually avoids RLC retransmissions** because they introduce delay. Thus, **HARQ handles most errors at the MAC layer.**
> So RLC retransmission does **not happen before MAC transmission**, but **after HARQ exhaustion** or **persistent errors**.

| Layer | Protocol | Timescale | Key Mechanism | Function |
| --- | --- | --- | --- | --- |
| **MAC** | HARQ | Sub-ms | Soft combining (IR) | Fast recovery from channel errors |
| **RLC** | ARQ | ms to tens of ms | Status report feedback | Reliable delivery of logical channels |
| **PDCP** | PDCP Retransmission | Handover timescale | Packet forwarding and duplicate removal | Seamless mobility and integrity |

Together they give low latency, very high reliability, and high throughput — but each on its own gives only one of them.

### 3.1 **13.1 Hybrid-ARQ with Soft Combining**

The road begins with the fastest loop, the one that keeps what it half-heard and adds the repeat to it.

!important[HARQ is the primary retransmission protocol and lives in MAC. When a transport block fails, the receiver asks for it again and combines what it already received with what arrives next. Figure 13.1 shows several stop-and-wait processes running in parallel: while one waits for its acknowledgement, the others keep the link busy. NR allows up to sixteen, in each direction, operating asynchronously — retransmissions are scheduled whenever the network chooses rather than at a fixed offset, which is what dynamic TDD and remote radio heads need.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.1 shows several stop-and-wait processes running in parallel: while one waits for its acknowledgement, the others keep the link busy.*

#### 3.1.1 **13.1.1 Soft Combining**

!important[Two ways of combining exist. Chase combining retransmits the identical coded bits, so the receiver accumulates energy. Incremental redundancy retransmits different coded bits, so the receiver accumulates energy and gains coding rate at the same time. NR uses incremental redundancy. Figure 13.2 contrasts them.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.2 contrasts them.*

#### 3.1.2 **How Incremental Redundancy Works**

Each retransmission is a different redundancy version, read out of the rate-matching buffer of Star 09 from a different starting point. All versions carry the same information bits in the sense that matters — they are all constraints on the same unknowns — but the coded bits transmitted differ. Systematic bits dominate in version zero and version three, which are therefore decodable on their own; parity bits dominate in versions one and two.

> [!important] 💡
> The transmitter’s buffer stores the full LDPC-coded block. Each retransmission draws a **different subset** of bits—designed for optimal rate matching. Systematic bits dominate in RV0 and RV3, giving those versions higher decoding independence.

The encoder does not duplicate the information bits. It produces a larger set of coded bits, every one of which — systematic and parity alike — is mathematically related to the same message. The versions carry different coded views of one message, each adding new redundancy, and the LDPC code is best pictured as a network of equations linking all coded bits to the same unknowns rather than as copies of them.

#### 3.1.3 Example for LDPC coding and soft coding

Take three information bits and three parity bits:

$$
u = [u_1, u_2, u_3]
$$

$$
p_1 = u_1 \oplus u_2 \\
p_2 = u_2 \oplus u_3 \\
p_3 = u_1 \oplus u_3
$$

The coded block $c = [u_1, u_2, u_3, p_1, p_2, p_3]$ has six bits, each linked to the same three data bits. Version zero might send $[u_1, u_2, u_3, p_1]$; version one $[p_2, p_3, u_1, u_2]$; version two $[u_3, p_1, p_2, p_3]$; version three another overlapping set. Each gives the receiver a different subset of equations about the same three unknowns. None duplicates the data; each adds an independent constraint. That is the information-theoretic meaning of "the same information": every transmission refers to the same unknowns even though the transmitted bits differ.

| **Concept** | **Description** |
| --- | --- |
| **LDPC Coding** | Creates a long codeword with info + parity bits; no duplication of data. |
| **Rate Matching** | Selects a subset of coded bits (via puncturing) to fit radio resources. |
| **Redundancy Versions (RV0–RV3)** | Same length, different content from the same LDPC codeword. |
| **Soft Combining** | Merges likelihoods from multiple RVs to boost decoding reliability. |
| **Systematic Bits** | The raw information bits, present mainly in RV0 & RV3. |
| **Parity Bits** | Additional redundancy (relationships among info bits), dominant in RV1 & RV2. |
| **Incremental Redundancy (IR)** | Combines new parity info across RVs — both energy and coding gain. |
| **Fixed TBS per HARQ** | Maintains soft buffer alignment; ensures decoding consistency. |

#### 3.1.4 **Implicit vs. Explicit Link Adaptation**

HARQ adapts the link without meaning to. When decoding fails, more redundancy is sent, and the effective code rate falls — implicit link adaptation, reactive, needing no channel prediction and robust under fast fading. Explicit link adaptation is the scheduler choosing a modulation and coding scheme from a channel-state report: proactive, faster when the report is accurate, and wrong when it is stale.

> [!important] 💡
> Difference: **Implicit link adaptation is reactive (based on decoding results), while explicit link adaptation is proactive (based on estimated CSI).**

> [!book] Book expansion
> Chapter 13 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 275–297, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00013-1)) treats HARQ as a MAC protocol whose transmissions, feedback, and process state are realised with physical channels — which is why its clauses are split between two specifications.

> [!spec] 3GPP reality check
> The HARQ entity, its processes, and the new-data indicator are [TS 38.321 V18.10.0, clauses 5.3.2 and 5.4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); the redundancy versions themselves are TS 38.212 clause 5.4.2.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [HARQ page](https://www.sharetechnote.com/html/5G/5G_HARQ.html) walks through a process's state across several attempts with the DCI fields shown at each step.

### 3.2 **13.1.2 Downlink Hybrid-ARQ**

Section 3.1 described soft combining in general. This section shows how a downlink retransmission is scheduled and which DCI fields drive it.

A downlink retransmission is scheduled like a new transmission, and the DCI carries the HARQ fields: the process number, the new-data indicator, and — when code-block-group operation is configured — a transmission indicator and a flush indicator. The new-data indicator is one bit that means everything: toggled, the phone flushes its soft buffer and starts fresh; unchanged, it combines what arrives with what it stored. Figure 13.3 shows the exchange.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.3 shows the exchange.*

When retransmission per code-block group is enabled, as in Figure 13.4, only the groups that failed are sent again. The transmission indicator is a bitmap of which groups are included, and the flush indicator says whether the phone should combine them with its buffer or discard what it held — the case, for instance, when a pre-emption corrupted the earlier attempt.

#### 3.2.1 **13.1.3 Uplink Hybrid-ARQ**

Uplink HARQ is asynchronous in the same way: the network schedules a retransmission with a grant carrying the process number, the new-data indicator, and the group transmission indicator. There is no flush indicator, because the soft buffer is at the base station.

#### 3.2.2 **Why No CBGFI in the Uplink?**

!note[The phone does not combine anything on the uplink. The base station keeps the soft buffer and decides for itself whether to combine or flush; the phone simply retransmits what it is told to, keeping a copy of its data until acknowledged but not for combining.]

> [!important] 💡
> This means:
> The **UE doesn’t have a “soft-combining buffer” for IR accumulation.**
> The gNB decides whether to flush or combine based on scheduling, since it holds the combining memory.
> **The UE still keeps a copy of its transmitted data until acknowledged, but not for combining purposes.**

#### 3.2.3 **13.1.4 Timing of Uplink Acknowledgments**

LTE fixed the time between a downlink transmission and its acknowledgement. NR cannot, because under dynamic TDD the slot in which the acknowledgement would fall may be a downlink slot. So the timing is signalled: a three-bit field in the DCI indexes a configured table of offsets, as Figure 13.5 shows. NR also processes faster than LTE — Table 13.1 gives the minimum processing times by numerology, down to about 0.18 ms at 120 kHz spacing for the lowest-latency case.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*So the timing is signalled: a three-bit field in the DCI indexes a configured table of offsets, as Figure 13.5 shows.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*So the timing is signalled: a three-bit field in the DCI indexes a configured table of offsets, as Figure 13.5 shows.*

#### 3.2.4 **13.1.5 Multiplexing of HARQ Acknowledgments**

With several carriers or several transport blocks answered at once, the acknowledgement becomes a multi-bit message organised as a codebook. Figure 13.6 shows the semi-static form, a matrix with a cell per transport block and carrier, sized for the worst case. Figure 13.7 shows the dynamic form, sized to what was actually transmitted, with the downlink assignment index keeping the phone's and the network's picture of the codebook aligned even when a DCI was lost.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.6 shows the semi-static form, a matrix with a cell per transport block and carrier, sized for the worst case.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.6 shows the semi-static form, a matrix with a cell per transport block and carrier, sized for the worst case.*

> [!spec] 3GPP reality check
> Acknowledgement timing, the two codebook types, and the assignment index are [TS 38.213 V18.8.0, clause 9.1 and 9.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); the processing-time table is TS 38.214 Table 5.3-1.

> [!engineering] ShareTechnote engineering view
> The [HARQ page](https://www.sharetechnote.com/html/5G/5G_HARQ.html) has a worked example of the dynamic codebook with a lost DCI, which is the case the assignment index exists for.

### 3.3 **13.2 Radio Link Control (RLC)**

HARQ is fast and occasionally wrong. This section adds the second loop, RLC, which guarantees delivery per logical channel.

RLC complements HARQ by guaranteeing error-free delivery per logical channel: segmentation, duplicate removal, and — in acknowledged mode — retransmission. Figure 13.8 shows how several logical channels, each with its own RLC entity, are multiplexed by MAC onto one transport channel.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 13.8 shows how several logical channels, each with its own RLC entity, are multiplexed by MAC onto one transport channel.*

#### 3.3.1 **RLC Operation Modes**

Transparent mode adds nothing — no segmentation, no retransmission — and serves the broadcast and common control channels. Unacknowledged mode segments but does not retransmit, and serves voice and streaming, where a late packet is worth less than a dropped one. Acknowledged mode does everything, and is the mode for ordinary data bearers.

#### 3.3.2 **13.2.1 Sequence Numbering and Segmentation**

Each RLC PDU carries a sequence number of six, twelve, or eighteen bits depending on mode and configuration. When an SDU does not fit the transport block, it is segmented, and each segment's header carries segmentation information — first, middle, or last — and, for all but the first, a byte offset into the SDU. LTE also concatenated several SDUs into one PDU; NR dropped that, so that PDUs can be assembled before the grant arrives and only segmented, if needed, once its size is known. That removal is a latency saving.

#### 3.3.3 **13.2.2 Acknowledged Mode and RLC Retransmissions**

RLC retransmission is slower than HARQ and is driven by status reports rather than per-block feedback. Figures 13.10 and 13.11 show the mechanism: each entity keeps a transmission and a reception window; the receiver detects a missing PDU by its sequence number; when a reassembly timer expires it sends a status report listing what is missing; and the transmitter retransmits the missing PDUs or segments.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 13.10 and 13.11 show the mechanism: each entity keeps a transmission and a reception window; the receiver detects a missing PDU by its sequence number; when a reassembly timer expires it sends a status report listing what is missing; and the transmitter retransmits the missing PDUs or segments.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 13.10 and 13.11 show the mechanism: each entity keeps a transmission and a reception window; the receiver detects a missing PDU by its sequence number; when a reassembly timer expires it sends a status report listing what is missing; and the transmitter retransmits the missing PDUs or segments.*

> [!important] 💡
> ### **RLC Acknowledgment Transmission**
> In **Acknowledged Mode**, the **UE transmits acknowledgment via RLC status reports.**
> - These reports include **ACKs** for received PDUs and **NACKs** for missing ones.
> - The transmitter uses this information to **retransmit missing PDUs**.
> - Status reports can be triggered **autonomously** or **on request** by the transmitter.
> Thus, the UE provides **feedback using state reports**.

> [!spec] 3GPP reality check
> The three modes, segmentation, and acknowledged-mode retransmission are [TS 38.322 V18.2.0, clauses 5.2 to 5.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip); the retransmission limit that turns a persistent failure into a radio-link failure is clause 5.3.2.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [RLC page](https://www.sharetechnote.com/html/5G/5G_RLC.html) shows an acknowledged-mode status report byte by byte, with the negative-acknowledgement ranges that make it compact.

### 3.4 **13.3 PDCP (Packet Data Convergence Protocol)**

RLC repairs losses within one cell. This section adds the highest loop, PDCP, whose retransmission exists for one occasion: mobility.

PDCP is the highest layer that can retransmit, and its retransmission is for one occasion: mobility. It compresses headers, ciphers, protects integrity, and duplicates or routes across two connections; and at an inter-base-station handover, the PDUs the old base station had not delivered are forwarded to the new one and sent from there, so that nothing is lost even though every HARQ and RLC buffer below was flushed. PDCP retransmission is about surviving a change of base station.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents, with HARQ split once more between the entity and the timing of its acknowledgement.

The three loops live in three documents, with HARQ split once more. The HARQ entity — its sixteen processes and the one-bit new-data indicator — is TS 38.321, but when the acknowledgement is sent, and how several are packed into one codebook, is TS 38.213, and how fast a phone must be ready is a table in TS 38.214. RLC acknowledged mode, with its windows, polling, and status reports, is TS 38.322. PDCP's reordering and recovery are TS 38.323. Every timer and count in all of them is configured through TS 38.331, and the figure shows the ones a demo can set wrong.

![[99 Attachments/5G/Protocol Figures/STAR-13-Retransmission-Protocols-Protocol.png|The three retransmission loops and the documents, timers and counters that run them]]

*Protocol figure: The three retransmission loops and the documents, timers and counters that run them.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.212 | V18.8.0, [38212-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 5.4.2.1; 5.4.2.2 | LDPC rate matching and circular-buffer bit selection |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 9 | HARQ-ACK timing, resources, and procedures |
| TS 38.321 | V18.10.0, [38321-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.3; 5.4; 5.22 | DL-SCH/UL-SCH HARQ and code-block-group-related procedures |
| TS 38.322 | V18.2.0, [38322-i20.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip) | 5.2; 5.3; 5.4 | RLC TM, UM, and AM operation |
| TS 38.323 | V18.5.0, [38323-i50.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip) | 5.1; 5.2 | PDCP transfer, reordering, duplication, and recovery context |

!note[**When you build or run a demo.** The retransmission loops are the most visible thing in a base-station log. Every grant shows a process number and a redundancy version, and a healthy link shows version zero mostly succeeding with occasional versions two and three. The acknowledgement offsets the scheduler may choose are a configured list; a TDD pattern with few uplink slots needs larger values in it, or acknowledgements have nowhere to go. RLC's poll timer and retransmission limit decide how long a persistent failure takes to become a radio-link failure — a small limit makes a flaky link drop quickly, a large one makes it stall. And PDCP's reordering timer is what lets a split bearer tolerate a slow leg; set it too low and packets are delivered out of order to the application. Each is one line, and each line is one clause.]

Release 15 began with parallel stop-and-wait HARQ, LDPC and Polar coding, flexible feedback timing, the RLC modes, and PDCP sequence handling, and these remain the core model. Release 16 added reliability features for URLLC, configured grants, multi-point transmission, code-block-group behaviour, and duplication. Release 18 refines conditions without moving HARQ out of MAC or turning PDCP into ordinary ARQ. Release summaries are cross-checked with TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the loops; this trace combines two noisy observations of one bit so that you can see soft combining add up.

Assume one coded BPSK bit $x=+1$ is observed twice through unit-gain channels with equal noise variance $\sigma^2=1$. The received normalized samples are $y_1=0.4$ and $y_2=0.7$. For this teaching model, the LLR for each observation is $2y/\sigma^2$, and independent observations add. This is not the NR LDPC decoder; it isolates the soft-combining principle.

**What we are working out.** The combined LLR and hard decision after two transmissions.

$$
\begin{aligned}
L_1
&=\frac{2y_1}{\sigma^2}
=\frac{2(0.4)}{1}
=0.8,\\
L_2
&=\frac{2y_2}{\sigma^2}
=\frac{2(0.7)}{1}
=1.4,\\
L_{\mathrm{comb}}
&=L_1+L_2\\
&=0.8+1.4\\
&=2.2>0\quad\Rightarrow\quad\hat{x}=+1.
\end{aligned}
$$

In this formula, $x$ is a unit-amplitude BPSK teaching symbol and $\hat{x}$ is the resulting hard decision. $y_1$ and $y_2$ are normalized received samples. $\sigma^2$ is normalized noise variance. $L_1$, $L_2$, and $L_{\mathrm{comb}}$ are dimensionless log-likelihood ratios; their sign determines the hard decision, while magnitude expresses confidence. All numbers are pedagogical assumptions. The standards plane supplies LDPC rate matching, RV, HARQ process, and feedback behavior; the simple AWGN equation is an explanatory model.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $x$ | +1 | normalized BPSK amplitude | pedagogical assumption |
| $y_1$ | 0.4 | normalized amplitude | pedagogical assumption |
| $y_2$ | 0.7 | normalized amplitude | pedagogical assumption |
| $\sigma^2$ | 1 | normalized variance | pedagogical assumption |
| $L_1$ | 0.8 | dimensionless | derived result |
| $L_2$ | 1.4 | dimensionless | derived result |
| $L_{\mathrm{comb}}$ | 2.2 | dimensionless | derived result |

The calculation uses two similar observations, resembling Chase-style combining. Incremental redundancy additionally provides differently selected coded bits, which the real decoder integrates in its codeword-domain buffer. A toy XOR parity demonstration can explain the idea of new parity, but it must not be called NR LDPC behavior. The correct NR mechanism is defined by TS 38.212 rate matching and the scheduled RV.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star supports U11, U12, U13, and U14. U11 supplies coding and error-detection foundations; U12 connects modulation, soft information, and link adaptation; U13 introduces protocol behavior and scheduling feedback; U14 evaluates latency, throughput, and reliability tradeoffs. The layered escalation is an effective capstone because it forces students to connect probability of decoding error with protocol state and end-to-end delay.

A useful exercise gives students a trace containing process ID, NDI, RV, CRC, RLC SN, and PDCP SN. They must mark which layer can repair each gap and which evidence is insufficient. This replaces memorized acronyms with causal debugging.

!warning[**“HARQ is a PHY protocol”.**

HARQ entities and process state belong to MAC. PHY implements coding, modulation, feedback channels, and soft combining. Both layers participate, but ownership matters when reading specifications and debugging buffers.]

!warning[**“Each RV is a separately encoded packet”.**

RV controls rate-matched selection from the coded-block circular buffer. The receiver combines selections associated with the same transport-block context. Treating RV as a new packet discards the reason soft-buffer identity is essential.]

!warning[**“NDI 0 means retransmission and NDI 1 means new data”.**

NDI is interpreted as a toggle within a HARQ process. Process history determines whether data is new.]

!warning[**“PDCP retransmits ordinary radio losses”.**

RLC AM provides the ordinary acknowledged retransmission loop. PDCP handles reordering, duplicate detection, duplication-related behavior, and recovery around mobility/bearer procedures; end-to-end protocols may retransmit above it.]

!warning[**“HARQ always completes in less than one millisecond”.**

Feedback and retransmission timing depend on numerology, slots, duplex pattern, scheduling, processing capability, and configuration. A sub-millisecond example is not a universal service guarantee.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-13-Retransmission-Protocols|Chapter 13]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00013-1)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
12. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_HARQ.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_RLC.html)
15. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_PDCP.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| ACK | Acknowledgment | successful HARQ reception indication. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| AM | Acknowledged mode | RLC mode with retransmission/status behavior. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| ARQ | Automatic repeat request | feedback-driven retransmission method. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| AWGN | Additive white Gaussian noise | simple channel model in the example. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| CRC | Cyclic redundancy check | decoded-block error detector. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| HARQ | Hybrid automatic repeat request | MAC process using coded retransmissions and soft combining. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| LDPC | Low-density parity-check | NR shared-channel coding family. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| LLR | Log-likelihood ratio | soft bit confidence metric. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| MAC | Medium Access Control | layer owning HARQ process state. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| NACK | Negative acknowledgment | unsuccessful HARQ reception indication. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| NDI | New data indicator | per-process toggle distinguishing new data context. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| PDCP | Packet Data Convergence Protocol | Layer-2 sequence, security, reordering, duplication context. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| PDU | Protocol data unit | layer-specific transmitted data object. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| RLC | Radio Link Control | segmentation, reassembly, and optional ARQ layer. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| RV | Redundancy version | rate-matching selection indication. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| SN | Sequence number | ordered identity in RLC or PDCP space. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| TM | Transparent mode | RLC mode with minimal processing. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| UE | User equipment | NR terminal. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| UM | Unacknowledged mode | sequenced RLC mode without RLC retransmission. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $x$ | transmitted BPSK teaching symbol | normalized amplitude |
| $y_1,y_2$ | first and second received samples | normalized amplitude |
| $\sigma^2$ | noise variance | normalized power |
| $L_1,L_2$ | individual log-likelihood ratios | dimensionless |
| $L_{\mathrm{comb}}$ | combined log-likelihood ratio | dimensionless |
| $\hat{x}$ | detected symbol | normalized amplitude |
| $N_\mathrm{HARQ}$ | HARQ process identifier/count context | integer |
| $SN_\mathrm{RLC}$ | RLC sequence number | modular integer |
| $SN_\mathrm{PDCP}$ | PDCP sequence number | modular integer |
