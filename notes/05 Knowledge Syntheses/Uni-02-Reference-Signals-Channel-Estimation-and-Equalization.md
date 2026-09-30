---
title: Uni-02 — Reference signals, channel estimation and equalization
type: knowledge_synthesis
language: en
uni: 2
release_baseline: 18
cssclasses:
- research-note-tables
lab_run: run-20260907-120305
---

# Uni-02 — Reference signals, channel estimation and equalization

!important[A receiver uses known reference symbols to recover data after propagation changes its amplitude and phase. This experiment generates a Physical Downlink Shared Channel (PDSCH), inserts its Demodulation Reference Signal (DM-RS), applies a frequency selective channel, and measures how practical channel estimation changes recovered bits. A coded setup recovers all 3,624 transport bits with a passing Cyclic Redundancy Check (CRC), then fails when the receiver uses the wrong reference identity.]

Press Ctrl+F (Command+F on a Mac) to jump to any stage. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

The overview places pilot observations beside the data they help recover.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - System Overview v1.png]]

*Original schematic: known pilots constrain a channel estimate before equalization. The pictured path geometry and grid pattern are schematic.*

Searchable structure: reference configuration → pilot mapping → faded observations → channel estimate → equalized data → payload CRC.

## 1. Reference signals in the downlink system

**Stage — Textbook workflow.**

The overview above showed pilots constraining a channel estimate before equalisation. This section says which notes supply the knowledge for each step and what the three reference signal families do.

The next generation NodeB (gNB) supplies data and reference symbols on a common resource grid. User Equipment (UE) reconstructs the reference sequence from its configuration. Dividing a received pilot by its known transmitted value gives an observation of the channel. The receiver must infer the response between observations before demodulating the data.

These course sources supply the knowledge used at each implementation stage.

| Star source | Knowledge used | Implementation |
| --- | --- | --- |
| [[Star-07-Overall-Transmission-Structure\|Transmission structure]] | Slots and subcarriers | Carrier and grid arrays |
| [[Star-08-Channel-Sounding\|Channel sounding]] | Measurement purpose | Distinguish reference families |
| [[Star-09-Transport-Channel-Processing\|Transport processing]] | Modulation and decoding | PDSCH payload setup |
| [[Star-25-RF-Characteristics\|Radio characteristics]] | Impairment reference planes | Noise and error measurements |
| [[Star-29-TS-38.211-Physical-Channels-and-Modulation\|Physical channels]] | Reference sequences and mapping | DM-RS symbols and indices |
| [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data\|Data procedures]] | Allocation and transport size | Coded setup settings |

