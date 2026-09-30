---
type: knowledge_synthesis
title: Uni-06 — Physical Uplink Shared Channel power control and coverage
language: en
uni: 6
release_baseline: 18
cssclasses:
- research-note-tables
---

# Uni-06 — Physical Uplink Shared Channel power control and coverage

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in [[#7.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

!important[The Physical Uplink Shared Channel (PUSCH) carries scheduled data from user equipment (UE) to the next generation NodeB (gNB). This experiment calculates the requested transmit power, applies the configured power limit, and decodes actual received waveforms. A grant can request more bandwidth than the UE can support at the desired received power.]

The system map locates the power limit before propagation and decoding.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - System Overview v1.png]]

*Original system schematic. The path loss estimate controls the command; the configured maximum limits the transmitted power. The waveform experiment uses one carrier, one antenna and one power adjustment state.*

## 1. Knowledge sources and engineering objective

**Stage — Textbook workflow.**

The overview above put the power limit before propagation and decoding. This section says what the experiment teaches and which notes supply each piece.

The teaching objective is to explain why a larger uplink allocation can lose coverage after the transmitter reaches its power limit. The decoder provides the observable result. A calculated receive power alone cannot establish successful delivery.

The source contributions connect spectrum, scheduling, power and receiver requirements.

| Source | Contribution | Experiment interface |
| --- | --- | --- |
| [[Star-03-Spectrum-for-5G\|Spectrum for 5G]] | Spectrum and numerology context | 30 kHz subcarrier spacing |
| [[Star-14-Scheduling\|Scheduling]] | Allocation and power headroom | Compare 6 and 24 resource blocks |
| [[Star-15-Uplink-Power-and-Timing-Control\|Uplink power and timing control]] | Open and closed control terms | Requested and limited transmit powers |
| [[Star-25-RF-Characteristics\|Radio frequency characteristics]] | Transmitter and receiver reference planes | Configured maximum and noise figure |
| [[Star-31-TS-38.213-Physical-Layer-Procedures-for-Control\|Control procedures]] | PUSCH power equation | Exact clamp computation |
| [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data\|Data procedures]] | Modulation and transport size | Actual encoded and decoded blocks |

The Chapter 15 note of this knowledge base ([[Star-15-Uplink-Power-and-Timing-Control|Star-15]]) introduces the same power equation. The executable experiment assigns a value to every term and checks its consequence at the decoder. Third Generation Partnership Project (3GPP) definitions use the frozen protocol manifest.

The official sources fix different parts of the chain.

