---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 10
title: Physical-Layer Control Signaling
language: en
course_units:
- U11
- U12
- U13
- U14
release_baseline: 18
---

# STAR-10 — Physical-Layer Control Signaling

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Before a phone can receive data, it has to be told where the data is: which slot, which resource blocks, which modulation, which retransmission process. That instruction is small, urgent, and has a peculiar property — it cannot itself be scheduled, because it *is* the scheduling. If the instruction had to wait for an instruction, nothing would ever start. So control gets a noticeboard of its own.

![[99 Attachments/5G/Concept Figures/STAR-10-Physical-Layer-Control-Signaling-Concept.png|Physical-layer control signalling explained as a noticeboard]]

*Concept figure: Physical-layer control signalling explained as a noticeboard.*

The board is the downlink control channel. The base station pins notes on it, each addressed by a name that only one phone knows — an RNTI. The name is not written on the note; it is mixed into the note's seal, so a note only decodes for the phone whose name fits. The board occupies only part of the hall, a region called a control resource set, and each phone checks it only at agreed times, its search space. A phone cannot tell in advance which note is its own, so it tries to unseal every candidate with its name — blind decoding — and the specification caps how many candidates it may be asked to try. Notes come in sizes: a phone with a poor signal gets a larger note with more redundancy, the aggregation level. And there is a reply slip, the uplink control channel, for the shortest messages in the system: got it, send again, the channel is good, I have something to send.

The chapter is the design of the board, the notes, the reading rules, and the reply slip. Control is coded with a different code from data — Polar rather than LDPC — because its notes are tens of bits rather than thousands, and it is never retransmitted: a note that is not read is simply never known to have existed, which is why the phone must try so hard to read it. Everything a scheduler decides reaches a phone through this board. Star 31 covers the same board from the specification's side, clause by clause.

**The question this chapter answers.** How does a device discover and interpret the control information that schedules NR transmissions?

!important[**The short answer.** The base station places a coded DCI payload on PDCCH resources inside a configured control resource set. The device monitors configured search-space candidates, decodes the DCI addressed to it, and then applies the indicated time, frequency, modulation, HARQ, and power-control decisions. In the other direction it reports acknowledgements, channel state, and scheduling requests on PUCCH, or multiplexed onto PUSCH when it has data to send.]

Names you will meet in this note: Physical Downlink Control Channel (PDCCH), Downlink Control Information (DCI), control resource set (CORESET), resource-element group (REG), control-channel element (CCE), aggregation level (AL), Radio Network Temporary Identifier (RNTI), common and UE-specific search space (CSS, USS), Physical Uplink Control Channel (PUCCH), Uplink Control Information (UCI), scheduling request (SR), HARQ acknowledgement (HARQ-ACK), Slot Format Indicator (SFI), downlink assignment index (DAI).

## 2. Where you are in 5G

Section 1 explained that the instruction saying where the data is cannot itself be scheduled. The map below shows where that instruction travels in 5G: the control channels on both sides of the grid.

![[99 Attachments/5G/Locator Maps/STAR-10-Where-You-Are-in-5G.png|Where Star 10 sits in the whole 5G system]]

*Locator: Where Star 10 sits in the whole 5G system.*

This chapter lights the data-plus-control box in the procedures band and the channels-and-signals box in the foundations. It is the channel through which the scheduler of Star 14 speaks, the acknowledgements of Star 13 return, and the reports of Star 08 are carried. The first note a phone ever reads, for the system information of Star 16, is at a position fixed by a table so that it can be found before anything is configured.

The Knowledge Structure Map sorts control information by direction — the DCI formats on the downlink and the UCI types on the uplink — and explains why the two use Polar rather than LDPC codes. The mechanism diagram draws blind decoding as a budget: the four constraints that narrow the search, and the specified cap on candidates per slot.

![[99 Attachments/5G/Knowledge Maps/STAR-10-Physical-Layer-Control-Signaling-Knowledge Structure Map.png|STAR-10 system-position map]]

*Knowledge map: The downlink and uplink control information, sorted by direction.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-10-PDCCH-Receiver-Decision-Chain.png|PDCCH receiver decision chain from configuration to scheduled data]]

*Mechanism: How a device finds its PDCCH, and the budget that bounds the search.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: PDCCH and CORESET → candidate monitoring and DCI → resource assignment → uplink-control formats → receiver action.


## 3. The textbook road

Section 2 placed the control channels. The road below walks through the chapter in the book's order: the downlink control path, the formats it carries, then uplink control and its formats.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base, including the author's questions at the end. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 Content

The road begins with the reason control signalling exists: a shared channel is only shareable if every device is told what part is theirs.

