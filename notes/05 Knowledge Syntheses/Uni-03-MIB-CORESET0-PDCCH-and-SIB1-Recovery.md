---
title: Uni-03 — Recovering MIB, CORESET0, PDCCH and SIB1
type: knowledge_synthesis
language: en
uni: 3
release_baseline: 18
lab_run: run-20260907-122809
cssclasses:
- research-note-tables
---

# Uni-03 — Recovering MIB, CORESET0, PDCCH and SIB1

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. Obtain the broadcast configuration needed for random access

**Stage — Textbook workflow.**

The overview above placed this receiver between cell search and random access. This section says what it must recover and why a decoded transport block is only half the job.

!important[A receiver that has found a cell still needs its uplink access configuration. This laboratory recovers the Master information block (MIB), derives the Control resource set (CORESET) zero and its monitoring occasions, finds a Physical downlink control channel (PDCCH) grant, then recovers and interprets System information block type 1 (SIB1). The verified output is a set of random access parameters decoded from actual message bytes.]

The system view places this broadcast receiver before the later access procedure.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 01 System Position v2.png]]

*Original schematic: the broadcast receiver sits between cell search, which supplied timing and the physical cell identity, and the random access procedure, which needs the PRACH configuration carried in SIB1. The experiment ends at that configuration handoff.*

The baseline uses a local New Radio (NR) teaching cell with Physical cell identity (PCI) 321, 30 kHz subcarrier spacing and Case C synchronization. Its 28 resource block capture contains one Synchronization signal and PBCH block (SSB) and a subsequent broadcast transmission. The recovered SIB1 describes a 51 resource block carrier; the capture observes only the lower region needed for this experiment. These are simulation settings.

The waveform test injected a 19 sample delay and 3400 Hz Carrier Frequency Offset (CFO), at 20 dB Signal-to-Noise Ratio (SNR) per occupied resource element. The receiver recovered the frame start at sample 19 and estimated 3253.073 Hz. The Downlink control information (DCI) and Downlink Shared Channel (DL-SCH) Cyclic redundancy check (CRC) results were both zero. All 528 transport bits matched the transmitter. Abstract Syntax Notation One (ASN.1) decoding recovered the same 50 byte SIB1 encoding. These values are program outputs in the saved [run summary](../10%20MATLAB%20Labs/uni03/results/run-20260907-122809/summary.json).

### 1.1 The result the learner must reproduce

Section 1 stated the goal; this section shows the command that reproduces the result and the two decoders it exercises.

Run the saved laboratory in MATLAB and inspect the decoded message. Successful physical decoding means that a transport block passed its CRC; the separate message decoder must identify BCCH-DL-SCH-Message, select SIB1 and recover the common radio fields.

```matlab
addpath('matlab/uni03');   % run from the publish folder root
report = run_uni03;
```

`run_uni03` writes a new directory rather than replacing this evidence run. The [laboratory README](../10%20MATLAB%20Labs/uni03/README.md) gives dependencies and the callable receiver interface.

## 2. Use the existing explanations and the correct specification

**Stage — 3GPP protocol.**

Section 1 gave the goal. This section says which notes explain each stage and which clauses of the standard fix the parameters.

Each source owns a different part of reception. 

The six foundation notes contribute specific operations to the executable chain.

| Source note | Knowledge contribution | Use in this laboratory |
|---|---|---|
| [[Star-10-Physical-Layer-Control-Signaling]] | Control resources, candidate search and DCI | Identify a usable broadcast grant |
| [[Star-14-Scheduling]] | Grant interpretation and resource assignment | Convert DCI to a data allocation |
| [[Star-16-Cell-Search-and-System-Information]] | Information acquired after synchronization | Connect decoded MIB to SIB1 |
| [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding]] | Polar control coding and DL-SCH coding | Decode bits and evaluate CRC results |
| [[Star-31-TS-38.213-Physical-Layer-Procedures-for-Control]] | Type0 common search space procedure | Derive frequency resources and monitoring time |
| [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data]] | Default time allocation, modulation and block size | Configure the data receiver from the grant |

