---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 37
title: TS 38.401 NG-RAN Architecture Description
language: en
course_units:
- U03–U14 cross-layer architecture reference
release_baseline: 18
---

# STAR-37 — TS 38.401 NG-RAN Architecture Description

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) — TS 38.401 V18.7.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

To a phone and to the core, a gNB is one thing. Inside, TS 38.401 lets it be three logical units on named links, each ending different protocols, possibly in different buildings. Think of one base station in three boxes: the brain, the pipe, and the radio.

![[99 Attachments/5G/Concept Figures/STAR-37-TS-38.401-Concept.png|TS 38.401 explained as one base station in three boxes]]

*Concept figure: TS 38.401 explained as one base station in three boxes.*

The brain is the control-plane central unit: RRC and control-plane PDCP end here, and it decides, admit, configure, move, release. The pipe is the user-plane central unit: user-plane PDCP and SDAP end here, and it seals and orders user packets and tunnels them to the core. The radio is the distributed unit: RLC, MAC, and PHY end here, and it schedules, retransmits, and drives the antennas of one or more cells. Three named links join them: F1-C carries control between brain and radio, F1-U carries user packets in tunnels between pipe and radio, and E1 lets the brain set up bearer contexts in the pipe. The brain reaches the core's access function over NG-C, the pipe reaches the user-plane function over NG-U, and the radio reaches the phones over Uu.

Why split at all? The radio must sit at the antenna; the brain can sit anywhere with fibre; one central unit can run dozens of distributed units; and the pipe scales separately from control. The split is logical: three nodes may be one box or three data centres, the interfaces exist either way, what changes is delay and what fails together, and an IP address never proves who owns a protocol. A user packet's real path is phone, radio unit, F1-U, pipe, NG-U, core; the radio unit never unseals it, the brain never carries it, and E1 sets the pipe up but no packet flows on it. The key fact to carry is that whoever terminates PDCP terminates ciphering, that this placement is an architectural decision, and that every identifier is meaningful on one interface only.

**The question this chapter answers.** Which split NG-RAN node terminates each protocol and carries each plane?

!important[**The short answer.** A gNB can split a central unit into a control-plane part and a user-plane part beside a distributed unit, connected by F1-C, F1-U, and E1. The central side hosts RRC, PDCP, and SDAP, with control-plane PDCP and RRC in the control unit and user-plane PDCP and SDAP in the user unit; the distributed unit hosts RLC, MAC, and PHY.]

Names you will meet in this note: Next Generation Radio Access Network (NG-RAN), central and distributed unit (CU, DU), control-plane and user-plane central unit (gNB-CU-CP, gNB-CU-UP), the F1-C, F1-U, E1, NG-C, NG-U, Xn-C, and Xn-U interfaces, Access and Mobility Management Function (AMF), User Plane Function (UPF), radio and transport network layer (RNL, TNL), tunnel endpoint identifier (TEID), the F1, E1, NG, and Xn application protocols (F1AP, E1AP, NGAP, XnAP).

This note freezes the clause map of this knowledge base and the official [TS 38.401 V18.7.0 archive](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf).

## 2. Where you are in 5G

Section 1 put one base station in three boxes. The map below shows where TS 38.401 sits in 5G: inside the base station, on the links between its units and toward the core.

![[99 Attachments/5G/Locator Maps/STAR-37-Where-You-Are-in-5G.png|Where Star 37 sits in the whole 5G system]]

*Locator: Where Star 37 sits in the whole 5G system.*

This chapter lights the architecture document of the specification band: the detailed form of the split that Star 06 and Star 28 introduced, the node that Star 22's relays reuse, and the home of the interfaces over which Star 36's messages and Star 35's packets travel between units. It is the last note, because it is where everything above becomes deployable boxes.

The Knowledge Structure Map draws the split architecture. The mechanism diagram traces the CU/DU path.

![[99 Attachments/5G/Knowledge Maps/STAR-37-TS-38.401-Knowledge Structure Map.png|STAR-37 system-position map]]

*Knowledge map: TS 38.401 — the CU/DU split and where protocols terminate.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-37-NG-RAN-CU-DU-Architecture-Path.png|Star 37 mechanism and handoff diagram]]

