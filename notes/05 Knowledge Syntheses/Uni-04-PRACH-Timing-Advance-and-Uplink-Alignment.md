---
type: knowledge_synthesis
title: Uni-04 — Physical random access channel detection, timing advance and uplink
  alignment
language: en
uni: 4
release_baseline: 18
cssclasses:
- research-note-tables
lab_run: uni04-pilot-and-expansion-20260907
---

# Uni-04 — Physical random access channel detection, timing advance and uplink alignment

!important[A receiver can recognize an uplink preamble while estimating its arrival time incorrectly. This experiment follows that error into the next transmission: generate a physical random access channel (PRACH), detect it, calculate timing advance (TA), and decode a physical uplink shared channel (PUSCH) using a fixed receive window. The result makes the timing discussion in the [[Star-17-Random-Access|random access note]] of this knowledge base measurable. In the system view, follow the measured arrival through the command to the scheduled receiver; the final block check tests whether that timing handoff worked.]

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - System Position v2.png|System position of initial uplink alignment]]

*Original system schematic. User equipment (UE) already has downlink timing; the next generation NodeB (gNB) measures uplink arrival. A commanded advance of 160 samples leaves one sample of arrival error in the baseline. The receiver then performs a fast Fourier transform (FFT), demodulation reference signal (DM-RS) estimation, minimum mean square error (MMSE) equalization and an uplink shared channel (UL-SCH) cyclic redundancy check (CRC). The 5G Core (5GC) is outside this experiment. The measured block error rate (BLER) bound comes from the saved MATLAB trials.*

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. Engineering objective and knowledge sources

**Stage — Textbook workflow.**

The overview above followed a measured arrival into a timing command and a scheduled receiver. This section says what the experiment delivers and which notes supply the knowledge.

The engineering output is a decoded first scheduled uplink block with its arrival aligned to the gNB receiver. The Chapter 17 note of this knowledge base ([[Star-17-Random-Access|Star-17]]) separates timing, resources and identity; this laboratory implements the timing part and measures its effect on data recovery. [[Uni-08-Complete-Radio-Access-and-First-Bidirectional-Transfer|Uni-08]] connects that part to response messages and connection establishment.

| Star source | Knowledge used | Executable consequence |
| --- | --- | --- |
| [[Star-07-Overall-Transmission-Structure\|Star-07]] | Numerology and cyclic prefix | Sample rate and receiver FFT windows |
| [[Star-15-Uplink-Power-and-Timing-Control\|Star-15]] | Uplink reference time and TA | Command sign, units and quantization |
| [[Star-17-Random-Access\|Star-17]] | Preamble, response and first grant | Identify what the timing measurement resolves |
| [[Star-29-TS-38.211-Physical-Channels-and-Modulation\|Star-29]] | PRACH sequence and mapping | Reproduce complex arrays from the definition |
| [[Star-31-TS-38.213-Physical-Layer-Procedures-for-Control\|Star-31]] | Initial timing command interpretation | Convert the index to seconds and samples |
| [[Star-33-TS-38.321-Medium-Access-Control\|Star-33]] | Random access response and timing maintenance | Distinguish an absolute command from later corrections |

The Third Generation Partnership Project (3GPP) defines the waveform and command interpretation. The selected estimator, rounding policy, noise levels and test tolerances are engineering choices.

