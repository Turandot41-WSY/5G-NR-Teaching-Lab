---
type: knowledge_synthesis
title: Uni-01 — Cell search, synchronization and Master Information Block recovery
language: en
uni: 1
release_baseline: 18
cssclasses:
- research-note-tables
lab_run: run-20260907-002810
---

# Uni-01 — Cell search, synchronization and Master Information Block recovery

> [!important]
> This experiment starts with complex received samples and recovers a cell identity, a timing reference and a Master Information Block (MIB). The receiver must estimate its frequency error and channel before it can trust the broadcast bits. The result supplies the first interface in the access sequence developed in your [[Star-16-Cell-Search-and-System-Information|cell search notes]].

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - System Overview v1.png|From received samples to cell information]]

*Original schematic. The base station broadcasts an SS/PBCH block; a receiver progressively obtains synchronization, identity and message fields. The channel adds noise, a pure sample delay and a constant frequency offset. In this diagram only, $\Delta f$ denotes the injected frequency offset and $T_s=1/F_s$ is the sample interval; the derivation below names the frequency offset $f_0$.*

## 1. Engineering objective and knowledge sources

**Stage — Textbook workflow.**

The overview above showed the base station broadcasting and the receiver working through synchronisation, identity and message fields. This section says what the experiment must deliver and which notes supply the knowledge for each step.

The laboratory makes the first part of the discovery sequence of this knowledge base executable: synchronization signal block → physical broadcast channel → master information block. Its output will later locate control resource set zero and System Information Block 1 (SIB1). Each stage below records the protocol definition, the MATLAB object and the observable result.

| Star source                                          | Knowledge used in this experiment | Concrete implementation                             |                                                     |
| ---------------------------------------------------- | --------------------------------- | --------------------------------------------------- | --------------------------------------------------- |
| [[Star-07-Overall-Transmission-Structure             | Star-07]]                         | Numerology, symbols and resource grids              | Sample rate, cyclic prefix and array dimensions     |
| [[Star-09-Transport-Channel-Processing               | Star-09]]                         | Broadcast coding and soft decoding                  | BCH encoder, rate matching and decoder              |
| [[Star-16-Cell-Search-and-System-Information         | Star-16]]                         | Discovery order and the meaning of broadcast fields | Receiver stage order and MIB parsing                |
| [[Star-29-TS-38.211-Physical-Channels-and-Modulation | Star-29]]                         | Signal generation and resource mapping              | PSS, SSS, PBCH and PBCH DM-RS arrays                |
| [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding  | Star-30]]                         | The broadcast channel coding chain                  | Payload, CRC, polar coding and output length checks |

The Third Generation Partnership Project (3GPP) specifications below define the transmitted signal and message. Receiver correlation, channel estimation and experimental noise levels are engineering choices. The frozen versions agree with the course protocol manifest.