| Source | Exact version | Clause | Used here |
| --- | --- | --- | --- |
| [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 18.8.0 | 7.1.1 | UE PUSCH power and adjustment terms |
| [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 18.9.0 | 6.3.1; 6.4.1.1; 5.3.1 | PUSCH, reference symbols and waveform |
| [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 18.8.0 | 6.2 | Uplink shared channel coding |
| [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 18.10.0 | 6.1.4 | Modulation, code rate and transport size |

## 2. System position and implementation boundary

**Stage — Textbook workflow.**

Section 1 gave the sources. This section fixes the boundary: what is supplied, what the model omits, and the values chosen.

The scheduled grant, timing and receiver carrier configuration are supplied. This removes acquisition uncertainty and isolates power control. 

The [MathWorks PUSCH throughput example](https://www.mathworks.com/help/5g/ug/nr-pusch-throughput.html) establishes the supported waveform and receiver chain. The local script uses the same public toolbox interfaces with a smaller allocation and an explicit loss sweep. [ShareTechnote's power control explanation](https://www.sharetechnote.com/html/5G/5G_PowerControl.html) helps relate configuration names to the command; official statements here use TS 38.213.

The model applies deterministic scalar path loss and Additive White Gaussian Noise (AWGN). Antenna gains are absorbed into the effective loss. The downlink loss estimate equals the uplink effective loss by assumption. There is no frequency selective fading, external interference, power amplifier distortion, timing error or retransmission. The sweep measures sensitivity to effective path loss; it does not infer a coverage radius.

The experiment fixes these values before producing each waveform.

| Quantity | Value | MATLAB owner | How we got it |
| --- | --- | --- | --- |
| Carrier grid and spacing | 24 RB; 30 kHz | nrCarrierConfig | Assumed configuration |
| Allocation | 6 or 24 RB | pusch.PRBSet | Assumed grant |
| Maximum configured power | 23 dBm | cfg.pmaxdBm | Assumed limit |
| Nominal power term | −90 dBm | cfg.p0dBm | Assumed configuration |
| Loss compensation | 0.8 or 1 | cfg.alphas | Assumed configuration |
| Receiver noise figure | 5 dB | cfg.noiseFiguredB | Assumed receiver |
| Effective loss | 90 to 135 dB | cfg.lossdB | Assumed sweep |
| Repetitions | 24 blocks per point | cfg.nTrials | Experimental sample size |

Here a resource block (RB) contains 12 consecutive subcarriers. The selected numerology has 14 Orthogonal Frequency Division Multiplexing (OFDM) symbols per 0.5 ms slot with normal cyclic prefix. The configuration follows [TS 38.211 V18.9.0, §§4.2, 4.3.2 and 4.4.4.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

## 3. Convert a grant into transmit power

**Stage — 3GPP protocol.**

Section 2 fixed the values. This section turns a grant into a transmit power with the standard's equation, then into a noise level at the decoder.

The command sums a nominal reference, the allocated bandwidth, compensated loss, the transport format correction and the accumulated control adjustment. The single carrier form suppresses the specification's bandwidth part, carrier, serving cell, resource set and occasion indices; it preserves their terms.

### 3.1 Apply the power clamp

The first step is the power equation and its clamp; this section evaluates both for one grant.

The original expression retains the bandwidth part, carrier, cell and occasion indices that the scalar calculation suppresses.

External source: [7.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.213 V18.8.0, §7.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=25), printed page 24. The ordinary PUSCH power equation combines allocated bandwidth, compensated path loss, transport format and adjustment state, subject to configured maximum output power. The laboratory sets the last two adjustments to zero.*

The configured maximum determines whether a command can be transmitted. For one scheduled PUSCH, [TS 38.213 V18.8.0, §7.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) gives the scalar specialization used by the script.

$$
\begin{aligned}
P_{\mathrm{cmd}}&=P_0+10\log_{10}(2^\mu M)
+\alpha PL+\Delta_{\mathrm{TF}}+f,\\
P_{\mathrm{tx}}&=\min(P_{\mathrm{CMAX}},P_{\mathrm{cmd}}).
\end{aligned}
$$

Here $P_{\mathrm{cmd}}$ is requested total PUSCH power in dBm; $P_0$ is the sum of the nominal and UE specific configured components in dBm; $\mu$ is the dimensionless subcarrier spacing index; $M$ is allocated RB count; $\alpha$ is the dimensionless loss compensation factor; $PL$ is the selected reference signal loss estimate in dB; $\Delta_{\mathrm{TF}}$ is the transport format correction in dB; and $f$ is the accumulated adjustment for the selected power control state in dB. $P_{\mathrm{CMAX}}$ is configured maximum output power in dBm and $P_{\mathrm{tx}}$ is the resulting total transmit power. The factor $2^\mu M$ expresses bandwidth relative to one RB at the reference numerology, and 10 converts a power ratio to decibels.

The experiment sets $\Delta_{\mathrm{TF}}=0$ dB by disabling the transport format correction and holds $f=0$ dB. It does not execute a closed control loop or decode transmit power commands. The configured 23 dBm limit is an experiment input; actual UE power limits depend on the applicable radio specification, band, power class and reductions.

What we are working out: total transmit power for 6 RB at 100 dB effective loss, at the UE output reference plane.

$$
\begin{aligned}
P_{\mathrm{tx}}
&=\min\{P_{\mathrm{CMAX}},P_0+10\log_{10}(2^\mu M)+\alpha PL+\Delta_{\mathrm{TF}}+f\}\\
&=\min\{23,-90+10\log_{10}(2^1\cdot6)+1\cdot100+0+0\}\\
&=20.7918\ \mathrm{dBm}.
\end{aligned}
$$

Here $P_{\mathrm{CMAX}}=23$ dBm, $P_0=-90$ dBm, $\mu=1$, $M=6$, $\alpha=1$, $PL=100$ dB, and $\Delta_{\mathrm{TF}}=f=0$ dB are assumed inputs in cfg and uni06_power. $P_{\mathrm{tx}}=20.7918$ dBm is calculated at the transmitter output. The command remains 2.2082 dB below the limit.

The worked input table shows where each value applies.

| Symbol | Value | Status | Reference |
| --- | --- | --- | --- |
| $P_0$, $P_{\mathrm{CMAX}}$ | −90, 23 dBm | Assumed | UE command and output |
| $\mu$, $M$, $\alpha$ | 1, 6, 1 | Assumed | Scheduled allocation |
| $PL$ | 100 dB | Assumed | Effective radio path |
| $\Delta_{\mathrm{TF}}$, $f$ | 0, 0 dB | Assumed | Control state |
| $P_{\mathrm{tx}}$ | 20.7918 dBm | Calculated | uni06_power output |

All additions are in decibel power units with a common dBm power reference. Results are displayed to four decimal places here and retained at full precision in the CSV.

### 3.2 Turn effective loss into decoder noise

Section 3.1 gave the transmit power. This section carries it across the path loss and the receiver noise to the ratio the decoder sees.

!note[The decoder needs the ratio between useful received signal power and noise over the allocated bandwidth. The thermal density is taken as −174 dBm/Hz, a rounded engineering reference near 290 K. Receiver noise figure adds 5 dB. The scalar attenuation is normalized out of the waveform; the noise variance carries the same signal to noise ratio (SNR).]

What we are working out: receive SNR for the power limited 6 RB allocation at 125 dB path loss.

$$
\begin{aligned}
B&=12M\Delta f=12\cdot6\cdot30{,}000=2.16\times10^6\ \mathrm{Hz},\\
N&=-174+10\log_{10}(B/1\mathrm{Hz})+F\\
&=-174+10\log_{10}(2.16\times10^6)+5=-105.6555\ \mathrm{dBm},\\
\gamma_{\mathrm{dB}}&=P_{\mathrm{tx}}-PL-N\\
&=23-125-(-105.6555)=3.6555\ \mathrm{dB}.
\end{aligned}
$$

Here $B$ is allocated noise bandwidth, $M=6$ RB and $\Delta f=30{,}000$ Hz are assumed allocation values, 12 is the number of subcarriers per RB, $F=5$ dB is assumed noise figure, and $N$ is calculated integrated receiver noise. $P_{\mathrm{tx}}=23$ dBm is the clamped program output at $PL=125$ dB; $\gamma_{\mathrm{dB}}$ is calculated SNR at an active resource element. The assumed loss and gains use the same transmitter and receiver reference planes.

The receiver model implements sample noise variance $1/(N_{\mathrm{FFT}}10^{\gamma_{\mathrm{dB}}/10})$. Here $N_{\mathrm{FFT}}$ is the transform size returned by nrOFDMModulate, and the unit symbol energy convention matches the [MathWorks SNR definition](https://www.mathworks.com/help/5g/ug/snr-definition-used-in-link-simulations.html). The normalized channel has unit amplitude; the experiment is mathematically equivalent to attenuation followed by receiver noise under the stated scalar model.

The local table links the link budget to the waveform.

| Quantity | Value | Status | Where it applies |
| --- | --- | --- | --- |
| $B$ | 2.16 MHz | Calculated | Allocated subcarriers |
| $F$ | 5 dB | Assumed | Receiver |
| $N$ | −105.6555 dBm | Calculated | Allocated bandwidth |
| $P_{\mathrm{tx}}$, $PL$ | 23 dBm; 125 dB | Program output; assumed | UE output; effective path |
| $\gamma_{\mathrm{dB}}$ | 3.6555 dB | Calculated | Active resource element |

!important[Increasing from 6 to 24 RB multiplies bandwidth by four and raises integrated noise by 6.0206 dB. Before clamping, the command rises by the same amount. After clamping, the transmitter cannot supply that increase.]

## 4. Generate and decode real uplink arrays

**Stage — MATLAB experiment.**

Section 3 computed powers. This section generates real uplink waveforms and decodes them.

The implementation generates a new random transport block for each trial, attaches and encodes it through the toolbox Uplink Shared Channel (UL-SCH) chain, maps PUSCH and its Demodulation Reference Signal (DM-RS), and performs OFDM modulation. The receiver estimates channel and noise from DM-RS, applies Minimum Mean Square Error (MMSE) equalization and decodes the block.

The array ownership table identifies where each intermediate result is created.

| Stage | MATLAB interface | Stored object | Meaning |
| --- | --- | --- | --- |
| Transport size and bits | nrTBS; nrULSCH | trials.TBS | 768 or 3104 payload bits |
| Data and pilots | nrPUSCH; nrPUSCHDMRS | reps.grid | 288 × 14 complex grid |
| Waveform | nrOFDMModulate | reps.tx; reps.rx | Complex time samples |
| Practical estimation | nrChannelEstimate | reps.hest | Channel estimates per grid location |
| Equalize and decode | nrEqualizeMMSE; nrULSCHDecoder | reps.eq; trials.CRC | Equalized symbols and block outcome |

The Cyclic Redundancy Check (CRC) outcome is counted after the actual decoder. Block Error Rate (BLER) is the fraction of failed transport blocks in the finite trial set. Transport Block Size (TBS) counts original payload bits, excluding coding and reference symbols. These coding and mapping stages follow [TS 38.212 V18.8.0, §6.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) and [TS 38.211 V18.9.0, §§6.3.1 and 6.4.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

The generated grid checks whether the grant activates the intended subcarriers before interpreting its power budget. Compare its occupied region and reference signal stripes with the mapping exclusions in the protocol excerpt; empty carrier resources contribute no transmitted symbols in this trial.


External source: [6.3.1.6](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.211 V18.9.0, §6.3.1.6](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=61), printed page 60. PUSCH amplitude scaling follows the power procedure, while data mapping excludes resource elements used by the associated reference signals.*


![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - PUSCH resource grid v1.png]]

*MATLAB output from reps(1).grid: magnitude of the 288 by 14 transmit grid with subcarriers up and OFDM symbols across. Only the 72 subcarriers of the 6 RB allocation are active; the striped columns at symbols 2, 7 and 11 are the DM-RS positions, and the rest of the carrier stays zero.*


OFDM modulation converts that grid into the envelope below. The changes between data and reference symbols follow their different resource occupancy; the envelope verifies the sample structure, while the link budget supplies the absolute transmit power.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Transmit envelope v1.png]]

*MATLAB output from reps(1).tx and reps(1).fs: the upper panel shows the sample magnitude of the OFDM waveform over one 0.5 ms slot with the fourteen symbol boundaries marked and the RMS level of each symbol drawn as a step line; the lower panel gives the power of each symbol relative to the slot mean in dB. Symbols 2, 7 and 11 carry the DM-RS and sit about 2.5 dB below the others because DM-RS type 1 occupies every second subcarrier; the absolute output power is carried by the link budget.*

The transport size calculation assigns more payload to the wider grant at the same modulation and target code rate. The bars establish its potential delivery advantage, which the subsequent CRC results will either preserve or remove.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Payload size versus allocation v1.png]]

*MATLAB output from results.TBS: transport block bits for the 6 RB and 24 RB grants at target rate 0.48 with QPSK, 768 against 3104 bits. This is the payload advantage the wider allocation offers before any decoding failure is counted.*

The receiver estimates the channel from noisy DM-RS after applying the calculated SNR. Comparing the estimates at the ends of the loss sweep with the flat true channel shows the estimation error that also enters equalization.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Channel estimate error v1.png]]

*MATLAB output from reps.hest at OFDM symbol 7: magnitude of the DM-RS channel estimate at 90 dB and at 135 dB loss over the first 72 subcarriers. The true channel is flat at one; the departure at 135 dB is noise entering the estimate at the far end of the sweep.*

## 5. Read power, reliability and delivery together

**Stage — Measured results.**

Section 4 produced decoded blocks. This section reads power, reliability and delivered bits together across the loss sweep.

The actual run contains 768 decoded transport blocks: eight loss values, two compensation factors, two allocations and 24 independent noise and payload realizations per configuration. The displayed BLER uncertainty uses a 95% Wilson interval.

### 5.1 Observe the clamp and receive SNR

The first reading is the clamp itself and the receive SNR it produces.

The compensation factor changes how quickly the power command approaches the limit. With $\alpha=1$, increasing loss is fully compensated until clamping. With $\alpha=0.8$, each extra decibel of path loss reduces receive SNR by 0.2 dB before clamping.

The power calculation is evaluated across the loss sweep before any blocks are decoded. In the fractional compensation plot, follow each rising command to its flat 23 dBm segment: the wider grant consumes the available power margin first.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Power clamp alpha 0.8 v1.png]]

