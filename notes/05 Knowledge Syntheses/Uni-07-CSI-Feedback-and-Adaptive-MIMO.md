---
type: knowledge_synthesis
title: Uni-07 — Channel state information, feedback and adaptive MIMO
language: en
uni: 7
release_baseline: 18
cssclasses:
- research-note-tables
---

# Uni-07 — Channel state information, feedback and adaptive MIMO

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

!important[Channel State Information (CSI) describes the channel that a transmitter can use when choosing spatial weights, the number of layers and a modulation. Multiple Input Multiple Output (MIMO) transmission makes these choices consequential: two antennas do not guarantee two useful data streams. This experiment transmits an actual CSI Reference Signal (CSI-RS), estimates a complex channel, selects a finite precoder and decodes a Physical Downlink Shared Channel (PDSCH).]

The system map follows the measurement and data paths through separate reference signals.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - System Overview v1.png]]

*Original system schematic. CSI-RS informs the transmitter's spatial choice. The Demodulation Reference Signal (DMRS) in the data transmission estimates the effective channel used by the receiver. The two measurements serve different decisions.*

## 1. Knowledge sources and engineering objective

**Stage — Textbook workflow.**

The overview above separated the measurement path from the data path. This section says what the experiment connects and which notes supply each piece.

The objective is to connect a standardized reference signal and codebook to measurable delivered payload. The experiment separates loss from noisy estimation, finite precoder choices and an old precoder report, then tests a local rank selection rule.

These source notes supply distinct parts of the implementation.

| Source | Contribution | Experiment interface |
| --- | --- | --- |
| [[Star-08-Channel-Sounding\|Channel sounding]] | Measurement resources and channel information | Two CSI-RS ports |
| [[Star-11-Multi-Antenna-Transmission\|Multiple antenna transmission]] | Layers, ports and precoding | Complex 2 × 2 matrices |
| [[Star-12-Beam-Management\|Beam management]] | Measurement age and spatial choice | Current and delayed precoder index |
| [[Star-14-Scheduling\|Scheduling]] | Convert reports into a data allocation | Rank and modulation decisions |
| [[Star-29-TS-38.211-Physical-Channels-and-Modulation\|Physical channels]] | Reference symbols, resource mapping and modulation | Actual resource grids and samples |
| [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data\|Data procedures]] | CSI codebooks and transport size | Two port codebook and nrTBS |

The Chapter 11 and Chapter 12 notes of this knowledge base ([[Star-11-Multi-Antenna-Transmission|Star-11]] and [[Star-12-Beam-Management|Star-12]]) supply the conceptual route. Here the port weights, estimated arrays and decoded blocks make that route executable. 

The frozen Third Generation Partnership Project (3GPP) specifications determine the implemented signal and codebook.