| Official source | Clauses used | What the source fixes |
| --- | --- | --- |
| [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 5.3.1; 7.3.3; 7.4.1.4; 7.4.2; 7.4.3 | Waveform, identities, sequences and resource mapping |
| [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.1.1–7.1.5 | Broadcast payload, scrambling, CRC, polar coding and rate matching |
| [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.1 | Case C candidate timing and block index interpretation |
| [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.2.1–6.2.2 | BCCH-BCH message structure and MIB field meanings |

> [!book] Textbook — the discovery sequence
> The Chapter 16 note of this knowledge base ([[Star-16-Cell-Search-and-System-Information|Star-16]]) asks why the synchronization grid needs an offset relative to the carrier grid. This experiment recovers $k_{\mathrm{SSB}}=0$ and the control configuration bits; Uni-03 will use them to locate SIB1. Here $k_{\mathrm{SSB}}$ is the subcarrier offset defined in TS 38.211 §7.4.3.1. The teaching sequence follows Dahlman, Parkvall and Sköld, *5G NR: The Next Generation Wireless Access Technology*, second edition, Chapter 16, printed pp. 335–347 ([chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7)).

## 2. System position and the experiment boundary

**Stage — Textbook workflow.**

Section 1 listed the sources. This section fixes the boundary of the experiment: which node does what, what the receiver is given, and what it must work out for itself.

The next generation NodeB (gNB) constructs a broadcast waveform. User equipment (UE) receives one short capture and returns acquisition fields. The 5G Core network (5GC) enters the later connection sequence; this experiment ends before a connection exists.

The closest implementation is the official [MathWorks cell search and MIB/SIB1 example](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html). The custom scripts expose a smaller setup and save selected intermediate arrays.

| Interface | Supplied to it | Returned from it |
| --- | --- | --- |
| Transmitter | Cell identity 321; frame 426; block index 0 | Resource grid and complex waveform |
| Channel setup | Waveform; noise seed; frequency error; integer delay | Received samples |
| Receiver | Samples; sample rate; 30 kHz spacing; eight block hypotheses | Identity, timing, frequency estimate, channel estimate and MIB fields |
| Evaluation only | Receiver output and transmitted truth | Field comparison, success count and uncertainty |

Frequency range 1 (FR1), an unpaired band around 3.5 GHz and normal cyclic prefix provide the radio context. Case C uses 30 kHz subcarrier spacing and the applicable eight candidate positions; the setup activates only index zero, starting at symbol 2 in the first half frame. The 24 resource block capture grid is a numerical observation window. The receiver knows its sample rate and search hypotheses. It is not performing an unrestricted radio frequency (RF) raster search. [TS 38.213 V18.8.0, §4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

> [!important] Important — keep the message and resource counts distinct
> The unpunctured block contains 432 PBCH data resource elements and 144 PBCH reference elements. The MATLAB BCH input has 24 formatted message bits; physical layer processing expands the payload to 32 bits before CRC attachment. These distinctions correct the compressed “576 resource elements” and “32-bit MIB” descriptions that can otherwise obscure the implementation. The official locators are TS 38.211 §§7.3.3 and 7.4.3, TS 38.212 §7.1 and TS 38.331 §6.2.2.

## 3. From protocol parameters to receiver arrays

**Stage — 3GPP protocol.**

Section 2 fixed what goes in and what comes out. This section follows the signal through the receiver in six stages, each pairing a clause of the standard with the MATLAB operation and the picture it produces.

Six stages connect standards definitions to MATLAB operations and observable results. Each scientific image comes from the delivered scripts and saved experiment data.

### 3.1 Build the broadcast grid and the received capture

The first stage builds what the base station transmits and what the receiver captures: the SSB on its grid, the waveform, and the noisy, delayed, frequency-shifted samples.

A synchronization signal and physical broadcast channel block (SSB) groups the Primary Synchronization Signal (PSS), Secondary Synchronization Signal (SSS), Physical Broadcast Channel (PBCH) and its Demodulation Reference Signal (DM-RS). One resource element (RE) is one subcarrier in one symbol. This setup uses the unpunctured mapping in [TS 38.211 V18.9.0, §7.4.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

The original SS/PBCH table supplies the coordinates used to label this resource grid.


External source: [7.4.3.1; Table 7.4.3.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.3.1; Table 7.4.3.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=148), printed page 147. The table fixes the symbol and subcarrier locations of PSS, SSS, PBCH and PBCH DM-RS within the SS/PBCH block.*


![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 01 SSB Resource Map v1.png|Actual SS/PBCH resource mapping]]

*MATLAB result — t.labels. Horizontal positions are the four symbols within the SSB; vertical positions are its 240 subcarriers. PBCH occupies parts of three symbols, with reference elements interleaved among its data.*


| Source parameter | Value | MATLAB representation | Check |
| --- | --- | --- | --- |
| SSB size, 38.211 §7.4.3 | 240 × 4 RE positions | t.ssb | PSS 127; SSS 127; DM-RS 144; PBCH 432 |
| Subcarrier spacing, 38.213 §4.1 | 30 kHz | c.subcarrierSpacing | Normal cyclic prefix |
| Capture grid, engineering choice | 24 resource blocks | nrCarrierConfig | 288 subcarriers; SSB centered |
| Transform size, Toolbox output | 512 samples | t.nfft | Sample rate 15.36 MHz |

Orthogonal frequency division multiplexing (OFDM) converts subcarrier values to time samples. Here the Fast Fourier Transform (FFT) size and subcarrier spacing (SCS) imply the sample rate:

$$
\begin{aligned}
F_s &= N_{\mathrm{FFT}}\Delta f\\
&=512\times30{,}000\ \mathrm{s}^{-1}\\
&=15.36\times10^6\ \mathrm{samples/s}.
\end{aligned}
$$

The transform length and spacing set the sample rate used for timing measurements.

| Symbol | Value and unit | Meaning and source |
| --- | --- | --- |
| $F_s$ | 15.36 × 10⁶ samples/s | Sample rate calculated above |
| $N_{\mathrm{FFT}}=512$ | Dimensionless | Transform length returned by nrOFDMInfo; implementation value |
| $\Delta f=30{,}000$ | Hz | Selected subcarrier spacing |

The product fixes the sample reference for every later timing measurement. The waveform definition is [TS 38.211 V18.9.0, §5.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

OFDM modulation produces the transmitted envelope below. Its active interval locates the broadcast burst before any impairment is applied, providing the timing reference for the received capture.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 05 Transmit Envelope v1.png|Transmitted SSB waveform envelope]]

*MATLAB result — t.waveform. Magnitude of the transmitted capture in milliseconds: the active interval holds the four OFDM symbols of one SS/PBCH block, and the remaining symbols of the capture are empty. This is the waveform the channel delays, rotates and buries in noise before the receiver sees it.*

The received in-phase and quadrature (I/Q) samples contain Additive White Gaussian Noise (AWGN), a pure delay and Carrier Frequency Offset (CFO). These impairments enter before acquisition. Signal-to-noise ratio (SNR) is defined at an active RE, following the [MathWorks link simulation convention](https://www.mathworks.com/help/5g/ug/snr-definition-used-in-link-simulations.html).

$$
\begin{aligned}
y[n]&=s[n-d]\exp(j2\pi f_0n/F_s)+w[n],\\
\sigma_w^2&=\frac{1}{N_{\mathrm{FFT}}10^{\mathrm{SNR}_{dB}/10}}\\
&=\frac{1}{512\times10^{8/10}}\\
&\approx3.0955\times10^{-4}.
\end{aligned}
$$

The sample model specifies the injected delay, frequency offset and noise.

| Symbol | Value and unit | Meaning |
| --- | --- | --- |
| $y[n]$, $s[n]$ | Normalized complex amplitude | Received and transmitted samples |
| $n$ | Dimensionless index | Sample position |
| $d=137$ | Samples | Injected delay |
| $f_0=23{,}700$ | Hz | Injected frequency offset |
| $j^2=-1$ | Dimensionless | Imaginary unit |
| $F_s=15.36$ | MHz | Sample rate calculated above |
| $w[n]$, $\sigma_w^2$ | Zero mean; total variance ≈ 3.0955 × 10⁻⁴ | Complex noise; each real and imaginary component has half the total variance |

The transform convention makes the noise variance after the FFT equal to $N_{\mathrm{FFT}}\sigma_w^2$. The receiver is not supplied these experiment inputs.

Applying the sample model produces the capture below. The envelope still identifies a region containing signal energy; the raw I/Q samples show why the receiver needs a sequence comparison to obtain precise timing.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 06 Received IQ v1.png|Received in-phase and quadrature samples]]

*MATLAB result — wave and rx.timingOffset. The upper panel smooths the received magnitude at 8 dB over 16 samples so the SSB burst stands out from the noise, with the PSS reference origin marked; the lower panel zooms into 64 raw in-phase and quadrature samples at that origin, which carry 137 samples of delay and 23.7 kHz of frequency offset that the receiver must estimate.*

The periodogram places that capture in frequency. Inspect the raised band against the marked SSB edges; this broad view locates occupied spectrum but cannot resolve the small carrier offset.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 07 Received Spectrum v1.png|Spectrum of the noisy received capture]]

*MATLAB result — fft(wave). The periodogram of the noisy capture smoothed over 40 bins, so the raised SSB band shows above the noise floor; the dashed lines mark the 240-subcarrier SSB band of TS 38.211 §7.4.3. The 23.7 kHz offset is too small to see at this 20 MHz scale, which is why the next figure zooms in. The vertical scale is relative power.*

### 3.2 Search PSS and coarse frequency together

Section 3.1 produced samples that carry an unknown timing and frequency error. This section makes the first estimate: which PSS was sent, and roughly what the frequency error is.

The PSS supplies one of three identity components. A frequency error rotates its samples during correlation, so the receiver compares both sequence and frequency hypotheses. It tests nine frequency corrections, from −60 to +60 kHz in 15 kHz steps, for each of the three sequences.

The specified register state and cyclic shifts can be checked against the three generated PSS candidates.


External source: [7.4.2.2.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.2.2.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=146), printed page 145. The PSS sequence, cyclic shift and initial register state define the three transmitted candidates; correlation and frequency search are receiver implementation choices.*


![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 02 PSS Candidates v1.png|The three generated PSS candidates]]