*MATLAB output from results.TxPowerdBm at α = 0.8: transmit power against effective path loss for both allocations. Each decibel of loss raises the command by 0.8 dB until the 23 dBm limit; the 24 RB curve sits 6 dB higher and reaches the clamp first.*

Full compensation raises the command more quickly as loss increases. Comparing the knees below with those in the fractional compensation plot separates the effect of compensation from the additional power requested by the wider allocation.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Power clamp alpha 1.0 v1.png]]

*MATLAB output from results.TxPowerdBm at α = 1: with full compensation the command rises one for one with loss, so the wider allocation saturates 6 dB of path loss earlier than the narrow one. A flat segment is the clamp of TS 38.213 §7.1.1.*

Subtracting path loss and integrated noise from each limited transmit power gives the receive SNR below. Under fractional compensation, the common decline before saturation comes from incomplete loss compensation; separation between allocations begins when their power limits prevent equal compensation.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - SNR alpha 0.8 v1.png]]

*MATLAB output from results.SNRdB at α = 0.8: receive SNR falls by 0.2 dB per decibel of loss before clamping, identically for both allocations, and by a full decibel afterwards. Equal SNR before the clamp is why the wider grant looks free until the limit.*

With full compensation, the flat SNR region ends at each allocation's power clamp. Read the gap after both curves begin falling as the decoder margin lost by spreading limited total power over the wider bandwidth.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - SNR alpha 1.0 v1.png]]

