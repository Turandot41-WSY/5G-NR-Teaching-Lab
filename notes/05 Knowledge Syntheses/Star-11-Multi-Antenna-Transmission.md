---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 11
title: Multi-Antenna Transmission
language: en
course_units:
- U06
- U07
- U08
release_baseline: 18
---

# STAR-11 — Multi-Antenna Transmission

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

An antenna array steers a beam without moving anything. Feed the same signal to a row of antennas, and delay each one by a little more than its neighbour. In one direction the delays exactly compensate the extra distance each wave travels, so the wavefronts arrive in step and add up; in every other direction they arrive out of step and partly cancel. Change the delays and the direction swings. No motor, no time — a new set of eight numbers. Every beam in 5G, from the swept synchronisation blocks of Star 16 to the millimetre-wave links of Star 26, is that trick.

![[99 Attachments/5G/Concept Figures/STAR-11-Multi-Antenna-Transmission-Concept.png|How an antenna array steers a beam by phase, and the three things students conflate]]

*Concept figure: How an antenna array steers a beam by phase, and the three things students conflate.*

The same array can do two different things with those numbers. It can carry one stream and point it — beamforming, the rank-one case, and at millimetre wave the only reason the link exists. Or it can carry several streams at once, each with its own set of weights, through different paths in the channel — spatial multiplexing, which needs a channel rich enough to keep the streams apart. The set of weights is the precoder, W, and the whole chapter is about who decides W, from what measurement, and how often.

Three words are conflated so routinely that the chapter is half spent keeping them apart. An antenna is hardware. A port is a channel the phone is allowed to assume, a promise. A layer is a data stream. The precoder maps layers onto ports, and the array maps ports onto antennas. A phone with two antennas can receive four layers if the channel allows; a base station with sixty-four antennas may transmit one. Number of antennas is not rank, and rank is not port count.

One design choice makes the rest simple. The reference signal that the phone uses to estimate the channel is sent through the same precoder as the data, so the phone estimates the effective channel — the channel and the precoder together — and never needs to know what W was. That transparency is why NR can change precoders freely, and why the downlink and uplink chapters that follow can be about how W is chosen rather than how it is told.

**The question this chapter answers.** If a base station has many antenna elements, how does NR turn that hardware into stronger coverage, interference control, or several simultaneous data streams, and how does a receiver know what effective channel to estimate?

!important[**The short answer.** NR separates physical antenna elements, logical antenna ports, transmission layers, and the precoder. An implementation combines element signals into one or more logical ports. The transmitter maps a codeword to one or more layers and applies a precoding matrix before radiating the result. The same resources can therefore be used for array gain, spatial interference suppression, or spatial multiplexing. A rank-one transmission carries one layer but may still use a large array; a rank-four transmission carries four layers and needs a channel with enough usable spatial dimensions. "Number of antennas" is not interchangeable with "rank".]

Names you will meet in this note: Multiple-Input Multiple-Output (MIMO), single-user and multi-user MIMO (SU-MIMO, MU-MIMO), precoder (W), transmission layer, antenna port, rank indicator (RI), precoding-matrix indicator (PMI), channel-quality indicator (CQI), channel state information reference signal (CSI-RS), sounding reference signal (SRS), SRS resource indicator (SRI), transmitted precoding-matrix indicator (TPMI), demodulation reference signal (DM-RS), transmission reception point (TRP).

## 2. Where you are in 5G

Section 1 steered a beam with delays. The map below shows where multi-antenna transmission sits in 5G: between the coded layers of Star 09 and the physical antennas, in both directions.

![[99 Attachments/5G/Locator Maps/STAR-11-Where-You-Are-in-5G.png|Where Star 11 sits in the whole 5G system]]

*Locator: Where Star 11 sits in the whole 5G system.*

This chapter lights antennas and MIMO in the physical foundations. It consumes the measurements of Star 08, feeds the beam management of Star 12, and is where the layer count in Star 09's transport-block arithmetic comes from. Star 26 covers the millimetre-wave hardware that makes large arrays practical.

