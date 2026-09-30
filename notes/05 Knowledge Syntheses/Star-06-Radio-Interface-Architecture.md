---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 6
title: Radio-Interface Architecture
language: en
course_units: []
release_baseline: 18
---

# STAR-06 — Radio-Interface Architecture

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

A packet leaving your phone goes through an airport. At check-in it is told which flight it is on — which radio bearer carries its kind of traffic. At security it is sealed and numbered, so that nothing can read it, alter it, or slip a duplicate into the queue. At baggage handling, a suitcase too big for the hold is split into containers that fit, with labels so they can be reassembled on arrival. At the gate, someone decides which passengers board which aircraft and when, and re-boards anyone who missed it. And then there is the runway: the aircraft itself, and the physics of getting it into the air. Each stage does one job and refuses the others.

![[99 Attachments/5G/Concept Figures/STAR-06-Radio-Interface-Architecture-Concept.png|The NR protocol stack explained as an airport]]

*Concept figure: The NR protocol stack explained as an airport.*

The stages have names — SDAP, PDCP, RLC, MAC, PHY — and above them sits a control tower, RRC, that never touches a bag but decides how every desk below should behave. The reason for separating the jobs is not tidiness. Each job changes at a different rate. Security rules change rarely; boarding order changes every millisecond. A single desk that did both would have to be rebuilt whenever either changed, and the network could never be upgraded one part at a time. Layers are what let a base station vendor improve its scheduler without a single phone noticing.

This is also the chapter that turns the rest of the book into a map. Every later chapter lives at one desk: scheduling and retransmission are the gate, coding and antennas are the runway, connection setup and mobility are the tower. And it is how an engineer reads a log — every line names the layer that wrote it. The chapter walks the stack from the core network down to the physical layer, then covers the control plane, the states a device can be in, and how it moves between cells.

**The question this chapter answers.** How does one application packet become a scheduled radio transmission, and which protocol layer owns each transformation?

!important[**The short answer.** The 5G system classifies traffic into QoS flows; SDAP maps them to radio bearers; PDCP handles packet-level security and ordering; RLC segments and optionally retransmits; MAC multiplexes, schedules, and runs HARQ; PHY codes and maps the transmission. RRC configures the radio relationship. Each layer consumes a service data unit from above and produces a protocol data unit for its peer.]

Names you will meet in this note: Fifth Generation Core (5GC), Next Generation Radio Access Network (NG-RAN), Access and Mobility Management Function (AMF), User Plane Function (UPF), QoS Flow Identifier (QFI), Service Data Adaptation Protocol (SDAP), Packet Data Convergence Protocol (PDCP), Radio Link Control (RLC), Medium Access Control (MAC), Physical Layer (PHY), Radio Resource Control (RRC), Non-Access Stratum (NAS), Signalling Radio Bearer (SRB), Data Radio Bearer (DRB), Hybrid ARQ (HARQ), Central Unit (CU), Distributed Unit (DU).

## 2. Where you are in 5G

Section 1 sent a packet through an airport. The map below shows the same journey as boxes: the core behind the base station, the protocol layers inside it, and the phone at the end.

![[99 Attachments/5G/Locator Maps/STAR-06-Where-You-Are-in-5G.png|Where Star 06 sits in the whole 5G system]]

*Locator: Where Star 6 sits in the whole 5G system.*

This chapter lights the whole protocol stack in the left band, the radio link in the top band, and the access network beside it. It is the structural chapter: every procedure in the middle band is performed by one of the layers named here, and every physical foundation at the bottom is what the lowest layer does. Stars 33 to 36 return to the four upper layers one specification at a time.

The Knowledge Structure Map presents the five user-plane layers with the single question each one answers and the specification that owns it. The mechanism diagram follows one IP packet down the stack, showing the header each layer prepends and why RLC's output is the only one that gets shorter.

![[99 Attachments/5G/Knowledge Maps/STAR-06-Radio-Interface-Architecture-Knowledge Structure Map.png|STAR-06 system-position map]]

*Knowledge map: The NR user-plane stack and the question each layer answers.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-06-Radio-Interface-Protocol-Chain.png|Star 06 mechanism and handoff diagram]]

*Mechanism: One IP packet travelling down the NR protocol stack.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 6.1 Overall System Architecture → 6.1.2 Radio-Access Network (RAN) → 6.2 Quality-of-Service (QoS) Handling → 6.3 Radio Protocol Architecture → 6.4 User-Plane Protocols.


## 3. The textbook road

Section 2 placed the layers on the map. The road below walks through the architecture chapter in the book's order: the core and the access network first, then the user plane layer by layer, then the control plane and mobility.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 6.1 Overall System Architecture

