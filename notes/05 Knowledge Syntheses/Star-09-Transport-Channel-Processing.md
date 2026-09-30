---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 9
title: Transport-Channel Processing
language: en
course_units:
- U03
- U04
- U05
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-09 — Transport-Channel Processing

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Imagine posting a long letter through a storm. Some of the ink will run. You cannot stop that; you can only prepare for it, and there is a natural order to the preparations. First you seal the envelope in a way that shows if it was damaged — that is the cyclic redundancy check, which cannot fix an error but can prove one happened. Then you split a long letter into postcards of a fixed size, each with its own seal, so that one ruined card does not ruin the whole. Then you rewrite each card with extra words that let a reader reconstruct a smudged one — that is the error-correcting code, the LDPC code in NR, and it is the only step that actually repairs damage.

Then, because the envelope has limited space, you decide how many of those extra words to include this time, and which ones to send if the first attempt fails — rate matching and redundancy versions. Then you write in a script only your addressee knows, so that a neighbour's letter cannot be mistaken for yours — scrambling. And finally you choose the handwriting: small and dense when the weather is fine, large and sparse when it is not — modulation.

![[99 Attachments/5G/Concept Figures/STAR-09-Transport-Channel-Processing-Concept.png|Transport-channel processing explained as a letter sent through a storm]]

*Concept figure: Transport-channel processing explained as a letter sent through a storm.*

The order is not arbitrary. Each precaution assumes the one before it: you cannot split what is not sealed, and you cannot fix what you cannot detect. And "say it twice" is the expensive step — every extra word is bandwidth not spent on the message — so the whole chain is really about spending as little redundancy as the storm requires, and no more. The number that comes out at the end, the transport block size, is how many words of actual message fit once the precautions are paid for. That number is what a throughput test measures, and this chapter is where it comes from.

The chapter walks the chain in order, from the transport block MAC hands down to the antenna ports the signal leaves on, and then turns to the reference signals that ride with the data so the receiver can undo the channel. The whole thing lives in two documents: TS 38.212 owns everything that is still bits, and TS 38.211 owns everything that has become a signal.

**The question this chapter answers.** How does one transport block become mapped radio symbols, and where do coding, rate matching, HARQ, modulation, layers, and reference signals enter?

!important[**The short answer.** MAC supplies a transport block. The physical layer adds a CRC, segments when needed, encodes each code block with LDPC, selects coded bits through rate matching, concatenates and scrambles, modulates, maps layers and antenna ports, inserts reference signals, and maps the grid. HARQ changes the selected redundancy and combines receiver evidence; it does not create a new information block on every retransmission.]

Names you will meet in this note: transport block (TB), code block (CB), cyclic redundancy check (CRC), Low-Density Parity-Check code (LDPC), base graph (BG), redundancy version (RV), incremental redundancy (IR), log-likelihood ratio (LLR), modulation and coding scheme (MCS), transport block size (TBS), cubic metric (CM), Discrete Fourier Transform spread OFDM (DFT-s-OFDM), demodulation reference signal (DM-RS), phase-tracking reference signal (PT-RS), code-division multiplexing (CDM).

## 2. Where you are in 5G

Section 1 prepared a letter for a storm in a fixed order. The map below shows that order as boxes in 5G: the pipeline between MAC's transport block and the antennas.

![[99 Attachments/5G/Locator Maps/STAR-09-Where-You-Are-in-5G.png|Where Star 09 sits in the whole 5G system]]

*Locator: Where Star 9 sits in the whole 5G system.*

This chapter lights channel coding in the physical foundations and the data-plus-control box in the procedures band. It sits between the grid of Star 07, on which everything is placed, and the retransmission protocol of Star 13, which reuses the redundancy versions defined here. Star 30 covers the same coding chain from the specification's side, clause by clause.

The Knowledge Structure Map lays the eight stages out as a pipeline, each with what goes wrong without it, and marks where the owning specification changes from bits to signal. The mechanism diagram works one transport-block-size calculation through with every number checked.

![[99 Attachments/5G/Knowledge Maps/STAR-09-Transport-Channel-Processing-Knowledge Structure Map.png|STAR-09 system-position map]]

*Knowledge map: The eight stages of transport-channel processing and what each defends against.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-09-Transport-Block-Processing-Chain.png|Star 09 mechanism and handoff diagram]]

*Mechanism: A worked transport-block-size calculation.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Content → Pipeline at a glance → 9.1 Transport Block (TB), CRC & Segmentation → 9.2 LDPC Channel Coding (per Code Block) → 9.3 Rate Matching (per CB) — “Make it fit & prep for HARQ-IR”.