*MATLAB output from results.SNRdB at α = 1: SNR stays constant while the command is met and drops one for one after the clamp. Once both allocations clamp, 24 RB has 6.0206 dB less SNR than 6 RB because its noise bandwidth is four times larger.*

Subtracting the requested command from the maximum produces the headroom plot. Its zero crossing identifies where increasing the requested power ceases to increase transmitted power, connecting the command calculation to the SNR decline.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Power headroom v1.png]]

*MATLAB calculation of 23 − results.CommanddBm at α = 1: how far the requested power lies below or above the configured limit. Negative headroom is an unmet command, the regime where coverage is lost; it is not the decoded power headroom report of the MAC layer.*

### 5.2 Count decoded blocks and delivered bits

Section 5.1 predicted a margin. This section counts what the decoder actually delivered, with intervals.

!warning[The reliability comparison must retain sample size. Zero errors among 24 trials has a Wilson upper bound of 0.13798; it does not establish a failure probability below one percent.]

The finite sample interval uses the observed block failures.

$$
\begin{aligned}
\hat p&=k/n,\qquad d=1+z^2/n,\\
c&=(\hat p+z^2/(2n))/d,\\
h&=z\sqrt{\hat p(1-\hat p)/n+z^2/(4n^2)}/d,\\
[p_L,p_U]&=[\max(0,c-h),\min(1,c+h)].
\end{aligned}
$$

