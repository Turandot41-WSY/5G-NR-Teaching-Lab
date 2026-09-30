---
type: knowledge_synthesis
title: 'Uni-09 — A connected multiuser TDD cell: scheduling and delivered performance'
language: en
uni: 9
release_baseline: 18
cssclasses:
- research-note-tables
---

# Uni-09 — A connected multiuser TDD cell: scheduling and delivered performance

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#8.2 Abbreviation index]] and the maths letters in [[#8.3 Mathematical and physical symbol index]]; the lookup box in the right margin of the site explains any abbreviation as you type.

!important[A connected cell must divide finite radio opportunities among users with different channels and queued data. This experiment creates a next generation NodeB (gNB) and four User Equipment (UE) nodes in the Wireless Network Toolbox simulator. It compares scheduling policies, offered traffic, positions and Time Division Duplex (TDD) patterns using actual application delivery and protocol counters.]

The system map starts with connected users and follows data to the receiving application.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - System Overview v1.png]]

*Original system schematic. Application arrivals feed the Radio Link Control (RLC) and Medium Access Control (MAC) processing. Scheduling and Hybrid Automatic Repeat Request (HARQ) affect delivery; the TDD pattern bounds when each direction can transmit.*

## 1. Knowledge sources and engineering objective

**Stage — Textbook workflow.**

The overview above followed data from arrivals to the receiving application. This section says what the experiment measures and where the knowledge comes from.

The objective is to measure how a scheduler trades cell payload, service to individual users and delay when the load exceeds available resources. The implementation starts after connection establishment. `connectUE` creates the simulator connection directly; these results do not require a preceding access experiment to execute.

The source contributions identify the mechanisms whose effects can and cannot be measured here.

| Source | Contribution | Experiment interface |
| --- | --- | --- |
| [[Star-14-Scheduling\|Scheduling]] | Resource allocation and policy objectives | Three built in schedulers |
| [[Star-20-Industrial-IoT-and-URLLC-Enhancements\|Industrial services]] | Delivery and deadline requirements | Delay and finite reliability evidence |
| [[Star-21-Interference-Handling-in-TDD-Networks\|TDD interference]] | Direction and neighboring cell assumptions | Explicit single cell boundary |
| [[Star-28-TS-38.300-NR-and-NG-RAN-Overall-Description\|System description]] | Layer responsibilities | Application, RLC, MAC and physical layer |
| [[Star-33-TS-38.321-Medium-Access-Control\|MAC]] | Scheduling reports and HARQ processes | MAC retransmission counters |
| [[Star-34-TS-38.322-Radio-Link-Control\|RLC]] | Segmentation and reassembly | Default unacknowledged bearer |

The Chapter 14, 20 and 21 notes of this knowledge base ([[Star-14-Scheduling|Star-14]], [[Star-20-Industrial-IoT-and-URLLC-Enhancements|Star-20]] and [[Star-21-Interference-Handling-in-TDD-Networks|Star-21]]) motivate these comparisons. Their broader industrial and interference procedures are not inferred from a single simulated cell. 

The frozen Third Generation Partnership Project (3GPP) sources assign the relevant behavior to exact clauses.