| Source | Exact version | Clause or table | Used here |
| --- | --- | --- | --- |
| [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 18.9.0 | 7.4.1.5.3; Table 7.4.1.5.3-1, row 3 | Two port CSI-RS mapping |
| [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 18.10.0 | 5.2.2.2.1; Table 5.2.2.2.1-1 | Type I single panel, two port codebook |
| TS 38.211 | 18.9.0 | 7.3.1; 7.4.1.1; 5.3.1 | PDSCH, DMRS and OFDM waveform |
| [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 18.8.0 | 7.2 | Downlink shared channel coding |
| TS 38.214 | 18.10.0 | 5.1.3 | Modulation, code rate and transport block size |

## 2. Measurement model and implementation boundary

**Stage — 3GPP protocol.**

Section 1 gave the sources. This section fixes the model: antennas, grid, channel, ageing, and what the experiment does not implement.

The experiment has two transmit ports and two receive antennas, one resource allocation and a channel that is constant over each slot and across its subcarriers. A resource block (RB) contains 12 subcarriers; six RB produce 72 active subcarriers. Orthogonal Frequency Division Multiplexing (OFDM) uses 30 kHz spacing, normal cyclic prefix and 14 symbols per 0.5 ms slot. [TS 38.211 V18.9.0, §§4.2–4.4 and 5.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) owns these waveform definitions.

The script uses separate measurement and data slots. It reserves 1 ms per data attempt: one 0.5 ms measurement slot and one 0.5 ms data slot. Delayed feedback is pipelined from a previous measurement; the four slot age does not add four idle slots to this accounting. The resulting goodput includes this explicit measurement allocation. It excludes control channel and encoded feedback overhead.

The configuration is small enough to inspect every intermediate dimension. The Signal to Noise Ratio (SNR) sweep uses the normalized reference described in §7.1.

| Quantity | Value | MATLAB configuration | Interpretation |
| --- | --- | --- | --- |
| Grid | 6 RB; 30 kHz; cell identity 7 | nrCarrierConfig | Assumed carrier |
| CSI-RS | Row 3; density one; symbol 6; subcarrier 0 | nrCSIRSConfig | Standard mapping, chosen location |
| Antennas | 2 transmit; 2 receive | H is 2 × 2 | Assumed channel size |
| Channel evolution | ρ = 0.9; age 4 slots | cfg.rho; cfg.delaySlots | Local correlation model |
| Noise reference | −5, 0, 5, 10, 15, 20 dB | cfg.SNRdB | Assumed sweep |
| Code rate | 0.48 | nrDLSCH; nrTBS | Chosen target rate |
| Trials | 24 per SNR and mode | cfg.nTrials | 720 decoded blocks |
| Random generator | Seed 7007, twister | rng | Reproducible sequence |

The [MathWorks CSI reporting example](https://www.mathworks.com/help/5g/ug/5g-nr-downlink-csi-reporting.html) supplies a broader report workflow. This local experiment implements the two port precoder subset explicitly. It does not encode Uplink Control Information (UCI), produce a full standardized Channel Quality Indicator (CQI) report, simulate a control channel, track an analog beam or perform beam failure recovery. The feedback index is passed as an integer inside MATLAB. Rank and modulation rules below are stated local assumptions.

### 2.1 Define the channel and measurement age

The first definition is the channel and how it ages between measurement and use.

Let H have receive antennas on rows and transmit ports on columns. With a column vector of transmitted symbols x, the receiver sees

$$\mathbf y=\mathbf H\mathbf x+\mathbf n.$$

The script represents waveform samples on rows, so the corresponding multiplication is `rx = tx*H.' + noise`. The dot transpose preserves the physical complex coefficients; conjugating H would change the channel.

The old channel H₀ and the innovation E have independent circular complex Gaussian entries with mean zero and unit mean squared magnitude. The current channel is

$$\mathbf H=\rho^d\mathbf H_0+\sqrt{1-\rho^{2d}}\,\mathbf E,
\qquad \rho=0.9,\quad d=4.$$

Thus the element correlation is 0.9⁴ = 0.6561 after 2 ms. This is a controlled correlation model. No speed, Doppler spectrum, delay spread, path geometry or blockage process has been inferred from ρ. Those would require a different channel model and additional parameters.

### 2.2 Estimate CSI from transmitted samples

Section 2.1 defined the channel. This section estimates it from transmitted reference samples.

The orthogonal weights define how the reference ports share resources. Channel estimation and averaging remain receiver choices.

External source: [7.4.1.5.3; Table 7.4.1.5.3-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.1.5.3; Table 7.4.1.5.3-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=140), printed page 139. FD-CDM2 assigns two orthogonal frequency weights to separate the reference ports before channel estimation.*

The least squares idea divides received reference symbols by known transmitted symbols, or solves a matrix system when several ports are present. In compact notation, after separating the reference ports,

$$\widehat{\mathbf H}=\mathbf Y\mathbf X^{\mathsf H}
(\mathbf X\mathbf X^{\mathsf H})^{-1}.$$

This expression explains identifiability. The actual receiver uses `nrChannelEstimate`, including Frequency Domain Code Division Multiplexing (FD-CDM2), interpolation and averaging. It does not substitute H for its estimate. The CSI-RS port mapping and CDM structure come from [TS 38.211 V18.9.0, §7.4.1.5.3, Table 7.4.1.5.3-1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

```matlab
csirs = nrCSIRSConfig(NumRB=6,RowNumber=3, ...
    SymbolLocations=6,SubcarrierLocations=0,Density='one');
ci = nrCSIRSIndices(carrier,csirs);
cs = nrCSIRS(carrier,csirs);
cg = nrResourceGrid(carrier,2);
cg(ci) = cs;
[ct,oi] = nrOFDMModulate(carrier,cg,Windowing=0);
[hh,nn] = nrChannelEstimate(carrier,yg,ci,cs,CDMLengths=[2 1]);
Hm = squeeze(mean(mean(hh,1),2));
```

!warning[The final averaging is valid for this frequency flat, static slot model. It would erase useful frequency selectivity in a channel with resolvable delay spread. `nn` is estimated but does not drive the local modulation rule; that rule uses the configured noise reference and Hm. The PDSCH receiver independently estimates its effective channel and noise from DMRS.]

The selected CSI-RS row determines where the transmitter inserts known symbols. Compare the protocol row with the occupied column in the generated port grid before interpreting the receiver estimate; this checks the measurement resources on which the later spatial decision depends.


External source: [7.4.1.5.3; Table 7.4.1.5.3-1, rows 1-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.1.5.3; Table 7.4.1.5.3-1, rows 1-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=139), printed page 138. The first three rows of the CSI-RS location table include the laboratory choice: row 3, two ports and FD-CDM2. Density one is selected from the permitted values.*


![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - CSI resource grid v2.png]]

*MATLAB output from CSIgrid: the nonzero CSI-RS resource elements on transmit port one in the 72 by 14 grid. Row 3 of TS 38.211 Table 7.4.1.5.3-1 places the two-port signal in one symbol with density one; plot indices are one based, so configured symbol 6 appears at column 7.*


The estimator expands the received reference symbols into a channel value at every grid position for each receive antenna and port. Since the simulated channel is constant across this grid, the variation below is estimation and interpolation noise; averaging it produces the matrix used for precoder selection.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - CSI estimated channel grid v2.png]]

*MATLAB output from Hgrid: magnitude of the saved 72 by 14 estimate for receive antenna one and port one at 10 dB. The true channel is constant over the slot, so all variation is estimation and interpolation noise, which is then averaged into the single matrix Hm.*

## 3. Convert CSI into weights, rank and modulation

**Stage — 3GPP protocol.**

Section 2 produced an estimate. This section turns it into a precoder, a rank and a modulation.

The Precoding Matrix Indicator (PMI) identifies a permitted matrix. A finite set constrains the spatial directions the transmitter can use. Singular Value Decomposition (SVD) supplies useful comparison weights, but it does not itself constitute the finite report in this experiment.

### 3.1 Construct the actual two port codebook

The first choice is the finite set of precoders; this section builds the two-port codebook from the standard's table.

For rank one, [TS 38.214 V18.10.0, §5.2.2.2.1, Table 5.2.2.2.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) gives the four columns

$$
\mathbf W_1=\frac{1}{\sqrt2}
\begin{bmatrix}1&1&1&1\\1&j&-1&-j\end{bmatrix}.
$$

Column numbers in MATLAB are 1 to 4; reported PMI values are 0 to 3. Every column has squared norm one. Both ports have equal magnitude, with four relative phases. The script's selection rule is

$$p^*=\arg\max_{p\in\{0,1,2,3\}}
\|\widehat{\mathbf H}\mathbf w_p\|_2^2.$$

This maximizes estimated received signal power for a single layer under the stated noise and channel model. It is a local selection criterion over a standard codebook. It does not implement every CSI reporting hypothesis, interference measurement or codebook restriction allowed by §5.2.

The complex weight plot checks the implementation against the permitted columns in the protocol table. The coincident entries on the first port and differing phases on the second explain exactly what changes when the transmitter applies another PMI.


External source: [5.2.2.2.1; Table 5.2.2.2.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.214 V18.10.0, §5.2.2.2.1; Table 5.2.2.2.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf#page=110), printed page 109. The two port codebook defines the four permitted columns for one layer. Maximizing estimated received power over these columns is the laboratory selection rule.*


![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Codebook weights v2.png]]

*MATLAB output from W: the complex entries of the four rank-one columns of TS 38.214 Table 5.2.2.2.1-1. The first port carries the same weight in every column, so those points coincide; the second port takes the four phases 1, j, −1 and −j that the PMI selects between.*


!note[The ideal precoder comparator uses the dominant right singular vector of the true H. The measured SVD comparator uses Hm. In both cases, modulation still uses measured Hm and reception still estimates the effective channel from noisy DMRS. “Ideal SVD” in the plot legends therefore means an ideal precoder.]

### 3.2 Define the five implemented modes

Section 3.1 gave the codebook. This section defines the five modes the experiment compares.

The comparisons hold carrier size, target code rate and total precoder norm fixed.

| Plot mode | Spatial information | Applied weights | Other decisions |
| --- | --- | --- | --- |
| Ideal SVD | True current H | Dominant right singular vector | Measured quality, practical receiver |
| Measured SVD | Current CSI-RS estimate | Dominant estimated vector | Local modulation rule |
| Current PMI | Current CSI-RS estimate | Best of four rank one columns | Local modulation rule |
| Delayed PMI | Old CSI-RS estimate | Old selected column | Fresh Hm for modulation |
| Adaptive rank | Current CSI-RS estimate | Rank one PMI or rank two matrix | Local rank and modulation rules |

!important[The delayed mode ages only PMI. A fresh channel estimate still evaluates its modulation quality. This isolates the cost of stale spatial weights and understates the problem of delaying the entire CSI report. Current and delayed channels are shared across modes, while encoded data and noise are independently drawn as the script advances its random sequence. The resulting comparison uses matched channels.]

### 3.3 Make rank and modulation decisions explicit

Section 3.2 named the modes. This section states the local rules for rank and modulation so that nothing in the results is hidden.

The experiment switches to two layers only when the estimated weaker singular mode exceeds a local threshold:

$$
\frac{10^{\mathrm{SNR}/10}\,\sigma_{\min}^2(\widehat{\mathbf H})}{2}>5.
$$

For two layers it applies the first rank two matrix in the same standard table,

$$\mathbf W_2=\frac12\begin{bmatrix}1&1\\1&-1\end{bmatrix},
\qquad\|\mathbf W_2\|_F^2=1.$$

The normalization shares total signal power over the two layers. This script fixes rank two PMI at zero; it does not search both rank two matrices. The scalar 5 is an experimental threshold.

The local predicted quality and modulation rule are

$$\widehat\gamma_{\mathrm{dB}}=\mathrm{SNR}_{\mathrm{dB}}
+10\log_{10}\frac{\|\widehat{\mathbf H}\mathbf W\|_F^2}{L},
\qquad
Q_m=\begin{cases}4,&\widehat\gamma_{\mathrm{dB}}>12,\\2,&\text{otherwise.}\end{cases}$$

Here L is the number of layers. Quadrature Phase Shift Keying (QPSK) carries two coded bits per symbol and 16 Quadrature Amplitude Modulation (16QAM) carries four. The 12 dB switch and fixed target code rate 0.48 are teaching choices. They do not reproduce a complete Modulation and Coding Scheme (MCS) table or claim a target block error probability. `nrTBS` applies transport size processing using the selected modulation, number of layers and available resources; [TS 38.214 V18.10.0, §5.1.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) owns that procedure.

## 4. Follow one actual array through the receiver

**Stage — MATLAB experiment.**

Section 3 fixed the rules. This section follows one saved array through them, matrix by matrix.

The saved representative at SNR 10 dB, trial 1, Current PMI contains these rounded matrices:

$$
\mathbf H=\begin{bmatrix}
-0.9829-0.1314j&-0.8315+0.6135j\\
0.0725-0.3983j&-0.1479+0.6968j
\end{bmatrix},\quad
\widehat{\mathbf H}=\begin{bmatrix}
-1.0033-0.1654j&-0.8595+0.5631j\\
0.0399-0.3440j&-0.1297+0.6216j
\end{bmatrix}.
$$

PMI 1 selects [1, j]ᵀ/√2. The normalized squared estimation error is 0.0054706, the true received power gain is 2.0819 and the predicted quality is 13.082 dB. The script chooses one layer, 16QAM and 1544 payload bits. The Cyclic Redundancy Check (CRC) passes and the saved bit error count is zero. This one successful trial contributes 1.544 Mbit/s under the 1 ms allocation rule.

The coefficient comparison puts the true, current measured and old measured channels beside each other for this successful trial. Their differences do not force a different finite index: the same column can remain the preferred choice across a range of channel estimates.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Channel matrix comparison v2.png]]