*MATLAB result — nrPSS. Vertical offsets separate the three sequences for reading; actual sequence values are −1 and +1.*


The sequence generator follows the binary recurrence and shift in [TS 38.211 V18.9.0, §7.4.2.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip):

$$
\begin{aligned}
x(i+7)&=(x(i+4)+x(i))\bmod2,\\
m&=(n+43N_{ID}^{(2)})\bmod127,\\
d_{\mathrm{PSS}}(n)&=1-2x(m).
\end{aligned}
$$

The recurrence uses the following dimensionless sequence values, indices and specified constants.

| Symbol | Value or range | Meaning |
| --- | --- | --- |
| $x$ | $x(0)=0$, $x(1)=1$, $x(2)=1$, $x(3)=0$, $x(4)=1$, $x(5)=1$, $x(6)=1$ | Binary sequence initialized in ascending index order |
| $i$ | Recurrence index | Advances the recurrence |
| $n$ | $0,\ldots,126$ | Element index: position in the PSS sequence |
| $m$ | Shifted index | Selects the binary sequence element |
| $N_{ID}^{(2)}$ | $0$, $1$, or $2$ | Three candidates; selects the PSS |
| Coefficient; sequence length | 43; 127 | Constants specified by TS 38.211 §7.4.2.2.1 |

The test suite implements this recurrence independently and compares all three arrays with nrPSS.

Correlating the generated candidates exposes their discrimination before noise and frequency error enter. Compare the central matched peak with competing peaks in the sequence correlations below.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 03 PSS Correlations v1.png|PSS candidate correlations]]

*MATLAB result — sequence correlations. The matched sequence produces a strong central peak; other peaks explain why acquisition must compare competing hypotheses.*

The search now uses the received samples. Each heatmap entry retains the best timing score for a sequence and frequency hypothesis, so the largest entry selects the coarse correction and PSS component together.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 08 Coarse Search v1.png|PSS and frequency hypothesis search]]

*MATLAB result — rx.pssScores. Each cell contains the maximum timing correlation for a sequence and frequency correction. The winning column supplies the PSS component.*

The offset comparison shows the remaining gap after this discrete search and the estimate obtained after refinement. The next derivation explains how the cyclic prefix supplies that finer correction.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 32 Coarse and Fine Offset v1.png|Coarse hypotheses and the fine correction for the winning PSS]]

*The receiver first picks the best of nine coarse hypotheses and then refines it from the PSS phase; the fine step closes most of the gap to the injected offset.*

> [!matlab] MATLAB — receiver prior knowledge
> The receiver is given sample rate, spacing and its candidate list. It is not given cell identity, delay, frequency offset, SSB index or MIB bits. Transmitter values enter only the later acceptance check.

### 3.3 Correct the remaining frequency error and define timing

The coarse search of Section 3.2 lands within half a subcarrier spacing. This section removes the rest of the frequency error with the cyclic prefix and turns the correlation peak into the SSB start sample.

The Cyclic Prefix (CP) repeats the end of an OFDM symbol. Comparing samples separated by one transform length exposes their phase rotation. The receiver first removes the coarse estimate, then measures the residual frequency from CP samples. This estimator follows the engineering approach in the [MathWorks receiver example](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html).

$$
\begin{aligned}
C&=\sum_{n\in\mathcal C}z^*[n]z[n+N_{\mathrm{FFT}}],\\
\widehat f_{\mathrm{fine}}&=\frac{F_s}{2\pi N_{\mathrm{FFT}}}\arg(C),\\
z_{\mathrm{corrected}}[n]&=y[n]\exp(-j2\pi\widehat f n/F_s).
\end{aligned}
$$

The estimator uses interior CP samples to measure phase rotation over one transform length.

| Symbol | Value and unit | Meaning |
| --- | --- | --- |
| $z[n]$ | Complex sample | Sample after coarse correction |
| $\mathcal C$ | Positions across four SSB symbols | Interior CP sample positions |
| $*$ | Complex conjugation | Operation applied to the first sample |
| $C$, $\arg$ | Phase in radians | Complex correlation sum and its principal angle |
| $N_{\mathrm{FFT}}=512$ | Samples | Transform length |
| $F_s=15.36$ | MHz | Sample rate |
| $\widehat f_{\mathrm{fine}}$ | Hz | Estimated residual frequency |
| $\widehat f$ | Hz | Sum of coarse and fine estimates |

