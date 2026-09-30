---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 19
title: NR in Unlicensed Spectrum
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-19 — NR in Unlicensed Spectrum

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Licensed spectrum is a room you own: you decide who speaks and when, which is what every scheduler in this course assumes. Unlicensed spectrum is a shared room where Wi-Fi already lives, and its house rules are older than 5G. NR in unlicensed spectrum is what happens when a system built to own the room learns to borrow it.

![[99 Attachments/5G/Concept Figures/STAR-19-NR-in-Unlicensed-Spectrum-Concept.png|NR in unlicensed spectrum explained as the house rules of a shared room]]

*Concept figure: NR in unlicensed spectrum explained as the house rules of a shared room.*

The rules are four. Listen before you talk: wait until the room has been quiet for a fixed moment, then roll a die and wait that many more short slots; if someone else starts, pause the count. Speak for a bounded time: once you win you may hold the room for a few milliseconds, the channel occupancy time, then stop and listen again. Hand the floor over quickly: inside your turn you may pass it to your partner, the phone, with a gap too short for anyone else to enter, and the partner need not roll the die. And do not shout in one corner: regulators cap power per megahertz, so the uplink spreads itself across the band as a comb of resource blocks.

What this does to the rest of the book is the reason the chapter is long. The scheduler of Star 14 no longer owns the medium it schedules, so every plan is conditional on winning the room. Data may start mid-slot the instant the room is won. Acknowledgements may arrive later if the phone lost its own listen. One grant may cover several packets because each grant cost a win. The control channel is copied into every 20 MHz sub-band because any one of them may be the free one. The key fact to carry is that channel access is not initial access. Initial access happens once; channel access happens before every transmission, forever.

**The question this chapter answers.** How can a scheduled cellular system transmit reliably when it must sense a channel, contend with Wi-Fi and other networks, obey occupancy limits, and sometimes lose a planned slot before transmission?

!important[**The short answer.** NR-U adds shared-spectrum channel-access procedures around normal NR scheduling. Before applicable transmissions, a node performs a channel access procedure. Type 1 uses sensing with a contention window and back-off. Type 2 uses shorter sensing under defined conditions, within or around a channel occupancy already obtained or shared. Successful sensing permits transmission for a bounded COT; it never grants ownership. A failed assessment defers the transmission, so scheduling must account for uncertain start time and interrupted opportunities.]

Names you will meet in this note: listen-before-talk (LBT), channel occupancy time (COT), contention window (CW), dynamic frequency selection (DFS), power spectral density (PSD), license-assisted access (LAA), frame-based and load-based equipment (FBE, LBE), resource block set (RB set), new feedback indicator (NFI), downlink feedback information (DFI).

## 2. Where you are in 5G

Section 1 moved NR from a room it owns into a shared room. The map below shows where unlicensed operation sits in 5G: the same radio boxes, with a new gate before every transmission.

![[99 Attachments/5G/Locator Maps/STAR-19-Where-You-Are-in-5G.png|Where Star 19 sits in the whole 5G system]]

*Locator: Where Star 19 sits in the whole 5G system.*

This chapter lights unlicensed operation in the spectrum band of Star 03 and touches nearly every procedure: the scheduler of Star 14, the HARQ timing of Star 13, the control channel of Star 10, the reference signals of Star 08, and the configured grants of Star 20. It is the clearest example in the course of one external constraint, a shared medium, rippling through a whole design.

The Knowledge Structure Map draws channel access at the centre with the procedures it disturbs around it. The mechanism diagram traces one listen, one win, and one shared occupancy.

![[99 Attachments/5G/Knowledge Maps/STAR-19-NR-in-Unlicensed-Spectrum-Knowledge Structure Map.png|STAR-19 system-position map]]

*Knowledge map: The unlicensed-spectrum rules and the NR features each one forced.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-19-NR-U-Channel-Access-Loop.png|Star 19 mechanism and handoff diagram]]