*MATLAB output from reps{8}: magnitudes of the four entries of the true channel H, the current estimate Hm and the old estimate Hold in column order for the 10 dB representative. The three differ in every entry although this trial selects the same PMI from both estimates.*

The stored dimensions identify which operations act on symbols and which act on samples.

| Saved object | Actual dimensions | Meaning | Next operation |
| --- | --- | --- | --- |
| CSIgrid | 72 × 14 × 2 | Subcarrier, symbol, transmit port | OFDM modulation |
| Hgrid | 72 × 14 × 2 × 2 | Subcarrier, symbol, receive antenna, port | Average to Hm |
| w | 2 × L | Port by data layer | Apply to layer grid |
| tx and rx | 1920 × 2 each | Complex waveform samples | Channel and OFDM demodulation |
| eq, rank one | 792 × 1 | Equalized data symbols | Soft demodulation and decoding |

PDSCH DMRS shares the applied precoder with the data. The receiver estimates that effective channel, extracts allocated resource elements, applies Minimum Mean Square Error (MMSE) equalization and forms soft bits. `nrDLSCHDecoder` uses at most 12 Low Density Parity Check (LDPC) iterations. The CRC supplies the block outcome. [TS 38.211 V18.9.0, §§7.3.1 and 7.4.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) defines the signal mapping; [TS 38.212 V18.8.0, §7.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) defines the channel coding.

