---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 16
title: Cell Search and System Information
language: en
course_units:
- U09
- U10
release_baseline: 18
---

# STAR-16 — Cell Search and System Information

## 1. What this is, and why it exists

A phone that has just been switched on knows nothing: neither the timing, nor the cell's name, nor which beam it is in, nor where the control channel is, nor even how wide the carrier is. Every later procedure assumes those facts. So the cell behaves like a lighthouse: it flashes a short, fixed pattern every twenty milliseconds, and each part of the flash answers one question and tells the phone where to look for the next.

![[99 Attachments/5G/Concept Figures/STAR-16-Cell-Search-and-System-Information-Concept.png|Cell search explained as a lighthouse flash that tells a phone everything in order]]

*Concept figure: Cell search explained as a lighthouse flash that tells a phone everything in order.*

The phone does not scan every frequency; it scans a sparse shortlist, the synchronisation raster, where a flash is allowed to be. The first part of the flash, the primary synchronisation signal, is one of three patterns; catching it sets the phone's symbol clock and gives one third of the cell's name. The second part, the secondary signal, is one of 336 patterns; with the first it spells one of 1008 cell identities and marks the frame edge. Pinned to the flash is a short note, the master information block: 32 bits saying which of up to 64 flashes this was, the frame number, and where the cell's noticeboard is. That noticeboard, control resource set zero, is where the phone reads the first system information block, which finally tells it the bandwidth, the random-access rules, and how to reach everything else.

Why a flash and a note rather than one big announcement? Because a phone that knows nothing can only find something small, fixed, and regular. The flash is four symbols by 240 subcarriers, always the same shape, so it can be found by correlation with no configuration at all. Everything that varies between cells is pushed one step later, where the phone already has a clock and a name. Above 6 GHz the lighthouse turns: up to 64 flashes in five milliseconds, one per beam, and the note says which one was caught. The key fact to carry is that the phone cannot ask for anything until the last step. Everything before is listening.

**The question this chapter answers.** With no timing, cell identity, beam, control-channel configuration, or system bandwidth known, what sequence lets a UE find a cell and decode SIB1?

!important[**The short answer.** The UE searches candidate synchronization-raster frequencies and SSB time positions. It detects PSS to obtain the three-valued $N_{ID}^{(2)}$ and coarse timing, then SSS to obtain the 336-valued $N_{ID}^{(1)}$ and frame timing. Together they form the physical cell identity $N_{ID}^{cell}=3N_{ID}^{(1)}+N_{ID}^{(2)}$, one of 1008. The UE then decodes the PBCH for the MIB, which locates CORESET 0, where the PDCCH scheduling SIB1 is found.]

Names you will meet in this note: synchronisation signal block (SSB), primary and secondary synchronisation signal (PSS, SSS), physical broadcast channel (PBCH), master information block (MIB), system information block (SIB), control resource set (CORESET), remaining minimum system information (RMSI), physical cell identity (PCI), common resource block (CRB), global synchronisation channel number (GSCN), system-information RNTI (SI-RNTI).

## 2. Where you are in 5G

Section 1 described a phone that knows nothing at switch-on. The map below shows where cell search sits in 5G: the very first box a phone passes, before control channels, before random access, before data.

![[99 Attachments/5G/Locator Maps/STAR-16-Where-You-Are-in-5G.png|Where Star 16 sits in the whole 5G system]]

*Locator: Where Star 16 sits in the whole 5G system.*

This chapter lights the start of the procedures band: initial access. It is the first thing a phone does on the physical layer of Star 07, using the reference-signal ideas of Star 08 and the polar-coded broadcast channel of Star 09. It hands the phone to random access in Star 17 holding a timing reference, a cell identity, and the configuration to transmit. The beam sweep it describes is the same one Star 12 later refines.

The Knowledge Structure Map draws the chain from synchronisation to configuration. The mechanism diagram traces one phone from detecting nothing to reading SIB1.

![[99 Attachments/5G/Knowledge Maps/STAR-16-Cell-Search-and-System-Information-Knowledge Structure Map.png|STAR-16 system-position map]]

*Knowledge map: What a device knows at each stage of cell acquisition.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-16-Cell-Search-to-System-Information.png|Star 16 mechanism and handoff diagram]]

*Mechanism: The synchronisation signal block, drawn on the resource grid.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 16.1 The SS Block → 16.2 SS Burst Set – Multiple SS Blocks in the Time Domain → 16.3 Details of PSS, SSS, and PBCH → 16.4 Providing Remaining System Information → Unified Logical Sequence for Initial Access.


