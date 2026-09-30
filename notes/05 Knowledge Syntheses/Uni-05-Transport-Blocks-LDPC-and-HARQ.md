---
title: Uni-05 — Transport blocks, LDPC coding and HARQ
type: knowledge_synthesis
language: en
uni: 5
release_baseline: 18
cssclasses:
- research-note-tables
lab_run: run-20260907-120612
---

# Uni-05 — Transport blocks, LDPC coding and HARQ

!important[A failed transmission can still carry useful evidence. This experiment encodes a Transport Block (TB), sends selected portions of its Low-Density Parity-Check (LDPC) codeword, and combines noisy observations before decoding again. A Cyclic Redundancy Check (CRC) accepts or rejects each decoded block. The saved failure trace has 337 information bit errors after its first transmission, 214 after its second and zero after its third.]

Press Ctrl+F (Command+F on a Mac) to jump to any stage. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

The system overview places coding and error detection on the two sides of the radio channel.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - System Overview v1.png]]

*Original schematic: the transmitter supplies coded observations; the receiver combines evidence, decodes and checks the recovered transport block. The diagram omits feedback timing.*

Searchable structure: transport CRC → segmentation → LDPC encoding → RV selection → aligned likelihoods → decoding → CRC and transmission accounting.

## 1. Coding and retransmission in the downlink system

**Stage — Textbook workflow.**

The overview above placed coding and error detection on the two sides of the channel. This section says what HARQ combines and which notes supply each piece.

Hybrid Automatic Repeat Request (HARQ) combines error detection, decoding and retransmission. The transmitter retains the same transport block for its retransmissions. The receiver retains soft evidence associated with that block and adds new evidence at matching encoded positions.

The course sources provide distinct pieces of this processing chain.

| Star source | Knowledge used | Experiment operation |
| --- | --- | --- |
| [[Star-09-Transport-Channel-Processing\|Transport processing]] | Bit and codeword stages | Explicit encoder chain |
| [[Star-10-Physical-Layer-Control-Signaling\|Control signaling]] | HARQ fields | Fixed process and RV inputs |
| [[Star-13-Retransmission-Protocols\|Retransmission]] | Soft combining and repeat attempts | IR, Chase and reset comparisons |
| [[Star-14-Scheduling\|Scheduling]] | Resource and service accounting | Coded bits charged per attempt |
| [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding\|Channel coding]] | CRC, LDPC and rate matching | Toolbox functions |
| [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data\|Data procedures]] | Target rate and TBS | Explicit coding setup |
| [[Star-33-TS-38.321-Medium-Access-Control\|Medium access]] | Process ownership and new data | Buffer lifecycle |