## 5. Interpret measured estimation, feedback and payload results

**Stage — Measured results.**

Section 4 followed one trial. This section reads the statistics across the sweep: estimation, feedback, rank, and delivered payload.

Every plot below comes from `run_uni07.m` and its saved trial arrays. A point uses 24 blocks. Block Error Rate (BLER) is failed blocks divided by attempted blocks. Payload goodput is the sum of payload bits whose CRC passes, divided by the reserved time. Root Mean Square (RMS) Error Vector Magnitude (EVM) compares the equalized complex symbols with the actual transmitted data symbols. The Normalized Mean Squared Error (NMSE) divides squared channel estimation error by squared true channel magnitude.

### 5.1 Estimation error and effective channel power

The first statistic is the measurement itself: how far the estimate is from the true channel.

The SNR sweep first tests the measurement that supplies every spatial rule. Falling mean NMSE below shows that the CSI-RS estimate approaches the simulated channel as noise decreases; overlapping mode curves reflect their shared estimate.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - NMSE v2.png]]

*MATLAB output from results.NMSE: mean normalized squared error of the CSI-RS channel estimate against SNR, 0.094 at 0 dB and 0.00085 at 20 dB. All modes reuse the same estimate per trial, so their curves overlap by construction.*

Applying each selected weight to the true current channel gives the collected power below. Compare current PMI with measured SVD for the effect of restricting the available weights, then compare current and delayed PMI for the cost of retaining an old spatial choice.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Gain v2.png]]

