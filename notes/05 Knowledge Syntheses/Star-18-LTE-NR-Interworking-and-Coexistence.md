---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 18
title: LTE–NR Interworking and Coexistence
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-18 — LTE-NR Interworking and Coexistence

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Nobody can switch a country from 4G to 5G overnight. NR arrived in patches, first in city centres and stadiums, while LTE kept covering everywhere else. So the two systems had to share, and the chapter is about two very different kinds of sharing. Think of a new motorway opening beside an old road, with the old road staying open.

![[99 Attachments/5G/Concept Figures/STAR-18-LTE-NR-Interworking-and-Coexistence-Concept.png|LTE and NR interworking explained as a new motorway beside an old road]]

*Concept figure: LTE and NR interworking explained as a new motorway beside an old road.*

The first kind shares the phone. In dual connectivity a phone drives both roads at once. One road is the master: it holds the phone's registration, its route, and every instruction. The other is the secondary and carries cargo. Cargo can travel on the master road, on the secondary road, or be split at a depot, the PDCP layer, and sent along both to be reassembled at the far end. That is why "the master does control and the secondary does data" is a slogan; the bearer type decides where data goes. Sometimes the phone may not transmit on both roads at the same instant, because two transmitters on one handset make distortion in its own receiver.

The second kind shares the lanes. Low-band spectrum is scarce, so LTE and NR are painted onto the same carrier. LTE has road furniture it cannot move: its cell-specific reference signals every few symbols and its synchronisation signals at the centre. NR drives around them using a map, bitmaps that say which resource blocks, symbols, and subframes belong to LTE, and it puts no data there. That is rate matching around LTE, and it is possible because both systems step to the same 15 kHz beat.

The vocabulary matters. Non-standalone is a family of deployments in which NR relies on an existing LTE anchor. EN-DC is one architecture in that family, with an LTE base station as master. Standalone is NR with its own core and no LTE anchor, and it is not a dual-connectivity architecture at all.

**The question this chapter answers.** When operators introduce NR into an LTE network, which node anchors control, where can user data travel, and how can LTE and NR share radio resources without destroying each other's reference signals?

!important[**The short answer.** Several distinct mechanisms answer different parts. NSA is a deployment family in which NR service can rely on an existing LTE/EPC anchor; EN-DC is a specific MR-DC architecture with an LTE eNB as master node and an en-gNB as secondary node. SA uses an NR gNB and 5G Core without LTE anchoring. In MR-DC the master node anchors the UE's RRC connection, but user data can use an MCG bearer, SCG bearer, or split bearer.]

Names you will meet in this note: multi-radio dual connectivity (MR-DC), E-UTRA–NR dual connectivity (EN-DC), non-standalone and standalone (NSA, SA), master and secondary cell group (MCG, SCG), evolved packet core (EPC), 5G core (5GC), cell-specific reference signal (CRS), dynamic spectrum sharing (DSS), intermodulation distortion (IMD).

## 2. Where you are in 5G

Section 1 described two kinds of sharing between LTE and NR. The map below shows where both sit in 5G: LTE beside NR under one access network, and both radios sharing one band.

![[99 Attachments/5G/Locator Maps/STAR-18-Where-You-Are-in-5G.png|Where Star 18 sits in the whole 5G system]]

*Locator: Where Star 18 sits in the whole 5G system.*

This chapter lights the architecture band where NR meets LTE, and the deployment options of Star 05 and Star 06 that assumed a core and a master. It leans on the reserved-resource mechanism of Star 09, which is what rate matching around LTE uses, and on the scheduler of Star 14, which must honour the reserved map. Star 04 supplies the LTE signals that cannot be moved.

The Knowledge Structure Map draws dual connectivity and spectrum coexistence side by side. The mechanism diagram traces the interworking paths a bearer can take.

![[99 Attachments/5G/Knowledge Maps/STAR-18-LTE-NR-Interworking-and-Coexistence-Knowledge Structure Map.png|STAR-18 system-position map]]

*Knowledge map: The LTE and NR deployment options as four small schematics.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-18-LTE-NR-Interworking-Paths.png|Star 18 mechanism and handoff diagram]]