A Channel State Information Reference Signal (CSI-RS) supports measurements used for transmission decisions. DM-RS supports demodulation of a scheduled channel. A Phase Tracking Reference Signal (PT-RS) supports tracking of phase variation when configured. These jobs connect the Chapter 8 note ([[Star-08-Channel-Sounding|Star-08]]) with the Chapter 9 note ([[Star-09-Transport-Channel-Processing|Star-09]]) of this knowledge base. Transmitted PDSCH reference definitions are [TS 38.211 V18.9.0, §§7.4.1.1 and 7.4.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

## 2. Protocol settings and the experiment boundary

**Stage — 3GPP protocol.**

Section 1 gave the sources. This section fixes the boundary: what the standard defines, what is an engineering choice, and the values chosen for the experiment.

The standard defines the transmitted symbols and their resource positions. The channel model, interpolation, equalizer and trial count are engineering choices. 

The values below were chosen for the experiment. The fixed configuration below determines the resource arrays.

| Parameter | Local value | MATLAB setting | Source |
| --- | --- | --- | --- |
| Carrier grid | 24 resource blocks | NSizeGrid | Engineering window |
| Subcarrier spacing | 30 kHz | SubcarrierSpacing | 38.211 §4.2 |
| Data | One layer; QPSK | NumLayers; Modulation | 38.211 §7.3.1 |
| Allocation | PRBs 0–23; symbols 0–13 | PRBSet; SymbolAllocation | Engineering choice |
| DM-RS | Type 1; start 2; length 1 | DMRS configuration | 38.211 §7.4.1.1.2 |
| Additional positions | 0 or 2 | DMRSAdditionalPosition | 38.211 mapping tables |
| Reference identity | 42; failure uses 43 | NIDNSCID | 38.211 §7.4.1.1.1 |
| Data identities | 42 and 7 | NID; RNTI | 38.211 §7.3.1.1 |

Quadrature Phase Shift Keying (QPSK) carries two bits per modulation symbol. A Resource Element (RE) is one subcarrier during one Orthogonal Frequency Division Multiplexing (OFDM) symbol. Physical Resource Block (PRB) indices select groups of twelve subcarriers. The Radio Network Temporary Identifier (RNTI) controls data scrambling in this setup.

The receiver starts with an aligned resource grid. The two-path channel acts as a complex multiplier at each RE. This diagonal OFDM model assumes adequate cyclic prefix and synchronization and omits Intercarrier Interference (ICI). The variable DopplerHz in the files represents a common phase rate across symbols. It is an engineering stress parameter. The [MathWorks PDSCH throughput example](https://www.mathworks.com/help/5g/ug/nr-pdsch-throughput.html) supplies the broader waveform/channel implementation.

## 3. Generate known symbols and map their resources

**Stage — 3GPP protocol.**

Section 2 chose the configuration. This section generates the known symbols the receiver will rely on and places them on the grid.

The receiver needs both pilot values and their locations. nrPDSCHDMRS supplies the values; nrPDSCHDMRSIndices supplies their positions.

### 3.1 Sequence generation and resource accounting

The first step is the pilot sequence itself: how the binary sequence becomes complex symbols and how many resource elements they occupy.

The binary sequence becomes a complex reference through [TS 38.211 V18.9.0, §7.4.1.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip):

$$
r(m)=\frac{1-2c(2m)}{\sqrt{2}}+
j\frac{1-2c(2m+1)}{\sqrt{2}}.
$$

Here $r(m)$ is reference symbol $m$ with normalized complex amplitude; $m$ is a nonnegative index; $c(i)$ is binary pseudo-random sequence element $i$ from §5.2.1; and $j^2=-1$. The factor $1/\sqrt{2}$ gives unit symbol energy. Multiplication by two converts each binary value into a sign: zero gives +1 and one gives −1. Initialization depends on slot, symbol and identity; the Toolbox performs this official initialization.

Generating the first 72 references tests the sequence configuration before propagation is introduced. Compare the real and imaginary sign changes with the sequence rule beside them; these are the known values that the receiver must regenerate for pilot division.


External source: [7.4.1.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.1.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=128), printed page 127. The reference sequence and its initialization define known transmitted DM-RS symbols. The receiver estimation and interpolation method is an implementation choice.*


![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 02 DMRS sequence v2.png]]

*MATLAB result from b.dmrs: real and imaginary parts of the first 72 DM-RS symbols generated by nrPDSCHDMRS. Every value is ±1/√2, so each pilot is one QPSK point produced by the r(m) rule of TS 38.211 §7.4.1.1.1; the pseudo-random sign pattern is what the receiver regenerates from identity 42.*


Plotting the same references in the complex plane checks their amplitude as well as their signs. The four points in the constellation establish the constant modulus used in the pilot division equation later.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 03 DMRS constellation v2.png]]

*MATLAB result from b.dmrs: all 432 pilot symbols fall on the four constant-modulus QPSK points. A pilot of known magnitude one lets the receiver divide the received value by it without amplifying noise, which is why the standard fixes the pilot alphabet.*

The type 1 port offsets and weights determine the reference positions inside the data allocation. In the resource map, compare the columns labeled 2 for DM-RS with the surrounding data labeled 1; the axes count from zero, and the resource counts determine the bit capacity calculated next.


External source: [7.4.1.1.2; Table 7.4.1.1.2-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §7.4.1.1.2; Table 7.4.1.1.2-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=132), printed page 131. Configuration type 1 specifies port offsets and orthogonal weights used with the resource mapping equations; the laboratory selects port 1000.*


![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 01 Resource map v2.png]]

*MATLAB result from b.mask: one slot of the 24-PRB grid with OFDM symbols across and subcarriers up; value 1 marks data and value 2 marks DM-RS. The three pilot columns at symbols 2, 7 and 11 are the type 1 mapping with two additional positions from TS 38.211 §7.4.1.1.2; every other resource element carries PDSCH data.*


For this configuration, six reference REs per PRB occupy each of three DM-RS symbols. The resource calculation is:

$$
\begin{aligned}
N_{\mathrm{DMRS}}&=24\times6\times3=432\ \mathrm{RE},\\
N_{\mathrm{data}}&=24\times12\times14-432=3600\ \mathrm{RE},\\
G&=2N_{\mathrm{data}}=2\times3600=7200\ \mathrm{bit}.
\end{aligned}
$$

Here $N_{\mathrm{DMRS}}$ and $N_{\mathrm{data}}$ are pilot and data counts (program output, checked by hand). The dimensionless counts 24, 12 and 14 are allocated PRBs, subcarriers per PRB and symbols per slot. Six is the type 1 pilot count for the selected port and group without data; three is the mapped DM-RS symbol count. $G$ is rate matched bit capacity; QPSK supplies the factor two. Mapping follows [TS 38.211 V18.9.0, §7.4.1.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

The local resource table retains the quantities required by coding.

| Symbol | Value and unit | Evidence | Where it applies |
| --- | --- | --- | --- |
| $N_{\mathrm{DMRS}}$ | 432 RE | Program output and arithmetic | Transmit grid |
| $N_{\mathrm{data}}$ | 3600 RE | Program output and arithmetic | Transmit grid |
| $G$ | 7200 bit | Calculated | PDSCH codeword |

The transmitter fills those positions with data and reference symbols before applying the channel. Read the phase levels in the populated grid as the transmitted reference for the later channel phase and received constellation; occupied REs have unit magnitude.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 04 Transmitted grid v2.png]]

*MATLAB result from b.tx: phase in radians of every occupied element of the transmit grid. The QPSK data elements take one of four phase levels and the DM-RS columns carry their own known phases; all occupied elements have unit magnitude, and this array is what nrOFDMModulate turns into the time waveform.*

### 3.2 Optional phase reference mapping

Section 3.1 mapped the demodulation reference signal. This section maps the optional phase tracking signal too, so that the cost of tracking phase is visible even though the trials do not use it.

PT-RS sequence and mapping follow [TS 38.211 V18.9.0, §§7.4.1.2.1–7.4.1.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip). The setup generates a candidate with time density 1 and frequency density 2. It does not transmit or use PT-RS in the receiver trials.

Value 3 marks 132 optional PT-RS positions that would displace data.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 23 Optional PTRS map v2.png]]

*MATLAB result from b.ptrsIndices: value 3 marks the 132 positions that PT-RS would occupy with time density 1 and frequency density 2 under TS 38.211 §7.4.1.2.2. The setup only generates these candidates; the trials do not transmit PT-RS, so the map shows the data that phase tracking would cost.*

The [ShareTechnote DM-RS guide](https://www.sharetechnote.com/html/5G/5G_PDSCH_DMRS.html) supplies further configuration illustrations. The counts above come from the local Toolbox arrays.

## 4. Estimate the channel and recover the payload

**Stage — MATLAB experiment.**

Section 3 placed known pilots on the transmit grid. This section sends the grid through a controlled channel and uses those pilots to recover the channel and then the payload.

!important[A known pilot removes the unknown transmitted symbol from the received observation. Noise and interpolation then determine the quality of the channel estimate.]

### 4.1 A controlled faded channel

Before estimating anything, the channel must be defined. This section builds the two-path channel with a common phase rotation.

Two paths create repeated frequency fades. Their response is multiplied by a common phase:

$$
\begin{aligned}
H[k,l]&=\frac{1+0.72e^{-j2\pi k/96}}{\sqrt{1+0.72^2}}
e^{j(\phi+2\pi f_{\phi}t_l)},\\
t_l&=l(0.5\ \mathrm{ms})/14,\\
y[k,l]&=H[k,l]x[k,l]+n[k,l].
\end{aligned}
$$

Here $H[k,l]$ is dimensionless channel gain; $k=0,\ldots,287$ selects a subcarrier and $l=0,\ldots,13$ a symbol. $x,y,n$ are normalized transmitted, received and noise amplitudes. The second-path amplitude is assumed to be 0.72 relative to the first; 96 subcarriers is its response period. The denominator normalizes average channel power. $\phi$ is an independently drawn common phase in radians; $f_{\phi}$ is the phase rate in hertz; $t_l$ is a uniform symbol-time approximation in seconds. The leading 1 is the first-path amplitude reference; the 2π factor converts cycles to radians. The assumed 0.5 ms slot duration corresponds to 30 kHz normal-prefix numerology, and division by 14 distributes it uniformly across symbols. These are engineering equations.

Evaluating the channel equation over the slot gives the magnitude map below. Its repeated dark rows locate the fades that should also be visible in the received grid, so the receiver can be assessed against a known pattern of attenuation.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 05 True channel magnitude v2.png]]