## 3. The textbook road

Section 2 placed the pipeline. The road below walks through it stage by stage in the book's order, from the transport block to the reference signals that travel with it.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

The whole chain in one line: transport block → CRC → LDPC per code block → rate matching with redundancy versions → concatenation → scrambling → modulation → layer mapping (at most four uplink layers) → optional uplink DFT precoding → multi-antenna precoding → resource mapping → OFDM → radio.

### 3.1 Content

The road begins with a rule for reading the chapter: every stage exists for the stage after it.

!important[The chapter is best read as one pipeline. Every stage exists because the next one has a constraint the previous cannot satisfy, and reading the blocks in isolation misses that.]

> [!book] Book expansion
> Chapter 9 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 165–196, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00009-X)) presents the chain as a block diagram and then opens each block; this note keeps that order.

> [!spec] 3GPP reality check
> The bit-level chain is [TS 38.212 V18.8.0, clauses 5–7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip); the signal-level stages that follow are TS 38.211 clause 7.3.1.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [channel coding page](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html) walks the same chain with worked bit counts at each stage.

### 3.2 Pipeline at a glance

Section 3.1 gave the rule; this section gives the picture, the block diagram that the rest of the road fills in.

Figure 9.1 is the block diagram for the whole chapter: transport block, transport-block CRC, code-block segmentation, LDPC per code block, rate matching with redundancy versions, bit interleaver, scrambling, modulation, layer mapping, the uplink-only DFT precoding, multi-antenna precoding, and resource mapping. Keep it in mind; each later stage is one box of it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.1 is the block diagram for the whole chapter: transport block, transport-block CRC, code-block segmentation, LDPC per code block, rate matching with redundancy versions, bit interleaver, scrambling, modulation, layer mapping, the uplink-only DFT precoding, multi-antenna precoding, and resource mapping.*

### 3.3 9.1 Transport Block (TB), CRC & Segmentation

The first three blocks of the diagram receive the letter and seal it. This section covers the transport block, its CRC and the split into code blocks.

MAC hands the physical layer a transport block whose size was chosen to fit the grant at the chosen modulation and coding scheme. The physical layer appends a transport-block CRC for end-to-end error detection. If the block is larger than the code can handle, it is split into code blocks of a standard maximum size, each with its own CRC. Segmentation exists for the decoder: a bounded block bounds the decoder's complexity and latency, and lets several blocks be decoded in parallel.

> [!spec] 3GPP reality check
> CRC attachment is [TS 38.212 V18.8.0, clause 5.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) — 24 bits for a transport block, 16 for small ones — and segmentation is clause 5.2.2, with the code-block limit of 8448 bits for base graph 1 and 3840 for base graph 2.

### 3.4 9.2 LDPC Channel Coding (per Code Block)

Section 3.3 produced code blocks. This section encodes each one, the only stage that can actually repair damage.

Each code block is encoded with a quasi-cyclic low-density parity-check code. NR defines two base graphs, and the encoder chooses between them by block size and code rate — the small graph for small or low-rate blocks, the large one otherwise — and lifts the chosen graph to the block's size. The output is systematic bits followed by parity bits, and the code rate is set later by rate matching. LDPC was chosen over LTE's Turbo code for its high throughput, efficient hardware, and strong performance across a wide range of signal-to-noise ratios. Figure 9.2 shows the coding steps, Figure 9.3 how a transport block is cut into code blocks with their CRCs, and Figure 9.4 when each base graph is selected. Segmentation matters again here: retransmission of individual code-block groups, covered in Star 13, depends on each block carrying its own CRC.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.2 shows the coding steps, Figure 9.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.2 shows the coding steps, Figure 9.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.2 shows the coding steps, Figure 9.*

> [!spec] 3GPP reality check
> The base-graph selection rule is [TS 38.212 V18.8.0, clause 7.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip): base graph 2 when the payload is at most 292 bits, or the rate is at most one quarter, or the payload is at most 3824 bits at a rate of at most two thirds; base graph 1 otherwise. The encoding itself is clause 5.3.2.

### 3.5 9.3 Rate Matching (per CB) — “Make it fit & prep for HARQ-IR”

The encoder produced more bits than the envelope holds. This section chooses which of them to send now and which to keep for a retransmission.

Rate matching has two jobs at once, and the author's note states them precisely.