The negative exponential removes the positive rotation in the channel model. Reversing the conjugation reverses the estimate's sign.

!important[The principal residual range is less than half an SCS in magnitude: 15 kHz here. A 15 kHz coarse grid brings a true frequency within the search range to within 7.5 kHz of a candidate. Noise, poor timing or an incorrect candidate can still cause failure.]

After frequency correction, the PSS timing correlation below selects the reference origin. Its sample coordinate must be converted to the SSB start before the receiver extracts the broadcast symbols.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 09 Timing Peak v1.png|PSS timing correlation after frequency correction]]

*MATLAB result — rx.timingCorrelation. The reference puts PSS in its second symbol, so the detected reference origin precedes the actual SSB.*

The spectrum comparison uses the same capture before and after the estimated correction. Movement toward the marked band edges verifies the correction's direction; the remaining error is evaluated from the saved estimate.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 27 Spectrum Correction v1.png|Spectrum before and after the receiver's own frequency correction]]

*MATLAB result — wave, rx.correctedWaveform and rx.frequencyOffset. The smoothed periodogram of the same 8 dB capture before and after the receiver applies its own 23.6 kHz estimate, zoomed to twice the SSB band; the dotted line is the injected offset and the dashed lines the 240-subcarrier band edges, so the reader sees the SSB energy move back inside the band.*

The stored example has reference offset 685 samples. Its reference first symbol contains 556 samples, giving the SSB CP start:

$$
\begin{aligned}
n_{\mathrm{SSB}}&=n_{\mathrm{ref}}+L_{\mathrm{ref},0}\\
&=685+556\\
&=1241\ \mathrm{samples}.
\end{aligned}
$$

The timing conversion relates the reference origin to the SSB cyclic prefix start in the received capture.

| Symbol | Value and unit | Meaning and source |
| --- | --- | --- |
| $n_{\mathrm{ref}}$ | 685 samples | Reference origin counted from zero, returned by nrTimingEstimate |
| $L_{\mathrm{ref},0}$ | 556 samples | First reference symbol length from nrOFDMInfo |
| $n_{\mathrm{SSB}}$ | 1241 samples | Start of the SSB cyclic prefix in the received capture |

!warning[The transmitted start is 1104 samples; adding the injected delay of 137 gives the same 1241. Comparing 685 directly with the transmitted SSB start would use different reference origins.]

### 3.4 Use SSS to obtain the complete physical cell identity

With timing and frequency corrected, the receiver can read the second synchronisation signal. This section uses it to complete the cell identity.

After timing and frequency correction, the receiver extracts four SSB symbols. It compares the SSS elements with 336 candidate sequences associated with the selected PSS. The Physical Cell Identity (PCI) then follows from [TS 38.211 V18.9.0, §§7.4.2.1 and 7.4.2.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

The transmitted SSS sequence below is a diagnostic reference. In reception, the corresponding sequence is unknown and must be selected by comparison with the extracted SSS elements.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 04 SSS Sequence v1.png|SSS sequence for the transmitted cell]]

*MATLAB result — nrSSS(321). The 127 BPSK values of the secondary synchronization signal generated for physical cell identity 321 by the m-sequence rule of TS 38.211 §7.4.2.3. The receiver never sees this array; it regenerates all 336 candidates itself and correlates them against the received symbol.*

The SSS search plot records that comparison over all remaining groups. Its peak supplies the group index used in the cell identity calculation immediately below.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 10 SSS Search v1.png|SSS correlation over all identity groups]]

*MATLAB result — rx.sssScores. Correlation score of the received SSS symbol against every candidate group index, once the PSS has fixed the identity within the group. The single peak at group 107 combines with N_ID^(2) = 0 to give cell identity 3 × 107 + 0 = 321, the value the transmitter used.*

$$
\begin{aligned}
N_{ID}^{\mathrm{cell}}&=3N_{ID}^{(1)}+N_{ID}^{(2)}\\
&=3\times107+0\\
&=321.
\end{aligned}
$$

The two detected components determine one dimensionless physical cell identity.

| Symbol | Value and range | Meaning |
| --- | --- | --- |
| $N_{ID}^{(1)}$ | 107; 0 to 335 | SSS group index |
| $N_{ID}^{(2)}$ | 0; 0 to 2 | PSS component |
| $N_{ID}^{\mathrm{cell}}$ | 321; 0 to 1007 | Resulting physical cell identity |

A detected PSS leaves 336 possible identities. SSS resolves that identity, while complete radio frame timing still requires the block index and broadcast timing information.

Inspect the extracted SSB against the transmitted resource map: occupied regions remain visible, while noise also fills positions that were empty at transmission. The channel estimator will use the reference positions within this received grid.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 12 Received SSB v1.png|SSB extracted from the received waveform]]

*MATLAB result — abs(rx.grid). The four extracted symbols include noise on unused elements as well as occupied elements.*

### 3.5 Resolve the block index and estimate the PBCH channel

The identity fixes the reference signal the broadcast channel was sent with, up to the block index. This section resolves that index and estimates the channel from the reference elements.

The PBCH DM-RS changes with identity and block index. With eight candidate blocks in this setup, the receiver constructs eight references and compares the resulting channel to noise scores. It then uses the selected reference to estimate the channel for PBCH demodulation.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 11 DMRS Hypotheses v1.png|Eight PBCH reference hypotheses]]

*MATLAB result — rx.dmrsScores. Index zero gives the strongest score. The scoring rule belongs to the receiver; the candidate sequences are specified.*

PBCH DM-RS initialization depends on identity and block index. [TS 38.211 V18.9.0, §7.4.1.4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) defines:

$$
\begin{aligned}
c_{\mathrm{init}}={}&2^{11}(\bar i_{\mathrm{SSB}}+1)
(\lfloor N_{ID}^{\mathrm{cell}}/4\rfloor+1)\\
&+2^6(\bar i_{\mathrm{SSB}}+1)
+(N_{ID}^{\mathrm{cell}}\bmod4)\\
={}&2048\times1\times81+64\times1+1\\
={}&165953.
\end{aligned}
$$

The accepted block index and cell identity set the dimensionless reference sequence seed.

| Symbol | Value | Meaning and source |
| --- | --- | --- |
| $c_{\mathrm{init}}$ | 165953 | Seed for the pseudo-random sequence generator |
| $\bar i_{\mathrm{SSB}}=0$ | Eight candidate positions | Accepted reference index |
| Cell identity | 321 | Identity recovered from PSS and SSS |
| Powers of two | 2¹¹ and 2⁶ | Weights fixed by TS 38.211 §7.4.1.4.1 |

Floor and modulo are integer operations. nrPBCHDMRS generates the resulting 144 reference symbols.

Comparing those reference symbols with their received values gives the channel estimate. In the magnitude plot, departures from the unit propagation channel expose noise and receiver error in this setup.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 13 Channel Magnitude v1.png|Estimated channel magnitude]]

*MATLAB result — abs(rx.channelEstimate). This AWGN setup has a unit propagation channel; variation in the estimate reflects noise and receiver error.*

The phase plot adds the part of the channel estimate that magnitude cannot show. Compare its traces across SSB symbols to inspect the residual rotation that equalization must accommodate.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 14 Channel Phase v1.png|Estimated channel phase]]

*MATLAB result — channel phase in radians. The four traces correspond to the four SSB symbols and include the residual phase that equalization must handle.*

Minimum Mean Square Error (MMSE) equalization uses the channel and noise variance estimated from the received DM-RS. The constellations compare PBCH symbols before and after equalization at the same input SNR.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 15 Received PBCH v1.png|PBCH constellation before equalization]]

*MATLAB result — rx.pbchReceived. The 432 PBCH resource elements extracted from the received grid before equalization, plotted in the complex plane. The channel phase and noise have spread the QPSK points into clouds; the DM-RS channel estimate of the next step is what turns them back into decisions.*

Applying the estimated channel and noise variance gives the constellation below. Compare the recovered QPSK regions with the preceding received constellation; the remaining spread becomes uncertainty in the decoder input.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 16 Equalized PBCH v1.png|PBCH constellation after equalization]]

*MATLAB result — rx.pbchEqualized. The same 432 symbols after DM-RS channel estimation and equalization, back in four QPSK regions. The residual scatter is noise plus estimation error, and it becomes the soft-bit uncertainty that the polar decoder of TS 38.212 §7.1 must resolve.*

The error vector plot measures this spread symbol by symbol against transmitted truth. It is an evaluation diagnostic; the decoder receives soft values computed from the equalized observations.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 29 PBCH Error Vector v1.png|Error vector per equalized PBCH symbol]]

*Each point is the distance between an equalized PBCH symbol and the symbol that was transmitted; the RMS line gives the error vector magnitude the decoder had to tolerate.*

### 3.6 Decode BCH and interpret the recovered fields

The equalised broadcast symbols are ready for decoding. This section decodes them and reads the recovered fields, the frame number above all.

The Broadcast Channel (BCH) coding chain connects a formatted message to PBCH symbols. Abstract Syntax Notation One (ASN.1) defines the MIB fields. The experiment explicitly packs one BCCH-BCH CHOICE bit plus 23 MIB bits before calling nrBCH; it checks the field positions against [TS 38.331 V18.10.0, §§6.2.1–6.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).

| Representation | Length | Implementation | Source |
| --- | --- | --- | --- |
| Formatted BCCH-BCH message | 24 bits | t.mibBits | 38.331 §6.2.2 |
| Augmented BCH payload | 32 bits | nrBCH payload generation | 38.212 §7.1.1 |
| Payload plus Cyclic Redundancy Check (CRC) | 56 bits | CRC24C attachment | 38.212 §7.1.3 |
| Polar code and rate matching | 512 → 864 bits | nrBCH | 38.212 §§7.1.4–7.1.5 |
| Quadrature Phase Shift Keying (QPSK) | 432 symbols | nrPBCH | 38.211 §§5.1.3 and 7.3.3 |

The length table omits two operations that preserve bit count. BCH payload interleaving and scrambling follow [TS 38.212 V18.8.0, §§7.1.1–7.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip). PBCH applies its separate scrambling operation before modulation under [TS 38.211 V18.9.0, §7.3.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); for this case with eight candidate positions, its sequence segment depends on three SSB index bits.

!note[The receiver passes Log-Likelihood Ratios (LLRs) to nrBCHDecode, retaining bit signs and reliability information. It weights these soft values using the equalizer's reliability output and uses a decoder list length of eight. These are receiver choices in the delivered implementation.]

The soft value histogram shows how strongly the demodulator favors its bit decisions. Values near zero carry little confidence and leave more work to the polar decoder.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 17 Soft Bits v1.png|Distribution of PBCH decoder soft values]]

*MATLAB result — rx.softBits. Sign favors a bit value; magnitude expresses confidence. The histogram contains 864 soft values.*

The agreement plot compares those signs with the transmitted coded bits during evaluation. Disagreeing positions show the errors present before decoding, providing a baseline for the recovered message check.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 28 Coded Bit Agreement v1.png|Soft-value sign agreement with the transmitted coded bits]]

*Before polar decoding, the sign of each soft value is compared with the transmitted coded bit; the decoder must repair the disagreeing positions using the code structure.*

After decoding, compare the recovered formatted message with the transmitted message in the bit plot below. Agreement at this stage verifies payload recovery for this capture; field parsing then gives the configuration needed for further reception.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 18 MIB Bit Recovery v1.png|Transmitted and recovered message bits]]