*MATLAB result from b.H, evaluation only: magnitude of the two-path channel over 288 subcarriers and 14 symbols. Fades repeat every 96 subcarriers because of the second path's delay; the pattern does not change across symbols because only a common phase rotates in time.*

The magnitude pattern stays fixed while the common phase evolves across symbols. The phase map reveals that rotation, wrapped in radians, and sets the temporal variation that interpolation must recover between pilot observations.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 06 True channel phase v2.png]]

*MATLAB result from b.H: phase of the same channel in radians, wrapped to ±π. The vertical bands come from the two-path structure; the slow drift along the symbol axis is the phase rate f_φ that the estimator must track from three pilot symbols.*

Multiplying the transmitted grid by this channel and adding noise produces the received amplitudes below. The attenuated rows line up with the true magnitude fades, identifying where the available observations are weakest.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 07 Received grid v2.png]]

*MATLAB result from b.rx: magnitude of the received grid at 25 dB. Rows near the channel nulls are visibly darker; these are the resource elements where the pilot observation is weakest and where estimation error will concentrate.*

Extracting only the data positions from that received grid gives the constellation below. The rotated and scaled clouds show the combined distortion that channel estimation and equalization must remove before bit decisions become useful.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 08 Received constellation v2.png]]

*MATLAB result from b.rx at the data positions: before equalization the QPSK points are rotated by the channel phase and scaled by its magnitude into clouds, so no decision boundary works yet. Equalization is the step that returns them to four regions.*

Signal-to-Noise Ratio (SNR) uses unit transmit RE energy and injected complex Additive White Gaussian Noise (AWGN) variance. At the 25 dB baseline:

$$
\begin{aligned}
\sigma_n^2&=10^{-\mathrm{SNR}_{dB}/10}\\
&=10^{-25/10}=0.00316228.
\end{aligned}
$$

Here $\sigma_n^2$ is total complex noise variance, and $\mathrm{SNR}_{dB}=25$ dB is the chosen transmit-RE reference. Each real component has half the complex variance. The coefficient 10 and base 10 follow the decibel definition for a power ratio. A deep channel fade reduces local received SNR because the setup does not renormalize each faded RE.

### 4.2 Pilot division and interpolation

Section 4.1 defined the true channel. This section observes it at the pilot positions and interpolates between them.

A Least Squares (LS) observation follows from dividing a received pilot by its known value:

$$
\widehat H_p=\frac{y_p}{x_p}=H_p+\frac{n_p}{x_p}.
$$

Here $p$ selects a pilot RE; $x_p,y_p,n_p$ are transmitted, received and noise amplitudes; $H_p$ is the true gain; and $\widehat H_p$ is the estimated gain. The equation requires a nonzero pilot. Unit pilot magnitude preserves the noise variance in this division.

Applying pilot division at the known reference positions produces the samples below. Their scatter about the true response measures the observation error before the estimator fills the gaps between pilots.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 09 Pilot channel samples v2.png]]

*MATLAB result from b.rx(dmrsIndices)./b.dmrs: least-squares channel samples at the pilot positions compared with the true channel. Each point is one pilot division Ĥp = yp/xp; the scatter around the true curve is the noise term np/xp that interpolation must average out.*

The practical estimator uses those samples to fill the complete grid. Compare its recovered fade locations with the true magnitude map; the smoother transitions reveal what interpolation changes between measured positions.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 10 Estimated channel magnitude v2.png]]

*MATLAB result from b.Hhat: the full-grid estimate produced by nrChannelEstimate from 432 pilots. Compared with the true magnitude, the fades are recovered but the transitions are smoother because the estimator interpolates between pilots.*

Subtracting the true complex response from the estimate tests both magnitude and phase together. Concentrated error in the map below identifies where an apparently plausible magnitude surface still gives less accurate compensation.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 11 Channel estimation error v2.png]]

*MATLAB result from abs(b.Hhat-b.H).^2: squared complex error per resource element. Error rises near the channel nulls and at the grid edge where interpolation has fewer neighbours; the colour scale shows it stays below 0.04 over most of the slot at 25 dB.*

