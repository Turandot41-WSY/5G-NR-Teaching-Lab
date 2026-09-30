---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 14
title: Scheduling
language: en
course_units:
- U03
- U04
- U05
release_baseline: 18
---

# STAR-14 — Scheduling

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

A scheduler is a maître d' seating a full restaurant every millisecond. It knows who is waiting and how much they want to order — the buffer status each phone reports. It knows how hungry each one is — the quality-of-service class that says a video call cannot wait and a software update can. It knows which tables are drafty tonight — the channel-quality reports of Star 08 that say which phone can use which resources well. And it knows who still owes a reply — the retransmission processes of Star 13 that must be served before new food. From all that it produces, every slot, one seating plan: which phone, which resource blocks, which modulation, which retransmission process, and when to reply.

![[99 Attachments/5G/Concept Figures/STAR-14-Scheduling-Concept.png|The scheduler explained as a maître d' seating a restaurant every millisecond]]

*Concept figure: The scheduler explained as a maître d' seating a restaurant every millisecond.*

Two things make the uplink harder than the downlink. The maître d' cannot see into a guest's bag, so a phone with data must first raise a hand — one bit, the scheduling request — then be given a tiny table on which to say how much it holds, and only then get a table of the right size. Four messages before any data moves. And a guest who eats every day at noon can be given a standing reservation — a configured grant — with no request and no wait, at the cost of a table that may sometimes sit empty. That reservation is how a factory robot gets its command through in under a millisecond.

The most important thing about the scheduler is what the standard does not say. 3GPP fixes to the bit what the scheduler may know — the reports — and what it may say — the grants. It never says how the scheduler should decide. That gap is deliberate: it is where vendors compete, and why a stadium and a factory can run different policies on identical radios. Every open-source base station has a line in its configuration that chooses the policy, and no clause governs that line.

**The question this chapter answers.** How does an NR scheduler decide which device receives time–frequency resources, transmission direction, modulation, rank, and retransmission opportunities when demand, channel quality, latency targets, and power limits change every slot?

!important[**The short answer.** 3GPP standardises the evidence, the control formats, the constraints, and the procedures through which scheduling is expressed; it does not prescribe a scheduling objective. Downlink scheduling can use buffer state, channel-state reports, HARQ state, quality of service, and implementation estimates. Uplink scheduling additionally depends on scheduling requests, buffer-status reports, power-headroom reports, sounding, configured grants, and past reception. The base station signals dynamic allocations in DCI, or sets up semi-persistent and configured behaviour through RRC and MAC.]

Names you will meet in this note: Downlink Control Information (DCI), scheduling request (SR), buffer-status report (BSR), power-headroom report (PHR), logical-channel prioritisation (LCP), prioritised bit rate (PBR), bucket-size duration (BSD), semi-persistent scheduling (SPS), configured grant (CG), pre-emption indicator (PI), discontinuous reception (DRX), wake-up signal (WUS), bandwidth part (BWP), configured-scheduling RNTI (CS-RNTI).

## 2. Where you are in 5G

Section 1 seated a restaurant every millisecond. The map below shows where the scheduler sits in 5G: inside MAC at the base station, with the reports of every phone flowing into it.

![[99 Attachments/5G/Locator Maps/STAR-14-Where-You-Are-in-5G.png|Where Star 14 sits in the whole 5G system]]

*Locator: Where Star 14 sits in the whole 5G system.*

This chapter lights scheduling in the procedures band and the MAC layer of the stack. Its inputs come from Star 08 and Star 13, its output travels on the control channel of Star 10, and its decisions are what Star 09's arithmetic turns into a transport block. Star 33 covers the MAC specification that carries the reports.

The Knowledge Structure Map draws the scheduler as the unspecified middle between specified inputs and specified outputs. The mechanism diagram is a sequence diagram of the four-message exchange an uplink grant costs, with the configured-grant shortcut beside it.

![[99 Attachments/5G/Knowledge Maps/STAR-14-Scheduling-Knowledge Structure Map.png|STAR-14 system-position map]]

*Knowledge map: What the scheduler knows, what it decides, and what it must signal.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-14-Scheduler-Decision-Loop.png|Star 14 mechanism and handoff diagram]]

