---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 7
title: Overall Transmission Structure
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-07 — Overall Transmission Structure

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Imagine a theatre with one stage and thousands of people who all want to watch a different play. Nobody can have the whole hall to themselves, so the theatre does two things. It sells seats, so that several people share the room without sitting on each other. And it sells showings, so that the same seat serves a different person at eight o'clock and at ten. The air around a 5G base station is that hall. Frequency is the row of seats, running left to right. Time is the sequence of showings, running down the page. A phone that wants to receive data is not given "the air"; it is given a few seats for a few showings, and told exactly which ones.

![[99 Attachments/5G/Concept Figures/STAR-07-Overall-Transmission-Structure-Concept.png|The NR resource grid explained as theatre seating]]

*Concept figure: The NR resource grid explained as theatre seating.*

Everything in this chapter is the fine print of that ticketing system. How wide is one seat? That is the subcarrier spacing, and unlike LTE, NR lets the theatre choose from a family of widths. How long is one showing? That is the OFDM symbol, and its length follows directly from the seat width. Which seats may a cheap phone even look at? That is the bandwidth part. Where does seat numbering start, so that two phones with different tickets agree on which seat is seat 17? That is Point A. Why does the whole hall sometimes run "everyone listens" showings and sometimes "everyone speaks" showings? That is the duplex scheme. And when the same seat is served by several loudspeakers at once, how does a phone know which ones to trust together? That is the antenna port.

None of this is visible. You cannot see a subcarrier or a slot; you can only see their consequences, in a throughput number or a latency figure. That is why this chapter matters more than its dryness suggests. Every later chapter — scheduling, retransmission, beam management, positioning — assumes you already know where a transmission *is*, in time and in frequency. This chapter is where that knowledge is built.

**The question this chapter answers.** How do NR timing, frequency coordinates, active bandwidth, duplex direction, and antenna-port assumptions define where a transmission exists?

!important[**The short answer.** NR places transmissions on a numerology-specific time–frequency grid. Point A and the carrier and grid offsets provide the frequency reference; a bandwidth part limits the portion a device is active in; FDD or TDD decides which direction a slot serves; and antenna ports plus quasi-co-location assumptions define the channel view a receiver may assume. A count of grid positions becomes a capacity only after channel-specific overhead and scheduling have been applied.]

Names you will meet in this note: Orthogonal Frequency Division Multiplexing (OFDM), subcarrier spacing (SCS), cyclic prefix (CP), resource element (RE), resource block (RB), common resource block (CRB), physical resource block (PRB), bandwidth part (BWP), carrier aggregation (CA), supplementary uplink (SUL), frequency division duplex (FDD), time division duplex (TDD), slot format indication (SFI), quasi co-location (QCL).

## 2. Where you are in 5G

Section 1 sold seats and timed scenes in a theatre. The map below shows where the seating plan sits in 5G: the time and frequency grid that every channel of every later chapter is drawn on.

![[99 Attachments/5G/Locator Maps/STAR-07-Where-You-Are-in-5G.png|Where Star 07 sits in the whole 5G system]]

*Locator: Where Star 7 sits in the whole 5G system.*

Read the locator from the bottom up. This chapter lives in the physical foundations, at the point where spectrum (Stars 03, 25, 26) has been turned into a usable carrier and before any actual channel (Star 29) or coding (Star 30) is placed on it. Above it, every procedure in the middle band — cell search, random access, scheduling, retransmission — will name its resources in the units defined here. The same map appears in every note with a different box lit; if you ever feel lost, come back to it.

Two closer views follow. The Knowledge Structure Map shows how the units of this chapter nest, from Point A outward to a carrier and its bandwidth parts. The mechanism diagram shows the grid itself and the numerology table that scales it.

![[99 Attachments/5G/Knowledge Maps/STAR-07-Overall-Transmission-Structure-Knowledge Structure Map.png|STAR-07 system-position map]]

*Knowledge map: How an NR carrier and its bandwidth parts are anchored to Point A.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-07-NR-Grid-Hierarchy.png|Star 07 mechanism and handoff diagram]]