A frequency slice makes those departures easier to inspect than the full surface. Follow the estimated curve through the true fade minima; this is where channel compensation is most sensitive to the estimate and the equalizer's noise term.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 12 Frequency interpolation v2.png]]

*MATLAB result from b.H(:,7) and b.Hhat(:,7): one symbol slice of true and estimated magnitude across the subcarriers. The estimate follows the fade shape; the largest departures sit at the sharp minima, which is where the MMSE equalizer's noise term protects the decision.*

!note[The experiment uses [MathWorks nrChannelEstimate](https://www.mathworks.com/help/5g/ref/nrchannelestimate.html), generated pilot indices and Code Division Multiplexing (CDM) lengths [1 1]. Its interpolation and denoising are receiver choices. The DM-RS standard does not require this particular estimator.]

### 4.3 Equalization and bit evidence

Section 4.2 produced a channel estimate on every resource element. This section uses it to equalise the data symbols and turn them into bit evidence.

!important[A Minimum Mean Square Error (MMSE) equalizer reduces noise amplification at a channel null. For one layer and unit symbol variance:]

$$
\widehat x=\frac{\widehat H^*}{\lvert\widehat H\rvert^2+\widehat{\sigma}_n^2}y.
$$

Here $\widehat x$ is the equalized symbol, $y$ the received symbol, $\widehat H$ the channel estimate, star means complex conjugation, and $\widehat{\sigma}_n^2$ is estimated noise variance. The denominator adds channel power and noise power in the same normalization. nrEqualizeMMSE implements this operation; residual gain bias is expected at low SNR.

Applying the MMSE expression to the received data produces the constellation below. The restored decision regions show that the estimated response compensates the channel, while their remaining spread is passed to soft demodulation.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 13 Equalized constellation v2.png]]

*MATLAB result from b.eq: data symbols after MMSE equalization with the practical estimate. Four compact clouds return; the residual spread is noise plus estimation error, and it is what the soft demodulator turns into likelihood ratios.*

Repeating equalization on the same received symbols with the true channel gives an evaluation reference. Comparing the cloud spread with the practical result isolates the contribution of channel estimation under the same noise realization.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 14 Oracle constellation v2.png]]

*MATLAB result from b.perfect, evaluation only: the same symbols equalized with the true channel. The difference from the previous figure isolates the loss caused by estimation alone; at 25 dB it is small, so most of the spread is noise.*

Soft demodulation turns the compensated symbols into a Log Likelihood Ratio (LLR) for each bit: a positive value favors zero and a negative one favors one. In the histogram, overlap across the decision threshold identifies evidence pointing to the wrong bit; the small overlap is consistent with the baseline recovery.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 15 Soft bit distributions v2.png]]

*MATLAB result from b.llr and b.bits: histograms of log likelihood ratios separated by the transmitted bit. Positive values favour 0 and negative favour 1; the two populations barely overlap, which is why the uncoded BER at this point is zero.*

Comparing the hard decisions with the transmitted bits checks that constellation and likelihood separation produce correct data. The baseline has no bit errors, so the error location plot has no stems; this establishes the uncoded result used to interpret the mismatch test.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 16 Bit error locations v2.png]]

*MATLAB result from b.bits ~= b.bhat: positions of uncoded bit errors along the 7,200-bit codeword. The baseline produces no errors, so the plot is empty by design; it is the reference against which the failure cases below are read.*

The coded supplement adds Downlink Shared Channel (DL-SCH) processing with Low-Density Parity-Check (LDPC) coding. Transport Block Size (TBS) comes from nrTBS and the actual allocation at target rate 0.5. The receiver scales likelihoods by equalizer Channel State Information (CSI), performs rate recovery and decoding, and checks CRC. Coding follows [TS 38.212 V18.8.0, §§7.2.1–7.2.6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip); TBS follows [TS 38.214 V18.10.0, §5.1.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).

The deterministic payload check records CRC and equality to transmitted bits.

| Receiver identity | Transport bits | Coded bits | CRC | Bit errors |
| --- | --- | --- | --- | --- |
| 42 | 3624 | 7200 | Pass | 0 |
| 43 | 3624 | 7200 | Fail | 1536 |

These are (program output) from coded-20260907-120710/summary.csv, seed 42002, at 25 dB. Two deterministic cases establish this setup's payload handoff; they do not estimate coded block error probability.