| Frozen official source | Clause | Use in this laboratory |
| --- | --- | --- |
| [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 4.1; 4.3.1 | Time unit and uplink/downlink frame relationship |
| TS 38.211 V18.9.0 | 5.3.2; 6.3.3.1; 6.3.3.2 | PRACH sequence, waveform and occasions |
| TS 38.211 V18.9.0 | 6.3.1; 6.4.1.1 | PUSCH and its DM-RS |
| [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.2; 8.1; 8.2 | TA interpretation, preamble use and response reception |
| [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.1; 5.2; 6.2.3 | Random access, timing maintenance and response fields |
| [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 6.2 | UL-SCH transport block coding |

Dahlman, Parkvall and Sköld, *5G NR: The Next Generation Wireless Access Technology*, second edition, Chapter 17, printed pp. 349–370, supplies the procedure sequence ([chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9)). Chapter 15, pp. 325–334, supplies the timing control context ([chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00015-5)). Their Release 15/16 treatment remains useful for this four step terrestrial example. The frozen Release 18 documents also contain other preamble lengths and access options; the experiment exercises only length 839 and an absolute initial command.

## 2. System position and observable interfaces

**Stage — Textbook workflow.**

Section 1 named the sources. This section places the experiment between the two nodes and lists the interfaces with their observable outputs.

The user equipment (UE) derives its initial transmission time from a received downlink reference. Propagation has already delayed that reference. The next generation NodeB (gNB) therefore measures the arrival of the physical random access channel (PRACH) relative to its own scheduled uplink origin. Timing advance (TA) changes when the UE transmits the following physical uplink shared channel (PUSCH).

The laboratory builds on the detection and absent signal checks in the official [MathWorks PRACH test](https://www.mathworks.com/help/5g/ug/5g-nr-prach-detection-test.html), with its own smaller configuration and explicit signal to noise ratio (SNR) definition.

Each interface below has a separate observable output, allowing an incorrect arrival estimate to be traced through command conversion to the data receiver.

| Interface | Input | Output | Verification |
| --- | --- | --- | --- |
| PRACH transmitter | Occasion, logical root, preamble | Complex waveform | Active occasion and exact sequence check |
| PRACH detector | Noisy samples and candidate set | Preamble index and sample offset | Identity and timing tolerance |
| TA conversion | Measured delay, uplink numerology | Absolute command and advance | Units, sign, rounding and clipping |
| PUSCH receiver | Aligned waveform; known grant | Equalized symbols and decoded bits | Error vector magnitude and CRC |

This standalone case uses frequency range 1 (FR1) with frequency division duplexing (FDD), a single path and one antenna. TA is passed directly between the two waveform experiments. A random access response (RAR) waveform, its uplink grant bits, contention resolution and radio resource control (RRC) messages are integrated separately in Uni-08. A successful CRC here proves recovery of the configured UL-SCH block under the stated timing conditions.

## 3. From protocol parameters to arrays

**Stage — 3GPP protocol.**

Section 2 fixed the interfaces. This section builds the preamble from its clause, maps it, and turns a measured arrival into a command.

The Zadoff–Chu PRACH sequence follows TS 38.211 §6.3.3. The measured arrival is converted into a timing advance command using T_c and the step equations of TS 38.213 §4.2.

### 3.1 Select one active occasion

Before generating anything, one occasion must be chosen; this section fixes the settings that determine the waveform.

The following settings determine the waveform. An inactive occasion must be excluded from a detection denominator: generating no preamble is a different experiment from failing to detect a transmitted one.

| Parameter | Value | MATLAB representation | Source or choice |
| --- | --- | --- | --- |
| Carrier grid | 25 resource blocks (RB), 15 kHz spacing | `nrCarrierConfig` | Teaching configuration |
| PRACH occasion | FR1 FDD, index 27, slot 0 | `nrPRACHConfig` | 38.211 §6.3.3.2, Table 6.3.3.2-2 |
| PRACH sequence | Format 0, length 839, spacing 1.25 kHz | `LRA`, `SubcarrierSpacing` | 38.211 §6.3.3 |
| Sequence selection | Logical root 0, preamble 0, zone index 8 | `SequenceIndex`, `PreambleIndex`, `ZeroCorrelationZone` | Selected entries in §6.3.3.1 tables |
| Waveform sample rate | 7.68 MHz | `info.SampleRate` | Toolbox OFDM construction |
| Injected arrival delay | 161 samples | Channel buffer | Engineering scenario |
| PUSCH allocation | Six RB; one layer; QPSK; 768 bits | `PRBSet=0:5`, `nrTBS` | Selected grant and target rate 0.48 |
| Reference signals | Three DM-RS symbol positions | `DMRSAdditionalPosition=2` | 38.211 §6.4.1.1 |
| Common timing offset | 0 in this setup | `NTAoffset=0` | Explicit assumption |

Here RB means resource block, containing 12 subcarriers, and quadrature phase shift keying (QPSK) carries two coded bits per modulation symbol. PRACH and PUSCH use different subcarrier spacings. The TA command uses the numerology of the first uplink transmission after the response. [TS 38.213 V18.8.0, §4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

### 3.2 Generate the preamble and inspect its structure

Section 3.1 chose the occasion. This section generates the Zadoff–Chu preamble and inspects its structure.

For the selected odd sequence length, the Zadoff–Chu (ZC) root is

$$
x_u(n)=\exp\left(-j\pi\frac{u n(n+1)}{L_{\mathrm{RA}}}\right),\qquad 0\le n<L_{\mathrm{RA}}.
$$

Here $x_u(n)$ is the dimensionless complex sequence sample, $j^2=-1$, $u$ is the physical root number, $n$ is the integer sample index, and $L_{\mathrm{RA}}=839$ is the selected sequence length. The logical root index 0 maps to physical root $u=129$ for this configuration. Logical and physical root numbers are different fields. [TS 38.211 V18.9.0, §6.3.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

For example, the first nontrivial sample is $x_{129}(1)=\exp[-j\pi(129)(1)(2)/839]$. Its magnitude is one and its phase is approximately $-0.966$ rad. Substituting the indices before examining a complete waveform makes an incorrect root or sign easy to detect.

Evaluating the specified root gives the real samples paired with the sequence definition below. Their changing oscillation comes from the quadratic phase; the phase and magnitude checks that follow distinguish this variation from a change in signal power.


External source: [6.3.3.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §6.3.3.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=70), printed page 69. The PRACH root sequence, cyclic shift and frequency representation specify the preamble samples used for timing acquisition.*


![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Root Sequence Samples v1.png]]

*MATLAB calculation from the selected root u = 129: real part of the first 101 samples of the Zadoff–Chu sequence x_u(n) of TS 38.211 §6.3.3.1. The oscillation speeds up with n because the phase grows as n(n+1), the quadratic law that gives every root constant magnitude and a sharp autocorrelation.*


The wrapped phase of the same root exposes its quadratic progression. Read its phase wrapping together with the magnitude comparison next: the varying real component belongs to a sequence with constant envelope power.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Root Sequence Phase v1.png]]

*MATLAB sequence phase in radians, wrapped at ±π, for the same 839-sample root. The parabolic growth of the phase is the defining property of a Zadoff–Chu sequence; the wrapped view shows the quadratic progression without the envelope, which stays at exactly one.*

The cyclic shift selects a preamble associated with that root:

$$
x_{u,v}(n)=x_u\big((n+C_v)\bmod L_{\mathrm{RA}}\big).
$$

Here $v$ labels a preamble shift, $C_v$ is the integer cyclic shift in samples, $n$ is the sequence sample, and $L_{\mathrm{RA}}$ is the sequence length; $x_{u,v}$ and $x_u$ are dimensionless complex sequences. This preamble uses $C_v=0$. `nrPRACH` returns the discrete Fourier transform (DFT) used by the physical mapping. Its unnormalized DFT matches `fft(x)` exactly in the saved test. Dividing by $\sqrt{839}$ is done only for the comparison plot below. [TS 38.211 V18.9.0, §6.3.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

Comparing the root magnitude with its normalized DFT magnitude checks both representations used in generation. Their flat traces connect the sequence definition to the frequency samples that the Toolbox maps into the PRACH grid.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Sequence and DFT Magnitudes v1.png]]

*MATLAB root magnitude and normalized DFT magnitude, both flat at one. A Zadoff–Chu sequence has constant envelope in time and in frequency, which is why nrPRACH can map the preamble into frequency as its unnormalized 839-point transform without any shaping.*

Circular autocorrelation tests the generated root against its shifted copies before noise or frequency offset is introduced. The isolated peak in the lag plot supplies the ideal reference for the displaced correlation peak in the later CFO failure test.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Sequence Autocorrelation v1.png]]

*MATLAB circular autocorrelation of the generated root with itself over all 839 shifts, without noise or frequency offset. The single peak at zero lag and near-zero values elsewhere are what let the detector tell shifted copies apart and read the arrival delay from the peak position.*

Generating all 64 preamble indices tests how the selected zone configuration assigns roots and shifts. Read changes in physical root together with the cyclic shift sequence; exhausting one root's available shifts causes the generator to advance to another root.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Preamble Root and Shift Assignment v1.png]]

*Values returned by nrPRACH for each of the 64 preamble indices: physical root number on the left axis and cyclic shift C_v in samples on the right. With zero correlation zone index 8 each root yields a fixed number of shifts, so the logical root advances to the next physical root once its shifts are used, as the tables of TS 38.211 §6.3.3.1 prescribe.*

### 3.3 Map resources and construct the waveform

Section 3.2 produced a sequence. This section maps it onto the PRACH grid and turns it into samples.

`nrPRACHGrid`, `nrPRACHIndices` and `nrPRACHOFDMModulate` turn the sequence into samples at the configured occasion. The resource grid below is indexed in PRACH frequency bins; it uses the preamble's spacing rather than the carrier's 15 kHz data spacing.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - PRACH Resource Occupancy v1.png]]