The Knowledge Structure Map compares the three things an array can buy — reliability, coverage, rate — and the one number, rank, that decides between them. The mechanism diagram follows a codeword to the physical antennas, marking the two fan-outs and which of them the phone negotiates.

![[99 Attachments/5G/Knowledge Maps/STAR-11-Multi-Antenna-Transmission-Knowledge Structure Map.png|STAR-11 system-position map]]

*Knowledge map: What extra antennas buy: diversity, beamforming or spatial multiplexing.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-11-MIMO-Spatial-Processing-Chain.png|Star 11 mechanism and handoff diagram]]

*Mechanism: From codeword to physical antenna, and where rank constrains the chain.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 11.1 Introduction → 11.2 Downlink Multi-Antenna Precoding → 11.2.2 / 11.2.3 Type-II CSI (Rel-15) and Rel-16 Enhanced Type-II → 11.3 NR Uplink Multi-Antenna Precoding → LTE ↔ NR: what's different here?.


## 3. The textbook road

Section 2 placed precoding between layers and antennas. The road below walks through the chapter in the book's order: the three effects, downlink precoding and its reports, then the uplink.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

Three questions the author raised before the walkthrough set the vocabulary for it.

**MIMO, layers, spatial multiplexing, precoder, multi-antenna.** Multi-antenna is the hardware capability — several ports. MIMO, or spatial multiplexing, is the use of that hardware to send several layers at once. The precoder W is the software knob that turns ports into beams — each column of W is one — and maps layers onto ports. Analogue processing can only beamform; digital processing can beamform and multiplex.

| Term | In this chapter it means / how it connects |
| --- | --- |
| **Multi-antenna (MIMO)** | Using multiple antenna **ports** with a precoder W to shape beams and/or carry multiple **layers**. **Digital = full control (beamforming + spatial multiplexing);** analog = beamforming only. |
| **Layer** | One independent data stream; columns of W act like digital “beams” for each layer. |
| **Spatial multiplexing** | Sending \>1 layer at once (rank NL); needs digital control of W and adequate SNR/orthogonality. |
| **Precoder** | The NT×NL weight matrix W mapping layers→antenna ports; “precoding” = applying W. |
| **Antenna port** | A transmit signal path the spec can reference; UL/DL signaling and SRS/CSI-RS measurements are defined per port and constrain which precoders are valid. |

**Why can device capability be seen as antenna-port coherence in the uplink precoder?** Because the coherence a phone declares between its ports — none, partial, or full — directly restricts which codebook entries are legal, and therefore how many layers it can realise. With no coherence only port-selection vectors are allowed and rank two must avoid coupling ports; with partial coherence, combinations within pairs; with full coherence, combinations across all ports. Spatial-multiplexing capacity hinges on coherence before it hinges on antenna count.

**Is SRS used as a test in both codebook and non-codebook precoding?** Yes, differently. In codebook-based transmission the phone sends a multi-port SRS, the network measures it and selects rank and precoder, and with several SRS resources also signals which resource — which beam or panel — the precoder should be applied on. In non-codebook transmission the phone first chooses W from the downlink CSI-RS, then sends one SRS per column of W, and the network prunes columns with its selection in each grant.

### 3.1 11.1 Introduction

The road begins with what antennas buy: three effects, and why they matter more in NR than in LTE.