*MATLAB result — exact comparison of transmitted and recovered formatted message bits, including CHOICE and spare bits. Correct field structure comes from the packing checked against TS 38.331, independently of this equality test.*

The System Frame Number (SFN) combines six high bits from MIB with four low bits added during BCH payload processing. The accepted example reconstructs:

$$
\begin{aligned}
\mathrm{SFN}&=16b_{\mathrm{high}}+b_{\mathrm{low}}\\
&=16\times26+10\\
&=426.
\end{aligned}
$$

The decoded high and low bit groups reconstruct the frame count.

| Symbol | Value and unit | Meaning |
| --- | --- | --- |
| $b_{\mathrm{high}}=26$ | Dimensionless integer | Decoded from the six MIB bits |
| $b_{\mathrm{low}}=10$ | Dimensionless integer | Decoded from the four additional physical layer bits |
| 16 | Dimensionless multiplier | Shifts the value represented by six bits by four binary places |
| SFN | 426; frame count modulo 1024 | Reconstructed system frame number |

Sources: [TS 38.331 V18.10.0, §6.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) and [TS 38.212 V18.8.0, §7.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).

The field comparison checks the parsed frame and control configuration against transmitted truth. These values turn successful bit recovery into a usable input for locating system information.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 26 Recovered Fields v1.png|Recovered broadcast field values]]

*MATLAB result — parsed fields agree with the transmitter: frame 426, common spacing 30 kHz, DM-RS Type-A position 2 and pdcch-ConfigSIB1 value zero.*

The MIB's control configuration and recovered $k_{\mathrm{SSB}}=0$ constrain the Control Resource Set (CORESET) and monitoring occasions for the next stage. The Common Resource Block (CRB) offset callout in Star-16 motivates this handoff, but the absolute Point A location still requires later configuration such as offsetToPointA. [TS 38.211 V18.9.0, §7.4.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) distinguishes these offsets. [ShareTechnote's PBCH decoding page](https://www.sharetechnote.com/html/5G/5G_PBCH_Decoding.html) provides an engineering reading order; [its MIB/SIB page](https://www.sharetechnote.com/html/5G/5G_Mib_Sib.html) explains the fields. Field meanings remain tied to the frozen specifications above.

## 4. Repeated experiments and observed failures

**Stage — Measured results.**

Sections 3.1 to 3.6 followed one capture. This section repeats the experiment many times across noise levels to see how often recovery succeeds and where it fails.

The example verifies one use of the acquisition interface; repeated captures measure recovery under the selected assumptions. The pilot evaluates eight SNR levels with 40 trials per level. Each trial draws an integer delay from 0 to 511 samples and a frequency offset uniformly within ±45 kHz. Seeds are independent within each SNR level and reused between levels, making comparisons across SNR paired.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 19 Acquisition Success v1.png|Acquisition success and Wilson confidence intervals]]

*MATLAB result — summary.csv. Bars are pointwise Wilson 95% intervals. Complete recovery checks CRC, PCI, SSB index, all message bits, SFN, half frame and the reconstructed SSB offset.*

| Active-RE SNR | Complete recoveries | Wilson 95% interval | Interpretation |
| --- | --- | --- | --- |
| −18, −14 or −10 dB | 0/40 at each level | 0–8.76% | No complete message in this sample |
| −6 dB | 35/40 | 73.89–94.54% | Acquisition failures remain frequent |
| −2, 2, 6 or 10 dB | 40/40 at each level | 91.24–100% | This sample has no failures; reliability is not proven perfect |

!important[The example at 8 dB estimates 23,642.77 Hz for an injected 23,700 Hz and finds the exact SSB start at sample 1241. The statistical curves use the full saved trial set.]

The stage comparison explains where complete recovery is lost. Compare correct identity decisions with accepted messages at the same SNR; the gap measures failures after identity detection.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 24 Stage Bottleneck v1.png|Identity success compared with complete acquisition]]

*MATLAB result — stage counts. At −10 dB, 17/40 trials identify PCI correctly while 0/40 complete message recovery. A detected cell is not yet a usable broadcast configuration.*

The outcome chart separates those failures by their stopping point. The capture length category identifies searches whose timing estimate leaves too few recorded samples to extract the block.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 31 Outcome Classes v1.png|How the 320 trials ended, per SNR]]

*Each SNR column stacks the four ways a trial ended; the capture-length failures dominate at low SNR because a false timing peak places the block beyond the recorded samples.*

For captures that pass the complete recovery check, the frequency error curve measures residual estimation accuracy. Read it alongside the success plot, since rejected captures do not enter this conditional statistic.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 20 Frequency Error v1.png|Frequency error among successful acquisitions]]

*MATLAB result — conditional Root Mean Square Error (RMSE). Only successful trials enter this curve: 35 at −6 dB and 40 at each higher level. Failed acquisitions are excluded from this error statistic and remain visible in the success plot.*

The timing plot applies the same successful capture selection to integer sample error. Its marker counts reveal how many recoveries share an offset, including exact timing recovery.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 21 Timing Error v1.png|Timing error among successful acquisitions]]

*MATLAB result — timing errors of the successful trials. Marker size and the number beside each marker give how many trials share that SNR and integer error, so the reader can see that most recoveries land on the exact start sample.*

The individual error panels expose variation hidden by an average: frequency estimates remain dispersed even when timing lands on the exact sample. Their common selection of successful captures preserves the interpretation of the preceding curves.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 30 Error Scatter v1.png|Frequency error against timing error for every successful trial]]

*MATLAB result — trials.frequencyErrorHz and trials.timingErrorSamples for the 195 successful trials. The upper panel spreads each trial's residual frequency error over its SNR with the RMS drawn as a black bar; the lower panel counts how many successful trials ended with each integer timing error. Timing is already exact at the lowest SNR while the frequency error keeps shrinking as SNR rises.*