## 3. The textbook road

Section 2 placed cell search at the entrance. The road below walks through the chapter in the book's order: the synchronisation block, the burst set that sweeps it, its three signals in detail, the remaining system information, then the whole sequence in one table.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Book, 3GPP, and ShareTechnote callouts are additions; the source note itself remains read-only.*

### 3.1 **16.1 The SS Block**

The road begins with the thing a phone looks for first: the synchronisation block and the three signals inside it.

!important[The synchronisation signal block is the foundation of NR cell detection. It carries the primary synchronisation signal, the secondary synchronisation signal, and the physical broadcast channel. Together they let a phone detect a cell, acquire timing and frequency, and read the master information block.]

#### 3.1.1 **16.1.1 Basic Structure**

Figure 16.1 shows the block: four OFDM symbols by 240 subcarriers, with the PSS in the first symbol, the SSS in the third, and the PBCH across the second and fourth, plus its own demodulation reference signals for coherent reception.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 16.1 shows the block: four OFDM symbols by 240 subcarriers, with the PSS in the first symbol, the SSS in the third, and the PBCH across the second and fourth, plus its own demodulation reference signals for coherent reception.*

Different numerologies can carry the block, but to spare phones from searching several at once, most bands define a single one, as Table 16.1 shows.

| Numerology | Bandwidth | Duration | Frequency range |
| --- | --- | --- | --- |
| 15 kHz | 3.6 MHz | 285 µs | FR1 (below 3 GHz) |
| 30 kHz | 7.2 MHz | 143 µs | FR1 |
| 120 kHz | 28.8 MHz | 36 µs | FR2 |
| 240 kHz | 57.6 MHz | 18 µs | FR2 |

The short block durations of the high numerologies are what allow rapid beam sweeping at millimetre-wave frequencies. The 60 kHz numerology cannot carry the block in any range.

#### 3.1.2 **16.1.2 Frequency-Domain Position**

!note[In LTE the synchronisation signals always sat at the carrier centre. NR allows the block to be placed flexibly, to speed up cell search, and reduces the search to a sparse synchronisation raster of candidate frequencies. Since the block may then not align with the common resource block grid, the phone needs two more facts: the PBCH signals the offset between the block and the grid, and SIB1 later gives the absolute carrier location.]

> Why is the CRB grid offset needed?
> [!important] 💡
> The CRB offset tells the UE how the **SSB frequency location** maps to the **carrier's resource grid**, which is what lets it locate **CORESET 0 and SIB1** in frequency. The SSB's own grid, used for synchronisation and PBCH, can be shifted relative to the PDSCH/PDCCH grid used for data and control; the offset aligns the synchronisation reference with the carrier's operational bandwidth. Without it, the UE could not tune to the region where SIB1 is broadcast.

#### 3.1.3 **16.1.3 SS-Block Periodicity**

The block repeats with a period between 5 and 160 milliseconds, typically 20 for initial search. A longer period saves the network's always-on energy but makes a phone dwell longer on each frequency before concluding nothing is there; the sparse raster compensates by reducing how many frequencies must be tried. A shorter period speeds cell search for connected phones. A phone doing initial search may assume a block at least every 20 milliseconds; a carrier with a longer period will not be found by initial access but can still serve connected phones, for instance as a secondary carrier in carrier aggregation.

> [!book] Book expansion
> Chapter 16 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 335–347, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7)) makes the block's fixed shape the whole argument: every design freedom, in frequency position, in period, in beam count, is paid for by something signalled one step later.

> [!spec] 3GPP reality check
> The block's structure and the mapping of its three signals are [TS 38.211 V18.9.0, clause 7.4.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); its allowed time positions and periods are TS 38.213 clause 4.1; the synchronisation raster is TS 38.104 clause 5.4.3.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [SS block page](https://www.sharetechnote.com/html/5G/5G_SS_Block.html) draws the block on a resource grid and lists the raster points per band, which is what an engineer needs to set the block's frequency in a configuration.

### 3.2 **16.2 SS Burst Set – Multiple SS Blocks in the Time Domain**

Section 3.1 described one block. A directional cell needs several, one per beam; this section groups them into a burst set and explains sweeping.