The Chapter 16 notes of this knowledge base ([[Star-16-Cell-Search-and-System-Information|Star-16]]), especially section 16.4, motivate the staged broadcast procedure. Their channel terminology is read against the standard: Broadcast Control Channel (BCCH) is a logical channel; Broadcast Channel (BCH) and DL-SCH are transport channels. [Dahlman, Parkvall and Sköld, chapter 16](https://doi.org/10.1016/B978-0-12-822320-8.00016-7), printed pages 335–347 in the second edition, explains why the first broadcast message supplies enough information to find the next one.

The official table below identifies the frozen editions and the clauses that control the actual parameters. Original table rows were checked in the extracted DOCX files under [[Protocol/Rel-18/spec-manifest.yml|the frozen Release 18 manifest]].

| 3GPP specification and version | Exact clause or table | Implemented operation |
|---|---|---|
| [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 7.3.2; 7.4.1.3; 7.3.1; 7.4.1.1 | Control/data mapping and reference signals |
| [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.3.1.2.1; 7.3.2; 7.3.3; 7.2 | Format 1_0, control CRC/coding, DL-SCH decoding |
| [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.1; 10.1; 13, Tables 13-4 and 13-11 | Monitoring region, candidate set and frame parity |
| [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 5.1.2.2.2; Table 5.1.2.1.1-2; 5.1.3.1–5.1.3.2 | Frequency/time allocation, coding rate and block size |
| [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.2.2 MIB and SIB1; 6.3.2 RACH-ConfigCommon; 8.1 | Message fields and unaligned encoding |
| [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | Table 7.1-1; 5.1 | SI-RNTI value and later random access use |

The [MathWorks cell search example](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html) supplies the installed configuration helpers used by the lab. [ShareTechnote Type0 common search space](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html) provides a secondary visual explanation of the resource relationship. The local receiver adds candidate logs, wrong configuration tests and an actual encoded SIB1 setup. It is a teaching implementation of established procedures.

## 3. Convert recovered MIB fields into a monitoring region

**Stage — 3GPP protocol.**

Section 2 named the clauses. This section turns the recovered MIB bits into the region of the grid where the receiver must look for control.

!important[The Physical Broadcast Channel (PBCH) receiver returns decoded MIB fields only after BCH CRC acceptance. The field `pdcch-ConfigSIB1` contains two four bit indices. Its upper four bits select the CORESET0 resource row; the lower four bits select the search space timing row. Choosing the resource table also requires the SSB spacing, common spacing and applicable minimum channel bandwidth. Those inputs are not all carried in the eight bit field. [TS 38.213 V18.8.0, clause 13](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).]

### 3.1 Recover the inputs before applying a table

The table lookup needs inputs the MIB does not fully carry. This section lists what was recovered and what the receiver assumes.

The baseline recovered System frame number (SFN) 426, SSB index zero, common spacing 30 kHz and `pdcchConfigSib1=0`. The receiver uses the known Case C search profile; band n78 supplies the 10 MHz minimum bandwidth branch for this table selection.

The BCH decoder supplies the MIB bits used by the table lookup. Their agreement with the transmitter's formatted message in the comparison below verifies the input to that lookup before any control resources are inferred.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 12 MIB Agreement v1.png]]

*MATLAB result from run.mat: the 24 generated BCH transport bits beside the 24 recovered ones, agreeing at every position. These bits carry the MIB fields of TS 38.331 §6.2.2 that the rest of the receiver reads: system frame number 426, common spacing 30 kHz, kSSB 0 and pdcch-ConfigSIB1 0.*

The values below come from `run.mat:m`; the table choice is a documented receiver assumption.

| Parameter | Value | Evidence | Consumer |
|---|---|---|---|
| `systemFrameNumber` | 426 | Program output | Monitoring frame parity |
| `subcarrierSpacingCommon` | 30 kHz | Program output | Control/data numerology |
| `kSsb` | 0 | Program output | Frequency raster alignment |
| `dmrsTypeAPosition` | 2 | Program output | Default data allocation |
| `pdcchConfigSib1` | 0 | Program output | Both table indices zero |
| SSB spacing / minimum bandwidth | 30 kHz / 10 MHz | Assumed n78 profile | Table 13-4 selection |

Here, spacing is frequency separation between adjacent subcarriers. The indices are dimensionless. `kSsb=0` removes a fractional resource block offset in this setup; the receiver intentionally rejects nonzero values because that resampling and frequency placement case is not implemented.

### 3.2 Separate frequency placement from monitoring time

With the inputs fixed, this section reads the two tables: one for where the control region sits in frequency, one for when to monitor it.

Table 13-4 row zero supplies 24 resource blocks, two Orthogonal frequency-division multiplexing (OFDM) symbols and zero resource block offset between the SSB reference and CORESET0. Table 13-11 row zero supplies $O=0$, $M=1$ and first symbol zero. Multiplexing pattern 1 makes the receiver monitor two consecutive slots associated with the selected SSB.

The comparison below gives the two coordinate questions separate axes.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 02 Geometry and Monitoring v2.png]]

*Original schematic with two separate coordinate questions: frequency placement of CORESET0 relative to the SSB selects the capture rows, and the monitoring occasion selects the slot columns. Only slot 1 holds the transmitted broadcast control and data in this setup; the labels and MATLAB slices give the exact extents.*

The monitoring table supplies the offset and scaling parameters for the slot calculation.

External source: [13; Table 13-11](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.213 V18.8.0, §13; Table 13-11](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=239), printed page 238. For multiplexing pattern 1 in FR1, index 0 supplies O=0, M=1 and first symbol 0 to the monitoring occasion calculation.*

What we are working out: the monitoring slot associated with SSB index zero, relative to the current 10 ms frame.

$$
\begin{aligned}
n_0 &= \left(O2^\mu+\lfloor i_{\mathrm{SSB}}M\rfloor\right)\bmod N_{\mathrm{slot}} \\
&= \left(0\cdot2^1+\lfloor0\cdot1\rfloor\right)\bmod20 \\
&=0.
\end{aligned}
$$

Here, $n_0$ is a slot index, $O=0$ and $M=1$ are the dimensionless table parameters, $\mu=1$ is the numerology index for 30 kHz, $i_{\mathrm{SSB}}=0$ is the recovered block index and $N_{\mathrm{slot}}=20$ is the number of 30 kHz slots per frame. The floor operator produces an integer slot contribution. The associated frame parity is even because the quotient before the modulo operation is zero. All table inputs are reported by [TS 38.213 V18.8.0, clause 13](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); the selected indices are program outputs. `uni03_table(m).monitorSlots` returns `[0 1]`.

The compact variable table records the calculation's inputs and result.

| Symbol | Value and unit | Input status | Source and reference plane |
|---|---|---|---|
| $O,M$ | 0, 1 | Reported | Table 13-11, row 0 |
| $\mu,N_{\mathrm{slot}}$ | 1, 20 slots/frame | Calculated | 30 kHz frame numerology |
| $i_{\mathrm{SSB}}$ | 0 | Program output | Decoded SSB index |
| $n_0$ | 0 slots | Calculated | Start of monitoring pair |

The output is an integer slot coordinate, with no time rounding. A matching frequency region in an odd frame does not satisfy the monitoring occasion; the odd frame failure test stops before candidate decoding.

### 3.3 Translate resource coordinates into array indices

Section 3.2 gave resource coordinates. This section converts them into MATLAB array indices of the captured grid.

The capture has 336 subcarriers because each of its 28 resource blocks contains 12 subcarriers. Its centered 240 subcarrier SSB starts at MATLAB row 49. With the selected zero offset, CORESET0 starts on that same row and extends to row 336. These coordinates belong to the partial capture.

What we are working out: the first MATLAB row and number of rows required for control reception.

$$
\begin{aligned}
r_{\mathrm{first}} &= (N_{\mathrm{cap}}12-N_{\mathrm{SSB}})/2+1 \\
&=(28\cdot12-240)/2+1=49, \\
N_{\mathrm{rows}} &= N_{\mathrm{RB}}12=24\cdot12=288.
\end{aligned}
$$

Here, $r_{\mathrm{first}}$ is the one based array row, $N_{\mathrm{cap}}=28$ is the assumed capture width in resource blocks, $N_{\mathrm{SSB}}=240$ is the reported SSB width in subcarriers and $N_{\mathrm{RB}}=24$ is the table supplied CORESET width. The coefficient 12 is the subcarrier count per resource block. The division by two centers the SSB in the capture; the final one converts a zero based offset into MATLAB indexing. `rows=49:336` and `grid(rows,15:28)` are the resulting 288 by 14 monitoring slot array.

Applying the selected CORESET0 row and the capture coordinates produces the transmitted monitoring slice below. Compare the control region's width and duration with the protocol row; the later, narrower data region is the allocation that the grant must describe.


External source: [13; Table 13-4](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.213 V18.8.0, §13; Table 13-4](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=234), printed page 233. For the applicable 30 kHz SSB and 30 kHz PDCCH case, index 0 gives 24 resource blocks, two symbols and zero resource block offset.*


![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 14 Transmit Monitoring Slot v1.png]]

*MATLAB result: magnitude of the 288 by 14 transmit slice, rows 49 to 336 of the capture in slot 1. PDCCH occupies the first two OFDM symbols across the 24 CORESET0 resource blocks and the scheduled PDSCH occupies a narrower band later in the slot, the layout the grant will describe.*


Extracting the same coordinates after synchronization produces the received slice. The retained control and data regions show that the derived monitoring window contains the transmitted allocation despite noise and estimation error; candidate decoding must now test the control content within it.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 15 Receive Monitoring Slot v1.png]]

*MATLAB result: the same slice recovered from the received grid using the MIB-derived frequency region and the selected monitoring slot. Noise and residual estimation error appear in the same coordinates; the control and data regions are still visible, which is what candidate search relies on.*

The array table fixes the dimensions and indexing convention.

| Symbol or array | Value | Evidence | Meaning |
|---|---|---|---|
| $r_{\mathrm{first}}$ | 49 | Calculated | First CORESET row, MATLAB indexing |
| $N_{\mathrm{rows}}$ | 288 | Calculated | 24 resource blocks of 12 subcarriers |
| `grid(rows,15:28)` | 288 by 14 complex values | Program output | Slot 1 relative to frame start |
| Capture versus carrier | 28 versus 51 resource blocks | Assumed setup / encoded field | Observed subset versus configured extent |

## 4. Search control candidates and decode the grant

**Stage — MATLAB experiment.**

Section 3 fixed where and when to look. This section searches every control candidate in that region and decodes the one that passes its CRC.

The receiver does not know the transmitter's selected candidate. It enumerates the configured candidates, estimates a channel from the Demodulation reference signal (DM-RS), equalizes each candidate, obtains soft bit values and polar decodes DCI format 1_0. System information RNTI (SI-RNTI) 65535 masks the control CRC; the PDCCH scrambling input uses RNTI zero in this common search case. Confusing these two uses of Radio network temporary identifier (RNTI) changes the decoded result. [TS 38.211 V18.9.0, 7.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) and [TS 38.212 V18.8.0, 7.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).

### 4.1 Count the control resources and hypotheses

The search space is finite. This section counts the control channel elements and the candidates the receiver must try.

A Control-channel element (CCE) contains six resource element groups. Each group occupies one resource block during one OFDM symbol. The aggregation level tells the decoder how many CCEs belong to one candidate.

What we are working out: the number of CCEs available in the selected CORESET.

$$
\begin{aligned}
N_{\mathrm{CCE}} &= N_{\mathrm{RB}}N_{\mathrm{sym}}/6 \\
&=24\cdot2/6=8.
\end{aligned}
$$

Here, $N_{\mathrm{CCE}}=8$ is the calculated control element count, $N_{\mathrm{RB}}=24$ is the table supplied frequency width and $N_{\mathrm{sym}}=2$ is its duration in OFDM symbols. The coefficient six is the number of resource element groups per CCE from [TS 38.211 V18.9.0, 7.3.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip). The MATLAB search space requests `[0 0 4 2 0]` candidates at aggregation levels `[1 2 4 8 16]`; an aggregation of 16 cannot fit eight CCEs.

The comparison distinguishes a wrong resource hypothesis from a wrong identity hypothesis.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 03 Candidate Comparison v2.png]]