Plotting estimated offset against injected offset checks the correction across the tested frequency range. Inspect distance from the equality line to distinguish accurate tracking from a result that merely falls inside the search interval.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 25 CFO Estimates v1.png|Injected and estimated frequency offsets]]

*MATLAB result — 40 trials at 6 dB. The dashed line is equality, so displacement from it directly shows estimation error.*

The two stress experiments test frequency correction and the configured search range. Disabling frequency correction changes the decoding outcome; moving the frequency far beyond the configured search range tests a different receiver assumption.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 22 CFO Stress v1.png|Frequency correction enabled and disabled]]

*MATLAB result — stress.csv. Every bar contains ten trials at 8 dB. The 120 kHz case is outside the coarse search interval; these comparisons diagnose acquisition failures and provide limited information about rare failures.*

Removing the transmitted signal tests whether the receiver accepts noise as a broadcast message. The plot reports the observed acceptances together with their uncertainty, so an empty error count cannot be read as proof that false acceptance is impossible.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - 23 Noise Only v1.png|Noise-only CRC acceptance and uncertainty]]

*MATLAB result — 0/40 noise-only CRC acceptances, with a Wilson upper endpoint of 8.76%. The receiver always selects a correlation maximum; this is not a 3GPP detector conformance test.*

> [!warning] Failure — a plausible intermediate output can still be wrong
> Correlation produces an identity candidate even from noise. CRC acceptance reduces this risk but does not mathematically eliminate undetected errors. The teaching test therefore compares all recovered fields with known transmitted values, while a deployed receiver would need its own acquisition and consistency policy.

## 5. Engineering choices and reproducibility

**Stage — Reproduce and references.**

The statistics of Section 4 hold under the assumptions the setup declared. This section lists those choices, their consequences, and the next controlled test for each.

The current evidence supports a working acquisition interface under a declared baseband model. The next experiment should change one assumption at a time so that a loss of decoding can be assigned to a stage.

| Choice | Current implementation | Consequence | Next controlled test |
| --- | --- | --- | --- |
| Candidate search | 3 PSS × 9 frequency candidates | Bounded search cost and capture interval | Widen CFO range or change grid step |
| Fine estimator | Interior CP samples | Sensitive to noise, timing and residual range | Add sample clock error or multipath |
| Channel estimate | PBCH DM-RS only | Practical estimate; no true channel supplied | Frequency selective fading |
| Observation | One active SSB | No burst combining or cell competition | Repeated blocks and multiple cells |
| Acceptance statistics | 40 trials per SNR | Wide intervals near zero or one | Increase trials before a reliability claim |

> [!matlab] MATLAB — reproducible execution
> Open the companion [MATLAB README](<../matlab/uni01/README.md>), run the nine acceptance tests, then run the pilot. The web preview provides an experiment download. Configuration, software version, random seeds, source hashes, raw trial data and figure scripts travel with the results.

~~~matlab
results = runtests('test_uni01.m');
assertSuccess(results)
out = run_uni01('pilot');
~~~

Run run-20260907-002810 produced the figures and numerical results in this note. Its nine tests cover a noiseless round trip, timing and frequency estimation, all three PSS identities, the independent PSS recurrence, required experiment functions, implementation availability, checks of all acquired fields, rejection of an unsupported SSB setup, and uncertainty from finite samples. Receiver estimates come from samples; truth enters uni01_accept only after decoding.

| Reported result | Exact evidence location | How it is obtained |
| --- | --- | --- |
| Example identity, SFN and timing | summary.json, example | Parsed receiver output |
| Success counts and intervals | summary.csv; trials.csv | Field predicate followed by Bernoulli counts |
| Frequency and timing RMSE | summary.csv | Errors over successful trials only |
| Frequency stress outcome | stress.csv | Matched correction-on and correction-off trials |
| Every scientific image | run.mat; figures/catalog.json | uni01_plots regenerates the saved arrays |

!warning[The setup omits multipath, an analog front end, competing cells and a search across the full frequency raster. It does not yet establish SIB1 reception. These boundaries define the next work in Uni-02 and Uni-03 and the interfaces that Uni-08 will integrate.]

## 6. Implementation flow and the next interface

**Stage — Reproduce and references.**

Section 5 named what was chosen. This section draws the whole chain, definitions beside executable stages, and says what the next experiment receives.

The complete chain below puts executable stages beside their governing definitions. Solid arrows show execution and data transfer; dashed arrows show how a parameter or equation controls a later operation. The estimator is labelled as an engineering choice so it cannot be mistaken for a mandatory 3GPP receiver.

![[99 Attachments/5G/Uni Labs/Uni-01/Uni-01 - Implementation Flow v1.png|Implementation flow with equations and official sources]]

*Original schematic. Sequence search, frequency correction, identity recovery, reference selection and BCH decoding produce fields for the next experiment on control channel reception. The compact labels $N_1$, $N_2$ and $N_{\mathrm{cell}}$ mean $N_{ID}^{(1)}$, $N_{ID}^{(2)}$ and $N_{ID}^{\mathrm{cell}}$ from Section 3; the estimator's $r$ denotes the coarsely corrected samples called $z$ there.*

The next interface receives the detected SSB timing, PCI, spacing, offset, block index and MIB control configuration. It must turn those fields into a monitored control region and a decoded SIB1; successful MIB recovery alone does not validate that later step.

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

The specifications fix the signal and message. The textbook and engineering pages explain why their stages fit together; the saved MATLAB data support the reported experimental results.

### 7.1 References

The sources, in the order the note used them.