## 5. Failure cases and statistical scans

**Stage — Measured results.**

Section 4 recovered the payload in the baseline. This section breaks the receiver on purpose, first with a wrong reference identity and then with a channel that rotates too fast for the pilots.

A wrong reference identity removes the receiver's knowledge of its pilots. Increasing phase rate instead tests how long a pilot observation remains useful.

### 5.1 Reference mismatch and temporal interpolation

The first failure changes one number: the reference identity the receiver uses.

!warning[The mismatch changes only the receiver DM-RS identity from 42 to 43. Data scrambling stays correct.]

Applying the receiver with the mismatched reference identity disperses the equalized symbols even with 25 dB SNR. Compare the ring below with the baseline decision regions: the failed compensation connects the incorrect pilots to the coded payload failure reported above.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 17 Identity failure constellation v2.png]]

*MATLAB result from f.eq: equalized symbols when the receiver regenerates DM-RS with identity 43 instead of 42. The pilots no longer match, the channel estimate is wrong, and the constellation collapses into a ring even at 25 dB; scrambling was correct, so the failure is entirely the reference mismatch.*

The temporal test keeps the reference identity correct and compares pilot densities at 1000 Hz. Each estimate is measured against its own true channel; the phase error across symbols below shows whether observations remain close enough in time to track the rotation.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 18 Phase tracking v2.png]]

*MATLAB result from slow.H, slow.Hhat, fast.H and fast.Hhat: phase error of the estimate against its own true channel at a 1000 Hz phase rate, for one pilot symbol and for three. With one symbol the estimator cannot follow the rotation between symbols; three pilot symbols keep the error small across the slot.*

At 25 dB and 1000 Hz, one pilot symbol gives mean uncoded Bit Error Rate (BER) 0.33332; three symbols give 0.000018519 (program output, 30 trials per point). Their mean Root Mean Square (RMS) Error Vector Magnitudes (EVMs) are 116.96% and 17.739%. Additional observations reduce interpolation error in this model.

### 5.2 Noise, phase rate and confidence intervals

Section 5.1 showed two single failures. This section sweeps noise and phase rate over many trials so that the failures become probabilities with intervals.

The scan contains seven SNR values from 0 to 30 dB, three phase rates (0, 300, 1000 Hz), two pilot configurations and 30 trials per point: 1,260 trial realizations, with 30 independent draws within each parameter point. Data, noise and common channel phase vary with the saved seed; path amplitudes remain fixed.

The static channel slice of the scan isolates noise sensitivity. Compare the BER curves as SNR rises, with zeros plotted at the 10⁻⁶ floor; their decline establishes the baseline against which the changing phase cases are assessed.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 19 BER scan v2.png]]

*MATLAB result from summary.BER: uncoded bit error rate against SNR for the static channel and both pilot densities, 30 trials per point. Zero-error points sit on the 10⁻⁶ floor; the curves fall steeply above 10 dB, and the extra pilots cost nothing here because nothing changes in time.*

Holding SNR at 25 dB and increasing phase rate tests temporal interpolation. The separation between the EVM curves shows the symbol distortion caused by sparse pilots after the noise level has been fixed.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 20 Phase rate scan v2.png]]

*MATLAB result from summary.EVM: RMS error vector magnitude at 25 dB for phase rates 0, 300 and 1000 Hz. One pilot symbol degrades quickly with rate while three symbols stay usable, which is the case the standard's additional DM-RS positions were designed for.*

Normalized Mean Square Error (NMSE) measures channel error relative to true channel energy. Its decline with SNR in the estimation scan links improved pilot observations to a better recovered response, complementing the BER and EVM measurements of the data output.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 22 Estimation NMSE v2.png]]

*MATLAB result from summary.NMSE: normalized mean square error of the channel estimate against SNR. It falls about one decade per 10 dB, following the noise term of the least-squares division; a floor would appear only if the interpolation model mismatched the channel.*

The estimator also supplies the noise term used by MMSE equalization. Comparing its values with the injected variance across 30 static 25 dB trials checks this input independently of the recovered channel magnitude.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 24 Noise estimation v2.png]]

*MATLAB result from trials.NoiseEstimate: the estimator's noise variance in 30 static trials at 25 dB against the injected value 0.00316. The estimates scatter around the true variance; this number feeds the MMSE denominator, so its accuracy sets the equalizer's balance between gain and noise.*