*Magnitude of the actual PRACH grid before waveform generation, indexed in the preamble's own 1.25 kHz bins, with the count of occupied bins printed on the grid. The occupied band is the 839 subcarriers of format 0 at the configured occasion; the grid uses the preamble spacing rather than the carrier's 15 kHz data spacing.*

OFDM modulation turns the populated PRACH grid into a sampled waveform. The occupied region in its spectrum checks that the preamble bins have retained their frequency placement through that transform.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - PRACH Waveform Spectrum v1.png]]

*FFT of the generated baseband waveform relative to its maximum, a numerical baseband spectrum. The flat occupied region confirms the frequency placement of the 839 preamble bins inside the 7.68 MHz sampled carrier.*

### 3.4 Convert measured arrival into a command

The waveform arrives late. This section converts the measured delay into a timing advance command with the standard's time unit.

The basic time unit and absolute command interpretation are

$$
\begin{aligned}
T_c&=\frac{1}{480000\times4096}=0.5086263021\ \mathrm{ns},\\
N_{\mathrm{TA}}&=T_A\frac{16\times64}{2^\mu},\\
\Delta T_{\mathrm{TA}}&=\frac{16\times64T_c}{2^\mu}.
\end{aligned}
$$

Here $T_c$ is the NR basic time unit in seconds, $T_A$ is the dimensionless absolute command index from 0 to 3846, $N_{\mathrm{TA}}$ is the commanded advance counted in units of $T_c$, $\mu$ is the first PUSCH numerology index, and $\Delta T_{\mathrm{TA}}$ is one command step in seconds. The factors 16 and 64 are dimensionless. The local PUSCH uses $\mu=0$, so the step is $0.5208333333\ \mu\mathrm{s}$. [TS 38.211 V18.9.0, §4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); [TS 38.213 V18.8.0, §4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

!important[At $F_s=7.68\times10^6$ samples/s, one step is $F_s\Delta T_{\mathrm{TA}}=4$ samples. The gNB in this laboratory rounds to the nearest permitted index:]

$$
\begin{aligned}
T_A&=\operatorname{clip}_{[0,3846]}\!\left(\operatorname{round}\frac{d_{\mathrm{est}}}{F_s\Delta T_{\mathrm{TA}}}\right)
=\operatorname{round}(161/4)=40,\\
d_{\mathrm{res}}&=d_{\mathrm{est}}-N_{\mathrm{TA}}T_cF_s=161-160=1\ \text{sample}.
\end{aligned}
$$

Here $d_{\mathrm{est}}$ is the measured arrival offset in samples, $F_s$ is sample rate, $T_A$ is the command, $\Delta T_{\mathrm{TA}}$ is the command step, $N_{\mathrm{TA}}T_cF_s$ is the advance in samples, and $d_{\mathrm{res}}$ is the predicted residual from that estimate. `clip` restricts the index to the permitted range. This rounding is a receiver policy; the specification defines how the UE interprets the command. In the exact baseline, predicted and physical residuals coincide. In general the physical residual uses the true injected delay: $d_{\mathrm{physical}}=d_{\mathrm{true}}-N_{\mathrm{TA}}T_cF_s$, where $d_{\mathrm{true}}$ and $d_{\mathrm{physical}}$ are evaluation quantities in samples. The CFO case predicts $66-68=-2$ samples while the physical residual is $161-68=93$ samples.

Applying the absolute command conversion to 18 independently injected noiseless delays tests its quantization. Compare the staircase of commanded advance with the estimated delay and residual; the protocol defines the step interpretation, while the residual reflects the laboratory's rounding policy.


External source: [4.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.213 V18.8.0, §4.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=14), printed page 13. The excerpt distinguishes the absolute random access timing command from a subsequent relative adjustment; both scale with the uplink subcarrier spacing.*


![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - Measured Timing Advance Quantization v1.png]]