- 3GPP. **TS 38.211 V18.9.0**, §§5.3.1, 7.3.3, 7.4.1.4, 7.4.2 and 7.4.3. [Official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
- 3GPP. **TS 38.212 V18.8.0**, §7.1. [Official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
- 3GPP. **TS 38.213 V18.8.0**, §4.1. [Official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
- 3GPP. **TS 38.331 V18.10.0**, §§6.2.1–6.2.2. [Official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).
- Dahlman, E., Parkvall, S. and Sköld, J. **5G NR: The Next Generation Wireless Access Technology**, second edition, Chapter 16, pp. 335–347. [Chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7).
- MathWorks. **NR Cell Search and MIB and SIB1 Recovery**. [Official example](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html). Accessed 2026-09-06.
- MathWorks. **SNR Definition Used in Link Simulations**. [Official definition](https://www.mathworks.com/help/5g/ug/snr-definition-used-in-link-simulations.html). Accessed 2026-09-07.
- ShareTechnote. **PBCH Decoding** and **MIB/SIB**. [Decoding page](https://www.sharetechnote.com/html/5G/5G_PBCH_Decoding.html); [field guide](https://www.sharetechnote.com/html/5G/5G_Mib_Sib.html). Accessed 2026-09-06; linked and paraphrased.
- Course sources: [[Star-07-Overall-Transmission-Structure]], [[Star-09-Transport-Channel-Processing]], [[Star-16-Cell-Search-and-System-Information]], [[Star-29-TS-38.211-Physical-Channels-and-Modulation]] and [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding]]. Their contributions are mapped in Section 1.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.211 V18.9.0, §7.4.2.2.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=146); [TS 38.211 V18.9.0, §7.4.3.1; Table 7.4.3.1-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=148). Accessed 2026-09-08.

### 7.2 Abbreviation index

Definitions and sources: [[5G Abbreviation Database]].

| Abbreviation | Full term |
| --- | --- |
| 3GPP | Third Generation Partnership Project |
| 5G | Fifth Generation |
| 5GC | 5G Core network |
| UE | User equipment |
| gNB | next generation NodeB |
| NR | New Radio |
| FR1 | Frequency range 1 |
| RB (PHY) | Resource block |
| RE | Resource element |
| OFDM | Orthogonal frequency-division multiplexing |
| PSS | Primary synchronization signal |
| SSS | Secondary synchronization signal |
| SSB | Synchronization signal and PBCH block |
| PCI | Physical cell identity |
| PBCH | Physical broadcast channel |
| DM-RS | Demodulation reference signal |
| BCH | Broadcast Channel |
| BCCH | Broadcast Control Channel |
| MIB | Master information block |
| SIB1 | System information block type 1 |
| CORESET | Control resource set |
| CRB | Common Resource Block |
| SFN | System frame number |
| CRC | Cyclic redundancy check |
| QPSK | Quadrature phase-shift keying |
| SCS | Subcarrier spacing |
| CP | Cyclic prefix |
| CFO | Carrier Frequency Offset |
| FFT | Fast Fourier transform |
| IFFT | Inverse fast Fourier transform |
| ASN.1 | Abstract Syntax Notation One |
| AWGN | Additive White Gaussian Noise |
| SNR | Signal-to-Noise Ratio |
| MMSE | Minimum Mean Square Error |
| LLR | Log-likelihood ratio |
| RMSE | Root Mean Square Error |
| I/Q | In-phase and Quadrature |
| RF | Radio frequency |
| TS | Technical Specification |
| MATLAB | Matrix Laboratory |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with value, unit and where each applies.

| Symbol | Meaning | Unit or range | First calculation |
| --- | --- | --- | --- |
| $F_s$ | Complex sample rate | 15.36 Msamples/s | 3.1 |
| $T_s$ | Sample interval used in the overview | $1/F_s$ seconds | Overview |
| $N_{\mathrm{FFT}}$ | Transform length | 512 samples | 3.1 |
| $\Delta f$ | Subcarrier spacing | 30 kHz | 3.1 |
| $s[n]$, $y[n]$, $w[n]$ | Transmitted sample, received sample and additive noise | Normalized complex amplitude | 3.1 |
| $n,d$ | Sample index and injected delay | Samples; $d=137$ in the example | 3.1 |
| $f_0$, $\widehat f$, $\widehat f_{\mathrm{fine}}$ | Injected, estimated total and estimated residual frequency offsets | Hz; positive for forward phase rotation | 3.1 and 3.3 |
| $\sigma_w^2$ | Total complex time sample noise variance | Normalized power | 3.1 |
| $j,\pi$ | Imaginary unit and circle constant | Dimensionless | 3.1 |
| $x(i)$, $m$, $d_{\mathrm{PSS}}(n)$ | Binary recurrence, shifted index and PSS sequence | Bits, index, normalized amplitude | 3.2 |
| $N_{ID}^{(1)}$, $N_{ID}^{(2)}$, $N_{ID}^{\mathrm{cell}}$ | SSS component, PSS component and complete cell identity | 0–335; 0–2; 0–1007 | 3.2 and 3.4 |
| $z[n],C,\mathcal C$ | Coarsely corrected samples, CP correlation sum and selected CP positions | Complex amplitude; amplitude squared; index set | 3.3 |
| $n_{\mathrm{ref}}$, $L_{\mathrm{ref},0}$, $n_{\mathrm{SSB}}$ | Reference origin, first reference symbol length and SSB CP start | Zero-based received sample reference | 3.3 |
| $c_{\mathrm{init}},\bar i_{\mathrm{SSB}}$ | PBCH DM-RS seed and candidate index | Integer; index 0–7 in this setup | 3.5 |
| $k_{\mathrm{SSB}}$ | Subcarrier offset within the common-grid mapping | Zero in this setup; defined by 38.211 §7.4.3.1 | 1 |
| $b_{\mathrm{high}},b_{\mathrm{low}}$ | Six high and four low SFN bits interpreted as integers | 0–63 and 0–15 | 3.6 |
| $\mathrm{SFN}$ | Reconstructed system frame number | Frame count modulo 1024 | 3.6 |