*Original schematic of the three decoder hypotheses. Only correct resources with the correct SI-RNTI 65535 yield CRC zero; a wrong resource set or a wrong identity both end in a CRC failure. The eight CCEs come from 24 resource blocks over two symbols divided by six groups per CCE.*

!warning[Candidate enumeration can include the same physical resource set more than once. In this eight CCE setup, candidates 1 and 2 at aggregation 4 coincide, as do candidates 3 and 4. The transmitter selects candidate 2; the receiver first accepts candidate 1 because its resources are identical. The recorded attempts therefore cannot be interpreted as a count of unique resources.]

The control resource table states what is counted.

| Quantity | Value | Evidence | Interpretation |
|---|---|---|---|
| CORESET groups | 48 | Calculated | 24 blocks during two symbols |
| CCE count | 8 | Calculated | Six groups per CCE |
| Attempts in empty slot 0 | 6 | Program output | Four AL4 and two AL8 entries |
| Baseline accepted attempt | 7 | Program output | Slot 1, AL4, candidate 1 |

### 4.2 Inspect every attempted CRC result

Section 4.1 counted the hypotheses. This section logs every CRC result so that the accepted candidate can be located.

The first monitoring slot contains the SSB but no broadcast PDCCH. Its six control attempts fail. The first candidate in slot 1 passes, after which the receiver interprets the recovered DCI.