*MATLAB preamble timing estimates, commanded advance and residual for 18 injected noiseless delays. The staircase is the 4-sample command step of TS 38.213 §4.2 at μ = 0; the residual stays within ±2 samples because the gNB rounds to the nearest permitted index, with half-step ties rounding upward.*


The configured offset enters the UE's frame relation as $(N_{\mathrm{TA}}+N_{\mathrm{TA,offset}})T_c$. Here $N_{\mathrm{TA,offset}}$ is an additional configured count in basic time units and equals zero. An arbitrary injected arrival delay must have a stated reference before it can be interpreted geometrically. Under reciprocal propagation with one way delay $\tau$, the initial arrival error is $2\tau$ because the UE's downlink clock is already delayed. The baseline 161 samples correspond to 20.9635 microseconds of arrival error, hence 10.4818 microseconds one way and approximately 3142 m under that model. This distance is an inference from the single path assumption.

## 4. Actual experiment and failure analysis

**Stage — MATLAB experiment.**

Section 3 built and commanded. This section runs the experiment: detection with timing accuracy, false alarms, a fixed receiver window, a residual sweep, and coverage after timing is correct.

### 4.1 Detection must include timing accuracy

The first question is whether a detection is also a correct timing. This section shows that a frequency offset can separate the two.

!important[Carrier frequency offset (CFO) rotates the preamble while the detector accumulates its correlation. At sufficiently large offset a plausible preamble identity can accompany an unusable timing estimate. The diagnostic correlation below compares the same noiseless waveform at zero CFO and 1250 Hz CFO.]