A trial fails the engineering demodulation criterion when its uncoded BER exceeds 0.05. This event is distinct from transport Block Error Rate (BLER), which requires coded CRC outcomes. A 95% Wilson interval accompanies the failed-trial fraction:

$$
p_{\pm}=
\frac{\widehat p+z^2/(2N)\pm
z\sqrt{\widehat p(1-\widehat p)/N+z^2/(4N^2)}}
{1+z^2/N}.
$$

Here $\widehat p=E/N$ is the observed failure fraction, $E$ the failed-trial count, $N=30$ the trials per point, and $z=1.95996398454$ the standard-normal 97.5th percentile. $p_-,p_+$ are probability bounds. The constants 1, 2 and 4 follow from solving the quadratic score inequality for a Bernoulli proportion; they are not fitted parameters. The interval covers sampling uncertainty under the fixed model; it does not cover omitted radio effects.

The interval plot compares demodulation failures at 1000 Hz for both pilot densities.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - 21 Block failure intervals v2.png]]

*MATLAB result from summary.Failures with Wilson bounds: fraction of trials whose uncoded BER exceeds 0.05 at 1000 Hz, with 95% intervals over 30 trials. One pilot symbol fails in every trial and three symbols in none; the interval widths show what 30 trials can and cannot claim.*

!warning[At 25 dB and 1000 Hz, all 30 trials with one pilot symbol exceeded the threshold, while none with three symbols did. The corresponding Wilson bounds are [0.88649, 1] and [0, 0.11351]. Floating point roundoff near zero is displayed as zero. Zero observed failures does not establish zero population error probability.]

## 6. Reproduce the result and implement the receiver

**Stage — Reproduce and references.**

Section 5 reported numbers. This section says exactly how to reproduce them and where each number is saved.

The laboratory retains generated truth, practical receiver outputs and evaluation as separate arrays. Every plot caption names the saved field it displays.

### 6.1 Run evidence and calculation traceability

The run identifiers, software versions and saved fields behind every number above.

The run used MATLAB R2026a Update 4, version 26.1.0.3312084, and 5G Toolbox 26.1. Scripts save the twister generator, every trial seed, software inventory, log, MAT arrays, CSV summaries and SHA-256 source hashes.

From the course root, add matlab/uni02 to the MATLAB path, then run run_uni02 and run_uni02_coded. Each entry point creates a timestamped result directory. The uncoded run snapshot predates the coded supplement; each snapshot is complete for its own entry point.

The table below maps numerical claims to explicit substitutions or saved program outputs.

| Result | File or field | Reproduction | Scope |
| --- | --- | --- | --- |
| Resource counts | b.nData, b.nDMRS | §3.1 arithmetic | One grid |
| BER/EVM/NMSE | run-20260907-120305/run.mat; summary.csv | uni02_link and trial seeds | 1260 trials |
| CRC and bit equality | coded-20260907-120710/coded.mat; summary.csv | uni02_coded | Two cases |
| Figure values | visual-review/figures/catalog.json | Caption field | MATLAB arrays |
| Executed source | source-hashes.json; source/ | SHA-256 comparison | Exact run snapshot |

The published numerical plots are v2 exports from saved arrays in run-20260907-120305/visual-review. The plotting source is retained there with its own SHA-256 manifest. Re-exporting did not change the Monte Carlo results.

### 6.2 Engineering flow and limits

Section 6.1 gave the evidence; this section draws the implementation flow and states the limits of the model.

The implementation flow connects protocol configuration to practical receiver calculations. The numerical channel starts at the aligned grid, and the final step uses the coded setup to check the recovered payload and CRC.

![[99 Attachments/5G/Uni Labs/Uni-02/Uni-02 - Engineering Flow v2.png]]

*Original schematic: pilot mapping follows TS 38.211 V18.9.0 §7.4.1.1. Pilot division, interpolation and MMSE equalization are receiver choices. In the figure, x, y, H and n are normalized grid quantities; p selects a pilot; hat denotes estimation; conj denotes complex conjugation; abs denotes magnitude; sigma_n squared is noise variance. Symbol energy is one.*

The recovered 3,624-bit payload supplies a reproducible interface to later link experiments. Transfer to a moving radio link requires a waveform channel with timing, frequency offset, ICI, spatial layers and a coded BLER scan. The optional PT-RS result establishes its generated positions only.

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