*Mechanism: The NR resource grid and the numerology table.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 7.1 Transmission Scheme → 7.2 Time-Domain Structure → 7.3 Frequency-Domain Structure → 7.4 Bandwidth Parts (BWP) → 7.5 Frequency-Domain Location of NR Carriers.


## 3. The textbook road

Section 2 placed the grid under every other box. The road below walks through the chapter in the book's order: the waveform, time, frequency, bandwidth parts, carriers, duplexing, then the antenna ports and quasi co-location that the grid's users assume.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **7.1 Transmission Scheme**

The road starts with the waveform, because the grid only exists if the signal is OFDM. This section says why NR chose it for both directions.

NR uses Orthogonal Frequency Division Multiplexing (OFDM) in both directions. The reason is practical rather than elegant: OFDM tolerates multipath and Doppler well, and it maps naturally onto a time–frequency grid, which makes everything that follows — scheduling, reference signals, bandwidth parts — easy to describe as "these subcarriers, these symbols".

The uplink has one extra option. Besides plain OFDM, a device may use DFT-precoded OFDM, which behaves like single-carrier transmission. The precoding lowers the peak-to-average power ratio, so the power amplifier can run closer to its efficient region, which matters for a battery-powered phone at the cell edge. The price is that DFT-precoded transmission is limited to a single MIMO layer, whereas plain OFDM supports up to four uplink layers.

The other change from LTE is the subcarrier spacing. LTE fixed it at 15 kHz. NR scales it as Δf = 15 × 2^μ kHz, and each doubling halves the symbol duration and the cyclic prefix together. Table 7.1 gives the family and where each member is typically used.

| Δf (kHz) | Useful Symbol Time (µs) | CP (µs) | Typical Use |
| --- | --- | --- | --- |
| 15 | 66.7 | 4.7 | FR1 macro cells / LTE coexistence |
| 30 | 33.3 | 2.3 | Mid-band FR1 |
| 60 | 16.7 | 1.2 | Upper FR1 / Lower FR2 |
| 120 | 8.33 | 0.59 | mmWave |
| 240 | 4.17 | 0.29 | SS Block only |

The key idea is that one waveform, with one scalable parameter, lets NR run from sub-GHz wide-area coverage to millimetre-wave beamformed links. A subframe contains one or more slots depending on the spacing, and each slot holds 14 OFDM symbols with the normal cyclic prefix.

> [!book] Book expansion
> Chapter 7 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 115–145, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00007-6)) spends its opening pages on why the same waveform serves both directions and why the numerology family was chosen; read it for the design argument behind Table 7.1.

> [!spec] 3GPP reality check
> The waveform and numerology are fixed in [TS 38.211 V18.9.0, clauses 4.2 and 5.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip). Clause 4.2 is the μ table; clause 5.3 is the OFDM baseband signal generation, including the DFT-precoding branch for the uplink.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [numerology page](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html) tabulates the same family with symbol and CP lengths to the sample, which is what you need when checking a capture.

### 3.2 **7.2 Time-Domain Structure**

OFDM gives symbols; this section stacks them into slots, subframes and frames and shows the one thing in that stack that scales.

#### 3.2.1 **7.2.1 OFDM Numerologies**

!important[The time structure has three fixed anchors and one thing that scales. A radio frame is always 10 ms. A subframe is always 1 ms. A slot always holds 14 symbols with the normal cyclic prefix, or 12 with the extended one. What scales is how many slots fit in a subframe: 2^μ of them, so a slot lasts 1/2^μ ms.]

| Numerology μ | Subcarrier Spacing Δf = 15 × 2^μ kHz | Slot Duration |
| --- | --- | --- |
| 0 | 15 kHz | 1 ms |
| 1 | 30 kHz | 0.5 ms |
| 2 | 60 kHz | 0.25 ms |
| 3 | 120 kHz | 0.125 ms |
| 4 | 240 kHz | 0.0625 ms (FR2 only) |

Because the frame and subframe never change, two numerologies on the same carrier still agree about where a subframe begins. That is the property that lets them be mixed.

