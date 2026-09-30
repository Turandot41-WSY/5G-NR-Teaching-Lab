---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 20
title: Industrial IoT and URLLC Enhancements
language: en
course_units: []
release_baseline: 18
---

# STAR-20 — Industrial IoT and URLLC Enhancements

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Release 15 made a slot fast. On an empty network that is enough for low latency. A factory floor is never empty: bulk data, video, and status reports are always on the air, and the packet that matters, a stop command, an alarm, must win against all of it. Release 16 adds the tools that let it win, and one more that gives every robot the same microsecond.

![[99 Attachments/5G/Concept Figures/STAR-20-Industrial-IoT-and-URLLC-Enhancements-Concept.png|Industrial IoT and URLLC enhancements explained as a factory floor where the alarm must always win]]

*Concept figure: Industrial IoT and URLLC enhancements explained as a factory floor where the alarm must always win.*

Each tool removes one way an urgent packet could lose. It could be blocked by another phone already transmitting: uplink pre-emption lets the base station tell that phone to stop mid-sentence, a cancellation, or tell the urgent phone to shout over it with a boosted power target. It could be blocked by the phone's own traffic: a priority bit lets a high-priority alarm drop a normal-priority acknowledgement or data block that overlaps it. It could wait to ask permission: several standing grants can be active at once, a small frequent lane for the alarm flow and a large slow lane for bulk data, with rules about which flow may use which. It could wait for the next slot: repetition across the slot boundary starts now with part of the coded block and continues in the next slot with the rest. It could be lost to fading: duplication sends the same packet on up to four legs, and the first to arrive wins.

The sixth tool is a clock. Two robots passing a part must close their grippers in the same microsecond. Radio synchronisation only says "a slot starts now", never what time it is. So the cell stamps a frame with wall-clock time and the phone adds half its timing advance for the flight. The key fact to carry is that every tool is network-controlled. A phone cannot boost, pre-empt, or prioritise itself; it does what a protected control message tells it.

**The question this chapter answers.** What does an industrial deployment need that Release 15 low latency does not supply, and how does each Release 16 enhancement supply it?

!important[**The short answer.** Predictability under load. Uplink pre-emption by cancellation or power boosting resolves collisions between devices; a priority index resolves them inside one device; multiple configured grants with logical-channel restrictions remove the request; repetition across slot boundaries removes the wait for a slot; PDCP duplication over up to four legs removes retransmission latency; and a reference-time message with propagation compensation gives devices a sub-microsecond wall clock.]

Names you will meet in this note: ultra-reliable low-latency communication (URLLC), industrial Internet of Things (IIoT), cancellation indication (CI), configured grant (CG), semi-persistent scheduling (SPS), redundancy version (RV), master and secondary cell group (MCG, SCG), time-sensitive networking (TSN), timing advance (TA).

## 2. Where you are in 5G

Section 1 asked how a stop command wins on a busy factory floor. The map below shows where the Release 16 additions sit in 5G: small changes in scheduling, control and PDCP, all serving one kind of packet.

![[99 Attachments/5G/Locator Maps/STAR-20-Where-You-Are-in-5G.png|Where Star 20 sits in the whole 5G system]]

*Locator: Where Star 20 sits in the whole 5G system.*

This chapter lights the Release 16 industrial enhancements in the procedures band. It builds directly on the scheduler and configured grants of Star 14, the pre-emption indicator and HARQ of Star 13, the power control of Star 15, the control formats of Star 10, and the PDCP layer of Star 06. Star 27 places it among the later releases.

The Knowledge Structure Map draws the enhancements against the traffic they protect. The mechanism diagram traces one urgent packet through the reliability and latency chain.

![[99 Attachments/5G/Knowledge Maps/STAR-20-Industrial-IoT-and-URLLC-Enhancements-Knowledge Structure Map.png|STAR-20 system-position map]]

*Knowledge map: The one-way latency budget for eMBB and URLLC configurations.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-20-URLLC-Reliability-Latency-Chain.png|Star 20 mechanism and handoff diagram]]

*Mechanism: How URLLC reaches five nines by multiplying independent mechanisms.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: Chapter 20: Industrial IoT and URLLC Enhancements → Introduction → 20.1 Uplink Preemption → 20.2 Uplink Collision Resolution → 20.3 Configured Grants and Semi-Persistent Scheduling.