These references support the definitions and implementation choices used above.

### 7.1 References

The source versions below match the frozen protocol manifest; web implementation pages were checked on 2026-09-07.

- 3GPP, [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), §§4.2, 5.2.1, 7.3.1, 7.4.1.1 and 7.4.1.2.
- 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), §§7.2.1–7.2.6.
- 3GPP, [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip), §5.1.3.2.
- MathWorks, [nrChannelEstimate](https://www.mathworks.com/help/5g/ref/nrchannelestimate.html), practical estimation.
- MathWorks, [NR PDSCH throughput](https://www.mathworks.com/help/5g/ug/nr-pdsch-throughput.html), broader waveform implementation.
- ShareTechnote, [PDSCH DM-RS](https://www.sharetechnote.com/html/5G/5G_PDSCH_DMRS.html), secondary configuration guide.
- Dahlman, Parkvall and Sköld, 5G NR: The Next Generation Wireless Access Technology, second edition, Chapters 8 and 9; local reading sources [[Star-08-Channel-Sounding|Chapter 8]] and [[Star-09-Transport-Channel-Processing|Chapter 9]].
- Course syntheses: [[Star-07-Overall-Transmission-Structure|Overall Transmission Structure]], [[Star-08-Channel-Sounding|Channel Sounding]], [[Star-09-Transport-Channel-Processing|Transport Channel Processing]], [[Star-25-RF-Characteristics|RF Characteristics]], [[Star-29-TS-38.211-Physical-Channels-and-Modulation|TS 38.211 Physical Channels and Modulation]], [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data|TS 38.214 Physical Layer Procedures for Data]].

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.211 V18.9.0, §7.4.1.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=128); [TS 38.211 V18.9.0, §7.4.1.1.2; Table 7.4.1.1.2-1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=132). Accessed 2026-09-08.

### 7.2 Abbreviation index

The course maintains the shared [[5G Abbreviation Database]].

| Abbreviation | Full term |
| --- | --- |
| AWGN | Additive White Gaussian Noise |
| BER | Bit Error Rate |
| BLER | Block Error Rate |
| CDM | Code Division Multiplexing |
| CRC | Cyclic Redundancy Check |
| CSI | Channel State Information |
| CSI-RS | Channel State Information Reference Signal |
| DL-SCH | Downlink Shared Channel |
| DM-RS | Demodulation Reference Signal |
| EVM | Error Vector Magnitude |
| gNB | Next generation NodeB |
| ICI | Intercarrier Interference |
| LDPC | Low-Density Parity-Check |
| LLR | Log Likelihood Ratio |
| LS | Least Squares |
| MMSE | Minimum Mean Square Error |
| NMSE | Normalized Mean Square Error |
| OFDM | Orthogonal Frequency Division Multiplexing |
| PDSCH | Physical Downlink Shared Channel |
| PRB | Physical Resource Block |
| PT-RS | Phase Tracking Reference Signal |
| QPSK | Quadrature Phase Shift Keying |
| RE | Resource Element |
| RMS | Root Mean Square |
| RNTI | Radio Network Temporary Identifier |
| SNR | Signal-to-Noise Ratio |
| TBS | Transport Block Size |
| UE | User Equipment |

### 7.3 Mathematical and physical symbol index

Symbols describe normalized grid quantities unless physical units are shown.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $r(m),c(i)$ | Reference symbol; sequence element | Complex; binary |
| $k,l,p$ | Subcarrier, symbol and pilot selection | Integer indices |
| $x,y,n$ | Transmitted, received and noise signals | Normalized amplitude |
| $H,\widehat H,\widehat x$ | True channel, estimated channel, equalized symbol | Complex |
| $\sigma_n^2,\widehat{\sigma}_n^2$ | True and estimated noise variance | Normalized power |
| $\phi,f_{\phi},t_l$ | Initial phase, phase rate, symbol time | rad; Hz; s |
| $N_{\mathrm{DMRS}},N_{\mathrm{data}}$ | Pilot and data counts | RE |
| $G$ | Rate matched capacity | bit |
| $j,\pi$ | Imaginary unit; circle constant | Dimensionless |
| $E,N,\widehat p$ | Failures, trials, observed fraction | Counts; probability |
| $z,p_-,p_+$ | Normal quantile; interval bounds | Dimensionless |
