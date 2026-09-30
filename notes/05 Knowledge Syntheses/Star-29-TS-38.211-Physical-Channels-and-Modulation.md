---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 29
title: TS 38.211 Physical Channels and Modulation
language: en
course_units:
- U03
- U04
- U05
- U06
- U07
- U08
- U09
- U10
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-29 — TS 38.211 Physical Channels and Modulation

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf) — TS 38.211 V18.9.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

TS 38.211 never decides what to send. It defines the board every transmission is placed on, the pieces that exist, and the squares each piece may occupy. It is the grammar of the radio.

![[99 Attachments/5G/Concept Figures/STAR-29-TS-38.211-Concept.png|TS 38.211 explained as the grammar of a radio: a chessboard, the pieces, and where each may stand]]

*Concept figure: TS 38.211 explained as the grammar of a radio: a board, the pieces, and where each may stand.*

The board is clause 4. One square is a resource element, one subcarrier for one symbol. The square's size is the numerology: 15, 30, 60, or 120 kHz wide, and correspondingly short in time. Twelve squares up is a resource block, fourteen across is a slot, and a carrier is up to 275 blocks high, all numbered from one origin called Point A so that every device counts the same way. Each board belongs to one antenna port, a promise that every square on it saw the same channel, so a pilot on one square tells the receiver how to read the data on the others.

The pieces are clauses 5 to 8. Channels carry payload from above: the shared channels carry data, the control channels carry grants and feedback, the broadcast channel carries the master block, the random-access channel carries the preamble. Signals exist only for the receiver: demodulation reference signals to estimate the channel, channel-state signals to measure it, phase-tracking signals to follow the oscillator, sounding to let the base station listen, and the synchronisation signals to find the cell. Clause 5 supplies the shared arithmetic, how bits become constellation points and how points become an OFDM waveform, and clauses 6, 7, and 8 place the uplink, downlink, and sidelink pieces on the board.

What the document never says is which piece moves, when, and where. The grant is TS 38.213 and 38.214, the coding is TS 38.212, the configuration is TS 38.331. TS 38.211 answers one question only: what complex symbols sit on which squares, and how they become a waveform.

**The question this chapter answers.** What does TS 38.211 define, and what should I stop looking for inside it?

!important[**The short answer.** TS 38.211 defines the NR physical signal vocabulary and how it occupies time, frequency, antenna ports, and complex baseband: numerologies, frame timing, resource grids, modulation mappings, sequences, OFDM generation, and the physical channels and reference and synchronisation signals for uplink, downlink, and sidelink. It is the specification for the question "what complex symbols and resource elements are transmitted?" Coding is TS 38.212, procedures are TS 38.213 and 38.214, measurements are TS 38.215, and MAC is TS 38.321, so a grant crosses several documents: procedure in 38.214, coding in 38.212, modulation and mapping in 38.211.]

Names you will meet in this note: orthogonal frequency-division multiplexing (OFDM), bandwidth part (BWP), resource element (RE), physical resource block (PRB), common resource block (CRB), demodulation reference signal (DM-RS), channel-state-information reference signal (CSI-RS), phase-tracking reference signal (PT-RS), sounding reference signal (SRS), DFT-spread OFDM (DFT-s-OFDM), the physical shared, control, broadcast, and random-access channels (PDSCH, PUSCH, PDCCH, PUCCH, PBCH, PRACH), synchronisation signal block (SSB), control resource set (CORESET), resource-element group and control-channel element (REG, CCE).

The course freezes TS 38.211 V18.9.0, dated March 2026, from the official `38211-i90.zip` archive. The first-pass clause map of this knowledge base supplies a navigational index; the official document remains official, and the textbook chapter metadata is in [[5G NR 2e Source Manifest]].

## 2. Where you are in 5G

Section 1 called TS 38.211 the board every transmission is placed on. The map below shows where that board sits in 5G: under every channel and signal of the radio.

![[99 Attachments/5G/Locator Maps/STAR-29-Where-You-Are-in-5G.png|Where Star 29 sits in the whole 5G system]]

