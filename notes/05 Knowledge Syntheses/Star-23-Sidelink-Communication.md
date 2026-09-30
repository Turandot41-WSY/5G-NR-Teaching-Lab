---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 23
title: Sidelink Communication
language: en
course_units: []
release_baseline: 18
---

# STAR-23 — Sidelink Communication

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Everything so far went phone to tower to phone. Sidelink is phone to phone: faster, because there is one hop instead of two, and possible where there is no tower at all, in a tunnel, a desert, or a disaster area. Two trucks in a platoon exchange braking data this way. But someone still has to decide who speaks when, and that is what the chapter is about.

![[99 Attachments/5G/Concept Figures/STAR-23-Sidelink-Communication-Concept.png|Sidelink communication explained as talking to the car beside you without the tower]]

*Concept figure: Sidelink communication explained as talking to the car beside you without the tower.*

There are two ways to share the air. In mode 1 the tower still hands out turns: car A asks for one, the tower grants a slot, and A uses it to talk to car B rather than to the tower. That is the uplink grant of Star 14 pointed sideways, with low collision risk and a need for coverage. In mode 2 there is no tower, or none that helps. Every car listens for about a second to hear who has booked what, picks a slot nobody claimed, and writes in its own header "I am using this one, and I book that one too". Collisions happen; the reservation note is what keeps them rare.

Three details follow from the missing tower. The control header comes in two halves: a public half in a fixed format that says which resources are taken and booked, which everyone reads to sense the air, and a private half that rides with the data and says who it is for and how it is coded. The clock is passed hand to hand: a car that sees a tower or GPS broadcasts a small sidelink synchronisation block and becomes a lantern for cars that see nothing else, with a priority order from GPS or tower, to an in-coverage car, to one hop further out. And every packet starts with a throwaway symbol: a tower's volume changes slowly, but sidelink packets arrive from a car ten metres away and then one five hundred metres away a millisecond apart, so the first symbol is a copy of the second, spent on setting the receiver's gain. The key fact to carry is that removing the tower from the data path moves every decision it used to make, who, when, how loud, what time it is, onto the cars.

**The question this chapter answers.** What has to change when there is no base station in the data path, and how do devices divide a shared channel, acknowledge each other, and agree on a clock?

!important[**The short answer.** Sidelink defines its own physical channels for control, data, feedback, and broadcast, drawn from configured resource pools. Resource allocation is either granted by the network (mode 1) or chosen by the device through sensing and announced reservations (mode 2). Control information is split into a public first stage for sensing and a private second stage for the addressee. Feedback adapts to unicast, groupcast, and broadcast. Synchronisation follows a priority chain from GNSS or a base station through in-coverage devices to those beyond.]

Names you will meet in this note: vehicle-to-everything (V2X), physical sidelink control, shared, feedback, and broadcast channels (PSCCH, PSSCH, PSFCH, PSBCH), sidelink control information (SCI), sidelink synchronisation signal block (S-SSB), automatic gain control (AGC), global navigation satellite system (GNSS), resource pool, subchannel.

## 2. Where you are in 5G

Section 1 let two phones talk without a tower. The map below shows where sidelink sits in 5G: a separate link on the phone side, with its own channels and its own clock.

![[99 Attachments/5G/Locator Maps/STAR-23-Where-You-Are-in-5G.png|Where Star 23 sits in the whole 5G system]]

*Locator: Where Star 23 sits in the whole 5G system.*

This chapter lights sidelink at the edge of the procedures band, where the radio link of Star 07 is reused between devices. Mode 1 is the scheduler of Star 14; the sidelink synchronisation block is a cousin of the cell-search block of Star 16; the feedback channel echoes Star 13; and the sensing algorithm has the flavour of the listen-before-talk of Star 19. It is a Release 16 chapter, placed among the others in Star 27.

The Knowledge Structure Map draws the channels, procedures, and synchronisation on one map. The mechanism diagram traces one packet through the resource chain.

![[99 Attachments/5G/Knowledge Maps/STAR-23-Sidelink-Communication-Knowledge Structure Map.png|STAR-23 system-position map]]

*Knowledge map: The two questions sidelink has to answer, and what was invented to answer them.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-23-NR-Sidelink-Resource-Chain.png|Star 23 mechanism and handoff diagram]]