*MATLAB output from results.Gain: mean squared norm of H times the applied weights, the channel power the chosen precoder collects. At 10 dB the ideal SVD collects 3.90, the current PMI 3.37 and the delayed PMI 2.72; for two layers the plot sums both layers.*

The following three empirical Cumulative Distribution Functions (CDFs) retain the spread across individual channel trials. At the lowest displayed SNR, compare gains at a common cumulative probability to see how estimation, the finite codebook and feedback age affect different parts of the sample.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Gain CDF SNR 0 v2.png]]

*MATLAB output from trials.Gain at 0 dB: empirical distribution of the 24 collected gains for ideal, current and delayed weights. The gap between the curves combines the finite codebook, noise in the report and channel evolution during the 2 ms age.*

With a cleaner current estimate, the next distribution tests whether a finite set of phases can collect the same power as the ideal precoder. A remaining gap for some channels reflects the restriction on available spatial weights.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Gain CDF SNR 10 v2.png]]

*MATLAB output from trials.Gain at 10 dB: the current finite codebook still sits below the ideal comparator for some channel directions. Better estimation cannot create a weight that the four-column codebook does not contain.*

At the highest displayed SNR, compare delayed PMI with current PMI after the measurement error has fallen. Their remaining separation shows why increasing reference signal quality cannot repair a spatial report that describes an older channel.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Gain CDF SNR 20 v2.png]]

*MATLAB output from trials.Gain at 20 dB: the delayed weights keep their gain penalty although the current measurement is now accurate. Higher SNR removes estimation error but does not remove measurement age.*

### 5.2 Quantization and delayed index decisions

Section 5.1 measured the estimate. This section looks at the index it produces and how often an old index still agrees.

Each histogram counts selected current indices; it is a diagnostic for the codebook selection rule. The first histogram checks which phase choices the noisy measurements select across the saved channel trials.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI SNR 0 v2.png]]

*MATLAB output from trials.PMI at 0 dB in current-PMI mode: how often each of the four indices was selected in 24 trials. The indices are discrete phase choices around the unit circle.*

Matching each old index to its current counterpart produces the count matrix below. Read diagonal cells as agreement and off diagonal cells as changes arising from measurement noise and channel evolution together.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI agreement SNR 0 v2.png]]

*MATLAB output from trials.DelayedPMI against trials.PMI at 0 dB: counts of old versus current index for the same channel pair. Diagonal cells are agreement; off-diagonal cells come from both noise in the old report and channel evolution.*

The intermediate SNR histogram repeats the selection check on the channels drawn at that sweep point. Unequal counts describe this finite sample's use of the codebook and cannot establish a preferred phase for the channel population.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI SNR 10 v2.png]]

*MATLAB output from trials.PMI at 10 dB: the phase choices favoured by the realized channels in this sample. Twenty-four trials show which columns were used; they do not establish a population preference.*

The corresponding count matrix identifies which phase choices changed. Interpret these cells alongside the gain distributions: different index changes need not incur the same loss of collected channel power.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI agreement SNR 10 v2.png]]

*MATLAB output at 10 dB: the count matrix localizes which index changed into which, instead of treating PMI as a continuous error. Index 0 and index 3 are neighbouring phases, so a change between them costs less gain than a change across the circle.*

The final histogram records the current choices when estimation noise is small. Its counts still depend on the new channel realizations at this SNR, so changes from the earlier histograms are not a controlled effect of noise alone.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI SNR 20 v2.png]]

*MATLAB output from trials.PMI at 20 dB: current index counts for a new set of random channels from the recorded sequence. With accurate estimates the selection reflects the channel alone.*