An SS burst set groups several blocks in time, each potentially on a different beam, as Figure 16.2 shows. That is beam sweeping, and it is how a directional cell stays discoverable from every direction.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*An SS burst set groups several blocks in time, each potentially on a different beam, as Figure 16.2 shows.*

A burst set occupies five milliseconds, in the first or second half of a frame. The number of blocks depends on frequency: up to four below 3 GHz, eight between 3 and 6 GHz, and 64 above 24 GHz. Each block carries a time index so the phone knows which beam and position it caught. Figure 16.3 shows the candidate positions for the 15 kHz numerology; the first and last two symbols of each slot are left free so that connected phones keep their downlink and uplink control. Not every position need be used; any subset can carry actual blocks.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 16.3 shows the candidate positions for the 15 kHz numerology; the first and last two symbols of each slot are left free so that connected phones keep their downlink and uplink control.*

> Role of PBCH scrambling patterns
> [!important] 💡
> Eight different **scrambling patterns** are applied to the **PBCH** to indicate implicitly **which SSB (time index)** was received. From it the UE infers the **SSB's position** within the burst set and the **frame timing reference** (with the half-frame bit), which is what lets it align in time and associate with the right **random-access occasions**.

> [!spec] 3GPP reality check
> The candidate positions per numerology, cases A to E, and the maximum count per band are [TS 38.213 V18.8.0, clause 4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); which positions are actually used is signalled in SIB1 by ssb-PositionsInBurst.

### 3.3 **16.3 Details of PSS, SSS, and PBCH**

Sections 3.1 and 3.2 described the block's shape and timing. This section opens it up: how each of the three signals is built and what the phone gets from it.

#### 3.3.1 **16.3.1 Primary Synchronization Signal (PSS)**

The PSS enables initial detection and frequency synchronisation. It is one of three m-sequences, cyclic shifts of one base sequence of length 127. Detecting it narrows the physical cell identity to one of three groups and sets the symbol timing.

#### 3.3.2 **16.3.2 Secondary Synchronization Signal (SSS)**

The SSS supplies the rest of the identity. It is built from two m-sequences with shifts, giving 336 distinct signals for each PSS, and 1008 identities in all. Its detection yields the full identity, the frame timing, and a check on the PSS decision.

#### 3.3.3 **16.3.3 Physical Broadcast Channel (PBCH)**

The PBCH carries the master information block and a few extra bits. It is rate-matched over 576 resource elements and sent twice within a block. Table 16.2 lists its contents.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Table 16.2 lists its contents.*

The block's time index reaches the phone in two parts: an implicit part in the PBCH scrambling and an explicit part in the payload.

> Meaning of MIB repetition over 80 ms
> [!important] 💡
> The MIB is constant over **80 ms = 8 frames**, so all SSBs across those frames carry the **same MIB**. The burst effectively repeats every eight frames, letting a late-arriving UE decode the same configuration reliably.