The Chapter 13 note of this knowledge base ([[Star-13-Retransmission-Protocols|Star-13]]) explains soft combining and the distinction between Medium Access Control (MAC) HARQ and Radio Link Control (RLC) retransmission. The present setup demonstrates only the HARQ coding/combining mechanism. Its resources and timing are supplied directly rather than decoded from Downlink Control Information (DCI). A Redundancy Version (RV) chooses a starting position for rate matching; it does not define a new transport block. The [ShareTechnote HARQ guide](https://www.sharetechnote.com/html/5G/5G_HARQ.html) supplies a further practical overview.

## 2. Protocol ownership and the executable boundary

**Stage — 3GPP protocol.**

Section 1 gave the sources. This section fixes the boundary: which stages follow the coding specification, which are engineering choices, and the values chosen.

Transmitted CRC, segmentation, LDPC construction and rate matching follow the frozen coding specification. The decoder algorithm, channel, RV ordering, maximum attempts and trial budget are declared implementation choices. 

The following mapping keeps protocol definitions beside actual Toolbox operations.

| Stage | Official source | MATLAB function | Returned evidence |
| --- | --- | --- | --- |
| TB CRC | 38.212 §7.2.1; §5.1 | nrCRCEncode | Payload with CRC |
| Base graph | 38.212 §7.2.2 | nrDLSCHInfo | BGN |
| Segmentation | 38.212 §7.2.3; §5.2.2 | nrCodeBlockSegmentLDPC | Code block matrix |
| LDPC | 38.212 §7.2.4; §5.3.2 | nrLDPCEncode | Encoded blocks |
| Rate matching | 38.212 §7.2.5; §5.4.2 | nrRateMatchLDPC | G transmitted bits |
| Receive alignment | Inverse transmitted mapping | nrRateRecoverLDPC | Encoded-position likelihoods |
| Decode and CRC | Receiver algorithm; CRC §5.1 | nrLDPCDecode; nrCRCDecode | Bits and acceptance |

All 38.212 locators refer to [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). The Base Graph Number (BGN) chooses one of two LDPC graphs. A Code Block (CB) is the independently encoded segment. The Downlink Shared Channel (DL-SCH) coding chain can supply a Physical Downlink Shared Channel (PDSCH); the present Monte Carlo experiment begins at coded modulation symbols, after resource allocation.

The experiment fixes the following inputs.

| Quantity | Value | Reason | Where it applies |
| --- | --- | --- | --- |
| TB length A | 1024 bit | Small reproducible coding example | LDPC chain input |
| Target rate R | 0.5 | Select base graph | Initial coding configuration |
| Transmitted length G | 2048 bit per attempt | Controlled comparison | Rate matched output |
| Modulation | QPSK, one layer | Two bits per symbol | Unit symbol energy |
| RV sequence | 0, 2, 3, 1 | IR comparison | Rate matcher input |
| Decoder | Normalized min-sum; 12 iterations | Explicit algorithm limit | LDPC decoder |
| SNR | −4 to 2 dB in 1 dB steps | Observe initial failure and recovery | QPSK symbol energy |
| Trials | 60 per SNR and method | Teaching uncertainty estimate | Independent TBs |

Quadrature Phase Shift Keying (QPSK) carries two bits per symbol. Signal-to-Noise Ratio (SNR) is referenced to unit transmit symbol energy. Independent complex Additive White Gaussian Noise (AWGN) is added on each attempt. There is no fading, channel-estimation error or feedback loss in this coding experiment.

A scheduled New Radio (NR) Transport Block Size (TBS) is determined through [TS 38.214 V18.10.0, §5.1.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip). The length 1024 here is a coding function setup. The related [[Uni-02-Reference-Signals-Channel-Estimation-and-Equalization|reference and equalization experiment]] does use nrTBS and successfully recovers its scheduled 3,624-bit payload.

## 3. Construct the protected LDPC codeword

**Stage — 3GPP protocol.**

Section 2 fixed the values. This section builds the protected codeword: CRC, segmentation, then the LDPC encoder.

CRC attachment detects residual errors after decoding. Segmentation makes large blocks fit the selected graph dimensions. LDPC parity relates transmitted observations to the same underlying information bits.

### 3.1 Transport CRC and bit lengths

The first step protects the block: this section attaches the CRC and records every bit length.

The full Transport Block (TB) enters its Cyclic Redundancy Check (CRC). For this 1024-bit input, nrDLSCHInfo selects CRC16. The standard chooses the CRC polynomial and length according to [TS 38.212 V18.8.0, §7.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), with polynomial definitions in §5.1.

The generated transport block supplies the information bits against which every decode is checked. The sample below identifies the start of that saved payload before CRC attachment changes its length.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 01 Input bits v2.png]]

*MATLAB result from b.tb: the first 96 of the 1024 random information bits that form the transport block. The whole block remains in run.mat; every later array in this note is a transformation of these bits.*

Applying CRC attachment preserves the payload and appends 16 check bits. Inspect the boundary in the protected block's tail below; the receiver later evaluates those check bits after recovering the complete information block.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 02 CRC attachment v2.png]]

*MATLAB result from b.withCRC: the tail of the protected block, where the dashed marker separates the final 32 payload bits from the 16 CRC bits that nrCRCEncode appended under TS 38.212 §7.2.1. Those 16 bits are what the receiver later uses to accept or reject a decode.*

The baseline block length after CRC is:

$$
\begin{aligned}
B&=A+L\\
&=1024+16=1040\ \mathrm{bit}.
\end{aligned}
$$

Here $A=1024$ bit is the assumed information length, $L=16$ bit is the selected CRC length (Toolbox output following §7.2.1), and $B=1040$ bit is the calculated protected-block length. The sum combines bit counts at the same interface.

The bit table records the dimensions actually returned by the encoder.

| Symbol | Value | Evidence | Where it applies |
| --- | --- | --- | --- |
| A | 1024 bit | Assumed | TB input |
| L | 16 bit | Program output | TB CRC |
| B | 1040 bit | Calculated | Protected block |
| K | 1040 bit | Program output | LDPC input per CB |
| N | 5200 bit | Program output | LDPC output per CB |
| G | 2048 bit | Assumed | Rate matched output |

Counting the returned arrays gives the stage lengths below. The increase during protection and encoding, followed by the reduction during rate matching, explains why transmitted length must be accounted for separately from delivered information.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 03 Encoder lengths v2.png]]

*MATLAB result from b.tb, withCRC, cbs, encoded and rateMatched: bit counts at each stage of the chain. The 1024 information bits become 1040 with CRC, 5200 after LDPC encoding with parity, and 2048 transmitted bits after rate matching to the configured capacity G.*