Logging each candidate CRC turns the search into an inspectable sequence. In the acceptance trace, follow the rejected candidates until the first pass; that position identifies the monitoring slot and candidate whose grant is handed to the data receiver.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 17 Candidate Acceptance v1.png]]

*MATLAB result from candidates.csv: the CRC outcome of every recorded control attempt in order. The six attempts in the empty slot 0 fail, and the seventh attempt, aggregation level 4 candidate 1 in slot 1, is the first to pass its SI-RNTI CRC and ends the search.*

The syndrome plot explains why some failed attempts repeat the same result. Equal nonzero syndromes within a slot expose repeated resource hypotheses, while the accepted candidate has an exact zero represented at the plot's stated display floor.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 18 Candidate Syndromes v1.png]]

*MATLAB result: the CRC syndrome of each attempt on a logarithmic axis, with the exact zero of the accepted attempt drawn at 0.5 so it can be displayed. Identical syndromes in the same slot reveal candidates that occupy the same physical CCEs.*

!warning[A zero CRC result accepts a decoded block under the configured identity. It does not prove that the message is authentic; this broadcast reception experiment does not establish a cryptographic security context.]

### 4.3 Connect constellation, soft bits and DCI fields

Section 4.2 accepted one candidate. This section looks inside it: the constellation, the soft bits and the decoded DCI fields.

The equalized control symbols should cluster near the four Quadrature phase-shift keying (QPSK) points. The decoder then uses the signed Log-likelihood ratio (LLR) for each coded bit, rather than first reducing all observations to hard decisions.

Extracting and equalizing the accepted control candidate gives the constellation below. Its cluster spread shows the remaining symbol uncertainty that the polar decoder receives through the soft bits.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 19 PDCCH Constellation v1.png]]

*MATLAB result: equalized symbols of the accepted control candidate. The four QPSK clusters show the DM-RS channel estimate and equalizer working on the control resources; their spread is the noise the polar decoder must overcome through its soft input.*

Soft demodulation preserves that uncertainty in the LLR array. Read stem sign as the preferred bit and magnitude as its confidence; the histogram shows the distribution of evidence supplied to polar decoding for this accepted candidate.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 20 PDCCH LLR v1.png]]

*MATLAB result: the first 120 control soft bits as stems, whose sign is the bit decision and whose height is the confidence, and below them the histogram of all 432 soft bits fed to the polar decoder. The two well separated populations show why soft values outperform hard decisions at this SNR.*

After rate recovery, polar decoding and CRC checking, the DCI comparison tests the information bits against the generated grant. Their agreement verifies the fields used to choose the next resource slice, beyond the visual quality of the constellation.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 21 DCI Agreement v1.png]]

*MATLAB result: decoded DCI format 1_0 information bits beside the transmitted ones, agreeing after rate recovery, polar decoding and CRC checking. These bits hold the RIV, time index, MCS and redundancy version that the data receiver reads next.*

## 5. Recover the data allocation, transport bits and SIB1 fields

**Stage — MATLAB experiment.**

Section 4 recovered the grant. This section uses it to find the data allocation, decode the transport block and parse the SIB1 bytes.

!note[The Physical downlink shared channel (PDSCH) receiver obtains its allocation from the accepted grant. It also needs the MIB's DM-RS Type A position and the default time allocation table applicable to SIB1. These known rules remove the apparent circular dependency of needing SIB1 configuration before receiving SIB1.]

### 5.1 Turn DCI into the PDSCH resource slice

The grant is a few small numbers. This section turns them into the resource slice the data receiver must extract.

The recovered grant contains Resource indication value (RIV) 168, time index zero, Modulation and coding scheme (MCS) index 4 and redundancy version zero. Its system information indicator is zero, identifying SIB1 in this format. [TS 38.212 V18.8.0, 7.3.1.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).

The grant diagram connects the decoded fields to the data receiver settings.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 04 Grant and Data v2.png]]

*Original schematic connecting the decoded grant fields to the PDSCH receiver settings: the RIV fixes the resource blocks, the time index selects the default allocation row, and the MCS fixes modulation and code rate. DM-RS locations are drawn schematically.*

What we are working out: the frequency assignment represented by the short allocation branch of the RIV encoding.

$$
\begin{aligned}
\mathrm{RIV} &= N_{\mathrm{BWP}}(L_{\mathrm{RB}}-1)+R_{\mathrm{start}} \\
&=24(8-1)+0=168.
\end{aligned}
$$

Here, $N_{\mathrm{BWP}}=24$ is the Bandwidth part (BWP) width used for this Type0 grant, $L_{\mathrm{RB}}=8$ is the allocation length in resource blocks and $R_{\mathrm{start}}=0$ is the first Physical resource block (PRB) relative to that BWP. RIV is a dimensionless integer. This branch applies because $L_{\mathrm{RB}}-1=7$ is no greater than half the BWP width. The source is [TS 38.214 V18.10.0, 5.1.2.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip). The receiver produces `pdsch.PRBSet=0:7`.