*Mechanism: TS 38.401 — identifier scope across the NG-RAN interfaces.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.401 V18.7.0, clause 5, PDF page 13](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.401 V18.7.0, clause 5, PDF page 13, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [RAN architecture overview](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html). The reproduced image is omitted from this distribution.

*Source excerpt: RAN architecture overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure corrections
> The distributed unit does **not** terminate PDCP ciphering or integrity: user-plane PDCP and SDAP terminate in the user-plane central unit, and control-plane PDCP and RRC in the control-plane central unit. The real user path is **UE → gNB-DU → gNB-CU-UP → UPF** over Uu, F1-U, and NG-U; a DU-to-UPF arrow omits the user unit and is schematic. The bottom strip of the map is also schematic: authoritative ownership is clauses 4 principles, 5 general architecture, 6 NG-RAN architecture, 7 functions, 8 procedures, 9 synchronisation, 10 interfaces, and 11 inter-node transport association.

> [!note] Searchable structure
> UE and 5GC endpoints → CU-CP, CU-UP, and DU termination → F1-C, F1-U, E1, NG, and Xn → identifiers and bearer contexts → setup, mobility, and recovery procedures.

An arrow shows reachability. 

## 3. Foundations and prerequisites

Section 2 placed the split. Six foundations follow: logical versus physical, the two termination chains, where security ends, what the interfaces are, how identifiers are scoped, and where architecture meets procedure.

### 3.1 Logical function is not physical deployment

The first foundation is the difference between a logical unit and a building.

!important[Clause 4 separates access-network and core functions from transport and permits one physical element to host several logical nodes, so "central" and "distributed" name roles. The radio network layer describes the logical nodes; the transport network layer carries their signalling and data. A trace must not infer protocol ownership from an address or physical separation from a logical interface.]

> [!spec] 3GPP reality check
> The principles, including the separation of radio and transport network layers and the freedom to host several logical nodes in one element, are [TS 38.401 V18.7.0, clause 4](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf).

### 3.2 Control and user planes have different termination chains

Section 3.1 separated logical from physical. This section follows a packet and a message through the units to see where each protocol ends.

Clause 5.2 describes the user plane: an uplink packet is processed by PHY, MAC, and RLC in the distributed unit, carried as a PDCP PDU over F1-U, processed by user-plane PDCP and SDAP in the user-plane central unit, and transported to the user-plane function over NG-U, with the reverse in downlink; E1 coordinates bearer context and is not the packet route. Clause 5.3 describes the control plane: RRC terminates in the control-plane central unit, the distributed unit transfers it over F1-C, and non-access-stratum messages pass transparently to the access function.

### 3.3 Protocol ownership fixes the security boundary

Section 3.2 showed where protocols end. This section draws the consequence for security.

!important[The central unit hosts RRC, SDAP, and PDCP; after separation, control-plane PDCP and RRC sit in the control unit and user-plane PDCP and SDAP in the user unit; the distributed unit hosts RLC, MAC, and PHY. Because ciphering and integrity belong to PDCP and RRC, the distributed unit cannot be the security endpoint merely because protected data crosses it; the behaviour is TS 38.323 and the configuration TS 38.331. Transport protection on F1 or NG is a different control with different endpoints and does not relocate PDCP.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [RAN architecture page](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html) draws the split with the protocol stack of each unit beside it, which is the picture that makes "whoever terminates PDCP terminates ciphering" visible, provided the reader notes where its own diagram is schematic.

### 3.4 Interfaces are named relationships

Section 3.3 named the units. This section names the links between them and insists that each is a relationship with a job.

F1-C links the control unit and the distributed unit for control; F1-U links the user unit and the distributed unit for data; E1 links the two central units for bearer-context control; NG-C reaches the access function and NG-U the user-plane function; Xn-C and Xn-U join access-network nodes. Their application and transport protocols live in companion specifications. A trace records interface instance, direction, transport address, tunnel identifier, and local endpoint; "sent on F1" loses the plane and "sent to the CU" loses which unit.

### 3.5 Contexts and identifiers are local scopes

Links carry contexts. This section explains the identifiers and why each has a scope.

Clause 6.2 defines the application-protocol identities of UE-associated connections: central-side and distributed-side identifiers on F1, control-side and user-side identifiers on E1, and a RAN UE ID to correlate a phone across a disaggregated deployment, each with a declared scope and lifetime. Clause 6.4 distinguishes the UE context in the distributed unit, in the central unit, the bearer context in the user unit, and the logical connections; a bearer context holds the bearers, sessions, and flows a user path needs and is state.

> [!spec] 3GPP reality check
> The F1AP and E1AP identifiers and the RAN UE ID are TS 38.401 clause 6.2; the UE and bearer contexts are clause 6.4; the messages that create them are the UE context procedures of TS 38.473 and the bearer context procedures of TS 38.463.

### 3.6 Architecture and procedure specifications meet at explicit handoffs

The last foundation is where this document stops and the procedure documents begin.

TS 38.300 supplies the wider overview; TS 38.401 refines node and interface relationships and the overall procedures; F1AP, E1AP, NGAP, and XnAP define the messages; TS 38.331 defines RRC and TS 38.323 PDCP. A claim about a field cites the application protocol; a claim about placement cites TS 38.401.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clauses 4–5 establish invariants and plane paths

The walk starts with clauses 4 and 5: the invariants and the two planes.

Clause 4 states the principles: signalling and data transport are logically separated, access and core functions from transport, the access network controls mobility for a connection, interfaces use logical models, and equipment may host several nodes. Clause 5 divides the Uu and NG protocols into user and control structures: the user plane implements the session service; the control plane requests and controls service, resources, handover, and state and carries non-access-stratum messages transparently. Before debugging, classify an observation as user payload, radio control, core-facing control, or transport support.

### 4.2 Clause 6 fixes nodes, terminations, IDs, and associations

Section 4.1 fixed the principles. This section reads clause 6, which fixes nodes, terminations and identifiers.

Clause 6.1.1 defines the overall network: base stations connect to the core over NG and to each other over Xn, and a base station can contain one central unit and several distributed units over F1 while remaining one node to the outside. Clause 6.1.2 adds the control and user separation with F1-C, F1-U, and E1, the control unit selecting user-unit resources and establishing user-unit-to-distributed-unit connectivity through bearer-context management. Clauses 6.1.3 to 6.1.6 extend to backhaul relays, their stacks, multicast, and layer-2 relays, reusing the ownership model with extra contexts. Clauses 6.2 to 6.5 cover identifiers, transport addresses, and associations; keep a correlation table of node, interface, peer identifier, bearer or session, address, tunnel identifier, state, and event rather than treating one number as universal.

> [!spec] 3GPP reality check
> The node graph is [TS 38.401 V18.7.0, clauses 6.1.1 and 6.1.2](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf); the F1-U tunnels carry PDCP PDUs in the NR user-plane protocol of TS 38.425 over GTP-U per TS 38.474.

### 4.3 Clause 7 assigns distributed architecture functions

Section 4.2 built the structure. This section reads clause 7, which distributes functions across it.

Clause 7 describes network functions rather than interface principles: sharing, remote and cross-link interference management, non-public networks, random-access optimisation, positioning, multicast with its switching and shared-tunnel recovery, cell-identity and coverage optimisation, quality-of-experience measurement, and machine-learning support. Several distribute measurement, coordination, and action across units: a distributed unit detects local conditions while a central unit coordinates across its units or peers. "Centralised" does not mean every sample travels to the centre; "distributed" does not mean the radio unit owns the policy.

### 4.4 Clause 8 turns the split into procedures

Section 4.3 assigned functions. This section reads clause 8, where the split becomes procedures.

Clause 8.1 follows initial access across Uu and F1: the distributed unit receives the first RRC message, adds lower-layer context and a cell identity, and transfers it to the central unit, which creates the higher-layer context and returns RRC content through the distributed unit, which relays but never terminates it. Clause 8.2 covers mobility within a central unit, including moves between distributed units that change the lower endpoint while preserving higher context, conditional and lower-layer-triggered mobility, and relay recovery, where delivery status and forwarding matter because moving the radio leg does not erase outstanding PDCP data. Clauses 8.3 to 8.8 cover centralised retransmission, multi-connectivity, F1 startup and cell activation, state transitions, re-establishment, and multiple F1-C transport associations, which is why node, cell, UE-context, and bearer readiness are separate state.

Clause 8.9 combines E1 and F1: initial access with the separation, bearer-context setup over F1-U, release, handover or user-unit change, and later state, trace, relay, and authorisation cases; an E1 success confirms control state, an F1-U tunnel confirms the user path, and neither alone proves end-to-end delivery. Clauses 8.10 to 8.24 add transport associations, sharing, backhaul, drive-test minimisation, multicast, conditional secondary nodes, small data, relays, repeaters, multipath, mobile backhaul, and timing resiliency, so "clause 8" is often too coarse for a test requirement.

> [!spec] 3GPP reality check
> Initial access across the split is TS 38.401 clause 8.1 and, with the control and user separation, clause 8.9.1; the F1 setup, UE context setup, and bearer context setup messages it relies on are TS 38.473 and TS 38.463.

### 4.5 Clauses 9–11 close synchronization and interface scope

Section 4.4 covered the procedures. This section reads clauses 9 to 11, which close synchronisation and interface scope.

Clause 9 covers base-station synchronisation, a prerequisite that does not change the split. Clause 10 names the NG, Xn, F1, E1, and antenna-interface principles as a pointer to the companion specifications. Clause 11.1 covers multiple transport associations for Xn-C. The document extends beyond clause 8 even though its longest procedures are there.

### 4.6 End-to-end diagnostic trace

The walk ends with a diagnostic trace you can apply to any log.

!note[For uplink data, begin at the phone's PDCP entity, then the bearer through its RLC, MAC, and PHY, the receiving distributed-unit context, the F1-U tunnel, the user unit's PDCP and SDAP, and the NG-U transport to the user-plane function; reverse the direction but not the ownership for downlink. A packet seen at the distributed unit has not reached the user unit; one seen at the core has not proved radio delivery. For control, record the RRC transaction at the phone and control-unit endpoints, the distributed unit's transfer role over F1-C, any E1 operation, and the NG-C exchange, correlating F1AP and E1AP identities rather than timestamps, and verifying the first divergent context, tunnel, or sequence state before changing radio parameters.]

## 5. Worked example

Section 4 walked the clauses. Section 5 adds up one split-RAN latency, a calculation you can redo by hand.

### 5.1 Worked numerical example

The example below states what is being computed and between which points.

**What we are working out.** Illustrative one-way split-RAN user-plane latency from a reassembled uplink PDCP PDU at the gNB-DU F1-U ingress to delivery at the UPF-facing edge, including F1-U transport, CU-UP processing, and NG-U/N3 transport.

$$
\begin{aligned}
T_{\mathrm{split,UL}}
&=T_{F1\text{-}U}+T_{CU\text{-}UP}+T_{NG\text{-}U}\\
&=0.35\ \mathrm{ms}+0.20\ \mathrm{ms}+0.70\ \mathrm{ms}\\
&=1.25\ \mathrm{ms}.
\end{aligned}
$$

Here, $T_{\mathrm{split,UL}}$ is the calculated one-way contribution across the declared DU-to-UPF-facing boundary. $T_{F1\text{-}U}=0.35$ ms is an assumed one-way F1-U transport delay from DU to CU-UP. $T_{CU\text{-}UP}=0.20$ ms is an assumed CU-UP processing and local forwarding delay at the user-plane PDCP/SDAP termination. $T_{NG\text{-}U}=0.70$ ms is an assumed one-way NG-U/N3 transport delay from CU-UP toward the UPF. These values are local design inputs.

### 5.2 Variable-value table

Section 5.1 computed the sum. The table below lists every term with its status.

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $T_{\mathrm{split,UL}}$ | 1.25 ms | calculated | local serial sum | DU F1-U ingress to UPF-facing delivery |
| $T_{F1\text{-}U}$ | 0.35 ms | assumed | illustrative transport budget | DU to CU-UP over F1-U |
| $T_{CU\text{-}UP}$ | 0.20 ms | assumed | illustrative processing budget | CU-UP user-plane termination |
| $T_{NG\text{-}U}$ | 0.70 ms | assumed | illustrative transport budget | CU-UP to UPF over NG-U/N3 |

**Dimensional check.** All terms are serial durations in milliseconds, so direct addition is valid. The result deliberately excludes Uu scheduling and transmission, UE processing, DU lower-layer processing before the chosen ingress, queuing outside the local assumptions, retransmissions, UPF processing, and data-network latency. It cannot be called radio latency, PDU-session latency, or end-to-end service latency.

The calculation exposes the figure correction operationally. Removing the CU-UP term would not merely shorten a drawing; it would erase the user-plane PDCP/SDAP termination and its processing budget. A deployment review should measure each segment at its own timestamp boundary and compare the sum only after clocks, directions, load conditions, and percentiles are aligned.

If the measured total exceeds the local budget, first verify packet correlation by bearer and TEID, then compare F1-U transport, CU-UP processing, and NG-U transport separately. A larger total does not prove a radio failure, while a fast F1-U segment does not prove the CU-UP or core-facing path is healthy.

## 6. The 3GPP protocol: which document, and what it says

The example crossed three links. This section names what each clause fixes and draws the terminations and identifiers.

Clause 6 fixes the nodes, links, and identifiers; clause 8 the procedures across them; the messages themselves live in F1AP, E1AP, NGAP, and XnAP. The figure draws where each protocol stops, the links and their protocols, the per-interface identifiers of a phone, the three-context bring-up, and the path of a user packet, and sets each beside the configuration line that declares it and the log line that shows it.

![[99 Attachments/5G/Protocol Figures/STAR-37-TS-38.401-Protocol.png|The NG-RAN split of TS 38.401: nodes, terminations, links, identifiers and context procedures, with the configuration lines each becomes]]

*Protocol figure: The NG-RAN split of TS 38.401: nodes, terminations, links, identifiers and context procedures, with the configuration lines each becomes.*

| Clause | Fixed V18.7.0 scope | Engineering question |
|---|---|---|
| 4 | general principles | which logical and transport separation must remain invariant? |
| 5.1–5.3 | general architecture; user and control planes | which service path is being traced? |
| 6.1 | overall gNB, CU-CP and CU-UP, IAB, MBS, and relay architectures | which node terminates the function? |
| 6.2–6.5 | identifiers, transport addresses, UE and MBS associations | which scoped context correlates the event? |
| 7.1–7.11 | sharing, interference, NPN, RACH optimisation, positioning, MBS, cell identity and coverage, QoE, AI/ML | where are measurement, coordination, and action placed? |
| 8.1–8.9 | initial access, mobility, retransmission, multi-connectivity, startup, state, re-establishment, F1 and E1 procedures | which ordered context transition is active? |
| 8.10–8.24 | Release 18 transport, sharing, IAB, MDT, MBS, SDT, relay, repeater, multipath, mobility, and timing-resiliency procedures | which feature-specific subclause applies? |
| 9 | gNB synchronisation | what timing prerequisite is assumed? |
| 10 | NG, Xn, F1, E1, and antenna-interface principles | which companion interface specification owns the detail? |
| 11.1 | multiple TNL associations for Xn-C | how is Xn-C transport resilience represented? |

The official text is the [TS 38.401 V18.7.0 archive](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf).

!note[**When you build or run a demo.** An open-source base station that supports the split runs as three processes, and their configuration files are clause 6 as addresses: the control unit binds F1-C and E1 and points at the core's access function; the user unit binds F1-U on one side and points at the user-plane function on the other; the distributed unit points at the control unit and lists its cells. Start-up is the graph coming up: an F1 setup from each radio unit, an E1 setup from each user unit, and an NG setup to the core.

A phone's connection is three contexts in order: its first message carried up over F1, a UE context created in the radio unit, and a bearer context created in the user unit with the tunnel identifiers that let packets flow. A phone that connects but passes no data has a bearer context or tunnel that never came up, and the E1 and F1-U logs, correlated by their own identifiers rather than by time, show which. A single-process base station skips all of this and still obeys the same terminations, which is why the split can be added later without changing the phone.]

Release 15 established the main architecture and the split. Release 16 expanded relaying and several optimisation and multi-connectivity contexts. Later releases broadened multicast, small data, relaying, and other branches, and the frozen Release 18 text adds lower-layer-triggered mobility, mobile backhaul, multipath, repeaters, and timing resiliency while preserving the termination split. "Release 18" alone is not provenance: record the specification, exact version, clause, configuration branch, and any corrective delta. The note follows the official document where the navigation extraction is less granular, especially for clauses 7 and 8, which the supplied image labels inaccurately. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states the split; the engineering page gives the vocabulary a deployment uses.

ShareTechnote's [5G RAN Architecture](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html) page is useful for recognising the CU/DU vocabulary, F1, and the deployment questions a split raises, and its value is engineering expression: it helps a reader ask where a split sits and what a trace might show. The fixed TS 38.401 version remains authoritative for logical-node definitions, endpoints, cardinalities, identifiers, and procedure conditions.

Use the tutorial beside the official clause: for each diagram element, annotate protocol termination, peer endpoint, interface plane, context identifier, and direct clause. Reject any secondary diagram that sends user traffic from the distributed unit straight to the user-plane function without a schematic-omission warning, or that assigns PDCP security to the distributed unit.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

In the Saar University 5G course alignment, this Star follows the PHY and Layer-2 specification Stars and turns their protocol layers into deployable logical nodes. Before class, students should distinguish SDAP/PDCP, RLC, MAC, and PHY and review control versus user plane. During class, trace one RRC setup on CU-CP/DU and one data bearer on CU-UP/DU. Afterwards, correlate identifiers across sample F1/E1/NG logs.

The architecture exercise should require two drawings. The control drawing terminates RRC in the CU-CP and reaches the AMF through NG-C/N2. The user drawing terminates user-plane PDCP/SDAP in the CU-UP and reaches the UPF through NG-U/N3. Comparing the drawings exposes why E1 is control coordination rather than a shortcut for user packets.

### 8.1 Supplement: the NAS identities beside the RAN identifiers

The confusions come after the supplements. This one places the NAS identities beside the RAN identifiers of Section 5.

Section 5 followed one UE across F1, E1 and NG identifiers. The NAS side has its own family, and the comic's point is why a permanent number is concealed and then replaced.

![[99 Attachments/5G/Supplement Figures/STAR-37-Saar-UE-Identities.png|PEI, SUPI, SUCI and 5G-GUTI]]

*Supplement figure: The four UE identities PEI, SUPI, SUCI and 5G-GUTI as cards, with the digit structure of SUPI and the two parts of 5G-GUTI drawn beneath.*
*Figure 8.1 — PEI, SUPI, SUCI and 5G-GUTI; SUPI as MCC + MNC + MSIN; 5G-GUTI as GUAMI + 5G-TMSI.*

| Identity | Owner | Issued by | Used |
|---|---|---|---|
| PEI | device | manufacturer | on request |
| SUPI | subscriber, permanent | operator, on the SIM | never in clear over the air |
| SUCI | subscriber, concealed | UE, with the home network's public key | first Registration Request |
| 5G-GUTI | subscriber, temporary | AMF, in Registration Accept | every NAS message afterwards |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 01; 3GPP TS 23.501 clause 5.9.

### 8.2 Supplement: CU, DU, RU and the transport between them

Section 8.1 covered identities. This supplement adds the physical transport between CU, DU and RU.

TS 38.401 defines CU and DU as logical nodes. The training deck adds the physical consequence: three transport segments with different budgets.

![[99 Attachments/5G/Supplement Figures/STAR-37-Saar-CU-DU-Transport.png|CU, DU, RU and the three transport segments]]

*Supplement figure: The gNB split into CU, DU and RU boxes with the F1 and eCPRI interfaces between them, three transport-segment cards for fronthaul, midhaul and backhaul, and notes on bandwidth, deployment and timing.*
*Figure 8.2 — CU, DU and RU with F1 and eCPRI between them; fronthaul, midhaul and backhaul budgets.*

| Segment | Between | Latency | Distance | Character |
|---|---|---|---|---|
| Fronthaul | RU ↔ DU | ≈ 100 µs | 1–2 km | eCPRI, point to point |
| Midhaul | DU ↔ CU | < 3 ms | 40–80 km | one CU per 300–500 sites |
| Backhaul | CU ↔ core | per service | ≤ 200 km | statistical multiplexing |

Source: Supplementary material, *5G key technologies and applications* (training deck, 2018), slides 92–94; 3GPP TS 38.401, TS 38.470.

## 9. Common confusions

The six sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “The DU performs PDCP ciphering and integrity termination”

!warning[The DU hosts RLC, MAC, and PHY. User-plane PDCP terminates in the CU-UP; control-plane PDCP terminates in the CU-CP. Transport security at a DU does not change that radio-protocol ownership.]

### 9.2 “The user path is UE → DU → UPF”

!warning[That drawing omits the CU-UP. The split-gNB path includes UE radio processing, DU lower layers, F1-U to CU-UP PDCP/SDAP, and NG-U/N3 toward UPF. Record the omitted node whenever using a simplified topology.]

### 9.3 “E1 carries the ordinary user packets”

!warning[E1 connects CU-CP and CU-UP for control of bearer contexts. The ordinary CU-UP–DU data leg is F1-U, while core-facing user data uses NG-U/N3. Do not identify a plane solely from the word “UP” in a node name.]

### 9.4 “One UE identifier is global across F1 and E1”

!warning[F1AP and E1AP use peer-specific identifiers with defined scopes. Use RAN UE ID and explicit correlation state where applicable; never join records only because two numeric fields match.]

### 9.5 “A successful F1 setup proves the data bearer works”

!warning[Node/interface setup, cell activation, UE context, E1 bearer context, F1-U tunnel, NG-U transport, and radio delivery are distinct gates. Verify the first failed gate and its owner.]

### 9.6 “TS 38.401 defines every application-protocol field”

!warning[TS 38.401 defines architecture and overall procedures. F1AP, E1AP, NGAP, XnAP, RRC, PDCP, and transport specifications own executable details. Cite the architecture clause and the companion message clause together.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.401 V18.7.0: NG-RAN; Architecture description*, clauses 4–11, [official direct archive](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf).
2. Clause map of this knowledge base for TS 38.401 V18.7.0.
4. 3GPP, *TS 38.300 V18.10.0: NR and NG-RAN overall description*, [official direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
5. 3GPP, *TS 38.323 V18.5.0: Packet Data Convergence Protocol*, [official direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip).
6. 3GPP, *TS 38.331 V18.10.0: Radio Resource Control protocol specification*, [official direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).
7. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm) and [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
8. ShareTechnote, [5G RAN Architecture](https://www.sharetechnote.com/html/5G/5G_RAN_Architecture.html), accessed 2026-08-03.
9. Saar University 5G course alignment.
10. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

All external links above occur earlier in the explanatory body. The direct 3GPP archives are official inputs, the clause map and the course crosswalk are navigation aids of this knowledge base, ShareTechnote is engineering expression, and the ledger records the reuse/correction decision.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| 5GC | Fifth Generation Core network | This is the core-network system reached through NG. It is outside the DU/CU split. | Section 2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| AI/ML | Artificial Intelligence/Machine Learning | Clause 7.11 describes NG-RAN support for these functions. It does not relocate radio protocols. | Section 4.3; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| AMF | Access and Mobility Management Function | This is the 5GC control-plane peer reached over NG-C/N2. It does not carry the ordinary user packet path. | Section 3.2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| CU | Central Unit | This is the centralized logical part of a split gNB. It can be further separated into CU-CP and CU-UP. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| DRB | Data Radio Bearer | A DRB carries user-plane data under configured treatment. Its context crosses architecture procedures but its PDCP endpoint remains in the CU-UP. | Section 3.5; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| DU | Distributed Unit | This logical node hosts RLC, MAC, and PHY. It does not terminate PDCP. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| E1 | Interface between CU-CP and CU-UP | This interface connects CU-CP and CU-UP for control. It is not the normal user-packet data leg. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| F1-C | F1 Control-plane interface | This interface connects CU-CP and DU. It carries CU/DU control relationships and transferred RRC content. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| F1-U | F1 User-plane interface | This interface connects CU-UP and DU. It carries the split-gNB user-plane leg. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| gNB | next-generation NodeB | This is an NG-RAN logical node. Its CU/DU internals remain externally visible as one gNB at the architecture boundary. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| gNB-CU-CP | gNB Central Unit Control Plane | This node hosts RRC and control-plane PDCP. It controls DU and CU-UP context through F1-C and E1. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| gNB-CU-UP | gNB Central Unit User Plane | This node hosts user-plane PDCP and SDAP. It lies on the real UE-to-UPF user path. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| gNB-DU | gNB Distributed Unit | This node hosts RLC, MAC, and PHY and supports cells. It terminates F1 toward the CU functions. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| IAB | Integrated Access and Backhaul | IAB reuses radio resources and adds backhaul topology. It is a clause-6/8 branch rather than the baseline one-hop path. | Section 4.2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| MAC | Medium Access Control | MAC is a lower-layer protocol hosted by the DU. It schedules and multiplexes radio resources under the wider configuration. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| MBS | Multicast Broadcast Service | MBS adds session and bearer associations plus shared transport options. Its procedures do not redefine the ordinary unicast path. | Section 4.2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| MDT | Minimization of Drive Tests | MDT distributes trace and measurement activation/reporting across nodes. It appears in the clause-8 procedure family. | Section 4.4; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| NAS | Non-Access Stratum | NAS control is transparently transported through NG-RAN. Its endpoint is in the UE/core relationship. | Section 3.2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| NG-RAN | Next Generation Radio Access Network | This is the access network containing gNBs and related nodes. TS 38.401 defines its logical architecture. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| NG-U | NG User-plane interface | This is the core-facing user-plane side of NG. With N3 terminology, it connects the RAN user plane toward the UPF. | Section 2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| PDCP | Packet Data Convergence Protocol | PDCP terminates in CU-UP for user plane and CU-CP for control plane. Its placement fixes the radio security-processing boundary. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| PHY | Physical layer | PHY processes the radio waveform and is hosted in the DU side of the stated split. It is below MAC and RLC. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| QoE | Quality of Experience | RAN-visible QoE measurement support is described in clause 7.10. QoE evidence is not identical to a QoS configuration. | Section 4.3; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| QoS | Quality of Service | QoS flows are mapped into radio and bearer contexts. The CU-UP hosts SDAP for the gNB user plane. | Section 3.5; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| RLC | Radio Link Control | RLC is hosted by the DU. Its segmentation/retransmission role is distinct from PDCP security and reordering. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| RRC | Radio Resource Control | RRC terminates in the CU-CP. A DU transfers RRC messages without becoming their RRC endpoint. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| SDAP | Service Data Adaptation Protocol | SDAP maps QoS flows to data radio bearers. In a gNB user plane it is hosted by the CU-UP. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| TEID | Tunnel Endpoint Identifier | A TEID identifies a tunnel endpoint in the applicable transport context. It is not a global UE identity. | Section 4.2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| TNL | Transport Network Layer | The TNL provides signalling or data transport for logical interfaces. Collocation does not erase its logical role. | Section 3.1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| UE | User Equipment | The UE is the radio endpoint. Its peer protocol entities terminate in different gNB logical nodes according to layer. | Section 1; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| UPF | User Plane Function | The UPF is the 5GC user-plane peer reached through NG-U/N3. It is not directly attached to the DU in the split path. | Section 2; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| Xn-C | Xn Control-plane interface | This interface carries control relationships between NG-RAN nodes. Clause 11.1 addresses multiple TNL associations for it. | Section 3.4; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| Xn-U | Xn User-plane interface | This interface can support inter-node user-plane forwarding. It does not replace F1-U inside a split gNB. | Section 3.4; [official TS 38.401](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |
| PEI | Permanent Equipment Identifier | The PEI identifies the device hardware. | Section 8; Supplement |
| SUPI | Subscription Permanent Identifier | The SUPI is the permanent subscriber identity issued on the SIM. It is never sent in clear over the air. | Section 8; Supplement |
| SUCI | Subscription Concealed Identifier | The SUCI is the SUPI encrypted with the home network's public key. | Section 8; Supplement |
| 5G-GUTI | 5G Globally Unique Temporary UE Identity | The 5G-GUTI is the temporary identity the AMF allocates in Registration Accept. | Section 8; Supplement |
| GUAMI | Globally Unique AMF Identifier | The GUAMI is the first part of the 5G-GUTI and names the serving AMF. A new AMF uses it to find the old one. | Section 8; Supplement |
| 5G-TMSI | 5G Temporary Mobile Subscriber Identity | The 5G-TMSI is the second part of the 5G-GUTI. It is unique only inside the allocating AMF. | Section 8; Supplement |
| MCC | Mobile Country Code | The MCC is the three-digit country part of a SUPI or PLMN identity. | Section 8; Supplement |
| MNC | Mobile Network Code | The MNC is the two- or three-digit operator part of a SUPI or PLMN identity. | Section 8; Supplement |
| MSIN | Mobile Subscriber Identification Number | The MSIN is the subscriber-specific part of an IMSI-form SUPI. It is the only part the SUCI encrypts. | Section 8; Supplement |
| RU | Radio Unit | The RU holds the low physical layer and the radio front end. | Section 8; Supplement |
| AAU | Active Antenna Unit | An AAU integrates the antenna array with its transceivers and amplifiers. | Section 8; Supplement |
| RRU | Remote Radio Unit | An RRU is a radio front end mounted near a passive antenna. | Section 8; Supplement |
| BBU | Baseband Unit | A BBU is the integrated baseband cabinet of a 4G site. | Section 8; Supplement |
| eCPRI | enhanced Common Public Radio Interface | eCPRI is the packetised fronthaul interface between the DU and the RU. It carries sampled signals with a latency budget near 100 microseconds. | Section 8; Supplement |
| MEC | Multi-access Edge Computing | MEC places application servers at the edge of the transport network. | Section 8; Supplement |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit/domain | Role |
|---|---|---|---|
| $T_{\mathrm{split,UL}}$ | One-way local split-RAN contribution from DU F1-U ingress to UPF-facing delivery | ms | calculated output |
| $T_{F1\text{-}U}$ | One-way DU-to-CU-UP transport delay | ms | assumed input |
| $T_{CU\text{-}UP}$ | CU-UP processing and local forwarding delay | ms | assumed input |
| $T_{NG\text{-}U}$ | One-way CU-UP-to-UPF transport delay | ms | assumed input |

Each delay uses one direction and one declared timestamp boundary. A different percentile, clock domain, load, retransmission condition, or measurement plane requires a new ledger entry rather than silent symbol reuse.