Here $k$ is failed block count, $n=24$ is trial count, $\hat p$ is observed BLER, $z=1.95996398454005$ is the standard normal quantile for a two sided 95% interval, and $d,c,h$ are dimensionless Wilson denominator, center and half width. $p_L,p_U$ are the bounded lower and upper probability estimates. The interval assumes independent trials at a fixed configuration; it does not describe unmodeled fading or interference.

Actual waveform decoding tests whether the SNR trends predict payload recovery. In the fractional compensation plot, compare the first nonzero failure points with the preceding SNR curves; the narrower allocation retains successful decoding farther into the loss sweep.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Decoded BLER alpha 0.8 v1.png]]

*MATLAB output from results.BLER with Lower95 and Upper95 at α = 0.8, 24 trials per point: fraction of failed transport blocks against path loss. The first failures appear where the SNR curve crosses the decoder's limit, later for the narrow allocation.*

The full compensation run repeats that decoder test with the faster rising power command. The separation between its allocation curves establishes a coverage consequence of clamping, subject to the spacing of the tested loss points and their sampling intervals.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Decoded BLER alpha 1.0 v1.png]]

*MATLAB output from results.BLER with Wilson intervals at α = 1: the coverage transition of the two allocations. At 125 dB the 6 RB blocks all decode while all 24 RB blocks fail; the 5 dB sweep spacing limits how precisely the transition is located.*

