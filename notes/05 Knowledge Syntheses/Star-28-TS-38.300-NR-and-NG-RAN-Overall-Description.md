---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 28
title: TS 38.300 NR and NG-RAN Overall Description
language: en
course_units:
- U03–U14 cross-layer reference
release_baseline: 18
---

# STAR-28 — TS 38.300 NR and NG-RAN Overall Description

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf) — TS 38.300 V18.10.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Thirty specifications define the NR radio. TS 38.300 is the one that draws them on a single page, names every node and layer, and points to the document that holds the detail. It is an atlas.

![[99 Attachments/5G/Concept Figures/STAR-28-TS-38.300-Concept.png|TS 38.300 explained as an atlas rather than a street map]]

*Concept figure: TS 38.300 explained as an atlas rather than a street map.*

Clause 4 is the map of the city: phone, base station, and core; the NG and Xn roads between them; and how a base station may be split into a central and a distributed unit, with the interfaces detailed in TS 38.401. Clause 5 says what the radio offers, waveforms, channels, synchronisation, random access, one page each, and sends you to TS 38.211 to 38.214 for how they are made. Clause 6 says who does what in layer 2: MAC schedules and retransmits, RLC segments, PDCP protects, SDAP maps quality flows to bearers, each detailed in its own document. Clause 7 is the control plane, RRC states, system information, access control, and capabilities, with every message in TS 38.331. Clauses 8 and 9 are names and moving: the identities a phone carries, and mobility, paging, handover, failure, and recovery. Clauses 10 to 12 are scheduling, power saving, and quality of service: what the scheduler may use, how a phone sleeps, and how a service promise reaches a radio bearer.

The reading rule is simple. Open it first, for every question, and leave it as soon as you need a bit field, a timer, or a table. The atlas says which document owns a behaviour; it never contains the algorithm itself.

**The question this chapter answers.** How should an engineer navigate TS 38.300 to connect architecture, protocols, radio procedures, mobility, and QoS without asking the overview document for details owned by another specification?

!important[**The short answer.** TS 38.300 is the Stage-2 system map for NR and NG-RAN. Clause 4 establishes nodes, interfaces, planes, splits, and deployment options; clause 5 summarises the physical layer; clause 6 covers layer 2; clause 7 covers RRC; clause 8 defines identities; clause 9 covers mobility and state transitions; clause 10 scheduling; and clause 12 QoS. It says what functions exist and how they fit, then hands executable detail to the owning specification.]

Names you will meet in this note: New Radio (NR), Next Generation Radio Access Network (NG-RAN), user equipment (UE), next generation NodeB (gNB), 5G Core (5GC), central and distributed unit (CU, DU), control and user plane (CP, UP), quality of service (QoS), medium access control (MAC), radio link control (RLC), packet data convergence protocol (PDCP), service data adaptation protocol (SDAP), radio resource control (RRC), integrated access and backhaul (IAB), non-public network (NPN).

This note teaches the fixed clause map of this knowledge base and 3GPP [TS 38.300 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf). The extraction is a navigation aid; the official file is official, and the course manifest records its hash and retrieval date.

## 2. Where you are in 5G

Section 1 called TS 38.300 an atlas. The map below shows where the atlas sits in 5G: over every box, pointing to the document that holds each one's detail.

![[99 Attachments/5G/Locator Maps/STAR-28-Where-You-Are-in-5G.png|Where Star 28 sits in the whole 5G system]]

*Locator: Where Star 28 sits in the whole 5G system.*

This chapter lights the specification band as a whole, because TS 38.300 is the document that spans it. It is the written form of the architecture of Stars 05 and 06, and the index into the protocol notes of Stars 29 to 37, each of which is one of the documents it points to.

The Knowledge Structure Map routes architecture, protocol ownership, and system procedures to their companion specifications. The mechanism diagram is the responsibility map.

![[99 Attachments/5G/Knowledge Maps/STAR-28-TS-38.300-Knowledge Structure Map.png|STAR-28 system-position map]]

*Knowledge map: TS 38.300 — NR and NG-RAN architecture at Stage 2.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-28-TS-38.300-Responsibility-Map.png|Star 28 mechanism and handoff diagram]]