*Mechanism: The listen-before-talk channel access procedure as a flowchart.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Chapter 19: NR in Unlicensed Spectrum → 19.1 Unlicensed Spectrum for NR → 19.2 Technology Components for Unlicensed Spectrum → 19.3 Channel Access in Unlicensed Spectra → 19.4 Downlink Data Transmission.


## 3. The textbook road

Section 2 placed the gate. The road below walks through the chapter in the book's order: the bands, what NR already had, how the channel is won, then what changes for data, control and initial access.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Chapter 19: NR in Unlicensed Spectrum**

The road begins with the one change that organises the whole chapter: the base station no longer owns its carrier.

!important[Everything before this chapter assumed the base station owns its carrier. Here it does not, and the chapter is organised as the consequences of that one change: which bands, what NR already had that helped, how the channel is won, and then what each of data transmission, control signalling, and feedback had to become.]

> [!book] Book expansion
> Chapter 19 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 381–418, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00019-2)) is the longest of the feature chapters because it revisits nearly every earlier one under the new constraint.

> [!spec] 3GPP reality check
> Channel access itself is a document shared with LTE, [TS 37.213](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/), clause 4; the NR-specific changes are gathered in [TS 38.213 V18.8.0, clause 16](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [NR-U page](https://www.sharetechnote.com/html/5G/5G_NR_Unlicensed.html) walks the listen-before-talk categories with timing diagrams, which is the fastest way to see what a defer period and a back-off look like on a timeline.

### 3.2 **19.1 Unlicensed Spectrum for NR**

Section 3.1 stated the change; this section says where it applies, the 5 and 6 GHz bands and their rules.

The chapter extends NR to unlicensed bands, mainly at 5 and 6 GHz. Licensed spectrum offers exclusive use, predictable interference, and high quality of service, suited to wide-area coverage. Unlicensed spectrum is open to anyone, free, unpredictable, power-limited, and suited to local capacity. Figure 19.1 shows the two deployment modes.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.1 shows the two deployment modes.*

In license-assisted access a licensed carrier carries control and mobility for reliability and an unlicensed carrier adds capacity, through LTE–NR dual connectivity or NR carrier aggregation. In standalone operation everything, including initial access, happens in unlicensed spectrum, which suits private networks such as factories.

> [!important] 💡
> Why need unlicensed spectrum? Why not take this spectrum into licensed so management is easier?
> A: Scarcity and cost: licensed spectrum is scarce and very expensive (auctions cost billions), and operators often run out of licensed bandwidth.
> Availability: unlicensed spectrum is "free" and abundant.
> Regulation and history: governments allocated these bands (ISM bands) for public use decades ago. Wi-Fi and Bluetooth already rely on them. You cannot simply "take them" for licensed use because billions of existing devices (laptops, phones, routers) would stop working.
> Distribution (Fig 19.2): the 5 GHz band offers roughly 500–600 MHz of spectrum (split into chunks). The 6 GHz band is massive, offering 500 MHz (EU) to 1200 MHz (US). This is huge compared to typical licensed allocations (often 10–20 MHz chunks).

#### 3.2.1 **19.1.1 The 5 GHz Band**

The 5 GHz band has a mature ecosystem, used by Wi-Fi and LTE-LAA, and is divided into 20 MHz channels. Indoor use is limited to about 23 dBm and outdoor to about 30 dBm, and dynamic frequency selection is required to protect radar. Figure 19.2 shows the band's availability by region, with the 5 GHz sub-bands and the emerging 6 GHz band.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.2 shows the band's availability by region, with the 5 GHz sub-bands and the emerging 6 GHz band.*

Three regulations shape the design. A power-spectral-density limit caps energy per megahertz, around 10 dBm/MHz. A channel-occupancy-time limit caps how long one may transmit continuously, a few milliseconds. And listen-before-talk requires checking that the channel is free before transmitting. Figure 19.3 shows the consequence of the density limit: a narrow transmission must lower its total power, while a wide one can raise it while staying under the cap.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.3 shows the consequence of the density limit: a narrow transmission must lower its total power, while a wide one can raise it while staying under the cap.*

#### 3.2.2 **19.1.2 The 6 GHz Band**

The 6 GHz band is newer and larger, up to 1200 MHz in the United States. No mobile technology is established there, unlike 5 GHz with LTE-LAA, though satellites use it; it is greenfield for mobile but still requires fair-sharing rules.

> [!spec] 3GPP reality check
> The NR unlicensed bands are n46 (5150–5925 MHz) and n96 and n102 (6 GHz) in [TS 38.101-1 V18.x, clause 5.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/); the regulatory limits themselves come from ETSI EN 301 893 and national rules.

### 3.3 **19.2 Technology Components for Unlicensed Spectrum**

The bands have house rules. This section lists what NR already had that made obeying them easier than it was for LTE.

NR was designed for forward compatibility, which made adapting it easier than adapting LTE. Its ultra-lean design minimises always-on signals, which in LTE blocked the channel and caused listen-before-talk failures. Its flexible frame structure, with 30 kHz spacing and mini-slots, fits the shared room. Figure 19.4 shows the key change: in licensed NR data starts at a slot boundary, but in unlicensed spectrum transmission must begin the instant sensing succeeds, so data starts mid-slot to grab the channel.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.4 shows the key change: in licensed NR data starts at a slot boundary, but in unlicensed spectrum transmission must begin the instant sensing succeeds, so data starts mid-slot to grab the channel.*

> [!important] 💡
> **DFS vs. LBT**
> Both are coexistence mechanisms, but they solve different problems on different timescales.

| Feature | DFS (dynamic frequency selection) | LBT (listen-before-talk) |
| --- | --- | --- |
| Purpose | protect radar systems (primary users) | coexist with Wi-Fi and other NR (peer users) |
| Timescale | slow, long-term: detect radar, vacate the channel for 30 minutes | fast, dynamic: check milliseconds before every transmission |
| Mechanism | scan for radar pulses; if found, move to a new channel entirely | sense energy on the current channel; if busy, back off; if idle, transmit |
| Mandatory? | only in bands where radar operates, such as parts of 5 GHz | mandatory in the EU and Japan; the US has looser rules |

### 3.4 **19.3 Channel Access in Unlicensed Spectra**

With the rules and the tools named, this section reaches the centre of the chapter: how a base station or a phone wins the channel before it may transmit.

The scheduler does not control the medium. It must contend for it.

#### 3.4.1 **19.3.1 Dynamic Channel-Access Procedures**

!important[The mechanism is listen-before-talk, built on Wi-Fi's principles of energy detection and random back-off.]

> [!important] 💡
> **Channel Access Procedure Type 1**
> 1. **Is "Channel Access" = "Initial Access"?** No. They are completely different. Initial access is the process of a phone finding a cell and logging into the network (scanning SSB, random-access preamble); it happens once when you turn on the phone or move to a new area. Channel access (LBT) is the momentary permission to "speak" on the radio; it happens every single millisecond before sending a data packet.
> 2. **Procedure interpretation (Fig 19.5):** Step A, the defer period: listen for a fixed time (16 µs plus slots) to ensure the channel is truly idle. Step B, random back-off: this is the contention window.
> 3. **Why random back-off?** Imagine five people in a room waiting for a speaker to finish. If everyone starts talking the exact moment the speaker stops, they collide. If everyone rolls a die and waits that many seconds, one person will likely start first, and the others will hear them and stop. Random back-off is a random waiting time to avoid collision.

Figure 19.5 is the flowchart of type 1 access, the category-4 procedure. Wait until the channel is idle for the defer period. Draw a random N between zero and the contention window. Each time the channel is free for a 9 µs slot, subtract one. If it becomes busy, pause and resume when free. Transmit when N reaches zero.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.5 is the flowchart of type 1 access, the category-4 procedure.*

Table 19.1 gives the contention windows by priority class. High-priority traffic, class 1, draws from a small window of 3 to 7 and usually wins quickly; low-priority traffic, class 4, draws from 15 to 1023 and waits longer.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*High-priority traffic, class 1, draws from a small window of 3 to 7 and usually wins quickly; low-priority traffic, class 4, draws from 15 to 1023 and waits longer.*

#### 3.4.2 **19.3.1.1 Channel-Access Procedure Type 1 and Listen-Before-Talk**

In licensed spectrum the base station decides when to transmit, with no sensing and guaranteed access. In unlicensed spectrum it must sense first, and the transmission is probabilistic; it may not happen when planned.

#### 3.4.3 **19.3.1.2 Channel-Access Procedure Type 2 and COT Sharing**

If the base station wins the channel and starts an occupancy, it can share the remaining time with the phone, or the phone with it, without a full random back-off. No back-off is needed because the channel is already owned by the network inside the occupancy. The base station won it with type 1, transmits, then pauses for a gap so short, 16 or 25 µs, that no other device can enter; to outsiders the channel is still busy. Type 1 is the hard work of starting a period; type 2 is the quick check, or none, that continues one.

Figure 19.6 shows sharing: downlink data after type 1, a gap under 25 µs, and uplink data immediately with type 2.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.6 shows sharing: downlink data after type 1, a gap under 25 µs, and uplink data immediately with type 2.*

Figure 19.7 shows the cyclic extension: to make the gap exactly short enough, the phone may start early with a filler that extends its cyclic prefix.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.7 shows the cyclic extension: to make the gap exactly short enough, the phone may start early with a filler that extends its cyclic prefix.*

#### 3.4.4 **19.3.2 Semi-Static Channel-Access Procedures**

Frame-based equipment transmits at fixed periods, say every 10 ms, if the channel is free, and if blocked waits for the next period. It is less flexible than load-based listening but simpler in controlled environments. Figure 19.8 shows attempts at fixed instants, and a busy channel costing a whole cycle.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.8 shows attempts at fixed instants, and a busy channel costing a whole cycle.*

#### 3.4.5 **19.3.3 Carrier Aggregation and Wideband Operation**

Wider bandwidth combines several 20 MHz chunks, and sensing can be done per chunk or across the whole. Figure 19.9 shows the two options: one back-off counter for all carriers, which transmit together, or one counter per carrier, harder to synchronise.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.9 shows the two options: one back-off counter for all carriers, which transmit together, or one counter per carrier, harder to synchronise.*

Figure 19.10 shows a single 80 MHz carrier split into four 20 MHz resource-block sets separated by guard bands, with sensing on each set individually.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.10 shows a single 80 MHz carrier split into four 20 MHz resource-block sets separated by guard bands, with sensing on each set individually.*

> [!spec] 3GPP reality check
> Type 1 access with its defer period, back-off, and contention-window table is [TS 37.213, clause 4.1.1](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/); type 2 access and occupancy sharing are clauses 4.1.2 and 4.2.1; the energy-detection threshold is 4.1.5 and semi-static access is 4.3.

> [!engineering] ShareTechnote engineering view
> The [NR-U page](https://www.sharetechnote.com/html/5G/5G_NR_Unlicensed.html) tabulates the contention windows and occupancy times per class next to Wi-Fi's access categories, which shows why the numbers are what they are.

### 3.5 **19.4 Downlink Data Transmission**

Section 3.4 won the channel. This section asks what changes for downlink data once a transmission may start at any moment and must end when the occupancy does.

Downlink data is scheduled as in licensed spectrum, but the scheduler must handle the uncertainty of sensing. Where licensed data maps to slot boundaries with fixed duration, unlicensed data may start anywhere, in a mini-slot, and end anywhere to fit the occupancy; mapping type B was extended to 2 to 13 symbols.

#### 3.5.1 **19.4.1 Downlink Hybrid-ARQ**

In licensed spectrum the acknowledgement comes at a fixed time. In unlicensed spectrum the phone may try to send it and fail its own sensing. The solution is a "later" timing and group-based feedback. Figure 19.11 shows acknowledgements sent in the same occupancy, one marked later because the occupancy ended, and that one bundled into a subsequent transmission.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.11 shows acknowledgements sent in the same occupancy, one marked later because the occupancy ended, and that one bundled into a subsequent transmission.*

Figure 19.12 shows feedback for groups of transmissions: if the base station hears no acknowledgement, it toggles the new-feedback indicator to ask the phone to resend that group's feedback with the next.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.12 shows feedback for groups of transmissions: if the base station hears no acknowledgement, it toggles the new-feedback indicator to ask the phone to resend that group's feedback with the next.*

#### 3.5.2 **19.4.2 Reference Signals**

The tracking and channel-state reference signals were modified to fit within the 20 MHz resource-block sets.

#### 3.5.3 **19.5 Uplink Data Transmission**

!note[The uplink is harder than the downlink because the phone must sense, and the base station does not know whether it will succeed.]

#### 3.5.4 **19.5.1 Interlaced Transmission**

> [!important] 💡
> **Interlaced Transmission**
> What is it? Instead of sending data on a contiguous block of frequencies (e.g. 100–110), the data is chopped up and spread out like a comb (e.g. 1, 11, 21, 31, …).
> Why need it? To meet PSD (power spectral density) limits. Regulators say "you can only transmit 10 dBm per 1 MHz". If you transmit 20 MHz of data in a solid block, you are limited by that density. If you spread the same data across a wider range (interlaced), you occupy more MHz virtually, allowing more total power while keeping the density low.
> Licensed comparison: licensed uses contiguous (localised) allocation, better for frequency-selective scheduling, and usually has no PSD limit. Unlicensed uses interlaced allocation, mandatory in some regions to get adequate uplink range.

Figure 19.13 shows the interlace definition: resource blocks picked at a spacing of ten, so that interlace 0 spreads its energy across the whole bandwidth.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.13 shows the interlace definition: resource blocks picked at a spacing of ten, so that interlace 0 spreads its energy across the whole bandwidth.*

#### 3.5.5 **19.5.2 Dynamic Scheduling for Uplink Data Transmission**

One control message can now schedule several transport blocks. Sending a control message requires the base station to win the channel, which is expensive, so a win should schedule as many uplink packets as possible. Figure 19.14 contrasts the inefficient sequence of grant, sense, grant, sense with a single grant followed by consecutive packets.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.14 contrasts the inefficient sequence of grant, sense, grant, sense with a single grant followed by consecutive packets.*

#### 3.5.6 **19.5.3 Configured Grants for Uplink Data Transmission**

A phone with a configured grant can transmit whenever it has data, subject to sensing. Because its timing is now variable, the uplink control information carries the HARQ process identity, since the base station can no longer infer which packet is being sent.

#### 3.5.7 **19.5.4 Uplink Sounding Reference Signal**

The sounding reference signal may be sent in any symbol, so that it fits into whatever occupancy was shared.

> [!spec] 3GPP reality check
> The interlace structure is [TS 38.211 V18.9.0, clause 6.3.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); HARQ groups, the new-feedback indicator, and configured-grant uplink control information for unlicensed operation are TS 38.213 clause 16 and TS 38.212 clause 6.3.

### 3.6 19.6 Downlink Control Signaling

Data needs control. This section shows how the control region and the search spaces were adapted so that a device finds control wherever the channel was free.

#### 3.6.1 **19.6.1 CORESET**

On an 80 MHz carrier the control region is repeated in every 20 MHz chunk, so the phone finds it whichever chunk was free. Figure 19.15 shows the control region duplicated in two resource-block sets.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.15 shows the control region duplicated in two resource-block sets.*

#### 3.6.2 **19.6.2 Blind Decoding and Search Space Groups**

Unlicensed operation requires frequent monitoring to catch the start of a burst, which drains the battery. Search-space groups solve it: group 0 monitors densely, group 1 sparsely. Figure 19.16 shows the phone monitoring densely until data starts, switching to sparse monitoring to save power, and switching back when a timer expires.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.16 shows the phone monitoring densely until data starts, switching to sparse monitoring to save power, and switching back when a timer expires.*

#### 3.6.3 **19.6.3 Downlink Scheduling Assignments-DCI Formats 1_0 and 1_1**

Three fields were added to the downlink assignment: the PDSCH group index, an extended downlink assignment index, and the channel-access type.

#### 3.6.4 **19.6.4 Uplink Scheduling Grants-DCI Formats 0_0 and 0_1**

The frequency-domain signalling was adapted for interlaced mapping and the time-domain signalling for multi-packet scheduling. Figure 19.17 shows resource-allocation type 2: which interlace to use and which resource-block set to apply it to.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.17 shows resource-allocation type 2: which interlace to use and which resource-block set to apply it to.*

Figure 19.18 shows the time-domain table extended so that one row describes the start and length of several consecutive uplink packets.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.18 shows the time-domain table extended so that one row describes the start and length of several consecutive uplink packets.*

#### 3.6.5 **19.6.5 Downlink Feedback Information-DCI Format 0_1**

Downlink feedback information lets the base station acknowledge configured-grant uplink data, since there is no dedicated channel for it; a flag in format 0_1 marks it.

#### 3.6.6 **19.6.6 Slot Format Indication-DCI Format 2_0**

Format 2_0 tells a group of phones how long the current occupancy lasts and which resource-block sets are available in it, so that each phone knows where and for how long it may expect data.

> [!spec] 3GPP reality check
> Search-space group switching, the wideband control region, and the added DCI fields are [TS 38.213 V18.8.0, clause 16](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) with the field definitions in TS 38.212 clause 7.3.1; the occupancy and resource-block-set indication is DCI format 2_0.

### 3.7 19.7 Uplink Control Signaling

Section 3.6 was downlink control. This section adapts uplink control, which must now be interlaced like data.

#### 3.7.1 **19.7.1 Uplink Control Signaling on PUCCH**

In licensed spectrum the uplink control channel is usually localised in frequency. In unlicensed spectrum it must be interlaced like data to meet the power-density cap. Figure 19.19 shows format 0, a small acknowledgement repeated across the comb.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.19 shows format 0, a small acknowledgement repeated across the comb.*

Figure 19.20 shows format 1 with the same repetition.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.20 shows format 1 with the same repetition.*

Figure 19.21 shows format 2 for larger reports, with spreading codes that let several phones share one interlace.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.21 shows format 2 for larger reports, with spreading codes that let several phones share one interlace.*

#### 3.7.2 **19.7.2 Uplink Control Signaling on PUSCH**

Uplink control on the data channel gains the configured-grant control information, which carries the HARQ process identity that the base station can no longer infer from timing.

### 3.8 19.8 Initial Access

Everything above assumed the phone had already found the cell. This section handles finding it, when even the synchronisation block cannot be sent at a guaranteed time.

In licensed spectrum the synchronisation block is sent at a fixed, guaranteed time. In unlicensed spectrum the base station may try and fail its listen, so the block's timing is not guaranteed.

#### 3.8.1 **19.8.1 Dynamic Frequency Selection**

Radar protection is implementation-specific: the base station detects radar and moves to a new channel.

#### 3.8.2 **19.8.2 Cell Search, Discovery Bursts, and Standalone Operation**

A discovery burst bundles the synchronisation block with SIB1. Because its timing is not fixed, the base station defines a window of a few milliseconds, and the phone looks for the burst anywhere inside it. Figure 19.22 shows the window and the burst inside it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 19.22 shows the window and the burst inside it.*

Because the block floats inside the window, the phone cannot use timing alone to know which beam it caught; Figure 19.23 shows how the block index modulo a configured number identifies the beam through quasi-co-location.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Because the block floats inside the window, the phone cannot use timing alone to know which beam it caught; Figure 19.23 shows how the block index modulo a configured number identifies the beam through quasi-co-location.*

#### 3.8.3 **19.8.3 Random Access**

Preambles are longer, to fill 20 MHz for power-density reasons. And there is no power ramping after a failed listen, because the base station did not miss the preamble for lack of power; the phone never sent it.

> [!spec] 3GPP reality check
> The discovery burst window and the quasi-co-location rule are TS 38.213 clause 4.1 with the unlicensed additions in clause 16; the wide preambles are TS 38.211 clause 6.3.3; the no-ramping rule after a failed listen is TS 38.321 clause 5.1.3.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents, starting with the one shared with LTE that holds the channel access rules.

Channel access is written in a document shared with LTE, TS 37.213, whose clause 4 holds the defer period, the back-off, the contention-window and occupancy table per priority class, the energy-detection threshold, the type 2 gaps, and semi-static access. The uplink interlace is TS 38.211. Everything NR changed to survive the shared room, resource-block sets, search-space groups, HARQ groups, the occupancy indication in DCI format 2_0, is gathered in TS 38.213 clause 16. The figure draws the listen-before-talk arithmetic, the class table, the gaps, and the interlace, with the configuration lines each becomes.

![[99 Attachments/5G/Protocol Figures/STAR-19-NR-in-Unlicensed-Spectrum-Protocol.png|The listen-before-talk rules, the occupancy sharing gaps and the uplink interlace, with their clauses and configured values]]

*Protocol figure: The listen-before-talk rules, the occupancy sharing gaps and the uplink interlace, with their clauses and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 37.213 | Rel-18, [37.213 archive](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/) | 4.1–4.3 | channel-access procedures, contention windows, energy threshold |
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 6.3.1 | uplink interlace structure |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4; 16 | NR-U procedures: RB sets, search-space groups, HARQ groups |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.3.2 | channel-access mode, energy threshold, interlace configuration |

!note[**When you build or run a demo.** The band and the channel-access mode are the first two lines; dynamic mode is load-based listening and semi-static mode is frame-based with a period. The energy-detection threshold is set by regulation, and a demo that transmits over a neighbour's Wi-Fi usually has it too high. Interlaced uplink is a flag, and the guard bands between resource-block sets follow from the bandwidth. The base-station log shows each listen as a priority class, a contention window, a back-off count, and an occupancy length, and a log full of failed listens says the room is crowded. Open-source stacks have partial NR-U support; expect to read TS 37.213 alongside the code.]

Release 16 introduced NR-U, with both license-assisted and standalone operation, type 1 and type 2 access, interlaces, and the control and feedback adaptations. Release 17 and 18 refine the 6 GHz band and coexistence rules. Release summaries are checked against TS 21.916 and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix the counters; this trace runs one back-off with a chosen window and counter so that you can see how long the wait lasts.

Assume a pedagogical contention window $CW=15$, a uniformly selected backoff counter $N=9$, and an eligible sensing-slot duration $T_{sl}=9\ \mu s$. Assume the channel remains idle for all nine decrement opportunities and ignore the fixed defer interval.

**What we are working out.** The variable backoff time contributed by the selected counter.

$$
\begin{aligned}
T_{backoff}
&=N\,T_{sl}\\
&=9\times9\ \mu\mathrm{s}\\
&=81\ \mu\mathrm{s}.
\end{aligned}
$$

Here, $N$ is the selected backoff counter, $T_{sl}$ is the eligible sensing-slot duration, and $T_{backoff}$ is their ideal idle-channel product.

For a uniform integer selection from 0 through 15, the expected counter and ideal idle-channel backoff are

$$
\begin{aligned}
E[N]&=\frac{0+15}{2}=7.5,\\
E[T_{backoff}]&=7.5\times9\ \mu\mathrm{s}=67.5\ \mu\mathrm{s}.
\end{aligned}
$$

In this formula, $CW$ is an assumed contention-window upper value, $N$ is the assumed selected counter, and $T_{sl}$ is an assumed sensing-slot duration. $T_{backoff}$ is the variable idle-channel countdown contribution, while $E[N]$ and $E[T_{backoff}]$ are their ideal uniform-selection expectations. All numerical values are pedagogical; actual access categories, contention-window sets, defer durations, threshold, and adjustment rules must come from TS 37.213 and applicable regulation. Busy slots would freeze progress and make elapsed wall-clock delay larger than the ideal product.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $CW$ | 15 | integer upper value | pedagogical assumption |
| $N$ | 9 | sensing slots | pedagogical draw |
| $T_{sl}$ | 9 | $\mu s$ | pedagogical assumption |
| $T_{backoff}$ | 81 | $\mu s$ | derived idle-channel result |
| $E[N]$ | 7.5 | sensing slots | derived expectation |
| $E[T_{backoff}]$ | 67.5 | $\mu s$ | derived expectation |

The ideal mean does not predict application latency because busy periods, collisions, retransmissions, missed configured grants, and COT boundaries add heavy and load-dependent variation. The example’s value is to separate a random counter from elapsed time and to show exactly where channel activity enters.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star extends U03, U04, and U05. Students reuse resource grids, duplexing, control channels, scheduling, HARQ, and random access, then add contention and regulation. It is a strong capstone comparison between centrally scheduled licensed operation and scheduled access gated by decentralized sensing.

A classroom exercise can place Wi-Fi and NR-U contenders on one timeline. Students mark sensing, frozen counters, COT, DL/UL sharing, and collision risk, then identify which details come from 3GPP and which come from regional regulation.

!warning[**“Unlicensed means no rules”.**

Unlicensed access avoids individual spectrum licensing; technical regulation still applies. Band, power, occupancy, sensing, and device-class requirements remain jurisdiction-specific.]

!warning[**“LBT is NR initial access”.**

LBT is a channel-access procedure that gates a transmission. Initial access is the synchronization, system-information, and random-access path by which a UE joins a cell. NR-U uses both.]

!warning[**“A successful LBT owns the channel”.**

It permits bounded occupancy under applicable conditions. Hidden nodes and other technologies can still interfere, and maximum COT prevents indefinite use.]

!warning[**“Type 2 means no sensing”.**

Type 2 uses shorter sensing under specific relationships and gaps. It is conditional.]

!warning[**“LBT happens every millisecond”.**

Access attaches to transmissions, gaps, and COT state. Numerology and scheduling vary. State the access occasion rather than inventing a fixed period.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-19-NR-in-Unlicensed-Spectrum|Chapter 19]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00019-2)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_NR_Unlicensed.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| CCA | Clear-channel assessment | energy-sensing decision before transmission. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| CG | Configured grant | preconfigured uplink opportunity. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| CG-DFI | Configured-grant downlink feedback information | feedback for configured-grant transmissions. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| COT | Channel occupancy time | bounded transmission occupancy after access. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| CW | Contention window | range controlling random backoff selection. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| DCI | Downlink control information | dynamic NR control/scheduling information. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| DL | Downlink | gNB-to-UE direction. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| gNB | next-generation NodeB | NR base station and possible COT initiator. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| HARQ | Hybrid automatic repeat request | link retransmission process affected by contention. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| LAA | Licensed assisted access | LTE coexistence precedent. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| LBT | Listen before talk | shared-spectrum channel-access principle. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| NR-U | NR in unlicensed spectrum | NR operation under shared-spectrum rules. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| PDCCH | Physical downlink control channel | scheduled control channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| PDSCH | Physical downlink shared channel | scheduled downlink data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| PUSCH | Physical uplink shared channel | scheduled/configured uplink data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| RRC | Radio Resource Control | configuration protocol. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| SSB | Synchronization signal/PBCH block | discovery-burst component. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| UE | User equipment | terminal and possible responding/initiating node. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |
| UL | Uplink | UE-to-gNB direction. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/37_series/37.213/37213-i60.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $CW$ | contention-window upper value/context | integer |
| $N$ | selected backoff counter | sensing-slot count |
| $T_{sl}$ | eligible sensing-slot duration | s |
| $T_{backoff}$ | idle-slot countdown contribution | s |
| $E[N]$ | expected selected counter | sensing-slot count |
| $E[T_{backoff}]$ | expected ideal backoff contribution | s |
| $T_{COT}$ | channel occupancy duration | s |
| $P_{th}$ | applicable sensing threshold | dBm or dBm/MHz per rule |
| $B_{occ}$ | occupied bandwidth | Hz |