| Subcarrier spacing (Δf) | Slot duration | Slots per frame | μ value |
| --- | --- | --- | --- |
| 15 kHz | 1 ms | 10 slots | 0 |
| 30 kHz | 0.5 ms | 20 slots | 1 |
| 60 kHz | 0.25 ms | 40 slots | 2 |
| 120 kHz | 0.125 ms | 80 slots | 3 |
| 240 kHz (mmWave) | 0.0625 ms | 160 slots | 4 |

Slots are the usual scheduling unit, but NR does not force a transmission to fill one. Figure 7.1 shows the nesting of frames, subframes, and slots.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.1 shows the nesting of frames, subframes, and slots.*

Figure 7.2 shows the consequence: a transmission may start and end inside a slot. This "mini-slot" freedom exists for three reasons. A low-latency service can start the moment its grant arrives instead of waiting for the next slot boundary. A millimetre-wave cell can sweep an analogue beam by giving each direction only a few symbols. And an unlicensed transmitter can start the instant its listen-before-talk check succeeds. The slot boundary is a timing reference.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.2 shows the consequence: a transmission may start and end inside a slot.*

Read together, the two figures say that a larger spacing gives a shorter slot, which gives lower latency and suits higher carrier frequencies, where the shorter symbol also tolerates phase noise better.

> [!book] Book expansion
> The textbook's treatment of mini-slots (Chapter 7, pp. 115–145) is the clearest statement of why NR decoupled transmissions from slot boundaries; the three motivations above are its own list.

> [!spec] 3GPP reality check
> Frames, subframes, and slots are defined in [TS 38.211 V18.9.0, clause 4.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); Table 4.3.2-1 gives the slots per frame and per subframe for each μ. The mini-slot freedom is expressed there as the allowed starting symbol and length of a PDSCH or PUSCH allocation, which TS 38.214 clauses 5.1.2.1 and 6.1.2.1 then constrain.