| Source | Exact version | Clause | Used here |
| --- | --- | --- | --- |
| [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | 18.10.0 | 6; 10 | Layer 2 and scheduling context |
| [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 18.8.0 | 11.1 | Slot directions and TDD interpretation |
| [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 18.10.0 | 5.1.2; 5.1.3; 6.1.2; 6.1.4 | Resource assignments and data sizes |
| [TS 38.321](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 18.10.0 | 5.3; 5.4 | Downlink and uplink transfer and HARQ |
| [TS 38.322](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip) | 18.2.0 | 5.2.2 | Unacknowledged RLC data transfer |
| [TS 38.331](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 18.10.0 | 6.3.2 | TDD and RLC configuration information elements |

## 2. Build the connected cell and preserve its assumptions

**Stage — 3GPP protocol.**

Section 1 gave the sources. This section builds the connected cell in the simulator and records every assumption.

The experiment uses MATLAB R2026a Update 4, version 26.1.0.3312084, 5G Toolbox 26.1 and Wireless Network Toolbox 26.1. `wirelessNetworkSimulator`, `nrGNB`, `nrUE`, `networkTrafficOnOff`, `statistics` and `kpi` execute the network. Thirty six independent simulator instances were run: four scenarios, three policies and three repetitions.

Both node types explicitly use `PHYModel='abstract-phy'`. This physical layer maps link quality into packet error behavior. It does not generate and decode complex waveform samples for each network packet. The network evidence is event driven protocol and delivery evidence; the waveform evidence remains in [[Uni-06-PUSCH-Power-Control-and-Coverage]] and [[Uni-07-CSI-Feedback-and-Adaptive-MIMO]]. [MathWorks nrGNB documentation](https://www.mathworks.com/help/5g/ref/nrgnb.html) defines the distinction and the required toolbox.

The baseline uses one antenna at every transmitter and receiver. The simulator's default free space path loss is retained. There is no mobility, shadowing, clutter model, external interferer, second cell or calibrated fading channel. The selected gNB power of 10 dBm is an experimental choice that makes position dependent service visible; it is not a macrocell deployment recommendation.

The configured values and retained defaults form the reproducibility boundary.

| Quantity | Value | MATLAB owner | Meaning |
| --- | --- | --- | --- |
| Frequency and bandwidth | 3.5 GHz; 5 MHz | nrGNB | Shared TDD carrier |
| Subcarrier spacing | 30 kHz | nrGNB | 0.5 ms slots |
| Peak transmit powers | gNB 10 dBm; UE 23 dBm | TransmitPower | Full allocation reference |
| Antennas | One transmit; one receive | Node defaults | No spatial multiplexing |
| Noise figures | gNB and UE: 6 dB | Node defaults | Receiver assumption |
| Receive gains | gNB 6 dB; UE 0 dB | Node defaults | Directional budget asymmetry |
| Maximum users per slot | 2 | MaxNumUsersPerTTI | Shared scheduling limit |
| Frequency allocation | Type 1 | ResourceAllocationType | Contiguous resource blocks |
| Run and observation step | 0.2 s; 0.01 s | cfg.duration; cfg.step | Finite window; twenty observations |
| Random seeds | 9007 + 100 × scenario + repetition | rng, twister | Same seed across policies |

### 2.1 Place users and understand the propagation comparison

The first assumption is geometry; this section places the users and explains the propagation comparison.

The gNB is at [0,0,10] m. Baseline UE positions are [30,0,1.5], [100,100,1.5], [300,−100,1.5] and [700,0,1.5] m. The far scenario multiplies the two horizontal coordinates by four and retains the heights. The plot uses a right handed East, North, Up (ENU) convention viewed from above; the simulation takes Cartesian distances and does not attach a geographical origin.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - UE positions v2.png]]

*MATLAB output from positions and farpositions: plan view in east and north metres with the gNB at the origin at 10 m height. Baseline slant distances are 31.2, 141.7, 316.3 and 700.1 m; the far scenario multiplies the horizontal coordinates by four, adding about 12 dB of free-space loss. Labels mark the far users; each baseline user sits one quarter of the way out along the same direction.*

For a free space model, the isotropic propagation loss is

$$PL_{\mathrm{dB}}=20\log_{10}\!\left(\frac{4\pi d f_c}{c}\right).$$

Here d is the three dimensional separation, f_c the carrier frequency and c the speed of light. Multiplying d by four adds approximately 12.04 dB of propagation loss. The retained height difference makes the actual distance ratio slightly different for the nearest UE. Antenna gains and receiver noise belong to the node configuration.

### 2.2 Translate TDD configuration into available directions

Section 2.1 placed the users. This section translates the TDD configuration into the directions each slot allows.

One 2.5 ms period contains five slots. The baseline has two full downlink (DL) slots, a special slot with 12 DL symbols, one guard symbol and one Uplink (UL) sounding symbol, then two full UL slots. The alternative has one full DL slot, the same special slot and three full UL slots. The `NumULSymbols=1` special slot symbol is reserved for the Sounding Reference Signal (SRS) by this toolbox implementation.

The common TDD configuration sets available transmission directions before the scheduler assigns users. Compare the protocol's slot and symbol counts with the plotted direction arrays to identify which full data opportunity changes direction in the alternative pattern.


External source: [11.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.213 V18.8.0, §11.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=209), printed page 208. The common TDD pattern fixes the downlink, uplink and flexible symbol counts within a period. Scheduler policies used to assign users are engineering choices.*


![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - TDD symbol allocations v2.png]]

*MATLAB output from patterns: the 70 symbol positions of one 2.5 ms period for the baseline with 2 DL, special and 2 UL slots and the more-uplink pattern with 1 DL, special and 3 UL, coloured by direction. The single uplink symbol of the special slot carries SRS, so it does not add a complete data slot.*


The nominal directional fractions, before reference signals and other implementation constraints, are

$$
\eta_{\mathrm{DL,base}}=\frac{2\times14+12}{70}=0.5714,
\qquad
\eta_{\mathrm{DL,moreUL}}=\frac{14+12}{70}=0.3714.
$$

The number of complete UL data slots rises from two to three. These counts explain the resource trade; they do not predict payload by themselves. [TS 38.213 V18.8.0, §11.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) defines direction interpretation, and [TS 38.331 V18.10.0, §6.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) defines the related configuration information elements. The local MATLAB field names are an interface to that configuration.

### 2.3 Configure traffic and the retained bearer

Section 2.2 fixed the directions. This section configures the traffic and the bearer that carries it.

Each application packet contains 1000 bytes. On time is 1 s and off time is zero, so each source stays active throughout the 0.2 s run. DataRate uses kbit/s. Full buffer mode is off; packets are generated by actual application sources.

The scenario table separates increased offered traffic from changes in geometry and directional resources. These controlled changes determine which earlier result each later comparison should use as its reference.

| Scenario | DL per UE | UL per UE | Position and pattern |
| --- | --- | --- | --- |
| Light | 500 kbit/s | 500 kbit/s | Baseline |
| Heavy | 6000 kbit/s | 3000 kbit/s | Baseline |
| Far users | 6000 kbit/s | 3000 kbit/s | Horizontal positions × 4 |
| More uplink | 6000 kbit/s | 3000 kbit/s | One DL and three UL full slots |

The default RLC bearer uses bidirectional Unacknowledged Mode (UM), a 12 bit sequence number, a 400 packet transmit buffer and a 30 ms reassembly timer. The default Buffer Status Report (BSR) period is 5 ms. The installed gNB implementation selects a CSI Reference Signal (CSI-RS) period of ten slots for these patterns; the default report period follows it. The Proportional Fair (PF) averaging time constant is twenty slots. These are retained MATLAB defaults. [MathWorks connectUE documentation](https://www.mathworks.com/help/5g/ref/nrgnb.connectue.html) explains default bearer and reporting configuration; the exact installed source is included in the source hash record.

!note[UM provides segmentation and reassembly but has no RLC retransmission procedure. The retransmission counters in this experiment belong to MAC HARQ. [TS 38.322 V18.2.0, §5.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip) defines UM transfer. Acknowledged Mode (AM), its polling and its retransmission timers are outside this run.]

## 3. Follow the scheduler, HARQ and application measurements

**Stage — MATLAB experiment.**

Section 2 built the cell. This section shows the code that runs it and separates what the standard fixes from what the scheduler chooses.

The runnable core creates the configured nodes and connects each UE before traffic starts.

```matlab
sim = wirelessNetworkSimulator.init;
g = nrGNB(DuplexMode='TDD',ChannelBandwidth=5e6, ...
    SubcarrierSpacing=30e3,CarrierFrequency=3.5e9, ...
    TransmitPower=10,Position=[0 0 10], ...
    DLULConfigTDD=pat,PHYModel='abstract-phy');
configureScheduler(g,Scheduler=policies(policy), ...
    MaxNumUsersPerTTI=2,ResourceAllocationType=1);
u = nrUE(Position=pos,TransmitPower=23,PHYModel='abstract-phy');
connectUE(g,u);
addNodes(sim,g);
addNodes(sim,u);
addTrafficSource(g,networkTrafficOnOff(DataRate=6000, ...
    PacketSize=1000,OnTime=1,OffTime=0),DestinationNode=u(1));
```

The full script adds both directions for all four users and registers application events. `run(sim,0.01,IsLastStep=...)` advances the same simulator instance between observations. It does not recreate the network at each sample.

### 3.1 Separate standardized procedures from policy choices

The first separation is between standardised procedures and the three scheduling policies.

!important[Round Robin (RR) rotates scheduling opportunities. Best Channel Quality Indicator (BestCQI) prioritizes favorable reported quality. PF accounts for instantaneous achievable rate relative to previously served rate. In the installed scheduler, its priority has the form]

$$\pi_i=\frac{r_i^{\alpha}}{\overline r_i^{\beta}},
\qquad\alpha=\beta=1\ \text{for PF}.$$

The report, traffic buffers, eligibility and HARQ state constrain which users can receive a grant. A high priority is therefore not a guarantee that all resources go to that user. The three policies are implementations supplied by MathWorks; 3GPP does not mandate a universal optimization objective across users. [TS 38.300 V18.10.0, §10](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) supplies the scheduling framework.

The toolbox schedules pending retransmissions before new data, retains the original transmission settings for those retransmissions, and supplies scheduling grants directly to UE nodes without modeling a Physical Downlink Control Channel (PDCCH) waveform or its errors. These are material simulator assumptions documented in the [MathWorks scheduler overview](https://www.mathworks.com/help/5g/ug/overview-nr-scheduler.html). The counter results cannot establish control channel reliability.

### 3.2 Interpret HARQ without mixing protocol layers

Section 3.1 covered scheduling. This section covers HARQ without mixing it with the layers above.

A failed physical transfer can request a MAC retransmission; a successful transfer advances delivery toward RLC reassembly and the application. The MAC HARQ processes in [TS 38.321 V18.10.0, §§5.3 and 5.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) own transport block state. HARQ feedback is not a MAC control element carried as part of the same payload.

A useful queue accounting identity is

$$B_i(t+\Delta t)=B_i(t)+A_i(t)-S_i(t)-D_i(t),$$

where B is buffered data, A new arrivals, S data removed for service and D discarded data over the interval. The actual stored application deficit, generated bytes minus delivered bytes, is broader than B: it can include queued data, data in transit and data lost before application delivery. The note labels it “undelivered bytes” and does not equate it to an exact RLC queue occupancy.

### 3.3 Define every reported metric

Sections 3.1 and 3.2 named the mechanisms. This section defines every metric the results report.

For user i over observation duration T, application goodput and delivery fraction are

$$G_i=\frac{8B_{i,\mathrm{received}}}{T},
\qquad
F_i=\frac{B_{i,\mathrm{received}}}{B_{i,\mathrm{generated}}}.$$

They count delivered application payload. Headers, coded bits, retransmitted copies and padding do not add new payload. Jain's fairness index across the four delivered rates is

$$J=\frac{(\sum_{i=1}^{4}G_i)^2}{4\sum_{i=1}^{4}G_i^2}.$$

J is one when rates are equal and approaches 1/4 when a single user receives all payload. Its interpretation depends on the offered load: equal rates may mean that all demands are met, or that all users are equally limited.

The application delay returned by `kpi` is the mean delay of packets that arrived. A user with no received packets has undefined conditional delay. The script converts the toolbox's zero in that case to `NaN`; those points are absent from delay plots. Unreceived packets are censored by the end of the 200 ms observation. A small conditional delay therefore cannot establish acceptable service to all generated packets.

The saved data retains different measurement levels.

| Object | Actual size | Fields | Interpretation |
| --- | --- | --- | --- |
| per_ue.csv | 144 rows × 19 columns | Rates, delays, bytes, retransmissions, decode failures | Four users per run |
| timeline.csv | 2880 rows × 11 columns | Time, per UE cumulative bytes and MAC retries | Twenty observations per run |
| events in run.mat | 36 cell entries | Time, node, generated/received flag, length, peer | Actual application events |
| raw in run.mat | 36 cell entries | Complete gNB and UE statistics; positions; TDD | Audit layer and configuration |
| summary.csv | 12 rows × 14 columns | Cell metrics and replicate intervals | Four scenarios × three policies |

Event records contain peer identity but do not retain packet identity. They support per user received byte accounting, including uplink traffic received at the gNB. They do not independently reconstruct a per packet delay distribution. The delay means come from the toolbox's application metric.

## 4. Compare traffic load before changing geometry

**Stage — Measured results.**

Section 3 defined the metrics. This section compares light and heavy traffic at the baseline geometry.

All quantitative figures are actual MATLAB output. Error bars across the three repetitions are approximate 95% Student t intervals, with their definition in [[#6. Finite samples, failure cases and evidence limits]]. Individual UE comparisons retain their identities; they are not independent samples of a random user population.

### 4.1 Light traffic exposes delivery timing with little competition

The first comparison is light traffic, where every policy delivers everything and only timing differs.

At light load, all policies deliver 2.08 Mbit/s downlink across four users. Each source generates thirteen packets during the finite interval, so the observed byte count corresponds to 0.52 Mbit/s per user. This initial arrival and packet quantization effect explains why measured payload slightly exceeds the nominal 0.5 Mbit/s generator rate over 0.2 s.

The per user downlink bars check whether that common cell total reaches every user. Equal delivered rates across policies establish that this light traffic case does not expose a throughput trade between their scheduling objectives.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light DLGoodputMbps v2.png]]

*MATLAB output from results.DLGoodputMbps in the light scenario: delivered downlink payload per user for each policy with t intervals over three repetitions. Every user's 0.5 Mbit/s demand is met under all policies, so equal throughput here reflects light load.*

The uplink bars apply the same byte accounting at the gNB application. Their small shortfall must be read against the observation boundary, since packets can remain pending when the run ends.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light ULGoodputMbps v2.png]]

*MATLAB output from results.ULGoodputMbps at light load: round robin and proportional fair deliver 1.92 Mbit/s in total and best CQI 2.00 Mbit/s. The small shortfall from generated bytes is packets still pending at the 200 ms boundary.*

The downlink delay plot retains the timing of received packets after the goodput comparison has established equal delivery. Differences here reflect when the scheduler can use the TDD opportunities relative to application arrivals.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light DLDelayMs v2.png]]

*MATLAB output from results.DLDelayMs at light load: mean delay of delivered downlink packets by user and policy. With little competition the delay is set by the TDD opportunity pattern and the packet arrival phase.*

Uplink delivery also waits for buffer reporting and an eligible transmission opportunity. Read the uplink delay plot separately from downlink delay because the two directions pass through different scheduling conditions.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light ULDelayMs v2.png]]