Off diagonal entries remain in the final agreement matrix despite the accurate current measurement. Together with the delayed gain distribution, they connect channel evolution to a stale precoder choice; the modulation rule still uses fresh measured quality.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - PMI agreement SNR 20 v2.png]]

*MATLAB output at 20 dB: off-diagonal counts remain even at high measurement quality, because the 2 ms age with correlation 0.656 changes the channel between the old and the current report.*

### 5.3 Rank, modulation and received constellations

Section 5.2 covered the index. This section covers rank and modulation, and the constellations they produce.

The script applies the local threshold to the weaker estimated singular mode in each trial. The mean rank curve records how often that test admits another layer; its rise is the mechanism by which the adaptive mode can carry more payload.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - MeanRank v2.png]]

*MATLAB output from results.MeanRank: average number of layers per mode against SNR. The adaptive mode rises from 1.125 at 10 dB to 1.79 at 20 dB as the weaker singular mode passes the local threshold; every other mode holds rank one.*

The applied weights also enter the predicted quality used to choose modulation. Compare the delayed and current PMI curves below: fresh quality estimation can lower the modulation when the old weights collect less power, even though the delayed spatial choice is retained.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - MeanQm v2.png]]

*MATLAB output from results.MeanQm: mean coded bits per symbol, between 2 for QPSK and 4 for 16QAM. At 10 dB the delayed mode averages 3.5 because stale weights lower the predicted quality on some trials, while current PMI reaches 16QAM on every trial.*

The next three constellations hold the current PMI algorithm fixed and show individual saved realizations at different noise references. The first has substantial spread at the equalizer output; its selected modulation and CRC are needed to interpret that spread as a transport result.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Received constellation SNR 0 v2.png]]

*MATLAB output from reps{3}.eq: equalized data symbols of the first current-PMI trial at 0 dB. The heavy spread should be read together with this trial's channel, QPSK modulation and CRC outcome.*

The intermediate constellation is the successful representative traced through the channel matrices earlier. Visible errors around the selected modulation points coexist with exact payload recovery after coding and soft decoding.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Received constellation SNR 10 v2.png]]

*MATLAB output from reps{8}.eq: the 10 dB representative with one layer and 16QAM. Sixteen clusters are visible with clear error vectors, yet the saved CRC passes with zero payload bit errors because the LDPC decoder absorbs them.*

The final representative has tighter clusters after equalization. It uses another channel realization, so this visual comparison illustrates receiver quality across saved cases without isolating SNR as the only changed input.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Received constellation SNR 20 v2.png]]

*MATLAB output from reps{13}.eq: the 20 dB representative, a different channel realization, showing the residual noise and estimation error at the equalizer output with tight 16QAM clusters.*

Averaging symbol errors over the trials produces EVM before the CRC reduces each outcome to success or failure. The adaptive mode's higher EVM at the high SNR end should be read with its increased rank: admitting a weaker layer can increase symbol error while still increasing delivered payload.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - EVMPercent v2.png]]

*MATLAB output from results.EVMPercent: root mean square error vector magnitude per mode against SNR. At 20 dB the adaptive mode shows 15.2% against 6.65% for rank-one current PMI because its second layer accepts a weaker spatial mode; EVM alone does not rank throughput.*

### 5.4 Decoding failures, goodput and finite samples

Section 5.3 showed symbols. This section counts failed blocks and delivered payload, with intervals.

The BLER plot counts the blocks that the actual receiver fails to decode after these spatial and modulation choices. Compare current and delayed PMI at low SNR for the observed reliability cost, retaining the independently drawn data and noise as part of the comparison's uncertainty.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - BLER v2.png]]

*MATLAB output from results.BLER: failed blocks out of 24 per mode and SNR. At −5 dB current PMI fails every block; at 0 dB it fails 2 of 24 while delayed PMI fails 6 of 24. Independent noise draws mean single-trial differences cannot be attributed to the weights alone.*

Goodput weights each successful block by its selected payload and includes the reserved measurement time. The plot connects the lower SNR reliability penalty of delayed PMI to reduced delivery, and the higher SNR use of another layer to the adaptive mode's payload gain.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - GoodputMbps v2.png]]

*MATLAB output from results.GoodputMbps: CRC-accepted payload per reserved millisecond. At 0 dB current PMI delivers 0.704 Mbit/s and delayed PMI 0.576 Mbit/s; at 20 dB the adaptive mode reaches 2.78 Mbit/s against 1.54 Mbit/s for the fixed rank-one modes.*

The BLER uncertainty is a Wilson 95% interval. For k failed blocks out of n, with z = 1.95996,