### 3.2 Base graph, segmentation and filler

Section 3.1 gave the lengths. This section chooses the base graph and shows what happens when a block is too large for one code block.

LDPC base graph selection uses the initial target rate and transport size. It remains associated with retransmissions of the same block [TS 38.212 V18.8.0, §7.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). nrDLSCHInfo returns base graph 2, one code block and lifting size 104 for the baseline.

The size and rate scan applies the graph selection rule to different transport inputs. Compare the regions of the numerical plot with the conditions in the protocol excerpt; graph selection determines which dimensions the segmentation and lifting steps can use.


External source: [7.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.212 V18.8.0, §7.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=120), printed page 119. The transport payload size and coding rate select the LDPC base graph for the initial transmission and retransmissions of the same block.*


![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 06 Base graph choice v2.png]]

*MATLAB result from sizes.BGN: the base graph nrDLSCHInfo selects for each transport length and target rate. Base graph 2 serves small blocks and low rates and base graph 1 the rest, following TS 38.212 §7.2.2; the baseline of 1024 bits at rate 0.5 lands on graph 2.*


Counting the generated code blocks as payload length grows tests the segmentation conditions beside the plot. Increases in the count identify inputs that require separate encoded blocks and the associated code block CRCs.


External source: [5.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.212 V18.8.0, §5.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=14), printed page 13. The maximum code block sizes and code block count determine when segmentation introduces a CRC for each code block.*


![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 05 Segmentation threshold v2.png]]

*MATLAB result from sizes.C at target rate 0.5: the number of code blocks as the transport length grows. Segmentation begins when the protected block exceeds the graph's maximum input, so a 9000-bit block splits into two segments, each with its own CRC24B under §7.2.3.*


The same size scan records the selected lifting size. Its steps show how the encoder moves between allowed dimensions as the payload grows; the unused capacity within those dimensions is measured next as filler.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 07 Lifting size v2.png]]

*MATLAB result from sizes.Zc: the lifting size chosen for each transport length. Only the discrete set of TS 38.212 Table 5.3.2-1 is allowed, so the encoder dimension steps up in jumps as the payload grows.*

Counting filler positions exposes the unused input capacity left by that dimension selection. Read the changes together with the lifting size steps to distinguish padding imposed by the graph from payload or transmitted parity.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 08 Filler count v2.png]]

*MATLAB result from sizes.FillerCount: how many filler bits the encoder inserts to pad the payload up to the next allowed lifting size, summed over all code blocks. Filler bits are known zeros the receiver treats as certain, which is why they appear as infinite likelihoods later.*

The larger setup sends 9000 information bits. It selects CRC24A, base graph 1, two code blocks, lifting size 208, input length 4576 per code block and 40 filler positions per block (program output, large.info). Segmentation adds a CRC24B to each code block when required by [TS 38.212 V18.8.0, §§7.2.3 and 5.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). The high-SNR round trip verifies zero information errors for this segmented setup.

Applying segmentation to the setup with 9000 information bits gives the matrix below. Its separate columns and marked filler positions make the code block dimensions concrete before the matrix is passed to LDPC encoding.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 04 Segmentation matrix v2.png]]

*MATLAB result from large.cbs: the actual 9000-bit setup segmented into two code blocks of 4576 input bits, with 40 filler positions per block marked −1 before encoding. This matrix is what nrLDPCEncode receives in the segmented case.*

### 3.3 Encode once and retain the result

Section 3.2 chose the graph. This section encodes once and keeps the result, because every retransmission will select from it.

The selected graph's parity checks constrain the codeword. The encoder inserts the required parity and handles the punctured positions according to [TS 38.212 V18.8.0, §5.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). nrLDPCEncode returns the encoded matrix used by every subsequent RV.

Encoding the baseline block produces the saved codeword sample below. Subsequent transmissions select observations from this retained array, so changing RV changes the transmitted selection while preserving the underlying transport block.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 09 Encoded bits v2.png]]

*MATLAB result from b.encoded: the first 160 of the 5200 encoded positions, systematic bits followed by parity. Every redundancy version selects its transmitted bits from this one codeword, so nothing is re-encoded on retransmission.*

