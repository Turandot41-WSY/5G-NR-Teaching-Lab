---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 15
title: Uplink Power and Timing Control
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-15 — Uplink Power and Timing Control

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Picture a choir spread across a field, singing to one conductor. The singer a hundred metres away and the singer five kilometres away must both be heard at the same loudness, and their syllables must land on the same beat. So the far singer sings at full voice and starts early; the near singer sings softly and starts on time. Every phone in a cell faces the same two decisions, and the chapter is about the two control loops that make them.

![[99 Attachments/5G/Concept Figures/STAR-15-Uplink-Power-and-Timing-Control-Concept.png|Uplink power and timing control explained as a choir singing to one conductor]]

*Concept figure: Uplink power and timing control explained as a choir singing to one conductor.*

The first dial is how loud. A phone measures how faint the tower sounds to it, and sings louder by that much; that is open-loop power control, done from a downlink measurement with no help from the network. Then the tower whispers small corrections, "a touch louder", "quieter", in two-bit commands that add up; that is the closed loop. Too loud wastes battery and drowns the phones in the next cell. Too quiet and the tower cannot decode the block.

The second dial is how early. Radio takes 3.3 microseconds per kilometre, and the tower's receiver only tolerates arrivals inside the short cyclic prefix of Star 07. The tower hears each phone's first transmission, measures how late it arrived, and tells the phone to start that much earlier: the timing advance. Every uplink transmission afterwards lands inside the same window, which is what keeps different phones' subcarriers orthogonal.

The two loops have different failure modes. Too loud is interference; too late is a broken OFDM symbol. Neither can be fixed by the other, so the chapter treats them as two separate mechanisms that happen to share one uplink.

**The question this chapter answers.** How does a gNB receive many UE transmissions with usable power and OFDM alignment when every UE has a different path loss, traffic, bandwidth, mobility, and hardware limit?

!important[**The short answer.** NR combines open-loop and closed-loop power control with timing advance. Open-loop control uses configured targets and the UE's own path-loss estimate to set a sensible transmit-power density; allocation bandwidth, transport-format effects, and closed-loop commands modify that value, and the UE's maximum transmit power clips the result. Timing advance moves a UE's uplink earlier so that signals from different distances fall inside the gNB receiver's arrival window.]

Names you will meet in this note: path loss (PL), transmit power control (TPC), power headroom report (PHR), timing advance (TA), timing-advance group (TAG), cyclic prefix (CP), supplementary uplink (SUL), modulation and coding scheme (MCS), sounding reference signal (SRS).

## 2. Where you are in 5G

Section 1 tuned a choir spread across a field. The map below shows where the two loops sit in 5G: in the uplink, between the grant of Star 14 and the transmission itself.

![[99 Attachments/5G/Locator Maps/STAR-15-Where-You-Are-in-5G.png|Where Star 15 sits in the whole 5G system]]

*Locator: Where Star 15 sits in the whole 5G system.*

This chapter lights the uplink control loops in the procedures band. It sits between the scheduler of Star 14, which decides how many resource blocks a phone gets and therefore how much power it needs, and random access in Star 17, which gives a phone its first timing advance. The physical layer of Star 07 supplies the cyclic prefix that the timing loop must respect; the power-headroom report of Star 14 is what the power loop sends back.

The Knowledge Structure Map draws the two loops side by side with their inputs. The mechanism diagram traces one power decision and one timing correction through the phone and the base station.

![[99 Attachments/5G/Knowledge Maps/STAR-15-Uplink-Power-and-Timing-Control-Knowledge Structure Map.png|STAR-15 system-position map]]

*Knowledge map: The uplink power-control equation broken into its terms.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-15-Uplink-Power-and-Timing-Loop.png|Star 15 mechanism and handoff diagram]]

*Mechanism: Why timing advance exists, shown as geometry and arrival times.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 15.1 Uplink Power Control → 15.2 Uplink Timing Control → Security Implications.


## 3. The textbook road