*MATLAB output from results.ULDelayMs at light load: delivered uplink delay, which includes waiting for an uplink slot, the buffer status report period and scheduling. It is a queueing delay measured at the application.*

The downlink HARQ counters test whether repeated physical transfers accompany the observed delivery timing. Their zero values provide the reference for later scenarios where traffic or propagation changes.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light DLRetransmissions v2.png]]

*MATLAB output from results.DLRetransmissions at light load: MAC HARQ retries counted at the gNB per user. Zero counts mean no observed downlink retransmission in this window, the reference for reading the delay and payload plots.*

The uplink retry counts come from each UE transmitter. Checking them alongside uplink delivery prevents a finite window shortfall from being treated as a decode failure without supporting protocol evidence.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Light ULRetransmissions v2.png]]

*MATLAB output from results.ULRetransmissions at light load: uplink HARQ retries counted at each UE transmitter, measured independently of the downlink counters.*

### 4.2 Heavy traffic exposes the policy objective

Section 4.1 had no competition. This section overloads the cell and shows what each policy does with scarcity.

Heavy traffic offers nominal totals of 24 Mbit/s downlink and 12 Mbit/s uplink. This exceeds the observed downlink service. RR and PF deliver nearly the same cell payload here, but opportunity fairness does not imply equal user throughput when channels differ.