For MIB `dmrsTypeAPosition=2`, default time allocation A row 1 gives mapping Type A, slot offset zero, start symbol 2 and length 12. The four bit DCI time index zero selects this first row. MCS index 4 gives modulation order two and target rate $308/1024$ in [TS 38.214 V18.10.0, Tables 5.1.2.1.1-2 and 5.1.3.1-1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip). Here, modulation order two means two coded bits per QPSK symbol; 308 is the table supplied numerator and 1024 is the table's rate normalization.

The receiver uses the RIV branches to recover the allocation start and length from the grant. In the paired numerical map, inspect the separate data, reference and unused classes within that allocation; these are the Toolbox indices used to extract symbols and estimate their channel.


External source: [5.1.2.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.214 V18.10.0, §5.1.2.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf#page=29), printed page 28. The two RIV branches encode the starting virtual resource block and contiguous allocation length. The laboratory uses the first branch for its eight resource blocks.*


![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 16 Channel Assignments v1.png]]

*MATLAB result calculated from the toolbox index arrays: the exact PDSCH data, DM-RS and unused resource elements in the eight allocated resource blocks over symbols 2 to 13. Each class has its own integer label, so the map can be checked against the mapping rules of TS 38.211 §7.4.1.1.*


The allocation table keeps the decoded fields separate from derived settings.

| Quantity | Value | Evidence | MATLAB representation |
|---|---|---|---|
| RIV | 168 | Decoded | `baseline.dci.frequencyRIV` |
| PRB start and length | 0 and 8 blocks | Calculated | `pdsch.PRBSet=0:7` |
| Start and duration | 2 and 12 symbols | Table output | `pdsch.SymbolAllocation=[2 12]` |
| Modulation and target rate | QPSK; 308/1024 | Table output | `pdsch.Modulation`, `targetCodeRate` |
| Transport block length | 528 bits | Program output | `nrTBS`, `transportBlockLength` |

The 528 bit block size follows the full resource and rounding procedure in clause 5.1.3.2. It is saved as a program output rather than inferred by simply multiplying the nominal code rate by the coded bit count.

### 5.2 Estimate the data channel and decode DL-SCH

Section 5.1 located the data. This section estimates its channel and decodes the shared channel.

The receiver builds the expected data DM-RS from the recovered cell context and grant, estimates the complex channel and equalizes the scheduled symbols. It passes QPSK soft decisions and the derived transport length to `nrDLSCHDecoder`.

Extracting the scheduled PDSCH positions gives the received constellation below. Its rotation and scaling show the distortion still present after acquisition, before the data DM-RS estimate is applied.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 22 PDSCH Before Equalization v1.png]]

*MATLAB result: received symbols extracted from the scheduled PDSCH resources before channel compensation. The clouds are rotated and scaled by the channel, so the QPSK orientation is lost until the DM-RS estimate is applied.*

Equalizing the same extracted symbols restores the QPSK regions. Comparing their orientation and spread with the preceding constellation checks the compensation step before interpreting the channel estimate that produced it.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 23 PDSCH After Equalization v1.png]]

*MATLAB result: the same data symbols after channel equalization, back in the four QPSK regions. The residual spread is noise plus estimation error and is what soft demodulation converts into the DL-SCH decoder input.*

The DM-RS estimator produces the magnitude surface below from reference observations in the scheduled band. Inspect that band when assessing the estimate; zeros outside the data allocation are unused output and do not measure a channel fade.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 24 Channel Magnitude v1.png]]

*MATLAB result: magnitude of the channel estimate the DM-RS estimator produced across the slot. Only subcarriers 0 to 95 belong to the data allocation; zeros outside it are unused estimator output. The surface is an estimate, interpolated and extrapolated from pilot observations.*

The phase surface of the same estimate shows the residual evolution across symbols after acquisition. Its drift explains why the data receiver still needs compensation from reference observations even though the monitoring slot has already been found.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 25 Channel Phase v1.png]]

*MATLAB result: phase of the same channel estimate in radians. The slow drift across symbols is the residual frequency error left after acquisition; only the scheduled data resources consume this estimate.*

Reliability weighting converts the equalized data and receiver confidence into the decoder input shown below. The signed stems and histogram retain both bit preference and confidence; successful transport recovery must be checked on the decoded bits and CRC after this stage.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 26 PDSCH LLR v1.png]]

*MATLAB result: the first 120 reliability-weighted data soft bits as stems and, below, the histogram of all soft bits supplied to the DL-SCH decoder. The signed values keep the confidence that hard slicing would discard; this is the actual array from which the 528-bit transport block was decoded.*

### 5.3 Parse actual SIB1 bytes and expose the random access fields

Section 5.2 recovered 528 bits with a passing CRC. This section parses them as an ASN.1 message and reads the random access fields.

The local setup was encoded as BCCH-DL-SCH-Message using Unaligned Packed Encoding Rules (UPER). It places 400 message bits at the start of the 528 bit transport block and appends 128 zero padding bits. After CRC acceptance, `sib1_codec.py` parses the recovered bytes with [pycrate 0.8.1](https://github.com/pycrate-org/pycrate), checks the SIB1 message choice and reencodes it. The canonical 50 byte result equals the original setup. The decoder consumes the message grammar and does not obtain the fields from transmitter metadata.

Comparing the recovered SIB1 bits with the encoded message checks the payload that enters message parsing. The matching rows below establish message bit agreement; the separate parsing and reencoding check establishes which fields those bits represent.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 27 SIB1 Bits v1.png]]

*MATLAB result: the 400 encoded SIB1 bits of the transmitter in the upper row and the recovered bits in the lower row, dark for one and white for zero, with the mismatch count in the title. The two rows are identical; the remaining 128 bits of the 528-bit block are zero padding the message decoder ignores.*

The two validation steps below explain why a good transport CRC must be followed by message decoding.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 05 Transport and ASN1 v2.png]]