The road starts one step behind the radio, with the network the base station is connected to and why its boundary with the access network is cleaner than LTE's.

Before the radio, the network behind it. The 5G system has a core and an access network, and the boundary between them is cleaner than LTE's was, because the core was redesigned at the same time as the radio.

#### 3.1.1 5G Core Network (5GC)

The 5G core grew out of LTE's Evolved Packet Core and changed three things. It is service-based: core functions are software services that call each other. It supports network slicing: several logical networks — one tuned for broadband, one for low latency, one for sensors — can share one physical infrastructure. And it splits control from user plane: the AMF and SMF handle signalling and sessions, while the UPF forwards the user's packets, so the two can be scaled and placed independently. Figure 6.1 shows the service-based architecture; Figure 6.2 shows the connection options, from non-standalone option 3 on the LTE core to standalone option 2 on the 5G core.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.1 shows the service-based architecture; Figure 6.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.1 shows the service-based architecture; Figure 6.*

> [!book] Book expansion
> Chapter 6 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 79–113, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00006-4)) treats the core only as far as the radio needs it; the full architecture is TS 23.501, which Star 01 cites.

> [!spec] 3GPP reality check
> The radio-side view of the architecture is [TS 38.300 V18.10.0, clause 4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip); the core itself is TS 23.501 clause 4, and the two documents draw the same NG interface from opposite sides.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [radio protocol stack page](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html) draws the whole stack on one screen with the interfaces named, which is the picture to keep beside this chapter.

### 3.2 6.1.2 Radio-Access Network (RAN)

Section 3.1 described the core. This section crosses the boundary into the access network and asks which nodes stand there and how one network serves two radios.

Two kinds of node connect to the 5G core: the gNB, which serves NR devices, and the ng-eNB, which serves LTE devices through the 5G core. Together they form NG-RAN, and the fact that one access network serves both radios is what made migration from LTE possible.

#### 3.2.1 gNB as a logical node

A gNB is a logical node. The textbook's phrase is exact: a base station is a possible implementation of a gNB, but not identical to it.

| Concept | Explanation |
| --- | --- |
| **gNB (logical)** | Network-level entity providing radio resource management, admission control, and protocol termination (PDCP/RLC/MAC/PHY). |
| **Base Station (physical)** | Hardware platform implementing part or all of a gNB. |
| **Example** | One gNB (Central Unit + DUs) → three-sector site serving three cells. **Alternatively, one gNB CU controls many remote radio heads along a highway. Each radio head is a “base station,” but together they form one logical gNB.** |

The gNB has four interfaces, and their names recur throughout the course. NG connects it to the core, with a control part to the AMF and a user part to the UPF. Xn connects gNBs to each other, for handover and dual connectivity. F1 connects a central unit to its distributed units when the gNB is split. And Uu is the air interface to the device. Figure 6.3 shows them; Figure 6.4 shows LTE–NR dual connectivity, option 3, in which an LTE base station and a gNB serve one device together.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.3 shows them; Figure 6.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.3 shows them; Figure 6.*

> [!spec] 3GPP reality check
> The gNB, its split into CU and DU, and the F1 interface are [TS 38.401 V18.7.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.401/38401-i70.zip); Star 37 is devoted to it.

### 3.3 6.2 Quality-of-Service (QoS) Handling

Nodes exist to carry traffic with a promised quality. This section shows that quality of service is decided twice, once in the core and once in the base station.

