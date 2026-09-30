---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 22
title: Integrated Access Backhaul
language: en
course_units: []
release_baseline: 18
---

# STAR-22 — Integrated Access Backhaul

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Every cell needs a link back to the network, the backhaul. Fibre cannot reach every lamp post, and digging it to every small cell is the cost that kills dense deployment. Integrated access and backhaul lets a small cell reach the network by radio, through another small cell, and each hop is ordinary NR. Picture a chain of lanterns: the first is fed by fibre, and each one after it is lit by the one before.

![[99 Attachments/5G/Concept Figures/STAR-22-Integrated-Access-Backhaul-Concept.png|Integrated access and backhaul explained as a chain of lanterns]]

*Concept figure: Integrated access and backhaul explained as a chain of lanterns.*

Each relay node has two faces. Its mobile-terminal face joins its parent exactly as a phone would: cell search, random access, a grant. Its distributed-unit face serves its children exactly as a tower would. The brain, the central unit, stays at the donor with the fibre, and every distributed unit in the chain talks to it as if the hops were not there. Nothing new is needed above the radio link except a thin layer that stamps every packet with a routing identity, so that each node can tell "mine, pass it up" from "not mine, forward it to the next hop".

The one hard problem is that a node cannot shout and listen at once on the same frequency: its tower face transmitting deafens its phone face receiving. So the node's time is divided into slots the tower face owns outright, slots it may use only if the parent is not talking to it, and slots it may not use. The parent releases the conditional slots with a short control message when it has nothing to say. IAB works best at millimetre waves because the nodes do not move, so they can hold narrow, high-gain beams at each other, and because there is enough bandwidth there to give some away to backhaul.

**The question this chapter answers.** What changes when the backhaul link is carried by the access radio itself, and how does a relay node avoid interfering with its own reception?

!important[**The short answer.** An IAB node combines a mobile-terminal function toward its parent with a distributed-unit function toward its children, with the central unit at the donor. A backhaul adaptation protocol routes packets across hops by a routing identity. Because a node cannot transmit and receive on one frequency at once, its distributed-unit resources are classified as hard, soft, or unavailable, and the parent indicates the availability of soft resources dynamically with DCI format 2_5. Timing is aligned over the air from the timing advance and a delta the parent supplies.]

Names you will meet in this note: integrated access and backhaul (IAB), central and distributed unit (CU, DU), mobile termination (MT), backhaul adaptation protocol (BAP), F1 interface, line of sight and non-line of sight (LOS, NLOS), hard, soft and not-available resources (H, S, NA), availability indicator (AI).

## 2. Where you are in 5G

Section 1 replaced fibre with radio for a small cell's backhaul. The map below shows where integrated access and backhaul sits in 5G: a base station that is also a phone, hanging off another base station.

![[99 Attachments/5G/Locator Maps/STAR-22-Where-You-Are-in-5G.png|Where Star 22 sits in the whole 5G system]]

*Locator: Where Star 22 sits in the whole 5G system.*

This chapter lights the architecture band where the CU/DU split of Star 06 is reused for a wireless hop. Its mobile-terminal face runs the cell search of Star 16 and the random access of Star 17; its timing rule extends Star 15; its beams are Star 12 at millimetre waves, Star 26. It is a Release 16 chapter, placed among the others in Star 27.

The Knowledge Structure Map draws the architecture and its resource rules. The mechanism diagram traces one packet across the multi-hop data path.

![[99 Attachments/5G/Knowledge Maps/STAR-22-Integrated-Access-Backhaul-Knowledge Structure Map.png|STAR-22 system-position map]]

*Knowledge map: An integrated access and backhaul tree with each relay node split into its two halves.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-22-IAB-Multi-Hop-Data-Path.png|Star 22 mechanism and handoff diagram]]

*Mechanism: How one IAB node partitions its time between its two halves.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Introduction → 22.4 The IAB Link.


## 3. The textbook road

Section 2 placed the relay. The road below walks through the chapter in the book's order: the architecture, spectrum and initial access first, then the IAB link itself and how a node shares its two halves.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Introduction**

The road begins with what an IAB node is and which parts of NR it reuses without change.