!important[Multi-antenna processing raises data rate, coverage, and spectral efficiency through three effects — diversity, directivity, and spatial multiplexing — and matters more in NR than in LTE because NR reaches frequencies where a link does not close without directivity. At millimetre wave, many small elements fit on one panel, and adjusting each element's phase steers a beam, as Figure 11.1 shows. Figure 11.2 gives the general model: layers mapped to antennas through the precoder W.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*At millimetre wave, many small elements fit on one panel, and adjusting each element's phase steers a beam, as Figure 11.1 shows.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*At millimetre wave, many small elements fit on one panel, and adjusting each element's phase steers a beam, as Figure 11.1 shows.*

The processing can be analogue or digital, and the difference decides what the array can do. Analogue processing, with a phase shifter per element and one radio chain for the whole array, is cheap and common at high frequency but forms one beam at a time. Digital processing, with a converter per element, is flexible enough for high-order spatial multiplexing and costs accordingly. Figures 11.3 and 11.4 show the two.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 11.3 and 11.4 show the two.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 11.3 and 11.4 show the two.*

| Dimension | **Analog (phased-array)** | **Digital (fully digital MIMO)** |
| --- | --- | --- |
| RF chains vs antennas | **NRF=1** for the whole array | **NRF=Nant** (one per element) |
| Max simultaneous layers | **NL≤1** (no true spatial multiplexing) | **NL≤min⁡(Nt,Nr,rank(H),SNR)** |
| Beamforming | Single steerable beam via phase shifters | Per-element complex weights → multiple beams at once |
| MU-MIMO/interference suppression | Very limited | Strong (precise nulling/precoding per user) |
| CSI/feedback need | Low–moderate (mainly best-beam selection) | High (full/partial CSI for rank/precoder per user) |
| Calibration burden | Lower (fewer RF chains) | Higher (per-chain gain/phase & reciprocity calibration) |
| Power & cost | Low per array | High (ADC/DAC & RF chain per element) |
| Best frequency band | **mmWave** & above (cost/thermals dominate) | **Sub-6 GHz** (practical scales), **small mmWave arrays if budget allows** |
| Typical NR usage | Narrow beams, sweep/select; time/freq separated users | MU-MIMO, spatial multiplexing, dynamic interference control |

> [!important] 💡
> **“Simultaneous beamforming” vs “spatial multiplexing”:**
> Analog can *sweep or switch* beams (not multiplex), hybrid can do **a few** simultaneous beams; only **digital** gives **true spatial multiplexing** with per-element complex weights and fine-grained MU interference control.
> **Complexity isn’t only “frequency-dependent”:** it scales with **antennas, bandwidth, ADC/DAC resolution & rate, calibration, and CSI/feedback**. mmWave just makes those costs bite harder.
> **UL waveform constraint:** if the UE uses **DFT-s-OFDM**, UL is **single-layer**; to send multiple UL layers you need **OFDM**. (This is orthogonal to analog/digital, but it’s why UL often runs rank-1 even with arrays.)

The consequence is scheduling: with an analogue transmitter, beams to different devices must be separated in time, as in Figure 11.5, whereas a digital transmitter can serve them at once on different frequencies, as in Figure 11.6. This is the architectural context for everything that follows — NR leans on beamforming because its high-frequency links are power-limited, and enables multiplexing wherever the radio allows.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The consequence is scheduling: with an analogue transmitter, beams to different devices must be separated in time, as in Figure 11.5, whereas a digital transmitter can serve them at once on different frequencies, as in Figure 11.*

> [!book] Book expansion
> Chapter 11 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 243–261, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00011-8)) opens with this analogue-versus-digital distinction because it decides which of the later mechanisms a given deployment can use at all.