The interval calculation can also be evaluated for every possible failure count at the fixed trial budget. The widest part of the curve below identifies the least precise probability estimates; even its endpoints retain uncertainty after uniformly successful or failed trials.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Finite sample uncertainty v1.png]]

*MATLAB calculation of the Wilson 95% interval width for every possible failure count out of 24 trials, with the counts actually observed in this run marked. The width is 0.138 at zero or 24 failures and about 0.37 at twelve, which is what a 24-trial point can and cannot prove about a block error probability.*

Multiplying each transport size by its accepted fraction and dividing by attempted slot time produces goodput. The fractional compensation curves show where the wider grant's extra payload stops compensating for its decoding failures.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Goodput alpha 0.8 v1.png]]

*MATLAB output from results.GoodputMbps at α = 0.8: CRC-accepted payload bits per attempted 0.5 ms slot. The wider allocation delivers four times more until its blocks start failing, after which its goodput collapses below the narrow one.*

The full compensation comparison makes the same trade visible at 125 dB loss: the narrow grant continues to deliver while the wide grant has exhausted its decoder margin. The selected rows that follow retain the underlying failure counts.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Goodput alpha 1.0 v1.png]]

*MATLAB output from results.GoodputMbps at α = 1: the surviving delivery at each loss. At 125 dB the 6 RB grant still delivers 1.536 Mbit/s while the 24 RB grant delivers nothing; acquisition, control and retransmission time are excluded.*

The selected rows give the exact observed reversal at full compensation.

| Loss | Allocation | Failed / tried | Receive SNR | Delivered payload |
| --- | --- | --- | --- | --- |
| 120 dB | 6 RB | 0 / 24 | 8.6555 dB | 1.536 Mbit/s |
| 120 dB | 24 RB | 0 / 24 | 2.6349 dB | 6.208 Mbit/s |
| 125 dB | 6 RB | 0 / 24 | 3.6555 dB | 1.536 Mbit/s |
| 125 dB | 24 RB | 24 / 24 | −2.3651 dB | 0 Mbit/s |
| 130 dB | 6 RB | 24 / 24 | −1.3445 dB | 0 Mbit/s |

These are program outputs in results/summary.csv with Alpha = 1. Goodput counts CRC accepted payload bits divided by all attempted slot durations.

What we are working out: useful payload delivery at 125 dB loss for the 6 RB allocation.

$$
\begin{aligned}
R_{\mathrm{good}}
&=\frac{TBS(n-k)}{nT_{\mathrm{slot}}}\\
&=\frac{768(24-0)}{24\cdot0.0005}\\
&=1.536\times10^6\ \mathrm{bit/s}.
\end{aligned}
$$

Here $TBS=768$ bits is nrTBS output, $n=24$ attempts and $k=0$ failures are recorded program outputs, $T_{\mathrm{slot}}=0.0005$ s is the selected numerology's slot duration, and $R_{\mathrm{good}}$ is calculated payload goodput. The aggregate requires the actual decoder sequence to obtain $k$.

The local trace identifies each input to that delivery value.

| Quantity | Value | Status | Source |
| --- | --- | --- | --- |
| TBS | 768 bits | Program output | nrTBS |
| Accepted attempts | 24 of 24 | Program output | CRC results |
| Attempt duration | 0.5 ms | Configured | 30 kHz numerology |
| Goodput | 1.536 Mbit/s | Calculated | Payload / elapsed slots |

### 5.3 Inspect what the decoder sees

Section 5.2 counted blocks. This section looks at the symbols the decoder saw before deciding.

Error Vector Magnitude (EVM) measures displacement from transmitted constellation points after equalization. It diagnoses signal quality, but the coded block decision still comes from the decoder.