!important[Quality of service is decided twice. In the core, the UPF classifies each IP packet into a QoS flow and marks it with a flow identifier. In the base station, SDAP maps each flow onto a radio bearer, which is the unit the radio protocols actually handle. The mapping can be explicit, signalled by RRC, or reflective, in which the device copies whatever mapping it observed on the downlink. Figure 6.5 shows the two levels.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.5 shows the two levels.*

> [!spec] 3GPP reality check
> QoS flows and 5QI values are defined in TS 23.501 clause 5.7; the flow-to-bearer mapping is [TS 37.324 V18.x, clause 5.2](https://www.3gpp.org/ftp/Specs/archive/37_series/37.324/) and its summary in TS 38.300 clause 12.

### 3.4 6.3 Radio Protocol Architecture

The two decisions of Section 3.3 travel through a stack of protocols. This section names the stack and separates the plane that carries data from the plane that sets it up.

The radio protocols are divided into a user plane, which carries the user's data, and a control plane, which carries the signalling that sets the user plane up. The two planes share the lower layers — PDCP, RLC, MAC, and PHY — and differ at the top: SDAP on the user plane, RRC and NAS on the control plane. Figure 6.6 draws both.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.6 draws both.*

### 3.5 6.4 User-Plane Protocols

Section 3.4 named two planes. This section follows the user plane first, layer by layer, from an IP packet down to the air.

Figure 6.7 shows the downlink stack; Figure 6.8 follows one flow of data through it, IP to SDAP to PDCP to RLC to MAC to PHY.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.7 shows the downlink stack; Figure 6.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.7 shows the downlink stack; Figure 6.*

| Layer | Function |
| --- | --- |
| **SDAP** | Maps QoS flows ↔ radio bearers (introduced in 5G). |
| **PDCP** | Header compression (ROHC), ciphering, integrity, duplication, and (in case of handover) duplicate removal and reordering. |
| **RLC** | Segmentation and retransmission of PDUs (transparent, unacknowledged, acknowledged modes). |
| **MAC** | Multiplexing, Hybrid-ARQ, scheduling. |
| **PHY** | Coding, modulation, multi-antenna processing. |

Each layer adds exactly one transformation on the way down, and the receiver undoes them in reverse order on the way up. The sections that follow take the layers one at a time.

### 3.6 6.4.1 Service Data Adaptation Protocol (SDAP)

The first layer a packet meets is the thinnest. This section explains why SDAP exists at all and what its one job is.

SDAP is the newest and thinnest layer. It exists only when NR connects to the 5G core, because only the 5G core has QoS flows to map; a non-standalone deployment on the LTE core has no SDAP at all. Its job is the mapping of Section 3.3 and the marking of packets with their flow identifier.

### 3.7 6.4.2 Packet Data Convergence Protocol (PDCP)

SDAP chose the bearer; the next layer seals the packet. This section explains PDCP: security, ordering and the layer that survives a handover.

PDCP is the security layer and the ordering layer. It compresses IP headers, ciphers the payload, protects integrity for signalling, removes duplicates, and can deliver in sequence when asked to. It is the layer that survives a handover — its sequence numbers continue while the layers below are torn down and rebuilt — which is why it also anchors dual connectivity. Figure 6.9 shows the arrangement.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.9 shows the arrangement.*

In dual connectivity a device is connected to a master cell group and a secondary cell group, and the two groups may belong to different gNBs — a low-band gNB for coverage as the master, a millimetre-wave gNB for throughput as the secondary. PDCP is the layer that splits or duplicates packets between the two paths.

| Bearer type | Description |
| --- | --- |
| **Normal bearer** | All traffic via MCG or SCG only. |
| **Split bearer** | PDCP distributes packets across both gNBs for throughput or diversity. |

### 3.8 6.4.3 Radio-Link Control (RLC)

A sealed packet rarely fits the space MAC has been granted. This section explains how RLC cuts it to size and, in one of its modes, repairs the losses.

RLC takes PDCP's packets, segments them to fit whatever MAC has been granted, numbers the pieces, and — in acknowledged mode — retransmits any that are lost. It runs in three modes: transparent, which adds nothing; unacknowledged, which segments but does not retransmit; and acknowledged, which does both. The important change from LTE is that NR's RLC no longer delivers in sequence.

#### 3.8.1 What is “in-sequence delivery”?

In-sequence delivery means passing data upward in the order it was sent. LTE's RLC held back later packets until earlier ones arrived, which added latency. NR's RLC forwards each packet the moment it is complete, even if an earlier one is still missing; if the application needs order, PDCP restores it. Moving the reordering up one layer is what lets NR's low-latency traffic skip the wait.

| Term | Meaning |
| --- | --- |
| **RLC SDU (Service Data Unit)** | Data received from PDCP. |
| **RLC PDU (Protocol Data Unit)** | **Segmented unit actually transmitted over the air.** |

A large IP packet arriving from PDCP as one SDU may leave as several PDUs, sent in different transmission intervals, each with its own header and sequence number. Figure 6.10 contrasts LTE and NR segmentation.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.10 contrasts LTE and NR segmentation.*

### 3.9 6.4.4 Medium Access Control (MAC)

RLC delivers segments; something has to decide when they go on the air. This section describes MAC, the gate, and the scheduler inside it.

MAC is the gate. It multiplexes several logical channels into one transport block, runs the fast retransmission scheme, and — in the base station — houses the scheduler that decides who transmits when.

#### 3.9.1 **6.4.4.1 Logical & Transport Channels**

Above MAC, data is organised by what it is: the logical channels BCCH, PCCH, CCCH, DCCH, and DTCH for broadcast, paging, common control, dedicated control, and dedicated traffic. Below MAC, data is organised by how it is carried: the transport channels BCH, PCH, DL-SCH, UL-SCH, and RACH, of which the two shared channels carry almost everything. MAC's multiplexing is the mapping between the two, and it packs RLC PDUs into transport blocks. Figures 6.11 and 6.12 show the mapping and the header placement; Figure 6.13 contrasts carrier aggregation, which happens inside one MAC, with dual connectivity, which needs two.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*12 show the mapping and the header placement; Figure 6.13 contrasts carrier aggregation, which happens inside one MAC, with dual connectivity, which needs two.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*12 show the mapping and the header placement; Figure 6.13 contrasts carrier aggregation, which happens inside one MAC, with dual connectivity, which needs two.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*12 show the mapping and the header placement; Figure 6.13 contrasts carrier aggregation, which happens inside one MAC, with dual connectivity, which needs two.*

#### 3.9.2 **6.4.4.2 Scheduling**

NR uses shared-channel transmission: all devices share the time–frequency resources, and the scheduler assigns them dynamically, slot by slot. Nothing is owned; everything is granted.

#### 3.9.3 Scheduler Functions (in gNB MAC)

| Direction | Function | Decision Basis |
| --- | --- | --- |
| **Downlink** | Select UEs + assign RBs + choose transport format (modulation, coding, antenna mapping). | Based on reported **CSI** (Channel State Info). |
| **Uplink** | **Grant time/frequency resources (UL-SCH) to UEs;** UEs then select which bearers to send from buffers. | Based on **buffer status reports (BSR)** + **power headroom reports (PHR)**. |

The two directions differ because the network knows its own buffers but not the device's. Downlink, it decides everything. Uplink, it grants a size and the device decides which of its logical channels fill it. Scheduling usually happens per slot, but can start mid-slot for latency-critical traffic.

#### 3.9.4 Scheduling Modes

| Mode | Description | Typical Use |
| --- | --- | --- |
| **Dynamic Scheduling** | gNB decides every slot; full flexibility. | eMBB / normal traffic. |
| **Semi-Persistent Scheduling (SPS)** | **Pre-configured repeating grants;** activated by control signaling. | VoIP, periodic URLLC. |
| **Configured Grant (CG)** | Uplink periodic resources configured by RRC; **UE can transmit without explicit grant.** Type 1 = fully configured by RRC; Type 2 = RRC config + L1/L2 activation. | Low-latency uplink (URLLC). |

Figures 6.14A and B show the downlink and uplink scheduling loops. Downlink, the base station decides everything; uplink, it grants and the device multiplexes its logical channels to fit.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Downlink, the base station decides everything; uplink, it grants and the device multiplexes its logical channels to fit.*

#### 3.9.5 **6.4.4.3 Hybrid ARQ (HARQ) with Soft Combining**

!important[HARQ is fast retransmission against channel errors, and its defining property is that a failed transmission is kept rather than discarded.]

| Property | Description |
| --- | --- |
| **Type** | Multiple stop-and-wait processes (up to 16 in NR). |
| **Feedback** | ACK/NACK per transport block via PUCCH. |
| **Asynchronous operation** | Retransmissions scheduled dynamically (essential for flexible TDD). |
| **Soft combining** | **The receiver stores soft bits from previous attempts** and combines them with new retransmissions for better decoding. |
| **Codeblock Group (CBG) retransmission** | Retransmit only the erroneous portions instead of the full transport block—reduces overhead. |

HARQ and RLC's ARQ divide the work between them. HARQ is fast and slightly unreliable — an acknowledgement can itself be misread. RLC's ARQ is slow and thorough, and it sees sequence numbers, so it catches the gap HARQ occasionally leaves. Figures 6.15 and 6.16 show the parallel processes and code-block-group retransmission; Star 13 takes the pair up in depth.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 6.15 and 6.16 show the parallel processes and code-block-group retransmission; Star 13 takes the pair up in depth.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 6.15 and 6.16 show the parallel processes and code-block-group retransmission; Star 13 takes the pair up in depth.*

### 3.10 **6.4.5 Physical Layer (PHY)**

MAC hands transport blocks to the last layer. This section describes the physical layer: what it codes, where it maps, and which channels appear on the air.

The physical layer codes, modulates, maps onto antennas, and places everything on the time–frequency grid. It offers MAC a small set of transport channels and hides everything about how they are carried. On the air it uses several physical channels: PDSCH and PUSCH for data, PDCCH and PUCCH for control, PBCH and PRACH for broadcast and random access, and reference signals such as CSI-RS and SRS for measurement. Stars 07 through 12 and 29 through 32 are all about this one desk.

### 3.11 **6.5 Control-Plane Protocols**

Sections 3.5 to 3.10 carried the user's data. This section turns to the control plane, the signalling that sets everything else up.

The control plane carries the signalling that sets everything else up: connection establishment, mobility, security, and configuration. Two protocols share it.

| Layer | Function | Communicates With |
| --- | --- | --- |
| **NAS (Non-Access Stratum)** | Authentication, registration, IP management. | Between **UE ↔ AMF** in Core Network. |
| **RRC (Radio Resource Control)** | System info, paging, connection setup, mobility, measurement config. | Between **UE ↔ gNB** in RAN. |

#### 3.11.1 **Signaling Radio Bearers (SRBs)**

RRC messages travel on signalling radio bearers — logical bearers reserved for control-plane data. They use the same PDCP, RLC, MAC, and PHY stack as user-plane bearers, and NAS messages, which run between the device and the core, are carried inside RRC messages and so travel the same way.

| Type | Purpose |
| --- | --- |
| **SRB0** | Used before security activation (e.g., RRC connection request). |
| **SRB1** | For RRC and NAS after connection setup. |
| **SRB2** | For dedicated RRC signaling (post-security). |

User data, by contrast, travels on data radio bearers. Keeping the two kinds of bearer apart is what lets signalling be prioritised and protected separately from traffic.

### 3.12 **6.5.1 RRC State Machine**

The control plane's main protocol is RRC. This section describes the three states it moves a device through, and why the middle one is the interesting one.

!note[RRC governs a device through three states, and the interesting one is the middle.]

| RRC State | Core-Network State | Connectivity | Mobility Control | Power Usage |
| --- | --- | --- | --- | --- |
| **RRC_IDLE** | CM-IDLE | No active RRC context | UE-controlled cell reselection | Lowest |
| **RRC_INACTIVE** | CM-CONNECTED | RRC context preserved | UE-controlled cell reselection | Low |
| **RRC_CONNECTED** | CM-CONNECTED | Full context established | Network-controlled handover | Medium–High |

*Table continued — panel 2 of 2.*

| RRC State | Transition |
| --- | --- |
| **RRC_IDLE** | Random Access → RRC_CONNECTED |
| **RRC_INACTIVE** | Fast resume to CONNECTED |
| **RRC_CONNECTED** | DRX for power saving |

Figure 6.17 shows the transitions.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.17 shows the transitions.*

These states describe radio connectivity. In idle there is no radio link, but the device can be paged. In inactive the device sleeps but both ends keep its context, so it can resume in a fraction of the time a fresh setup takes. In connected it is transferring data. The states directly control when the device listens, transmits, and sleeps, and Star 36 covers them in detail.

### 3.13 6.6 Mobility

A device in any RRC state can move. This section asks who decides where it goes, and shows that the answer depends on the state.

Mobility works differently depending on whether the device is connected. Connected, the network decides; idle or inactive, the device decides for itself.

#### 3.13.1 6.6.1 Network-Controlled Mobility

In the connected state the device measures neighbouring cells — reference-signal received power and quality — and reports them. The network compares them against configured events, such as a neighbour becoming stronger than the serving cell by a margin, and commands a handover. Figure 6.18 shows the sequence: data is forwarded from the source to the target, and the device performs random access to synchronise with the new cell.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.18 shows the sequence: data is forwarded from the source to the target, and the device performs random access to synchronise with the new cell.*

#### 3.13.2 6.6.2 Cell Reselection

In idle and inactive there is no connection to maintain, so the device searches synchronisation blocks on its own and reselects a better cell without telling anyone. No data moves during reselection, so nothing is lost by the silence.

#### 3.13.3 6.6.3 Tracking the Device

To reach an idle device the network must know roughly where it is. Cells are grouped into RAN areas and, above them, tracking areas; the core tracks an idle device to a list of tracking areas, and the access network tracks an inactive device to a RAN notification area. A larger area means less updating as the device moves and more paging when it is called. Figure 6.19 shows the hierarchy.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 6.19 shows the hierarchy.*

#### 3.13.4 6.6.4 Paging and the question on the paging process

Paging is how the network finds an idle or inactive device when data arrives for it. The core, or for an inactive device the access network, builds a paging message carrying the device's temporary identity. The message goes on the downlink data channel, scheduled by the control channel under the paging identifier. The device, asleep most of the time, wakes at its paging occasion, checks the control channel for that identifier, decodes the message if it finds one, and — if its own identity is inside — performs random access to come back to the connected state. Otherwise it sleeps until the next occasion. Even an idle device, then, must periodically listen; that listening is the cost of being reachable.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents. The stack is specified one document per layer, and the numbering makes them easy to find.

The stack is specified one document per layer, and the numbering makes them easy to find: TS 38.323 for PDCP, 38.322 for RLC, 38.321 for MAC, 38.331 for RRC, with SDAP in the 37 series because it serves LTE as well. Each document defines its header and its state machine, and the figure shows the numbers those headers carry — the PDCP count, the RLC window, the MAC subheaders — because those are the fields you will see when you open a packet capture of the air interface.

![[99 Attachments/5G/Protocol Figures/STAR-06-Radio-Interface-Architecture-Protocol.png|The six per-layer specifications and the header each layer adds]]

*Protocol figure: The six per-layer specifications and the header each layer adds.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| Overall protocols | [TS 38.300 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | The stack described top-down; the place to start before any per-layer document. |
| MAC | [TS 38.321 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | Multiplexing, HARQ, random access, and the scheduler's signalling. |
| RLC | [TS 38.322 V18.2.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip) | The three modes, segmentation, and ARQ. |
| PDCP | [TS 38.323 V18.5.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip) | Numbering, ciphering, integrity, reordering, duplication. |
| RRC | [TS 38.331 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | States, procedures, and the configuration of every layer below. |

!note[**When you build or run a demo.** The stack is the part of a demo you can see most directly. A gNB configuration names each bearer with its QoS class, its PDCP sequence-number length, its RLC mode and timers, and its MAC logical-channel priority, and each of those keys is a field in the corresponding specification. A capture of the Uu interface shows the headers stacked in exactly the order of this chapter, and the RRC log shows the bearers being created — SRB1 first, then SRB2 and the data bearers after security — in the sequence TS 38.331 clause 5.3.5 prescribes. When a demo attaches but carries no data, the fault is almost always at one desk, and the log line that reports it names the layer.]

Release 15 established the NR user and control stack and the inactive state. Later releases add duplication, multi-connectivity, sidelink, industrial, mobility, and power-saving options across several specifications, but the ownership rule holds: later features extend the peer protocols; they never merge SDAP, PDCP, RLC, MAC, PHY, and RRC into one layer. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix each layer; this trace adds up what the layers cost one packet in time, a calculation you can redo by hand.

**Worked numerical example.**

Use an illustrative header table to show why protocol overhead must be tied to a named packet path rather than quoted as one universal percentage.

**What we are working out.** Illustrative radio-stack PDU size before lower-layer coding, in bytes, at the PDCP/RLC/MAC packet boundary.

$$
\begin{aligned}
L_{PDU} &= L_{payload}+H_{SDAP}+H_{PDCP}+H_{RLC}+H_{MAC} \\ &= 1200+1+3+2+3 \\ &= 1209\ \mathrm{byte}
\end{aligned}
$$

Where:

- $L_{PDU}$ = 1209 byte, calculated (local sum); it belongs to the MAC PDU illustration.
- $L_{payload}$ = 1200 byte, assumed (illustrative application fragment); it belongs to the SDAP input.
- $H_{SDAP}$ = 1 byte, assumed (illustrative header); it belongs to the SDAP PDU.
- $H_{PDCP}$ = 3 byte, assumed (illustrative header); it belongs to the PDCP PDU.
- $H_{RLC}$ = 2 byte, assumed (illustrative header); it belongs to the RLC PDU.
- $H_{MAC}$ = 3 byte, assumed (illustrative subheader); it belongs to the MAC PDU.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $L_{PDU}$ | 1209 byte | calculated | local sum | MAC PDU illustration |
| $L_{payload}$ | 1200 byte | assumed | illustrative application fragment | SDAP input |
| $H_{SDAP}$ | 1 byte | assumed | illustrative header | SDAP PDU |
| $H_{PDCP}$ | 3 byte | assumed | illustrative header | PDCP PDU |
| $H_{RLC}$ | 2 byte | assumed | illustrative header | RLC PDU |
| $H_{MAC}$ | 3 byte | assumed | illustrative subheader | MAC PDU |

Bytes add because the quantities share one packet boundary. The values are teaching inputs; actual sizes depend on format, sequence-number length, security, segmentation, and multiplexing. Coding, reference signals, retransmissions, and RF overhead are outside this PDU table.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course, then lists the sentences students most often get wrong about the stack.

**Course alignment.** No single Saar unit owns the complete stack. Use this note as the packet-path reference for U03–U14, especially before coding, control signaling, HARQ, and access procedures. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

!warning[**“A bearer is a physical channel”.**

A bearer is a protocol service. Logical, transport, and physical channels describe later interfaces. The fix is to keep bearers and channels in separate categories; they describe different interfaces.]

!warning[**“RLC and HARQ retransmit the same object”.**

They operate on different protocol units and timescales. The fix is to compare the protocol units and timescales before equating two mechanisms.]

!warning[**“RRC carries every control bit”.**

RRC configures longer-lived behavior; MAC and PHY also carry fast control. The fix is to ask which layer carries the control, since configuration and fast control differ.]

!warning[**“QoS mapping guarantees latency”.**

Mapping selects treatment. Actual service depends on load, radio quality, and the end-to-end path. The fix is to separate the treatment a flow is assigned from the service it actually receives.]

!warning[**“The scheduler is standardized”.**

Interfaces and constraints are standardized; the scheduling algorithm is largely implementation-specific. The fix is to distinguish the standardized interface from the implementation-specific algorithm.]

### 6.1 Supplement: the core as six functions

The confusions above concern the radio side. The course's illustrated series insists that the base station is not the network; this supplement gives each core function its one job.

!warning[The illustrated signalling series starts by insisting that the base station is not the network. Section 3 named the core functions; this figure gives each its one job and places it on a plane.]

![[99 Attachments/5G/Supplement Figures/STAR-06-Saar-Core-Functions.png|The 5G core as six functions on two planes]]

*Supplement figure: The 5G core network drawn as a control plane of five functions above a user plane of UE, base station, UPF and data network.*
*Figure 6.1 — Control plane decides, user plane carries: AUSF, UDM, AMF, SMF and PCF above UE, gNB, UPF and data network.*

| Function | Plane | One job | Talks over |
|---|---|---|---|
| AMF | control | first contact, registration, location, paging | N1 to the UE, N2 to the gNB |
| SMF | control | owns each PDU session, picks the UPF, sets QoS and charging | N4 to the UPF |
| UPF | user | forwards the packets, anchors the session | N3 to the gNB, N6 to the data network |
| AUSF · UDM · PCF | control | authentication · subscription · policy | service-based interfaces |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 01; 3GPP TS 23.501 clause 4.2.

### 6.2 Supplement: PDU session establishment

Section 6.1 gave the functions; this supplement shows them at work in the six messages that build a PDU session.

!warning[Registration answers whether the UE may use the network; the PDU session builds its road. The six messages below are the comic's six steps with the TS 23.502 names attached.]

![[99 Attachments/5G/Supplement Figures/STAR-06-Saar-PDU-Session-Establishment.png|PDU session establishment in six steps]]

*Supplement figure: Sequence diagram of PDU session establishment across UE, gNB, AMF, SMF, PCF and UPF in six numbered steps.*
*Figure 6.2 — Six messages, then a session: request, SMF context, policy, N4, accept, downlink tunnel.*

| Step | Message | Who → whom | What it settles |
|---|---|---|---|
| 1 | PDU Session Establishment Request | UE → AMF (NAS) | data network, session type, slice |
| 2–3 | Create SM context · SM policy | AMF → SMF → PCF | who manages the session and under which rules |
| 4 | N4 Session Establishment | SMF → UPF | which UPF, forwarding and charging rules |
| 5 | Establishment Accept + N2 setup | SMF → UE via AMF, gNB | IP address, QoS rules, radio bearer; uplink open |
| 6 | N4 Session Modification | SMF → UPF | gNB tunnel endpoint; downlink open |

- One UE holds several sessions (Internet, IMS); one session holds several QoS flows; a session can be modified or released by the UE, the network or policy.

Source: Supplementary material, *Illustrated 5G signalling flows*, part 03; 3GPP TS 23.502 clause 4.3.2.

### 6.3 Supplement: QoS flows versus EPS bearers

A PDU session carries QoS flows. This supplement contrasts them with the LTE bearer: the SDAP mapping of Section 3.6 seen from the core.

!warning[The training deck's clearest slide pair contrasts the LTE end-to-end bearer with the NR two-level mapping. It is the SDAP layer of Section 3 seen from the core.]

![[99 Attachments/5G/Supplement Figures/STAR-06-Saar-QoS-Flows-vs-Bearers.png|LTE EPS bearers against the NR two-level QoS-flow mapping]]

*Supplement figure: Two stacked diagrams: the LTE end-to-end EPS bearer through UE, eNB, S-GW and P-GW, and the NR two-level mapping of packets to QoS flows inside a PDU session and of flows to data radio bearers at the gNB, with two notes.*
*Figure 6.3 — LTE: one EPS bearer per QoS class from UE to P-GW. NR: QoS flows inside a session tunnel, mapped to radio bearers by the gNB.*

| Aspect | LTE | NR |
|---|---|---|
| Unit of QoS | EPS bearer, identified by QCI | QoS flow, identified by QFI and 5QI |
| Who sorts packets | TFT filters at P-GW and UE | NAS filters at UPF and UE, marked in-band |
| Radio mapping | fixed: one radio bearer per EPS bearer | gNB's SDAP chooses the DRB per flow |
| Cost of a new class | dedicated bearer signalled end to end | a flow added to the existing session |

Source: Supplementary material, *5G key technologies and applications* (training deck, 2018), slides 42–45; 3GPP TS 23.501 clause 5.7, TS 37.324.

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 6, pp. 79–113, 2021, DOI [chapter 6](https://doi.org/10.1016/B978-0-12-822320-8.00006-4).
2. Chapter 6 notes of this knowledge base (the author's reading notes).
4. 3GPP, *TS 38.300 V18.10.0, clauses 4–6*, [Overall protocols](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
5. 3GPP, *TS 38.321 V18.10.0, clauses 4–6*, [MAC](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).
6. 3GPP, *TS 38.322 V18.2.0, clauses 4–6*, [RLC](https://www.3gpp.org/ftp/Specs/archive/38_series/38.322/38322-i20.zip).
7. 3GPP, *TS 38.323 V18.5.0, clauses 4–6*, [PDCP](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip).
8. 3GPP, *TS 38.331 V18.10.0, clauses 4–6*, [RRC](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).
9. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
10. ShareTechnote, [radio protocol stack](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html), accessed 2026-08-03.
11. ShareTechnote, [RLC](https://www.sharetechnote.com/html/5G/5G_RLC.html), accessed 2026-08-03.
12. Saar University 5G course alignment.
13. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| 5GC | Fifth Generation Core network | Section 1; fixed specification set in Section 6 |
| NG-RAN | Next Generation Radio Access Network | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| gNB | next generation NodeB | Section 1; fixed specification set in Section 6 |
| QoS | Quality of Service | Section 1; fixed specification set in Section 6 |
| SDAP | Service Data Adaptation Protocol | Section 1; fixed specification set in Section 6 |
| PDCP | Packet Data Convergence Protocol | Section 1; fixed specification set in Section 6 |
| RLC | Radio Link Control | Section 1; fixed specification set in Section 6 |
| MAC | Medium Access Control | Section 1; fixed specification set in Section 6 |
| PHY | Physical Layer | Section 1; fixed specification set in Section 6 |
| RRC | Radio Resource Control | Section 1; fixed specification set in Section 6 |
| DRB | Data Radio Bearer | Section 1; fixed specification set in Section 6 |
| SRB | Signaling Radio Bearer | Section 1; fixed specification set in Section 6 |
| PDU | Protocol Data Unit | Section 1; fixed specification set in Section 6 |
| SDU | Service Data Unit | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $L_{PDU}$ | Illustrative stack PDU length | byte |
| $L_{payload}$ | Payload length | byte |
| $H_{SDAP}$ | SDAP header length | byte |
| $H_{PDCP}$ | PDCP header length | byte |
| $H_{RLC}$ | RLC header length | byte |
| $H_{MAC}$ | MAC subheader length | byte |
| SMF | Session Management Function | The SMF owns each PDU session in the 5G core. It selects the UPF, allocates the IP address and installs QoS and charging rules over N4. |
| AUSF | Authentication Server Function | The AUSF runs primary authentication for a subscriber. It lets the network verify the UE and the UE verify the network before registration continues. |
| UDM | Unified Data Management | The UDM holds subscription data and the current serving-function records. Registration and session procedures read subscription and presence information from it. |
| PCF | Policy Control Function | The PCF decides access-and-mobility and session policies. It supplies QoS, charging and area rules to the AMF and SMF. |
| NSSF | Network Slice Selection Function | The NSSF selects the network slice instances serving a UE. It assists the AMF during registration when slices are requested. |
| NRF | Network Repository Function | The NRF is the service registry of the 5G core. Network functions discover each other through it. |
| CHF | Charging Function | The CHF collects charging events from the SMF and other functions. It converts session usage into billing records. |
| IMS | IP Multimedia Subsystem | The IMS is the operator service layer for voice, video and messaging over IP. A dedicated PDU session connects the UE to it. |
| QFI | QoS Flow Identifier | The QFI marks each packet with its QoS flow inside a PDU session. SDAP maps flows to radio bearers using it. |
| 5QI | 5G QoS Identifier | The 5QI names the QoS characteristics of a QoS flow. 5QI 1 is conversational voice. |
| QCI | QoS Class Identifier | The QCI names the QoS class of an EPS bearer. QCI 1 is conversational voice. |
| TFT | Traffic Flow Template | A TFT is the packet filter set that sorts EPS traffic into bearers. NR replaces it with QoS rules and in-band QFI marking. |
| AMBR | Aggregate Maximum Bit Rate | The AMBR caps the total rate of non-guaranteed flows per UE or per session. It comes from the subscription and the policy. |
| DN | Data Network | A DN is the network a PDU session reaches, such as the Internet or the IMS. It is named by a data network name. |
| N4 | N4 interface | N4 lets the SMF program the UPF. Session establishment, modification and release travel over it. |
| N6 | N6 interface | N6 connects the UPF to the data network. It is the user-plane exit of the 5G system. |

The symbols mean what they mean in this note; another note may use the same letter for something else.