> [!important] 💡
> **Goals**
> 1. **Fit the coded bits to exactly the allocated RE budget** (after excluding DM-RS/CSI-RS/SSB/control/reserved REs).
> 2. Enable **HARQ incremental redundancy** via **Redundancy Versions (RVs)**.

The mechanism, per code block, is a circular buffer. Some systematic bits — up to a third, depending on block size — are punctured; the remaining bits are written to the buffer, systematic first and then parity; and exactly as many bits as the allocation can carry are read out, starting at an offset that depends on the redundancy version. Figure 9.5 shows the ring and the four start points.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.5 shows the ring and the four start points.*

Think of the LDPC mother code as very low-rate. Each redundancy version reads a different stretch of it, so later retransmissions bring new parity rather than repeating the old. The first transmission is systematic-leaning; later ones are parity-heavier and complementary, and when the receiver combines them the effective code rate falls.

| RV | Read-out start in circular buffer | Intuition |
| --- | --- | --- |
| 0 | Offset A (systematic-leaning) | Good first shot |
| 1 | Offset B (parity-heavier) | Adds new parity diversity |
| 2 | Offset C (parity/systematic mix) | Further diversity |
| 3 | Offset D (complementary tail) | Even more parity |

On the receiver side the log-likelihood ratios from each attempt are added before decoding, which gives both coding gain and accumulated signal-to-noise ratio.

> [!important] 💡
> Soft Combining vs. “Hard Combining” : **Soft combining (NR HARQ)**: store **LLRs**, add them across retransmissions, then decode → best performance. “Hard combining”: combine hard decisions (bits); **not** used for NR HARQ because it loses reliability info.

The receiver de-rate-matches, soft-combines, decodes each code block, reassembles the transport block, and checks its CRC. If the soft buffer is limited, only a fraction of the mother code is kept; Figure 9.6 shows the idea that one third of the coded bits are never sent and two thirds may be, under the buffer constraint.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*If the soft buffer is limited, only a fraction of the mother code is kept; Figure 9.6 shows the idea that one third of the coded bits are never sent and two thirds may be, under the buffer constraint.*

> [!spec] 3GPP reality check
> Rate matching and the redundancy-version start positions are [TS 38.212 V18.8.0, clause 5.4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), Table 5.4.2.1-2.

### 3.6 9.4 Bit Interleaver (symbol-wise)

Rate matching chose the bits; this section reorders them so that each modulation symbol carries a mix of reliable and fragile ones.

The interleaver arranges the rate-matched bits in a matrix with as many rows as there are bits per modulation symbol, writes row by row, and reads column by column, so that each column becomes one modulation symbol's bits. The effect is to spread systematic and parity bits across symbols, so that one badly received symbol does not wipe out a run of consecutive bits. Figure 9.7 shows the 16QAM case.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.7 shows the 16QAM case.*

### 3.7 9.5 Scrambling (bit-domain separation)

The interleaved bits are still recognisable to a neighbour's decoder. This section makes them look random to anyone but the intended receiver.

!note[Scrambling multiplies the bit stream by a pseudo-random sequence that depends on the cell or the device. Without it, a decoder could lock onto an interferer's codeword; with it, an interferer's bits look random after descrambling and the code's processing gain is preserved. The sequence is initialised from the device's RNTI and a data-scrambling identity, falling back to the cell identity, and the downlink uses different sequences for two transport blocks.]

#### 3.7.1 How to understand the scrambling is a mechanism helps Multi-user / multi-cell “separation” at the bit domain?

NR uses different sequence initialisations for different things — downlink against uplink, one channel against another — keyed by identities such as the RNTI and, sometimes, a scrambling or cell identity. On the downlink, the base station scrambles the data bits with the device's RNTI, and also masks the control channel's CRC with it; only the device with the right RNTI descrambles to sense. On the uplink, different devices use different sequences, so after equalisation the decoder for one device treats residual energy from another as noise. Broadcast signals are tied to the cell identity, so another cell's broadcast fails the check.

> [!important] 💡
> This scrambling works on the bits themselves. It helps the decoder ignore the “wrong” stream and pass CRC only for the “right” one. It does **not** reduce the **power** of inter-cell/other-UE interference. The RF interference is still there. It’s **not** a strong “ID” mechanism by itself; the practical “this one is for me” check comes from the **RNTI-masked CRC** (PDCCH) and successful de-scrambling+decoding (PDSCH/PUSCH).

### 3.8 9.6 Modulation

Scrambled bits become symbols here. This section chooses the handwriting: how many bits each symbol carries and when to use which.