*Original schematic of the two validation steps: the physical decoder accepts the whole 528-bit block by CRC, and the ASN.1 decoder then identifies BCCH-DL-SCH-Message, selects SIB1 and extracts its fields. A good transport CRC alone does not tell the receiver what the bytes mean.*

The decoded random access settings are stored in [decoded-sib1.json](../10%20MATLAB%20Labs/uni03/results/run-20260907-122809/decoded-sib1.json). Their meanings follow [TS 38.331 V18.10.0, 6.3.2, RACH-ConfigCommon and RACH-ConfigGeneric](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).

| Decoded field | Value | Receiver use | Evidence |
|---|---|---|---|
| `prach-ConfigurationIndex` | 0 | Select time/format table row for TDD | Decoded UPER |
| `prach-RootSequenceIndex` | `l839:22` | Configure long preamble root index | Decoded UPER |
| `msg1-FDM`, `msg1-FrequencyStart` | `one`, 0 | One occasion for Frequency-division multiplexing (FDM), at the initial offset | Decoded UPER |
| `zeroCorrelationZoneConfig` | 0 | Select cyclic shift configuration | Decoded UPER |
| `preambleReceivedTargetPower` | −100 dBm | Initial preamble target power | Decoded UPER |
| `preambleTransMax`, `powerRampingStep` | `n10`, `dB2` | Attempt limit and ramp step | Decoded UPER |
| `ra-ResponseWindow` | `sl20` | Monitor response for 20 slots | Decoded UPER |
| `ra-ContentionResolutionTimer` | `sf64` | Later contention timer | Decoded UPER |

The Physical random access channel (PRACH) output also carries the uplink spacing and Time division duplex (TDD) context from `servingCellConfigCommon`: 30 kHz uplink spacing, a 5 ms pattern with four downlink slots, five uplink slots and one intervening flexible slot. PRACH configuration index zero must be interpreted with the TDD table; a frequency division duplex table would describe another occasion.

What we are working out: the duration represented by the decoded response window for this 30 kHz control numerology.

$$
\begin{aligned}
T_{\mathrm{slot}} &= 1\ \mathrm{ms}/2^\mu=1\ \mathrm{ms}/2^1=0.5\ \mathrm{ms},\\
T_{\mathrm{win}} &= N_{\mathrm{win}}T_{\mathrm{slot}}=20\cdot0.5\ \mathrm{ms}=10\ \mathrm{ms}.
\end{aligned}
$$

Here, $T_{\mathrm{slot}}$ is the calculated slot duration, $\mu=1$ identifies 30 kHz spacing, $N_{\mathrm{win}}=20$ is the decoded response window in slots and $T_{\mathrm{win}}=10$ ms is its duration. The 1 ms coefficient is the subframe duration. This conversion supplies a duration to the later random access procedure; the procedure determines the exact window start under [TS 38.213 V18.8.0, 8.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

The output table records the quantities passed to the next experiment.

| Quantity | Value and unit | Evidence | Where it applies |
|---|---|---|---|
| $T_{\mathrm{slot}}$ | 0.5 ms | Calculated | 30 kHz control slot |
| $N_{\mathrm{win}}$ | 20 slots | Decoded | SIB1 common RACH configuration |
| $T_{\mathrm{win}}$ | 10 ms | Calculated | Response monitoring duration |
| Message / padding | 400 / 128 bits | Encoded and recovered | DL-SCH transport input |

The pycrate schema file is versioned and hashed with the evidence. This setup uses base SIB1 information elements; its successful round trip does not verify all Release 18 extensions or all conditional presence rules needed by a commercial User equipment (UE).

## 6. Reproduce the evidence and identify failures

**Stage — Measured results.**

Sections 3 to 5 followed one capture. This section shows how to reproduce the evidence, measures reception statistically and breaks one assumption at a time.

The saved run contains one acquisition test using an actual time waveform and 120 conditional control/data tests using resource grids with known synchronization. Keeping these two experiment scopes explicit prevents the conditional SNR curve from being mistaken for a complete cell acquisition probability.

### 6.1 Trace the time waveform into the recovered grid

The first check is the time waveform itself, from injected impairments to the recovered grid.

The transmitter creates two 30 kHz slots. The first contains the SSB; the second contains control and data. The sample array is delayed, frequency shifted and corrupted by independent Gaussian noise. The existing cell search receiver estimates timing, frequency and MIB before the broadcast receiver is called.

Generating the complete capture places synchronization and broadcast reception in the same waveform. In the transmit grid, follow the occupied regions across the slot boundary to identify the reference layout for the recovered grid.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 07 Transmit Grid v1.png]]

*MATLAB result: magnitude of the complete generated capture, two 30 kHz slots of 336 subcarriers. The SSB occupies the first slot and the control plus data burst occupies the second; both regions belong to the same generated waveform.*

The acquisition stage uses the Primary synchronization signal (PSS) and Secondary synchronization signal (SSS), followed by PBCH recovery. Comparing the recovered grid with the transmitted layout checks that estimated synchronization and OFDM demodulation preserve both broadcast regions for the later receiver.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 08 Received Grid v1.png]]

*MATLAB result: the grid recovered after estimated synchronization and OFDM demodulation. Both broadcast regions are preserved with noise and residual estimation error added; this grid is the input to the MIB-driven broadcast receiver.*

The received time trace records the samples from which acquisition starts. Its time axis establishes the observation window and its normalized amplitude shows the signal supplied to synchronization; timing accuracy is evaluated against the saved injected delay.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 09 Received Waveform v1.png]]

*MATLAB result: the received time waveform in milliseconds using the saved sample rate, in normalized simulation amplitude. It carries the injected 19-sample delay and 3400 Hz frequency offset that the cell search receiver estimates before anything else.*