!important[Introduced in Release 16, integrated access and backhaul lets NR carry not only the access link between base station and device but the backhaul link between base stations. Wireless backhaul used to rely on proprietary technology in high millimetre-wave bands and strict line of sight. Two things changed: NR itself now uses millimetre waves for access, so reusing it for backhaul is natural; and street-level small cells need backhaul that survives non-line-of-sight, which NR was designed for. Figure 22.1 shows donor nodes on fibre and IAB nodes reaching them wirelessly while serving their own users.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.1 shows donor nodes on fibre and IAB nodes reaching them wirelessly while serving their own users.*

#### 3.1.1 **22.1 IAB Architecture**

The architecture is the CU/DU split. The donor node has fibre and holds a central unit and a distributed unit. An IAB node holds a mobile termination, which connects to the parent and looks like a phone to it, and a distributed unit, which serves its children and looks like a base station to them. The F1 interface between the donor's central unit and every distributed unit, even those several wireless hops away, is unaware of the hops. Figure 22.2 shows the structure, with the mobile-termination side facing the donor and the distributed-unit side facing the devices.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.2 shows the structure, with the mobile-termination side facing the donor and the distributed-unit side facing the devices.*

Figure 22.3 shows three hops: node 3 connects to node 2, which connects to node 1, which connects to the donor, and every distributed unit terminates at the one central unit.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.3 shows three hops: node 3 connects to node 2, which connects to node 1, which connects to the donor, and every distributed unit terminates at the one central unit.*

One new protocol, the backhaul adaptation protocol, routes packets across the hops by adding a header with a routing identity. Figures 22.4 and 22.5 show the user-plane and control-plane stacks with that layer above RLC: it reads the routing identity, passes the packet up to IP if it is for this node, and otherwise forwards it on the right egress link.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 22.4 and 22.5 show the user-plane and control-plane stacks with that layer above RLC: it reads the routing identity, passes the packet up to IP if it is for this node, and otherwise forwards it on the right egress link.*

#### 3.1.2 **22.2 Spectrum for IAB**

IAB works in any NR spectrum but focuses on millimetre waves for two reasons: the bandwidth there makes it easier to set capacity aside for backhaul, and stationary nodes allow very precise, high-gain beamforming to overcome the path loss. Out-of-band backhaul uses a different frequency from access and avoids interference; in-band backhaul shares the frequency and must manage it.

> [!important] 💡
> **mmWave Attenuation & Range — Q1: In 22.2, backhaul is using mmWave; is there any improvement to solve the mmWave problems in this scenario?**
> mmWave suffers high attenuation and blockage. The text names two improvements:
> **Massive beamforming:** "Massive beamforming enabled at higher frequencies is especially beneficial for the wireless-backhaul scenario with stationary nodes." Since IAB nodes are fixed, they can use large antenna arrays to create very narrow, high-gain beams. This focusing extends range and punches through attenuation better than omnidirectional signals.
> **Multi-hop architecture:** if the distance is too long for one hop, IAB natively supports multi-hop backhauling. You do not need to reach the donor in one go; you can hop through intermediate nodes (node 1 → node 2 → donor), keeping each link short and robust.

#### 3.1.3 **22.3 Initial Access of an IAB Node**

When an IAB node switches on, its mobile-termination side behaves as a phone: it performs cell search and random access. Because such nodes may be farther away than phones and switch on rarely, the network can broadcast a separate IAB-specific random-access configuration with longer preambles for coverage and less frequent occasions.

> [!important] 💡
> **Security in IAB Initial Access**
> **Issue:** potential vulnerabilities introduced by the wireless backhaul and the initial-access procedure of IAB nodes.
> - **Interference and jamming:** since the IAB node acts as a UE during initial access, it is vulnerable to the same physical-layer attacks. If an attacker jams the preamble or the synchronisation signals, the node cannot connect, and if the node fails, all child nodes and users connected to it lose connectivity (cascading failure).
> - **Fake base station (rogue parent):** the MT connects to a parent. A fake base station could attract it; mutual authentication usually prevents a full connection, but the initial handshake could still be disrupted.
> - **Routing attacks:** since IAB relies on BAP for routing, a compromised node could inject malicious headers, misrouting traffic or creating loops, though the donor CU configures the routing tables, creating a centralised point of trust.

> [!book] Book expansion
> The access sequence is the architectural bridge: a node first behaves as a mobile termination toward its parent and later exposes a distributed unit toward its children. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 22, pp. 443–456, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00022-2).