*Mechanism: The four-message exchange before uplink data can move.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 14.1 Downlink Scheduling → 14.1.2 Downlink Preemption Handling → 14.2 Uplink Scheduling → 14.3 Scheduling and Dynamic TDD → 14.4 Transmissions Without a Dynamic Grant—Semi-Persistent Scheduling and Configured Grants.


## 3. The textbook road

Section 2 placed the scheduler. The road below walks through the chapter in the book's order: downlink, uplink, dynamic TDD, transmissions without a grant, then power saving.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **14.1 Downlink Scheduling**

The road begins with the downlink, where the scheduler knows everything, because it holds the data itself.

!important[Downlink scheduling is the base station deciding, slot by slot, which devices it transmits to and how. Each scheduled device receives an assignment in DCI: the time–frequency resources its data occupies, the modulation and coding scheme, the HARQ information, and the multi-antenna parameters, including the beam through a TCI state. What the scheduler needs to know depends on its strategy, but almost any strategy needs the channel conditions at the device, including their spatial properties; the buffer state of each data flow; and the priorities of the flows, including how much is waiting for retransmission. Figure 14.1 shows that the control channel carrying an assignment may point to its own carrier — self-scheduling — or to another — cross-carrier scheduling.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.1 shows that the control channel carrying an assignment may point to its own carrier — self-scheduling — or to another — cross-carrier scheduling.*

#### 3.1.1 **Dynamic vs Semi-Persistent Scheduling**

Dynamic scheduling issues a fresh assignment for every transmission; it is the most flexible and suits bursty traffic. Semi-persistent scheduling allocates periodic resources once for predictable traffic such as voice, and the base station can still override it with a dynamic assignment when something urgent arrives.

> [!book] Book expansion
> Chapter 14 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 299–323, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00014-3)) is careful to describe the scheduler's inputs and outputs and never its algorithm, because the algorithm is outside the standard.

> [!spec] 3GPP reality check
> How a downlink assignment is interpreted — allocation types, time-domain tables, modulation and coding — is [TS 38.214 V18.10.0, clause 5.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); the assignment's fields are TS 38.212 clause 7.3.1.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [scheduling page](https://www.sharetechnote.com/html/5G/5G_Scheduling.html) traces one assignment from DCI fields to resource blocks.

### 3.2 **14.1.2 Downlink Preemption Handling**

Section 3.1 scheduled ordinary traffic. This section handles the urgent packet that arrives mid-transmission and borrows resources already given away.

Pre-emption is high-priority traffic — usually latency-critical — borrowing part of an ongoing lower-priority transmission. Figure 14.2 shows an urgent packet overlapping part of another device's data.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.2 shows an urgent packet overlapping part of another device's data.*

#### 3.2.1 **Timing of the Preemption Indicator**

The pre-emption indicator is sent after the damage has been done. Its job is to tell the affected device that part of its transmission was overwritten — in effect, "the resource elements you failed to decode were used for someone else's urgent packet; do not treat it as a channel error; the missing part will be retransmitted". It prevents the device from misreading its soft buffer rather than preventing the pre-emption itself.

#### 3.2.2 **Why the PI Can Flush Part of the Soft Buffer**

The device will already have stored soft bits from the overwritten region, and if it combined them with the retransmission they would corrupt it, because they are not its data at all. The indicator lets the base station tell the device to discard exactly that portion of its buffer.

#### 3.2.3 **Example**

The base station transmits a block, part of which is pre-empted. The device decodes what it can and stores soft bits for the rest, including the corrupted region. The base station sends the indicator marking that region; the device deletes those log-likelihood ratios. In the next retransmission the base station resends the missing code blocks, and the device combines its clean stored bits with the new ones. The indicator synchronises the two soft buffers; it does not itself trigger the retransmission.

> [!spec] 3GPP reality check
> The indicator is DCI format 2_1 in [TS 38.212 V18.8.0, clause 7.3.1.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), and the device's handling of it is TS 38.213 clause 11.2.

### 3.3 **14.2 Uplink Scheduling**

The downlink scheduler knew its own buffers. This section turns to the uplink, where it does not, and one difference changes everything.