> [!spec] 3GPP reality check
> The PSS and SSS sequences are [TS 38.211 V18.9.0, clauses 7.4.2.2 and 7.4.2.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); PBCH mapping and scrambling are clause 7.3.3; the polar coding of the 32-bit payload is TS 38.212 clause 7.1; the MIB fields are TS 38.331 clause 6.2.2.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [cell-search page](https://www.sharetechnote.com/html/5G/5G_CellSearch.html) walks a real capture from PSS correlation peak to decoded MIB, showing the numbers a demo's log prints at each step.

### 3.4 **16.4 Providing Remaining System Information**

The block delivers the MIB and nothing more. This section explains where the rest of the system information comes from and why it is split this way.

!important[System information is split between the MIB on the broadcast channel, which holds only what is needed to find the next stage, and the system information blocks, which hold the detailed configuration.]

#### 3.4.1 **SIB1 – Remaining Minimum System Information (RMSI)**

SIB1 carries the random-access parameters, the scheduling of the other blocks, the system bandwidth and CORESET 0 configuration, and the initial downlink bandwidth part. It is sent on the shared channel, scheduled by a control message addressed with the system-information identifier inside CORESET 0, which the MIB located. Figure 16.6 shows how the block, CORESET 0, and the SIB1 transmission are multiplexed; CORESET 0 sits at a position relative to the detected block under one of three patterns, pattern 1 for FR1 and patterns 2 and 3 for FR2.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 16.6 shows how the block, CORESET 0, and the SIB1 transmission are multiplexed; CORESET 0 sits at a position relative to the detected block under one of three patterns, pattern 1 for FR1 and patterns 2 and 3 for FR2.*

> [!spec] 3GPP reality check
> The tables that turn the MIB's 8-bit pdcch-ConfigSIB1 into a CORESET 0 size, offset, and monitoring occasions are [TS 38.213 V18.8.0, clause 13](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); the SIB1 content is TS 38.331 clause 6.2.2 and the acquisition procedure clause 5.2.

### 3.5 **Unified Logical Sequence for Initial Access**

The road ends with the whole entrance in one table: block, broadcast channel, MIB, CORESET 0 and SIB1, in the order a phone meets them.

The table below gives the logical and procedural chain a phone follows during initial access, and the relationship among the block, the broadcast channel, the MIB, CORESET 0, and SIB1.

| Stage | Physical / logical channel | Purpose |
| --- | --- | --- |
| 1. SSB (PSS + SSS + PBCH) | physical signals | detect the cell; obtain timing, frequency, and the cell identity |
| 2. PBCH decoding → MIB | PBCH carrying the BCH | SIB1 numerology, CORESET 0 configuration, CRB offset, frame timing |
| 3. CORESET 0 monitoring | PDCCH within CORESET 0 | search for SIB1 scheduling with the SI-RNTI |
| 4. SIB1 reception | PDSCH carrying the DL-SCH | full configuration: random access, bandwidth part, SIB scheduling |
| 5. Other SIBs | DL-SCH | on demand or periodically, depending on state |

The chain SSB → PBCH → MIB → CORESET 0 → SIB1 is a hierarchical discovery. The logical channels involved are the BCH for the MIB and the DL-SCH for SIB1 and the rest. Keeping the always-on part small conserves energy while keeping access fast.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the three documents that define the signals, code the payload and say when blocks may be sent.

The three signals are TS 38.211: the PSS and SSS sequences, the block's shape, and the PBCH mapping. TS 38.212 codes the 32-bit broadcast payload. TS 38.213 says when blocks may be sent, how many per band, and, in its clause 13 tables, how eight bits of the MIB become a CORESET 0 location. TS 38.331 lists the fields of the MIB and SIB1. The figure draws the cell-identity formula, the PSS sequence, the block's fixed shape, the period and beam count, and the MIB bits that locate the noticeboard.

![[99 Attachments/5G/Protocol Figures/STAR-16-Cell-Search-and-System-Information-Protocol.png|The synchronisation signals, the broadcast block and the system-information chain, with their clauses and configured values]]

*Protocol figure: The synchronisation signals, the broadcast block and the system-information chain, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 7.3.3; 7.4.2.2; 7.4.2.3; 7.4.3.1 | PBCH, PSS, SSS, and PBCH DM-RS mapping |
| TS 38.212 | V18.8.0, [38212-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.1 | PBCH transport processing and coding |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4; 13 | cell-search-related timing and Type0-PDCCH CSS/CORESET0 |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 5.2; 6.2.2 | system-information procedure and MIB/SIB1 ASN.1 content |

!note[**When you build or run a demo.** The block's frequency is a single raster number, and a phone will never find a cell whose block is set off the raster; that is the first thing to check when a demo phone sees no network. The cell identity and the block period are two lines. The bitmap of burst positions says which beams are sent, and a single-antenna demo sends one. The eight-bit CORESET 0 configuration selects a table row in TS 38.213 clause 13, and a row that does not fit the carrier's bandwidth silently breaks SIB1. The phone-side log prints the six steps in order, from the PSS correlation peak to the decoded SIB1, and the step at which it stops tells you which of those lines is wrong.]

Release 15 defined the four-symbol block, the 1008 identities, the MIB bootstrap, and the CORESET 0 path, and they are unchanged. Later releases add cases for reduced-capability devices, positioning, and broadcast while keeping the same chain. Release 18 wording governs field presence and conditions; repetition does not make every MIB bit constant, and SIB1 does not contain what is needed to find itself. Release summaries are checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix the sequences; this trace takes two detected components and computes the cell identity from them, a calculation you can redo by hand.

Assume correlation detects PSS component $N_{ID}^{(2)}=2$ and SSS component $N_{ID}^{(1)}=217$. These are teaching detection outcomes within the standardized domains.

**What we are working out.** The physical cell identity.

$$
\begin{aligned}
N_{ID}^{cell}
&=3N_{ID}^{(1)}+N_{ID}^{(2)}\\
&=3(217)+2\\
&=651+2\\
&=653.
\end{aligned}
$$

In this formula, $N_{ID}^{(2)}$ is the PSS-derived component with possible values 0–2. $N_{ID}^{(1)}$ is the SSS-derived component with possible values 0–335. $N_{ID}^{cell}$ is the dimensionless integer PCI in the range 0–1007. The selected component values are pedagogical assumptions; the combination equation and domains are official physical-layer definitions. TS 38.211 clauses 7.4.2.2 and 7.4.2.3 are the reference plane.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $N_{ID}^{(2)}$ | 2 | integer, 0–2 | assumed detected PSS component |
| $N_{ID}^{(1)}$ | 217 | integer, 0–335 | assumed detected SSS component |
| $N_{ID}^{cell}$ | 653 | integer, 0–1007 | derived PCI |

The formula is bijective over the component ranges: dividing a PCI by three gives the group component and remainder. Yet PCI alone does not identify a globally unique cell; neighboring networks plan reuse, and other identifiers distinguish cells and networks at higher layers. A receiver also needs timing, frequency, and broadcast decoding, so a correct PCI is necessary but not sufficient for access.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star aligns with U09 and U10. U09 supplies synchronization sequences, timing/frequency acquisition, correlation, and channel estimation. U10 follows system information and random access. The clean handoff is the SIB1 RACH configuration: synchronization delivers a decodable control path, and system information turns it into an access procedure.

For a classroom dependency exercise, remove one item—SSS, PBCH DM-RS, MIB, SearchSpace0, or SI-RNTI—and ask which later step becomes impossible. This reveals why the bootstrap is ordered.

!warning[**“PSS reduces the search to three PCIs”.**

PSS supplies the three-valued $N_{ID}^{(2)}$ component. SSS supplies one of 336 $N_{ID}^{(1)}$ values. Their combination yields one of 1008 PCIs.]

!warning[**“PBCH is transmitted twice in the SSB”.**

PBCH resources span SSB symbols 1–3 with mapping exclusions. Repeated SSB occasions are separate broadcast opportunities.]

!warning[**“The MIB is constant for 80 ms”.**

Some information is stable over intervals, but SFN-related and timing context vary. State the repetition periodicity and field behavior separately rather than calling the entire payload constant.]

!warning[**“SIB1 tells the UE where CORESET0 is”.**

The UE must find SIB1 before it can decode it. MIB `pdcch-ConfigSIB1` and TS 38.213 tables bootstrap CORESET0/SearchSpace0; DCI then schedules SIB1 on PDSCH.]

!warning[**“PCI uniquely identifies the network cell”.**

PCI is a physical-layer identity reused across geography. PLMN and cell identities at higher layers, plus frequency and context, distinguish the network entity.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-16-Cell-Search-and-System-Information|Chapter 16]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_CellSearch.html)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_PBCH.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_Mib_Sib.html)
15. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Definitions and sources: [[5G Abbreviation Database]].