*Mechanism: The three dual-connectivity bearer types and where the path forks.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 18.1 Overview → 18.1 LTE/NR Dual Connectivity → 18.2 LTE/NR Coexistence.


## 3. The textbook road

Section 2 placed the two radios side by side. The road below walks through the chapter in the book's order: the overview, dual connectivity, then coexistence in one band.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **18.1 Overview**

The road begins with why the two systems must share at all, and the two forms that sharing takes.

!important[Coexistence of LTE and NR is a transitional necessity. Operators introduce NR gradually, first in dense or high-traffic areas, while LTE remains the coverage backbone. Interworking has to provide seamless mobility, dual connectivity in which a phone keeps links to both systems at once, and spectrum sharing that lets both use the same bands. The chapter goes beyond handover to cover the last two.]

> [!book] Book expansion
> Chapter 18 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 371–379, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00018-0)) is short because most of the machinery, dual connectivity and reserved resources, already exists elsewhere in the book; what is new is how it is combined.

> [!spec] 3GPP reality check
> The whole multi-radio dual-connectivity architecture is one document, [TS 37.340 V18.7.0](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip); the overview and the option names are its clause 4.1.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [LTE interworking page](https://www.sharetechnote.com/html/5G/5G_LTE_Interworking.html) lays out the option numbers, 3, 3a, 3x, 4, 7, that vendors and operators actually use in conversation, alongside the 3GPP names.

### 3.2 **18.1 LTE/NR Dual Connectivity**

Section 3.1 named the first form. This section builds it: one phone connected to an LTE node and an NR node at the same time, and the options for which core sits behind them.

#### 3.2.1 **18.1.1 Principle**

A phone connects at once to one master node, an LTE or NR base station that handles control-plane signalling, and to one or more secondary nodes that add user-plane capacity. Control travels over the master's RRC connection; user data can be split dynamically across both for throughput. RRC and MAC coordinate and manage bearers; the physical layer runs two uplinks and two downlinks.

#### 3.2.2 **18.1.2 Deployment Scenarios**

In the multi-layer deployment of Figure 18.2 an LTE macro layer is the master and an NR small-cell layer the secondary, giving robustness and continuity for high-frequency NR.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*In the multi-layer deployment of Figure 18.2 an LTE macro layer is the master and an NR small-cell layer the secondary, giving robustness and continuity for high-frequency NR.*

In the co-sited deployment of Figures 18.3 and 18.4 both systems share a site or even hardware, and throughput aggregation is the gain when both run in parallel, whether NR is in a low band or at millimetre waves.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*In the co-sited deployment of Figures 18.3 and 18.4 both systems share a site or even hardware, and throughput aggregation is the gain when both run in parallel, whether NR is in a low band or at millimetre waves.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*In the co-sited deployment of Figures 18.3 and 18.4 both systems share a site or even hardware, and throughput aggregation is the gain when both run in parallel, whether NR is in a low band or at millimetre waves.*

#### 3.2.3 **18.1.3 Architecture Options**

Because LTE and NR can run under either core, the EPC or the 5G core, several options exist. Non-standalone has LTE provide the control plane while NR adds data capacity; standalone has NR connect to the 5G core on its own; EN-DC is the common transitional mode with LTE as master and NR as secondary. Inter-node signalling carries bearer mapping, the PDCP split, and scheduling coordination between the two base stations, so that migration from the EPC to the 5G core can be gradual.

#### 3.2.4 **18.1.4 Single-TX Operation**

!note[When LTE and NR uplink carriers transmit at the same time, intermodulation products can fall into the phone's own receive band. For such difficult band combinations the phone runs single-transmitter operation, alternating its uplink between the two carriers in time, as Figure 18.5 shows.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*For such difficult band combinations the phone runs single-transmitter operation, alternating its uplink between the two carriers in time, as Figure 18.5 shows.*

The two base stations coordinate so that no uplinks coincide; reference configurations keep HARQ timing and feedback consistent. MAC schedules the alternation and the physical layer keeps both timings. The result protects the receiver without an expensive radio front end.

> [!spec] 3GPP reality check
> Bearer types are [TS 37.340 V18.7.0, clause 4.2.2](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip), and adding a secondary node is clause 10.2; the band combinations that require single-transmitter uplink are listed in TS 38.101-3.

> [!engineering] ShareTechnote engineering view
> The [EN-DC page](https://www.sharetechnote.com/html/5G/5G_LTE_Interworking.html) shows a real secondary-node addition message sequence, which is the first thing a demo engineer looks at when a phone stays on LTE only.

### 3.3 **18.2 LTE/NR Coexistence**

Dual connectivity shares a phone; this section shares a band. It explains what lets LTE and NR live on one carrier and where the scheduler must tread carefully.

#### 3.3.1 **18.2.1 Concept**

Coexistence keeps LTE phones served during the NR rollout and uses scarce low-band spectrum well. There are two approaches. Static sharing divides the band between the two systems, as Figure 18.6 shows.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Static sharing divides the band between the two systems, as Figure 18.6 shows.*

Dynamic coexistence shares the band adaptively through scheduler coordination, as Figure 18.7 shows.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Dynamic coexistence shares the band adaptively through scheduler coordination, as Figure 18.7 shows.*

Static sharing takes bandwidth from LTE users and caps the peak rate of both. Dynamic spectrum sharing adjusts the split in real time as traffic shifts.

#### 3.3.2 **18.2.2 Enablers of Coexistence**

!important[Three NR features make it work. The 15 kHz numerology puts both systems on one time–frequency grid. Forward compatibility gave NR reserved resources, Star 09's mechanism, that can be declared off limits. And rate matching lets NR data skip the LTE regions, the cell-specific reference signals, synchronisation signals, and broadcast channel. What is conveyed is a set of bitmaps describing the avoided regions.]

#### 3.3.3 **18.2.3 Coexistence Scenarios**

| Scenario | Description |
| --- | --- |
| Downlink and uplink coexistence | LTE and NR share the full spectrum; scheduling must be coordinated in both directions |
| Uplink-only coexistence | NR supplements LTE with uplink carriers, as in supplementary uplink; easier to manage |

The two schedulers coordinate to avoid overlapping uplink data, to respect LTE's control channel and layer-1 signalling, and to leave symbols for LTE signals that cannot be scheduled away. MAC handles the coordination and the physical layer keeps symbol alignment.

#### 3.3.4 **18.2.4 Downlink-Specific Considerations**

The LTE downlink carries always-on signals that cannot be scheduled: the synchronisation signals, the broadcast channel, and the cell-specific reference signals. They would overlap NR data, so NR defines reserved-resource bitmaps to rate-match around them. Figure 18.9 shows the configuration.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 18.9 shows the configuration.*

| Bitmap | Function |
| --- | --- |
| Bitmap 1, frequency domain | the resource blocks holding LTE PSS/SSS |
| Bitmap 2, time domain | the OFDM symbols holding LTE PSS/SSS |
| Bitmap 3, subframe domain | the subframes in which they occur |

For the broadcast channel bitmap 2 covers four symbols and bitmap 3 one subframe. For the reference signals a dedicated configuration gives the LTE bandwidth, the number of ports, and the frequency shift, from which the NR scheduler derives the pattern. Rate-matching its data around these is what lets NR share a carrier with LTE at all.

> [!spec] 3GPP reality check
> The reference-signal pattern is the RateMatchPatternLTE-CRS information element and the generic bitmaps are RateMatchPattern, both in [TS 38.331 V18.10.0, clause 6.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip); the LTE signals they describe are TS 36.211 clause 6.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [DSS page](https://www.sharetechnote.com/html/5G/5G_DSS.html) draws the LTE reference-signal positions on an NR grid, which makes the rate-matching pattern visible.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: dual connectivity in one, rate matching around LTE in the RRC information elements of another.

Dual connectivity lives in one document, TS 37.340, which names the four options, the three bearer types, and the procedure for adding a secondary node. Rate matching around LTE lives in the RRC information elements of TS 38.331, which describe the LTE reference-signal pattern in a few fields and any other region as bitmaps. The RF constraint on simultaneous uplinks is TS 38.101-3. The figure draws the four options, the split bearer, where the LTE reference signals sit, the size of the bitmaps, and the configuration lines each becomes.

![[99 Attachments/5G/Protocol Figures/STAR-18-LTE-NR-Interworking-and-Coexistence-Protocol.png|The MR-DC options and bearer types, the LTE rate-matching pattern, and the configuration lines each becomes]]

*Protocol figure: The MR-DC options and bearer types, the LTE rate-matching pattern, and the configuration lines each becomes.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 37.340 | V18.7.0, [37340-i70.zip](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) | 4.2; 4.2.2; 10 | MR-DC architecture, bearer types, and procedures |
| TS 38.300 | V18.10.0, [38300-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | 4.1–4.2 | NR architecture and interworking overview |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 5.3; 6.3.2 | RRC procedures and rate-matching/configuration IEs |
| TS 36.300 | V18.8.0, [36300-i80.zip](https://www.3gpp.org/ftp/Specs/archive/36_series/36.300/36300-i80.zip) | 4.9 | E-UTRA dual-connectivity architecture context |
| TS 36.211 | V18.0.2, [36211-i02.zip](https://www.3gpp.org/ftp/Specs/archive/36_series/36.211/36211-i02.zip) | 6 | LTE physical signals/channels relevant to coexistence |

!note[**When you build or run a demo.** An EN-DC demo needs an LTE base station, an NR base station, and the X2 link between them, and the first thing to check when a phone never reaches NR is whether the secondary-node addition was sent and acknowledged. Each bearer's type and, for a split bearer, its primary path and split threshold are lines in the PDCP configuration that decide where the bytes actually go. On a shared carrier, the LTE reference-signal pattern is four values, the LTE carrier frequency, its bandwidth, its port count, and its shift, and a wrong shift silently corrupts LTE phones while NR looks healthy. Open-source stacks support standalone first; dual connectivity is where most demo effort goes.]

Release 15 defined EN-DC with LTE anchoring and rate matching around the LTE reference signals. Release 16 added the remaining MR-DC options, dynamic spectrum sharing refinements, and mobility improvements. Release 18 keeps the option and bearer clauses; NSA should not be equated with EN-DC, nor SA with the absence of dual connectivity. Release summaries are checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the bearers; this trace splits one data unit across an LTE leg and an NR leg and computes when each half arrives.

Assume a 12 Mbit PDCP data unit group is split into 4 Mbit over an LTE leg providing 40 Mbit/s and 8 Mbit over an NR leg providing 160 Mbit/s. Ignore protocol overhead and assume parallel start. Add an assumed 8 ms differential reordering wait after both radio portions are available.

**What we are working out.** LTE-leg time, NR-leg time, and ordered-delivery completion time.

$$
\begin{aligned}
t_{LTE}
&=\frac{4\ \mathrm{Mbit}}{40\ \mathrm{Mbit/s}}
=0.10\ \mathrm{s}=100\ \mathrm{ms},\\
t_{NR}
&=\frac{8\ \mathrm{Mbit}}{160\ \mathrm{Mbit/s}}
=0.05\ \mathrm{s}=50\ \mathrm{ms},\\
t_{deliver}
&=\max(t_{LTE},t_{NR})+t_{reorder}\\
&=\max(100,50)\ \mathrm{ms}+8\ \mathrm{ms}\\
&=108\ \mathrm{ms}.
\end{aligned}
$$

In this formula, the data volumes and rates are teaching assumptions. $t_{LTE}$ and $t_{NR}$ are ideal transfer durations, $t_{reorder}$ is an assumed receiver wait, and $t_{deliver}$ is the ordered-delivery completion time. The `max` appears because ordered delivery needs both portions. Official evidence defines bearer/PDCP behavior; rate allocation and flow control belong to implementation. The example ignores headers, HARQ/RLC retransmission, scheduler gaps, and backhaul delay.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $B_{LTE}$ | 4 | Mbit | assumed split volume |
| $B_{NR}$ | 8 | Mbit | assumed split volume |
| $R_{LTE}$ | 40 | Mbit/s | assumed delivered rate |
| $R_{NR}$ | 160 | Mbit/s | assumed delivered rate |
| $t_{reorder}$ | 8 | ms | assumed PDCP wait |
| $t_{deliver}$ | 108 | ms | derived completion time |

The faster NR leg becomes idle while the slower LTE portion determines completion. A smarter splitter might send less on LTE, but its prediction could be wrong after fading or scheduling changes. The example shows why split-bearer flow control and reordering state are real engineering problems rather than automatic addition of advertised peak rates.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star extends U03, U04, and U05. Students reuse time-frequency resource mapping, control channels, bearer layering, and scheduling, then apply them across two RATs. The topic is suitable for a capstone because correct answers require both PHY coexistence and higher-layer architecture.

A useful comparison table asks whether “NSA,” “EN-DC,” “split bearer,” and “DSS” answer a deployment, protocol-architecture, packet-path, or spectrum question. Each belongs to a different column.

!warning[**“NSA and EN-DC are synonyms”.**

EN-DC is a specific MR-DC architecture; NSA is a deployment family. Many commercial NSA deployments use EN-DC, but the terms answer different questions.]

!warning[**“The secondary node carries the user plane”.**

User data can use MCG, SCG, or split bearers. The master anchors RRC but can also carry user traffic. Inspect bearer configuration before assigning a packet path.]

!warning[**“SA means no dual connectivity”.**

SA means NR access with 5GC without LTE anchoring. NR-DC or other multi-connectivity can still exist. SA is not itself a DC architecture type.]

!warning[**“DSS overlays NR freely on LTE resources”.**

LTE legacy signals and control obligations constrain resources. NR uses configured reservation/rate matching and coordinated scheduling; overhead and traffic mix affect efficiency.]

!warning[**“LTE always has uplink transmit priority”.**

Single-TX and power-priority behavior is band-combination-, capability-, and procedure-dependent. Apply the current clause.]

### 6.1 Supplement: a VoNR call

The confusions above stayed with data. The supplements that follow are the course's illustrated flows; a voice call on NR comes first.

!warning[Voice over NR keeps the call on 5G; the core's contribution is one extra QoS flow. The comic's seven steps, redrawn as a sequence.]

![[99 Attachments/5G/Supplement Figures/STAR-18-Saar-VoNR-Call.png|A VoNR call in seven steps]]

*Supplement figure: Sequence diagram of a VoNR call across the caller, gNB, 5G core, PCF, IMS and a callee on 4G in seven steps.*
*Figure 6.1 — INVITE, policy, a dedicated 5QI 1 flow, IMS handling, routing to the callee, the call, and BYE.*

| Phase | Where | What happens |
|---|---|---|
| before any call | 5GC + IMS | 5G registration, IMS PDU session with its default flow, SIP REGISTER |
| INVITE | UE → CSCF | the call request rides the default flow |
| voice lane | PCF → SMF → gNB | PDU Session Modification adds a QoS flow with 5QI 1 |
| call | IMS ↔ callee's network | domain selection, ringing, answer, RTP |
| BYE | CSCF → PCF → SMF | the 5QI 1 flow is removed; the default flow stays |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 04; 3GPP TS 23.502, TS 23.228.

### 6.2 Supplement: connected-mode handover to 4G over N26

Section 6.1 kept the call on 5G. This supplement moves a connected phone to 4G over N26 while the downlink is still in flight.

!warning[Section 3 treated interworking as architecture. This is the procedure: the video keeps playing because the EPC builds its side first and an indirect tunnel catches the downlink in flight.]

![[99 Attachments/5G/Supplement Figures/STAR-18-Saar-5G-to-4G-Handover.png|Connected-mode 5G to 4G handover over N26]]

*Supplement figure: Sequence diagram of a 5G to 4G handover with N26 across UE, gNB, AMF, combined SMF and PGW-C, combined UPF and PGW-U, MME, S-GW and eNB.*
*Figure 6.2 — Handover Required, N26 relocation, EPC preparation, indirect forwarding, the switch, and Tracking Area Update.*

| Phase | Messages | Result |
|---|---|---|
| 1 decide | Handover Required; SM context for EPS | QoS flows already mapped to EPS bearers and EBIs |
| 2 prepare EPC | N26 Forward Relocation Request; Create Session; Handover Request/Ack | uplink road ready on the 4G side |
| 3 tunnel | Create Indirect Data Forwarding Tunnel; Forward Relocation Response | 5GC downlink detours via S-GW to the eNB |
| 4 switch | Handover Command; Handover Confirm | UE on 4G, uplink via S-GW and PGW-U |
| 5 finish | Handover Notify; Forward Relocation Complete; Modify Bearer; TAU | downlink switched, timers release the tunnel |

- Handover needs N26 and support at gNB and UE; without it the fallback is redirection, a release and a fresh connection on 4G.

Source: Supplementary material, *Illustrated 5G signalling flows*, part 07; 3GPP TS 23.502 clause 4.11.

### 6.3 Supplement: EPS fallback for voice

Section 6.2 moved the whole connection. This supplement moves only the voice bearer, the fallback that happens when the gNB cannot carry it.

!warning[Same INVITE, same IMS, different ending: when the gNB cannot carry a voice flow it asks for a handover, and the voice bearer is built on 4G.]

![[99 Attachments/5G/Supplement Figures/STAR-18-Saar-EPS-Fallback.png|EPS fallback for voice in seven steps]]

*Supplement figure: Sequence diagram of EPS fallback for voice across UE, gNB, AMF, IMS, EPC and eNB in seven steps.*
*Figure 6.3 — The gNB refuses the 5QI 1 flow, requests a handover, and the EPC builds the QCI 1 bearer the IMS asked for.*

| | VoNR | EPS fallback |
|---|---|---|
| Registration and IMS | on 5G | on 5G |
| Trigger | INVITE | INVITE, then the gNB refuses the voice flow |
| Voice bearer | QoS flow 5QI 1 on NR | EPS bearer QCI 1 after an N26 handover |
| Emergency calls | same flow with emergency flags | AMF orders the fallback itself |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 08; 3GPP TS 23.501 clause 5.16.3.

### 6.4 Supplement: the deployment options in one frame

The three supplements above each assumed one deployment option. This one puts the training deck's ten options into a single frame.

!warning[The training deck's ten option diagrams collapse to one question: which core, and which radio anchors the control plane.]

![[99 Attachments/5G/Supplement Figures/STAR-18-Saar-Deployment-Options.png|The four deployment-option families]]

*Supplement figure: Four panels for deployment options 2, 4 and 4a, 3 and 3a and 3x, and 7 and 7a and 7x, each with the core, the radio nodes and a UE joined by solid control-plane and dashed user-plane links, with two notes beneath.*
*Figure 6.4 — Options 2, 4/4a, 3/3a/3x and 7/7a/7x; solid links anchor control, dashed links carry user plane only.*

| Family | Core | Anchor | Typical use |
|---|---|---|---|
| Option 2 | 5GC | NR | standalone once NR coverage is continuous |
| Option 3 / 3a / 3x | EPC | LTE | the 2019–2021 launch configuration |
| Option 4 / 4a | 5GC | NR, with eLTE secondary | reuse LTE spectrum under an NR anchor |
| Option 7 / 7a / 7x | 5GC | eLTE | 5GC services with LTE still carrying control |

Source: Supplementary material, *5G key technologies and applications* (training deck, 2018), slides 33–35; 3GPP TR 38.801, TS 37.340.

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-18-LTE-NR-Interworking-and-Coexistence|Chapter 18]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00018-0)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/36_series/36.300/36300-i80.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/36_series/36.211/36211-i02.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
12. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_LTE_Interworking.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_DSS.html)
15. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_SplitBearer.html)
16. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| 5GC | 5G Core | core network used by standalone NR. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| CRS | Cell-specific reference signal | LTE signal constraining shared resources. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| DC | Dual connectivity | simultaneous master/secondary connectivity framework. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| DSS | Dynamic spectrum sharing | coordinated LTE/NR use of a carrier. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| EN-DC | E-UTRA–NR dual connectivity | LTE master with NR secondary and EPC context. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| EPC | Evolved Packet Core | LTE core used in common NSA deployments. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| E-UTRA | Evolved Universal Terrestrial Radio Access | LTE radio access. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| MCG | Master cell group | resources controlled through the master node. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| MR-DC | Multi-Radio dual connectivity | family of dual-RAT/dual-node architectures. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| NSA | Non-standalone | deployment using existing core/control dependency. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| PDCP | Packet Data Convergence Protocol | split/reordering/duplication bearer layer. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| RAT | Radio access technology | LTE or NR technology family. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| RRC | Radio Resource Control | connection-control protocol anchored by master node. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| SA | Standalone | NR deployment with 5GC and no LTE anchor requirement. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| SCG | Secondary cell group | resources controlled through the secondary node. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |
| UE | User equipment | terminal using one or both radio legs. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.340/37340-i70.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $B_{LTE}$ | data assigned to LTE leg | bit |
| $B_{NR}$ | data assigned to NR leg | bit |
| $R_{LTE}$ | delivered LTE-leg rate | bit/s |
| $R_{NR}$ | delivered NR-leg rate | bit/s |
| $t_{LTE}$ | LTE-leg transfer time | s |
| $t_{NR}$ | NR-leg transfer time | s |
| $t_{reorder}$ | assumed PDCP reordering wait | s |
| $t_{deliver}$ | ordered completion time | s |
| $\rho$ | conceptual fraction assigned to NR | dimensionless, 0–1 |
| VoNR | Voice over New Radio | VoNR is IMS voice carried on an NR QoS flow. It keeps the whole call on 5G. | Section 6; Supplement |
| VoLTE | Voice over LTE | VoLTE is IMS voice carried on an EPS bearer with QCI 1. EPS fallback ends in a VoLTE call. | Section 6; Supplement |
| IMS | IP Multimedia Subsystem | The IMS is the operator service layer for voice, video and messaging over IP. A dedicated PDU session connects the UE to it. | Section 6; Supplement |
| CSCF | Call Session Control Function | The CSCF is the SIP front desk of the IMS. It routes INVITE and BYE and asks the PCF for voice QoS. | Section 6; Supplement |
| SIP | Session Initiation Protocol | SIP is the signalling protocol of the IMS. INVITE starts a call and BYE ends it. | Section 6; Supplement |
| MME | Mobility Management Entity | The MME is the EPC control-plane node for attach, mobility and bearers. It is the AMF's counterpart over N26 during interworking. | Section 6; Supplement |
| S-GW | Serving Gateway | The S-GW is the EPC user-plane anchor for the radio side. It forwards bearers between the eNB and the P-GW and hosts indirect forwarding tunnels during handover. | Section 6; Supplement |
| P-GW | Packet Data Network Gateway | The P-GW connects EPC bearers to external data networks. Its control and user parts are combined with the SMF and UPF for 5G interworking. | Section 6; Supplement |
| PCRF | Policy and Charging Rules Function | The PCRF is the EPC policy node. It is the PCF's counterpart and triggers dedicated bearers for IMS voice. | Section 6; Supplement |
| N26 | N26 interface | N26 links the AMF and the MME for EPS interworking. Without it mobility between 5GC and EPC is a redirection instead of a handover. | Section 6; Supplement |
| EBI | EPS Bearer Identity | The EBI identifies an EPS bearer prepared for a QoS flow. The AMF assigns it at session creation so a later handover to 4G can proceed. | Section 6; Supplement |
| TAU | Tracking Area Update | TAU is the EPS procedure that refreshes a UE's location with the MME. It closes a 5G-to-4G handover and, after redirection, recreates the sessions. | Section 6; Supplement |
| EPS | Evolved Packet System | EPS is the 4G system of E-UTRAN and the EPC. EPS fallback moves voice from NR to it when the gNB cannot carry a voice flow. | Section 6; Supplement |
| QCI | QoS Class Identifier | The QCI names the QoS class of an EPS bearer. QCI 1 is conversational voice. | Section 6; Supplement |
| 5QI | 5G QoS Identifier | The 5QI names the QoS characteristics of a QoS flow. 5QI 1 is conversational voice. | Section 6; Supplement |
| HSS | Home Subscriber Server | The HSS stores subscriber data in the EPC and the IMS. It is the LTE counterpart of the 5G UDM. | Section 6; Supplement |