## 3. The textbook road

Section 2 placed the additions. The road below walks through the chapter in the book's order: pre-emption, collision resolution, configured grants, resource allocation, control channels, duplication, then time synchronisation.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **Chapter 20: Industrial IoT and URLLC Enhancements**

The road begins with the theme every addition shares: making urgent traffic win a contest it would otherwise lose.

!important[The chapter is a list of small additions with one theme: making urgent traffic win a contest it would otherwise lose, at a cost paid by the traffic it beats.]

> [!book] Book expansion
> Chapter 20 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 419–432, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00020-9)) is short because each enhancement is a new field or timer on a mechanism the book has already explained.

> [!spec] 3GPP reality check
> The Release 16 work is summarised in [TS 21.916 V16.2.0, clauses 5.2–5.3](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip); the physical-layer procedures land in TS 38.213 and TS 38.214.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [URLLC page](https://www.sharetechnote.com/html/5G/5G_URLLC.html) lists the Release 15 and Release 16 features side by side, which is useful for seeing which tool is which.

### 3.2 **Introduction**

Section 3.1 gave the theme; this section says what Release 15 already had and what Release 16 adds to it.

Release 15 introduced low latency; Release 16 adds enhancements for industrial verticals such as factory automation and power distribution, to support cases needing high reliability and low latency at once. Release 15 already had mini-slots, front-loaded design, and downlink pre-emption. Release 16 adds uplink pre-emption, improved prioritisation, configured-grant enhancements, and time-sensitive networking support.

### 3.3 **20.1 Uplink Preemption**

The first addition handles the hardest case: an urgent uplink packet arriving while another phone is already transmitting.

Under load, latency-critical data for one phone may arrive while another phone's transmission is in progress. In the downlink that is easy: the base station simply stops sending to one and sends to the other. In the uplink it is hard, because a high-priority phone transmitting on top of another causes interference. Two mechanisms control it: cancelling the low-priority transmission, or boosting the power of the high-priority one. Figure 20.1 shows both. On the left the network sends a cancellation to device 1, which stops, clearing the air for device 2. On the right device 2 transmits on top of device 1 with boosted power and overpowers the interference.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.1 shows both.*

#### 3.3.1 **20.1.1 Uplink Cancellation**

The base station sends a cancellation indication in DCI format 2_4. A low-priority phone that receives it stops any data or sounding transmission overlapping the indicated resources. There is a minimum processing time: a command that arrives too late cannot stop what is already in the air. Figure 20.2 shows the case with repetition: the first repetition is already transmitting and cannot be cancelled, but the second is.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.2 shows the case with repetition: the first repetition is already transmitting and cannot be cancelled, but the second is.*

#### 3.3.2 **20.1.2 Uplink Power Boosting for Dynamic Scheduling**

The network configures several open-loop power targets, and the scheduling command tells the phone which to use. The low-priority phone need not listen for cancellations at all.

> [!important] 💡
> **Is there any security problem in the power boosting part? Can a malicious device cover a legal device? How does gNB judge this?**
> The mechanism is network-controlled: the scheduling DCI indicates which configured $P_0$ value to use, so a device cannot arbitrarily decide to boost its power; it must receive a command (DCI) from the gNB to do so.
> **Security perspective (mindstorm):**
> 1. **Impersonation/spoofing:** if a malicious device could spoof the DCI, it could instruct a legitimate device to transmit at very high power, causing interference or battery drain. DCI is protected by RNTI masking, though not encrypted at the physical layer, making it a theoretical jamming target.
> 2. **Malicious overpowering:** a device ignoring the standard could transmit at maximum power without a grant (jamming). The gNB judges legality by checking whether it scheduled that high-power burst; energy on a resource it did not assign a boosted grant to is treated as interference.
> 3. **Legality check:** the gNB knows exactly which device is allowed to boost because the gNB issued the grant. The judgment is inherent in the scheduling logic.

> [!spec] 3GPP reality check
> The cancellation procedure is [TS 38.213 V18.8.0, clause 11.2A](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) and the format is TS 38.212 clause 7.3.1.3.5; the configurable power sets are TS 38.213 clause 7.1.1 with the selection field in DCI formats 0_1 and 0_2.

### 3.4 **20.2 Uplink Collision Resolution**

Section 3.3 resolved a contest between two phones. This section resolves one inside a single phone, when an alarm arrives during background traffic.

A phone sending low-priority background data may suddenly need to send a high-priority alarm. Release 15 used simple rules, such as a dynamic grant beating a configured one. Release 16 adds explicit priority levels, high and normal, and high drops normal. Figure 20.3 shows examples: a normal acknowledgement overlapping high-priority data is dropped; a high-priority scheduling request overlapping a normal data block drops the data so the request goes out at once.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.3 shows examples: a normal acknowledgement overlapping high-priority data is dropped; a high-priority scheduling request overlapping a normal data block drops the data so the request goes out at once.*

### 3.5 **20.3 Configured Grants and Semi-Persistent Scheduling**

Both contests are faster to win if the resources are already there. This section pre-allocates them with configured grants and semi-persistent scheduling.

!important[Resources are pre-allocated so a phone need not request them each time. Release 16 allows several active configurations at once, one for small periodic updates and one for alarms, say, and can restrict specific traffic flows to specific grants. Figure 20.4 shows a frequent small grant reserved for a critical flow and an infrequent large grant for bulk data, so that bulk data never clogs the fast lane.]

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.4 shows a frequent small grant reserved for a critical flow and an infrequent large grant for bulk data, so that bulk data never clogs the fast lane.*

> [!important] 💡
> **Uplink Configured Grants Mechanism — Q2: What's the uplink configured grants mechanism?**
> **Standard mechanism (dynamic):** when a phone has data it sends a scheduling request, the gNB processes it, the gNB sends a grant (DCI), and the phone transmits. This handshake takes time.
> **Configured grant mechanism:** the network tells the device in advance, "every Monday at 9:00 AM you have permission to upload". No handshake: when data arrives, the device transmits on the pre-assigned resource.
> **Why for IIoT?** Industrial machines generate data periodically (a sensor reading every 10 ms). Configured grants match this perfectly, removing the delay of the request–grant handshake.

### 3.6 **20.4 PUSCH Resource Allocation Enhancements**

Pre-allocated resources still sat inside slot boundaries in Release 15. This section lets a transmission cross the boundary instead of waiting.

In Release 15 a transmission could not cross a slot boundary, so data arriving late in a slot waited for the next. Figure 20.5 shows the gain: without repetitions the phone waits; with repetitions it sends the first part immediately and continues in the next slot.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.5 shows the gain: without repetitions the phone waits; with repetitions it sends the first part immediately and continues in the next slot.*

> [!important] 💡
> What's the meaning of repetition? Why is this emphasis needed?
> **Why "repetition"?** In standard cellular terms repetition means sending the same copy twice for reliability. Here it serves a segmentation purpose.
> **The problem:** you cannot transmit a continuous wave across a slot boundary because the boundary may contain control or reference signals. You have to stop and start again.
> **The solution:** the system treats the transmission in slot N and slot N+1 as two separate repetitions of the same transport block.
> **Coding:** in Release 16 they are not necessarily coded identically. The figure shows RV a and RV b: the transport block is coded once, but different parts of the coded bits (different redundancy versions) are sent in the two slots, and the receiver combines them. A single logical packet can span the slot boundary.

> [!spec] 3GPP reality check
> Repetition type B, with nominal and actual repetitions, is [TS 38.214 V18.10.0, clause 6.1.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); multiple configured grants are clause 6.1.2.3 and TS 38.321 clause 5.8.2, with up to twelve configurations per bandwidth part in TS 38.331.

### 3.7 **20.5 Downlink Control Channels**

Faster data needs faster commands. This section shows how control monitoring and the DCI fields were changed for urgent traffic.

Monitoring can now happen every second OFDM symbol so commands are caught at once. New fields carry priority, the open-loop power set, and the repetition number. Compact formats 0_2 and 1_2 are smaller and so more reliable.

| Feature | Normal situation (eMBB, Rel-15) | URLLC situation (Rel-16) |
| --- | --- | --- |
| Monitoring | once per slot, every 14 symbols | very frequent, every 2 symbols, to react instantly |
| Packet size | standard DCI, optimised for flexibility | compact DCI 0_2 and 1_2; smaller means easier to decode |
| Priority | all data treated alike or via logical channels | explicit priority indicator in DCI, high versus normal |
| Repetition | configured semi-statically, slow to change | number of repetitions indicated dynamically in the DCI |

### 3.8 **20.6 Multi-Connectivity With PDCP Duplication**

Sections 3.3 to 3.7 made one path faster. This section sends the same packet along several paths at once, so that one failure does not matter.

The same packet is sent along several paths, now up to four RLC entities at once. Figure 20.6 shows two copies through the master cell group and two through the secondary, one PDCP packet copied four times.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.6 shows two copies through the master cell group and two through the secondary, one PDCP packet copied four times.*

> [!important] 💡
> Why can **Multi-Connectivity With PDCP Duplication** help in URLLC?
> - **Reliability through diversity:** wireless channels fade and suffer interference. A packet sent on one frequency can be destroyed by a noise burst, requiring a retransmission that adds latency.
> - **The lottery analogy:** if you need to win instantly, one ticket (one path) is risky; four tickets (cells 1 to 4) dramatically raise the chance that at least one wins immediately.
> - **URLLC benefit:** the system does not wait to see whether the packet failed; it assumes one path might and sends backups at once, giving ultra-reliability with zero retransmission latency.

### 3.9 **20.7 Time Synchronization for Time-Sensitive Networks**

The road ends with a need the radio did not have before: giving every machine on the floor the same clock.

Industrial machines often move in step and need a common time reference accurate to under a microsecond. The network provides absolute wall-clock time to the phone. Figure 20.7 shows the 5G system acting as a bridge in a wired Ethernet network, with its time reference keeping the device on the right in step with the controller on the left.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.7 shows the 5G system acting as a bridge in a wired Ethernet network, with its time reference keeping the device on the right in step with the controller on the left.*

Figure 20.8 shows the computation: the base station announces that at the end of frame X the time is $t_{ref}$; the phone waits for that frame and adds the propagation delay, half its timing advance, to know the exact time.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 20.8 shows the computation: the base station announces that at the end of frame X the time is $t_{ref}$; the phone waits for that frame and adds the propagation delay, half its timing advance, to know the exact time.*

> [!important] 💡
> **Is there any difference between the normal system? In non-URLLC, is there no need for synchronization? Why emphasize this?**
> - **Normal system:** yes, normal systems sync, but to the radio frame. The phone knows "this is the start of a millisecond"; it does not know "it is exactly 10:00:00.000001". Purpose: radio signals must not overlap.
> - **TSN system:** industrial robots need absolute wall-clock time. If robot A passes a part to robot B, they must agree on the exact microsecond to close the gripper. Normal cellular networks do not carry absolute time with microsecond precision, and NTP over the internet is too jittery (milliseconds).
> - **How it helps:** the gNB uses its GPS clock to timestamp a specific frame ($t_{ref}$ in Fig 20.8). Propagation compensation: the device computes how long the wave travelled ($T_{TA}/2$); NTP does not know the flight time, 5G knows it physically.
> - **Result:** the device sets its clock to the factory master within 0.5 µs, allowing wireless control of high-speed machinery.

> [!spec] 3GPP reality check
> Duplication is [TS 38.323 V18.5.0, clause 5.11](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip); the reference time is the ReferenceTimeInfo information element in TS 38.331, delivered in SIB9 or a dedicated message, with the compensation rule in TS 38.331 clause 5.2.

> [!engineering] ShareTechnote engineering view
> The [URLLC page](https://www.sharetechnote.com/html/5G/5G_URLLC.html) collects the URLLC features and their TSN integration on one page, which is the view the industrial standards take of the 5G system.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names where each addition was written, as fields, timers and formats in existing documents.

Release 16 added little new physics; it added fields, timers, and formats. Cancellation is a DCI format and a procedure in TS 38.213. The boosted power sets are two extra targets and a selector bit in the same clause as the power equation. Priority is one bit in the DCI and in each configured grant. Repetition type B and multiple configured grants are TS 38.214. Duplication is TS 38.323. The clock is an RRC information element. The figure draws each with its clause and the configuration lines it becomes.

![[99 Attachments/5G/Protocol Figures/STAR-20-Industrial-IoT-and-URLLC-Enhancements-Protocol.png|The Release 16 industrial tools as clauses, fields and configured values]]

*Protocol figure: The Release 16 industrial tools as clauses, fields and configured values.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.212 | V18.8.0, [38212-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 7.3.1.1.3; 7.3.1.2.3; 7.3.1.3.5 | DCI formats 0_2, 1_2, and 2_4 |
| TS 38.213 | V18.8.0, [38213-i80.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 7.1.1; 9; 11.2A | power sets, priority, and uplink cancellation |
| TS 38.214 | V18.10.0, [38214-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 6.1.2.1; 6.1.2.3 | repetition type B and configured grants |
| TS 38.323 | V18.5.0, [38323-i50.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip) | 5.11 | PDCP duplication |
| TS 38.331 | V18.10.0, [38331-ia0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 6.3.2; ReferenceTimeInfo | every configuration above, and the clock |

!note[**When you build or run a demo.** A URLLC demo is a scheduling demo with priorities: a configured grant with a short period and priority one for the alarm flow, a second with a long period for everything else, and a logical-channel restriction tying each flow to its grant. Repetition type B and the repetition count are two lines that decide whether a late-arriving packet waits for the slot. Cancellation needs the indication's payload size and monitoring configured on the phones it may interrupt. Duplication is a flag on the bearer plus a second RLC leg, which needs carrier aggregation or dual connectivity underneath. The reference time is a broadcast or dedicated message with an uncertainty field, and its accuracy in a demo is bounded by the base station's own clock source. Open-source stacks support configured grants and repetition; cancellation and duplication are less common.]

Release 15 established the platform but not this set. Release 16 added the chapter's package: compact control, cancellation, configured-grant and repetition refinements, duplication over four legs, and industrial timing. Release 18 preserves the mechanisms while extending timing resiliency; the versions cited are where the clauses were checked. Release summaries are checked against TS 21.916 and 21.918. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents define duplication; this trace computes how likely it is that every copy fails before the deadline.

**What we are working out.** Probability that both duplicated legs fail before the deadline.

**Worked numerical example.** Use an intentionally simple independent-leg model to expose both the gain and its assumption.

Assume the failure probability of each leg for the relevant packet and deadline is $10^{-2}$. If, and only if, those failures are independent, the joint failure probability is their product:

$$
\begin{aligned}
P_{\mathrm{fail,2}} &= p_1 p_2 \\
&= (10^{-2})(10^{-2}) \\
&= 10^{-4}.
\end{aligned}
$$

Here $P_{\mathrm{fail,2}}$ is the dimensionless joint deadline-failure probability, while $p_1$ and $p_2$ are the dimensionless failure probabilities of legs 1 and 2.

The result corresponds to one failed duplicated delivery in ten thousand trials under the stated model, compared with one in one hundred for either leg alone. It is not a guaranteed URLLC figure. If both legs share a common failure with probability $p_c$, the common event creates a floor that duplication cannot remove. A field design must estimate correlation from mobility, interference, topology, scheduler placement, and transport dependencies rather than assume independence because two logical legs exist.

**Sanity check.** The product is dimensionless and smaller than either individual failure probability, as expected only for two independent chances.

The values are illustrative. The evidence plane is analytical: the multiplication rule follows elementary probability; the architectural reason for duplicate legs comes from TS 38.323 clause 5.11; and the actual $p_1$, $p_2$, and correlation must come from measurement or a validated system model.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $P_{\mathrm{fail,2}}$ | Joint deadline-failure probability | $10^{-4}$ | dimensionless | Derived under independence |
| $p_1$ | Deadline-failure probability of leg 1 | $10^{-2}$ | dimensionless | Assumed illustration |
| $p_2$ | Deadline-failure probability of leg 2 | $10^{-2}$ | dimensionless | Assumed illustration |
| $p_c$ | Common-cause failure floor | not assigned | dimensionless | Deployment measurement/model |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** The current Course Alignment assigns no direct course unit to Chapter 20. The best use is therefore a cross-cutting case study after students know scheduling, HARQ, PDCP, dual connectivity, and synchronization. It can connect the physical-layer and architecture units by asking students to trace which layer owns each deadline reduction.

For assessment, a strong question gives a failure mode—grant wait, decoding failure, common-path outage, or clock error—and asks the student to select configured grant, repetition, duplication, or time distribution and defend the boundary. This tests causal reasoning rather than release-name recall.

> “Is there any security problem in the power boosting part? Can a malicious device cover a legal device? How does gNB judge this?”

!warning[Yes, strong interference can cover a wanted signal, but legitimate identity is not decided by power. The gNB combines authenticated access and higher-layer context with scheduled-resource expectations and operational interference detection. RNTI masking is not cryptographic authentication, and power control remains bounded by configuration and UE capability.]

> “What’s the uplink configured grants mechanism?”

!warning[It preconfigures recurring uplink resources so a UE can transmit without waiting for a fresh dynamic grant on every occasion. Type 1 is radio-resource-control configured; Type 2 uses physical-layer activation/deactivation in addition to configuration. The gain is lower access delay; the trade is reserved capacity and collision management.]

> “What’s the meaning of repetition? Why is this emphasis needed?”

!warning[It supplies multiple nominal PUSCH transmissions for the same transport block, potentially across slot boundaries. The emphasis matters because an extra decoding opportunity can fit where a complete feedback-and-retransmission round trip would miss the deadline. It is not universally defined by different redundancy versions.]

> “Why can Multi-Connectivity With PDCP Duplication help in URLLC?”

!warning[Because duplicate PDCP data can traverse sufficiently diverse lower-layer legs. The receiver uses the first successful arrival and discards the redundant copy. The benefit shrinks when failures are correlated.]

> “Is there any difference between the normal system? In non-URLLC, is there no need for synchronization? Why emphasize this?”

!warning[All cellular systems require timing. Industrial URLLC emphasizes bounded error, traceability, and delivery of a common time reference because a small clock disagreement can invalidate coordinated actuation even when the packet itself arrives quickly.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 20, pp. 419–432, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00020-9).
2. 3GPP TS 21.916 V16.2.0, clauses 5.2–5.3. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
3. 3GPP TS 38.212 V18.8.0, clauses 7.3.1.1.3, 7.3.1.2.3, and 7.3.1.3.5. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip).
4. 3GPP TS 38.213 V18.8.0, clause 11.2A. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).
5. 3GPP TS 38.214 V18.10.0, clauses 6.1.2.3–6.1.2.3.3. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).
6. 3GPP TS 38.323 V18.5.0, clause 5.11. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip).
7. 3GPP TS 21.918 V18.0.0, clause 6.5. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
8. ShareTechnote, “5G/NR — URLLC,” accessed 2026-08-03. [Direct page](https://www.sharetechnote.com/html/5G/5G_URLLC.html).
9. Course Alignment, local course crosswalk, accessed 2026-08-03.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| DCI | Downlink Control Information | Physical-layer scheduling/control payload. | Section 1; [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| gNB | Next Generation Node B | NR base station. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| HARQ | Hybrid Automatic Repeat Request | Feedback-based link-layer retransmission process. | Section 1; [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) |
| IIoT | Industrial Internet of Things | Networked industrial sensing and control domain. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |
| PDCP | Packet Data Convergence Protocol | Radio protocol layer that can duplicate PDUs. | Section 1; [TS 38.323](https://www.3gpp.org/ftp/Specs/archive/38_series/38.323/38323-i50.zip) |
| PUSCH | Physical Uplink Shared Channel | Scheduled uplink data channel. | Section 1; [TS 38.214](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) |
| RNTI | Radio Network Temporary Identifier | Radio-context identifier used in control processing. | Section 1; [TS 38.212](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) |
| TSN | Time-Sensitive Networking | Bounded-time Ethernet/networking family used by industrial systems. | Section 1; [TS 21.918](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) |
| UE | User Equipment | Endpoint using the NR radio interface. | Section 1; [TS 38.213](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) |
| URLLC | Ultra-Reliable and Low-Latency Communication | Service family targeting stringent delay and delivery reliability. | Section 1; [TS 21.916](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $P_{\mathrm{fail,2}}$ | Probability that both duplicated legs miss the packet deadline | dimensionless |
| $p_1$ | Deadline-failure probability on the first leg | dimensionless |
| $p_2$ | Deadline-failure probability on the second leg | dimensionless |
| $p_c$ | Probability of a common-cause failure | dimensionless |
| ms | Millisecond | $10^{-3}$ s |