Each column of bits from the interleaver becomes one complex symbol: QPSK, 16QAM, 64QAM, or 256QAM, carrying two, four, six, or eight bits. The uplink adds π/2-BPSK for use with DFT precoding, where a very low cubic metric matters more than bits per symbol — a coverage-limited device at the cell edge. More bits per symbol means a denser constellation and a smaller margin for noise.

### 3.9 9.7 Layer Mapping (spatial streams before antennas)

Symbols can travel on several spatial streams at once. This section splits them into layers, before any antenna is chosen.

A layer is a spatial stream that exists before any antenna is chosen. Layer mapping sends every n-th modulation symbol to layer n, so one coded transport block feeds up to four layers — the downlink reaches eight through two transport blocks. The uplink has a restriction: DFT-precoded transmission supports a single layer only, so multi-layer uplink needs plain OFDM. Layers are not antennas; they are the streams that spatial multiplexing carries when the channel's rank allows, and their count is bounded by that rank.

> [!important] 💡
> **Layers are an abstract baseband stage** between codeword(s) and antennas. **Rank-1 ≈ beamforming** (one layer precoded across many antennas), **Every antenna** transmits a **weighted sum of all active layers**.

> [!important] 💡
> **SDM meaning.** Spatial Division Multiplexing = **sending multiple simultaneous spatial streams (layers) through different channel eigenmodes/users via precoding.** It’s **not** “different users → different antenna ports”; it’s **different users/layers → different spatial beams formed across the same antenna array.**

### 3.10 9.8 Uplink Transform Precoding (DFT-s-OFDM option) & Cubic Metric

Section 3.9 produced layers. Before they reach the uplink antenna, this section explains the optional DFT step and the amplifier reason for it.

Inserting a DFT before the OFDM subcarrier mapping gives the uplink a single-carrier-like envelope. The reason is the power amplifier: a waveform with lower cubic metric needs less back-off, so the same amplifier delivers more average power while staying linear, which is coverage. Figure 9.8 shows the size-M DFT over the M allocated subcarriers and the allowed sizes, products of two, three, and five.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.8 shows the size-M DFT over the M allocated subcarriers and the allowed sizes, products of two, three, and five.*

It sits after layer mapping and before multi-antenna precoding: each layer's symbol vector is transformed, mapped to contiguous subcarriers, and passed to OFDM. Combined with π/2-BPSK the cubic metric falls further still. Plain OFDM remains available, and DFT precoding is optional and configured per grant.

> 💡 CM refresher: A waveform “peakiness” metric tied to PA linearity. **Lower CM ⇒ the same PA can transmit more average power while staying linear.**

### 3.11 9.9 Multi-Antenna Precoding & Resource Mapping (Layers → Ports → Grid)

The layers now meet the antennas. This section follows them through the precoder to ports and onto the grid, and shows why the receiver never needs to know the precoder.

The chain from here is layers, through the precoder W, to antenna ports, through resource mapping to resource elements, and then to physical antennas. On the downlink the demodulation reference signal is precoded exactly as the data is, which makes precoding transparent to the receiver: it estimates the effective channel per layer and never needs to know W. Figure 9.9 shows the downlink precoding block in its context of reference signals, quasi co-location, and transmission configuration.

> [!important] 💡
> **Precoding** $\mathbf{W}$ **:** **maps L layers →** $N_t$ **antennas via linear combinations. All antennas help transmit all layers.**

> [!important] 💡
> **Reception:** each UE sees $\mathbf{y}_k = \mathbf{H}_k \mathbf{W}\mathbf{s} + \mathbf{n}$. Good $\mathbf{W}$ makes “its” layers strong and others weak (SU: parallel eigenmodes; MU: inter-user interference suppressed).

> [!important] 💡
> **MU-MIMO:** different UEs get different subsets of layers simultaneously; separation by **precoding**.

Precoding is a linear spatial mapping despite its name; the word is an accident of history.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Precoding is a linear spatial mapping despite its name; the word is an accident of history.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.12 shows the mapping from virtual to physical to common resource blocks and the interleaved and non-interleaved modes that DCI selects between; interleaving buys frequency diversity for allocations of any size.*

Resource mapping fills the grid frequency first and time second, so that transmission and reception can be pipelined. Figure 9.12 shows the mapping from virtual to physical to common resource blocks and the interleaved and non-interleaved modes that DCI selects between; interleaving buys frequency diversity for allocations of any size.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.12 shows the mapping from virtual to physical to common resource blocks and the interleaved and non-interleaved modes that DCI selects between; interleaving buys frequency diversity for allocations of any size.*