![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - PRACH Correlation and Frequency Offset v1.png]]

*Saved MATLAB diagnostic correlation of the same noiseless waveform at zero and at 1250 Hz carrier frequency offset. At 1250 Hz the detected preamble index is still zero, but the correlation peak moves so the estimated delay becomes 66 samples instead of 161: the identity survives while the timing is wrong.*

Statistical success requires index zero and timing error no greater than 0.5 microseconds, or 3.84 samples. This tolerance is a selected teaching criterion. Each SNR or CFO point has 100 trials with independently seeded complex Gaussian noise. PRACH SNR is active waveform sample power divided by noise variance. The probability curves below apply both acceptance conditions; their intervals quantify the uncertainty in counting correctly timed detections.

![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - PRACH Detection Probability with Confidence Intervals v1.png]]

*MATLAB detection counts with two-sided 95% Wilson intervals, 100 trials per point; success requires preamble index zero and a timing error within 3.84 samples. At −25 dB sample SNR and zero CFO, 69 of 100 trials meet the criterion, and the interval widths show how much 100 trials can resolve.*

The timing histogram examines the detected trials from the noise test. Its spread shows the scatter in arrival estimates after a detection; missed detections are absent from this histogram and remain counted in the success denominator above.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Detection Timing Error Distribution v1.png]]

*Histogram of timing error among detected trials at −25 dB, conditional on a detection. Missed detections are absent here but stay in the denominator of the probability above; the spread is the noise-driven scatter of the correlation peak.*

The CFO sweep tests whether the timing error remains centered as frequency offset increases. Systematic displacement in the scatter below identifies estimates that can return a preamble identity while producing an unusable advance command.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Frequency Offset Timing Scatter v1.png]]

*Every detected trial of the CFO sweep, with measured timing minus the injected 161 samples on the vertical axis. The systematic displacement at large CFO is invisible to a counter that only asks whether any preamble was detected.*

!warning[At 1250 Hz CFO and −5 dB sample SNR, all 100 trials report some preamble and none meet the timing criterion. In a separate noiseless diagnostic, the wrong estimate produces command 17 and a 68 sample advance, leaving 93 samples of actual arrival error. PUSCH then fails even when its own CFO is set to zero. That controlled comparison isolates propagation of the wrong timing estimate.]

### 4.2 Measure false alarms separately

Section 4.1 measured detections when a preamble was sent. This section measures what the detector does when nothing is sent.

A receiver must also reject noise when no UE transmits. The threshold sweep below uses 500 absent signal trials at each threshold.

![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - Noise Only False Alarms and Finite Sample Limits v1.png]]

*MATLAB counts of false alarms in 500 absent-signal trials per threshold. Thresholds 0.005 and 0.01 trigger in most trials; at 0.02 zero false alarms give a 95% Wilson upper bound of 0.76%, which is exactly what zero events in 500 trials can and cannot prove.*

!warning[Threshold 0.005 gives 438/500 false alarms and 0.01 gives 392/500. The selected 0.02 setting is supported by the measured signal and noise trials. Zero observed events does not establish a true event probability of zero or a conformance requirement below the confidence bound.]

### 4.3 Hold the receiver window fixed

Sections 4.1 and 4.2 measured the detector. This section moves to the data receiver and keeps its window fixed, so that only the phone's advance can align the arrival.

The receiver applies the same scheduled FFT window to both uncorrected and advanced signals. For the first symbol, the normal cyclic prefix (CP) has 40 samples, the FFT starts at sample 20, and its 512 samples end at index 531. Indices here are zero based. The known channel delay is used to generate and evaluate the signal; it does not reposition the receiver window. Comparing the waveform envelopes below against that common window checks that the improvement comes from advancing the UE transmission.

![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - PUSCH Waveform Positions before and after Timing Advance v1.png]]

*Measured waveform envelopes at the same gNB buffer origin, before and after the UE applies the commanded advance. Timing advance moves the arriving PUSCH by 160 samples into the receiver's scheduled FFT window; the receiver window itself never moves.*

Calculating the windows for all fourteen symbols extends the same indexing rule across the slot. The coordinate plot records their starts and inclusive ends so the alignment comparison can be reproduced without shifting the receiver to the known signal arrival.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Slot FFT Window Coordinates v1.png]]