> [!spec] 3GPP reality check
> The architecture, roles, and topology are [TS 38.300 V18.10.0, clause 4.7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip); the backhaul adaptation protocol is TS 38.340; the mobile termination's cell search and random access are owned by the ordinary physical-layer and MAC specifications.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [IAB page](https://www.sharetechnote.com/html/5G/5G_IAB.html) draws the protocol stacks hop by hop, which is the clearest way to see where the backhaul adaptation layer sits and where F1 terminates.

### 3.2 **22.4 The IAB Link**

Section 3.1 built the node; this section builds the link between a parent and a child, and asks how the child aligns its own transmissions.

The link between a parent's distributed unit and a child's mobile termination is the IAB link. The node must align its own transmissions, and it does so over the air, estimating propagation delay from signals exchanged with the parent. Figure 22.6 shows the child computing the delay by comparing its transmit and receive times with an offset the parent supplies.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.6 shows the child computing the delay by comparing its transmit and receive times with an offset the parent supplies.*

#### 3.2.1 **22.4.2 DU/MT Coordination and Configuration**

!important[In-band, a node cannot transmit and receive at once on the same frequency without severe self-interference, so the mobile termination listening to the parent and the distributed unit talking to children must coordinate. Distributed-unit resources are hard, always usable, with the mobile termination expecting nothing; or soft, usable only when they do not conflict with the mobile termination, and released explicitly by the parent with DCI format 2_5. Figure 22.7 shows the two harmful cases: the distributed unit transmitting while the mobile termination receives, and the reverse.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.7 shows the two harmful cases: the distributed unit transmitting while the mobile termination receives, and the reverse.*

#### 3.2.2 **Simultaneous DU/MT Operations**

The two halves may operate simultaneously in the same direction: both transmitting, the distributed unit to children and the mobile termination to the parent, or both receiving. Figure 22.8 shows both modes, which avoid the receiver desensitisation of opposing directions but still require resource separation.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.8 shows both modes, which avoid the receiver desensitisation of opposing directions but still require resource separation.*

Separation is in frequency or in space. Figure 22.9 shows spatial separation: different antenna panels pointing in different directions transmit to the parent and to the device at once, or receive from both, which requires good isolation between the panels.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.9 shows spatial separation: different antenna panels pointing in different directions transmit to the parent and to the device at once, or receive from both, which requires good isolation between the panels.*

#### 3.2.3 **Resource Configuration and "Soft" Resources**

Mobile-termination resources are configured as downlink, uplink, or flexible, like a phone's. Distributed-unit resources carry the same three directions plus a second label. Hard means the distributed unit is guaranteed the resource and the parent assumes the mobile termination cannot communicate then. Soft means the distributed unit may use it only if that does not conflict with the mobile termination, so that when the mobile termination is not scheduled the distributed unit reclaims the capacity.

#### 3.2.4 **Explicit Availability Indication (DCI Format 2_5)**

The parent controls the child's soft resources with DCI format 2_5, which points to a row of a pre-configured table of availability combinations. Figure 22.10 shows the parent sending an index that selects a row telling the node which soft slots its distributed unit may use.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 22.10 shows the parent sending an index that selects a row telling the node which soft slots its distributed unit may use.*

> [!important] 💡
> **Is IAB Frequent in Real Networks?**
> Q2: Is IAB a frequent mechanism in the real 5G network?
> - **Conceptually common:** the need is common. Digging fibre to every lamp post for small cells is prohibitively expensive and slow, and wireless backhaul is the logical solver.
> - **Deployment reality:** the standard is ready (Rel-16), but widespread commercial deployment is still ramping up.
> - **Pros:** reusing the standardised cellular technology enables lower cost than proprietary microwave links.
> - **Cons:** it needs mmWave spectrum to be truly effective, and mmWave coverage is still being built out.
> - **Verdict:** a key tool for densification and rapid deployment (emergency networks, temporary venues) where wired backhaul is impossible, while fibre remains the gold standard for high-capacity macro towers.

> [!spec] 3GPP reality check
> The hard, soft, and unavailable resource rules and the over-the-air timing are [TS 38.213 V18.8.0, clause 14](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); DCI format 2_5 is TS 38.212 clause 7.3.1.3.6; the parent's timing delta travels in a MAC control element of TS 38.321.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: an architecture clause, a routing header and one resource-availability message.

IAB is an architecture clause, a routing header, and one resource-availability control message. TS 38.300 names the roles and says F1 terminates at the donor. TS 38.340 defines the backhaul adaptation header, a ten-bit address and a ten-bit path, and the forwarding rule. TS 38.213 clause 14 writes down the hard, soft, and unavailable rule and the over-the-air timing. TS 38.212 defines the availability indication, and the F1 application protocol carries the resource configuration from the central unit. The figure draws each with its clause and the configuration lines it becomes.

![[99 Attachments/5G/Protocol Figures/STAR-22-Integrated-Access-Backhaul-Protocol.png|The IAB architecture, the backhaul adaptation header and the resource-availability signalling, with their clauses and configured values]]

*Protocol figure: The IAB architecture, the backhaul adaptation header and the resource-availability signalling, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.300 | V18.10.0, [38300-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | 4.7 | IAB architecture, topology, and signalling context |
| TS 38.340 | V18.2.0, [38340-i20.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.340/38340-i20.zip) | 4.2; 5.2 | BAP entities and data transfer |
| TS 38.212 | V18.8.0, [38212-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.3.1.3.6 | DCI format 2_5 |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 14 | IAB physical procedures and resource behaviour |
| TS 21.918 | V18.0.0, [21918-i00.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | 27.3 | mobile-IAB evolution |

!note[**When you build or run a demo.** An IAB demo is two base stations and a relay, and the relay's mobile termination must first appear in the parent's log as an ordinary connecting phone, which is the first checkpoint. The backhaul address and the routing table are what the donor's central unit pushes to each node, and a packet that vanishes between hops is almost always a routing entry. The distributed-unit resource pattern, a list of hard, soft, and unavailable slots, and the availability-combination table with its indicator identity are the lines that decide whether the relay ever serves its own cell. The timing delta in the log, next to the timing advance, is how the relay learnt where it is. Open-source support for IAB is early; expect to read TS 38.213 clause 14 alongside the configuration.]

Release 15 established NR access and the split architecture on which IAB builds; standardised IAB is Release 16, with donor and node roles, the backhaul adaptation protocol, topology management, and resource coordination. Release 17 refined topology, duplexing, and operation. Release 18 adds mobile IAB, where the relay itself may move, which intensifies parent selection, route maintenance, and service continuity without turning fixed deployments into mobile ones. Release summaries are checked against TS 21.916 and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the hops; this trace computes the payload rate that two hops with different airtime shares can deliver.

**What we are working out.** End-to-end payload-rate upper bound when two required hops receive different airtime shares.

**Worked numerical example.** Compare the two time-weighted hop service rates and select the bottleneck.

Assume hop 1 has link capacity 1.2 Gb/s and receives 50% of usable time. Hop 2 has link capacity 1.5 Gb/s and receives 40% of usable time. Ignore headers, retransmissions, interference variation, and spatial reuse. Every packet must cross both hops, so the slower time-weighted service rate is the bottleneck:

$$
\begin{aligned}
R_{\mathrm{end}} &= \min(\alpha_1 C_1,\alpha_2 C_2) \\
&= \min(0.50\times1.2,\ 0.40\times1.5)\ \mathrm{Gb/s} \\
&= \min(0.60,\ 0.60)\ \mathrm{Gb/s} \\
&= 0.60\ \mathrm{Gb/s}.
\end{aligned}
$$

Here $R_{\mathrm{end}}$ is the end-to-end rate bound in Gb/s, $\alpha_1$ and $\alpha_2$ are dimensionless airtime shares, $C_1$ and $C_2$ are hop capacities in Gb/s, and Gb/s means gigabits per second.

The equality of the two terms is accidental to the chosen numbers. Giving more time only to hop 1 would not raise end-to-end throughput if hop 2 remained at 0.60 Gb/s. Real schedulers also serve local access traffic, account for control overhead, retransmissions, queueing, and directional conflicts, and may reuse resources on sufficiently isolated links. The example is an upper bound teaching model.

**Sanity check.** The end-to-end rate cannot exceed either required hop's time-weighted rate, so the minimum operation has the correct limiting behavior.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $R_{\mathrm{end}}$ | End-to-end payload-rate upper bound | 0.60 | Gb/s | Derived model |
| $C_1$ | Instantaneous capacity of hop 1 | 1.2 | Gb/s | Assumed |
| $C_2$ | Instantaneous capacity of hop 2 | 1.5 | Gb/s | Assumed |
| $\alpha_1$ | Usable-time share of hop 1 | 0.50 | dimensionless | Assumed scheduler share |
| $\alpha_2$ | Usable-time share of hop 2 | 0.40 | dimensionless | Assumed scheduler share |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** The current Course Alignment has no direct unit mapping for Chapter 22. IAB works best as an architecture-and-scheduling case study after students understand gNB functional splits, initial access, beams, and time-frequency scheduling. It can also prepare later work on wireless transport resilience.

For assessment, give a three-hop topology and ask students to label CU, donor DU, each MT/DU pair, F1 traffic, BAP forwarding, and the resource conflict at one half-duplex node. The goal is to prevent a “wireless repeater” mental model.

> “In 22.2, backhaul is using mmwave... is there any improvement to solve this mmwave using scenario?”

!warning[Directional arrays, beam management, short planned hops, multi-hop routing, alternate parents, and topology adaptation improve link budget and resilience. They do not make arbitrary obstacles transparent. Site geometry and route diversity remain essential; lower-frequency or wired alternatives may be needed where blockage cannot be managed.]

> What are the security risks during IAB initial access, including jamming, a rogue parent, and the BAP trust boundary?

!warning[Jamming can prevent acquisition or degrade a backhaul link. A candidate parent is not trusted merely because its synchronization signal is strong; authenticated network access and operator credentials establish admission at higher layers. BAP operates within the operator's IAB domain and forwards configured traffic, but it is not itself a public proof of endpoint identity. Monitoring, certificate/key management, allowed-parent policy, and transport security complete the deployment boundary.]

> “Is IAB a frequent mechanism in the real 5G network?”

!warning[3GPP availability does not imply universal deployment. IAB is attractive where fiber is slow or costly and suitable radio paths exist, but prevalence varies by operator, spectrum, regulation, site density, hardware, and economics. A standards document can prove interoperability scope.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 22, pp. 443–456, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00022-2).
2. 3GPP TS 21.916 V16.2.0, clause 19.1.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
3. 3GPP TS 38.300 V18.10.0, clause 4.7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
4. 3GPP TS 38.340 V18.2.0, clauses 4.2 and 5.2. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.340/38340-i20.zip).
5. 3GPP TS 38.212 V18.8.0, clause 7.3.1.3.6. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
6. 3GPP TS 38.213 V18.8.0, clause 14. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
7. 3GPP TS 21.918 V18.0.0, clause 27.3. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
8. ShareTechnote, “5G/NR — IAB,” accessed 2026-08-03. [Direct page](https://www.sharetechnote.com/html/5G/5G_IAB.html).
9. Course Alignment, local course crosswalk, accessed 2026-08-03.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BAP | Backhaul Adaptation Protocol | Hop-by-hop routing and bearer-mapping protocol for IAB. | Section 1; [TS 38.340](https://www.3gpp.org/ftp/Specs/archive/38_series/38.340/38340-i20.zip) |
| CU | Central Unit | Centralized NG-RAN protocol entity. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| DCI | Downlink Control Information | Physical control information, including IAB availability format 2_5. | Section 1; [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| DU | Distributed Unit | Radio-facing gNB function serving access/backhaul. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| F1 | Interface between CU and DU | Logical interface whose traffic can traverse IAB. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| gNB | Next Generation Node B | NR base station. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| IAB | Integrated Access and Backhaul | NR access plus multi-hop wireless backhaul. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| MT | Mobile Termination | UE-like upstream function of an IAB node. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| NR | New Radio | 3GPP 5G radio access technology. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |
| UE | User Equipment | Access endpoint served by an IAB-DU. | Section 1; [TS 38.300](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $R_{\mathrm{end}}$ | End-to-end payload-rate upper bound | bit/s |
| $C_1$, $C_2$ | Instantaneous capacities of hops 1 and 2 | bit/s |
| $\alpha_1$, $\alpha_2$ | Usable-time fractions allocated to the hops | dimensionless |
| Gb/s | Gigabits per second | $10^9$ bit/s |