The heavy downlink bars expose how each policy divides the capacity once demands cannot all be met. Compare the served rates by user, especially the absent BestCQI delivery for weaker links, before judging the cell total.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy DLGoodputMbps v2.png]]

*MATLAB output from results.DLGoodputMbps under heavy load: round robin repetition 1 delivers 3.04, 2.88, 2.16 and 1.08 Mbit/s to UE1 to UE4. Best CQI serves only the two strongest links and delivers no downlink packets to UE3 or UE4 during the window.*

Under the same offered traffic scenario, uplink rates remain more similar across users. The comparison below retains the different transmit powers and receive gains of this direction, which limit any inference from reciprocal propagation to equal service.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy ULGoodputMbps v2.png]]

*MATLAB output from results.ULGoodputMbps under heavy load: uplink rates stay much closer across users than the downlink. UE power of 23 dBm and the gNB receive gain give the uplink a different link budget, so propagation reciprocity does not imply equal outcomes.*

The heavy downlink delay plot must be read with the preceding delivery bars. Missing BestCQI points belong to users that received no packets; the plotted delays describe service only for the users the policy served.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy DLDelayMs v2.png]]

*MATLAB output from results.DLDelayMs under heavy load: best CQI has points only for UE1 and UE2 because the other users received nothing, so their delay is undefined. Round robin repetition 1 gives 51.7, 56.6, 66.7 and 84.2 ms across the four users.*