The equalized symbols provide a continuous view of receiver degradation between the discrete CRC outcomes. Under fractional compensation, increasing EVM follows the declining SNR even before a block failure is observed.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Receiver EVM alpha 0.8 v1.png]]

*MATLAB output from results.EVMPercent at α = 0.8: root mean square error vector magnitude of the equalized QPSK symbols against path loss. EVM grows smoothly as SNR falls; it diagnoses signal quality while the block decision still comes from the decoder.*

Full compensation holds EVM approximately steady while the requested power can be supplied. Compare the start of each rise below with its power clamp to trace the bandwidth decision through to the receiver's symbol errors.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Receiver EVM alpha 1.0 v1.png]]

*MATLAB output from results.EVMPercent at α = 1: EVM is flat while the command is met and rises after the clamp, earlier for the wider allocation. These are simulation diagnostics.*

The saved constellation near the start of the sweep gives a reference for this EVM measure. Its compact clusters show the receiver operating with enough power margin for the configured payload.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Constellation PL 90 v1.png]]

*MATLAB output from reps(1).eq: one decoded QPSK block at 6 RB, α = 1 and 90 dB loss. Four tight clusters are the receiver's reference appearance when the command is met with margin.*

At 120 dB, the saved symbols have spread away from that reference appearance. This block still decodes, demonstrating why visible symbol error must be interpreted through the coded receiver and its CRC.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Constellation PL 120 v1.png]]

*MATLAB output from reps(2).eq: the same configuration at 120 dB loss. The clusters have spread substantially, yet this block still passes its CRC because LDPC coding and soft information recover the payload.*

At 135 dB, examine both the spread and the contraction toward the origin. The MMSE output is now beyond the observed coverage transition; the constellation explains the degraded soft input without supplying a substitute block decision.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Constellation PL 135 v1.png]]

*MATLAB output from reps(3).eq: the receiver beyond the observed coverage transition at 135 dB. MMSE equalization shrinks the cloud toward the origin as well as spreading it, so visual clustering cannot replace the CRC test.*

Dividing Radio Frequency (RF) transmit power by successful payload rate gives the energy comparison below. Its rise near loss of delivery joins the earlier power and goodput results: a grant can consume transmit power while yielding progressively fewer useful bits.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Energy per delivered bit v1.png]]

*MATLAB calculation of 10^((TxPowerdBm − 30)/10) divided by delivered bits per second: RF transmit energy per successfully delivered bit in nanojoules. It rises steeply as the clamp is approached; zero delivery has no defined value and is omitted, and amplifier efficiency is excluded.*

## 6. Reproduce the result and test its limits

**Stage — Reproduce and references.**

Section 5 reported. This section says how to reproduce the run and what a next experiment should vary.

MATLAB R2026a Update 4, 5G Toolbox 26.1 and seed 6007 produced the saved run. The script resets the random generator, processes configurations in a fixed order and saves configuration, toolbox versions, representative complex arrays and every block outcome.

The file roles identify the evidence needed for reproduction.

| File under matlab/uni06 | Content | Check |
| --- | --- | --- |
| run_uni06.m | Full waveform experiment and figures | 768 decoded blocks |
| uni06_power.m; test_uni06.m | Power relation and clamp assertions | Two numerical clamp cases |
| results/run.mat | Configuration, arrays, versions, tables | Actual MATLAB variables |
| results/trials.csv; summary.csv | Trial outcomes and aggregate values | Saved numerical source |
| results/run.log; source_hashes.txt | Execution and source identity | Reproduction evidence |

Run from the 5G Notebook directory:

~~~matlab
addpath('matlab/uni06');
run_uni06
~~~

The calculation trace distinguishes algebra from decoder outputs.

| Result | Trace path | Exact owner |
| --- | --- | --- |
| Requested and limited power | Explicit formula and substitution | uni06_power; CommanddBm, TxPowerdBm |
| Receive SNR | Link budget conversion | SNRdB, NoisedBm |
| Reliability and intervals | Actual decoder output and Wilson calculation | CRC; BLER, Lower95, Upper95 |
| Payload delivery | TBS multiplied by accepted trials | GoodputMbps |
| EVM and waveform appearance | Saved complex arrays | EVMPercent; reps.eq |