*Calculated start and inclusive end sample indices of all fourteen symbol windows from the Toolbox symbol lengths and cyclic prefix fraction 0.5. The first window starts at sample 20 and ends at 531; students reproducing the indexing can check each value against this table.*

Demodulation reference signals (DM-RS) provide channel and noise estimates. Minimum mean square error (MMSE) equalization produces symbols and reliability information; the UL-SCH decoder then checks the cyclic redundancy check (CRC). The comparison uses identical noise and transport bits within each pair, with a fresh decoder for every pair. Read the restored constellation regions beside the CRC outcomes below: this links the timing correction to successful block recovery under the paired conditions.

![[99 Attachments/5G/Uni Labs/Uni-04/Uni-04 - PUSCH Constellations and UL SCH CRC Results v1.png]]

*MATLAB PUSCH symbols and paired UL-SCH results at 15 dB per resource element, with the same noise and bits inside each pair. Without timing advance the constellation is a rotating cloud and all 100 blocks fail the CRC; with it the four QPSK regions return and all 100 blocks decode.*

Median error vector magnitude (EVM) falls from 100.29% without TA to 18.71% with TA. The EVM is the root mean square complex symbol error relative to the transmitted symbol energy. The corrected result retains noise and estimation error, visible in the equalized symbol ratio.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Equalized Symbol Ratio v1.png]]

*Equalized symbols divided by transmitted symbols for the representative corrected block. Perfect recovery would put every point at 1 + 0j; the residual cloud is noise plus DM-RS estimation error after MMSE equalization, and it sets the 18.71% median EVM.*

### 4.4 Sweep the residual rather than assuming a tolerance

Section 4.3 tested one residual. This section sweeps residual offsets from early to late and watches where decoding fails.

The expansion experiment injects residual offsets from −60 to +60 samples in steps of five. It decodes one fresh block per offset at 25 dB. These points are deterministic diagnostic outcomes for the saved seeds, rather than a statistical BLER curve. The EVM sweep below tests early and late arrival against the same window; the steep rise outside the region of low error shows the symbol cost of excess residual timing.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Residual Timing EVM Sweep v1.png]]

*EVM across 25 actual PUSCH receiver runs with residual offsets from −60 to +60 samples in steps of five at 25 dB. Early and late arrival are tested against the same window; EVM stays low only while the residual lies inside the cyclic prefix and then rises steeply.*

Decoding each residual offset produces the CRC outcomes below. Compare the passing region with the low EVM region: their agreement connects the symbol degradation to failed blocks in this setup, subject to the single block tested at each offset.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Residual Timing CRC Sweep v1.png]]

*One UL-SCH block per residual offset, where a zero marker means the block passed its CRC. The pass region matches the low-EVM region of the previous figure; one block per point is a deterministic diagnostic and does not estimate the error probability at that offset.*

### 4.5 Separate timing success from coverage

Section 4.4 varied timing at one noise level. This section holds timing correct and varies noise, so that coverage appears as a separate limit.

Correct timing leaves a receiver exposed to noise. The expansion runs 30 fresh corrected blocks at each of six PUSCH SNR values, from −5 through 20 dB. PUSCH SNR is per resource element and uses time sample noise variance $1/(N_{\mathrm{FFT}}10^{\mathrm{SNR}/10})$. Here $N_{\mathrm{FFT}}=512$ is transform length, SNR is in decibels, and the expression is complex sample variance under the Toolbox's transmit scaling. It is different from the PRACH active sample SNR above.

The BLER curve counts CRC failures after timing correction at each noise level. Its fall with SNR measures the remaining noise limit under aligned reception, with interval widths set by the number of tested blocks.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Aligned PUSCH SNR and BLER v1.png]]

*Actual UL-SCH CRC statistics after applying the measured timing advance, 30 fresh blocks per SNR from −5 to 20 dB, with 95% Wilson intervals. Correct timing removes the alignment failure but leaves the noise limit, so the block error rate now falls with SNR as coverage predicts.*

The EVM scatter uses the same corrected blocks before decoding. The changing spread with SNR explains how symbol quality varies within each point of the BLER curve while the timing condition is held fixed.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Aligned PUSCH EVM Distribution v1.png]]

*EVM for all 180 expansion blocks, one point per trial, so the variation stays visible instead of being hidden in a mean. EVM falls as SNR rises and clusters tightly at each SNR because timing is now correct in every block.*

Comparing each decoded payload with its transmitted bits provides the error counts below. Reading these beside the CRC statistics checks actual data agreement behind the binary acceptance result.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Aligned PUSCH Bit Error Counts v1.png]]

*Bit error count after UL-SCH decoding for each of the 180 blocks, relative to the 768-bit transport block. Blocks that fail the CRC carry many errors while passing blocks carry none, which is the all-or-nothing behaviour of an LDPC decoder followed by a CRC check.*