The input FFT provides a frequency view of the same corrupted waveform. Use the occupied band as the reference for the corrected spectrum that follows; its uncalibrated magnitude supports a placement check.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 10 Received Spectrum v1.png]]

*MATLAB result: FFT magnitude of the corrupted input waveform with the frequency axis relative to the capture centre. It shows the occupied band before frequency correction; the magnitude is uncalibrated and does not represent a power spectral density.*

Applying the receiver's frequency estimate produces the corrected spectrum below. The broad frequency axis makes the small correction difficult to see, so this visual comparison needs the numerical offset components to assess estimation accuracy.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 11 Corrected Spectrum v1.png]]

*MATLAB result: the spectrum after the receiver applies its estimated frequency offset. A few kilohertz of correction is invisible on a megahertz axis, so the numerical estimate of 3253 Hz against the injected 3400 Hz is the useful accuracy check.*

Separating the coarse and fine estimates in the component plot exposes how the total correction was formed. Their sum can be compared with the injected offset to quantify the residual that the later reference estimates must tolerate.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 13 Offset Components v1.png]]

*MATLAB result: coarse search output and fine estimate that add to the total frequency correction of 3253.073 Hz against the injected 3400 Hz. The 147 Hz residual stays inside this baseline's tracking range and did not prevent the MIB decode.*

The saved array path is directly executable.

```matlab
s = load(fullfile(report.output,'run.mat'));
r = uni03_receive(s.m, s.grid, struct);
assert(r.dciCRC == 0 && r.transportCRC == 0);
assert(isequal(r.transportBits,s.t.transportBits));
disp(r.dci)
```

`m` is the decoded MIB and acquisition result. `grid` is a complex 336 row capture with frame slot zero as its column origin. Receiver options are `siRNTI`, `offsetRB`, `slots` and `mcs`; they exist for controlled failure experiments. A nonzero BCH CRC, unsupported spacing/index profile or a capture missing the required rows stops this bounded receiver.

### 6.2 Measure reception after synchronization

Section 6.1 recovered one grid. This section adds noise to it many times and counts how often control and data still decode.

The conditional sweep adds independent complex Gaussian noise with mean power $10^{-\mathrm{SNR}/10}$ to each grid resource element. Signal resource elements have unit mean power. Each SNR point uses 20 independent noise draws and the same recovered noiseless MIB. The acceptance condition requires a valid DCI CRC, a valid transport CRC and exact transport bit equality.

Counting trials that satisfy all acceptance checks gives the conditional reception probability below. Read the transition with its interval widths: the scan measures recovery after synchronization under the declared noise model, and the next comparison identifies which decoder limits it.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 28 Reception Probability v1.png]]

*MATLAB result: fraction of 20 trials per SNR that pass DCI CRC, transport CRC and exact bit equality, with 95% Wilson intervals. Reception jumps from 0 of 20 at −4 dB to 20 of 20 at 0 dB; these are conditional results with known grid synchronization.*

Plotting control and transport acceptance separately locates the failed stage. Where control still passes but transport does not, the receiver has found a usable grant and the loss occurs during data recovery.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 29 Decoder Bottleneck v1.png]]

*MATLAB result: control acceptance and transport acceptance plotted separately. At −4 dB control decoding succeeds in 19 of 20 trials while no transport block passes, so the data decoder is the bottleneck at that SNR.*

The saved CSV counts support the plotted fractions.

| SNR per resource element | Successful trials | Fraction | Wilson 95% interval |
|---|---|---|---|
| −8 dB | 0 / 20 | 0 | 0 to 0.1611 |
| −4 dB | 0 / 20 | 0 | 0 to 0.1611 |
| 0 dB | 20 / 20 | 1 | 0.8389 to 1 |
| 4 dB | 20 / 20 | 1 | 0.8389 to 1 |
| 8 dB | 20 / 20 | 1 | 0.8389 to 1 |
| 16 dB | 20 / 20 | 1 | 0.8389 to 1 |

The data does not locate an exact sensitivity threshold. Further points between −4 and 0 dB, more trials and realistic fading would be needed to estimate a performance curve for another channel. This simulation also omits interference, oscillator phase noise, multiple antennas and retransmission combining.

### 6.3 Break one receiver assumption at a time

Section 6.2 varied the noise. This section changes one receiver assumption at a time so that each failure has one cause.

The failure experiments use the same received baseline grid. They change only the listed receiver parameter or monitoring context, so a failed data decode can be traced to the changed input.

Repeating reception on the baseline grid with one changed setting produces the failure comparison below. Distinguish cases that lose the control grant from the MCS case that reaches data decoding; this separation identifies the receiver input to inspect first.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 30 Failure Comparison v1.png]]

*MATLAB result: control and transport acceptance for each deliberately wrong receiver setting on the same baseline grid. A wrong MCS keeps the accepted DCI but breaks the transport decode; a wrong identity, frequency region or monitoring time prevents the grant altogether.*

The failure table identifies the next object to inspect when a similar trace occurs.

| Test | Control accepted | Transport accepted | Interpretation |
|---|---|---|---|
| Baseline | Yes | Yes | All 528 bits and canonical SIB1 agree |
| SI-RNTI 65534 | No | No | Twelve candidate attempts fail CRC |
| CORESET displaced by −1 resource block | No | No | Receiver extracts wrong resources |
| Only slot 0 monitored | No | No | Actual grant in slot 1 is missed |
| MCS overridden to 0 | Yes | No | Incorrect block size/rate after grant |
| SFN changed to 427 | No search | No | Odd frame fails occasion condition |

These are observed setup failures. The CRC is an error detector with finite residual error probability; the table does not claim that every possible wrong input is guaranteed to be rejected.

### 6.4 Hand the decoded configuration to random access