Section 2 placed the loops. The road below walks through the chapter in the book's order: power control, timing control, then the security question a reader asked.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **15.1 Uplink Power Control**

The road begins with loudness: how each phone's transmit power is set so that the base station hears every uplink at a level it can decode.

!important[Uplink power control sets each phone's transmit power so that the base station receives every uplink signal, whether data, control, preamble, or sounding, at a level it can decode, while interference to neighbouring cells stays low. It combines two operations. The open loop sets power from the phone's own estimate of path loss, made from a downlink reference signal. The closed loop refines it with commands from the base station based on what it actually received. Compared with LTE, NR adds beam awareness: several uplink beams can each have their own path-loss estimate and parameters.]

#### 3.1.1 **15.1.1 Baseline Power Control**

The PUSCH power is Equation 15.1:

$$
P_{PUSCH} = \min \{ P_{CMAX}, P_0 + \alpha \cdot PL + 10\log_{10}(2^{\mu} \cdot M_{RB}) + \Delta_{TF} + \delta \}
$$

Each term has an owner. $P_0$ is the target received power at the base station, configured. $\alpha$ is the path-loss compensation factor, configured, and fractional when below one. $PL$ is the path loss the phone estimates. The logarithmic term scales power with the number of resource blocks $M_{RB}$ at numerology $\mu$, because power is per subcarrier and a wider allocation needs proportionally more. $\Delta_{TF}$ corrects for the transport format, since a higher rate needs a higher signal-to-noise ratio. $\delta$ is the accumulated closed-loop adjustment. And $P_{CMAX}$ is the phone's maximum, which clips everything.

#### 3.1.2 **(1) Data Rate Dependence**

The required received power depends directly on the data rate. That follows from the Shannon relation

$$
C = B \cdot \log_2(1 + \text{SNR})
$$

To carry a higher rate the system needs a higher signal-to-noise ratio, hence more received power. The $\Delta_{TF}$ term captures this: a higher modulation and coding scheme raises the required energy per bit, so the phone transmits more; a lower one allows less. In practice power control and link adaptation are coupled. In poor conditions the base station lowers the rate rather than forcing power up and raising interference; in good conditions it allows a higher rate, which costs more power but yields more throughput. That coupling is what keeps spectral efficiency and interference stable together.

#### 3.1.3 **15.1.2 Beam-Based Power Control**

In NR power control operates per beam. Each uplink beam can have its own path-loss estimate and its own open-loop parameters, indexed by three configuration parameters $(q, j, l)$. Figure 15.1 shows it: each configured downlink reference signal, a CSI-RS or an SS block, yields a path-loss estimate; the parameter $q$ links a scheduling grant, through its SRS resource indicator, to a particular beam pair; and the transmit power follows the beam pair actually used. Up to four path-loss estimation processes can run in parallel, one per reference signal.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 15.1 shows it: each configured downlink reference signal, a CSI-RS or an SS block, yields a path-loss estimate; the parameter  links a scheduling grant, through its SRS resource indicator, to a particular beam pair; and the transmit power follows the beam pair actually used.*

#### 3.1.4 **Multiple Open/Closed-Loop Parameter Sets**

$P_0(j)$ and $\alpha(j)$ give different open-loop settings for random-access, scheduled, and grant-free transmissions. $\delta(l)$ supports two independent closed-loop processes, so that a correction learnt on one beam is not applied blindly to another. Together they allow beam-aware, service-specific power control that holds up as beams change.

#### 3.1.5 **15.1.3 Power Control for PUCCH**

Control-channel power follows the same shape with two differences. $\alpha$ is fixed at one, full path-loss compensation, because control information is worth more than the interference it costs. And the closed-loop commands arrive in downlink assignments, formats 1_0 and 1_1, rather than in uplink grants, since the control channel carries acknowledgements of downlink data. The acknowledgement must be reliable without wasting energy.

#### 3.1.6 **15.1.4 Power Control in Case of Multiple Uplink Carriers**