*Mechanism: TS 38.300 clause-to-specification routing map.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.300 V18.10.0, clause 4, PDF page 24](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.300 V18.10.0, clause 4, PDF page 24, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [RAN architecture overview](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html). The reproduced image is omitted from this distribution.

*Source excerpt: RAN architecture overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!note] Searchable structure
> UE and gNB architecture → radio protocol planes → PHY and Layer 2 roles → state, QoS, and mobility procedures → companion specifications.

Read the map as a routing diagram: a box is an owned concept or transformation, an arrow a dependency or handoff. When a trace diverges, walk one arrow upstream and compare the exact input object, configuration, release, and integer or state; that is more reliable than searching for the final error string, because layers use similar words for different objects. 

## 3. Foundations and prerequisites

Section 2 placed the atlas. Five foundations follow: what a stage 2 description is, where the access network ends, how a node can be split, what the two planes carry, and how the overview routes further reading.

### 3.1 Stage 2 defines behavior and boundaries

The first foundation is the kind of document this is: stage 2.

A Stage-2 description names functional entities, information flows, responsibilities, and interfaces. It is more concrete than a service requirement and less executable than a Stage-3 protocol. The right question is usually which function owns a behaviour and which companion specification defines the messages.

> [!spec] 3GPP reality check
> The three stages are 3GPP's own vocabulary: Stage 1 is requirements such as TS 22.261, Stage 2 is architecture such as TS 23.501 and [TS 38.300 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf), and Stage 3 is the protocol detail of TS 38.331 and the rest of the 38 series.

### 3.2 NG-RAN is not the 5GC

Section 3.1 said what the document describes. This section draws its first boundary, between the access network and the core.

!important[The phone reaches the radio access network through the NR air interface. The access network connects to the core through NG interfaces and to peer radio nodes through Xn. Scheduling, admission, mobility execution, and bearer handling are access-network functions; registration and session policy extend into the core.]

### 3.3 Logical nodes can be split

Section 3.2 placed the base station in the access network. This section splits it into logical units.