!warning[A finer sweep between 120 and 130 dB would locate the coverage transition more precisely. More trials are required before testing a small BLER target. Fading, inaccurate loss estimates, nonzero power adjustments and amplifier limits must be introduced before transferring the result to a deployment. The present result supports the allocation mechanism: once the transmitter is limited, assigning four times as much bandwidth lowers SNR by 6.0206 dB under this receiver model.]

The closing flow joins the specification terms to the experiment's observable delivery decision.

![[99 Attachments/5G/Uni Labs/Uni-06/Uni-06 - Closing Flow v1.png]]

*Original implementation synthesis. TS 38.213 V18.8.0 §7.1.1 owns the command and clamp; TS 38.214 V18.10.0 §6.1.4 owns transport parameters. The experiment evaluates smaller allocation at fixed code rate; reducing code rate is a proposed follow up.*

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

The sources below identify the official chain, implementation interfaces and teaching prerequisites used above.

### 7.1 References

The reference list preserves the exact versions used for the experiment.

- 3GPP, [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip), §7.1.1.
- 3GPP, [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), §§4.2, 4.3.2, 4.4.4.1, 5.3.1, 6.3.1 and 6.4.1.1.
- 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), §6.2.
- 3GPP, [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip), §6.1.4.
- MathWorks, [NR PUSCH throughput](https://www.mathworks.com/help/5g/ug/nr-pusch-throughput.html) and [SNR definition used in link simulations](https://www.mathworks.com/help/5g/ug/snr-definition-used-in-link-simulations.html), accessed 2026-09-07.
- ShareTechnote, [5G power control](https://www.sharetechnote.com/html/5G/5G_PowerControl.html), secondary explanation, accessed 2026-09-07.
- The Chapter 15 note of this knowledge base ([[Star-15-Uplink-Power-and-Timing-Control|Star-15]]) and the six linked teaching sources in §1.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.213 V18.8.0, §7.1.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=25); [TS 38.211 V18.9.0, §6.3.1.6](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf#page=61). Accessed 2026-09-08.

### 7.2 Abbreviation index

The short forms used in this note are spelled out below; the [[5G Abbreviation Database|global 5G abbreviation database]] gives their wider course context.

| Abbreviation | Full term |
| --- | --- |
| 3GPP | Third Generation Partnership Project |
| AWGN | Additive White Gaussian Noise |
| BLER | Block Error Rate |
| CRC | Cyclic Redundancy Check |
| DM-RS | Demodulation Reference Signal |
| EVM | Error Vector Magnitude |
| FFT | Fast Fourier Transform |
| gNB | Next generation NodeB |
| MMSE | Minimum Mean Square Error |
| OFDM | Orthogonal Frequency Division Multiplexing |
| PUSCH | Physical Uplink Shared Channel |
| QPSK | Quadrature Phase Shift Keying |
| RB | Resource Block |
| RF | Radio Frequency |
| SNR | Signal to Noise Ratio |
| TBS | Transport Block Size |
| UE | User Equipment |
| UL-SCH | Uplink Shared Channel |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with value, unit and where each applies.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $P_{\mathrm{cmd}}$, $P_{\mathrm{tx}}$ | Requested and actual total PUSCH power | dBm |
| $P_{\mathrm{CMAX}}$, $P_0$ | Configured maximum and nominal power term | dBm |
| $\mu$, $M$, $\alpha$ | Numerology index, RB count, loss compensation | Dimensionless |
| $PL$, $\Delta_{\mathrm{TF}}$, $f$ | Loss, transport correction, control adjustment | dB |
| $B$, $\Delta f$ | Allocation bandwidth and subcarrier spacing | Hz |
| $F$, $N$ | Noise figure and integrated noise | dB; dBm |
| $\gamma_{\mathrm{dB}}$ | Receive SNR at active resource element | dB |
| $N_{\mathrm{FFT}}$ | Transform size | Samples |
| $k$, $n$, $\hat p$ | Failed blocks, tried blocks, observed BLER | Counts; fraction |
| $z$, $d$, $c$, $h$, $p_L$, $p_U$ | Wilson calculation terms | Dimensionless |
| $TBS$, $T_{\mathrm{slot}}$, $R_{\mathrm{good}}$ | Payload bits, slot time, useful rate | bit; s; bit/s |