Comparing heavy uplink delay with the light traffic result holds geometry and TDD constant. The increase below therefore exposes waiting associated with greater traffic and scheduling competition under the retained link model.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy ULDelayMs v2.png]]

*MATLAB output from results.ULDelayMs under heavy load: conditional uplink delay grows with competition for uplink slots. Comparing with the light case attributes most of the increase to traffic and scheduling.*

The heavy downlink retry counters remain zero while delivery falls short of generated traffic. This combination identifies insufficient scheduled service in the baseline and gives no evidence of failed transmitted blocks causing the deficit.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy DLRetransmissions v2.png]]

*MATLAB output from results.DLRetransmissions under heavy load: zero downlink MAC retries coexist with a large undelivered byte deficit. Scheduling capacity limits service in this baseline while every transmitted block succeeds.*

The MAC rule identifies the transport block tracked by each uplink HARQ process; the scheduler comparison uses its retransmission counters.

External source: [5.4.2.1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.321 V18.10.0, §5.4.2.1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf#page=70), printed page 69. UL HARQ maintains parallel processes and each process supports one transport block. The experiment compares the resulting retransmission counters under its selected scheduler policies.*

The uplink counter plot checks the corresponding HARQ activity after increased load. These transport retransmissions and the application delivery fraction measure different events, so the latter cannot supply a block error rate.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Heavy ULRetransmissions v2.png]]

*MATLAB output from results.ULRetransmissions under heavy load: uplink retry counts as an independent diagnostic. A delivery fraction below one cannot by itself be read as a physical block error rate.*

The timeline accumulates successful cell delivery in repetition 1. A steeper BestCQI curve means more received payload across the cell; the earlier per user bars are still needed to identify who receives it.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - DLDeliveredBytes v2.png]]

*MATLAB output from timeline.DLDeliveredBytes, heavy scenario repetition 1: cumulative cell payload received every 10 ms per policy. Best CQI's steeper curve comes from serving the favourable users; this plot alone does not expose the starvation of the others.*

Subtracting delivered bytes from generated bytes produces the companion deficit trace. Its sustained growth shows unmet application demand during the run, including bytes still queued or in transit as well as any losses before reception.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - DLUndeliveredBytes v2.png]]

*MATLAB output from timeline generated minus delivered bytes, heavy scenario repetition 1: the cell's growing downlink deficit over 200 ms. It includes queued data, data in transit and data lost before application delivery, so it is broader than an RLC queue.*

## 5. Change position and TDD opportunities

**Stage — Measured results.**

Section 4 changed the load. This section changes the geometry and the TDD pattern instead.

The complete matrix of 36 runs compares changes in position and TDD opportunities through cell totals, fairness and delivery fraction.

### 5.1 Greater distance changes both usable rate and failure behavior

The first change moves the users away.

The far user scenario keeps heavy offered traffic and the baseline TDD pattern. Only horizontal position changes. The free space assumption makes this a controlled propagation comparison, with limited relevance to obstructed deployments.

Compare the far scenario's downlink bars with the heavy baseline for the same policy and user. The reduced delivered rates show which links account for the cell throughput loss after geometry changes under the free space model.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users DLGoodputMbps v2.png]]

*MATLAB output from results.DLGoodputMbps with horizontal positions multiplied by four: round robin delivers 5.04 Mbit/s cell downlink and best CQI 8.71 Mbit/s. The per-user bars show which links account for those totals after the extra 12 dB of loss.*

The uplink comparison tests the same position change with its different link budget. Inspect the farthest user's rate to see where the stronger uplink transmit configuration still leaves a service constraint.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users ULGoodputMbps v2.png]]

*MATLAB output from results.ULGoodputMbps in the far scenario: cell uplink payload falls to about 9.0 Mbit/s. The farthest user is hardest to serve although UE transmit power is 13 dB above the gNB's.*

The far downlink delay plot describes packets that arrive despite reduced service. Read missing points together with the goodput bars: absence means the conditional delay is undefined, while pending packets are censored by the end of the run.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users DLDelayMs v2.png]]

*MATLAB output from results.DLDelayMs in the far scenario: a missing point marks a user with no delivered packet, whose delay is undefined. The 200 ms window censors packets still pending at the end.*