> [!spec] 3GPP reality check
> The layer-to-port mapping is [TS 38.211 V18.9.0, clauses 7.3.1.4 and 7.3.1.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) for the downlink and 6.3.1.5 for the uplink; the specification never mentions analogue or digital, because it only sees ports.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [5G MIMO page](https://www.sharetechnote.com/html/5G/5G_MIMO.html) draws the analogue, digital, and hybrid architectures side by side with their radio-chain counts.

### 3.2 11.2 Downlink Multi-Antenna Precoding

Section 3.1 named the effects; this section shows how the downlink obtains them without burdening the phone: precode the reference signal together with the data.

!important[The downlink requirement is that the network may choose any useful precoder without burdening the phone with the details. The trick is to precode the demodulation reference signal together with the data: the precoder then becomes part of the effective channel the phone sees, of size receive antennas by layers, and the phone estimates that and decodes. No precoder is signalled; the phone needs only the number of layers. Figure 11.7 shows why this makes precoding transparent.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 11.7 shows why this makes precoding transparent.*

The phone helps the network choose through its channel-state reports: a rank indicator, a precoder index into a codebook chosen for the CSI-RS port count and the assumed rank, and a channel-quality indicator. The codebook is for feedback; the network is not bound to use the exact precoder reported. Two codebook families serve two purposes. Type I is compact and focuses energy, scaling to higher rank for a single user. Type II is far richer — hundreds of bits — and exists for multi-user MIMO, where the network must also limit interference between the users it schedules together; Release 16 improved its frequency granularity and cut its overhead with frequency-domain units and compression.

> [!book] Book expansion
> The textbook's point is that downlink precoding stays flexible for single- and multi-user operation while the phone's procedure stays simple: estimate the channel from the precoded reference signal, and report.

> [!spec] 3GPP reality check
> The codebooks and the reporting are [TS 38.214 V18.10.0, clause 5.2.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); the transparency comes from TS 38.211 clause 7.4.1.1, which precodes the reference signal with the data.

> [!engineering] ShareTechnote engineering view
> The [5G CSI report page](https://www.sharetechnote.com/html/5G/5G_CSI_Report.html) shows a Type I report field by field, which makes the bit budget concrete.

### 3.3 11.2.2 / 11.2.3 Type-II CSI (Rel-15) and **Rel-16 Enhanced Type-II**

Section 3.2 let the network choose any precoder. To choose well for several users at once it needs finer feedback; this section describes the Type II reports.

Multi-user MIMO needs high spatial resolution: the precoder must favour the target device and, at the same time, place nulls towards the devices scheduled alongside. Release 15's Type II report gives the network a small set of beams chosen across the whole band, W1, plus per-beam amplitudes and phases per subband, W2. Release 16 keeps the beams, adds frequency-domain units at subband or half-subband resolution, and compresses the per-unit coefficients through a DFT basis and a sparse mapping from delay to beam — twice the frequency granularity at lower overhead, with the maximum rank raised to four and up to six beams in some configurations. Figure 11.8 shows the structure.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 11.8 shows the structure.*

> [!spec] 3GPP reality check
> Type II and enhanced Type II are [TS 38.214 V18.10.0, clauses 5.2.2.2.3 to 5.2.2.2.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); the beam count L and the compression parameters are configured through TS 38.331's codebookConfig.

### 3.4 11.3 NR Uplink Multi-Antenna Precoding

Sections 3.2 and 3.3 were the downlink. This section applies the same transparency trick to the uplink and shows what differs when the phone is the transmitter.

The uplink should exploit the phone's antenna ports while keeping the base station's demodulation simple and respecting the phone's hardware. The same transparency trick applies: the precoder is applied to the uplink reference signal, so the base station demodulates without knowing W exactly. What differs is who chooses W, and NR offers two modes.

#### 3.4.1 11.3.1 Codebook-Based Transmission

In codebook-based transmission the network chooses the rank and a precoder from the uplink codebook, for two or four ports, and sends its index in the grant; the phone applies it. To choose well the network needs a measurement, so the phone transmits a multi-port SRS first. With several SRS resources configured, the grant also carries a resource indicator that selects the beam or panel on which the precoded layers should be mapped. Figure 11.11 shows the four-port rank-one codebook families under no, partial, and full coherence — antenna selection, pairwise combination, full combination — and Figure 11.12 the multi-SRS case in which the indicator picks a beam and the precoder shapes layers within it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 11.11 shows the four-port rank-one codebook families under no, partial, and full coherence — antenna selection, pairwise combination, full combination — and Figure 11.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 11.11 shows the four-port rank-one codebook families under no, partial, and full coherence — antenna selection, pairwise combination, full combination — and Figure 11.*

#### 3.4.2 11.3.2 Non-Codebook-Based Precoding

Non-codebook transmission reverses the roles and assumes reciprocity. The phone measures the downlink CSI-RS and chooses an arbitrary precoder. It then transmits one SRS per column of that precoder — one per candidate beam — so that the network can see what it proposes. The network measures those signals and, in each grant, selects a subset through the resource indicator, which fixes the final rank. The phone transmits with the reduced precoder. Figure 11.13 shows the exchange; the sounding can be periodic, semi-persistent, or aperiodic.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 11.13 shows the exchange; the sounding can be periodic, semi-persistent, or aperiodic.*

> [!important] 💡
> **Codebook vs non-codebook (UL):** regardless of analog/digital hardware, NR’s **codebook-based UL** chooses a precoder from a predefined set using SRS measurements; **non-codebook UL** lets the UE propose beams (via SRS per beam) and the gNB prunes them.
> **Antenna-port coherence limits layers:** if the UE can’t keep stable inter-port phase (**no/partial coherence**), viable precoders (and thus spatial multiplexing gain) shrink—even before hardware limits kick in.

> [!spec] 3GPP reality check
> Codebook-based and non-codebook-based uplink are [TS 38.214 V18.10.0, clauses 6.1.1.1 and 6.1.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); the uplink codebook tables themselves are TS 38.211 clause 6.3.1.5.

### 3.5 LTE ↔ NR: what’s different here?

The road ends with the table that puts LTE and NR side by side on every point above.

| Topic | NR (per Ch. 11) | LTE (as referenced in Ch. 11) | Why it matters |
| --- | --- | --- | --- |
| Importance of multi-antenna at high f | Central to NR (mmWave panels, strong beamforming) | LTE multi-antenna is important but used at lower f | NR design leans more on beamforming at high f. |
| Downlink precoder transparency | DM-RS precoded with data ⇒ UE sees H’=HW | — | Simplifies UE demod regardless of gNB precoder choice. |
| UL codebook-based PUSCH | “Essentially the same as LTE,” but **more extensive codebooks** and **multi-SRS+SRI** extension | Baseline UL codebooks; **no** multi-SRS+SRI in LTE per this chapter | NR gives gNB an extra “beam pick” knob via SRI. |
| UL rank with DFT-s-OFDM | Single-layer only (transform-precoded) | — | Practical constraint on UL spatial multiplexing when DFT-s-OFDM is used. |

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the two documents: the one that maps codewords to ports and the one that chooses and reports the precoder.

Precoding is written in two places. The physical mapping — how codewords become layers, layers become ports, and ports carry the precoded reference signal — is TS 38.211. How the precoder is chosen and reported — the downlink codebooks, the two uplink modes, the resource indicators — is TS 38.214. The figure lays them out with the limits a scheduler works inside: eight downlink layers and four uplink, one with DFT precoding; the coherence-dependent uplink codebook; and the two-stage structure and bit cost of Type II feedback.

![[99 Attachments/5G/Protocol Figures/STAR-11-Multi-Antenna-Transmission-Protocol.png|The documents that define layer mapping, the precoding codebooks, and the uplink precoder modes]]

*Protocol figure: The documents that define layer mapping, the precoding codebooks, and the uplink precoder modes.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 6.3.1.5; 6.4.1.1; 7.4.1.1 | PUSCH precoding/layers and PUSCH/PDSCH DM-RS |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 5.1.5; 5.2; 6.1.1; 6.2 | downlink spatial assumptions, CSI, uplink precoding and SRS |
| TS 38.215 | V18.5.0, [38215-i50.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip) | 5 | physical-layer measurements supporting CSI |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.3.2 information elements | CSI, SRS, antenna and TCI configuration vocabulary |

!note[**When you build or run a demo.** An open-source base station declares how many downlink antennas it drives and the maximum layers it will schedule, and those two numbers bound everything else. The codebook type the phone will report against — Type I single-panel, in almost every demo — is a configuration line, and the phone's declared coherence decides which uplink codebook rows the scheduler may pick. The log then shows the loop closing: a rank and precoder index reported by the phone, and a transmitted precoder index and rank in the next grant. If the reported rank is stuck at one on a two-antenna phone, the channel is not rich enough, or the two antennas are too close, or the phone is transform-precoding its uplink; the log will not tell you which, but this table tells you which clause governs each.]

Release 15 already contained layer mapping, both uplink modes, CSI-RS, SRS, Type I and Type II reporting, and precoded reference signals; these are foundations. Release 16 added enhanced Type II and multi-point transmission; Release 18 refines capability and signalling while keeping ports, layers, rank, codewords, and precoding separate. Release descriptions are cross-checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the mapping; this trace runs one real-valued two-port example through it so that you can see the effective channel appear.

Consider a real-valued teaching example with two transmit ports and two receive observations. Let the propagation channel, normalized Hadamard precoder, and transmitted layer vector be

$$
\mathbf{H}=\begin{bmatrix}1&1\\1&-1\end{bmatrix},\qquad
\mathbf{W}=\frac{1}{\sqrt{2}}\begin{bmatrix}1&1\\1&-1\end{bmatrix},\qquad
\mathbf{s}=\begin{bmatrix}1\\-1\end{bmatrix}.
$$

Here, $\sqrt{2}$ is the normalization factor that gives each column of the assumed Hadamard precoder unit norm.

**What we are working out.** The noiseless received vector $\mathbf{y}$, obtained first by forming the effective channel and then applying it to the two layer symbols.

$$
\begin{aligned}
\mathbf{H}_{\mathrm{eff}}
&=\mathbf{H}\mathbf{W}\\
&=\begin{bmatrix}1&1\\1&-1\end{bmatrix}
\frac{1}{\sqrt{2}}\begin{bmatrix}1&1\\1&-1\end{bmatrix}\\
&=\begin{bmatrix}\sqrt{2}&0\\0&\sqrt{2}\end{bmatrix},\\[4pt]
\mathbf{y}
&=\mathbf{H}_{\mathrm{eff}}\mathbf{s}\\
&=\begin{bmatrix}\sqrt{2}&0\\0&\sqrt{2}\end{bmatrix}
\begin{bmatrix}1\\-1\end{bmatrix}\\
&=\begin{bmatrix}\sqrt{2}\\-\sqrt{2}\end{bmatrix}.
\end{aligned}
$$

In this formula, $\mathbf{H}$ is a dimensionless normalized $2\times2$ channel matrix; its entries are assumed for this pedagogical calculation. $\mathbf{W}$ is a dimensionless normalized precoder whose columns have unit norm, and $\sqrt{2}$ is its normalization factor. $\mathbf{s}$ contains two unit-amplitude BPSK teaching symbols and therefore has normalized units. $\mathbf{H}_{\mathrm{eff}}$ is the effective channel seen by the two layers. Noise is set to zero only to expose the spatial algebra. These numbers are not prescribed by 3GPP; the official plane defines processing and signaling, while the values belong to the teaching plane. The example’s structural basis is the matrix model used in the chapter and in TS 38.211/38.214 processing clauses.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $\mathbf{H}$ | $[[1,1],[1,-1]]$ | normalized | pedagogical assumption |
| $\mathbf{W}$ | $\frac{1}{\sqrt2}[[1,1],[1,-1]]$ | normalized | pedagogical assumption |
| $\mathbf{s}$ | $[1,-1]^T$ | normalized BPSK symbols | pedagogical assumption |
| $\mathbf{H}_{\mathrm{eff}}$ | $\sqrt2\mathbf{I}$ | normalized | derived result |
| $\mathbf{y}$ | $[\sqrt2,-\sqrt2]^T$ | normalized | derived result |

The diagonal result is intentionally ideal. Real channels are complex, time-varying, frequency-selective, noisy, and imperfectly estimated. A practical scheduler might choose rank one if the singular values are unequal or if feedback delay makes the second dimension unreliable. The example demonstrates the principle: spatial multiplexing depends on the combined channel and precoder.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star supports U06, U07, and U08. U06 supplies OFDM resource and reference-signal foundations; U07 supplies propagation, fading, and channel-estimation concepts; U08 uses those foundations for MIMO, beamforming, diversity, and spatial multiplexing. A productive study order is: first distinguish ports from elements, then write the matrix model, then compare array gain with multiplexing gain, and finally trace CSI/DM-RS signaling through a scheduled link.

The worked example can be reused as a tutorial-board derivation after students understand complex channel coefficients. A useful oral check is: “Can a 64-element base station transmit rank one?” The correct answer is yes, because element count and layer count occupy different abstraction levels.

!warning[**“Massive MIMO means many layers”.**

Massive MIMO describes a large array regime; it does not guarantee high instantaneous rank. A large array can serve a single layer with strong beamforming gain, or serve several UEs through multi-user spatial separation. Rank depends on channel geometry, receiver capability, interference, and scheduling.]

!warning[**“DM-RS reveals every physical antenna channel”.**

For scheduled PDSCH, DM-RS lets the UE estimate the effective channel associated with the active port and precoding arrangement. Element-level channels and internal analog weights can remain hidden. Treating DM-RS as an array-calibration probe confuses an air-interface observable with implementation internals.]

!warning[**“PMI is the beam, and TCI is the precoder”.**

PMI is a feedback indication within a configured CSI codebook framework. A TCI state conveys QCL-related reception assumptions and associated reference signals. Either can correlate with beam choices, but neither phrase should be substituted blindly for a vendor’s numerical element-weight vector.]

!warning[**“Non-codebook PUSCH does not need SRS”.**

Non-codebook operation still relies on SRS resources or ports that represent candidate spatial transmissions. The distinction concerns how the transmission is selected and represented.]

!warning[**“More rank always means more throughput”.**

Additional layers split power and require separable channel dimensions. If the second singular mode is weak, a robust rank-one MCS can outperform a fragile rank-two allocation after retransmissions are counted. Rank, MCS, and resource allocation must be optimized jointly.]

### 6.1 Supplement: diversity and combining

The confusions above assumed several antennas already cooperate. This supplement steps back to diversity: several fading copies and a rule for adding them.

!warning[Before precoding there is diversity: several independently fading copies, and a rule for adding them. Every NR receiver is the last row of this table generalised.]

![[99 Attachments/5G/Supplement Figures/STAR-11-Saar-Diversity-Combining.png|Diversity branches and the three combiners]]

*Supplement figure: Diversity: four cards for space, polarisation, frequency and time branches; three combiner block diagrams for selection, equal-gain and maximal-ratio combining with their SNR formulas; two panels on interleaving and equalisation versus OFDM.*
*Figure 6.1 — Space, polarisation, frequency and time branches; selection, equal-gain and maximal-ratio combining; interleaving and equalisation.*

| Combiner | Rule | Output SNR | Needs |
|---|---|---|---|
| Selection | keep the best branch | max γi | SNR per branch |
| Equal gain | co-phase, equal weights | ≈ (Σ√γi)²/L | phase only |
| Maximal ratio | co-phase, weight by amplitude over noise | Σ γi | full channel estimate |

- Branch separation rules: antennas ≥ λ/2 apart, orthogonal polarisations, Δf > Bc, Δt > Tc.

Source: Supplementary material, *Multipath countermeasures* (handout); 3GPP TS 38.212, TS 38.214.

### 6.2 Supplement: massive MIMO as the deck tells it

Section 6.1 combined copies; this supplement follows the training deck's history of adding antennas until the array itself became the technology.

!warning[The training deck frames massive MIMO historically: each generation added antennas until the array itself became the technology.]

![[99 Attachments/5G/Supplement Figures/STAR-11-Saar-Massive-MIMO-Evolution.png|Massive MIMO: the antenna-count ladder, the claims and the deployment shapes]]

*Supplement figure: Massive MIMO evolution: five cards from 3G SISO to 5G 64T64R joined by arrows, two notes on the capacity and energy claims and their difficulties, and two deployment cards.*
*Figure 6.2 — From SISO to 64T64R, the capacity and energy claims, and the two deployment shapes.*

| Generation | Configuration | Headline peak |
|---|---|---|
| WCDMA / HSPA | SISO | 7.2 Mb/s |
| HSPA+ | 2×2 | 42 Mb/s |
| LTE / LTE-Advanced | 4×4 / 8×8 | 100 Mb/s / 1 Gb/s |
| NR massive MIMO | 64T64R and beyond | tens of Gb/s per cell |

Source: Supplementary material, *5G key technologies and applications* (training deck, 2018), slides 60–63.

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-11-Multi-Antenna-Transmission|Chapter 11]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00011-8)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.215/38215-i50.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_MIMO.html)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_CSI_Report.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_SRS.html)
15. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BPSK | Binary phase-shift keying | teaching modulation in the example. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| CQI | Channel quality indicator | reported link-quality recommendation. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| CSI | Channel state information | measurements and feedback for adaptation. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| CSI-RS | CSI reference signal | downlink measurement reference. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| DFT-s-OFDM | Discrete-Fourier-transform-spread OFDM | optional uplink waveform with restricted layer scope. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| DM-RS | Demodulation reference signal | effective-channel estimation for a scheduled channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| gNB | next-generation NodeB | NR base station. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| MCS | Modulation and coding scheme | scheduled robustness/throughput choice. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| MIMO | Multiple-input multiple-output | spatial transmission with multiple inputs and outputs. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PMI | Precoding matrix indicator | codebook-related CSI recommendation. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PDSCH | Physical downlink shared channel | downlink user-data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PUSCH | Physical uplink shared channel | uplink user-data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| QCL | Quasi-co-location | shared channel-property assumption. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| RI | Rank indicator | recommended layer count. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| SRS | Sounding reference signal | uplink channel sounding reference. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| TCI | Transmission configuration indication | configured QCL/spatial reception assumptions. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| UE | User equipment | NR terminal. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $\mathbf{H}$ | propagation channel matrix | complex or normalized gain |
| $\mathbf{W}$ | precoding matrix | dimensionless normalized weights |
| $\mathbf{H}_{\mathrm{eff}}$ | effective channel $\mathbf{H}\mathbf{W}$ | complex or normalized gain |
| $\mathbf{s}$ | vector of layer modulation symbols | normalized symbol amplitude |
| $\mathbf{y}$ | received observation vector | normalized amplitude or volts after receiver scaling |
| $\mathbf{n}$ | receiver noise-plus-interference vector | same domain as $\mathbf{y}$ |
| $N_\mathrm{layer}$ | number of scheduled layers, or rank | count |
| $\sqrt{2}$ | diagonal gain in the teaching example | dimensionless |
| $\mathbf{I}$ | identity matrix | dimensionless |
| MRC | Maximal-Ratio Combining | MRC co-phases diversity branches and weights each by its amplitude over its noise. The output SNR is the sum of the branch SNRs. | Section 6; Supplement |
| EGC | Equal-Gain Combining | EGC co-phases diversity branches and adds them with equal weight. It approaches MRC when the branches are similar. | Section 6; Supplement |
| ISI | Inter-Symbol Interference | ISI is the smearing of one symbol into the next by multipath delay. Equalisation or OFDM with a cyclic prefix removes it. | Section 6; Supplement |
| C-RAN | Centralised Radio Access Network | C-RAN pools baseband processing away from the antenna sites. Distributed antennas are processed jointly. | Section 6; Supplement |