!note[The receiver's iterative decoder is an engineering implementation. The setup uses normalized min-sum with early termination and a limit of 12 iterations per code block. The saved iterationsPerCB field preserves the actual vector; the scalar iterations field records its maximum. Codeword construction is official, while this iteration budget is not.]

## 4. Select redundancy versions and accumulate evidence

**Stage — MATLAB experiment.**

Section 3 produced one long codeword. This section decides which parts of it to send in each transmission and how the receiver adds the evidence up.

!important[An RV controls where selection begins in the encoded circular buffer. The receiver reverses bit interleaving and selection before combining, so likelihoods for one encoded position meet in one buffer location.]

### 4.1 Rate matching and overlap

The first question is where each transmission starts reading the codeword; this section computes the starting positions and their overlap.

The starting position depends on RV, base graph, lifting size and soft-buffer limit [TS 38.212 V18.8.0, §5.4.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). In the unlimited-buffer baseline, base graph 2 gives:

$$
\begin{aligned}
k_0(\mathrm{RV0})&=0,\\
k_0(\mathrm{RV2})&=
\left\lfloor\frac{25N_{\mathrm{cb}}}{N}\right\rfloor Z_c\\
&=\left\lfloor\frac{25\times5200}{5200}\right\rfloor104\\
&=2600.
\end{aligned}
$$

Here $k_0$ is the zero-based starting encoded position, RV0 and RV2 are redundancy-version labels, $N_{\mathrm{cb}}=5200$ is circular-buffer length, $N=5200$ is encoded-block length, and $Z_c=104$ is lifting size. Floor means the greatest integer no larger than its argument. The constant 25 is the specified base graph 2 coefficient for RV2. All quantities are dimensionless bit-position counts. This example follows the baseline graph and unlimited buffer; it is not a formula for every graph.

Rate recovery of unit likelihoods converts each RV's transmitted selection into a map of encoded positions. Compare where coverage begins with the starting position rule beside it; these maps identify where later soft evidence must be placed before addition.


External source: [5.4.2.1; Table 5.4.2.1-2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.212 V18.8.0, §5.4.2.1; Table 5.4.2.1-2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=33), printed page 32. The redundancy version selects a starting position in the LDPC circular buffer. Rate recovery aligns soft evidence from the selected positions.*


![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 10 RV coverage v2.png]]

*MATLAB result from maps: which encoded positions each redundancy version selects, obtained by rate-recovering unit likelihoods. RV0 starts at position 0 and RV2 at 2600, the k0 values of TS 38.212 §5.4.2.1; filler positions are removed from this diagnostic.*


Counting intersections between those maps gives the pairwise overlap matrix. Nonzero entries away from its diagonal identify evidence that an RV repeats, explaining why an additional version can provide both new positions and further observations of existing ones.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 11 RV overlap v2.png]]

*MATLAB result from maps: the number of encoded positions shared by each pair of redundancy versions. The nonzero off-diagonal counts show that a new RV revisits some bits, so incremental redundancy adds partly new and partly repeated evidence.*

Accumulating the maps in the sequence 0, 2, 3, 1 gives the distinct coverage curve below. Its growth measures how much of the codeword has been visited; decoding experiments are still needed to determine whether the noisy evidence is sufficient for acceptance.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 12 Accumulated coverage v2.png]]

*MATLAB result from maps in the order 0, 2, 3, 1: the fraction of encoded positions observed at least once after each attempt. Coverage grows towards the full codeword; it is an index diagnostic and does not depend on SNR.*

The note compares Incremental Redundancy (IR), using RV sequence 0,2,3,1, with Chase Combining (CC), using 0,0,0,0. A third receiver resets its buffer before each RV in the IR sequence. All methods use the same information bits and initial noise realization at a given seed.

### 4.2 Modulation, noise and soft alignment

Section 4.1 selected bits. This section turns them into symbols, adds noise, and aligns the soft evidence back to encoded positions.

The rate matched sequence becomes unit-energy QPSK symbols using nrSymbolModulate. The noise variance is $10^{-\mathrm{SNR}_{dB}/10}$, where $\mathrm{SNR}_{dB}$ is the declared symbol SNR and the resulting variance is total normalized complex power.

Mapping the rate matched bits to QPSK gives the transmitted constellation below. Its constant symbol energy sets the reference for the noise variance, allowing the received constellation to be interpreted under the declared SNR.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 13 Modulated symbols v2.png]]

*MATLAB result from b.x{1}: the rate-matched bits mapped by nrSymbolModulate onto unit-energy QPSK, with all 1024 symbols stacked on the four constellation points. This is the transmitted alphabet that the noise will spread.*

Adding noise to the symbols produces the saved −3 dB realization below. Observations cross the constellation decision boundaries, exposing the uncertainty that the soft demodulator must retain for later combining.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 14 Noisy symbols v2.png]]

*MATLAB result from f.y{1}: the received symbols of the saved −3 dB realization, with noise variance 10^(0.3) around each QPSK point. Many symbols cross a decision boundary, which is why the first decode fails and why soft combining is needed.*

The demodulator converts those noisy observations into signed likelihoods. The overlap of the bit populations in the histogram shows where a single transmission favors the wrong bit, linking constellation spread to the failed initial decode.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 15 Demodulator LLR v2.png]]