With DFT precoding on the uplink the reference signal cannot simply be mixed into the data without raising the cubic metric, so it is time-multiplexed with the data and built from Zadoff–Chu sequences with phase rotations. Figure 9.20 shows rate matching around co-scheduled code-division groups and Figure 9.21 the uplink reference-signal generation.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.20 shows rate matching around co-scheduled code-division groups and Figure 9.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.20 shows rate matching around co-scheduled code-division groups and Figure 9.*

### 3.12 9.10 Downlink Reserved Resources

Mapping onto the grid assumes every element is free. This section describes the elements that data must avoid so that a future signal can be placed there.

Forward compatibility needs a way to carve out downlink resource elements that data must be mapped around, so that a future signal can be placed there without breaking today's devices. Three ways exist: refer to an LTE carrier, to avoid its always-on reference signal; refer to a control resource set; or define a resource set with bitmaps. Figure 9.13 shows the bitmap method: a time bitmap selects symbols in one slot or a pair, a frequency bitmap selects whole resource blocks within those symbols, and a third bitmap of forty slots switches the pattern on and off over time without reconfiguring the other two.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.13 shows the bitmap method: a time bitmap selects symbols in one slot or a pair, a frequency bitmap selects whole resource blocks within those symbols, and a third bitmap of forty slots switches the pattern on and off over time without reconfiguring the other two.*

Reservation can also be dynamic: a DCI indicator says whether a configured pattern applies to a given assignment. Up to eight resource sets may be configured but only two indicators fit in the DCI, so sets are assigned to one indicator or the other and switched together. Figures 9.14 and 9.15 show the activation.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 9.14 and 9.15 show the activation.*

### 3.13 9.11 Reference Signals

The data is mapped; something must travel with it so that the receiver can undo the channel. This section introduces NR's purpose-specific reference signals.

NR's reference signals are purpose-specific and transmitted only when needed, in both directions — the ultra-lean principle in practice, and the opposite of LTE's always-on cell-specific signal. This chapter covers the demodulation reference signal for the data channels, which may include signals for other devices scheduled alongside in multi-user MIMO, and the phase-tracking signal; the sounding signals were Star 08.

### 3.14 9.11.1 Demodulation Reference Signals for OFDM (DL & UL)

Of those signals, one always accompanies data. This section describes its placement in time and its structure in frequency, two independent choices.

!important[The demodulation reference signal is the only signal guaranteed to accompany data, and it is what the receiver estimates the channel from. Its placement in time and its structure in frequency are two independent choices.]

#### 3.14.1 Time-domain placement (Fig. 9.16)

Two mapping types set where the reference signal sits in the slot, and it may occupy one symbol or two. Double-symbol placement exists mainly to provide more orthogonal ports. Front-loading the reference signal at the start of the transmission is what lets the receiver begin estimating — and decoding — before the slot ends. Figure 9.16 shows the options; some Release 15 restrictions were relaxed in Release 16.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.16 shows the options; some Release 15 restrictions were relaxed in Release 16.*

#### 3.14.2 Underlying sequence & why it’s “underlaid”

The reference signal is built on a Gold sequence of length 2³¹−1, whose good autocorrelation gives flat reference quality across frequency. The sequence is generated across all common resource blocks but transmitted only on the allocated ones. Generating it everywhere is what guarantees that devices scheduled together share the same base sequence, so that orthogonal codes applied on top of it produce mutually orthogonal reference signals for multi-user MIMO; if different devices used different base sequences, their references would not be orthogonal. The identity that seeds the sequence is configurable, with the cell identity as default.

> [!important] 💡
> > relationship type vs. mapping; PN; “underlaying”:
> - **Mapping type (A/B)** = **time-domain** scheduling of RS **occasions** (when in the slot). **Reference-signal type (1/2)** = **frequency-domain** structure (how subcarriers & CDM groups are laid out) **and** the **max # of orthogonal RSs** you can support. They are **independent knobs** — you can combine A/B with type 1/2.
> - The **“underlying PN”** is the **common Gold sequence** **under** all RSs; **orthogonal codes** (and sometimes frequency/time offsets) are **applied on top (underlayed/overlaid)** so multiple RSs from the **same** base PN become **mutually orthogonal** — crucial for MU-MIMO.
> - **Figs. 9.18 & 9.19** show how **type-1** and **type-2** place subcarriers & CDM groups to produce **many orthogonal RSs** ⇒ supports **multi-layer SU-MIMO** and **multi-user MIMO** demodulation.

#### 3.14.3 Frequency-domain structure