*Locator: Where Star 29 sits in the whole 5G system.*

This chapter lights the bottom of the specification band: the document that writes down the transmission structure of Star 07, the reference signals of Star 08, the control-channel geometry of Star 10, and the synchronisation block of Star 16. It receives coded bits from TS 38.212, Star 30, and procedural choices from TS 38.213 and 38.214, Stars 31 and 32, and produces the baseband samples that the RF of Stars 25 and 26 transmits.

The Knowledge Structure Map divides the document into its five regions. The mechanism diagram traces the resource-mapping chain from coded bits to RF.

![[99 Attachments/5G/Knowledge Maps/STAR-29-TS-38.211-Knowledge Structure Map.png|STAR-29 system-position map]]

*Knowledge map: TS 38.211 — physical channels and physical signals by direction.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-29-TS-38.211-Resource-Mapping-Chain.png|TS 38.211 resource-mapping chain from coded bits to RF transmission]]

*Mechanism: TS 38.211 resource mapping chain, coded bits to radio waveform.*

*Both diagrams are original teaching figures drawn for this course.*

> [!note] Searchable structure
> Resource coordinates (clause 4) → reusable signal functions (clause 5) → uplink mappings (clause 6) → downlink mappings (clause 7) → sidelink mappings (clause 8) → receiver inversion.

The phone and the base station each run a transmit and a receive physical layer. From above, MAC provides transport-channel data and control context; TS 38.212 turns information bits into coded, rate-matched sequences; TS 38.213 and 38.214 determine monitored resources, allocation interpretation, and modulation-and-coding operation. TS 38.211 then maps bits to constellation symbols, maps symbols and reference signals to resources, and generates a waveform; reception reverses the path. The document contains antenna ports rather than physical connectors because a port is a signal-model abstraction, a promise that symbols on the same port experience the same channel, and precoding and implementation decide how ports map to elements. 

## 3. Specification-guided walkthrough

Section 2 placed the board. The walkthrough below follows the specification's own order: time units, the grid, antenna ports, then the difference between a channel and a signal.

### 3.1 Numerology and nested time units

The walk starts with time. NR keeps LTE's 15 kHz spacing as a reference and scales it; this section shows how the symbol, the slot and the frame follow from that one choice.

NR scales subcarrier spacing from a 15 kHz reference:

$$
\Delta f=15\cdot2^{\mu}\ \text{kHz}.
$$

Here $\Delta f$ is the subcarrier spacing and $\mu$ the numerology index. The useful symbol time is the reciprocal,

$$
T_u=\frac{1}{\Delta f},
$$

before the cyclic prefix is added. A 10 ms frame holds ten 1 ms subframes; with normal cyclic prefix a slot holds 14 symbols and a subframe holds $2^{\mu}$ slots. Clauses 4.2 and 4.3 define the supported configurations and timing constants. The trade-off is physical: a larger spacing gives shorter symbols that tolerate more frequency error and Doppler but less delay spread, so numerology follows channel conditions, frequency range, and deployment rather than a service label.

> [!spec] 3GPP reality check
> The numerologies and the frame, subframe, slot, and symbol structure are [TS 38.211 V18.9.0, clauses 4.2 and 4.3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf); the configured value is the subcarrier spacing in TS 38.331's SCS-SpecificCarrier.

### 3.2 Resource grid, RE, RB, and common RB

Section 3.1 fixed time. This section fixes frequency: subcarriers, resource elements, resource blocks and the common grid they sit on.

For an antenna port and a subcarrier spacing the grid is indexed by subcarrier $k$ and symbol $l$, and one coordinate $(k,l)$ is a resource element. Twelve consecutive subcarriers form a resource block:

$$
N_{sc}^{RB}=12.
$$

A physical resource block is indexed within a bandwidth part. A common resource-block grid supplies a carrier-level reference so that configurations with different bandwidth parts describe positions consistently, anchored at Point A. Clauses 4.4.2 to 4.4.5 are definitive.