!important[A shared channel is only shareable if every device is told, every slot, what part of it is theirs. Control signalling is that telling, and without it the shared channel of Star 06 could not be shared at all.]

### 3.2 10.0 Overview (what this chapter sets up)

Section 3.1 gave the reason; this section gives the chapter's three themes against LTE before the details begin.

The chapter explains how NR delivers layer-one and layer-two control over the air: the downlink control channel, where it may live, how devices find it by blind decoding within search spaces, and what it carries. Against LTE, three themes stand out. NR decouples where control sits — the control resource set — from who is addressed — the search space. It supports beamformed control with its own demodulation reference signal. And it removes LTE's separate format and HARQ indicator channels, so that the design scales to wide bandwidths and to devices of very different radio capability. Figure 10.1 shows the pipeline from the device's side: CCE-to-REG mapping, candidate selection in a search space, and blind decoding of the PDCCH that carries the DCI; it sets the vocabulary for the whole chapter.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.1 shows the pipeline from the device's side: CCE-to-REG mapping, candidate selection in a search space, and blind decoding of the PDCCH that carries the DCI; it sets the vocabulary for the whole chapter.*

### 3.3 10.1 Downlink: the control path the UE follows

With the themes named, this section follows the path a device takes every slot: which regions it watches, which candidates it tries, and what it accepts.

Each slot the device monitors specific time–frequency regions using its search-space sets. Inside a region, candidate control channels built from control-channel elements may carry a DCI. The device blind-decodes the candidates and accepts only those whose RNTI-scrambled CRC checks.

#### 3.3.1 10.1.1 Physical Downlink Control Channel (PDCCH)

The PDCCH is the physical channel that carries DCI. Each instance is processed independently, and a 24-bit CRC — longer than LTE's — is attached and scrambled with an RNTI. The device recomputes the scrambled CRC; if it matches, the message is both error-free and intended for that device or group. A PDCCH occupies one, two, four, eight, or sixteen control-channel elements, the aggregation level, and the elements are formed from resource-element groups inside a control resource set by either a non-interleaved mapping, which keeps a whole element together, or an interleaved one, which spreads it in frequency for diversity. Each PDCCH carries its own demodulation reference signal, denser than LTE's, so that it can be beamformed transparently; a wideband reference can be configured to allow interpolation across bundles when frequency continuity matters more than beamforming.

Figure 10.2 shows the bit-level chain that turns a DCI payload into a PDCCH — CRC, RNTI scrambling, Polar coding, rate matching, QPSK. Figure 10.5 compares the two CCE-to-REG mappings, with bundle sizes of two, three, or six depending on the region's duration. Figure 10.6 contrasts per-PDCCH reference signals with the wideband option.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.2 shows the bit-level chain that turns a DCI payload into a PDCCH — CRC, RNTI scrambling, Polar coding, rate matching, QPSK.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.2 shows the bit-level chain that turns a DCI payload into a PDCCH — CRC, RNTI scrambling, Polar coding, rate matching, QPSK.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.2 shows the bit-level chain that turns a DCI payload into a PDCCH — CRC, RNTI scrambling, Polar coding, rate matching, QPSK.*

> [!book] Book expansion
> PDCCH is the physical carrier for a control codeword; it does not itself define the meaning of every DCI field. Resource mapping, coding, monitoring, and data-channel interpretation are deliberately split across specifications. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 10, pp. 197–241, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).

> [!spec] 3GPP reality check
> PDCCH mapping is [TS 38.211 V18.9.0, clause 7.3.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); DCI coding and field formats are TS 38.212 V18.8.0, clause 7.3.

External source: [TS 38.211 V18.9.0, clause 7.3.2.2, PDF page 135](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip). The reproduced image is omitted from this distribution.

*Source excerpt: 3GPP TS 38.211 V18.9.0, clause 7.3.2.2, PDF p. 135, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), accessed 2026-08-04. Retained for course review.*