> [!engineering] ShareTechnote engineering view
> The [frame structure page](https://www.sharetechnote.com/html/5G/5G_FrameStructure.html) draws each numerology's slots inside one subframe, which makes the "frame never changes" point visible at a glance.

### 3.3 **7.3 Frequency-Domain Structure**

Section 3.2 fixed the time axis. This section fixes the frequency axis: subcarriers, resource blocks, and a small difference from LTE at the carrier centre.

Start with a small but telling difference from LTE. LTE left the centre subcarrier — the DC subcarrier — unused, because a direct-conversion receiver distorts it. NR may use it. The reason is that in NR not every device is tuned to the carrier centre: a device operating in a bandwidth part on one side of the carrier has its own DC point somewhere else entirely. Rather than reserve a subcarrier that only some devices would find at their centre, NR leaves the handling to the receiver. Figure 7.3 contrasts the two approaches.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.3 contrasts the two approaches.*

Now the two units everything is counted in. A resource element is one subcarrier for one OFDM symbol. A resource block is twelve consecutive subcarriers — and, unlike in LTE, nothing more. The NR resource block has no time dimension. Figure 7.4 shows both.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.4 shows both.*

The grid on which data and reference signals are placed is the resource grid, and the specification defines one per subcarrier spacing and per antenna port.

| Domain | Unit | Description |
| --- | --- | --- |
| **Frequency** | 12 subcarriers × Δf Hz = 1 Resource Block | Basic frequency unit |
| **Time** | 14 OFDM symbols = 1 Slot | Basic time unit |

"One grid per numerology and per antenna port" means two things. Each spacing has its own grid, because a 30 kHz symbol is half the length of a 15 kHz symbol and the two cannot share cells. And each antenna port carries its own copy of the grid, because different ports may carry different reference signals on the same positions. Figure 7.5 shows two spacings side by side.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.5 shows two spacings side by side.*

#### 3.3.1 **7.2.3 Reference Point “Point A”**

A device that has just found a cell knows where the synchronisation block was, and little else. That is not enough to interpret a resource-block index, because the synchronisation block sits wherever the raster allowed. Point A solves this. It is a frequency reference: the position of the lowest subcarrier of common resource block zero, from which every numerology counts its blocks. Figure 7.6 shows the numbering.

| Concept | Definition | Scope |
| --- | --- | --- |
| **Point A** | Lowest subcarrier of CRB #0 → frequency reference for carrier | Global |
| **Common Resource Block (CRB)** | Numbering of RBs across entire carrier (independent of BWPs or numerology) | Carrier-wide |
| **Physical Resource Block (PRB)** | Actual RB used for a particular BWP and numerology | BWP-local |

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*| Concept | Definition | Scope | | --- | --- | --- | | Point A | Lowest subcarrier of CRB #0 → frequency reference for carrier | Global | | Common Resource Block (CRB) | Numbering of RBs across entire carrier (independent of BWPs or numerology) | Carrier-wide | | Physical Resource Block (PRB) | Actual RB used for a particular BWP and numerology | BWP-local |.*

The distinction between common and physical resource blocks is the one to hold on to. A common resource block is counted from Point A across the whole carrier. A physical resource block is counted from the start of the bandwidth part the device is currently in. The two are related by a single offset, which is the start of the bandwidth part in common-block units.

> [!book] Book expansion
> The textbook's Chapter 7 pages on the resource grid explain why the RB lost its time dimension in NR: with several numerologies and mini-slots, a time-frequency rectangle would have had to be redefined for each.

> [!spec] 3GPP reality check
> Resource elements, blocks, and Point A are in [TS 38.211 V18.9.0, clause 4.4](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip): 4.4.3 defines the element, 4.4.4 the block, and 4.4.4.2 the offset from Point A. The relation n_CRB = n_PRB + N_BWP,start is stated in clause 4.4.4.4.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [resource grid page](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html) works one example of Point A, the carrier offset, and a bandwidth part offset with real ARFCN numbers, which is the fastest way to see the three offsets add up.

### 3.4 **7.4 Bandwidth Parts (BWP)**

Section 3.3 assumed a device could listen to the whole carrier. This section removes that assumption with bandwidth parts, so that a narrow device or a sleepy phone listens to only a slice.

An NR carrier can be hundreds of megahertz wide. Not every device can or should receive all of it — a sensor with a narrow receiver cannot, and a phone with nothing to do should not, because a wide receiver draws power. A bandwidth part is the answer: a contiguous set of resource blocks inside the carrier, with its own numerology, that a device monitors and transmits on.

| Feature | Purpose |
| --- | --- |
| Multiple BWPs per carrier | Support devices with limited RF bandwidth. |
| One active BWP at a time (Release 15) | Reduce power and complexity. |
| BWP switching via RRC signaling | Allows dynamic adaptation to traffic. |

A device may be configured with up to four bandwidth parts in each direction, but only one is active at a time. Figure 7.7 shows a device moving between a narrow and a wide part as its traffic changes.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.7 shows a device moving between a narrow and a wide part as its traffic changes.*

#### 3.4.1 Mobility Measurements outside Active BWP

A device sometimes needs to measure signals that are not inside its active part — a neighbouring cell, for instance. Its receiver is tuned to the active part, so it cannot simply listen elsewhere. NR handles this the way inter-frequency measurement was always handled: the network schedules a measurement gap, the device retunes, measures, and returns. Measuring outside the active part is allowed; it is just not free.

### 3.5 **7.5 Frequency-Domain Location of NR Carriers**

A bandwidth part lives inside a carrier, and the carrier itself cannot sit anywhere. This section explains the rasters that fix where carriers and synchronisation blocks may be placed.

!note[A carrier cannot be placed at an arbitrary frequency. NR defines a carrier raster — a grid of allowed centre frequencies — that is finer at low frequencies and coarser at high ones: 5 kHz steps below 3 GHz, 15 kHz up to 24 GHz, and 60 kHz above. The synchronisation block uses a separate and much coarser synchronisation raster, so that a device searching blind has few positions to try. A consequence worth remembering is that the carrier centre and the synchronisation block centre need not coincide, which is exactly why Point A exists. Figure 7.8 shows the raster.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.8 shows the raster.*

### 3.6 **7.6 Carrier Aggregation**

Section 3.5 placed one carrier. This section combines several, and shows the two ways scheduling reaches each of them.

When one carrier is not enough, a device can receive several at once. Carrier aggregation combines up to sixteen component carriers, potentially more than 6 GHz of total bandwidth. Each carrier is scheduled separately, and NR offers two ways to deliver the scheduling: self-scheduling, where the control channel on a carrier grants data on the same carrier, and cross-carrier scheduling, where the control channel on the primary cell grants data on a secondary cell. Cross-carrier scheduling saves a device from monitoring control channels on every carrier. Figure 7.9 shows the two.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.9 shows the two.*

Feedback has a similar scaling problem. If a device receives on many downlink carriers, the acknowledgements for all of them can overload one uplink control channel. NR allows two PUCCH groups, each reporting on a different uplink cell, which balances the load for asymmetric aggregations. Figure 7.10 shows the split.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.10 shows the split.*

### 3.7 **7.7 Supplementary Uplink (SUL)**

Carrier aggregation adds capacity; it does not repair a weak uplink. This section adds a low-frequency uplink carrier for reach and separates it from aggregation.

Uplink coverage is usually the weak side of a high-frequency deployment: the base station transmits with far more power than a phone. A supplementary uplink adds a low-frequency uplink carrier, with better reach, alongside the existing downlink and uplink pair. Figure 7.11 shows the arrangement.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.11 shows the arrangement.*

The supplementary carrier can be an existing LTE uplink band, shared between the two systems, which is how operators improved cell-edge uplink without new spectrum. Figure 7.12 shows that coexistence.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.12 shows that coexistence.*

#### 3.7.1 **7.7.1 Relation to Carrier Aggregation**

The two look similar and are not. In carrier aggregation every uplink carrier has its own downlink, and the carriers are used together for throughput. A supplementary uplink shares a downlink with the ordinary uplink, and the device uses one of them at a time. It is a coverage tool.

### 3.8 **7.8 Duplex Schemes**

All the carriers above must be shared between the two directions. This section shows how one frame structure serves FDD, TDD and half-duplex, and how a device learns the direction of each slot.

LTE had separate frame structures for paired and unpaired spectrum. NR has one. The same frame, subframe, and slot serve time division duplex, frequency division duplex, and half-duplex FDD; only the way slots are assigned to directions differs. Figure 7.14 shows the unified structure.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.14 shows the unified structure.*

| Scheme | Separation Principle | Typical Spectrum | Characteristics |
| --- | --- | --- | --- |
| **FDD (Full-Duplex)** | UL ↔ DL split in frequency | Paired spectrum (\< 6 GHz) | Continuous UL & DL, best for macro coverage |
| **Half-Duplex FDD** | Same freq split but UE cannot TX/RX simultaneously | Low-cost devices | Lower complexity → slower switching |
| **TDD (Time-Division Duplex)** | UL ↔ DL split in time on same freq | Unpaired spectrum (\> 2 GHz) | Dynamic UL/DL allocation per slot |

#### 3.8.1 **7.8.1 TDD**

In TDD both directions share one carrier, and the base station decides, symbol by symbol, which direction each serves. NR allows this decision to be dynamic, so the uplink-to-downlink ratio can follow traffic. Each slot is made of downlink symbols, uplink symbols, or flexible ones that can go either way. The benefits are real: unpaired bands at 3.5 GHz and 26 GHz are used efficiently, asymmetric traffic is matched, and beam switching and low latency are easier. The cost is equally real: when neighbouring cells choose different directions for the same slot, they interfere in ways FDD never sees, which is why coordination is needed and why a later chapter is devoted to it.

#### 3.8.2 **7.8.2 FDD**

In FDD the two directions transmit at the same time on different frequencies. The frame timing is identical to TDD; only the frequency allocation differs. NR also supports half-duplex FDD, where a device cannot transmit and receive at once, which lets a low-cost device omit the duplex filter. FDD remains the natural choice for wide-area coverage in the paired bands below about 2 GHz.

#### 3.8.3 **7.8.3 Slot Format and Slot-Format Indication (SFI)**

Dynamic TDD only works if every device knows, for every slot, which symbols are downlink, uplink, or flexible. A device cannot infer this; it has to be told. NR does it in two steps. The specification defines a fixed catalogue of allowed slot formats, each a pattern of fourteen D, U, and F symbols. RRC then configures a table of the formats a cell will use, and a short dynamic indication — the slot format indicator, sent on the control channel — points at one entry. Figure 7.17 shows the catalogue and Figure 7.19 the table and the pointer.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.17 shows the catalogue and Figure 7.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.20 shows the override.*

The indication is authoritative. Even periodic reference signals obey it: if a slot is declared downlink, no uplink sounding is transmitted in it; if uplink, no downlink CSI-RS is expected. Figure 7.20 shows the override.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 7.20 shows the override.*

### 3.9 **7.10 Antenna Ports**

Everything so far described where a signal sits. This section adds the promise that lets a device interpret it: the antenna port.

!important[An antenna port is not an antenna. It is a promise: two signals transmitted from the same port have experienced the same radio channel, so a channel estimate made on one can be applied to the other. The promise is what lets a device use a reference signal to demodulate data. Ports are numbered by purpose, which makes a configuration or a capture readable at a glance.]

#### 3.9.1 **Table 7.2 – Antenna Ports in NR**

| Port Range | Purpose | Example Signals |
| --- | --- | --- |
| 0000-series | UL DMRS | PUSCH/PUCCH |
| 1000-series | DL DMRS | PDSCH |
| 2000-series | DL Control | PDCCH |
| 3000-series | CSI-RS | CSI measurements |
| 4000-series | Synchronization | SS/PBCH |
| 5000-series | Positioning | PRS |

Each port implies its own demodulation reference-signal pattern, which is how the receiver estimates that port's channel.

### 3.10 **7.10 Quasi-Colocation (QCL)**

Section 3.9 made the promise for one port. This section extends it across ports, so that an expensive measurement can be reused.

Quasi co-location extends the promise across ports. Two ports are quasi co-located if their signals share some large-scale channel properties without being identical, and the network can tell a device which properties. That lets the device reuse an expensive measurement — a Doppler estimate, a delay spread, a beam direction — made on one signal when receiving another.

| QCL Type | Shared Parameters | Usage |
| --- | --- | --- |
| Type A | Doppler, Doppler spread, avg delay, delay spread | Basic time-domain correlation |
| Type B | Doppler + Doppler spread | Mobility tracking |
| Type C | Doppler + avg delay | Frequency offset alignment |
| Type D | Spatial (QCL) – same beam direction | Beamformed ports |

The rule of thumb is simple. If two signals use the same known precoder, the device may treat them as one port. If the precoders differ or are unknown, they must be distinct ports, and QCL is how the network says which of their properties still match. Type D, the spatial one, is the workhorse of beam management: it is how a device is told which beam to receive a channel on.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the clauses that fix the numbers, and the configuration keys each clause becomes in base-station software.

The textbook explains the design; the specification fixes the numbers. The figure below lays out the clauses to open, the equations those clauses actually state, and the configuration keys each one becomes in open-source base-station software such as srsRAN or OpenAirInterface. The specification has almost no pictures of its own, so this is the picture.

![[99 Attachments/5G/Protocol Figures/STAR-07-Overall-Transmission-Structure-Protocol.png|The transmission-structure clauses, their equations, and their configuration lines]]

*Protocol figure: The five TS 38.211 clauses of the transmission structure, their equations, and the configuration lines they become.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| Numerology and frames | [TS 38.211 V18.9.0, clauses 4.2–4.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | The μ table and the frame, subframe, and slot definitions. |
| Grids, blocks, Point A, BWPs | [TS 38.211 V18.9.0, clauses 4.4–4.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | Resource grid, RE, RB, CRB/PRB numbering, bandwidth parts, antenna ports. |
| BWP and slot procedure | [TS 38.213 V18.8.0, clauses 11–12](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | Slot format indication and bandwidth-part switching as the device performs them. |
| RF carrier requirements | [TS 38.104 V18.14.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) | Channel bandwidths, the number of resource blocks per bandwidth and numerology, and the carrier raster. |

!note[**When you build or run a demo.** Every value in this chapter appears, under some name, in a gNB configuration file. The subcarrier spacing you choose is clause 4.2 of TS 38.211. The ARFCN you give for Point A is clause 4.4.4.2, converted through the ARFCN definition in TS 38.104 clause 5.4.2. The carrier bandwidth in resource blocks is a row of Table 5.3.2-1 in TS 38.104, and if you type a number that is not in that table the phone will not attach. The initial bandwidth part is a single resource-indication value, which TS 38.214 clause 5.1.2.2.2 tells you how to encode. The TDD pattern is TS 38.213 clause 11.1. When a demo misbehaves, the first question is which of these clauses the configuration violates, and this table is where to start looking.]

Release 15 established scalable numerology, bandwidth parts, Point A, flexible TDD, and the port concept. Later releases added bands, carrier combinations, and reference-signal configurations without changing the coordinate system, which is why the Release 18 clauses can be read as the current form of a Release 15 design. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The clauses give the numbers; this trace uses them in the grid arithmetic that every later chapter assumes you can do.

**Worked numerical example.**

Calculate the nominal subcarrier span of 106 PRBs at 30 kHz SCS. Keep this grid span separate from standardized channel bandwidth and usable data REs.

**What we are working out.** Nominal frequency span of the allocated PRB subcarriers, in megahertz, measured at the BWP resource-grid.

$$
\begin{aligned}
B_{grid} &= N_{PRB}N_{sc}\Delta f \\ &= (106)(12)(30\ \mathrm{kHz}) \\ &= 38.16\ \mathrm{MHz}
\end{aligned}
$$

Where:

- $B_{grid}$ = 38.16 MHz, calculated (local resource count); it belongs to the BWP grid.
- $N_{PRB}$ = 106 PRB, assumed (illustrative allocation); it belongs to the BWP.
- $N_{sc}$ = 12 subcarriers/PRB, reported (TS 38.211 clause 4.4.4); it belongs to the PRB.
- $\Delta f$ = 30 kHz, reported (TS 38.211 clause 4.2); it belongs to the numerology grid.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $B_{grid}$ | 38.16 MHz | calculated | local resource count | BWP grid |
| $N_{PRB}$ | 106 PRB | assumed | illustrative allocation | BWP |
| $N_{sc}$ | 12 subcarriers/PRB | reported | TS 38.211 clause 4.4.4 | PRB |
| $\Delta f$ | 30 kHz | reported | TS 38.211 clause 4.2 | numerology grid |

PRB count times subcarriers per PRB times hertz per subcarrier yields hertz. Twelve is the standardized PRB width. The 38.16 MHz result excludes guard bands and does not subtract reference, control, or reserved elements, so it is not user throughput.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about the grid.

**Course alignment.** This is a primary U03–U05 note. Use Section 3 to establish coordinates, Section 4 to connect them, and Section 5 as the grid arithmetic exercise before channel-specific processing. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

!warning[**“A PRB always contains 168 data REs”.**

A normal 14-symbol rectangle has 168 positions before channel-specific exclusions. It is not guaranteed data. The fix is to count what a grid position can hold before assuming it carries data.]

!warning[**“A BWP is a carrier”.**

A BWP is an active contiguous region within a carrier configuration. The fix is to distinguish the carrier from the part of it a device is currently using.]

!warning[**“Point A is the carrier center”.**

Point A is a grid reference; carrier center and grid offsets are separate quantities. The fix is to keep the grid reference and the carrier centre as separate quantities.]

!warning[**“TDD slot format schedules the UE”.**

It constrains direction. Scheduling still selects resources and a UE. The fix is to separate a direction constraint from an actual grant of resources.]

!warning[**“An antenna port is an antenna element”.**

A port describes a channel the phone may assume. The fix is to read a port as a channel promise rather than as a count of hardware.]

### 6.1 Supplement: small-scale fading

The confusions above are about the grid; the handout below is about the channel it must survive. The numerology table of Section 3 is two inequalities, and small-scale fading supplies the quantities on their other side.

!warning[The numerology table of Section 3 is two inequalities in disguise. The handout supplies the quantities on the other side of them.]

![[99 Attachments/5G/Supplement Figures/STAR-07-Saar-Small-Scale-Fading.png|Small-scale fading: delay spread, Doppler, the fading matrix and worked numbers]]

*Supplement figure: Small-scale fading: a power delay profile with the delay-spread formulas, a moving-UE sketch with the Doppler formulas, a two-by-two flat versus frequency-selective and slow versus fast matrix annotated with NR design answers, and worked numbers.*
*Figure 6.1 — Delay spread and coherence bandwidth, Doppler and coherence time, the fading matrix, and where NR sits in it.*

| Quantity | Relation | NR consequence |
|---|---|---|
| rms delay spread στ | Bc ≈ 1/(5·στ) | cyclic prefix must exceed the delay spread; each subcarrier stays flat |
| Maximum Doppler fm = v/λ | Tc ≈ 0.423/fm | subcarrier spacing ≫ Doppler; extra DM-RS when Tc is shorter than a slot |
| Envelope statistics | Rayleigh without line of sight, Rician with K factor | link adaptation and HARQ absorb the fades |

- Urban macro at 3.5 GHz: στ ≈ 1 µs → Bc ≈ 200 kHz; 120 km/h → fm ≈ 389 Hz, Tc ≈ 1.1 ms; 500 km/h → Tc ≈ 0.26 ms.

Source: Supplementary material, *Small-scale fading models* (handout); 3GPP TR 38.901, TS 38.211 clause 4.2.

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 7, pp. 115–145, 2021, DOI [chapter 7](https://doi.org/10.1016/B978-0-12-822320-8.00007-6).
2. Chapter 7 notes of this knowledge base (the author's reading notes).
4. 3GPP, *TS 38.211 V18.9.0, clauses 4.2–4.3*, [Numerology and frames](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
5. 3GPP, *TS 38.213 V18.8.0, clauses 11–12*, [BWP and slot procedure](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
6. 3GPP, *TS 38.104 V18.14.0, clauses 5–6*, [RF carrier requirements](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip).
7. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
8. ShareTechnote, [resource grid](https://www.sharetechnote.com/html/5G/5G_ResourceGrid.html), accessed 2026-08-03.
9. ShareTechnote, [numerology](https://www.sharetechnote.com/html/5G/5G_Phy_Numerology.html), accessed 2026-08-03.
10. ShareTechnote, [bandwidth part](https://www.sharetechnote.com/html/5G/5G_CarrrierBandwidthPart.html), accessed 2026-08-03.
11. Saar University 5G course alignment.
12. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| gNB | next generation NodeB | Section 1; fixed specification set in Section 6 |
| OFDM | Orthogonal Frequency Division Multiplexing | Section 1; fixed specification set in Section 6 |
| CP | Cyclic Prefix | Section 1; fixed specification set in Section 6 |
| SCS | Subcarrier Spacing | Section 1; fixed specification set in Section 6 |
| PRB | Physical Resource Block | Section 1; fixed specification set in Section 6 |
| BWP | Bandwidth Part | Section 1; fixed specification set in Section 6 |
| FDD | Frequency Division Duplex | Section 1; fixed specification set in Section 6 |
| TDD | Time Division Duplex | Section 1; fixed specification set in Section 6 |
| SUL | Supplementary Uplink | Section 1; fixed specification set in Section 6 |
| QCL | Quasi Co-Location | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $B_{grid}$ | Nominal allocated grid span | MHz |
| $N_{PRB}$ | Allocated PRB count | count |
| $N_{sc}$ | Subcarriers per PRB | subcarriers/PRB |
| $\Delta f$ | Subcarrier spacing | kHz |

The symbols mean what they mean in this note; another note may use the same letter for something else.