!important[A base station may be represented as central and distributed functions. The split assigns protocol functions and standardised interfaces; it does not require one server per logical node. A deployment statement must distinguish logical function, software instance, site, and hardware.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [RAN architecture page](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html) draws the CU/DU and CP/UP splits as boxes with their interface names, which is the picture an open-source configuration file reproduces line by line.

### 3.4 Planes carry different jobs

Sections 3.2 and 3.3 were about nodes. This section is about what flows through them: two planes with different jobs.

The user plane moves service data. The control plane configures resources, mobility, security state, and bearer behaviour. Both share the lower radio mechanisms, yet their traffic, reliability, and latency roles differ, and control-plane success is not user-plane throughput evidence.

### 3.5 Overview clauses route detailed reading

The last foundation is how to read the document: as a router to the detailed specifications.

TS 38.300 summarises physical channels, the layer-2 protocols, RRC, states, QoS, mobility, scheduling, access, and dual connectivity, and normally points outward for exact bit fields, timers, resource mappings, and algorithms. Navigation is part of technical correctness.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clause 4 builds the architecture graph

The walk starts with clause 4, the architecture graph.

Start with the phone, the base station, the core connection, the NG and Xn interfaces, and where each protocol terminates. Add the CU/DU split, multi-connectivity, IAB, non-public networks, repeaters, and other options only once the baseline graph is stable; each option changes an interface or a function's placement, never the definition of the waveform.

> [!spec] 3GPP reality check
> The graph is [TS 38.300 V18.10.0, clauses 4.1 to 4.4](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf); the F1 and E1 interfaces of the split and the node functions are TS 38.401 with their protocols in TS 38.473 and TS 38.463.

### 4.2 Clause 5 summarizes the PHY service

Section 4.1 built the graph. This section reads clause 5, the physical layer summarised.

The overview describes waveform families, downlink and uplink transmission, synchronisation, random access, sidelink, and the transport-channel relationships. Exact modulation, sequence generation, and resource mapping belong to TS 38.211; coding to TS 38.212; control and data procedures to TS 38.213 and 38.214.

### 4.3 Clauses 6–7 assign radio-protocol ownership

Section 4.2 covered the physical layer. This section reads clauses 6 and 7, which assign the radio protocols.

Clause 6 summarises layer 2: MAC multiplexes, schedules, and runs HARQ; RLC segments and optionally retransmits; PDCP protects and reorders; SDAP maps QoS flows to data radio bearers. Clause 7 summarises RRC services, states, system information, access control, capabilities, and configuration. These roles are interfaces; the protocol documents of Stars 33 to 36 hold the detail.

### 4.4 Clauses 8–9 connect identities, state, and mobility

Section 4.3 assigned the layers. This section reads clauses 8 and 9: identities, states and mobility.

Clause 8 defines the identities of the phone, the network, the transport toward the core, and sidelink contexts. Clause 9 organises mobility and state transitions: cell selection and reselection, handover, measurements, paging, random access, radio-link failure, beam-failure recovery, and timing advance. An identity, an RRC state, and a mobility procedure are related context with different jobs.

> [!spec] 3GPP reality check
> The three RRC states and the transitions between them are TS 38.300 clause 7.1 and 9.2, with the messages in TS 38.331 clause 5.3; the identities are clause 8, and the Xn handover procedures are TS 38.423.

### 4.5 Clauses 10–12 connect scheduling, power saving, and QoS

Section 4.4 covered mobility. This section reads clauses 10 to 12: scheduling, power saving and QoS.

Clause 10 summarises the scheduler and its supporting measurements, rate control, activation, cross-carrier behaviour, and coordination. Clause 11 covers power saving and clause 12 QoS. A QoS flow reaches radio resources only through bearer mapping, admission, scheduler decisions, channel conditions, and the rest of the end-to-end path; exact triggers, messages, counters, and physical resources are in their owning specifications.

### 4.6 Companion specifications close the implementation chain

The walk ends by naming the companion documents that close each pointer.

!note[Use TS 38.401 for architecture detail, TS 38.331 for RRC messages, TS 38.321, 322, 323, and 340 for the radio protocols, and TS 38.211 to 215 for the physical layer; a design review cites the overview clause and the executable clause together. A cross-specification trace starts with one event rather than one document. For a downlink transfer, record the QoS flow and bearer, the scheduler decision, the DCI that expresses the grant, the transport block, the coding and rate matching, the physical mapping, the receiver's CRC decision, and the acknowledgement or retransmission state; TS 38.300 explains why these form one chain and the detailed documents define each transition. The same discipline applies to mobility, where a measurement is not a handover and a handover command is not completed mobility, and to deployment options, where a CU/DU split changes processing placement and failure domains, IAB makes radio resources serve two purposes, a non-public network changes ownership but not the waveform, and a repeater changes the RF path while leaving protocol functions elsewhere.]

## 5. Worked example

Section 4 walked the clauses. Section 5 runs one calculation through them to show local traceability.

### 5.1 Worked numerical example

The example below is deliberately small: one calculation that shows how a number in this document is traced to its clause.

The example is intentionally small. It demonstrates local traceability and does not claim to reproduce a complete conformance vector.

**What we are working out.** Illustrative end-to-end radio-access processing time for one already-connected packet, in milliseconds, from SDAP ingress at the gNB to decoded SDAP delivery at the UE.

$$
\begin{aligned}
T_{RAN} &= T_{SDAP}+T_{PDCP}+T_{RLC}+T_{MAC}+T_{PHY}+T_{air}+T_{rx} \\ &= 0.05+0.10+0.10+0.30+0.35+0.50+0.60 \\ &= 2.00\ \mathrm{ms}
\end{aligned}
$$

Where:

- $T_{RAN}$ = 2.00 ms, calculated (local sum); it belongs to the gNB SDAP ingress to UE SDAP delivery.
- $T_{SDAP}$ = 0.05 ms, assumed (illustrative processing); it belongs to the gNB SDAP.
- $T_{PDCP}$ = 0.10 ms, assumed (illustrative processing); it belongs to the gNB PDCP.
- $T_{RLC}$ = 0.10 ms, assumed (illustrative processing); it belongs to the gNB RLC.
- $T_{MAC}$ = 0.30 ms, assumed (illustrative scheduling); it belongs to the gNB MAC.
- $T_{PHY}$ = 0.35 ms, assumed (illustrative transmit processing); it belongs to the gNB PHY.
- $T_{air}$ = 0.50 ms, assumed (illustrative radio interval); it belongs to the radio interface.
- $T_{rx}$ = 0.60 ms, assumed (illustrative receive chain); it belongs to the UE PHY to SDAP.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $T_{RAN}$ | 2.00 ms | calculated | local sum | gNB SDAP ingress to UE SDAP delivery |
| $T_{SDAP}$ | 0.05 ms | assumed | illustrative processing | gNB SDAP |
| $T_{PDCP}$ | 0.10 ms | assumed | illustrative processing | gNB PDCP |
| $T_{RLC}$ | 0.10 ms | assumed | illustrative processing | gNB RLC |
| $T_{MAC}$ | 0.30 ms | assumed | illustrative scheduling | gNB MAC |
| $T_{PHY}$ | 0.35 ms | assumed | illustrative transmit processing | gNB PHY |
| $T_{air}$ | 0.50 ms | assumed | illustrative radio interval | radio interface |
| $T_{rx}$ | 0.60 ms | assumed | illustrative receive chain | UE PHY to SDAP |

The displayed result is rounded only after the local substitution. All terms are durations on one serial path, so milliseconds add. The inputs are explicit assumptions. Setup, retransmission, core transport, queuing outside the stated window, and application time are excluded; the result cannot be advertised as 5G end-to-end latency.

The engineering check asks whether all operands share the declared boundary and whether an omitted cap, branch, state, overhead, or companion procedure could change the decision. If so, the next step is to restore that term rather than add false precision.

## 6. The 3GPP protocol: which document, and what it says

The example used one path. This section names what TS 38.300 fixes and what it leaves to other documents.

TS 38.300 owns the graph of nodes and layers; every number lives elsewhere. What it fixes is structure: a base station is a central unit plus distributed units over F1, the central unit may split into control and user parts over E1, NG-C runs to the AMF and NG-U to the UPF, and Xn joins base stations. The user plane stacks SDAP, PDCP, RLC, MAC, and PHY; the control plane puts RRC on the same lower layers. A phone is idle, inactive, or connected, and the inactive state keeps its context. Each identity is scoped to where it is used. A QoS flow reaches the radio as a data radio bearer through SDAP. Each structural fact is one a configuration file must reproduce, and the figure sets them beside the lines they become.

![[99 Attachments/5G/Protocol Figures/STAR-28-TS-38.300-Protocol.png|The structural facts TS 38.300 fixes, the documents that own the detail, and the configuration lines each becomes]]

*Protocol figure: The structural facts TS 38.300 fixes, the documents that own the detail, and the configuration lines each becomes.*

| Clause | Fixed V18.10.0 scope | Owner of the detail |
|---|---|---|
| 4 | architecture, interfaces, planes, splits, multi-connectivity, IAB, NPN, repeaters | TS 38.401, TS 38.410–38.473 |
| 5 | physical-layer overview and transport-to-physical relationships | TS 38.211–38.215 |
| 6 | layer 2: MAC, RLC, PDCP, SDAP, data flow, aggregation, BAP, multi-TRP | TS 38.321, 38.322, 38.323, 38.340 |
| 7 | RRC services, states, system information, access control, capabilities | TS 38.331, TS 38.306 |
| 8 | identities for the UE, the network, CN–RAN transport, and sidelink | TS 38.413, TS 23.003 |
| 9 | mobility and state transitions, measurements, paging, random access, failure and recovery, timing advance | TS 38.331, TS 38.423, TS 38.321 |
| 10 | scheduling, supporting measurements, rate control, activation, coordination | TS 38.214, TS 38.321 |
| 11–12 | UE power saving and QoS | TS 38.321, TS 23.501 |

The official text is [TS 38.300 V18.10.0, official archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf).

!note[**When you build or run a demo.** An open-source base station's configuration file is clause 4 written as keys: the address of the core's access function for the NG interface, and, if the stack is split, the F1 address between its own halves. The cell's global identity, its PLMN, cell identity, physical-cell identity, and tracking area, is clause 8. Whether the inactive state is enabled and how often the RAN pages are clause 7 and 9 lines. The mapping from a 5QI to a bearer is clause 12. And the start-up log is the graph coming up one edge at a time: the NG setup response from the core, the F1 setup between the halves, the cell in service, and then the first phone's RRC setup. When something fails, this table says which document describes the edge that did not come up.]

Release 15 established the first architecture and the standalone and non-standalone relationships. Release 16 broadened IAB, industrial, sidelink, positioning, unlicensed, multi-connectivity, and topology options. Release 18 continues the 5G-Advanced evolution with further architecture and procedure extensions, and the stable reading rule is to keep the baseline graph visible and add each option at its owning interface. Release 18 is a family of coordinated versions; a later corrective version is recorded as a clause-level delta. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification draws the graph; the engineering pages draw it with the message names.

ShareTechnote's [RAN architecture](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html) and [radio protocol stack](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html) pages draw the same graph and the same two stacks as TS 38.300 clause 4, but labelled with the message names and log lines a practitioner sees, which makes them the right pages for recognising what an NG setup or an F1 setup looks like in a capture. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the graph and the pages in place, this section positions the chapter in the course.

This note supports U03–U14 cross-layer reference. Before class, review binary representation, decibels, probability, protocol layering, and the relevant resource-grid concepts. During class, use Section 4 to locate ownership, Section 5 to audit one calculation, and Section 6 to navigate the fixed specification. Afterwards, connect the clause to a configuration or trace. The maintained course crosswalk remains unchanged.

This Star is a protocol map. It becomes useful when a student asks which document owns a statement, what representation crosses a boundary, or why two apparently similar terms have different test procedures.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “TS 38.300 defines every message field”

!warning[It is an overview and Stage-2 router. Stage-3 protocol TS documents define messages and information elements. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.2 “A gNB is one physical box”

!warning[A gNB is a logical node whose functions may be split and deployed across platforms. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.3 “NR and NG-RAN are synonyms”

!warning[NR is the radio interface; NG-RAN is the access network containing radio nodes and interfaces. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.4 “QoS mapping guarantees a service KPI”

!warning[Mapping selects radio treatment. Load, link quality, scheduling, transport, and application behavior still matter. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.5 “Every procedure belongs to one layer”

!warning[Access, mobility, recovery, and scheduling cross RRC, MAC, PHY, and sometimes core functions. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.300 V18.10.0: NR and NG-RAN Overall Description*, [official PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf).
2. Clause map of this knowledge base.
4. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm).
5. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
6. ShareTechnote, [RAN architecture](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html), accessed 2026-08-03.
7. ShareTechnote, [radio protocol stack](https://www.sharetechnote.com/html/5G/5G_RadioProtocolStackArchitecture.html), accessed 2026-08-03.
8. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; TS 38.300 V18.10.0 |
| NG-RAN | Next Generation Radio Access Network | Section 1; TS 38.300 V18.10.0 |
| UE | User Equipment | Section 1; TS 38.300 V18.10.0 |
| gNB | next generation NodeB | Section 1; TS 38.300 V18.10.0 |
| 5GC | Fifth Generation Core network | Section 1; TS 38.300 V18.10.0 |
| CU | Central Unit | Section 1; TS 38.300 V18.10.0 |
| DU | Distributed Unit | Section 1; TS 38.300 V18.10.0 |
| CP | Control Plane | Section 1; TS 38.300 V18.10.0 |
| UP | User Plane | Section 1; TS 38.300 V18.10.0 |
| QoS | Quality of Service | Section 1; TS 38.300 V18.10.0 |
| MAC | Medium Access Control | Section 1; TS 38.300 V18.10.0 |
| RLC | Radio Link Control | Section 1; TS 38.300 V18.10.0 |
| PDCP | Packet Data Convergence Protocol | Section 1; TS 38.300 V18.10.0 |
| SDAP | Service Data Adaptation Protocol | Section 1; TS 38.300 V18.10.0 |
| RRC | Radio Resource Control | Section 1; TS 38.300 V18.10.0 |
| IAB | Integrated Access and Backhaul | Section 1; TS 38.300 V18.10.0 |
| NPN | Non-Public Network | Section 1; TS 38.300 V18.10.0 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $T_{RAN}$ | Radio-access processing interval | ms |
| $T_{SDAP}$ | SDAP processing time | ms |
| $T_{PDCP}$ | PDCP processing time | ms |
| $T_{RLC}$ | RLC processing time | ms |
| $T_{MAC}$ | MAC/scheduling time | ms |
| $T_{PHY}$ | Transmit-PHY processing time | ms |
| $T_{air}$ | Radio interval | ms |
| $T_{rx}$ | UE receive-chain time | ms |

The symbols mean what they mean in this note; another note may use the same letter for something else.