> [!engineering] ShareTechnote engineering view
> The [PDCCH page](https://www.sharetechnote.com/html/5G/5G_PDCCH.html) separates CORESET, CCE aggregation, candidate monitoring, and DCI into distinct steps, which is the right way to learn them.

External source: [PDCCH transport-process overview](https://www.sharetechnote.com/html/5G/5G_PDCCH.html). The reproduced image is omitted from this distribution.

*Source excerpt: ShareTechnote, [5G/NR PDCCH](https://www.sharetechnote.com/html/5G/5G_PDCCH.html), transport-process overview, accessed 2026-08-04.*

#### 3.3.2 10.1.2 Control Resource Set (CORESET)

A control resource set is the time–frequency rectangle in which PDCCHs may be placed. Unlike LTE's control region, whose size varied slot by slot and had to be signalled, an NR region is fixed in size, which simplifies both ends and helps latency. Control and data can share the region: the data channel may start before the region ends, and unused control resources can be reused for data through the reserved-resource mechanism of Star 09, with the DCI telling the device how to rate-match around them. The CCE-to-REG mapping is a property of the region, one per region, so different regions on the same carrier can choose differently. Figure 10.4 shows the reuse of region resources; Figures 10.7 show spatial quasi co-location, in which a region's reference signal is linked to a CSI-RS or synchronisation block so that the device knows which receive beam to use while blind-decoding.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.4 shows the reuse of region resources; Figures 10.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.4 shows the reuse of region resources; Figures 10.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.4 shows the reuse of region resources; Figures 10.*

> [!book] Book expansion
> A CORESET defines a bounded time-frequency search region and its REG-to-CCE organisation. Search-space configuration then tells a device which candidate locations and aggregation levels to monitor. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 10, pp. 197–241, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).

> [!spec] 3GPP reality check
> CORESET mapping stays in TS 38.211 V18.9.0, clause 7.3.2.2; [TS 38.213 V18.8.0, clause 10.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) owns monitoring occasions and candidates.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [search-space page](https://www.sharetechnote.com/html/5G/5G_SearchSpace.html) makes clear why region location and candidate monitoring are related but not the same thing.

#### 3.3.3 10.1.3 Blind decoding & search spaces

!important[Search spaces exist to bound the device's work. NR restricts the candidate locations and aggregation levels a device must try, and limits the number of distinct DCI sizes it must monitor; the search space is that curated set at a monitoring occasion. A search-space set ties several aggregation-level-specific search spaces to one region, so a device can monitor different aggregation levels on the same time–frequency resource and the network can adapt the control code rate by choosing the level; up to ten sets per bandwidth part are allowed.

At each occasion the device decodes its candidates, and a candidate is valid only if the CRC checks — otherwise it was not transmitted, was corrupted, or was for someone else. The network can address a device only on elements that belong to that device's configured search spaces. Against LTE, NR adds aggregation level sixteen for extreme coverage and lets the candidate count per level be configured, so blind decodes can be spent where they matter. Figure 10.8 shows candidate counts varying by level and slot and motivates the prioritisation of common over device-specific spaces when the budget is tight; Figure 10.9 shows two devices with different search spaces inside the same region, sharing the resource but not the candidate map.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.8 shows candidate counts varying by level and slot and motivates the prioritisation of common over device-specific spaces when the budget is tight; Figure 10.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.8 shows candidate counts varying by level and slot and motivates the prioritisation of common over device-specific spaces when the budget is tight; Figure 10.*

> [!book] Book expansion
> Blind decoding is a constrained hypothesis test. The device tries configured candidate, format, and RNTI combinations, checks the CRC, and accepts only a valid addressed message. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 10, pp. 197–241, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).

> [!spec] 3GPP reality check
> The monitoring bound is TS 38.213 V18.8.0, clause 10.1, Table 10.1-2 — 44 candidates per slot at 15 kHz, falling to 20 at 120 kHz; CRC attachment and DCI coding are TS 38.212 V18.8.0, clause 7.3.

> [!engineering] ShareTechnote engineering view
> The [DCI page](https://www.sharetechnote.com/html/5G/5G_DCI.html) is a practical index of formats; exact field presence still comes from the frozen TS 38.212 clause.

#### 3.3.4 10.1.4 Downlink scheduling assignments — DCI 1_0, 1_1, 1_2

From how DCI is carried to what it contains. Format 1_1 is the full downlink assignment; 1_0 is the compact fallback that works before the device is fully configured; 1_2 is a further format with configurable field sizes. At a high level the fields are the resource allocation within the active bandwidth part, the modulation and coding scheme, the HARQ process, new-data indicator, and redundancy version, the number of transport blocks, and pointers to the data channel's reference-signal configuration; exact presence and size depend on the format. Table 10.1 maps formats to search spaces and RNTIs — C-RNTI for device-specific data, and the system-information, random-access, temporary, and paging identifiers for common operations. Table 10.2 compares the three downlink formats field by field when addressed by C-RNTI.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Table 10.2 compares the three downlink formats field by field when addressed by C-RNTI.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Table 10.2 compares the three downlink formats field by field when addressed by C-RNTI.*

### 3.4 10.1.5 Uplink Scheduling Grants — DCI 0_0, 0_1, 0_2

Section 3.3 ended with downlink assignments. This section turns to the uplink grants that mirror them, and the fallback formats that survive a reconfiguration.

Uplink grants mirror the downlink assignments: 0_1 is the full grant, 0_0 the fallback for when device and network may disagree about configuration — during or after a reconfiguration, for instance — and 0_2 the Release 16 variant tuned for low-latency traffic. The fallback formats 0_0 and 1_0 are the same size, which saves a blind decode. The field groups cover resources — carrier, bandwidth part, supplementary uplink, allocation type, time-domain index, hopping — the transport block, HARQ bookkeeping including the downlink assignment index and code-block-group information, multi-antenna settings such as the sounding resource indicator and precoding, and power control. Table 10.3 lists the fields with their release tags.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Table 10.3 lists the fields with their release tags.*

### 3.5 10.1.6 Slot Format Indication — DCI 2_0

Grants schedule data; the next formats carry group commands. This section starts with the slot format, which tells devices the direction of each symbol under dynamic TDD.

Under dynamic TDD a device cannot infer which symbols are downlink, uplink, or flexible, so it is told: format 2_0, addressed with the SFI-RNTI, and to keep the blind-decoding load down the device is told in advance which one or two candidates may carry it. The same format supports search-space switching and resource-block-set availability in unlicensed operation.

### 3.6 10.1.7 Preemption Indication — DCI 2_1

Section 3.5 told devices where they may listen. This section handles the case where urgent traffic overwrote data already sent, and tells the victim what to discard.

When urgent traffic arrives, the network may overwrite part of a downlink transmission already scheduled to another device. Format 2_1, addressed with the INT-RNTI, tells that device afterwards which resources were taken, so that it discards the corrupted soft bits rather than combining them. Star 20 gives the context.

### 3.7 10.1.8 Uplink Power Control Commands — DCI 2_2

A device on a configured grant never receives the dynamic grant that would carry its power command. This section supplies that command by another format.

A device on a configured grant receives no dynamic uplink grant and therefore no power-control field in one. Format 2_2, addressed with a TPC-RNTI and sized to match the fallback formats, carries power adjustments for several devices at once, so that link quality is maintained without adding a new DCI size to monitor.

### 3.8 10.1.9 SRS Control Commands — DCI 2_3

Section 3.7 controlled data power; this section controls the power and triggering of the sounding signal separately.

When sounding power is decoupled from data power, format 2_3 carries two power bits and two request bits per device, again sized to the fallback formats, so that channel sounding stays stable for scheduling and beamforming.

### 3.9 10.1.10 Uplink Cancellation Indicator — DCI 2_4

Pre-emption in Section 3.6 was a downlink story. This section adds its Release 16 uplink counterpart, the cancellation indicator.

Release 16 added the uplink counterpart of pre-emption: format 2_4, addressed with the CI-RNTI, tells a device to stop an uplink transmission already under way so that a more urgent one, or a coexistence rule, can be honoured.

### 3.10 10.1.11 Soft Resource Indicator — DCI 2_5

The next format serves a relay rather than a phone: it lends the relay its soft resources slot by slot.

A relay node's soft resources are lent by its parent slot by slot. Format 2_5, addressed with the AI-RNTI, says whether a time resource is available for the relay's own access link. Star 22 gives the context.

### 3.11 10.1.12 DRX Activation — DCI 2_6

The last group format serves power saving: it tells a device before its sleep cycle whether waking is worth it.

Format 2_6 carries the Release 16 wake-up signal and cell-dormancy control, so that a device can be told before its discontinuous-reception cycle whether there is any point in waking. Telling a device it may keep sleeping is itself a power saving.

### 3.12 10.1.13 Sidelink Scheduling — DCI 3_0, 3_1

Sections 3.5 to 3.11 covered group commands for the cell. This section covers the formats that schedule sidelink, where a phone talks to another phone.

When the network schedules sidelink transmissions, format 3_0 grants NR sidelink resources and 3_1 grants LTE sidelink resources from an NR cell; 3_1 is padded to the size of 3_0 so the two cost one blind decode. Star 23 covers the sidelink itself.

### 3.13 10.1.14 Signaling of Frequency-Domain Resources (types 0/1/2)

Every format above must name resources compactly. This section shows the three encodings that keep the frequency part of a grant small.

A bandwidth part can be hundreds of resource blocks wide, and naming blocks one by one would swamp the DCI. Three encodings keep it small. Type 0 is a bitmap over groups of blocks, the group size chosen per bandwidth part to shorten the map. Type 1 encodes a contiguous allocation as a start and a length, which is smaller still. Type 2, from Release 16, encodes interlaced uplink allocations for unlicensed operation. Virtual blocks map to physical ones without interleaving for type 0, and with or without it for downlink type 1 under a DCI bit. Figure 10.10 contrasts the bitmap and the start-plus-length encodings.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.10 contrasts the bitmap and the start-plus-length encodings.*

| Topic | NR | LTE | Why it matters |
| --- | --- | --- | --- |
| Scope of allocation | **Per BWP** (Type 0/1/2) | Whole carrier (no BWPs) | NR decouples scale → smaller DCIs. |
| Interlaced UL | **Type 2 (R16)** | N/A | NR-U coexistence. |
| VRB→PRB | Interleaved option for DL Type-1 | Simpler mapping | More scheduler freedom. |

> [!book] Book expansion
> A decoded allocation field is not a physical frequency until the device applies the configured allocation type, the bandwidth-part reference, and the table rules. The same principle holds for time-domain assignment. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 10, pp. 197–241, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).

> [!spec] 3GPP reality check
> Downlink allocation interpretation is [TS 38.214 V18.10.0, clause 5.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); uplink is clause 6.1.2.

> [!engineering] ShareTechnote engineering view
> The [scheduling page](https://www.sharetechnote.com/html/5G/5G_Scheduling.html) traces DCI fields to the resulting data-channel resources with worked examples.

### 3.14 10.1.15 Signaling of Time-Domain Resources

Section 3.13 named frequency. This section names time with an index into a configured table, and explains why the table exists.

Time placement varies with dynamic TDD, control overhead, and cross-slot scheduling, and naming slot, start, and length in every grant would cost too many bits. Instead the DCI carries an index into a table configured by RRC, separately for downlink and uplink, whose rows encode slot offset, start symbol, length, and for the downlink the mapping type, with start and length jointly encoded to exclude invalid combinations. Release 16 adds columns for repetition and multi-transport-block operation, and default tables serve until the configured ones arrive. Figure 10.11 shows the index-to-row relation.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.11 shows the index-to-row relation.*

| Topic | NR | LTE | Why it matters |
| --- | --- | --- | --- |
| Signaling | **Table index (DL/UL)** | Implicit/limited patterns | NR scales to dynamic TDD & repetition. |
| Repetitions | **R16 via table columns** | Limited | URLLC coverage/latency. |

### 3.15 10.1.16 Signaling of Transport-Block Sizes (TBS)

Frequency and time fix how many resource elements a grant contains. This section turns that count into a transport block size by calculation rather than by lookup.

LTE looked block sizes up in tables, and NR's range of bandwidths, durations, and overheads would make such tables enormous. So NR computes. A five-bit MCS index selects modulation and code rate from one of several tables — the 256QAM table, or a robust table selected by a dedicated RNTI. The usable resource elements are counted after subtracting reference signals and configured overhead; layers, modulation order, and code rate give an intermediate bit count; and quantisation turns it into a size the LDPC code handles well. Reserved MCS entries carry retransmissions, which change modulation only and keep the size. Figure 10.12 sketches the pipeline; Star 09's mechanism figure works one case in full.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.12 sketches the pipeline; Star 09's mechanism figure works one case in full.*

| Topic | NR | LTE | Why it matters |
| --- | --- | --- | --- |
| TBS derivation | **Formula + small table** | **Tables** | NR scales to wide BW/durations. |
| Robust MCS | **MCS-RNTI selects robust table** | Fixed | Reliability control for critical data. |

### 3.16 10.2 Uplink — Overview

Sections 3.3 to 3.15 were the downlink. This section opens the uplink, where control carries three things of very different size.

!note[Uplink control carries three things of very different size: acknowledgements, channel-state reports, and scheduling requests. When the device has no data to send they go on PUCCH, in short or long formats; when it has data they are multiplexed onto PUSCH, because transmitting both channels at once strains the power amplifier. Under carrier aggregation two PUCCH groups may be configured to balance the feedback load. Figure 10.13 shows the two groups.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.13 shows the two groups.*

> [!book] Book expansion
> Uplink control selects a PUCCH format or multiplexes UCI on PUSCH according to payload and scheduling context. HARQ-ACK, scheduling request, and CSI are information types. Dahlman, Parkvall, and Sköld, 2nd ed., Chapter 10, pp. 197–241, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).

> [!spec] 3GPP reality check
> PUCCH physical formats are TS 38.211 V18.9.0, clause 6.3.2; [TS 38.213 V18.8.0, clause 9](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) owns resource selection and procedure.

> [!engineering] ShareTechnote engineering view
> The [PUCCH page](https://www.sharetechnote.com/html/5G/5G_PUCCH.html) compares formats 0 to 4 by payload and duration, which is the fastest way to remember which is which.

### 3.17 10.2.1 Basic PUCCH Structure

The three kinds of uplink control need containers. This section introduces the two families of PUCCH formats, short and long.

Two families. Short formats occupy one or two symbols, usually at the end of a slot: format 0 for up to two bits, format 2 for more. Long formats occupy four to fourteen symbols for coverage: format 1 for up to two bits, formats 3 and 4 for more, with format 4 allowing two or four devices to share a resource by code multiplexing. Some formats support interlaced mapping for unlicensed operation. The design balances payload, coverage, multiplexing, and the linearity of the device's amplifier.

### 3.18 10.2.2 PUCCH Format 0 (short, ≤2 bits)

The first format is the smallest. This section shows how it carries one or two bits without modulating anything onto a carrier.

Format 0 carries one or two bits by sequence selection: the bits choose a phase rotation of a length-twelve base sequence, so nothing is modulated onto a carrier and the peak-to-average ratio stays very low. A reference rotation lets several devices share the resource, and cyclic-shift hopping randomises interference. Figure 10.14 shows the mapping and Figure 10.15 the rotations for the acknowledgement and scheduling-request combinations.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.14 shows the mapping and Figure 10.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.14 shows the mapping and Figure 10.*

### 3.19 10.2.3 PUCCH Format 1 (long, ≤2 bits)

When the same one or two bits need more energy, this section spreads them over a long format.

When one or two bits need more energy to reach the base station, format 1 modulates them onto a length-twelve sequence, spreads the result across symbols with an orthogonal code, and devotes about half the symbols to reference signals for coherent combining; frequency hopping is optional, with spreading per hop. Figure 10.16 shows both cases.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 10.16 shows both cases.*

### 3.20 10.2.4 PUCCH Format 2 (short, \>2 bits)

Sections 3.18 and 3.19 carried at most two bits. This section is the short format for more, with real channel coding.

For more than two bits in a short transmission — a channel report with an acknowledgement, say — format 2 applies a CRC, Reed–Muller coding for up to eleven bits or Polar coding beyond, scrambling with the device's RNTI and cell identity, and QPSK, over one or two symbols and as many resource blocks as the payload and maximum code rate require, with a reference signal every third subcarrier. Figure 10.17 sketches it.

### 3.21 10.2.5 PUCCH Format 3 (long, \>2 bits)

Section 3.20 was short; this section carries the largest payloads over a long format with the amplifier still efficient.

Format 3 carries the largest payloads with coverage and amplifier efficiency intact: the same coding as format 2, then QPSK or π/2-BPSK, then DFT precoding, with optional frequency hopping and at least one reference symbol per hop. The most critical bits — acknowledgements, requests, and the first part of a channel report — are placed nearest the reference signal. Figure 10.18 shows the pipeline and the hops.

### 3.22 10.2.6 PUCCH Format 4 (long, \>2 bits, code-multiplexed)

Format 3 uses a whole resource per device. This section adds the spreading that lets several devices share it.

Format 4 is format 3 with block spreading per symbol by an orthogonal sequence of length two or four before the DFT, so that two or four devices share one set of resource blocks. Figure 10.19 outlines it.

### 3.23 10.2.7 Resources & Parameters for PUCCH Transmission

The formats are defined; this section explains how a device knows which resource to use, and why NR needed more freedom here than LTE.

LTE tied each format to a fixed resource; NR needs more freedom for carrier aggregation, dynamic TDD, and beams. A device is configured with up to four PUCCH resource sets — set zero for payloads up to two bits with formats 0 and 1, the others for larger payloads with formats 2, 3, and 4 — and a resource indicator in the DCI picks a resource from the set. If set zero holds more than eight resources, the three-bit indicator is combined with the index of the first control-channel element, which can reproduce LTE's implicit rule with a zero-bit indicator. Periodic reports and scheduling requests use their own configured resources. Figure 10.20 shows the selection.

### 3.24 10.2.8 Uplink Control Signaling on PUSCH

Sections 3.17 to 3.23 assumed the device had no data to send. This section moves the control onto the data channel when it does.

Transmitting PUCCH and PUSCH at once forces the amplifier to back off and worsens out-of-band emissions, so when the device has data its control is carried on the data channel instead. Only acknowledgements and channel reports move; the scheduling request is handled otherwise. Up to two acknowledgement bits are punctured into the data; larger acknowledgement loads are rate-matched around. The device always knows how much space to reserve because the uplink downlink-assignment index in the DCI tells it, so a missed downlink assignment does not collapse the decoding. Critical bits go immediately after the first reference symbol, and the transmit power is held constant while the fraction given to control varies.

| Topic | NR | LTE | Why it matters |
| --- | --- | --- | --- |
| Simultaneous data+UCI | **Prefer UCI on PUSCH**; puncture≤2 ACK bits else rate-match | Puncture ACK on UL-SCH | NR scales to large ACK loads (CA/CBG) safely. |
| PUCCH resourceing | **Resource sets + indicator** | Tighter coupling | NR gives scheduler control & CA flexibility. |

### 3.25 Questions

The road ends with the questions a reader asked while studying the chapter, and their answers.

**“DCI is from L2, sent on PDCCH; PDCCH mapped by CCE; CORESET is central; blind search; search spaces; aided by DM-RS/QCL.”** Yes, conceptually right. Control information originating partly in MAC is packaged as DCI and carried on PDCCH; PDCCH occupies CCEs inside a CORESET; devices blind-decode the candidates their search spaces define; and reliability and beam selection are aided by the PDCCH's reference signal and its quasi co-location with a CSI-RS or synchronisation block.

**“Can I treat DCI the same as CORESET? Or does CORESET include DCI?”** No — different layers of the onion. DCI is the payload, the bits. PDCCH is the physical channel that carries the DCI, built from CCEs. CORESET is the time–frequency region where PDCCHs may be placed; it includes PDCCH resources. So: DCI ∈ PDCCH ∈ CORESET — content in channel in region.

**“Why call items in the search space ‘PDCCH candidates’? Could there be no PDCCH there, or not for me?”** Exactly. A search space is a set of potential locations, by aggregation level and position, that a device must try. At a monitoring occasion it attempts to decode each candidate. If the CRC checks, the candidate is valid and, through the RNTI, for this device or its group; if not, it was not transmitted, was corrupted, or was for someone else, and the device ignores it.

**Understanding “by configuring a CORESET and a search space set, the device can monitor control channels with different aggregation levels but using the same time-frequency resource.” And Fig. 10.9 intuition?** The same region — the same time–frequency resource — hosts several search spaces at different aggregation levels for one device. The level changes only how many CCEs are aggregated, and hence the code rate; so several level-specific search spaces overlap inside one region and the scheduler picks the level per device and channel condition. Figure 10.9's lesson is that the network can address a device only on CCEs belonging to that device's search spaces; overlapping use by others can block some levels, which is why devices are given different, often randomised, search spaces.

**“Is DCI the same as a DCI format? CSS/USS and RNTIs/CRC?”** DCI is the message; a DCI format is the template of type and size that says which fields are present. NR deliberately keeps purpose and size coupled in formats, and when two formats share a size a few bits disambiguate. Search spaces are common or device-specific, and the CRC is scrambled with an RNTI — the C-RNTI for device-specific, common or group identifiers for common — so the CRC check is how a device learns a candidate was meant for it. Set zero, the first common search space, hangs off CORESET 0 through the MIB; other sets arrive by RRC.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the four documents that share the board: the channel, the note, the rules and the data procedures.

Four documents share the board. TS 38.211 defines the channel: the resource-element group, the control-channel element of six groups, the aggregation levels, and the mapping into a region. TS 38.212 defines the note: the DCI formats field by field, and the coding — a 24-bit CRC scrambled with the RNTI, then Polar coding. TS 38.213 defines the reading rules: search spaces, monitoring occasions, the candidate budget per slot, and the uplink reply on PUCCH. And TS 38.331 configures all of it. The figure shows the numbers, because they are the ones a first demo gets wrong.

![[99 Attachments/5G/Protocol Figures/STAR-10-Physical-Layer-Control-Signaling-Protocol.png|The four documents that define the control channel, its message, its reading rules and its reply]]

*Protocol figure: The four documents that define the control channel, its message, its reading rules and its reply.*

| Behavior | Owner | Trigger/input | Frozen Rel-18 locator | Book-era → Rel-18 note |
| --- | --- | --- | --- | --- |
| PDCCH resource mapping | gNB transmitter; UE receiver | configured CORESET and search space | TS 38.211 V18.9.0, clause 7.3.2.2 | mapping remains clause-owned; later DCI formats do not redefine it |
| DCI coding and fields | gNB and addressed UE | scheduling/control decision | TS 38.212 V18.8.0, clause 7.3 | Rel-18 contains additional format/field conditions |
| Candidate monitoring | UE | common or UE-specific search-space configuration | TS 38.213 V18.8.0, clause 10.1 | monitoring rules include later capability and feature interactions |
| Time/frequency allocation | UE PHY | decoded DCI plus RRC-configured tables | TS 38.214 V18.10.0, clauses 5.1.2 and 6.1.2 | later releases add allocation conditions without changing ownership |
| Uplink control | UE transmitter; gNB receiver | HARQ-ACK, SR, and CSI | TS 38.211 V18.9.0, clause 6.3.2; TS 38.213 V18.8.0, clause 9 | format use is configuration- and payload-dependent |

!note[**When you build or run a demo.** The very first note a phone reads is the one that points to SIB1, and its board — CORESET 0 — is at a position fixed by the tables of TS 38.213 clause 13, selected by two small indices in the MIB. If those indices are wrong for the band and subcarrier spacing, no phone will ever attach, and this is the single most common first-demo failure. After that, the configuration names the aggregation level the scheduler prefers, which DCI formats it uses, and the PUCCH format and scheduling-request period, and the log shows each note as it was pinned: an RNTI, a format, and the resource blocks it granted. When a phone attaches but throughput is poor, check whether it is receiving its notes — a high control-channel miss rate at a low aggregation level is a sign the level should rise.]

The table is a navigation layer; the cited clauses hold the rules. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define the pieces; the trace below strings them together as one control event.

> [!note] End-to-end trace
> PDCCH and CORESET → candidate monitoring and DCI → resource assignment → uplink-control formats → receiver action.

Read each arrow as a handoff from one step to the next. Configuration constrains the available choices; the transmitter acts; the receiver measures or decodes; the result enables the next scheduled step.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** U11–U14: use this chapter to connect PDCCH/DCI to transport-channel processing, scheduling, HARQ, and uplink feedback.

!warning[**CORESET is not DCI.** A CORESET defines where PDCCH resources can exist; DCI is the coded bit payload whose fields tell the UE what action to take.]

!warning[**Blind decoding is bounded.** The UE does not search every RE or every payload length. RRC and common-search-space rules constrain candidates, aggregation levels, formats, and RNTI interpretations.]

!warning[**A grant does not carry user data.** DCI points to the PDSCH or PUSCH allocation and its interpretation. The transport block is carried on the scheduled shared channel.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 10, pp. 197–241, DOI [10.1016/B978-0-12-822320-8.00010-6](https://doi.org/10.1016/B978-0-12-822320-8.00010-6).
2. 3GPP, *TS 38.211 V18.9.0: NR; Physical Channels and Modulation*, clauses 6.3.2 and 7.3.2, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).
3. 3GPP, *TS 38.212 V18.8.0: NR; Multiplexing and Channel Coding*, clauses 6.3 and 7.3, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
4. 3GPP, *TS 38.213 V18.8.0: NR; Physical Layer Procedures for Control*, clauses 9, 10, and 13, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
5. 3GPP, *TS 38.214 V18.10.0: NR; Physical Layer Procedures for Data*, clauses 5.1 and 6.1, [official archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
6. ShareTechnote, [PDCCH](https://www.sharetechnote.com/html/5G/5G_PDCCH.html), [Search Space](https://www.sharetechnote.com/html/5G/5G_SearchSpace.html), [DCI](https://www.sharetechnote.com/html/5G/5G_DCI.html), and [Type-0 CSS](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html), accessed 2026-08-03.
7. Chapter 10 notes of this knowledge base (the author's reading notes, dated 2026-08-03).

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term | Primary clause |
| --- | --- | --- |
| AL | Aggregation level | TS 38.213 V18.8.0, clause 10.1 |
| CCE | Control-channel element | TS 38.211 V18.9.0, clause 7.3.2.2 |
| CORESET | Control resource set | TS 38.211 V18.9.0, clause 7.3.2.2 |
| CSS | Common search space | TS 38.213 V18.8.0, clauses 10.1 and 13 |
| DCI | Downlink control information | TS 38.212 V18.8.0, clause 7.3 |
| PDCCH | Physical downlink control channel | TS 38.211 V18.9.0, clause 7.3.2 |
| PUCCH | Physical uplink control channel | TS 38.211 V18.9.0, clause 6.3.2 |
| QCL | Quasi co-location | TS 38.214 V18.10.0, clause 5.1.5 |
| REG | Resource-element group | TS 38.211 V18.9.0, clause 7.3.2.2 |
| RNTI | Radio network temporary identifier | TS 38.321 V18.10.0, clause 7.1 |
| UCI | Uplink control information | TS 38.212 V18.8.0, clause 6.3 |
| USS | UE-specific search space | TS 38.213 V18.8.0, clause 10.1 |

Controlled two-sentence definitions are in [[5G Abbreviation Database]].

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
| --- | --- | --- |
| $L$ | PDCCH aggregation level | 1, 2, 4, 8, or 16 |
| $E_L$ | Available coded bits in the instructional model at level $L$ | bits |
| $E_1$ | Available coded bits assumed for one CCE in the example | bits per CCE |
| $K$ | Information-plus-CRC size used in the example | bits |
| $R_{eff}$ | Instructional effective code-rate proxy | dimensionless |
| $N_{CCE}$ | Available CCEs in the example CORESET | count |
| $N_{PDCCH}$ | Non-overlapping PDCCH packing upper bound | count |