The far uplink delay combines time awaiting service with any link adaptation and retransmission before reception. Its comparison with heavy baseline delay shows the service consequence of moving the users; the retry counters below help interpret the mechanism.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users ULDelayMs v2.png]]

*MATLAB output from results.ULDelayMs in the far scenario with t intervals across repetitions. Delay combines service opportunities, link adaptation and any retransmission before delivery.*

The abstract physical model now produces downlink failures that request HARQ retries. Compare these counts with each user's delivered rate, since infrequent scheduling can suppress both retries and successful service.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users DLRetransmissions v2.png]]

*MATLAB output from results.DLRetransmissions in the far scenario: the physical model now produces real downlink HARQ retries. A rarely scheduled user can show few retries while still receiving poor service, so retries must be read with delivered bytes.*

The uplink counters likewise record retries triggered by the abstract PHY outcomes. Together with the lower payload rates, they establish a failure mechanism in this geometry scenario that was absent from the heavy baseline's downlink results.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Far users ULRetransmissions v2.png]]

*MATLAB output from results.ULRetransmissions in the far scenario: uplink retries supply the explicit failure case the final test requires. The counts come from the abstract PHY's decode outcomes in the saved run.*

### 5.2 More uplink slots trade downlink capacity for uplink delivery

Section 5.1 changed distance. This section restores the positions and gives the uplink one more slot.

This scenario restores baseline positions and retains heavy traffic, then changes the directional pattern. The cell gives up one full DL slot and gains one full UL slot per period.

The downlink bars measure the cost of removing that full data opportunity at the original positions. Compare them with the heavy baseline to attribute the change to the configured TDD resources and resulting scheduling.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink DLGoodputMbps v2.png]]

*MATLAB output from results.DLGoodputMbps with the 1 DL / 3 UL pattern at baseline positions: round robin downlink falls from 9.15 to 5.67 Mbit/s. The loss is set by actual scheduling and overhead as well as the reduced 0.371 downlink symbol fraction.*

The corresponding uplink bars test whether the added opportunity carries more of the unchanged demand. Their increase establishes the directional benefit that must be weighed against the downlink reduction.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink ULGoodputMbps v2.png]]

*MATLAB output from results.ULGoodputMbps with the more-uplink pattern: round robin uplink rises from 9.73 to 11.76 Mbit/s, approaching the offered 12 Mbit/s over this window.*

Fewer downlink opportunities also change when delivered packets can be served. The delay comparison below shows the added waiting among received packets, with undefined delays retained for users without delivery.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink DLDelayMs v2.png]]

*MATLAB output from results.DLDelayMs with the more-uplink pattern: delivered downlink packets compete for fewer opportunities and wait longer. Best CQI's absent points again mark users with no delivery.*

The extra uplink slot reduces waiting for the same offered uplink traffic. Inspect that reduction alongside the increased goodput to assess the improvement in both delivered quantity and reception timing during the finite window.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink ULDelayMs v2.png]]

*MATLAB output from results.ULDelayMs with the more-uplink pattern: additional uplink slots reduce waiting for the fixed offered uplink load. The measurement is conditional on reception before the run ends.*

The downlink retry counters check whether the reduced delivery is accompanied by physical failures. They remain zero under the retained baseline propagation, supporting the interpretation that fewer scheduling opportunities reduce service.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink DLRetransmissions v2.png]]

*MATLAB output from results.DLRetransmissions with the more-uplink pattern: baseline propagation is retained, so retries stay at zero while downlink opportunities fall. The direction change acts through available resources.*

The uplink counter comparison checks the added delivery against retransmission demand. More received bytes without increased retries is consistent with the extra slot supporting more first transmissions.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - More uplink ULRetransmissions v2.png]]

*MATLAB output from results.ULRetransmissions with the more-uplink pattern: uplink retries alongside the increased payload. More delivered bytes come from more first transmissions without an increase in retries.*

### 5.3 Compare cell totals with user fairness and delivery fraction

Sections 5.1 and 5.2 looked at users. This section aggregates the whole matrix into cell totals, fairness and delivery fraction.

These six figures aggregate the complete experimental matrix into cell payload, rate fairness and delivery fraction. The downlink total below records the gain from favoring stronger links under overload, while the following fairness comparisons retain the cost to other users.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell DLGoodputMbps v2.png]]

*MATLAB output from summary.DLGoodputMbps: mean cell downlink payload per scenario and policy with t intervals over three repetitions. Best CQI raises the total under overload by serving favourable links; the Jain plot below shows how unevenly.*

The uplink totals separate the propagation penalty of the far scenario from the benefit of another uplink slot. Reading both directions together prevents a directional resource trade from appearing to improve the entire cell uniformly.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell ULGoodputMbps v2.png]]

*MATLAB output from summary.ULGoodputMbps: mean cell uplink payload responds strongly to the TDD change and shows a separate propagation penalty in the far scenario.*

Calculating Jain's index from each run's user rates exposes the distribution hidden in the downlink total. The BestCQI decline under heavy traffic corresponds to its observed concentration of delivery among the strongest users.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell DLJain v2.png]]

*MATLAB output from summary.DLJain: Jain fairness of the four downlink rates. The heavy baseline gives about 0.899 for round robin and proportional fair and 0.500 for best CQI, which serves two of four users; a high total rate coexists with unequal delivery.*