| Abbreviation | Full term |
| --- | --- |
| ASN.1 | Abstract Syntax Notation One |
| CORESET0 | Control resource set zero |
| CRC | Cyclic redundancy check |
| CSS | Common search space |
| DCI | Downlink control information |
| DM-RS | Demodulation reference signal |
| MIB | Master information block |
| OFDM | Orthogonal frequency-division multiplexing |
| PBCH | Physical broadcast channel |
| PCI | Physical cell identity |
| PDCCH | Physical downlink control channel |
| PDSCH | Physical downlink shared channel |
| PLMN | Public land mobile network |
| PSS | Primary synchronization signal |
| RACH | Random access channel |
| SFN | System frame number |
| SIB1 | System information block type 1 |
| SI-RNTI | System information RNTI |
| SSS | Secondary synchronization signal |
| SSB | Synchronization signal and PBCH block |
| UE | User equipment |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $N_{ID}^{(2)}$ | PSS-derived identity component | integer 0–2 |
| $N_{ID}^{(1)}$ | SSS-derived identity component | integer 0–335 |
| $N_{ID}^{cell}$ | physical cell identity | integer 0–1007 |
| $i_\mathrm{SSB}$ | SSB candidate index | integer |
| $f_\mathrm{raster}$ | synchronization-raster candidate frequency | Hz |
| $\Delta f$ | subcarrier spacing | Hz |
| $N_\mathrm{SC}^{SSB}$ | SSB occupied subcarriers | 240 |
| $N_\mathrm{sym}^{SSB}$ | SSB occupied OFDM symbols | 4 |