*MATLAB result from f.llr{1}: histogram of the soft demodulator output at −3 dB. Positive values favour bit 0; the overlap of the two populations measures how often noise reverses the evidence for a single transmission.*

The [MathWorks nrRateRecoverLDPC reference](https://www.mathworks.com/help/5g/ref/nrraterecoverldpc.html) documents the inverse mapping and filler treatment. An unobserved encoded position has zero likelihood; a known filler zero is represented by positive infinity. The plots omit filler infinities so they do not compress the finite evidence scale.

Applying rate recovery restores the likelihoods to encoded positions. In the buffer plot, distinguish the occupied evidence region from the flat unobserved region; this is the receiver state available after the initial transmission.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 16 Recovered soft buffer v2.png]]

*MATLAB result from f.recovered{1}: the magnitude of the first transmission's likelihoods, averaged over 40 encoded positions, after nrRateRecoverLDPC places them back at their encoded positions. Evidence exists only where RV0 selected bits, roughly the first 2048 positions; the flat zero beyond them is the part of the codeword this transmission never sent.*

Applying rate recovery to the second transmission and adding its likelihoods at matching positions produces the combined buffer below. Compare its newly occupied region and remaining gap with the initial buffer to see which encoded positions have gained observations before the next decode.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 17 Combined soft buffer v2.png]]

*MATLAB result from f.combined{2}: the same smoothed magnitude after the second transmission with RV2 is rate-recovered and added at aligned positions. The second block of evidence appears around positions 2600 to 4600, and where both RVs observed a bit the magnitude grows; the gap between them is still unobserved.*

For independent observations of the same encoded bit, multiplying conditional likelihoods becomes addition after taking logarithms:

$$
\begin{aligned}
L_i^{(J)}
&=\log\frac{\prod_{j=1}^{J}p(y_j\mid b_i=0)}
{\prod_{j=1}^{J}p(y_j\mid b_i=1)}\\
&=\sum_{j=1}^{J}
\log\frac{p(y_j\mid b_i=0)}{p(y_j\mid b_i=1)}
=\sum_{j=1}^{J}L_{i,j}.
\end{aligned}
$$

Here $i$ selects one encoded bit $b_i$; $j$ selects transmission observation $y_j$; $J$ is the number combined; $p$ is a conditional probability density; $L_{i,j}$ is a dimensionless natural-log likelihood ratio; and $L_i^{(J)}$ is accumulated evidence. The parenthesized superscript labels the attempt count. The binary values zero and one are the competing encoded-bit hypotheses, and observation numbering starts at one. Independence is supplied by the AWGN setup. Missing observations contribute zero evidence. This is the mathematical justification for soft addition.

### 4.3 Decode, check CRC and manage the block

Section 4.2 accumulated evidence. This section decodes after each transmission, checks the CRC, and shows the error count fall to zero.

The saved −3 dB trace reaches the iteration limit during its first two attempts. Its third attempt produces correct bits and a passing transport CRC.

Comparing the first decoded payload with the transmitted block gives the error locations below. Their spread through the payload shows the data corruption behind the initial failed CRC, even though the decoder has produced a complete output array.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 18 First decoding errors v2.png]]

*MATLAB result from f.decoded{1} and f.tb: the 337 information-bit errors of the first decode at −3 dB counted in blocks of 64 bits. The errors are spread over the whole 1024-bit block after the decoder reached its 12-iteration limit; the transport CRC catches this failure, which is what triggers the retransmission.*

!important[Decoding the accumulated buffer after each transmission reduces errors from 337 to 214 to zero. The attempt trace below connects the added soft evidence to recovered payload accuracy for this saved realization.]

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 19 Errors by attempt v2.png]]

*MATLAB result from f.bitErrors: information-bit errors after decoding the complete accumulated buffer at each attempt, 337 then 214 then 0. Each retransmission adds evidence to the same encoded positions until the decoder converges.*

The transport CRC fails twice and then passes on attempts three and four, as recorded below. Comparing this acceptance trace with the error count determines the first usable block and therefore the stopping point for transmission accounting.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 20 CRC decisions v2.png]]

*MATLAB result from f.fail: the transport CRC outcome per attempt, failing twice and passing at the third and fourth. Operational accounting stops after the first pass; the fourth trace is kept only as a diagnostic.*

A New Data Indicator (NDI), when applicable, helps determine whether a received transmission starts a new block or belongs to existing HARQ state. MAC process behavior, including new-transmission handling and soft combining, is specified in [TS 38.321 V18.10.0, §5.3.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip). The setup resets its buffer at the start of each independently generated TB. It assumes correct process association and immediate error-free feedback. A real User Equipment (UE) receiver must obtain that association from its control and process state.