Figure 9.17 shows the generation from a common base sequence and the orthogonal covers that separate ports.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 9.17 shows the generation from a common base sequence and the orthogonal covers that separate ports.*

Type 1, in Figure 9.18, maps the base sequence to every second subcarrier. Ports 1000 and 1001 use the even subcarriers and are separated by different length-two codes; ports 1002 and 1003 use the odd subcarriers, again separated by codes — two code-division groups in all. With two reference symbols a time-domain length-two code extends the orthogonality, giving up to eight orthogonal reference signals.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Type 1, in Figure 9.18, maps the base sequence to every second subcarrier.*

Type 2, in Figure 9.19, makes each code-division group two neighbouring subcarriers under a length-two code, two ports per group, with two such pairs per resource block, so three groups and six orthogonal signals per symbol; with two symbols and the time-domain code, twelve. Type 2 is sparser in frequency but supports more ports, and targets multi-user MIMO with many devices scheduled together.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Type 2, in Figure 9.19, makes each code-division group two neighbouring subcarriers under a length-two code, two ports per group, with two such pairs per resource block, so three groups and six orthogonal signals per symbol; with two symbols and the time-domain code, twelve.*

The point of all this orthogonality is that the receiver can estimate each layer's or each device's channel cleanly, which is what single-user and multi-user MIMO both depend on.

### 3.15 9.11.2 Demodulation Reference Signals for **DFT-Precoded** OFDM Uplink

Section 3.14 covered the OFDM uplink and downlink. With DFT precoding the design changes, and this section explains why Zadoff–Chu sequences take over.

With DFT precoding the design is single-layer only and must keep the cubic metric low, so Zadoff–Chu sequences are used, with additional sequences obtained by linear phase rotation as Figure 9.21 showed. For the very-low-cubic-metric π/2-BPSK uplink, Release 16 added π/2-BPSK-modulated pseudo-random sequences for the shortest lengths, so that the reference signal does not become the coverage limit.

### 3.16 9.11.3 Phase-Tracking Reference Signals (PT-RS)

Demodulation reference signals correct the channel; they cannot follow phase noise within a symbol. This section adds the reference signal shaped for that problem.

Phase noise grows with carrier frequency, and at millimetre wave it rotates the constellation within a single symbol. The phase-tracking reference signal is new in NR and shaped for that problem: dense in time and sparse in frequency, present only together with a demodulation reference signal and only when configured, with a density that follows the modulation and coding scheme and resets at each reference occasion.

### 3.17 **Keep the three concepts distinct:**

Three words have been used above that are easily merged. This section keeps layers, ports and antennas distinct, step by step.

> [!important] 💡
> 1. **Layers (L):** spatial streams (post-mod / post-DFT-precoding if used).
> 2. **Precoder matrix W (P×L):** maps **layers → antenna ports** (P) for **beamforming/multiplexing**.
> 3. **Ports → Physical antennas:** implementation (RF/digital) + **Resource Mapping** to **REs** on the grid.

Step by step: the layered symbol vector is multiplied by W to give the port vector; the reference signal is precoded the same way so that the receiver estimates the effective channel per layer; and resource mapping assigns each port's stream to its scheduled resource elements, skipping those occupied by reference signals, synchronisation, control, or reservation. On the uplink there are two modes: in codebook mode the network signals a codebook index and the device applies that W; in non-codebook mode W is effectively the identity and the network separates layers using its own measurements.

The receiver, at a high level, demodulates OFDM, estimates each port's channel from the precoded reference signal, uses W and the channel to separate the layers, produces log-likelihood ratios, de-interleaves, de-rate-matches and soft-combines across HARQ attempts, decodes each code block, and checks the CRCs.

### 3.18 Handy Tables

The tables below collect the numbers the road introduced, for quick lookup.

#### 3.18.1 A) Where key robustness comes from

| Stage | Robustness contribution |
| --- | --- |
| LDPC + RVs | Coding gain; IR across retransmissions lowers effective code rate |
| Bit interleaver | **Disperses burst errors, balances systematic/parity across symbols** |
| Scrambling | **Bit-domain separation of users/cells for decoder**; decorrelates interference |
| DFT-precoding (UL) | Lower CM → stronger practical SNR via higher PA efficiency |
| Precoding (W) | Beamforming / spatial multiplexing gain; per-layer DM-RS enables accurate equalization |

#### 3.18.2 B) HARQ quick facts

| Item | Meaning |
| --- | --- |
| HARQ type | **Incremental Redundancy** (IR) with **soft combining** (LLRs) |
| RVs | **RV0/1/2/3** → different circular-buffer readouts (complementary parity) |
| Benefit | Each retransmission adds **new information** |