## 5. Engineering choices and reproduction

**Stage — Reproduce and references.**

Section 4 measured. This section explains the choices behind the measurements and how to run them yourself.

### 5.1 Interpret the protocol boundary

The first choice is where the standard stops: this section reads the response fields and their interpretation.

The random access response (RAR) includes a 12 bit timing field, 27 bit uplink grant and 16 bit temporary cell radio network temporary identifier (TC-RNTI). A field width of 12 bits does not make all 4096 bit patterns valid initial TA indices. Later medium access control (MAC) timing adjustments use a different relative interpretation around command index 31. [TS 38.321 V18.10.0, §6.2.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); [TS 38.213 V18.8.0, §4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

!note[The [ShareTechnote RACH explanation](https://www.sharetechnote.com/html/5G/5G_RACH.html), accessed 2026-09-07, helps connect a preamble to the response and subsequent identity exchange. Use its procedure view to orient the experiment, then use the frozen clauses for field meanings and allowed values. A preamble index identifies a selected signature; two contending UEs can select the same signature, so it cannot by itself resolve their identities.]

| Engineering choice | What this experiment measures | Extension worth testing |
| --- | --- | --- |
| Single delayed path | Reference planes and quantization | Multipath bias and strongest path selection |
| Fixed receiver FFT window | Benefit of UE timing correction | Tracking under clock drift |
| One UE and one preamble | Identity/timing detection | Same preamble collisions and near/far power |
| Nearest permitted TA | Small quantization residual | Robust estimation under CFO ambiguity |
| Independent UL-SCH blocks | Initial decode probability | HARQ combining from [[Uni-05-Transport-Blocks-LDPC-and-HARQ\|Uni-05]] |

The current Saar units U03–05 supply numerology and U09–10 supply cell search and random access context. Power limited uplink operation continues in [[Uni-06-PUSCH-Power-Control-and-Coverage|Uni-06]]. The access state and message sequence continues in Uni-08.

### 5.2 Run and inspect the evidence

Section 5.1 drew the boundary. This section gives the commands, seeds and saved outputs.

Open the lab README and run the commands below from `matlab/uni04` in MATLAB R2026a with 5G Toolbox 26.1:

```matlab
test_uni04
run_uni04
test_outputs
uni04_expansion
test_expansion
```

`run_uni04` regenerates the original pilot files and six paired figures. `uni04_expansion` writes separate expansion results and sixteen scientific figures. Elapsed time is recorded for each execution in `expansion.mat`; runtime depends on hardware and software. Both commands replace their own generated outputs when rerun. A timestamped `results/source-*` directory stores the current source/configuration snapshot and SHA-256 manifest. This snapshot documents the current reproducible implementation rather than asserting a source hash was collected during the older pilot execution.

| Evidence | Saved file | Meaning |
| --- | --- | --- |
| Pilot configuration and seeds | `config.json`, `results/summary.json` | MATLAB version, assumptions and trial setup |
| Preamble statistics | `results/prach_trials.csv` | 3200 statistical trials; distinct from deterministic checks |
| Paired data recovery | `results/pusch_trials.csv` | 100 paired blocks with EVM, CRC and bit errors |
| Numerical expansion | `results/expansion.mat` | Exact root/DFT check, 25 delays, 180 blocks, versions |
| Expansion tables | `results/expansion_delay.csv`, `expansion_snr.csv` | Every new measurement and seed |
| Logs and figures | `results/expansion.log`, `uni04_plots.m`, `uni04_expansion.m` | Reproduction and plotting instructions |

The pilot uses seed 2026090401 with recorded per trial offsets. Expansion uses base seed 2026090704, with delay seeds `base+k` and SNR seeds `base+1000+serial`, all with MATLAB `twister`. Statistical intervals describe the stated independent noise and transport block trials; they do not cover uncertainty from untested channels or receiver models.

## 6. Implementation flow

**Stage — Measured results.**

Section 5 explained the choices. This section draws the complete chain, execution beside equations, and states the measured baseline.

The closing diagram joins the processing order to the sequence and command equations. Solid arrows carry execution; dashed arrows show mathematical dependencies. The scalar residual equation assumes the selected zero common timing offset and the measured arrival reference defined above.

![[99 Attachments/5G/Uni Labs/Uni-04/UNI-04 - Implementation Flow v1.png|PRACH and TA implementation with official formulas]]

*Original implementation schematic generated with image_gen. Sequence and command definitions are from TS 38.211 V18.9.0 §§4.1, 6.3.3.1 and TS 38.213 V18.8.0 §4.2. The nearest command calculation and residual arithmetic are engineering choices. Copyable equations and complete variable definitions are in §3.4.*

The measured baseline connects the stages: detection returns 161 samples, command 40 advances the UE by 160 samples, and a fixed receiver decodes all 100 corrected blocks. The CFO failure demonstrates that a detected signature can still lead to a wrong command and a failed first uplink block.

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

- Dahlman, E., Parkvall, S. and Sköld, J. *5G NR: The Next Generation Wireless Access Technology*, 2nd ed. Chapter 15, pp. 325–334, [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00015-5); Chapter 17, pp. 349–370, [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).
- 3GPP, [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), §§4.1, 4.3.1, 5.3.2, 6.3.1, 6.3.3, 6.4.1.1.
- 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), §6.2.
- 3GPP, [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip), §§4.2, 8.1, 8.2.
- 3GPP, [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), §§5.1, 5.2, 6.2.3.
- MathWorks, [5G NR PRACH Detection and False Alarm Test](https://www.mathworks.com/help/5g/ug/5g-nr-prach-detection-test.html), accessed 2026-09-07. The installed R2026a documentation supplies the exact API behavior used here.
- ShareTechnote, [5G/NR RACH](https://www.sharetechnote.com/html/5G/5G_RACH.html), accessed 2026-09-07. Engineering orientation; official values follow the frozen specifications.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.211 V18.9.0, §6.3.3.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=70); [TS 38.213 V18.8.0, §4.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=14). Accessed 2026-09-08.

### 7.2 Abbreviation index

Definitions and protocol locators are maintained in [[5G Abbreviation Database]].

| Abbreviation | Full term |
| --- | --- |
| 3GPP | Third Generation Partnership Project |
| 5GC | 5G Core |
| BLER | Block error rate |
| CFO | Carrier frequency offset |
| CP | Cyclic prefix |
| CRC | Cyclic redundancy check |
| DFT | Discrete Fourier transform |
| DM-RS | Demodulation reference signal |
| EVM | Error vector magnitude |
| FDD | Frequency division duplexing |
| FFT | Fast Fourier transform |
| FR1 | Frequency range 1 |
| gNB | Next generation NodeB |
| HARQ | Hybrid automatic repeat request |
| MAC | Medium access control |
| MMSE | Minimum mean square error |
| NR | New Radio |
| OFDM | Orthogonal frequency division multiplexing |
| PRACH | Physical random access channel |
| PUSCH | Physical uplink shared channel |
| QPSK | Quadrature phase shift keying |
| RAR | Random access response |
| RB | Resource block |
| RRC | Radio resource control |
| SNR | Signal to noise ratio |
| TA | Timing advance |
| TC-RNTI | Temporary cell radio network temporary identifier |
| UE | User equipment |
| UL-SCH | Uplink shared channel |
| ZC | Zadoff–Chu |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with their meaning and unit.

| Symbol | Meaning | Unit or range | Origin |
| --- | --- | --- | --- |
| $x_u(n)$ | Root sequence sample | Complex, dimensionless | 38.211 §6.3.3.1 |
| $u,n$ | Physical root and sample index | Integers | 38.211 §6.3.3.1 |
| $L_{\mathrm{RA}}$ | Selected sequence length | 839 samples | 38.211 §6.3.3 |
| $C_v,v$ | Cyclic shift and its label | Samples; integer index | 38.211 §6.3.3.1 |
| $T_c$ | Basic NR time unit | Seconds | 38.211 §4.1 |
| $T_A$ | Absolute command index | 0 to 3846 | 38.213 §4.2 |
| $N_{\mathrm{TA}}$ | Dynamic timing advance count | Units of $T_c$ | 38.213 §4.2 |
| $N_{\mathrm{TA,offset}}$ | Configured timing offset count | Units of $T_c$ | Selected zero in this setup |
| $\mu$ | First PUSCH numerology index | Zero here | 38.213 §4.2 |
| $\Delta T_{\mathrm{TA}}$ | Duration of one command step | Seconds | 38.213 §4.2 |
| $F_s$ | Waveform sample rate | Samples/s | Toolbox configuration |
| $d_{\mathrm{est}},d_{\mathrm{res}}$ | Measured delay and predicted residual | Samples | Receiver calculation |
| $d_{\mathrm{true}},d_{\mathrm{physical}}$ | Injected delay and physical residual | Samples | Simulation evaluation |
| $\tau$ | Assumed reciprocal one way delay | Seconds | Propagation model |
| $N_{\mathrm{FFT}}$ | PUSCH transform length | 512 samples | Toolbox waveform |