## 5. Compare reliability and transmission cost

**Stage — Measured results.**

Section 4 followed one saved trace. This section repeats the experiment over many blocks and compares the three receivers on reliability and cost.

A retransmission consumes coded-bit resources whether it succeeds or fails. The comparison therefore records initial failure, residual failure after at most four attempts, used attempts and delivered information per coded bit sent.

### 5.1 Initial and residual block error rates

The first comparison is reliability: initial failures, then failures remaining after four attempts.

The experiment tests 60 independent TBs at each of seven SNR values for each of three methods: 1,260 TB-method trials. Four diagnostic decoder attempts are saved per trial, producing 5,040 attempt rows. Within a seed, common data and noise draws support method comparison.

Initial Block Error Rate (BLER) is identical across methods because the first transmission is identical. The initial failure curve supplies a common reference: any later separation between methods arises after they receive or retain additional evidence.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 21 First attempt BLER v2.png]]

*MATLAB result from summary.FirstFailures: block error rate of the first transmission against SNR, identical for all three methods because their first attempt is the same. At 1 dB 51 of 60 blocks fail; at 2 dB none do.*

Residual BLER counts blocks never accepted within four attempts. Compare the combining methods with the receiver that resets its buffer in the plot below; this tests whether retaining aligned evidence changes delivery under the same attempt budget.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 22 Residual BLER v2.png]]

*MATLAB result from summary.ResidualFailures with Wilson bounds: fraction of blocks never accepted within four attempts, per method and SNR. Both combining methods deliver every block at −4 dB while the reset receiver delivers none; the bars show what 60 trials can claim.*

!warning[At −4 dB, both combining methods delivered all 60 TBs, while the reset receiver delivered none (program output). Zero residual errors yields a 95% Wilson interval [0, 0.060172], and 60 errors yields [0.93983, 1]. These sample sizes do not establish high-reliability service at rare-error levels.]

The interval is computed with the same binomial expression for every method:

$$
p_{\pm}=
\frac{\widehat p+z^2/(2N_T)\pm
z\sqrt{\widehat p(1-\widehat p)/N_T+z^2/(4N_T^2)}}
{1+z^2/N_T}.
$$

Here $\widehat p=E/N_T$ is the measured residual error fraction, $E$ is the failed-TB count, $N_T=60$ is the trial count and $z=1.95996398454$ gives nominal 95% coverage. $p_-,p_+$ are dimensionless probability bounds. The constants 1, 2 and 4 result from solving the Bernoulli score inequality; they are not tuning parameters. Roundoff of order $10^{-17}$ at the lower endpoint is displayed as zero.

### 5.2 Goodput and attempts

Section 5.1 counted failures. This section charges the attempts and computes what each method delivers per coded bit.

Delivered information is divided by all coded bits actually charged before acceptance or exhaustion. The −4 dB IR result gives a complete numerical example:

$$
\begin{aligned}
\eta&=\frac{A N_{\mathrm{success}}}{G N_{\mathrm{attempts}}}\\
&=\frac{1024\times60}{2048\times185}\\
&=0.162162\ \mathrm{information\ bit/coded\ bit}.
\end{aligned}
$$

Here $\eta$ is resource-normalized goodput; $A=1024$ bit and $G=2048$ bit are engineering inputs; $N_{\mathrm{success}}=60$ TB and $N_{\mathrm{attempts}}=185$ are measured program counts from the −4 dB IR summary row. The ratio is dimensionless with distinct numerator and denominator roles. It excludes control, pilot and cyclic-prefix overhead.

The resource table makes the comparison auditable.

| Quantity | IR at −4 dB | Chase at −4 dB | Evidence |
| --- | --- | --- | --- |
| Accepted TBs | 60 | 60 | summary.Delivered |
| Charged attempts | 185 | 239 | summary.TotalAttempts |
| Mean attempts | 3.0833 | 3.9833 | summary.MeanAttempts |
| Goodput | 0.162162 | 0.125523 | summary.GoodputBitsPerCodedBit |

Applying the resource accounting to each SNR gives the goodput curves below. Their separation measures a delivery cost that residual BLER alone cannot reveal when both combining methods recover the tested blocks.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 23 Goodput v2.png]]

*MATLAB result from summary.GoodputBitsPerCodedBit: delivered information bits per coded bit charged. The 0.5 ceiling is A/G with one attempt; incremental redundancy stays above Chase combining at low SNR because it needs fewer attempts for the same delivery.*