### 3.19 End-to-End Processing Chain (with optional UL DFT-s-OFDM)

Everything above is now stitched into one chain, transmitter and receiver, with the retransmission loop of Star 13 closing it.

```plain text
[TB bits]
 → TB CRC
 → TB segmentation → [CB_i]
 → LDPC encode (per CB)
 → Rate Matching (per CB): puncture + circular buffer + choose RV (0/1/2/3)
 → Concatenate CBs (codeword)
 → Scrambling (UE/cell dependent)
 → Modulation (QPSK/16/64/256QAM; UL may use π/2-BPSK when DFT-s-OFDM)
 → Layer Mapping (≤4 UL layers)
 → [UL optional] DFT-precoding (per layer)
 → Multi-Antenna Precoding: s_L × W = x_ports
 → Resource Mapping: x_ports → REs (skip DM-RS/CSI-RS/SSB/reserved)
 → OFDM → RF
```

And the receiver, with incremental-redundancy HARQ: OFDM demodulation and per-port channel estimation from the precoded reference signal; layer separation using W and the channel, then soft demapping; soft combining with the log-likelihood ratios of earlier redundancy versions; and de-rate-matching, LDPC decoding per code block, and the code-block and transport-block CRC checks.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the two documents that split the chain at exactly the point where bits stop being bits.

The chain is split between two documents at exactly the point where bits stop being bits. TS 38.212 owns the CRC, the segmentation, the LDPC code, and rate matching; TS 38.211 owns scrambling, modulation, layer mapping, and everything after. TS 38.214 sits above both and says how many bits the chain will be asked to carry. The figure lays out the six clauses with the numbers each one fixes — the base-graph rule, the code-block limit, the redundancy-version start positions, the bits per symbol — because those are the numbers a decoder cannot work without, and they are why a wrong modulation-and-coding setting in a configuration shows up as a wrong block size in the log.

![[99 Attachments/5G/Protocol Figures/STAR-09-Transport-Channel-Processing-Protocol.png|The channel-coding clauses of TS 38.212, the signal clauses of TS 38.211, and the numbers a decoder cannot work without]]