External source: [TS 38.211 V18.9.0, clause 4.4.2, PDF page 14](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: 3GPP TS 38.211 V18.9.0, clause 4.4.2, PDF p. 14, [official PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf), accessed 2026-08-04.*

External source: [Resource-grid definition overview](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html). The reproduced image is omitted from this distribution.

*Source excerpt: ShareTechnote, [5G/NR Resource Grid](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html), resource-grid definition overview, accessed 2026-08-04.*

!note["RB" is overloaded: here it is a resource block, in protocol discussion a radio bearer. The controlled vocabulary writes `RB (PHY)` and `RB (bearer)`.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [resource-grid page](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html) draws the grid at several numerologies side by side, which is the fastest way to see the square change size while the block and slot counts stay fixed.

### 3.3 Antenna ports and quasi co-location

The grid has coordinates; this section adds the promise that lets a receiver interpret them: the antenna port.

!important[An antenna port identifies a referenceable channel experience: if a data channel and its demodulation reference signal share the intended port, the receiver estimates the effective channel from the reference symbols and demodulates the data. Quasi co-location extends the idea, letting selected large-scale properties be inferred between signals or ports according to a configured type. TS 38.211 defines the port and signal mapping; the procedural interpretation is in TS 38.214 and the RRC configuration.]

### 3.4 Physical channel versus physical signal

With coordinates and ports defined, the last foundation separates what carries payload from what supports reception.

!important[A physical channel carries information from a transport or control payload: PDSCH, PUSCH, PDCCH, PUCCH, PBCH, and PRACH. A physical signal supports acquisition, measurement, estimation, tracking, or sounding without being the payload: PSS, SSS, DM-RS, CSI-RS, PT-RS, and SRS. PRACH is called a channel but carries a preamble rather than a coded transport block; the vocabulary follows the specification.]

## 4. Mechanism and derivation

Section 3 gave the vocabulary. Section 4 walks the clauses that use it.

### 4.1 Clause 5: generic functions

The walk starts with clause 5, the generic functions every channel shares.

Clause 5 begins with modulation mapping: bit groups become constellation points. For QPSK the normalised mapping is

$$
d(i)=\frac{1}{\sqrt{2}}\left[(1-2b_{2i})+j(1-2b_{2i+1})\right],
$$

where $b_{2i}$ and $b_{2i+1}$ are coded bits and $d(i)$ has unit average energy. Clause 5.1 gives the exact mappings, now up to 1024QAM. Clause 5.2 defines the pseudo-random and low-PAPR sequences. Clause 5.3 defines OFDM baseband generation, with transform precoding for PUSCH in clause 6.3.1.4. A simplified symbol for port $p$ is

$$
s_l^{(p)}(t)=\sum_k a_{k,l}^{(p)}
e^{j2\pi(k+k_0)\Delta f(t-N_{CP,l}T_s)},
$$

over the useful interval after the cyclic-prefix shift, where $a_{k,l}^{(p)}$ is the value on subcarrier $k$ and symbol $l$, $k_0$ the frequency placement, $N_{CP,l}$ the prefix length, and $T_s$ the time unit. The expression shows the IFFT logic; exact scaling, timing, phase, and frequency location are in clause 5.3.

> [!spec] 3GPP reality check
> Modulation mapping is [TS 38.211 V18.9.0, clause 5.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf), the sequences clause 5.2, and OFDM generation clause 5.3; the 1024QAM constellation is a Release 17 addition an older summary may lack.

### 4.2 Clause 6: uplink channels and signals

Section 4.1 covered the shared functions. This section reads clause 6, the uplink.

Clause 6.3 defines the uplink channels: PUSCH carries shared-channel data and possibly multiplexed control, with CP-OFDM or transform-precoded DFT-s-OFDM; PUCCH carries feedback, scheduling requests, and channel-state reports in several formats; PRACH carries preambles for detection and timing. Clause 6.4 defines the uplink reference signals: demodulation signals for PUSCH and PUCCH, phase tracking where configured, and sounding for scheduling, beams, reciprocity, and positioning. The three channels pose three receiver problems: sequence detection and timing before any scheduling for PRACH, reliable recovery of a small critical payload for PUCCH, and efficient transport of a large block, possibly with layers and multiplexed control, for PUSCH. Transform precoding spreads a block of symbols with a DFT before subcarrier mapping, keeping frequency-domain equalisation while giving a single-carrier-like envelope that helps the power amplifier; it is not a different air interface and does not remove the cyclic prefix. For coded bits go to TS 38.212; for the resources a grant selected, to TS 38.213 and 38.214; for the mapping of the symbols and pilots, stay in clause 6.

### 4.3 Clause 7: downlink channels and signals

Section 4.2 covered the uplink. This section reads clause 7, the downlink.

Clause 7.3 defines the downlink channels: PDSCH for shared-channel data and higher-layer signalling, PDCCH for control information mapped through resource-element groups and control-channel elements inside a control resource set, and PBCH for the master information block inside the synchronisation block. Clause 7.4 defines the downlink signals: PDSCH and PDCCH demodulation signals, CSI-RS for measurement, tracking, and beams, PT-RS for common phase error, and PSS and SSS for cell detection and identity, with the block's mapping in clause 7.4.3. PBCH is a channel; the SS/PBCH block is a compound structure containing it, and a beam sweep transmits several block indices without creating several cells. The reference signals are purpose-specific: DM-RS follows a scheduled channel and estimates the precoded channel of that transmission; CSI-RS can be configured for broader purposes and need not coincide with data; PT-RS is sparse. "Pilot" alone is too imprecise for configuration or debugging. A rectangular allocation does not mean every enclosed element carries the same channel: a control resource set bounds possible control resources while the element-group mapping, control demodulation signals, candidate selection, and rate matching decide actual occupancy.

> [!spec] 3GPP reality check
> The control-channel geometry, resource-element groups and control-channel elements, is TS 38.211 clause 7.3.2; the synchronisation block's four symbols and 240 subcarriers are clause 7.4.3; the demodulation reference-signal positions that a configured value selects are clause 7.4.1.1.

### 4.4 Clause 8: sidelink

Sections 4.2 and 4.3 covered the two directions between phone and base station. This section reads clause 8, where the same grammar serves phone to phone.

Clause 8 applies the grammar to direct device-to-device transmission, defining the sidelink channels and signals with their mapping and reference structures, while resource selection and control remain in the companion procedures. A student who reads only the uplink and downlink clauses misses how NR reuses its primitives beyond the phone-to-base-station link.

### 4.5 Receiver inversion

The walk ends where the specification stops: at the receiver, which the document never mandates.

A receiver obtains synchronisation and sampling and frequency alignment, removes the cyclic prefix, transforms to the frequency domain, selects the elements of a channel and its reference signals, estimates and equalises the effective channel, demaps constellation symbols to likelihoods, and hands soft information to TS 38.212 decoding:

$$
r(t)\rightarrow Y[k,l]\rightarrow\widehat{H}[k,l]\rightarrow
\widehat{d}[i]\rightarrow LLR\rightarrow\text{channel decoder}.
$$

Here $r(t)$ is the received waveform, $Y[k,l]$ the received grid, $\widehat{H}[k,l]$ the channel estimate, $\widehat{d}[i]$ the equalised observations, and $LLR$ the soft bits. TS 38.211 defines the transmitted structures that make these operations possible; it mandates no receiver algorithm.

## 5. Worked example

Section 4 walked the clauses. Section 5 counts the resource elements of one allocation, a calculation you can redo by hand.

Assume a PDSCH allocation spans $N_{PRB}=50$ PRBs, $N_{sym}=12$ OFDM symbols, and one layer. The allocation contains

$$
N_{RE,total}=N_{PRB}\cdot12\cdot N_{sym}.
$$

Here, $N_{RE,total}$ is the total grid-element count, $N_{PRB}$ is the allocation width in physical resource blocks, 12 is subcarriers per PRB, and $N_{sym}$ is the allocation duration in OFDM symbols.

Substitution gives

$$
N_{RE,total}=50\cdot12\cdot12=7200\ \text{RE}.
$$

Assume, only for this exercise, that DM-RS and other reserved resources consume $N_{RE,overhead}=600$ RE. The remaining data-mapped elements are

$$
N_{RE,data}=7200-600=6600\ \text{RE}.
$$

Here, $N_{RE,data}$ is the remaining data-mapped element count and $N_{RE,overhead}=600$ is the exercise assumption for reference and reserved elements.

With 64QAM, the modulation order is $Q_m=6$ coded bits per constellation symbol. The number of rate-matched coded bits that can be mapped in this simplified single-layer allocation is

$$
G=N_{RE,data}\cdot Q_m\cdot \nu,
$$

Here, $G$ is the coded-bit mapping capacity, $N_{RE,data}$ is the data-mapped RE count, $Q_m$ is coded bits per modulation symbol, and $\nu$ is the number of spatial layers.

where $\nu=1$ is the number of layers in the example. Therefore

$$
G=6600\cdot6\cdot1=39{,}600\ \text{coded bits}.
$$

This is not the user-data transport-block size. A scheduler selects the applicable MCS and allocation; TS 38.214 defines how those scheduled inputs are interpreted and how transport-block size is determined; TS 38.212 performs coding and rate matching to $G$; TS 38.211 maps the resulting modulation symbols. CRCs, code-block segmentation, code rate, resource exclusions, xOverhead, multiple layers, and exact DM-RS configuration must all be applied before a throughput claim is valid.

Now add timing. At $\mu=1$, nominal slot duration is

$$
T_{slot}=\frac{1\ \text{ms}}{2}=0.5\ \text{ms}.
$$

If this allocation occurs once in a slot, the tempting raw mapped-bit rate is

$$
R_{mapped}=\frac{39{,}600}{0.5\ \text{ms}}=79.2\ \text{Mbit/s}.
$$

Here, $R_{mapped}$ is the illustrative mapped coded-bit rate, 39,600 bits is the calculated mapping capacity, and 0.5 ms is the assumed once-per-slot interval.

That number counts mapped coded bits under stated assumptions. It is not application throughput and should be labeled exactly as such. The exercise demonstrates the specification chain: geometry from TS 38.211, coding capacity $G$ passed to TS 38.212, and transport-block interpretation from TS 38.214.

## 6. The 3GPP protocol: which document, and what it says

The example counted elements. This section names what each clause fixes and draws the equations they state.

Clause 4 is the coordinates, clause 5 the arithmetic, clauses 6 to 8 the pieces. The figure draws the subcarrier-spacing rule and the slot structure, the resource element and block and Point A, the QPSK mapping, the OFDM symbol expression with transform precoding beside it, and the control and synchronisation-block geometry, and sets each beside the line of a cell's configuration that fixes it.

![[99 Attachments/5G/Protocol Figures/STAR-29-TS-38.211-Protocol.png|The coordinate system, the modulation and waveform arithmetic, and the channel and signal geometry of TS 38.211, with the configuration lines each becomes]]

*Protocol figure: The coordinate system, the modulation and waveform arithmetic, and the channel and signal geometry of TS 38.211, with the configuration lines each becomes.*

| Clause | Official content | Typical companion source | Reader question |
| --- | --- | --- | --- |
| 4.2–4.3 | numerologies, frames, subframes, slots, symbols | TS 38.213 and 38.214 procedures | what is the time-frequency clock? |
| 4.4 | antenna ports, grids, REs, RBs, BWPs, Point A | TS 38.331 configuration | where can something be mapped? |
| 5.1–5.3 | modulation, sequence generation, OFDM generation | TS 38.212 coded inputs | how do bits become complex baseband? |
| 6.3–6.4 | uplink channels, transform precoding, reference signals | TS 38.213 and 38.214 clauses 6 and 8–9 | what does the UE transmit? |
| 7.3–7.4 | downlink channels, reference and synchronisation signals | TS 38.213 and 38.214 clauses 5, 10, 13 | what does the gNB transmit? |
| 8 | sidelink channels and signals | sidelink procedure specifications | what is transmitted between UEs? |

!note[**When you build or run a demo.** A software base station's cell configuration is clause 4 in a handful of lines: the subcarrier spacing, which fixes the square and the slot count per frame; the carrier's frequency and bandwidth in resource blocks, which fix the board and Point A; and the initial bandwidth part as a rectangle on it. The demodulation reference-signal position and additional positions are clause 7.4.1.1 as two lines. When a phone fails to decode, the physical-layer log prints allocations as squares, a slot, a symbol range, a block range, layers, and a modulation, and comparing those against the configured grid is the first check. The waveform itself is never configured; it follows from the grid.]

Release 15 established the coordinate system, the CP-OFDM and DFT-s-OFDM choices, the primary channels, and the reference-signal framework. Release 16 and later releases added feature-specific mappings and options; 1024QAM in clause 5.1 is one concrete difference from a textbook-era overview. The right comparison method is clause diffing against the frozen archive and [[Protocol/Rel-18/spec-manifest.yml|spec-manifest.yml]], whose hash proves the exact input. Release context is on the official [3GPP Release 18 page](https://www.3gpp.org/specifications-technologies/releases/release-18).

## 7. ShareTechnote engineering intuition

The specification states rules; the engineering pages show them on a screen.

ShareTechnote's [resource-grid](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html) page moves the reader among subcarrier, symbol, element, and block; the [frame-structure](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html) and [numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html) pages show the hierarchy scaling with $\mu$; the [antenna-port](https://www.sharetechnote.com/html/5G/5G_AntennaPorts.html) page gives implementation intuition for the promise a port makes; and [PBCH decoding](https://www.sharetechnote.com/html/5G/5G_PBCH_Decoding.html) is a receiver checklist for the first block a phone ever reads. Use them to form the questions, which grid, which port, which reference signal, which mapping, and answer them in the fixed clause. The handling record is ShareTechnote 5G Topic Crosswalk.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

For U03–U05, focus on clauses 4–5: numerology, frames, resource grids, modulation, and OFDM. For U06–U08, focus on antenna ports and reference signals supporting sounding, MIMO, and beam management. For U09–U10, use PSS, SSS, PBCH/SSB, and PRACH to connect acquisition with access. For U11–U14, use PDCCH/PUCCH/PDSCH/PUSCH mapping while companion notes explain coding, control, and HARQ.

Students should not read TS 38.211 linearly on the first pass. Begin with the clause map, follow one channel end-to-end across companion specifications, then return for exact mapping details. Course Alignment holds the course-wide mapping; the existing notebooks remain private and unchanged.

## 9. Common confusions

The six sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “TS 38.211 is the whole PHY”

!warning[It is the channels/modulation and resource-mapping core. Coding, procedures, and measurements are separate specifications.]

### 9.2 “A PRB always contains 168 usable data REs”

!warning[Twelve subcarriers times fourteen symbols gives 168 grid coordinates for a normal-CP full slot, but reference signals, control, reserved resources, and allocation duration reduce data REs. A PRB definition is frequency-domain; usable data depends on mapping.]

### 9.3 “An antenna port is a physical antenna”

!warning[It is a logical reference for a channel experience. Precoding and implementation map ports to array elements.]

### 9.4 “SSB and PBCH are the same”

!warning[PBCH is one physical channel inside the larger SS/PBCH block. PSS, SSS, and PBCH DM-RS also occupy that block.]

### 9.5 “Numerology alone determines latency”

!warning[Numerology sets symbol and slot scale. Scheduling, processing, retransmission, transport, and application behavior determine service latency.]

### 9.6 “Resource mapping determines the transport-block size”

!warning[Mapping yields available coded-bit positions. TS 38.214 and TS 38.212 determine transport-block sizing and coding before TS 38.211 maps symbols.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.211 V18.9.0: NR; Physical Channels and Modulation*, clauses 4–8, [official PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf).
2. 3GPP, *TS 38.212 V18.8.0: NR; Multiplexing and Channel Coding*, clauses 5–7, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
3. 3GPP, *TS 38.213 V18.8.0: NR; Physical Layer Procedures for Control*, core clauses 4–13 and feature-specific clauses 14–22, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
4. 3GPP, *TS 38.214 V18.10.0: NR; Physical Layer Procedures for Data*, clauses 5–6, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
5. [[5G NR 2e Source Manifest|E. Dahlman, S. Parkvall, and J. Sköld, 5G NR: The Next Generation Wireless Access Technology, 2nd ed., Chapters 7–10, Elsevier, 2021; DOI/page manifest]].
6. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18), accessed 2026-08-03.
7. ShareTechnote, [Resource Grid](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html), [Frame Structure](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html), [Numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html), [Antenna Ports](https://www.sharetechnote.com/html/5G/5G_AntennaPorts.html), and [PBCH Decoding](https://www.sharetechnote.com/html/5G/5G_PBCH_Decoding.html), accessed 2026-08-03.
8. Clause map of this knowledge base for TS 38.211 V18.9.0, generated 2026-08-03 from the official document.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | Primary clause |
| --- | --- | --- |
| BWP | Bandwidth part | TS 38.211 V18.9.0, clause 4.4.5 |
| CSI-RS | Channel state information reference signal | TS 38.211 V18.9.0, clause 7.4.1.5 |
| DFT-s-OFDM | Discrete Fourier transform spread OFDM | TS 38.211 V18.9.0, clause 6.3.1.4 |
| DM-RS | Demodulation reference signal | TS 38.211 V18.9.0, clauses 6.4.1 and 7.4.1 |
| OFDM | Orthogonal frequency-division multiplexing | TS 38.211 V18.9.0, clauses 4.2 and 5.3 |
| PBCH | Physical broadcast channel | TS 38.211 V18.9.0, clause 7.3.3 |
| PDCCH | Physical downlink control channel | TS 38.211 V18.9.0, clause 7.3.2 |
| PDSCH | Physical downlink shared channel | TS 38.211 V18.9.0, clause 7.3.1 |
| PRACH | Physical random access channel | TS 38.211 V18.9.0, clause 6.3.3 |
| PRB | Physical resource block | TS 38.211 V18.9.0, clause 4.4.4.1 |
| PUCCH | Physical uplink control channel | TS 38.211 V18.9.0, clause 6.3.2 |
| PUSCH | Physical uplink shared channel | TS 38.211 V18.9.0, clause 6.3.1 |
| RE | Resource element | TS 38.211 V18.9.0, clause 4.4.2 |
| SSB | Synchronization signal and PBCH block | TS 38.211 V18.9.0, clause 7.4.3 |

Controlled two-sentence explanations are in [[5G Abbreviation Database]].

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $\Delta f$ | Subcarrier spacing | Hz or kHz |
| $\mu$ | Numerology index | configured non-negative integer |
| $T_u$ | Useful OFDM symbol duration | seconds |
| $N_{sc}^{RB}$ | Subcarriers per resource block | 12 |
| $k$, $l$ | Subcarrier and OFDM-symbol indices | integers |
| $p$ | Antenna-port index | integer |
| $a_{k,l}^{(p)}$ | Complex resource-grid value | normalized complex amplitude |
| $N_{CP,l}$ | Cyclic-prefix length for symbol $l$ | samples |
| $T_s$ | Reference time unit in the pedagogical waveform | seconds |
| $b_i$ | Coded bit at index $i$ | 0 or 1 |
| $d(i)$ | Modulation symbol | complex amplitude |
| $N_{PRB}$ | Number of allocated physical resource blocks | count |
| $N_{sym}$ | Number of allocated OFDM symbols | count |
| $N_{RE,total}$ | Total grid REs in the exercise allocation | count |
| $N_{RE,overhead}$ | Assumed reference/reserved REs | count |
| $N_{RE,data}$ | Remaining data-mapped REs | count |
| $Q_m$ | Modulation order in coded bits per symbol | bits/symbol |
| $\nu$ | Number of spatial layers | count |
| $G$ | Rate-matched coded-bit mapping capacity | bits |
| $R_{mapped}$ | Raw mapped coded-bit rate in the exercise | bits/s |