The last step hands the decoded configuration to the next experiment.

The final flow ties each transformation to the value or check that permits the next operation.

![[99 Attachments/5G/Uni Labs/Uni-03/Uni-03 - 06 Final Flow v2.png]]

*Original schematic of the whole chain from MIB fields through CORESET0, PDCCH candidate, grant, PDSCH and ASN.1 parsing to the decoded PRACH configuration. Transmitting a preamble and completing access are later laboratory stages.*

The reproducibility record is `run-20260907-122809`, MATLAB R2026a Update 4, 5G Toolbox 26.1 and random seed 63003. `run.mat` contains waveform, recovered MIB, grid, candidate traces and transport arrays. `trials.csv`, `summary.csv`, `failures.csv` and `candidates.csv` preserve numerical results; `decoded-sib1.json` preserves message interpretation. `source-hashes.json` and its source snapshots bind the evidence to the local implementation. The [README](../10%20MATLAB%20Labs/uni03/README.md) documents the external helper and ASN.1 dependencies.

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

The source editions below support the protocol claims. Simulation evidence comes from the saved files rather than from the reference tutorials.

### 7.1 References

The reference register preserves the same primary and explanatory routes used in the body.

1. 3GPP, [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), physical channels and modulation; 7.3.1–7.3.2 and 7.4.1.
2. 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), multiplexing and channel coding; 7.2 and 7.3.
3. 3GPP, [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip), physical layer procedures for control; 4.1, 8.2, 10.1 and 13.
4. 3GPP, [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip), physical layer procedures for data; 5.1.2–5.1.3.
5. 3GPP, [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip), radio resource control; MIB, SIB1, RACH-ConfigCommon and encoding in 6.2.2, 6.3.2 and 8.1.
6. 3GPP, [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), medium access control; 5.1 and Table 7.1-1.
7. E. Dahlman, S. Parkvall and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, second edition, [chapter 16](https://doi.org/10.1016/B978-0-12-822320-8.00016-7), pp. 335–347. Reading route in this knowledge base: [[Star-16-Cell-Search-and-System-Information|Star-16]].
8. MathWorks, [NR Cell Search and MIB and SIB1 Recovery](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html), installed R2026a example helpers, inspected 2026-09-07.
9. ShareTechnote, [Type0 common search space](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html), explanatory resource and timing context, inspected 2026-09-07.
10. pycrate contributors, [pycrate ASN.1 runtime](https://github.com/pycrate-org/pycrate), version 0.8.1 used for local BCCH-DL-SCH UPER encoding and decoding.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.213 V18.8.0, §13; Table 13-4](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=234); [TS 38.213 V18.8.0, §13; Table 13-11](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=239); [TS 38.214 V18.10.0, §5.1.2.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf#page=29). Accessed 2026-09-08.

### 7.2 Abbreviation index

The two column index uses the terminology in [[5G Abbreviation Database]]. The detailed explanations establish each term where it first affects the receiver.

| Abbreviation | Full term |
|---|---|
| ASN.1 | Abstract Syntax Notation One |
| BCCH | Broadcast Control Channel |
| BCH | Broadcast Channel |
| BWP | Bandwidth part |
| CCE | Control-channel element |
| CFO | Carrier Frequency Offset |
| CORESET | Control resource set |
| CRC | Cyclic redundancy check |
| DCI | Downlink control information |
| DL-SCH | Downlink Shared Channel |
| DM-RS | Demodulation reference signal |
| FDM | Frequency-division multiplexing |
| LLR | Log-likelihood ratio |
| MCS | Modulation and coding scheme |
| MIB | Master information block |
| NR | New Radio |
| OFDM | Orthogonal frequency-division multiplexing |
| PBCH | Physical broadcast channel |
| PCI | Physical cell identity |
| PDCCH | Physical downlink control channel |
| PDSCH | Physical downlink shared channel |
| PRACH | Physical random access channel |
| PRB | Physical resource block |
| PSS | Primary synchronization signal |
| QPSK | Quadrature phase-shift keying |
| RIV | Resource indication value |
| RNTI | Radio network temporary identifier |
| SFN | System frame number |
| SI-RNTI | System information RNTI |
| SIB1 | System information block type 1 |
| SNR | Signal-to-Noise Ratio |
| SSB | Synchronization signal and PBCH block |
| SSS | Secondary synchronization signal |
| TDD | Time division duplex |
| UE | User equipment |
| UPER | Unaligned Packed Encoding Rules |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with value, unit and where each applies.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $O,M$ | Type0 monitoring table parameters | Dimensionless |
| $\mu$ | Numerology index; 1 for 30 kHz | Integer |
| $i_{\mathrm{SSB}}$ | Recovered SSB index | Integer |
| $n_0,N_{\mathrm{slot}}$ | First monitoring slot and slots per frame | Slot counts |
| $N_{\mathrm{cap}},N_{\mathrm{RB}}$ | Capture and CORESET frequency widths | Resource blocks |
| $N_{\mathrm{SSB}},N_{\mathrm{rows}}$ | SSB and extracted array widths | Subcarriers |
| $r_{\mathrm{first}}$ | First MATLAB row of CORESET0 | One based index |
| $N_{\mathrm{sym}}$ | CORESET duration | OFDM symbols |
| $N_{\mathrm{CCE}}$ | Available CCE count | Integer |
| $N_{\mathrm{BWP}}$ | BWP width used to interpret the grant | Resource blocks |
| $L_{\mathrm{RB}},R_{\mathrm{start}}$ | PDSCH length and first block | Resource blocks / index |
| $T_{\mathrm{slot}},T_{\mathrm{win}}$ | Slot and response window duration | ms |
| $N_{\mathrm{win}}$ | Decoded response window count | Slots |