!important[The uplink scheduler does the same job — which devices transmit, on which resources, with what parameters — with one difference that changes everything: a device cannot transmit spontaneously. It needs a grant, which is what keeps interference and fairness under control. So uplink scheduling has more parts: dynamic grants on the control channel, configured grants for periodic traffic, scheduling requests, buffer-status reports, and power-headroom reports. Figure 14.3 shows the division of labour — the scheduler controls the transport format, the device controls which logical channels fill it — and Figure 14.4 the preparation time a device needs between grant and transmission, which every design wants shorter.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.3 shows the division of labour — the scheduler controls the transport format, the device controls which logical channels fill it — and Figure 14.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.3 shows the division of labour — the scheduler controls the transport format, the device controls which logical channels fill it — and Figure 14.*

#### 3.3.1 **14.2.1 Uplink Priority Handling and Logical-Channel Multiplexing**

When a grant arrives, the device decides what goes in it. First it determines which logical channels are eligible for this grant; then how much of the grant each gets. Two grant types exist: dynamic, where the base station signals frequency, time, and modulation each time; and configured, where the device transmits on pre-arranged resources without a grant, which is what low-latency and voice traffic use. When both exist, a dynamic grant can override a configured one.

#### 3.3.2 **How Priority Handling and Buffer Levels Work**

Each logical channel carries three RRC-configured values: a priority from 1 to 16, a prioritised bit rate that is the minimum it should receive, and a bucket-size duration that says how quickly that entitlement refills. On a grant the device looks at its buffers, forms a priority metric

$$
M_i = f(\text{Priority}_i, \text{BufferLevel}_i, \text{PBR}_i)
$$

and fills the grant from the highest metric down. The product of prioritised bit rate and bucket duration is a bucket of bits that each channel should, at minimum, be allowed to send in a given time. Channels are served in priority order up to their buckets first; whatever remains is given out in strict priority order. Figure 14.5 illustrates it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.5 illustrates it.*

#### 3.3.3 **Example Scenario**

Take a video stream at priority 3 with a prioritised rate of 256 kbit/s, a voice call at priority 1 with 64 kbit/s, and background data at priority 10 with none. On a grant worth 512 kbit/s the device gives 64 to the voice call first, 256 to the video next, and the remaining 192 to background. The latency-critical flows are always served; best effort fills what is left. Prioritisation is, in effect, a small scheduler running inside the device, once per grant.

#### 3.3.4 **14.2.2 Scheduling Request (SR)**

A device with data and no grant sends a scheduling request on the uplink control channel at its next configured occasion. It is a single bit: the buffer is not empty. The base station answers with a grant, and Figure 14.6 shows the exchange. A device that already has a grant does not need the request; it sends the richer buffer-status report instead.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The base station answers with a grant, and Figure 14.6 shows the exchange.*

#### 3.3.5 14.2.3 Buffer-Status Reports

To size future grants the scheduler needs to know how much is waiting. The buffer-status report is a MAC control element, flagged by a reserved logical-channel identity in a subheader as Figure 14.7 shows, and it reports per logical-channel group — up to eight of them — the total bytes waiting across the channels in the group. It is triggered when higher-priority data arrives than is already queued, periodically under a timer, or in place of padding when a transport block has room to spare, since a report is more useful than padding.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*The buffer-status report is a MAC control element, flagged by a reserved logical-channel identity in a subheader as Figure 14.7 shows, and it reports per logical-channel group — up to eight of them — the total bytes waiting across the channels in the group.*

#### 3.3.6 **14.2.4 Power Headroom Reports (PHR)**

The power-headroom report tells the base station how much more the device could transmit before hitting its limit. It is triggered periodically, when the path loss changes by more than a threshold, or in place of padding, with a prohibit timer to bound the signalling load. Headroom is defined as

$$
PH = P_{CMAX,c} - P_{used,c}^{(no\ limit)}
$$

where $P_{CMAX,c}$ is the device's configured maximum on that carrier and the second term is the power the current allocation and modulation would require if there were no upper limit. It is not the difference between maximum and actual transmit power; it is the difference between the maximum and what the device would have used unconstrained, which is why it can be negative. Figure 14.8 shows it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.8 shows it.*

#### 3.3.7 **Interpreting the Definition of PHR**

The maximum is the device's hardware or regulatory limit — 23 dBm, say. The unconstrained requirement is what the current resource size and modulation would need to reach the target signal-to-noise ratio with an infinitely strong amplifier. If the limit is 23 dBm and the requirement is 20 dBm, the headroom is 3 dB. Give the device more resource blocks or a higher modulation and the requirement rises, so the headroom falls.

#### 3.3.8 **Why Report This to the gNB?**

The base station knows the maximum but not the instantaneous usage, which depends on the allocation, the modulation, the path loss, and the distribution of power across carriers. Only the device can compute how close it is to its limit. With the report, the scheduler avoids allocating more resource blocks than the device can power, adjusts modulation to keep the link quality, and rebalances across carriers. The report does not control power; it makes scheduling power-aware.

> [!spec] 3GPP reality check
> Scheduling request, buffer-status report, power-headroom report, and logical-channel prioritisation are [TS 38.321 V18.10.0, clauses 5.4.3 to 5.4.6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), with the report formats in clause 6.1.3; the request's occasions are TS 38.213 clause 9.2.4.

> [!engineering] ShareTechnote engineering view
> The [buffer-status report page](https://www.sharetechnote.com/html/5G/5G_MAC_CE_BSR.html) decodes a real report byte by byte, and the [scheduling request page](https://www.sharetechnote.com/html/5G/5G_SR.html) shows the request's occasions on a slot grid.

### 3.4 **14.3 Scheduling and Dynamic TDD**

Sections 3.1 and 3.3 assumed each slot had a direction. Under dynamic TDD the scheduler chooses that too; this section shows how a device learns it.

Under dynamic TDD the scheduler also decides, slot by slot, which direction a slot serves, where LTE had fixed patterns. Three mechanisms tell a device the direction: the dynamic assignment or grant it receives, a semi-static pattern from RRC, and a slot-format indication shared by a group. A full-duplex device can be scheduled in both directions independently; a half-duplex device must never be given both at once; and a configured semi-static pattern binds the scheduler too. The benefit is asymmetry — more downlink slots while streaming, more uplink while uploading — with cross-link interference between neighbouring cells as the cost to be coordinated, which Star 21 takes up.

### 3.5 **14.4 Transmissions Without a Dynamic Grant—Semi-Persistent Scheduling and Configured Grants**

Every decision so far cost a control message. This section removes the message for traffic that is periodic and predictable.

Dynamic scheduling costs a control message per transmission. For traffic that is periodic and predictable, NR removes the message: semi-persistent scheduling on the downlink and configured grants on the uplink. Figure 14.9 shows configured-grant uplink transmissions.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.9 shows configured-grant uplink transmissions.*

#### 3.5.1 **Downlink Semi-Persistent Scheduling**

The base station configures a periodic transmission by RRC and activates it once with a control message addressed by a configured-scheduling identifier instead of the ordinary one. The device then receives periodically on the fixed resources and modulation, deriving the HARQ process number from the transmission time. It keeps monitoring the control channel throughout, because a dynamic assignment can still arrive.

#### 3.5.2 Meaning of “Occasional Transmissions of Large Amounts of Data”

Semi-persistent scheduling handles the regular small packets; when a larger burst arrives — a codec frame that grew, extra control — the base station adds a dynamic assignment on top. The periodic allocation keeps the overhead low, and dynamic assignments top it up when an exception occurs, so that resources are neither wasted on a large standing allocation nor lacking when a burst comes.

#### 3.5.3 **Uplink Configured Grants**

Type 1 is fully defined by RRC — periodicity, offset, frequency, modulation — and takes effect as soon as it is configured. Type 2 has its periodicity from RRC but is activated and deactivated by the control channel, like downlink semi-persistent scheduling, and the device confirms activation with a MAC control element. With no control message per transmission, the HARQ process number is derived from the slot or symbol number so that both ends agree. Configured grants remove both the signalling and the latency of asking, which is what low-latency and repetitive uplink traffic needs.

> [!spec] 3GPP reality check
> Configured grants are [TS 38.321 V18.10.0, clause 5.8.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); downlink semi-persistent scheduling is clause 5.8.1; both are configured through TS 38.331's ConfiguredGrantConfig and SPS-Config.

### 3.6 **14.5 Power-Saving Mechanisms**

The road ends with the cost none of the above counts: the energy a device spends watching for assignments that mostly never come.

!note[A connected device spends most of its energy not on sending or receiving data but on watching the control channel for assignments that mostly never come. NR's power-saving tools all reduce that watching: discontinuous reception, wake-up signals, cross-slot scheduling, cell dormancy, and bandwidth adaptation.]

#### 3.6.1 **14.5.1 Discontinuous Reception**

Discontinuous reception lets the device switch its receiver off between periodic on-durations, during which it watches the control channel. Figure 14.10 shows the structure: the on-duration, an inactivity timer that keeps the device awake after activity, and the cycle. With no activity the device sleeps until the next cycle; with activity the inactivity timer restarts. Retransmission timers can wake it for an expected retransmission so that none is missed, and two nested cycles trade power against delay.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.10 shows the structure: the on-duration, an inactivity timer that keeps the device awake after activity, and the cycle.*

#### 3.6.2 short DRX, Long DRX, and Wake Signal Interaction

After recent activity the device uses the short cycle, waking every ten to twenty milliseconds, because recent activity predicts more. After a longer quiet spell it falls to the long cycle, sleeping for hundreds of milliseconds. A wake signal — an expired timer, arriving data, an expected retransmission, or a configured wake-up signal — brings it back. The sequence is active, then short, then long, then back to active on a wake.

#### 3.6.3 **14.5.2 Wake-Up Signals**

The wake-up signal, DCI format 2_6, tells a device before its next long cycle whether to wake at all. If no data is expected the device skips the on-duration entirely, and checking for the wake-up signal costs far less than a full monitoring period. Figure 14.11 shows it.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.11 shows it.*

#### 3.6.4 **14.5.3 Cross-Slot Scheduling for Power Saving**

Ordinarily a device must buffer received samples while it decodes the control channel, in case data follows in the same slot. If the network guarantees that data will never start before the next slot — a minimum slot offset of one — every same-slot entry in the time-domain table becomes invalid, the device need not buffer, and it can sleep until the slot where data will be. Figure 14.12 shows the two cases, and a single bit in the DCI switches between the low-latency and the power-saving mode.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.12 shows the two cases, and a single bit in the DCI switches between the low-latency and the power-saving mode.*

#### 3.6.5 **14.5.4 Cell Dormancy**

With carrier aggregation, a secondary cell can be put into a dormant state: the device stops monitoring its control channel but keeps measuring channel state and beams, so that reactivation is faster than from a fully deactivated cell. Dormancy is implemented as a bandwidth part with no control-channel monitoring, and up to five dormancy bits in DCI formats 0_1, 1_1, or 2_6 switch cells in and out of it, as Figure 14.13 shows.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Dormancy is implemented as a bandwidth part with no control-channel monitoring, and up to five dormancy bits in DCI formats 0_1, 1_1, or 2_6 switch cells in and out of it, as Figure 14.13 shows.*

#### 3.6.6 **14.5.5 Bandwidth Adaptation**

Monitoring hundreds of megahertz for a control channel that rarely carries anything is wasteful. Bandwidth adaptation keeps the device on a narrow bandwidth part for control and switches it to a wide one only when large data arrives; a DCI command widens the receiver, and a timer or explicit signal returns it to the default narrow part afterwards. Figure 14.14 shows the switch. It is discontinuous reception in the frequency domain.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 14.14 shows the switch.*

> [!spec] 3GPP reality check
> Discontinuous reception is [TS 38.321 V18.10.0, clause 5.7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); the wake-up signal is DCI 2_6 in TS 38.212 clause 7.3.1.3.7; bandwidth-part switching and dormancy are TS 38.213 clause 12; all are configured through TS 38.331.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents that specify the scheduler's inputs and outputs to the bit, and leave its decision unspecified.

The scheduler's inputs and outputs are specified to the bit, and its decision is not. TS 38.321 defines what a phone tells the scheduler — the one-bit request, the buffer-status formats and their size tables, the power-headroom report — and how the phone fills a grant by priority and bucket. TS 38.212 and TS 38.214 define what the scheduler may say back: the fields of a grant and how they are interpreted. TS 38.213 fixes the request occasions. The figure shows the values that decide how fast a demo feels, and ends with the one line no clause defines: the policy.

![[99 Attachments/5G/Protocol Figures/STAR-14-Scheduling-Protocol.png|The scheduling inputs a phone provides, the outputs a scheduler signals, and the configured values between them]]

*Protocol figure: The scheduling inputs a phone provides, the outputs a scheduler signals, and the configured values between them.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 9–13 | HARQ-ACK, PDCCH monitoring, BWP and related control procedures |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 5.1; 6.1 | PDSCH/PUSCH resource allocation and link adaptation procedures |
| TS 38.321 | V18.10.0, [38321-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.4.3–5.4.6; 6.1.3 | logical-channel prioritization, SR, BSR, PHR, and MAC CEs |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.3.2 information elements | DRX, BWP, SPS, configured-grant and bearer configuration |

!note[**When you build or run a demo.** The scheduling request period is the first latency an uplink pays, and a demo that feels sluggish on upload often has a long one. The buffer-status timers decide how current the scheduler's picture is. Each logical channel's priority, prioritised bit rate, and bucket duration are three lines that decide which traffic wins when the grant is small. A configured grant is a periodicity and a size, and it is the difference between a robot command arriving in a millisecond or in five. And the scheduler policy — round-robin, proportional-fair, or the vendor's own — is a line in the base-station configuration that no specification governs; when two demos on identical hardware behave differently, that line is usually why.]

Release 15 established flexible slot scheduling, dynamic grants, bandwidth parts, discontinuous reception, semi-persistent scheduling, configured grants, the three reports, and prioritisation. Release 16 added reliability and latency options for industrial, unlicensed, and multi-point use; Release 18 adds capability, extended-reality, and energy-efficiency refinements, and still publishes no scheduling objective. Release summaries are checked against TS 21.915, 21.916, and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix what the scheduler sees; this trace applies one proportional-fair metric to two phones so that you can see who is served.

Assume UE A can presently achieve $r_A=120$ Mbit/s and has an exponentially averaged throughput $\bar R_A=60$ Mbit/s. UE B can achieve $r_B=80$ Mbit/s but has an average $\bar R_B=20$ Mbit/s. A simple proportional-fair teaching metric is $m_i=r_i/\bar R_i$. This metric is common in literature but is not mandated by 3GPP.

**What we are working out.** The two normalized scheduling metrics and the selected UE under the assumed maximum-metric rule.

$$
\begin{aligned}
m_A
&=\frac{r_A}{\bar R_A}
=\frac{120\ \mathrm{Mbit/s}}{60\ \mathrm{Mbit/s}}
=2.0,\\
m_B
&=\frac{r_B}{\bar R_B}
=\frac{80\ \mathrm{Mbit/s}}{20\ \mathrm{Mbit/s}}
=4.0,\\
m_B&>m_A\quad\Rightarrow\quad\text{schedule UE B under the assumed rule.}
\end{aligned}
$$

**Immediate guide.** $r_i$ is the estimated instantaneous achievable rate, $\bar R_i$ is the historical average rate, and $m_i$ is a dimensionless ratio. The rates and maximum-metric rule are pedagogical assumptions. The equation belongs to the implementation and analysis plane. The official specifications define reports, grants, control fields, logical-channel prioritization, and transmission procedures that allow a vendor scheduler to realize its decision.

| Variable | Value | Unit/status | Evidence plane |
|---|---:|---|---|
| $r_A$ | 120 | Mbit/s | assumed instantaneous estimate |
| $\bar R_A$ | 60 | Mbit/s | assumed historical average |
| $m_A$ | 2.0 | dimensionless | derived metric |
| $r_B$ | 80 | Mbit/s | assumed instantaneous estimate |
| $\bar R_B$ | 20 | Mbit/s | assumed historical average |
| $m_B$ | 4.0 | dimensionless | derived metric |

Although A offers higher raw rate, B has received less historical service, so the ratio favors B. A latency-aware implementation might override this result if A carries an urgent packet; a power-limited uplink allocation might also require a different objective. The example demonstrates how a declared policy maps evidence to a choice.

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** This Star aligns with U03, U04, and U05. Those units establish time-frequency resources, duplexing/numerology constraints, and medium-access/control concepts. Scheduling turns that static resource description into a changing allocation under traffic and channel uncertainty. The topic also revisits later coding and QoS ideas, but its primary prerequisite is fluency with slots, PRBs, PDCCH, PDSCH, and PUSCH.

For coursework, students can compare maximum-rate, round-robin, and proportional-fair choices using the same input table, then list which inputs are standardized and which objective is an implementation assumption.

!warning[**“3GPP defines the scheduler formula”.**

3GPP defines messages, fields, constraints, and procedures. A cross-UE metric is vendor policy. Any equation in a teaching note must be labeled as an example or literature choice.]

!warning[**“BSR is an uplink grant request”.**

SR indicates need for resources; BSR reports buffered data, often once the UE has a way to send the MAC CE. Their triggers and interactions differ. A scheduler may also infer demand from prior grants and traffic models.]

!warning[**“Logical-channel prioritization schedules UEs”.**

LCP is the UE procedure that fills an available uplink grant from logical-channel queues. The gNB scheduler decides which UE and resources receive a grant. Both involve priority, but at different decision scopes.]

!warning[**“Preemption indication deletes HARQ state”.**

PI identifies affected resources for defined receiver handling. It does not universally suppress feedback or flush arbitrary soft buffers. Applicable channel and procedure clauses govern the effect.]

!warning[**“Configured grants eliminate scheduling”.**

They move part of the decision to configuration time. Activation, collisions, power, retransmission, traffic variation, and release still require control. Predictability replaces some dynamic grants.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. [[Star-14-Scheduling|Chapter 14]]
3. Course Alignment
4. [Textbook chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00014-3)
5. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip)
6. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip)
7. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip)
8. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip)
9. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.915/21915-f00.zip)
10. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip)
11. [3GPP direct Release-18 artifact](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip)
12. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_Scheduling.html)
13. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_SR.html)
14. [ShareTechnote direct source](https://www.sharetechnote.com/html/5G/5G_MAC_CE_BSR.html)

**Coverage note.** Every link above appears in the explanatory body before this section. Internal links lead to the related notes and the source ledger; external links lead to the exact edition and clause each fact comes from.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| BSR | Buffer status report | UE report of queued uplink data. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| BWP | Bandwidth part | active configured bandwidth subset. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| CQI | Channel quality indicator | downlink link-adaptation evidence. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| DCI | Downlink control information | dynamic scheduling/control message. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| DRX | Discontinuous reception | energy-saving monitoring cycle. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| gNB | next-generation NodeB | NR base station and scheduler host. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| HARQ | Hybrid automatic repeat request | retransmission process state. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| LCP | Logical-channel prioritization | UE procedure for filling an uplink grant. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MAC CE | Medium Access Control control element | control payload such as BSR or PHR. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| MCS | Modulation and coding scheme | selected robustness/rate setting. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PDCCH | Physical downlink control channel | carrier of DCI. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PDSCH | Physical downlink shared channel | scheduled downlink data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PHR | Power headroom report | uplink power-feasibility evidence. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PRB | Physical resource block | frequency-domain allocation unit. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| PUSCH | Physical uplink shared channel | scheduled uplink data channel. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| QoS | Quality of service | service priority and performance requirements. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| RNTI | Radio network temporary identifier | control-message addressing/scrambling identity. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SPS | Semi-persistent scheduling | configured recurring downlink scheduling pattern. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| SR | Scheduling request | indication that uplink resources are needed. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| UE | User equipment | scheduled terminal. | Section 1; [3GPP source](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit/domain |
|---|---|---|
| $i$ | UE index | integer |
| $r_i$ | estimated instantaneous achievable rate | Mbit/s |
| $\bar R_i$ | averaged served throughput | Mbit/s |
| $m_i$ | proportional-fair teaching metric $r_i/\bar R_i$ | dimensionless |
| $Q_i$ | conceptual queue-state input | bits or implementation-specific |
| $D_i$ | conceptual delay-state input | s |
| $C_i$ | conceptual channel-state input | implementation-specific |
| $N_\mathrm{PRB}$ | allocated physical resource blocks | count |