*Mechanism: Mode 2 sidelink resource selection drawn on the resource pool.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Introduction → 23.1 NR Sidelink-Transmission and Deployment Scenarios → 23.2 Resources for Sidelink Communication → 23.3 Sidelink Physical Channels → 23.4 Sidelink Procedures.


## 3. The textbook road

Section 2 placed sidelink beside the ordinary link. The road below walks through the chapter in the book's order: scenarios, resources, physical channels, procedures, then synchronisation.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Introduction**

The road begins with what sidelink is, where it came from and what Release 16 aimed it at.

!important[Sidelink, or device-to-device communication, lets devices talk directly without passing data through a base station. It appeared in LTE Release 12 and was expanded for NR in Release 16 with a focus on vehicle-to-everything: platooning, extended sensors, and advanced driving.]

> [!book] Book expansion
> Chapter 23 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 457–478, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00023-4)) builds sidelink out of the uplink: the same waveform, a mirrored channel set, and a scheduler that is either the network or the device itself.

> [!spec] 3GPP reality check
> The Release 16 sidelink work is summarised in [TS 21.916 V16.2.0, clause 8.4](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip); the physical layer is clause 8 of TS 38.211, 38.212, and 38.214 and clause 16 of TS 38.213.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [sidelink page](https://www.sharetechnote.com/html/5G/5G_SideLink.html) draws the channel layout inside a sidelink slot, which is the picture to hold while reading the channel definitions.

### 3.2 **23.1 NR Sidelink-Transmission and Deployment Scenarios**

Section 3.1 gave the purpose; this section gives the three ways a device can transmit and the scenarios each serves.

There are three transmission types: unicast from one device to one, groupcast from one to a defined group, and broadcast from one to anyone listening. Figure 23.1 shows the three.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.1 shows the three.*

There are two deployment scenarios. In coverage, devices are connected to a base station that can control the sidelink. Out of coverage, devices are isolated and must rely on pre-configuration and their own decisions. Figure 23.2 shows both.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.2 shows both.*

> [!important] 💡
> **Concrete Scenarios for Sidelink**
> Q4: Which scenario needs this sidelink system (without gNB)?
> - **Public safety and disaster relief:** firefighters entering a burning building or working in a hurricane zone where cell towers are destroyed need instant local voice and data to coordinate.
> - **Deep remote V2X:** two autonomous trucks in a platoon through a remote tunnel or desert highway with no coverage must still exchange braking and steering data in milliseconds.
> - **Tactical and military:** units in hostile environments where infrastructure may be jammed or absent.
> - **Consumer mesh:** friends hiking in the mountains sharing GPS locations or photos without internet.

### 3.3 **23.2 Resources for Sidelink Communication**

The three transmission types need resources. This section explains resource pools and why sidelink kept ordinary OFDM.

NR sidelink uses ordinary OFDM, where LTE sidelink used the single-carrier variant. A resource pool is a configured set of slots and subchannels available for sidelink, kept apart from ordinary cellular traffic, as Figure 23.3 shows.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*A resource pool is a configured set of slots and subchannels available for sidelink, kept apart from ordinary cellular traffic, as Figure 23.3 shows.*

Within a slot not every symbol is available; the network configures a start symbol and a length, leaving gaps for switching. Figure 23.4 shows the first symbols of a slot kept free.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.4 shows the first symbols of a slot kept free.*

> [!spec] 3GPP reality check
> Resource pools, their subchannel size and slot bitmap, are the SL-ResourcePool information element in [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip); the sidelink bandwidth part is SL-BWP-Config.

### 3.4 **23.3 Sidelink Physical Channels**

With the pool defined, this section names the channels that occupy it, each mirroring a cellular one.

Sidelink defines its own physical channels, mirroring the cellular ones. The shared channel carries data and the second-stage control information. The control channel carries the first-stage control needed to decode the shared channel. The feedback channel carries acknowledgements. The broadcast channel carries the synchronisation information. Figure 23.5 maps each channel to what it carries.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.5 maps each channel to what it carries.*

> [!important] 💡
> **Split SCI Mechanism**
> Why does sidelink use a split SCI? What is the difference from normal NR control, and how does it help sidelink?
> - **The mechanism:** the first-stage SCI, on the control channel, holds the public metadata: frequency and time resources, the reservation, and what is needed to demodulate the second stage. It uses a fixed format (QPSK) known to everyone. The second-stage SCI, on the shared channel, holds the private metadata: the destination, the HARQ process, and the modulation and coding, and its size and modulation can vary.
> - **Difference from normal NR:** in the downlink the base station sends all control in one block (DCI on PDCCH), knowing where the user is and what channel it has.
> - **Why the split helps:** (1) sensing in mode 2 requires devices to listen to everyone to avoid collisions; the first stage carries the reservation, so any device can decode it and see "this slot is busy" without decoding the private data. (2) Adaptability: the second stage travels with the data and can be beamformed and link-adapted, compressed for a near neighbour or made robust for a distant car.

#### 3.4.1 **23.3.1 PSSCH/PSCCH**

The two are transmitted together, the control channel occupying the first symbols and lowest frequencies of the allocation. Figure 23.6 shows the structure: the first symbol is a copy of the second for gain control; the control channel sits early and low so the receiver decodes it first and learns where the data is; and the last symbol is left empty for switching.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.6 shows the structure: the first symbol is a copy of the second for gain control; the control channel sits early and low so the receiver decodes it first and learns where the data is; and the last symbol is left empty for switching.*

> [!important] 💡
> **AGC Mechanism**
> Why does sidelink emphasise automatic gain control?
> - **What it is:** AGC adjusts the receiver amplifier's "volume" so the signal is neither buried in noise nor distorted.
> - **Why sidelink cares:** in the downlink the base station transmits continuously or predictably, and the phone tracks its power smoothly. On sidelink, packets arrive in bursts from different devices: one from a car 10 m away, extremely loud, and the next a millisecond later from a car 500 m away, extremely quiet.
> - **The solution:** the receiver cannot track a stable level, so it resets its gain for every packet. The AGC symbol, a duplicate of the first data symbol, is a dummy: the receiver measures its energy, sets the gain, and is ready for the real data in the next symbol.

#### 3.4.2 **23.3.2 PSFCH**

The feedback channel sits at the end of the slot. Figure 23.7 shows it in the second-to-last symbol, with a guard gap between the data and the feedback so the radio can switch from receiving to transmitting.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.7 shows it in the second-to-last symbol, with a guard gap between the data and the feedback so the radio can switch from receiving to transmitting.*

> [!spec] 3GPP reality check
> The sidelink channels and their mapping in a slot are [TS 38.211 V18.9.0, clause 8](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); the two stages of control information are TS 38.212 clauses 8.3 and 8.4.

### 3.5 **23.4 Sidelink Procedures**

The channels exist; this section describes the procedures that use them: how devices avoid transmitting over each other, and how they retransmit.

#### 3.5.1 **23.4.1 Resource Allocation and Power Control**

!important[This is the core of how devices avoid talking over each other. Figure 23.8 shows both modes: in mode 1 the base station tells the device when to transmit; in mode 2 the device senses and picks its own empty slot.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.8 shows both modes: in mode 1 the base station tells the device when to transmit; in mode 2 the device senses and picks its own empty slot.*

> [!important] 💡
> > A complete comparison between mode 1 and mode 2.

| Feature | Mode 1 (NR) / mode 3 (LTE) | Mode 2 (NR) / mode 4 (LTE) |
| --- | --- | --- |
| Controller | the network (gNB) controls everything | the device controls itself, autonomously |
| Coverage | in coverage only; needs a connection to the gNB | any: in, out of, or partial coverage |
| Mechanism | scheduling grants; the device asks and the gNB assigns time and frequency | sensing and selection; the device listens, finds empty spots, reserves them |
| Collision risk | low; the gNB coordinates all users | higher; two devices may pick the same slot (half-duplex and hidden-node effects) |
| Use case | dense urban areas where the gNB manages high traffic | highways, tunnels, remote areas, ad-hoc safety messages |

#### 3.5.2 **23.4.1.1 Resource-Allocation Mode 1**

Mode 1 is like uplink scheduling: the base station sends a grant in DCI format 3_0. Figure 23.9 contrasts the two: the grant goes to device A, but A uses it to transmit to device B.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.9 contrasts the two: the grant goes to device A, but A uses it to transmit to device B.*

Figure 23.10 shows that one grant can reserve up to three future slots, allowing retransmissions.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.10 shows that one grant can reserve up to three future slots, allowing retransmissions.*

#### 3.5.3 **23.4.1.2 Resource-Allocation Mode 2**

Devices sense: they listen to the reservation announcements in other devices' first-stage control. Figures 23.11 and 23.12 show reservation: a transmitting device notes in its header "I am using this slot and I reserve that future one", and others avoid it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Figures 23.11 and 23.12 show reservation: a transmitting device notes in its header "I am using this slot and I reserve that future one", and others avoid it.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.13 shows selection: a sensing window looking back to see who reserved what, and a selection window ahead from which a slot not marked busy is chosen.*

Figure 23.13 shows selection: a sensing window looking back to see who reserved what, and a selection window ahead from which a slot not marked busy is chosen.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.13 shows selection: a sensing window looking back to see who reserved what, and a selection window ahead from which a slot not marked busy is chosen.*

> [!important] 💡
> **Security in Mode 2 Sensing**
> Is there any security problem in this scenario?
> Yes; the equality of mode 2 brings risks because no central authority validates actions.
> - **Denial of service (resource hogging):** a malicious user can transmit fake control messages reserving all future slots. Legitimate devices, following the protocol, see the spectrum as full and cannot send safety messages.
> - **Privacy leakage:** since reservations must be announced publicly, a passive eavesdropper can track traffic patterns, frequency, and potentially the identity of a vehicle.
> - **Injection and spoofing:** a malicious user can spoof high-priority reservations; the sensing algorithm makes legitimate users back off when they detect a higher priority, which an attacker can abuse to keep kicking them off the channel.

#### 3.5.4 **23.4.2 Hybrid-ARQ Feedback and Retransmissions**

Sidelink supports retransmissions. Unicast uses ordinary acknowledgement and negative acknowledgement. Groupcast has two options: negative-only, where a member speaks up only if it did not hear, efficient for large groups; or full acknowledgement from every member, with high overhead.

> [!spec] 3GPP reality check
> The mode-1 grant is DCI format 3_0 in TS 38.212 clause 7.3.1.4; the mode-2 sensing and selection algorithm with its windows and thresholds is [TS 38.214 V18.10.0, clause 8.1.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); feedback on the feedback channel is TS 38.213 clause 16.3.

> [!engineering] ShareTechnote engineering view
> The [sidelink page](https://www.sharetechnote.com/html/5G/5G_SideLink.html) steps through a mode-2 selection with a worked sensing window, which makes the exclusion-and-threshold rule concrete.

### 3.6 **23.5 Sidelink Synchronization**

Every procedure above assumes the devices agree on time. The road ends with how devices without a tower find a common clock.

!note[Devices need a common clock to find the slots. The master reference is usually GNSS or a base station. If device A sees the base station it becomes a synchronisation source; device B out of coverage syncs to A, and C to B. Figure 23.14 shows the chain.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.14 shows the chain.*

#### 3.6.1 **23.5.1 The Sidelink SS/PSBCH Block**

A special block plays the role of the cell's synchronisation block for sidelink. Figure 23.15 shows it: primary and secondary sidelink synchronisation signals for timing, and a broadcast channel carrying the sidelink master information block.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.15 shows it: primary and secondary sidelink synchronisation signals for timing, and a broadcast channel carrying the sidelink master information block.*

#### 3.6.2 **23.5.2 Synchronization Procedure**

Devices prioritise their source: base station first, then an in-coverage device, then an out-of-coverage device. Figure 23.16 shows the in-coverage flag passing down the chain: device 1 sets it true; device 2, synced to 1, sets it false but signals that it is one hop away.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 23.16 shows the in-coverage flag passing down the chain: device 1 sets it true; device 2, synced to 1, sets it false but signals that it is one hop away.*

> [!important] 💡
> **Security in Synchronization**
> Is there a security problem in the synchronisation process?
> - **The risk:** yes. Sidelink synchronisation relies on trust; devices synchronise blindly to the source with the highest-priority signal.
> - **Attack vector:** a malicious user broadcasts a fake synchronisation block with the in-coverage flag set to true, mimicking a direct connection to a base station.
> - **Impact:** nearby legitimate devices choose the attacker as their best source and set their clocks to its wrong time, desynchronising from the legitimate network. They then transmit in the wrong slots, causing collisions with legitimate traffic and effectively jamming the area.

> [!spec] 3GPP reality check
> The sidelink synchronisation block is TS 38.211 clause 8.4; the source-selection priority is TS 38.331 sl-SyncPriority with the procedure in TS 38.213 clause 16.1.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: clause 8 of the physical-layer documents and clause 16 of the procedures document.

Sidelink is clause 8 of the physical-layer documents and clause 16 of the procedures document. TS 38.211 defines the channels and the synchronisation block. TS 38.212 defines the two stages of control information and the mode-1 grant. TS 38.214 holds the sensing and selection algorithm that every mode-2 device runs, with its windows and thresholds. TS 38.213 holds feedback and the synchronisation priority. TS 38.331 holds the resource pools and every configured number. The figure draws the pool, the booking a header carries, the sensing rule, the feedback cadence, and the clock chain, with the configuration lines each becomes.

![[99 Attachments/5G/Protocol Figures/STAR-23-Sidelink-Communication-Protocol.png|The sidelink channels, the two-stage control, the mode-2 sensing algorithm and the synchronisation priority, with their clauses and configured values]]

*Protocol figure: The sidelink channels, the two-stage control, the mode-2 sensing algorithm and the synchronisation priority, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 8 | sidelink physical channels and signals |
| TS 38.212 | V18.8.0, [38212-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.3.1.4; 8.3–8.4 | sidelink DCI and first- and second-stage SCI |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 16 | sidelink control, feedback, power, and timing procedures |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 8.1–8.4 | PSSCH transmission and reception, resource selection |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | SL-BWP-Config; SL-ResourcePool | pools, sensing windows, thresholds, feedback, sync priority |

!note[**When you build or run a demo.** A sidelink demo is two devices and, optionally, a base station; without one it is mode 2 and the pool must be pre-configured identically on both devices, or they will never find each other. The pool is a subchannel size, a subchannel count, and a slot bitmap. The sensing window, the selection window, and the exclusion thresholds are the lines that decide how often two devices collide. The feedback period decides how quickly a lost packet is repeated. The synchronisation source is one line, and a bench demo with no GPS and no base station must have one device configured as the reference or neither will transmit. The device log shows the fraction of the pool sensed as free and the slot chosen, which is the fastest way to see the algorithm working.]

Release 15 aimed the first NR release at network access; NR sidelink for vehicles arrived in Release 16 with unicast, groupcast, broadcast, feedback, and autonomous selection. Release 17 broadened coverage and relays; Release 18 continues with the enhancements in TS 21.918 clauses 9.3 and 9.4. The clause baseline does not imply that every device implements every cast type, band, or relay feature. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define sensing; this trace counts how many candidate resources survive sensing-based exclusion.

**What we are working out.** Fraction of initially monitored candidate resources that remain after sensing-based exclusion.

**Worked numerical example.** Subtract sensed exclusions and normalize by the configured candidate count.

Suppose a configured selection window contains 200 candidate single-slot resources after basic pool restrictions. Sensing and decoded reservations exclude 75. The UE has 125 candidates before its final randomized or rule-based selection:

$$
\begin{aligned}
N_{\mathrm{cand}} &= N_{\mathrm{pool}}-N_{\mathrm{excl}} \\
&= 200-75 \\
&= 125, \\
f_{\mathrm{remain}} &= \frac{N_{\mathrm{cand}}}{N_{\mathrm{pool}}} \\
&= \frac{125}{200} \\
&= 0.625.
\end{aligned}
$$

Here $N_{\mathrm{pool}}$ is the initial candidate-resource count, $N_{\mathrm{excl}}$ is the excluded count, $N_{\mathrm{cand}}$ is the remaining count, and $f_{\mathrm{remain}}$ is the dimensionless remaining fraction.

Thus 62.5% of the illustrative candidates remain. This does not mean collision probability is 37.5% or success probability is 62.5%. Exclusions reflect predicted conflicts based on what the UE could sense. Half-duplex gaps, hidden nodes, fading, simultaneous selections, reservation horizons, and threshold configuration can leave collisions among the remaining candidates. The numbers are assumed for teaching; the selection procedure is anchored in TS 38.214 clauses 8.1–8.4.

**Sanity check.** The remaining count is nonnegative and no larger than the original pool, while the normalized fraction lies between zero and one.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $N_{\mathrm{pool}}$ | Candidates after basic pool constraints | 200 | resources | Assumed |
| $N_{\mathrm{excl}}$ | Candidates removed by sensing/reservations | 75 | resources | Assumed |
| $N_{\mathrm{cand}}$ | Candidates remaining before final selection | 125 | resources | Derived |
| $f_{\mathrm{remain}}$ | Remaining fraction | 0.625 | dimensionless | Derived |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** The current Course Alignment assigns no direct unit to Chapter 23. Sidelink can nevertheless serve as an advanced exercise after physical channels, reference signals, scheduling, and HARQ. It is particularly valuable for contrasting Uu network scheduling with PC5 peer communication and for exposing why distributed radio selection is not distributed authentication.

A compact assessment asks students to label Mode 1 and Mode 2 authority, place first- and second-stage SCI, identify the half-duplex observation gap, and name a higher-layer control for a false-reservation attack.

> “Which scenario needs this sidelink system (without gNB)?”

!warning[Out-of-coverage vehicles or public-safety teams, coverage shadows, local industrial coordination, and relay scenarios can need direct peer communication without immediate gNB scheduling. Sidelink is also useful in coverage when direct latency, local awareness, or spectral reuse is valuable.]

> “Why in sidelink using split SCI? What’s the difference between the normal SCI in NR system, and how can this mechanism help the scenario in the sidelink?”

!warning[The first stage exposes resource and decoding information needed broadly; the second stage accompanies PSSCH and supports the particular transmission. The split reduces unnecessary blind decoding and helps neighboring devices understand resource use. It is a functional split.]

> “For AGC, Why in Sidelink emphasis this mechanism?”

!warning[Peer transmitters can arrive with different powers and no base-station-controlled downlink envelope. An initial symbol/energy opportunity helps receiver settling before data decoding. The purpose is standard-visible; the exact AGC circuit algorithm is implementation-specific.]

> How do Mode 1 and Mode 2 compare completely?

!warning[Mode 1 has gNB resource authority and benefits from network coordination but depends on coverage and scheduling. Mode 2 selects from a pool using local sensing and reservations, supports autonomy and out-of-coverage use, but faces hidden nodes, half-duplex gaps, and distributed congestion.]

> Is Mode-2 sensing secure?

!warning[No. It estimates occupancy and reservations among compliant devices. It does not authenticate SCI or stop jamming, forged reservations, or rule violation. Higher-layer credentials and monitoring are required.]

> Is sidelink synchronization secure?

!warning[Synchronization priority chooses a timing source according to protocol and configuration; it is not source authentication. A deceptive or jammed source can disturb acquisition, so security and resilience require higher-layer trust, plausibility checks, and multi-source monitoring.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 23, pp. 457–477, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00023-4).
2. 3GPP TS 21.916 V16.2.0, clause 8.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
3. 3GPP TS 38.211 V18.9.0, clause 8. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
4. 3GPP TS 38.212 V18.8.0, clauses 7.3.1.4 and 8.3–8.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
5. 3GPP TS 38.213 V18.8.0, clause 16. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
6. 3GPP TS 38.214 V18.10.0, clauses 8.1–8.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
7. 3GPP TS 21.918 V18.0.0, clauses 9.3–9.4. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
8. ShareTechnote, “5G/NR — Sidelink,” accessed 2026-08-03. [Direct page](https://www.sharetechnote.com/html/5G/5G_SideLink.html).
9. Course Alignment, local course crosswalk, accessed 2026-08-03.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| AGC | Automatic Gain Control | Receiver gain-settling function; exact implementation is not mandated. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| DCI | Downlink Control Information | Network control format used for Mode-1 scheduling. | Section 1; [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| gNB | Next Generation Node B | Optional network scheduler for sidelink resources. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| HARQ | Hybrid Automatic Repeat Request | Link-layer feedback and retransmission process. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PC5 | Direct interface between UEs | 3GPP sidelink radio interface. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PSCCH | Physical Sidelink Control Channel | Channel carrying first-stage SCI. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PSFCH | Physical Sidelink Feedback Channel | Channel carrying sidelink HARQ feedback. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| PSSCH | Physical Sidelink Shared Channel | Sidelink data channel carrying transport block and second-stage SCI. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| SCI | Sidelink Control Information | Control information split across two decoding stages. | Section 1; [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| S-SS/PSBCH | Sidelink Synchronization Signal / Physical Sidelink Broadcast Channel | Sidelink timing and essential broadcast-information pair. | Section 1; [TS 38.211](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) |
| UE | User Equipment | Peer sidelink transmitter or receiver. | Section 1; [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) |
| V2X | Vehicle-to-Everything | Vehicle communication service family. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $N_{\mathrm{pool}}$ | Candidate count after basic pool constraints | resources |
| $N_{\mathrm{excl}}$ | Count excluded by sensing and reservations | resources |
| $N_{\mathrm{cand}}$ | Count remaining before final selection | resources |
| $f_{\mathrm{remain}}$ | Fraction of candidates remaining | dimensionless |