The uplink fairness plot applies the same calculation to the reverse direction. Its change in the far scenario shows where the otherwise similar user rates separate as the propagation conditions worsen.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell ULJain v2.png]]

*MATLAB output from summary.ULJain: uplink fairness stays near one in the heavy baseline and more-uplink cases and falls to 0.787 for far-user best CQI, exposing a different directional constraint.*

Dividing received downlink bytes by generated bytes measures how much offered demand the cell serves. The plot below complements fairness: a higher aggregate fraction can coexist with users receiving nothing.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell DLDeliveryFraction v2.png]]

*MATLAB output from summary.DLDeliveryFraction: delivered over generated downlink bytes. Only 37.9% arrive under heavy round robin or proportional fair; best CQI delivers 48.8% in total while leaving two users unserved during the window.*

The uplink fraction approaches complete delivery when the pattern supplies more uplink opportunities. Its remaining deficit includes packets pending at the observation boundary, so this comparison supports a service result within the run rather than an inferred packet loss probability.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Cell ULDeliveryFraction v2.png]]

*MATLAB output from summary.ULDeliveryFraction: the more-uplink pattern delivers about 98% of generated uplink bytes under round robin and proportional fair. The remainder is not automatically a loss probability, because packets can still be pending at the boundary.*

Selected numerical results make the policy trade explicit.

| Scenario and policy | DL payload | UL payload | DL Jain | DL delivery fraction |
| --- | --- | --- | --- | --- |
| Light RR | 2.080 Mbit/s | 1.920 Mbit/s | 1.000 | 1.000 |
| Heavy RR | 9.147 Mbit/s | 9.733 Mbit/s | 0.899 | 0.379 |
| Heavy BestCQI | 11.787 Mbit/s | 9.720 Mbit/s | 0.500 | 0.488 |
| Far users RR | 5.040 Mbit/s | 9.067 Mbit/s | 0.554 | 0.209 |
| More uplink RR | 5.667 Mbit/s | 11.760 Mbit/s | 0.928 | 0.235 |

## 6. Finite samples, failure cases and evidence limits

**Stage — Measured results.**

Section 5 reported means. This section says what three repetitions can and cannot show, and names the failure cases.

Each reported mean uses three repetitions. For a replicate metric x, the plotted interval is

$$\overline x\ \pm\ t_{0.975,2}\frac{s_x}{\sqrt3},
\qquad t_{0.975,2}=4.30265.$$

This interval assumes independent repetitions of the stated simulator model and uses a very small sample. The same seed is reset across policies to reduce changes in the initial random setup, but policies consume random numbers differently; this is not a paired test with identical physical events. For bounded quantities such as Jain index or delivery fraction, the symmetric t approximation can extend beyond the physical range. The raw values remain within their bounds.

Heavy RR downlink is 9.1467 ± 0.0574 Mbit/s and heavy BestCQI is 11.7867 ± 0.0574 Mbit/s under this calculation. A narrow interval here measures repeat variation in a short deterministic topology. It does not include uncertainty from propagation, deployment geometry, traffic composition or implementation defaults. Zero sample variation similarly does not imply zero uncertainty about real networks.

!warning[The observed failure cases are operationally different. Heavy BestCQI leaves two users with no downlink delivery during 200 ms. Heavy RR develops a growing application byte deficit despite zero observed MAC retries. The far case produces retransmissions and weaker delivery. The more uplink case improves uplink service by reducing downlink opportunities. These outcomes should not be collapsed into one “packet loss” figure.]

!warning[The sample does not establish Ultra Reliable Low Latency Communication (URLLC) performance or an industrial deadline guarantee. It has no explicit deadline aware policy, no rare event campaign, no tail delay distribution and no calibrated interference environment. Star 20 motivates evaluating those criteria; it does not turn these measurements into their validation.]

Star 21 also defines a boundary. A second cell with an incompatible direction can create cross link interference, but this run contains only one gNB. Changing its TDD pattern measures directional resource allocation. It does not measure neighboring cell coordination, remote interference or interference mitigation. A subsequent experiment would need an explicit aggressor, coupling model and synchronization assumptions before making those claims.

## 7. Reproduce and audit the implementation

**Stage — Reproduce and references.**

Section 6 drew the limits. This section gives the commands and the audit that reproduce the run.

Run from this notebook's root directory:

```sh
/Applications/MATLAB_R2026a.app/bin/matlab -singleCompThread -batch "addpath('matlab/uni09'); run_uni09"
```

The initial validation discovered that no received packets produced zero delay from the toolbox. A failing test reproduced that misleading value; the runner now stores `NaN` for those users, and the subsequent full rerun passed. Other checks verify 144 per UE records, 2880 timeline records, delivered bytes no greater than generated bytes, Jain bounds and the presence of actual retransmissions.

The artifacts support source inspection and independent recalculation.