*Protocol figure: The channel-coding clauses of TS 38.212, the signal clauses of TS 38.211, and the numbers a decoder cannot work without.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| Coding pipeline | [TS 38.212 V18.8.0, clauses 5–7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | CRC, segmentation, LDPC, rate matching, and the downlink and uplink shared-channel chains. |
| Modulation and mapping | [TS 38.211 V18.9.0, clauses 5–7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | Scrambling, modulation, layer mapping, precoding, resource mapping, and the reference signals. |
| Data procedures | [TS 38.214 V18.10.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | MCS tables and the transport-block-size derivation. |
| HARQ entity | [TS 38.321 V18.10.0, clauses 5.3–5.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | The processes that walk the redundancy versions. |

!note[**When you build or run a demo.** A base-station configuration names an MCS table and a maximum index, and every scheduling decision in the log shows the row that was chosen, the transport block size TS 38.214 derived from it, and the redundancy version of the attempt. A first transmission is version 0; if you see versions 2 and 3 following it, HARQ is working and the channel is losing blocks. Most open-source schedulers aim for a first-attempt block error rate of about ten percent — that is a design choice, so a log full of retransmissions is normal, and a log with none usually means the link is under-used. Below MAC there is nothing to capture: a packet analyser shows the MAC PDU and then the chain becomes a signal, which is why the log is where this chapter is debugged.]

The textbook describes the Release 15 and 16 chain. Release 18 keeps it and extends modulation options, MIMO and reference-signal configurations, reduced-capability operation, and multicast; the pipeline order is the stable spine, and exact tables and limits come from the fixed clauses. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define each stage; this trace runs one transport block through the arithmetic, a calculation you can redo by hand.

**Worked numerical example.**

Use a compact effective-rate proxy to show why information bits and mapped coded bits must be named separately. This is not the complete official base-graph selection.

**What we are working out.** Instructional effective transport-block information ratio, dimensionless, measured at the coded-bit allocation.

$$
\begin{aligned}
R_{eff} &= \frac{A}{G} \\ &= \frac{10000\ \mathrm{bit}}{14400\ \mathrm{bit}} \\ &= 0.694
\end{aligned}
$$

Where:

- $R_{eff}$ = 0.694, calculated (local ratio); it belongs to the scheduled coded-bit allocation.
- $A$ = 10000 bit, assumed (illustrative TB payload); it belongs to the MAC-to-PHY TB.
- $G$ = 14400 bit, assumed (illustrative mapped coded-bit budget); it belongs to the PHY allocation.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $R_{eff}$ | 0.694 | calculated | local ratio | scheduled coded-bit allocation |
| $A$ | 10000 bit | assumed | illustrative TB payload | MAC-to-PHY TB |
| $G$ | 14400 bit | assumed | illustrative mapped coded-bit budget | PHY allocation |

Bits cancel, so the ratio is dimensionless. It compares information bits with mapped coded bits only. TB/CB CRCs, filler bits, base-graph selection, rate matching per code block, modulation, layers, and retransmissions must be applied for a official transport calculation.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about the pipeline.

**Course alignment.** This note supports U03–U05 for the grid-to-bit pipeline and U11–U14 for coding, control, and retransmission. Use the symbol table when moving between scheduling, TS 38.214, TS 38.212, and TS 38.211. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

!warning[**“CRC corrects errors”.**

CRC detects residual errors; LDPC decoding supplies correction capability. The fix is to separate detection from correction: the CRC finds errors, the code fixes them.]

!warning[**“Rate matching changes the message”.**

It selects coded representation to fit resources; the information block remains the HARQ process payload. The fix is to distinguish the coded representation from the information block it represents.]

!warning[**“Scrambling encrypts data”.**

PHY scrambling randomizes/interleaves interference appearance. Security is handled elsewhere. The fix is to file scrambling under interference management.]

!warning[**“More QAM bits equal more payload”.**

Coding, overhead, layers, channel quality, and retransmissions determine delivered payload. The fix is to name every term in the budget before quoting a delivered rate.]

!warning[**“Every retransmission repeats identical bits”.**

An RV can select a different region of the mother-code circular buffer for incremental redundancy. The fix is to treat a redundancy version as a selection from the buffer.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 9, pp. 165–196, 2021, DOI [chapter 9](https://doi.org/10.1016/B978-0-12-822320-8.00009-X).
2. Chapter 9 notes of this knowledge base (the author's reading notes).
4. 3GPP, *TS 38.212 V18.8.0, clauses 5–7*, [Coding pipeline](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
5. 3GPP, *TS 38.211 V18.9.0, clauses 5–7*, [Modulation and mapping](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
6. 3GPP, *TS 38.214 V18.10.0, clauses 5–6*, [Data procedures](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
7. 3GPP, *TS 38.321 V18.10.0, clauses 5.3–5.4*, [HARQ entity](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).
8. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
9. ShareTechnote, [PDSCH](https://www.sharetechnote.com/html/5G/5G_PDSCH.html), accessed 2026-08-03.
10. ShareTechnote, [LDPC](https://www.sharetechnote.com/html/5G/5G_LDPC.html), accessed 2026-08-03.
11. ShareTechnote, [channel coding](https://www.sharetechnote.com/html/5G/5G_ChannelCoding.html), accessed 2026-08-03.
12. Saar University 5G course alignment.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| gNB | next generation NodeB | Section 1; fixed specification set in Section 6 |
| TB | Transport Block | Section 1; fixed specification set in Section 6 |
| CRC | Cyclic Redundancy Check | Section 1; fixed specification set in Section 6 |
| CB | Code Block | Section 1; fixed specification set in Section 6 |
| LDPC | Low-Density Parity-Check | Section 1; fixed specification set in Section 6 |
| HARQ | Hybrid Automatic Repeat Request | Section 1; fixed specification set in Section 6 |
| RV | Redundancy Version | Section 1; fixed specification set in Section 6 |
| QPSK | Quadrature Phase-Shift Keying | Section 1; fixed specification set in Section 6 |
| QAM | Quadrature Amplitude Modulation | Section 1; fixed specification set in Section 6 |
| MIMO | Multiple-Input Multiple-Output | Section 1; fixed specification set in Section 6 |
| DM-RS | Demodulation Reference Signal | Section 1; fixed specification set in Section 6 |
| PT-RS | Phase-Tracking Reference Signal | Section 1; fixed specification set in Section 6 |
| PDSCH | Physical Downlink Shared Channel | Section 1; fixed specification set in Section 6 |
| PUSCH | Physical Uplink Shared Channel | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $R_{eff}$ | Instructional effective information ratio | dimensionless |
| $A$ | Transport-block payload length | bit |
| $G$ | Mapped coded-bit budget | bit |

The symbols mean what they mean in this note; another note may use the same letter for something else.