$$
\widehat p=k/n,\quad
c=\frac{\widehat p+z^2/(2n)}{1+z^2/n},\quad
h=\frac{z\sqrt{\widehat p(1-\widehat p)/n+z^2/(4n^2)}}{1+z^2/n}.
$$

The reported limits are c ± h, bounded to [0,1]. The error bars below apply them to the PMI failure counts and show the probability range left unresolved by this finite Bernoulli sample, conditional on the simulation model.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - BLER intervals v2.png]]

*MATLAB output from results.BLER with Lower95 and Upper95: Wilson intervals for the PMI modes. A point with zero failures in 24 trials still carries an upper limit of 0.138, so this sample cannot support a stringent reliability claim.*

Goodput intervals use the trial standard deviation s and the Student t multiplier 2.0687 for 23 degrees of freedom:

$$\overline G\ \pm\ 2.0687\frac{s_G}{\sqrt{24}}.$$

!warning[The goodput error bars below are approximate intervals for the mean of a discrete mixture of rates and failures. Compare their width with the mean differences before interpreting a policy advantage; identical observed outcomes can yield a zero sample variance even when unobserved errors remain possible.]

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Throughput intervals v2.png]]

*MATLAB output from results.GoodputMbps with GoodputHalfCI95: mean goodput with Student t intervals over 24 trials. The adaptive mode at 20 dB reads 2.779 ± 0.273 Mbit/s; the intervals describe Monte Carlo variation and omit model and threshold uncertainty.*

A compact numerical comparison anchors the figures in the saved CSV.

| SNR | Mode | Failed blocks | Goodput | Mean rank |
| --- | --- | --- | --- | --- |
| 0 dB | Ideal SVD | 1/24 | 0.736 Mbit/s | 1 |
| 0 dB | Current PMI | 2/24 | 0.704 Mbit/s | 1 |
| 0 dB | Delayed PMI | 6/24 | 0.576 Mbit/s | 1 |
| 20 dB | Current PMI | 0/24 | 1.544 Mbit/s | 1 |
| 20 dB | Adaptive rank | 0/24 | 2.779 Mbit/s | 1.7917 |

## 6. Reproduce the experiment and trace its decisions

**Stage — Reproduce and references.**

Section 5 reported. This section says how to reproduce the run and where every number is saved.

The experiment was run with MATLAB R2026a Update 4, version 26.1.0.3312084 and 5G Toolbox 26.1. The local tests check codebook dimensions, normalization, the imaginary phase entry, expected trial count, use of rank two and the presence of both successful and failed blocks.

Run from this notebook's root directory:

```sh
/Applications/MATLAB_R2026a.app/bin/matlab -singleCompThread -batch "addpath('matlab/uni07'); run_uni07"
```

The saved artifacts retain the evidence required to recompute every reported statistic.

| Artifact | Contents | Inspect for |
| --- | --- | --- |
| run_uni07.m | Complete experiment and figure generation | Every assumption and API call |
| uni07_codebook.m | Explicit two port weights | Standard table correspondence |
| run.mat | Configuration, versions, 720 trials and complex arrays | Actual samples and matrices |
| trials.csv | One row per decoded transport block | CRC, bit errors, PMI, rank, payload |
| representative_channel.csv | Real and imaginary parts of true, current and old channel matrices | Numeric trace in §4 |
| representative_waveform.csv | Port one transmitted and antenna one received samples | Actual complex sample values |
| summary.csv | Thirty SNR and mode results | Means and uncertainty |
| figures.csv | Quantitative figure inventory | Twenty five MATLAB figures |
| run.log | Actual execution log | Version and passed assertions |
| source_hashes.txt | SHA-256 source and specification hashes | Exact reproducibility baseline |

For a first extension, age the quality estimate as well as PMI and preserve the same channel pairs. A second extension can replace the flat channel with a calibrated delay and Doppler model before adding a full CQI report. Neither extension has been executed in these results.

The closing map places the standard signal and codebook alongside the local rules and actual decoding evidence.

![[99 Attachments/5G/Uni Labs/Uni-07/Uni-07 - Closing Flow v1.png]]