The mean attempt curves expose the transmission counts behind that goodput difference. Compare their ordering with the goodput curves: more charged attempts consume additional coded resources for the delivered payload.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 24 Attempts v2.png]]

*MATLAB result from summary.MeanAttempts: average number of charged transmissions per block. A failed block still costs at least one attempt; at −4 dB incremental redundancy averages 3.08 attempts and Chase combining 3.98 to deliver the same 60 blocks.*

The −3 dB IR histogram resolves the trial distribution behind its mean of three attempts. The occupied bins show how service cost varies among blocks; the final bin must be interpreted with the acceptance record because it can also contain exhausted trials.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 26 Service distribution v2.png]]

*MATLAB result from trials.UsedAttempts at −3 dB with incremental redundancy: histogram of how many attempts each of the 60 blocks needed. The mean of three hides this spread; the last bin would hold both accepted and exhausted blocks.*

At −2 dB, IR uses 123 attempts and Chase uses 171 to deliver the same 60 TBs. At −1 dB and 0 dB, both use 120 attempts. The measured advantage depends on the selected rate, RV overlap, noise and stopping rule. These coding curves cannot be converted into radio bit/s without a stated allocation duration and overhead model.

### 5.3 Decoder effort and limits of the sample

Section 5.2 compared methods at a fixed decoder budget. This section changes only the decoder effort and states the limits of the sample.

The decoder iteration limit can change acceptance when the same observations are reused. This supplement keeps one −1 dB realization fixed and changes only the iteration ceiling.

Reusing the fixed observations while changing the iteration ceiling gives the acceptance comparison below. A changed outcome here is caused by decoder effort, so it must be distinguished from the benefit of additional transmitted observations measured in the HARQ scan.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - 25 Iteration limit v2.png]]

*MATLAB result from iterScan: one fixed −1 dB realization decoded with different iteration ceilings. Acceptance changes with decoder effort alone, separating what more iterations buy from what more transmitted evidence buys; one realization is a diagnostic.*

!warning[The Monte Carlo tests use a fixed target rate, block length and normalized min-sum decoder. They do not validate link adaptation, a multi-process scheduler, finite feedback delay, control errors, fading or soft-buffer limits. The deterministic 9000-bit case verifies segmentation and desegmentation, but its high-SNR success is not a large-block reliability estimate.]

## 6. Reproduce the coding chain and manage its state

**Stage — Reproduce and references.**

Section 5 reported numbers. This section says how to reproduce them and how the receiver's state must be managed.

A useful HARQ experiment must retain encoded-position evidence and charge only attempts that its acceptance rule would actually use. The delivered scripts preserve both the full diagnostic trace and the operational stopping count.

### 6.1 Exact run and acceptance checks

The run identifier, software versions and saved fields behind every number above.

The accepted run is run-20260907-120612. It used MATLAB R2026a Update 4, version 26.1.0.3312084, and 5G Toolbox 26.1. Random generation uses twister with every trial seed saved. The initial high-SNR setup passes CRC and has zero bit errors. The −8 dB test setup fails its first CRC. The segmented 9000-bit setup also passes its high-SNR round trip.

From the course root, add matlab/uni05 to the MATLAB path and run run_uni05. The entry point runs test_uni05 before the experiment. A new timestamped directory contains the MAT arrays, trial and summary CSV files, deterministic segmentation scan, software/configuration JSON, MATLAB log, figure catalog, source snapshot and SHA-256 hashes.

The table below maps each result to an explicit substitution or saved program output.

| Result | Saved field or file | Derivation | Where it applies |
| --- | --- | --- | --- |
| Coding dimensions | b.info; segmentation.csv | nrDLSCHInfo and encoder | CB arrays |
| Saved failure | f.bitErrors; f.fail | Actual decoder and CRC | 1024 information bits |
| BLER and intervals | summary.csv | CRC outcomes and Wilson formula | Independent TBs |
| Goodput | summary.csv | §5.2 substitution | Information/coded bits |
| Figure arrays | visual-review/figures/catalog.json | Named fields in run.mat | Plot-specific |
| Code identity | source-hashes.json | SHA-256 of source snapshot | Exact executed files |

The helper performs all four attempts to preserve diagnostic arrays. UsedAttempts is the index of the first successful CRC, or four when none succeeds. Only those charged attempts enter goodput; later diagnostic decodes do not represent scheduled transmissions.

The published numerical plots are v2 exports from saved arrays in run-20260907-120612/visual-review. The plotting source is retained there with its own SHA-256 manifest. Re-exporting did not change the Monte Carlo results.

### 6.2 Implementation flow and integration boundary

Section 6.1 gave the evidence; this section draws the implementation flow and names the boundary to the next experiment.

The closing flow connects the official bit construction to receiver evidence accumulation and the measured resource ratio.

