---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 31
title: TS 38.213 Physical-Layer Procedures for Control
language: en
course_units:
- U09–U14
release_baseline: 18
---

# STAR-31 — TS 38.213 Physical Layer Procedures for Control

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf) — TS 38.213 V18.8.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

TS 38.211 said what a signal is; TS 38.212 said how it is coded. TS 38.213 is the rulebook of behaviour: what a phone does, slot by slot, in response to what it decodes and measures, without being told each time. Think of it as the phone's standing orders.

![[99 Attachments/5G/Concept Figures/STAR-31-TS-38.213-Concept.png|TS 38.213 explained as the phone's standing orders]]

*Concept figure: TS 38.213 explained as the phone's standing orders.*

There are six. Keep time, clause 4: advance every transmission by the amount the network measured, and if the orders stop coming, stop transmitting and knock again. Watch for your name, clauses 10 and 13: search a fixed set of candidate control positions every monitoring occasion, within a budget per slot, and when nothing has been configured yet use the default table row. Say how loud, clause 7: set power from the target, the bandwidth, the measured path loss, and every accumulated nudge, never above the maximum. Knock, clause 8: pick a preamble, send it at a computed power, wait a window, climb by a step, stop after a maximum, then say your name and wait to hear it back. Answer, clause 9: reply to each downlink block on the control channel a fixed number of slots later, packed in a codebook the network can predict, on the resource the grant named. Move rooms, and give up, clauses 12, 5, and 6: switch bandwidth part when a grant says so or a timer expires, declare the link lost after enough bad estimates, and find a new beam when yours fails.

Why a separate document? A grant is sixty bits; the behaviour it triggers is pages long. TS 38.213 holds the pages, so that every phone from every maker reacts identically to the same sixty bits. The key fact to carry is that these are procedures the phone runs; the base station's side is mostly unspecified, which is where vendors differ.

**The question this chapter answers.** How does TS 38.213 convert configured resources and decoded control into timing, power, monitoring, random-access, feedback, bandwidth-part, and recovery behaviour?

!important[**The short answer.** TS 38.213 is a procedure document. Clause 4 covers synchronisation and timing adjustment; clause 5 radio-link monitoring; clause 6 link recovery; clause 7 uplink power; clause 8 physical random access; clause 9 uplink control and acknowledgement; clause 10 reception of control; clause 11 group-common signalling; clause 12 bandwidth parts; clause 13 the type-0 common search space; and clauses 14 to 22 the feature-specific families of Release 18. TS 38.211 supplies modulation and mapping, TS 38.212 channel coding.]

Names you will meet in this note: physical downlink and uplink control channel (PDCCH, PUCCH), physical uplink shared channel (PUSCH), physical random-access channel (PRACH), sounding reference signal (SRS), uplink control information (UCI), HARQ acknowledgement (HARQ-ACK), bandwidth part (BWP), common search space (CSS), control resource set (CORESET), radio-link monitoring (RLM), beam-failure recovery (BFR), timing advance (TA), downlink control information (DCI), downlink assignment index (DAI).

This note teaches the fixed clause map of this knowledge base and 3GPP [TS 38.213 V18.8.0](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The extraction is a navigation aid; the official file is official, and the course manifest records its hash and retrieval date.

## 2. Where you are in 5G

Section 1 called TS 38.213 the rulebook of behaviour. The map below shows where behaviour sits in 5G: the procedures a phone runs slot by slot around the control channel.

![[99 Attachments/5G/Locator Maps/STAR-31-Where-You-Are-in-5G.png|Where Star 31 sits in the whole 5G system]]

*Locator: Where Star 31 sits in the whole 5G system.*

This chapter lights the control-procedure document of the specification band: the written form of the control signalling of Star 10, the power and timing loops of Star 15, the cell-search tables of Star 16, the random access of Star 17, the acknowledgement timing of Star 13, and the beam recovery of Star 12. It takes its resources from TS 38.331, Star 36, its messages from TS 38.212, Star 30, and its mapping from TS 38.211, Star 29.

The Knowledge Structure Map draws the control-procedure chain. The mechanism diagram traces one control event through it.

![[99 Attachments/5G/Knowledge Maps/STAR-31-TS-38.213-Knowledge Structure Map.png|STAR-31 system-position map]]

*Knowledge map: TS 38.213 control procedures by initiator and timescale.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-31-TS-38.213-Control-Procedure-Chain.png|Star 31 mechanism and handoff diagram]]

*Mechanism: TS 38.213 — what a device does in a single slot.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.213 V18.8.0, clause 4, PDF page 10](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.213 V18.8.0, clause 4, PDF page 10, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [PDCCH overview](https://www.sharetechnote.com/html/5G/5G_PDCCH.html). The reproduced image is omitted from this distribution.

*Source excerpt: PDCCH overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_PDCCH.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> In the cross-specification boundary, **TS 38.211 owns modulation, sequence generation, waveform generation, and physical-resource mapping; it does not own channel coding. Channel coding and multiplexing are defined in TS 38.212.** The body boundary statement is authoritative.

> [!note] Searchable structure
> Synchronisation and link state → power and timing control → random access and UCI → PDCCH, slot, and BWP monitoring → type-0 CSS and receiver action.

Read the map as a routing diagram: a box is an owned concept or transformation, an arrow a handoff. When a trace diverges, walk one arrow upstream and compare the exact input object, configuration, release, and state. 

## 3. Foundations and prerequisites

Section 2 placed the procedures. Five foundations follow: what a procedure selects, why monitoring is bounded, why timing and power are feedback loops, why recovery differs from scheduling, and which documents the procedures depend on.

### 3.1 A procedure selects among configured resources

The first foundation is what a procedure is: a selection among configured resources.

RRC and broadcast information provide sets of resources and parameters; control information and measured state select or trigger an action. TS 38.213 defines conditions, calculations, monitoring occasions, and responses.

> [!spec] 3GPP reality check
> The resources a procedure selects among are information elements of [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip), such as SearchSpace, ControlResourceSet, PUCCH-Config, and BWP; the procedures that pick among them are the clauses of TS 38.213.

### 3.2 Monitoring is a bounded receiver task

Section 3.1 said procedures select. This section shows that the first thing bounded is how much a phone must decode.

!important[The phone does not decode every position. Control-resource-set and search-space configuration bound the candidates, and clause rules bound the occasions and candidate counts, which makes control reception feasible and creates explicit missed-control failure modes.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [PDCCH page](https://www.sharetechnote.com/html/5G/5G_PDCCH.html) draws a search space as candidate boxes inside a control resource set at each aggregation level, which is the picture behind the blind-decoding budget.

### 3.3 Timing and power are feedback systems

Section 3.2 bounded decoding. This section names the two loops the phone runs continuously: timing and power.

Downlink synchronisation establishes a time reference; timing advance aligns uplink arrival; open-loop power uses path-loss estimates and targets; closed-loop terms refine transmit power. Every value needs its serving-cell, bandwidth-part, channel, and reference-signal context.

### 3.4 Recovery is not ordinary scheduling

Section 3.3 covered normal operation. This section covers what happens when the link stops working.

Radio-link monitoring evaluates whether the link remains usable under defined hypotheses; beam-failure detection and recovery use candidate beams and access or control resources to restore communication. They share signals with ordinary operation but have different state and success conditions.

### 3.5 Control procedure spans companion TS documents

The last foundation is where the procedures reach into other documents.

TS 38.331 configures the information elements, TS 38.212 constructs and codes control information, TS 38.211 maps the channels and signals, and TS 38.214 applies the data procedures; TS 38.213 supplies the actions at the control boundary.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clauses 4–6 establish and protect radio timing

The walk starts with clauses 4 to 6, which establish and protect timing.

Cell-search and synchronisation inputs give frame and symbol timing; timing-advance commands move the uplink; radio-link monitoring tests link hypotheses; beam-failure recovery selects recovery resources. A timing estimate, a commanded adjustment, and a protocol state must be logged separately.

> [!spec] 3GPP reality check
> Timing advance and its granularity are [TS 38.213 V18.8.0, clause 4.2](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf); the in-sync and out-of-sync hypotheses of radio-link monitoring are clause 5, with the counters and timer in TS 38.331; beam-failure detection and recovery are clause 6.

### 4.2 Clause 7 calculates uplink transmit power

Section 4.1 aligned timing. This section reads clause 7, which sets transmit power.

PUSCH, PUCCH, SRS, and PRACH each have a power equation with target terms, path loss, bandwidth factors, closed-loop adjustments, and a maximum-power cap. A simplified calculation must say which terms it omits and which reference signal supplies the path loss.

### 4.3 Clause 8 controls random-access PHY behavior

Section 4.2 set power. This section reads clause 8, the physical side of random access.

The phone selects and transmits a preamble under the configured associations, monitors for a response, and follows the grant and timing behaviour; MAC owns the broader state machine in TS 38.321, and the preamble sequence and mapping stay in TS 38.211.

### 4.4 Clause 9 schedules UCI and HARQ feedback

Section 4.3 got the phone connected. This section reads clause 9, which schedules its feedback.

Acknowledgement codebooks, scheduling requests, and channel-state reports occupy the control channel or are multiplexed on data under defined conditions; timing, resource indication, collisions, and prioritisation decide what is sent. TS 38.212 encodes the bits; TS 38.213 decides their procedural use.

> [!spec] 3GPP reality check
> The semi-static and dynamic acknowledgement codebooks are clauses 9.1.2 and 9.1.3, the acknowledgement timing is the k1 set of dl-DataToUL-ACK in clause 9.2.3, and the control-channel resource is chosen through the resource indicator of clause 9.2.1.

### 4.5 Clause 10 bounds PDCCH monitoring

Section 4.4 covered what the phone sends. This section reads clause 10, which bounds what it listens for.

!important[A search space references a control resource set and defines monitoring occasions and candidates; the phone blind-decodes the candidates, applies the identity-masked CRC check, and acts on valid control information. A control resource set is a region, a search space a rule, a candidate a hypothesis, and the control information a payload.]

> [!spec] 3GPP reality check
> The maximum candidates and control-channel elements a phone monitors per slot, by numerology, are Tables 10.1-2 and 10.1-3 of TS 38.213 clause 10.1; the type-0 common search space that applies before any dedicated configuration is clause 13.

### 4.6 Clause 11 group-common signalling and clauses 12–13 BWP/initial control

The walk ends with clauses 11 to 13: group signalling, bandwidth parts and the initial control search.

Clause 11 is broader than slot format: clause 11.1 handles slot configuration, and clauses 11.2 to 11.5 interrupted-transmission indication, group power commands, sounding switching, and adaptation of cell operation. Clause 12 constrains bandwidth-part operation, and clause 13 derives the type-0 common search space from broadcast parameters and tables; none schedules data alone, and together they bound how a phone finds and interprets control.

!note[These procedures interact through state, so a useful trace follows one control event across clauses: before a phone can act on a grant it needs valid synchronisation, an applicable bandwidth part, a configured or derived control resource set and search space, a monitoring occasion, a candidate, a decoded payload, and a resource interpretation, and a missing uplink can originate at any earlier gate. Timing and power should be inspected together but accounted for separately: extra power cannot repair a timing error that moves energy outside the receive window, and correct timing cannot repair insufficient quality. Recovery adds a context switch, since the same synchronisation block or channel-state signal can serve acquisition, measurement, beam management, or recovery depending on its configured resource set and state. The type-0 common search space is a useful integration test, because the phone derives control resources before any dedicated configuration: a broadcast field selects a table row, which fixes geometry and occasions, then clause 10 monitoring and TS 38.211 mapping apply with TS 38.212 coding, and a failure is diagnosed in that order.]

## 5. Worked example

Section 4 walked the clauses. Section 5 runs one small calculation through them.

### 5.1 Worked numerical example

The example below is deliberately small: one calculation that shows how a number in this document is traced to its clause.

The example is intentionally small. It demonstrates local traceability and does not claim to reproduce a complete conformance vector.

**What we are working out.** Illustrative capped PUSCH transmit power for a one-PRB, $\mu=0$ case, in dBm, at the clause-7 transmit-power accounting boundary.

$$
\begin{aligned}
P_{\mathrm{PUSCH}} &= \min\!\left\{P_{CMAX},\ 10\log_{10}\!\left(2^{\mu}M_{RB}\right)+P_0+\alpha PL+\Delta_{TF}+f_{cl}\right\} \\
&= \min\!\left\{23,\ 10\log_{10}\!\left(2^0\!\cdot1\right)-76+(0.8)(100)+1+2\right\} \\
&= 7\ \mathrm{dBm}
\end{aligned}
$$

Where:

- $P_{\mathrm{PUSCH}}$ = 7 dBm, calculated (clause-7-shaped local model); it belongs to the PUSCH transmit-power accounting boundary.
- $P_{CMAX}$ = 23 dBm, assumed (illustrative maximum-power limit); it belongs to the applicable UE serving-cell power limit.
- $\mu$ = 0, assumed (illustrative numerology); it belongs to the scheduled PUSCH.
- $M_{RB}$ = 1 PRB, assumed (illustrative resource allocation); it belongs to the scheduled PUSCH.
- $P_0$ = -76 dBm, assumed (illustrative target term); it belongs to the serving-cell PUSCH.
- $\alpha$ = 0.8, assumed (illustrative compensation factor); it belongs to the serving-cell PUSCH.
- $PL$ = 100 dB, assumed (illustrative path-loss estimate); it belongs to the configured reference signal.
- $\Delta_{TF}$ = 1 dB, assumed (illustrative format adjustment); it belongs to the scheduled PUSCH.
- $f_{cl}$ = 2 dB, assumed (illustrative closed-loop state); it belongs to the power-control loop.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $P_{\mathrm{PUSCH}}$ | 7 dBm | calculated | clause-7-shaped local model | PUSCH transmit-power accounting boundary |
| $P_{CMAX}$ | 23 dBm | assumed | illustrative maximum-power limit | applicable UE serving-cell power limit |
| $\mu$ | 0 | assumed | illustrative numerology | scheduled PUSCH |
| $M_{RB}$ | 1 PRB | assumed | illustrative resource allocation | scheduled PUSCH |
| $P_0$ | -76 dBm | assumed | illustrative target term | serving-cell PUSCH |
| $\alpha$ | 0.8 | assumed | illustrative compensation factor | serving-cell PUSCH |
| $PL$ | 100 dB | assumed | illustrative path-loss estimate | configured reference signal |
| $\Delta_{TF}$ | 1 dB | assumed | illustrative format adjustment | scheduled PUSCH |
| $f_{cl}$ | 2 dB | assumed | illustrative closed-loop state | power-control loop |

The displayed result is rounded only after the local substitution. The $10\log_{10}(2^{\mu}M_{RB})$ term accounts for the assumed resource allocation, decibel-domain offsets add to the dBm target, and dimensionless $\alpha$ scales a dB path-loss term. The minimum applies the assumed maximum-power limit. Exact indexing and channel-specific conditions remain in clause 7; this example teaches term ownership.

The engineering check asks whether all operands share the declared boundary and whether an omitted cap, branch, state, overhead, or companion procedure could change the decision. If so, the next step is to restore that term rather than add false precision.

The sign of each term carries an operational meaning. A larger path-loss estimate raises the requested power when alpha is positive; reducing alpha makes the UE compensate only part of that increase. A positive closed-loop term raises the command relative to the open-loop baseline, while a negative term lowers it. The format adjustment represents a channel/procedure-dependent contribution and must not be copied between PUSCH, PUCCH, SRS, and PRACH as though the equations were interchangeable.

The calculated request is 7 dBm, below the assumed 23 dBm limit, so the applied result remains 7 dBm. If a request exceeds the applicable cap, the UE cannot realize the full compensation. That saturation changes the link-budget interpretation: increasing the target or scheduled bandwidth may no longer increase transmit power as expected, and received quality can fall. A trace should record both the calculated request and applied capped value so saturation is visible rather than hidden inside one logged power number.

The path-loss term also needs a declared reference signal and power reference. A value reconstructed from received reference-signal power is not portable across a different beam, serving cell, BWP, or reference-signal configuration without checking the clause conditions. Calibration, measurement filtering, and timing affect the estimate. This is why the immediate guide labels the local $PL$ value as assumed and names its reference plane instead of presenting it as a measured or universally calculated geometric loss.

Finally, power correctness does not establish control success. The UE must still transmit on the scheduled resources at the commanded timing, with the required waveform and coding, and the gNB must detect and decode it under the applicable procedure. The worked value closes only the power-term table. Timing, resource mapping, coding, channel estimation, interference, and receiver thresholds remain parallel verification gates.

## 6. The 3GPP protocol: which document, and what it says

The example used one budget. This section names what each clause fixes and draws the budgets, timers and formulas.

Each clause is one behaviour, and each behaviour has a budget, a timer, or a formula. The figure draws the blind-decoding budget per slot, the acknowledgement timing and codebook types, the timing-advance standing order and its timer, the radio-link-monitoring thresholds, and bandwidth-part switching, and sets each beside the configuration line that sets it and the log line that shows it running.

![[99 Attachments/5G/Protocol Figures/STAR-31-TS-38.213-Protocol.png|The procedure clauses of TS 38.213, the budgets, timers and formulas each fixes, and the configuration lines that set them]]

*Protocol figure: The procedure clauses of TS 38.213, the budgets, timers and formulas each fixes, and the configuration lines that set them.*

| Clause | Fixed V18.8.0 scope | Reader question |
|---|---|---|
| 4 | synchronisation, cell search, timing adjustment, SCell activation timing | what is the phone's time reference, and how is the uplink advanced? |
| 5 | radio-link monitoring | when is the link declared unusable? |
| 6 | link recovery, including beam-failure recovery | how is communication restored when control has failed? |
| 7 | uplink power control for PUSCH, PUCCH, SRS, and PRACH | how loud, term by term? |
| 8 | physical-layer random-access procedure | how does a phone knock, and what does it wait for? |
| 9 | UCI, HARQ-ACK codebooks, PUCCH and PUSCH feedback | when and where does the phone answer? |
| 10 | PDCCH monitoring and search-space candidates | how much may a phone be asked to search? |
| 11 | group-common signalling: slot configuration, interruption, group TPC, SRS switching, cell-operation adaptation | what does a group of phones do next? |
| 12 | bandwidth-part operation | which room is the phone in, and when does it move? |
| 13 | type-0 PDCCH common search space | where does a phone look before it is configured? |
| 14–22 | feature-specific procedures: IAB, DAPS, sidelink, RedCap, MBS, RRC_INACTIVE PUSCH, repeaters, mobility | which Release 18 branch applies? |

The official text is [TS 38.213 V18.8.0, official archive](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf).

!note[**When you build or run a demo.** Most of this document is exercised by a handful of configuration lines. A search space's periodicity and candidate counts per aggregation level decide how often and how hard a phone searches, and a set that exceeds the per-slot budget is rejected by the phone. The acknowledgement codebook type and the k1 set decide the shape and timing of every reply, and a mismatch between what the network expects and what the phone sends shows up as acknowledgements decoded as garbage. The bandwidth-part inactivity timer and default part decide when a phone falls back to the narrow room. The radio-link-monitoring threshold and the beam-failure count decide how quickly a phone gives up. And the timing-advance command in every log line is clause 4 running; a phone that stops transmitting after a quiet spell has let its alignment timer expire, which is clause 4's standing order to knock again.]

Release 15 established the core monitoring, random-access, feedback, timing, power, bandwidth-part, and type-0 search-space procedures. Release 16 and Release 18 extend recovery, multi-point, sidelink, industrial, reduced-capability, and other control cases while preserving the main clause route, and the exact tables of V18.8.0 take priority over earlier tutorial inventories. Release 18 is a family of coordinated versions; a later corrective version is recorded as a clause-level delta. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states rules; the engineering pages walk the tables with worked rows.

ShareTechnote's [PDCCH](https://www.sharetechnote.com/html/5G/5G_PDCCH.html) page draws search spaces and candidates as the phone sees them, its [type-0 common search space](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html) page walks the clause 13 tables with worked rows, its [power control](https://www.sharetechnote.com/html/5G/5G_PowerControl.html) page evaluates the clause 7 formula with numbers, and its [bandwidth part](https://www.sharetechnote.com/html/5G/5G_CarrrierBandwidthPart.html) page shows a switch on a timeline. Use them to recognise fields, processing order, and log artefacts, then return to the fixed specification for exact definitions and applicability.

A productive lab table has five columns: configured input, derived state or integer, transmitted or received artefact, pass check, and owning clause. If a tutorial uses a different release or omits a branch, record the mismatch rather than merging it silently with the official path.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

This note supports U09–U14. Before class, review binary representation, decibels, probability, protocol layering, and the relevant resource-grid concepts. During class, use Section 4 to locate ownership, Section 5 to audit one calculation, and Section 6 to navigate the fixed specification. Afterwards, connect the clause to a configuration or trace. The maintained course crosswalk remains unchanged.

This Star is a protocol map. It becomes useful when a student asks which document owns a statement, what representation crosses a boundary, or why two apparently similar terms have different test procedures.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “TS 38.211 performs channel coding”

!warning[TS 38.211 owns modulation, sequences, waveforms, and mapping. TS 38.212 owns coding. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.2 “CORESET and search space are synonyms”

!warning[CORESET is a resource region; search space defines when/where the UE tests candidates. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.3 “A slot format schedules data”

!warning[It constrains link direction. A grant and data procedure still select a UE and resources. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.4 “Open-loop power ignores feedback forever”

!warning[Open-loop terms establish a baseline; closed-loop commands can adjust it under the applicable procedure. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

### 9.5 “TS 38.213 owns the complete RACH state machine”

!warning[It owns PHY procedure. TS 38.321 owns MAC random-access state and completion logic. Repair the trace by naming the input/output object, owning clause, companion TS, and observable pass condition.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.213 V18.8.0: Physical-Layer Procedures for Control*, [official PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf).
2. Clause map of this knowledge base.
4. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm).
5. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
6. ShareTechnote, [PDCCH](https://www.sharetechnote.com/html/5G/5G_PDCCH.html), accessed 2026-08-03.
7. ShareTechnote, [Type-0 CSS](https://www.sharetechnote.com/html/5G/5G_CommonSearchSpace_Type0_PDCCH.html), accessed 2026-08-03.
8. ShareTechnote, [power control](https://www.sharetechnote.com/html/5G/5G_PowerControl.html), accessed 2026-08-03.
9. ShareTechnote, [bandwidth part](https://www.sharetechnote.com/html/5G/5G_CarrrierBandwidthPart.html), accessed 2026-08-03.
10. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| NR | New Radio | Section 1; TS 38.213 V18.8.0 |
| UE | User Equipment | Section 1; TS 38.213 V18.8.0 |
| gNB | next generation NodeB | Section 1; TS 38.213 V18.8.0 |
| PDCCH | Physical Downlink Control Channel | Section 1; TS 38.213 V18.8.0 |
| PUCCH | Physical Uplink Control Channel | Section 1; TS 38.213 V18.8.0 |
| PUSCH | Physical Uplink Shared Channel | Section 1; TS 38.213 V18.8.0 |
| PRACH | Physical Random Access Channel | Section 1; TS 38.213 V18.8.0 |
| SRS | Sounding Reference Signal | Section 1; TS 38.213 V18.8.0 |
| UCI | Uplink Control Information | Section 1; TS 38.213 V18.8.0 |
| HARQ-ACK | Hybrid Automatic Repeat Request Acknowledgement | Section 1; TS 38.213 V18.8.0 |
| BWP | Bandwidth Part | Section 1; TS 38.213 V18.8.0 |
| CSS | Common Search Space | Section 1; TS 38.213 V18.8.0 |
| CORESET | Control Resource Set | Section 1; TS 38.213 V18.8.0 |
| RLM | Radio Link Monitoring | Section 1; TS 38.213 V18.8.0 |
| BFR | Beam Failure Recovery | Section 1; TS 38.213 V18.8.0 |
| TA | Timing Advance | Section 1; TS 38.213 V18.8.0 |
| DCI | Downlink Control Information | Section 1; TS 38.213 V18.8.0 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $P_{\mathrm{PUSCH}}$ | Simplified capped PUSCH transmit power | dBm |
| $P_{CMAX}$ | Assumed applicable maximum transmit power | dBm |
| $\mu$ | Numerology index used by the resource-power term | non-negative integer |
| $M_{RB}$ | Scheduled PUSCH allocation width | PRB |
| $P_0$ | Target power term | dBm |
| $\alpha$ | Path-loss compensation factor | dimensionless |
| $PL$ | Estimated path loss | dB |
| $\Delta_{TF}$ | Format/resource adjustment | dB |
| $f_{cl}$ | Closed-loop adjustment | dB |

The symbols mean what they mean in this note; another note may use the same letter for something else.