| Artifact | Contents | Audit use |
| --- | --- | --- |
| run_uni09.m | Thirty six network runs and plots | Configuration and measurement code |
| test_uni09_outputs.m | No delivery semantics and retry checks | Regression against false zero delay |
| run.mat | All configurations, raw statistics and events | Actual simulator evidence |
| per_ue.csv | Per UE outcomes | Fairness, delays and delivered counts |
| timeline.csv | Cumulative measurements every 10 ms | Growth of delivery and deficits |
| application_events.csv | Generated and received application events with peer identity | Recalculate per user delivered bytes |
| summary.csv | Replicate mean and interval half widths | Cell comparisons |
| figures.csv | Thirty four quantitative figures | Plot inventory |
| run.log | Execution and passed assertions | Actual MATLAB run record |
| source_hashes.txt | Source, installed interface and specification hashes | Frozen evidence baseline |

The closing flow links the standardized procedures to the concrete simulator objects, counters and decision criteria.

![[99 Attachments/5G/Uni Labs/Uni-09/Uni-09 - Closing Flow v1.png]]

*Original implementation flow. Connected nodes receive application traffic, contend under a configured TDD pattern and update delivery after MAC and RLC processing. ACK and NACK are alternative HARQ outcomes. Goodput, conditional delay, retransmissions and fairness must be interpreted together.*

## 8. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 8.1 References

The exact protocol baseline is in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]]. [TS 38.300 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) supplies system and scheduling context; [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) owns MAC transfer; [TS 38.322 V18.2.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip) owns RLC transfer. The [MathWorks scheduler overview](https://www.mathworks.com/help/5g/ug/overview-nr-scheduler.html), [nrGNB interface](https://www.mathworks.com/help/5g/ref/nrgnb.html) and [connectUE interface](https://www.mathworks.com/help/5g/ref/nrgnb.connectue.html) explain the implemented simulator. [ShareTechnote's frame structure page](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html) provides secondary orientation to TDD patterns; the clauses cited above control official statements. Sources were checked on 2026-09-07.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.213 V18.8.0, §11.1](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf#page=209); [TS 38.321 V18.10.0, §5.4.2.1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf#page=70). Accessed 2026-09-08.

### 8.2 Abbreviation index

The local two column index links to the shared [[5G Abbreviation Database]].

| Abbreviation | Full term |
| --- | --- |
| [[5G Abbreviation Database\|3GPP]] | Third Generation Partnership Project |
| [[5G Abbreviation Database\|gNB]] | Next generation NodeB |
| [[5G Abbreviation Database\|UE]] | User Equipment |
| [[5G Abbreviation Database\|TDD]] | Time Division Duplex |
| [[5G Abbreviation Database\|DL]] | Downlink |
| [[5G Abbreviation Database\|UL]] | Uplink |
| [[5G Abbreviation Database\|RLC]] | Radio Link Control |
| [[5G Abbreviation Database\|MAC]] | Medium Access Control |
| [[5G Abbreviation Database\|PHY]] | Physical layer |
| [[5G Abbreviation Database\|HARQ]] | Hybrid Automatic Repeat Request |
| [[5G Abbreviation Database\|UM]] | Unacknowledged Mode |
| [[5G Abbreviation Database\|AM]] | Acknowledged Mode |
| [[5G Abbreviation Database\|BSR]] | Buffer Status Report |
| [[5G Abbreviation Database\|CSI-RS]] | Channel State Information Reference Signal |
| [[5G Abbreviation Database\|SRS]] | Sounding Reference Signal |
| [[5G Abbreviation Database\|CQI]] | Channel Quality Indicator |
| [[5G Abbreviation Database\|RR]] | Round Robin |
| [[5G Abbreviation Database\|PF]] | Proportional Fair |
| [[5G Abbreviation Database\|PDCCH]] | Physical Downlink Control Channel |
| [[5G Abbreviation Database\|URLLC]] | Ultra Reliable Low Latency Communication |
| [[5G Abbreviation Database\|ENU]] | East, North, Up |
| [[5G Abbreviation Database\|ACK]] | Acknowledgement |
| [[5G Abbreviation Database\|NACK]] | Negative Acknowledgement |
| [[5G Abbreviation Database\|TTI]] | Transmission Time Interval |
| [[5G Abbreviation Database\|CSV]] | Comma Separated Values |

### 8.3 Mathematical and physical symbol index

The letters used in the calculations above, with their meaning and unit.

| Symbol | Meaning | Unit or bounds |
| --- | --- | --- |
| d | Three dimensional transmitter to receiver distance | m |
| fc, c | Carrier frequency; speed of light | Hz; m/s |
| PL | Free space propagation loss | dB |
| ηDL | Nominal fraction of DL symbols | 0–1 |
| πi | Scheduling priority for user i | Relative score |
| ri, r̄i | Instantaneous and previously served rate | Consistent rate units |
| α, β | PF priority exponents | Both one here |
| B, A, S, D | Queue state, arrivals, service and discards | Bytes |
| Breceived, Bgenerated | Cumulative application payload | Bytes |
| T, Δt | Observation duration; sampling interval | 0.2 s; 0.01 s |
| Gi | Delivered application payload rate | bit/s; plotted Mbit/s |
| Fi | Received bytes divided by generated bytes | 0–1 |
| J | Jain fairness index for four users | 1/4–1 for nonzero delivery |
| x̄, sx | Replicate mean and sample standard deviation | Units of measured metric |
| t0.975,2 | Student t multiplier with two degrees of freedom | 4.30265 |
| NaN | Missing numerical value for undefined delay | No received packets |