![[99 Attachments/5G/Uni Labs/Uni-05/Uni-05 - Engineering Flow v1.png]]

*Original schematic: encoding and rate selection follow TS 38.212 V18.8.0 §§7.2.1–7.2.5 and §5.4.2.1. Aligned LLR addition and goodput are the receiver and evaluation equations explained above. The RV subscripts in the drawing identify two generic transmission selections; the actual experiment uses 0,2,3,1.*

A successful coded block can be passed to a later PDSCH waveform experiment with its TB identity and CRC outcome. Receiver state must be cleared for a new TB and retained only for transmissions associated with the same process and block. The MAC interpretation remains anchored to [TS 38.321 V18.10.0, §5.3.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

These sources support the transmitted definitions, receiver implementation and course connections used in the experiment.

### 7.1 References

The source versions below match the frozen protocol manifest; web implementation pages were checked on 2026-09-07.

- 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), §§5.1, 5.2.2, 5.3.2, 5.4.2, 7.2.1–7.2.6.
- 3GPP, [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip), §5.1.3.2.
- 3GPP, [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), §5.3.2.2.
- MathWorks, [nrRateRecoverLDPC](https://www.mathworks.com/help/5g/ref/nrraterecoverldpc.html), rate recovery and filler representation.
- ShareTechnote, [HARQ](https://www.sharetechnote.com/html/5G/5G_HARQ.html), secondary process overview.
- Dahlman, Parkvall and Sköld, 5G NR: The Next Generation Wireless Access Technology, second edition, Chapter 13; [[Star-13-Retransmission-Protocols|Chapter 13]].
- Course sources: [[Star-09-Transport-Channel-Processing|Transport Channel Processing]], [[Star-10-Physical-Layer-Control-Signaling|Physical Layer Control Signaling]], [[Star-13-Retransmission-Protocols|Retransmission Protocols]], [[Star-14-Scheduling|Scheduling]], [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding|TS 38.212 Multiplexing and Channel Coding]], [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data|TS 38.214 Physical Layer Procedures for Data]], [[Star-33-TS-38.321-Medium-Access-Control|TS 38.321 Medium Access Control]].
- Companion experiment: [[Uni-02-Reference-Signals-Channel-Estimation-and-Equalization|Reference and equalization experiment]].

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.212 V18.8.0, §7.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=120); [TS 38.212 V18.8.0, §5.2.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=14); [TS 38.212 V18.8.0, §5.4.2.1; Table 5.4.2.1-2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf#page=33). Accessed 2026-09-08.

### 7.2 Abbreviation index

The shared [[5G Abbreviation Database]] provides course-wide lookup.

| Abbreviation | Full term |
| --- | --- |
| AWGN | Additive White Gaussian Noise |
| BGN | Base Graph Number |
| BLER | Block Error Rate |
| CB | Code Block |
| CC | Chase Combining |
| CRC | Cyclic Redundancy Check |
| DCI | Downlink Control Information |
| DL-SCH | Downlink Shared Channel |
| HARQ | Hybrid Automatic Repeat Request |
| IR | Incremental Redundancy |
| LDPC | Low-Density Parity-Check |
| LLR | Log Likelihood Ratio |
| MAC | Medium Access Control |
| NDI | New Data Indicator |
| NR | New Radio |
| PDSCH | Physical Downlink Shared Channel |
| QPSK | Quadrature Phase Shift Keying |
| RLC | Radio Link Control |
| RV | Redundancy Version |
| SNR | Signal-to-Noise Ratio |
| TB | Transport Block |
| TBS | Transport Block Size |
| UE | User Equipment |

### 7.3 Mathematical and physical symbol index

Bit counts, position indices and likelihoods have distinct roles in this experiment.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $A,L,B$ | Information, CRC and protected-block lengths | bit |
| $K,N,G$ | LDPC input, encoded length and transmitted length | bit |
| $N_{\mathrm{cb}},Z_c,k_0$ | Circular buffer, lifting size and start index | Counts |
| $i,j,J$ | Encoded bit, observation and attempt count | Integer indices |
| $b_i,y_j,p$ | Bit, observation and conditional density | Binary; complex; density |
| $L_{i,j},L_i^{(J)}$ | Individual and accumulated likelihood ratio | Dimensionless |
| $E,N_T,\widehat p$ | Failed TBs, tested TBs and error fraction | Counts; probability |
| $z,p_-,p_+$ | Normal quantile and Wilson interval | Dimensionless |
| $\eta$ | Delivered information per coded bit | bit/bit |
| $N_{\mathrm{success}},N_{\mathrm{attempts}}$ | Accepted blocks and charged attempts | Counts |