With carrier aggregation or a supplementary uplink, each carrier runs its own copy of the equation, but the sum of all transmit powers must stay below the phone's total limit $P_{TMAX}$. If simultaneous transmissions exceed it, powers are scaled down. In LTE–NR dual connectivity the LTE carrier is prioritised for control-plane continuity, and NR takes what remains.

> [!book] Book expansion
> Chapter 15 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 325–334, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00015-5)) introduces the power equation once, then shows each later feature, beams, control channel, and multiple carriers, as a change to one of its terms.

> [!spec] 3GPP reality check
> The equation is [TS 38.213 V18.8.0, clause 7.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) for PUSCH, 7.2.1 for PUCCH, 7.3.1 for SRS, and 7.4 for PRACH; the closed-loop command values are Table 7.1.1-1.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [power-control page](https://www.sharetechnote.com/html/5G/5G_PowerControl.html) works the equation with numbers and shows the RRC parameters that set each term.

### 3.2 **15.2 Uplink Timing Control**

Section 3.1 set the loudness; this section sets the beat, so that every phone's transmission lands inside the cyclic prefix.

!important[Uplink timing control makes every phone's transmission arrive at the base station inside the cyclic prefix, which is what keeps the subcarriers of different phones orthogonal on a shared uplink. Figure 15.2 shows two phones at different distances: the near one needs a small timing advance, the far one a large one, and both signals then arrive together.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 15.2 shows two phones at different distances: the near one needs a small timing advance, the far one a large one, and both signals then arrive together.*

#### 3.2.1 **Purpose and Mechanism**

The target is to make all phones' signals arrive at the same time. Without it the OFDM orthogonality across users breaks, producing intra-cell interference and decoding failure. Timing control is a requirement of any OFDMA uplink.

#### 3.2.2 **Timing Advance (TA)**

The base station measures each phone's uplink timing from what it receives, whether sounding, data, or a preamble, and sends a timing-advance command as a MAC control element telling the phone to move its transmission earlier or later. Updates come a few times a second, more often for a moving phone. Different numerologies use step sizes scaled to their cyclic-prefix lengths.

#### 3.2.3 **Loss of Uplink Synchronization**

If no timing-advance command arrives within a configured period, the phone assumes its uplink timing is no longer valid. It must then re-establish timing through random access before sending any data or control.

#### 3.2.4 **Timing-Advance Groups (TAGs)**

In multi-carrier or dual-connectivity setups, uplink carriers may terminate at different physical sites, such as remote radio heads. NR therefore groups carriers into timing-advance groups. All carriers in a group share one timing advance; different groups receive independent commands; and the step size follows the largest subcarrier spacing in the group.

> [!spec] 3GPP reality check
> The timing-advance definition and granularity are [TS 38.213 V18.8.0, clause 4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); the command, its six-bit format, and the alignment timer are TS 38.321 clauses 5.2 and 6.1.3.4.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [timing-advance page](https://www.sharetechnote.com/html/5G/5G_TimingAdvance.html) converts the command value to microseconds and metres for each numerology, which is the calculation a demo engineer most often needs.

### 3.3 **Security Implications**

Both loops are driven by commands from the base station. This section asks what an attacker could do with them, and what limits the damage.

Could an attacker exploit timing control, say by blocking timing-advance commands? In theory, and several layers limit it. Blocking the commands could force a phone into repeated random access, but RRC and MAC timers, backoff, and access barring bound the damage. Intercepting or spoofing the commands is impractical because they travel in MAC control elements inside ciphered, integrity-protected connections. And networks watch random-access failure and synchronisation-loss rates as anomaly signals, reallocating resources or switching beams when they rise. Physical-layer jamming remains, as in any wireless system, a low-level denial-of-service vector.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the clauses that hold the power equation, the timing advance and the commands that carry both.

Both loops are written down in TS 38.213. Clause 7 holds the power equation for each uplink channel, the closed-loop command table, and the allowed values of $\alpha$. Clause 4.2 defines the timing advance and its granularity. TS 38.321 carries the six-bit timing-advance command and the timer whose expiry sends a phone back to random access. TS 38.331 holds every constant: the target, the compensation factor, which reference signal the loss is measured on, and the timer. The figure draws the two equations with their clauses and the configuration lines they become.

![[99 Attachments/5G/Protocol Figures/STAR-15-Uplink-Power-and-Timing-Control-Protocol.png|The uplink power equation and the timing-advance command, with their clauses and configured values]]

*Protocol figure: The uplink power equation and the timing-advance command, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.2; 7 | timing advance and uplink power control |
| TS 38.321 | V18.10.0, [38321-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.2; 6.1.3 | timing maintenance and MAC control elements |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.3.2 information elements | power-control, PHR, timer, and timing-advance configuration |
| TS 38.101-3 | V18.14.0, [38101-3-ie0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-3/38101-3-ie0.zip) | applicable multi-band RF requirements | UE power constraints in inter-band/multi-radio cases |

!note[**When you build or run a demo.** The nominal target and the compensation factor are the two lines that decide whether a phone at the cell edge is heard or drowns its neighbours; the textbook's fractional compensation is one configured value below one. Whether closed-loop commands accumulate is a flag, and a demo whose uplink power drifts usually has it set differently from what the scheduler assumes. The alignment timer is the line that decides how long a silent phone keeps its timing before it must repeat random access; a long value suits a static demo bench, a short one a moving phone. And the timing-advance command in the base-station log, one value per phone, is the quickest way to read how far away each phone is.]

Release 15 introduced flexible numerology with scaled timing-advance steps, fractional open-loop power control, closed-loop commands, and the headroom report, and these remain the model. Release 16 extended the combinations, with multiple transmission points, configured grants, dual connectivity, and supplementary uplink, in which power and timing state must be managed. Release 18 keeps the indexed formulas and capability-dependent clauses. Release summaries are checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The clauses give the equation; this trace substitutes one set of values into it, a calculation you can redo by hand.

Assume a pedagogical allocation with $M=20$ resource blocks, $P_0=-80$ dBm, $\alpha=0.8$, estimated $PL=100$ dB, $\Delta_{TF}=1$ dB, closed-loop term $f=2$ dB, and applicable $P_{\mathrm{CMAX}}=23$ dBm.

**What we are working out.** The uncapped and capped PUSCH transmit power.

$$
\begin{aligned}
P_{\mathrm{raw}}
&=10\log_{10}(M)+P_0+\alpha PL+\Delta_{TF}+f\\
&=10\log_{10}(20)-80+0.8(100)+1+2\\
&=13.01-80+80+1+2\\
&=16.01\ \mathrm{dBm},\\
P_{\mathrm{PUSCH}}
&=\min(23,16.01)\ \mathrm{dBm}\\
&=16.01\ \mathrm{dBm}.
\end{aligned}
$$

In this formula, $P_{\mathrm{raw}}$ is the uncapped power request and $P_{\mathrm{PUSCH}}$ is the capped result. $M$ is the assumed resource-block count; $P_0$ and $P_{\mathrm{CMAX}}$ are absolute powers in dBm; $PL$, $\Delta_{TF}$, and $f$ are dB terms; $\alpha$ is dimensionless. The values are pedagogical and not a recommended network configuration. The structural equation is based on TS 38.213 clause 7, whose full indexed form and conditions govern real use. The result lies below the cap, leaving approximately 7 dB between requested power and this assumed ceiling, though formal PHR computation uses its own specified definitions.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $M$ | 20 | resource blocks | pedagogical assumption |
| $P_0$ | -80 | dBm | pedagogical configuration |
| $\alpha$ | 0.8 | dimensionless | pedagogical configuration |
| $PL$ | 100 | dB | assumed estimate |
| $\Delta_{TF}$ | 1 | dB | assumed adjustment |
| $f$ | 2 | dB | assumed closed-loop state |
| $P_{\mathrm{CMAX}}$ | 23 | dBm | assumed applicable ceiling |
| $P_{\mathrm{PUSCH}}$ | 16.01 | dBm | derived result |

If the raw sum exceeded 23 dBm, the UE would be power-limited. Increasing bandwidth then would not preserve the desired per-PRB power. The scheduler might reduce allocation, lower MCS, or accept a different link budget depending on policy. This is why power control and scheduling cannot be optimized independently.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star aligns primarily with U03, U04, and U05. The student needs OFDM symbols, cyclic prefix, resource blocks, link budget, and MAC-control concepts before power and timing loops become intuitive. It also prepares later performance work by showing that a scheduler’s nominal allocation may be infeasible under a UE power ceiling.

A compact lab can vary path loss and allocation size in the Section 5 equation, identify the clipping boundary, and then draw received OFDM symbols with residual arrival offsets inside or outside the cyclic-prefix tolerance.

!warning[**“Power control guarantees a target SINR”.**

The formula chooses transmit power from configured and measured terms under a ceiling. Interference, path-loss error, fading, and receiver conditions remain uncertain. Closed-loop feedback improves control but cannot guarantee instantaneous SINR.]

!warning[**“The Shannon equation defines the transport-format term”.**

Shannon capacity supplies broad intuition. The NR power-control terms and MCS procedures are standardized separately and include implementation decisions. Direct substitution confuses an information-theory bound with protocol configuration.]

!warning[**“Multiple carriers always share power proportionally, with LTE first”.**

Total-power and priority behavior depends on band combination, capability, channel combination, and applicable clauses. Neither proportional scaling nor LTE priority is a universal rule.]

!warning[**“Timing advance makes every signal arrive exactly together”.**

It brings arrivals into the receiver’s tolerated window. Quantization, motion, multipath, and processing margin prevent literal equality and explain why alignment needs maintenance.]

!warning[**“The timing-advance MAC CE is individually secured and cannot be jammed”.**

It is not an individually ciphered/integrity-protected standalone field. Security context and transport protection must be described at their actual layers, and physical jamming remains possible.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-15-Uplink-Power-and-Timing-Control|Chapter 15]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00015-5)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-3/38101-3-ie0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_PowerControl.html)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_TimingAdvance.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BWP | Bandwidth part | configured active bandwidth context. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| CP | Cyclic prefix | OFDM guard interval supporting timing tolerance. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| FFT | Fast Fourier transform | receiver OFDM demodulation operation. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| gNB | next-generation NodeB | NR base station. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MAC CE | Medium Access Control control element | carrier of timing/power-related control information. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MCS | Modulation and coding scheme | scheduled link-adaptation setting. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| OFDM | Orthogonal frequency-division multiplexing | waveform requiring controlled symbol alignment. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PHR | Power headroom report | UE indication of remaining power margin. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PRB | Physical resource block | scheduled bandwidth unit. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PUSCH | Physical uplink shared channel | uplink channel using the worked power formula. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SINR | Signal-to-interference-plus-noise ratio | received link-quality quantity. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SRS | Sounding reference signal | uplink channel measurement reference. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| TA | Timing advance | UE transmit-time shift command/state. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| TPC | Transmit power control | closed-loop power-control command/process. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| UE | User equipment | uplink transmitter. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $P_{\mathrm{PUSCH}}$ | applied PUSCH transmit power | dBm |
| $P_{\mathrm{raw}}$ | requested power before clipping | dBm |
| $P_{\mathrm{CMAX}}$ | applicable UE transmit-power ceiling | dBm |
| $M$ | scheduled allocation size | resource blocks or clause-defined bandwidth measure |
| $P_0$ | configured nominal power term | dBm |
| $\alpha$ | fractional path-loss compensation factor | dimensionless |
| $PL$ | estimated path loss | dB |
| $\Delta_{TF}$ | applicable transport-format adjustment | dB |
| $f$ | closed-loop TPC adjustment | dB |
| $T_\mathrm{CP}$ | cyclic-prefix duration | s |
| $\tau$ | propagation delay | s |