*Original implementation flow. CSI-RS generation and the permitted precoder weights follow the cited clauses. The gain criterion, age model and rank/modulation thresholds are local experimental choices. The result is CRC checked payload, with uncertainty retained beside its mean.*

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The exact versions and source files are recorded in [[Protocol/Rel-18/spec-manifest.yml|the frozen Rel-18 manifest]]. CSI-RS mapping uses [TS 38.211 V18.9.0, §7.4.1.5.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the two port weights use [TS 38.214 V18.10.0, Table 5.2.2.2.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf). The [MathWorks CSI reporting example](https://www.mathworks.com/help/5g/ug/5g-nr-downlink-csi-reporting.html) and [SNR normalization explanation](https://www.mathworks.com/help/5g/ug/snr-definition-used-in-link-simulations.html) support the public implementation interfaces and sample noise scaling. The latter explains why the code uses sample variance 1/(NFFT × 10^(SNR/10)). All links were checked on 2026-09-07.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.211 V18.9.0, §7.4.1.5.3; Table 7.4.1.5.3-1, rows 1-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=139); [TS 38.211 V18.9.0, §7.4.1.5.3; Table 7.4.1.5.3-3](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=140); [TS 38.214 V18.10.0, §5.2.2.2.1; Table 5.2.2.2.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf#page=110). Accessed 2026-09-08.

### 7.2 Abbreviation index

This two column local index links to the shared [[5G Abbreviation Database]]. The definitions describe terms used in this experiment.

| Abbreviation | Full term |
| --- | --- |
| [[5G Abbreviation Database\|3GPP]] | Third Generation Partnership Project |
| [[5G Abbreviation Database\|CSI]] | Channel State Information |
| [[5G Abbreviation Database\|CSI-RS]] | Channel State Information Reference Signal |
| [[5G Abbreviation Database\|MIMO]] | Multiple Input Multiple Output |
| [[5G Abbreviation Database\|PDSCH]] | Physical Downlink Shared Channel |
| [[5G Abbreviation Database\|DMRS]] | Demodulation Reference Signal |
| [[5G Abbreviation Database\|RB]] | Resource Block |
| [[5G Abbreviation Database\|OFDM]] | Orthogonal Frequency Division Multiplexing |
| [[5G Abbreviation Database\|FD-CDM2]] | Frequency Domain Code Division Multiplexing of length two |
| [[5G Abbreviation Database\|PMI]] | Precoding Matrix Indicator |
| [[5G Abbreviation Database\|RI]] | Rank Indicator |
| [[5G Abbreviation Database\|CQI]] | Channel Quality Indicator |
| [[5G Abbreviation Database\|UCI]] | Uplink Control Information |
| [[5G Abbreviation Database\|SVD]] | Singular Value Decomposition |
| [[5G Abbreviation Database\|SNR]] | Signal to Noise Ratio |
| [[5G Abbreviation Database\|QPSK]] | Quadrature Phase Shift Keying |
| [[5G Abbreviation Database\|16QAM]] | 16 Quadrature Amplitude Modulation |
| [[5G Abbreviation Database\|MCS]] | Modulation and Coding Scheme |
| [[5G Abbreviation Database\|TBS]] | Transport Block Size |
| [[5G Abbreviation Database\|CRC]] | Cyclic Redundancy Check |
| [[5G Abbreviation Database\|MMSE]] | Minimum Mean Square Error |
| [[5G Abbreviation Database\|LDPC]] | Low Density Parity Check |
| [[5G Abbreviation Database\|BLER]] | Block Error Rate |
| [[5G Abbreviation Database\|RMS]] | Root Mean Square |
| [[5G Abbreviation Database\|EVM]] | Error Vector Magnitude |
| [[5G Abbreviation Database\|NMSE]] | Normalized Mean Squared Error |
| [[5G Abbreviation Database\|CDF]] | Cumulative Distribution Function |
| [[5G Abbreviation Database\|FFT]] | Fast Fourier Transform |
| [[5G Abbreviation Database\|CSV]] | Comma Separated Values |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with their meaning and unit.

| Symbol | Meaning | Unit or size |
| --- | --- | --- |
| H, H₀, Ĥ | Current true, old true and estimated channels | Complex 2 × 2 |
| E | Channel innovation | Complex 2 × 2 |
| x, y, n | Transmitted, received and noise symbol vectors | Complex |
| ρ, d | Correlation coefficient per slot; report age | Dimensionless; slots |
| W, wₚ | Applied matrix; codebook column p | 2 × L; 2 × 1 |
| p, p* | Candidate PMI; selected PMI | Integer 0–3 |
| L | Number of spatial layers | 1 or 2 |
| σmin | Smallest singular value | Normalized amplitude |
| γ̂ | Local predicted received quality | dB |
| Qm | Coded bits per modulation symbol | 2 or 4 |
| G | Delivered payload per reserved time | Mbit/s |
| k, n | Failed blocks; attempted blocks | Counts |
| z, c, h | Wilson multiplier, center and half width | Dimensionless |
| sG | Sample standard deviation of trial goodput | Mbit/s |
| NFFT | Transform length used in sample noise scaling | 128 samples |
| j | Imaginary unit | j² = −1 |
