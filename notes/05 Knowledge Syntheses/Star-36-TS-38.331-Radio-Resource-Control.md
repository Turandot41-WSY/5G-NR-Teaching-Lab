---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 36
title: TS 38.331 Radio Resource Control
language: en
course_units:
- U03–U14 cross-layer reference
release_baseline: 18
---

# STAR-36 — TS 38.331 Radio Resource Control

[Open the specification PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) — TS 38.331 V18.10.0, the version used throughout this note.

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Every lower layer does what it is told. RRC is where the telling happens: a phone and a base station agree on a state, exchange messages in one strict grammar, and configure everything else. It is the control tower's language.

![[99 Attachments/5G/Concept Figures/STAR-36-TS-38.331-Concept.png|TS 38.331 explained as the control tower's language]]

*Concept figure: TS 38.331 explained as the control tower's language.*

Three states are three contracts. In idle there is no connection; the phone is camped on a cell, listens for paging, and reads system information. In inactive the connection is suspended but the context is kept on both sides, so it resumes with less signalling. In connected the connection is active, with dedicated configuration, measurements, handover, and data. Each arrow between them is a named procedure with a timer: setup from idle to connected in three messages bounded by one timer; release with suspend into inactive; resume back; release to idle; and, when the radio link fails, re-establishment or a fall to idle.

Three more ideas complete the picture. Messages are a grammar: every one is written in ASN.1 as a tree of fields, lists, and optional branches, and a decoder that drops an unknown branch gives a plausible, wrong tree; clause 6 is the syntax and clause 5 says what to do with each field. RRC configures and does not do: a reconfiguration can add a bearer, set a timer, name a reference signal, or install a security context, and the owning layer applies it, so a message can complete and a lower layer still apply it wrongly. And measure, then move: clause 5.5 configures what to measure and the event that triggers a report, a neighbour better than the serving cell by an offset for long enough; the report is evidence, the handover command is the decision, and RRC never measures a signal itself. The key fact to carry is that the state fixes what context exists and what may be signalled, and every procedure starts a timer and names what happens on expiry, so no lost message leaves both ends waiting.

**The question this chapter answers.** How does RRC establish and maintain a shared control state between a phone and a base station, configure every lower layer, and coordinate security, measurements, and mobility, without itself performing any radio action?

!important[**The short answer.** RRC carries access-stratum configuration and state changes and transfers non-access-stratum information transparently. It establishes and releases signalling and data radio bearers, distributes system information, activates security, configures lower layers, controls measurements, and coordinates mobility including changes of radio access technology. It commands and describes these actions; the configured lower layer transmits the waveform, schedules the block, or ciphers the packet.]

Names you will meet in this note: Radio Resource Control (RRC), access and non-access stratum (AS, NAS), signalling and data radio bearer (SRB, DRB), radio access technology (RAT), information element (IE), Abstract Syntax Notation One (ASN.1), master and system information block (MIB, SIB), reference signal received power (RSRP), synchronisation signal block (SSB), transaction identifier, the timers T300, T304, T310, T311, and T319.

## 2. Where you are in 5G

Section 1 called RRC the control tower's language. The map below shows where it sits in 5G: at the top of the control plane, configuring every layer below.

![[99 Attachments/5G/Locator Maps/STAR-36-Where-You-Are-in-5G.png|Where Star 36 sits in the whole 5G system]]

*Locator: Where Star 36 sits in the whole 5G system.*

This chapter lights the top of the protocol stack in the specification band: the written form of the connection and states of Star 06, the system information of Star 16, the measurement reports behind the mobility of Stars 12 and 18, and the source of every configured value cited in Stars 29 to 35. It rides the signalling bearers of PDCP, Star 35, and speaks to the core through the architecture of Star 37.

The Knowledge Structure Map draws the state and configuration path. The mechanism diagram traces one connection through its states.

![[99 Attachments/5G/Knowledge Maps/STAR-36-TS-38.331-Knowledge Structure Map.png|STAR-36 system-position map]]

*Knowledge map: TS 38.331 — the three RRC states and the transitions between them.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-36-RRC-State-and-Configuration-Path.png|Star 36 mechanism and handoff diagram]]

*Mechanism: TS 38.331 — how one reconfiguration reaches four layers.*

*Both diagrams are original teaching figures drawn for this course.*

> [!warning] Redraw-required state arrows
> The mechanism draft contains a directional ambiguity. The concept figure above gives the correct directions from TS 38.331 V18.10.0, clauses 4.2 and 5: Setup moves `RRC_IDLE` to `RRC_CONNECTED`, release with suspend moves `RRC_CONNECTED` to `RRC_INACTIVE`, and Resume moves `RRC_INACTIVE` to `RRC_CONNECTED`. The official excerpt and clause text are authoritative.

External source: [TS 38.331 V18.10.0, clause 5, PDF page 43](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.331 V18.10.0, clause 5, PDF page 43, [official 3GPP archive](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [RRC overview](https://www.sharetechnote.com/html/5G/5G_RRC_Overview.html). The reproduced image is omitted from this distribution.

*Source excerpt: RRC overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_RRC_Overview.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

> [!warning] Figure correction
> The map's clause panel is not official. In TS 38.331 V18.10.0 the authoritative order is **5.4 inter-RAT mobility**, **5.5 measurements**, **5.6 UE capabilities**, and **5.7 other procedures**. Security is part of **5.3 connection control**, including the AS security context and initial activation. The body clause table overrides the image labels.

**Searchable structure.** State → message → configuration → result → next state.


## 3. Foundations and prerequisites

Section 2 placed RRC. Four foundations follow: states as contracts, configuring rather than doing, messages as a schema, and timers that make procedures finite.

### 3.1 Necessary background: states are contracts

The first foundation is the three states and what each keeps.

!important[Idle, inactive, and connected summarise what context is retained and which procedures are available: idle emphasises cell selection, reselection, system information, and paging; inactive retains access-network context so the connection resumes with less signalling; connected maintains an active connection with dedicated configuration, reporting, mobility, and data. A state name alone does not explain a transition; a trace must record the initiating event, selected cell, stored context, timer, message, and completion condition. Release can lead to idle or inactive by message content; resume is not setup.]

> [!spec] 3GPP reality check
> The states and transitions are [TS 38.331 V18.10.0, clause 4.2](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf); setup is clause 5.3.3 under T300, release with suspend clause 5.3.8, and resume clause 5.3.13 under T319.

### 3.2 RRC configures rather than performs lower-layer work

Section 3.1 gave the states. This section says what RRC does inside them: it configures, and other layers act.

!important[A message can configure PDCP, RLC, MAC, and the physical layer, add a bearer, select a timer, provide a measurement object, name a reference signal, or supply security, and the receiving implementation applies the elements to the owning layer. Two failure classes follow: a control-plane failure, where the message, transaction, validation, or transition did not complete, and a configuration-effect failure, where the exchange completed but a lower layer applied the object incorrectly. Log the handoff as producer, message field, consumer, applied value, observable.]

### 3.3 Messages and information elements form a schema

Section 3.2 said RRC configures. This section shows the grammar it configures in.

Clause 6 defines the message containers and each information element in ASN.1: a message chooses procedure and direction, nested elements carry configuration objects, identifiers, lists, options, and extensions, and the same element type may appear in several messages with presence depending on state, capability, release, or condition. Decode in order: top-level message and critical-extension branch, transaction identity, nested lists by identifier, then the clause 5 procedure for each field. A decoder that drops an unknown extension yields a plausible but incomplete tree, so a log tool must keep raw bytes, release context, and schema version.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [RRC overview](https://www.sharetechnote.com/html/5G/5G_RRC_Overview.html) shows decoded setup and reconfiguration messages as trees beside their ASN.1, which is the fastest way to see how a field name in the specification becomes a line in a log.

### 3.4 Timers and transactions make procedures finite

The last foundation is what stops a procedure from waiting forever.

Many procedures start a timer, await a response or radio event, and define a failure action on expiry, including establishment, re-establishment, resume, handover synchronisation, and barring; the timer is part of the official state machine. Transaction identifiers match selected command and complete exchanges, though not every message uses one the same way. A robust trace keeps direction, state before, trigger, transaction identity, timer start and stop, content, lower-layer handoff, and state after. The protected first-pass extraction gives a short route into this very large document; the fixed archive remains official.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 walks the clauses in order.

### 4.1 Clause 4 defines states, services, and functions

The walk starts with clause 4: states, services and functions.

Clause 4 introduces the states and transitions, including interaction with other technologies, defines the use of signalling bearers, the services provided upward and expected below, and the function set: system-information broadcast, paging, connection establishment and maintenance, bearer control, security coordination, mobility, measurement configuration and reporting, and capability exchange. Architecture does not prescribe one software process, in the base station or the phone. Clause 4 answers what state or bearer can exist; the trigger for a message belongs to clause 5.

### 4.2 Clause 5.2 governs system information

Section 4.1 named the functions. This section reads clause 5.2, system information.

The phone needs common information before dedicated control can configure it. Clause 5.2 defines acquisition, validity, re-acquisition, change indication, on-demand requests, and actions after reception; the master block supplies the earliest parameters and the system blocks, from SIB1, the access, scheduling, and common information. Distinguish acquisition, validity, and application: a phone can decode a block and judge it invalid for the area, value tag, or context, or know that information changed without holding the new content. A trace should record cell, state, block type, scheduling source, value tag, trigger, decode, and application time.

> [!spec] 3GPP reality check
> Acquisition, the value tag, the three-hour validity, and the change indication by paging are [TS 38.331 V18.10.0, clause 5.2.2](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf); the scheduling of the blocks is the si-SchedulingInfo of SIB1 in clause 6.3.1.

### 4.3 Clause 5.3 owns connection control and security activation

Section 4.2 read the broadcast. This section reads clause 5.3, where a connection is controlled and security activated.

Connection control begins with paging and establishment, then reconfiguration, bearer changes, security, re-establishment, release, resume, access control, radio-link-failure handling, and release-specific branches: clause 5.3.3 is setup, 5.3.5 the reconfiguration hub carrying cell-group, bearer, measurement, and mobility configuration, 5.3.7 re-establishment, 5.3.8 release, 5.3.13 resume. Security belongs here: clause 5.3.1.2 establishes the access-stratum security context and 5.3.4 activates it through the security-mode procedure, with key updates in reconfiguration. RRC carries the control and selects the context; PDCP applies the protection. Order matters: activation must use the accepted algorithm and context, and the completion message is part of the transition.

> [!spec] 3GPP reality check
> Setup with T300 is clause 5.3.3; the security-mode command, integrity-protected but not ciphered, and its algorithms are clause 5.3.4; reconfiguration with synchronisation and T304 is clause 5.3.5.5; the timer and constant values are the tables of clause 7.1.

### 4.4 Clauses 5.4–5.7 have fixed, distinct jobs

Section 4.3 covered the connection. This section reads clauses 5.4 to 5.7, each with one fixed job.

Clause 5.4 is inter-RAT mobility, handover to NR and mobility from NR, without the main measurement framework. Clause 5.5 is measurements: objects, report configurations, identities, quantity configuration, gaps and timing, performance, layer-3 filtering, event triggering, and report construction, with reference-signal power from the synchronisation block or channel-state signal and events A1 to A6 and B1 and B2 comparing filtered results with offsets, thresholds, and hysteresis. Clause 5.6 is capabilities: the enquiry and the phone's supported bands, combinations, and feature sets, which say what it supports. Clause 5.7 is other procedures: information transfer, failure information, assistance, segmentation, idle and inactive measurements, history, positioning, application-layer reporting; clause 5.8 opens sidelink. These labels are the correction to the supplied image.

> [!spec] 3GPP reality check
> The layer-3 filter and its coefficient are clause 5.5.3.2, the event entry conditions such as A3 clause 5.5.4, and the report contents clause 5.5.5; the capability enquiry is clause 5.6.1.

### 4.5 Clause 6 turns procedure intent into bits

The walk ends with clause 6, where procedure becomes bits.

Clause 6 defines the messages, elements, field semantics, constraints, and ASN.1, with critical extensions allowing evolution while preserving decode structure. Never apply a field by name alone: use the enclosing message, extension branch, presence condition, release schema, identifier references, and the clause 5 action; a list to add or modify differs from a list to release, and an absent optional field can mean reuse, release, default, or not applicable. The complete chain is trigger, current state, message and transaction, validated elements, lower-layer application, timer and result, new state.

## 5. Worked example

Section 4 walked the clauses. Section 5 evaluates one measurement event, a calculation you can redo by hand.

### 5.1 Worked numerical example

The example below evaluates Event A3 with chosen levels and offsets.

Clause 5.5.4.4 defines Event A3 around a neighbor becoming offset-better than the serving primary cell. Assume the configured measurement identity already resolves to the intended object and report configuration. Use Layer-3-filtered serving and neighbor levels, frequency/cell offsets, A3 offset, and hysteresis at one evaluation instant.

**What we are working out.** The Event A3 entry margin $D_{\mathrm{A3}}$ in decibels at the UE's filtered-measurement reference plane. A positive result satisfies the entry inequality at this instant; it does not by itself prove that time-to-trigger has elapsed or that a report was sent.

$$
\begin{aligned}
D_{\mathrm{A3}}
&=\left(M_n+O_{fn}+O_{cn}-H_{ys}\right)
-\left(M_p+O_{fp}+O_{cp}+O_{ff}\right)\\
&=\left(-92+0+1-2\right)
-\left(-97+0+0+3\right)\ \mathrm{dB}\\
&=(-93)-(-94)\ \mathrm{dB}\\
&=1\ \mathrm{dB}.
\end{aligned}
$$

Where:

- $D_{\mathrm{A3}}$ is the entry margin: 1 dB, calculated (the equality chain using TS 38.331 clause 5.5.4.4); it belongs to the UE's Layer-3-filtered event evaluation.
- $M_n$ is the neighbor-cell measurement result: -92 dBm, assumed (the instructional filtered trace); it belongs to the configured neighbor object.
- $M_p$ is the serving primary-cell measurement result: -97 dBm, assumed (the instructional filtered trace); it belongs to the serving cell.
- $O_{fn}$ and $O_{fp}$ are frequency-specific offsets for neighbor and serving frequencies; local values 0 dB and 0 dB; evidence (assumed); source the instructional measurement configuration; reference plane event evaluation.
- $O_{cn}$ and $O_{cp}$ are cell-specific offsets for neighbor and serving cells; local values 1 dB and 0 dB; evidence (assumed); source the instructional measurement configuration; reference plane event evaluation.
- $H_{ys}$ is configured hysteresis: 2 dB, assumed (the instructional report configuration); it belongs to the entry condition.
- $O_{ff}$ is the configured A3 offset: 3 dB, assumed (the instructional report configuration); it belongs to the comparison threshold.
- The bracketed levels are handled numerically in dBm with dB offsets. Their subtraction cancels the common one-milliwatt logarithmic reference and yields a margin in dB.

#### 5.1.1 Variable-value table

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $D_{\mathrm{A3}}$ | 1 dB | calculated | local equality chain; clause 5.5.4.4 | UE event evaluation |
| $M_n$ | -92 dBm | assumed | instructional filtered trace | configured neighbor cell |
| $M_p$ | -97 dBm | assumed | instructional filtered trace | serving primary cell |
| $O_{fn}$ | 0 dB | assumed | instructional configuration | neighbor frequency |
| $O_{fp}$ | 0 dB | assumed | instructional configuration | serving frequency |
| $O_{cn}$ | 1 dB | assumed | instructional configuration | neighbor cell |
| $O_{cp}$ | 0 dB | assumed | instructional configuration | serving cell |
| $H_{ys}$ | 2 dB | assumed | instructional report configuration | A3 entry condition |
| $O_{ff}$ | 3 dB | assumed | instructional report configuration | A3 comparison |

**Dimensional and sanity check.** Offsets and hysteresis are differences in dB; they can adjust logarithmic levels expressed in dBm. Subtracting the two adjusted levels leaves dB, so the 1 dB result is dimensionally correct. If the neighbor level falls by 2 dB with every configuration value fixed, the margin becomes negative; this direction matches the event's physical meaning.

The calculation only checks the entry inequality at one instant. The UE must also apply the configured time-to-trigger and other clause conditions before the event is considered fulfilled and a report is initiated. Layer-3 filtering means the input values are not raw instantaneous samples. Measurement availability, gaps, reference-signal timing, state, and report limits remain separate prerequisites.

For debugging, recompute the margin from the exact decoded configuration and filtered measurements. If the arithmetic disagrees with the UE, inspect identifier resolution and offset signs. If it agrees but no report appears, inspect time-to-trigger, leaving/entering transitions, state, report amount, and message transmission rather than changing the formula.

## 6. The 3GPP protocol: which document, and what it says

The example evaluated one event. This section names what each clause fixes and draws the handshake, the security command and the event.

Clause 5 is the procedures with their timers; clause 6 is the ASN.1 they carry. The figure draws the setup handshake under T300, the security-mode command and its algorithms, the value-tag and age rule for stored system information, the A3 event with the layer-3 filter, and the handover under T304, and sets each beside the configuration line that sets it and the log line that shows it.

![[99 Attachments/5G/Protocol Figures/STAR-36-TS-38.331-Protocol.png|The RRC states and procedures of TS 38.331 with their timers, the measurement event and filter formulas, the system-information validity rule and the ASN.1 schema, with the configuration lines each becomes]]

*Protocol figure: The RRC states and procedures of TS 38.331 with their timers, the measurement event and filter formulas, the system-information validity rule and the ASN.1 schema, with the configuration lines each becomes.*

| Clause | Authoritative scope | Start here for | Do not confuse with |
|---|---|---|---|
| 4 | states, bearers, services, functions | architecture and state vocabulary | detailed message actions |
| 5.1 | general procedure requirements | shared UE behaviour and MR-DC context | one specific procedure |
| 5.2 | system information | acquisition, validity, SIB actions | dedicated reconfiguration |
| 5.3 | connection control and AS security | setup, security, reconfiguration, failure, release, resume | inter-RAT mobility or measurements |
| 5.4 | inter-RAT mobility | handover to NR and mobility from NR | main measurement events |
| 5.5 | measurements | objects, filtering, events, reports | the physical measurement definition alone |
| 5.6 | UE capabilities | enquiry and capability transfer | current configuration |
| 5.7 | other procedures | information transfer, assistance, failure, history | the sidelink branch |
| 5.8 onward | sidelink and specialised procedures | direct, relay, and sidelink control | the Uu connection-control core |
| 6 | messages and IEs | ASN.1 syntax and field semantics | procedure trigger and state |
| 7 | timers, counters, constants | every value with its allowed set | the procedure that uses it |

!note[**When you build or run a demo.** The RRC log is the demo's story told in order: a setup request, a setup, a complete, a security-mode command and its complete, a capability enquiry, and a reconfiguration that carries the bearers and the measurement configuration; each has a timer from clause 7 whose value the cell broadcasts, and a demo that drops phones after a fixed interval is usually a timer expiring on a message that never arrived. The measurement event offsets, hysteresis, time to trigger, and filter coefficient are the lines that decide when a phone reports a neighbour, and a handover demo that ping-pongs has a small offset or a short time to trigger. The security algorithms named in the command must be ones the core and the phone share, and a mismatch shows as a phone that connects and then silently fails every packet. Every lower-layer configuration in this course arrived as a field in one of these messages, and the raw message bytes with the schema version are the only reliable evidence of what was actually sent.]

The stable core is familiar across releases: the three states, system information, setup, security activation, reconfiguration, measurement, mobility, capability exchange, release, resume, re-establishment, and an extensible schema. V18.10.0 adds a far larger surface: conditional and lower-layer-triggered mobility, small data in the inactive state, sidelink and relay, non-terrestrial control, reduced-capability support, multicast, positioning, multipath, and application-layer measurement. This is a reading delta; a V18 decoder accepting a field does not mean a Release 15 peer understands it. The map correction holds across releases: 5.4 is inter-RAT mobility, 5.5 measurements, 5.6 capabilities, 5.7 other, and security stays in 5.3. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The specification states procedures; the engineering pages show the messages that move between states.

ShareTechnote's [RRC overview](https://www.sharetechnote.com/html/5G/5G_RRC_Overview.html) helps a beginner see idle, inactive, and connected operation and the messages that move between them, and its [measurement report](https://www.sharetechnote.com/html/5G/5G_MeasurementReport.html) page suggests an object-first workflow: resolve a measurement identity into one object and one report configuration, then the quantity, reference-signal type, offsets, filtering, gaps, and event rule, and only then evaluate a reported value. TS 38.331 V18.10.0 remains the source for exact messages, timers, conditions, and actions.

For any RRC failure, build a six-line table: state before, trigger, message, decisive element, timer and transaction, state after, plus one lower-layer observable such as bearer creation, search-space update, measurement start, or security activation, which shows whether the protocol failed or the configured effect failed later. Tutorial screenshots may use another release or display convention; preserve the raw message and fixed schema so a tree view never becomes the sole evidence.

## 8. Course alignment

With the clauses and the pages in place, this section positions the chapter in the course.

The Saar University 5G course alignment uses RRC after cell acquisition, radio-interface architecture, Layer 2, control signaling, and measurement foundations. The learner already knows what a resource, bearer, reference signal, and lower-layer procedure is; this Star explains how the network and UE agree on the configuration that makes those mechanisms operate together.

One course exercise can follow `MIB`/`SIB1` acquisition into connection setup, security activation, and reconfiguration. A second can decode a measurement identity and reproduce the Event A3 comparison from Section 5. The exercise should mark which result is an RRC outcome and which belongs to PHY, MAC, RLC, or PDCP.

For revision, use a compact route: current state → trigger → clause-5 procedure → clause-6 message/IE → lower-layer owner → timer/result → next state. This route works for setup, resume, re-establishment, measurement, and mobility without memorizing the full ASN.1 tree.

RRC also bridges into architecture. In a split gNB, control termination belongs in the control-plane central function, while lower-layer configuration crosses the appropriate internal interfaces. The following TS 38.401 Star uses that handoff to place RRC, PDCP, and user traffic in their nodes.

### 8.1 Supplement: initial registration

The confusions come after the supplements. RRC setup carries the first NAS message; this supplement follows what the core does with it.

RRC setup carries the first NAS message; this is what the core does with it. The comic's five questions, redrawn with the TS 23.502 message names.

![[99 Attachments/5G/Supplement Figures/STAR-36-Saar-Initial-Registration.png|Initial registration in seven steps]]

*Supplement figure: Sequence diagram of initial registration across UE, gNB, AMF, AUSF, UDM and PCF in seven numbered steps.*
*Figure 8.1 — Registration Request, authentication through AUSF and UDM, mutual authentication, subscription and policy retrieval, Registration Accept.*

| Step | Message | Settles |
|---|---|---|
| 1 | Registration Request (SUCI or 5G-GUTI, type initial) | who is asking |
| 2–4 | Nausf authentication, Nudm vector, Authentication Request/Response | both sides are genuine |
| 5 | Nudm registration and subscription data | what was bought; which AMF serves the UE |
| 6 | Npcf access-and-mobility policy | where and with what priority |
| 7 | Registration Accept (5G-GUTI) + Complete | a temporary identity replaces SUCI |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 02; 3GPP TS 23.502 clause 4.2.2.

### 8.2 Supplement: paging and the service request

Section 8.1 registered the phone. This supplement shows what survives idle and what the service request restores.

RRC_IDLE seen from the core: registration and sessions survive, the radio, N2 and N3 do not. The service request restores only what the current task needs.

![[99 Attachments/5G/Supplement Figures/STAR-36-Saar-Service-Request.png|Paging and the service request]]

*Supplement figure: Sequence diagram of the service request procedure across UE, gNB, AMF, SMF and UPF, preceded by paging.*
*Figure 8.2 — Downlink data notification, paging, Service Request, session activation, uplink then downlink tunnels restored.*

| Trigger | First message | Then |
|---|---|---|
| network-triggered | downlink data notification → Paging | UE answers with Service Request |
| UE-triggered | Service Request | AMF activates the sessions in use via SMF and UPF |

Source: Supplementary material, *Illustrated 5G signalling flows*, part 05; 3GPP TS 23.502 clause 4.2.3.

### 8.3 Supplement: deregistration

Section 8.2 restored a session. This supplement takes everything down in order.

Airplane mode is a deregistration. The order matters: sessions first, presence and policy records next, the radio last.

![[99 Attachments/5G/Supplement Figures/STAR-36-Saar-Deregistration.png|Deregistration in five steps]]

*Supplement figure: Sequence diagram of UE-initiated deregistration across UE, gNB, AMF, SMF, UPF, UDM and PCF in five steps.*
*Figure 8.3 — Deregistration Request, session release through SMF and UPF, UDM and PCF clean-up, Deregistration Accept and N2 release.*

- Idle is not deregistered: an idle UE can be paged; a deregistered UE must register from scratch.
- The UE, the AMF or the UDM may start the procedure; the clean-up order is the same.

Source: Supplementary material, *Illustrated 5G signalling flows*, part 06; 3GPP TS 23.502 clause 4.2.2.3.

## 9. Common confusions

The sentences in the table below are the misreadings this chapter is meant to prevent, each with its fix and a trace check.

| Confusion | Correct reading | Trace check |
|---|---|---|
| Clause 5.4 is security | Security is primarily in 5.3 connection control; 5.4 is inter-RAT mobility. | Which exact 5.3 security procedure ran? |
| Clause 5.5 is mobility | 5.5 owns measurements; 5.4 owns inter-RAT mobility. | Is the object an event/report or a RAT change? |
| Capability means configuration | Capability reports support; RRC separately selects configuration. | Was the feature actually configured? |
| Complete message proves radio success | It proves a control exchange. | What observable shows application? |
| Inactive equals idle | Inactive retains access-network context for resume. | Which context and identifier remain? |
| RRC performs ciphering | RRC activates/configures security; PDCP applies protection. | Which bearer, COUNT, and PDCP context? |

The image's clause panel reverses several ownership labels. A reader following it would search 5.4 for security, 5.5 for mobility, 5.6 for capability transfer, and 5.7 for measurements. Only the capability label happens to point to the right broad area. Use the clause table in Section 6 and the V18.10.0 document instead.

!warning[Measurement arithmetic has two additional traps. First, RSRP levels in dBm combine with offsets in dB; the final comparison margin is in dB. Second, satisfying an event inequality at one instant does not prove time-to-trigger completion. Filtering and report limits can also alter the observed sequence.]

!warning[Message syntax can be mistaken for procedure ownership. An IE defined in clause 6 may configure PDCP or PHY, but clause 6 does not execute that lower-layer mechanism. Always read the enclosing clause-5 action and then hand the field to the named owner.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. 3GPP, *TS 38.331 V18.10.0: Radio Resource Control protocol specification*, [official PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf).
2. Clause map of this knowledge base.
4. 3GPP, [38-series specification index](https://www.3gpp.org/dynareport/38-series.htm).
5. ShareTechnote, [RRC overview](https://www.sharetechnote.com/html/5G/5G_RRC_Overview.html), accessed 2026-08-03.
6. ShareTechnote, [measurement report](https://www.sharetechnote.com/html/5G/5G_MeasurementReport.html), accessed 2026-08-03.
7. Saar University 5G course alignment.
8. Supplementary course material (not redistributed): the illustrated 5G signalling flow series, the radio-basics handouts and the 2018 key-technology training deck, as redrawn in the Supplement subsections above.

The clause map of this knowledge base is a locator, the ledger records reuse decisions, tutorials provide engineering intuition, and the official archive alone fixes official V18.10.0 behavior.

## 11. Abbreviation index

The canonical course vocabulary is maintained in [[5G Abbreviation Database|the 5G abbreviation database]]. The table also follows the shared format in [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| RRC | Radio Resource Control | RRC is the stateful control protocol between UE and gNB. It carries configuration and coordinates procedures across radio layers. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| UE | User Equipment | A UE is the user-side protocol endpoint. It applies received configuration and reports procedure results. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| gNB | next generation NodeB | A gNB is the NG-RAN node serving the UE. Its RRC peer controls radio connection and configuration. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| AS | Access Stratum | The AS contains radio-access protocols and procedures. Its security context protects configured radio signaling and traffic. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| NAS | Non-Access Stratum | NAS signaling runs between UE and core network functions. RRC can transfer it transparently across the radio access. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| SRB | Signalling Radio Bearer | An SRB carries control-plane signaling. RRC establishes and configures SRBs for defined procedures. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| DRB | Data Radio Bearer | A DRB carries user-plane traffic. RRC adds, modifies, or releases its configuration. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| RAT | Radio Access Technology | A RAT is one radio-system family such as NR or E-UTRA. Clause 5.4 controls mobility between RATs. | Section 1; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| PDCP | Packet Data Convergence Protocol | PDCP applies packet continuity and configured protection below RRC or SDAP. RRC supplies its bearer configuration and security context. | Section 3.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| RLC | Radio Link Control | RLC segments, reassembles, and optionally retransmits lower-layer data. RRC configures its bearer mode and parameters. | Section 3.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| MAC | Medium Access Control | MAC multiplexes and schedules radio transport. RRC supplies parameters but does not run the scheduler. | Section 3.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| PHY | Physical Layer | PHY transmits and receives physical channels and signals. RRC configures resources whose execution remains in PHY. | Section 3.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| IE | Information Element | An IE is a typed field or container in the RRC schema. Its enclosing message and procedure determine how it is used. | Section 3.3; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| ASN.1 | Abstract Syntax Notation One | ASN.1 defines the machine-readable RRC message schema. Release selection controls which extension branches a decoder understands. | Section 3.3; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| MIB | Master Information Block | The MIB provides the earliest essential system information. It helps the UE continue cell acquisition and obtain SIB1. | Section 4.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| SIB | System Information Block | A SIB carries broadcast or requested common configuration. Its validity and acquisition conditions matter independently of successful decoding. | Section 4.2; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| RSRP | Reference Signal Received Power | RSRP is a reference-signal power measurement used in configured event evaluation. Layer-3 filtering and offsets shape its RRC-level use. | Section 4.4; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| SSB | Synchronization Signal and PBCH Block | An SSB supplies synchronization and broadcast resources that can also support measurement. RRC identifies how its results enter configured reporting. | Section 4.4; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| CSI-RS | Channel State Information Reference Signal | CSI-RS provides configurable reference resources for channel measurement. RRC links those resources to measurement objects and reports. | Section 4.4; [TS 38.331 V18.10.0](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| SUCI | Subscription Concealed Identifier | The SUCI is the SUPI encrypted with the home network's public key. It is used in the first Registration Request. | Section 8; Supplement |
| SUPI | Subscription Permanent Identifier | The SUPI is the permanent subscriber identity issued on the SIM. It is never sent in clear over the air. | Section 8; Supplement |
| 5G-GUTI | 5G Globally Unique Temporary UE Identity | The 5G-GUTI is the temporary identity the AMF allocates in Registration Accept. It replaces the permanent identity in later NAS messages. | Section 8; Supplement |
| AUSF | Authentication Server Function | The AUSF runs primary authentication for a subscriber. It lets the network verify the UE and the UE verify the network before registration continues. | Section 8; Supplement |
| UDM | Unified Data Management | The UDM holds subscription data and the current serving-function records. Registration and session procedures read subscription and presence information from it. | Section 8; Supplement |
| PCF | Policy Control Function | The PCF decides access-and-mobility and session policies. It supplies QoS, charging and area rules to the AMF and SMF. | Section 8; Supplement |
| SMF | Session Management Function | The SMF owns each PDU session in the 5G core. It selects the UPF, allocates the IP address and installs QoS and charging rules over N4. | Section 8; Supplement |
| N2 | N2 interface | N2 carries control signalling between the NG-RAN and the AMF. Idle releases it and the service request restores it. | Section 8; Supplement |
| N3 | N3 interface | N3 carries user-plane tunnels between the NG-RAN and the UPF. Idle releases it and the service request restores it. | Section 8; Supplement |
| TAI | Tracking Area Identity | A TAI names a tracking area inside a PLMN. Registration Accept gives the UE the list of areas where it need not re-register. | Section 8; Supplement |
| NSSAI | Network Slice Selection Assistance Information | The NSSAI lists the slices a UE requests or is allowed. Registration Accept returns the allowed set. | Section 8; Supplement |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain | Role and convention |
|---|---|---|---|
| $D_{\mathrm{A3}}$ | Event A3 entry margin | dB | Positive means the entry inequality is met at the evaluated instant. |
| $M_n$ | Neighbor-cell filtered measurement | dBm | Level at the configured neighbor reference plane. |
| $M_p$ | Serving primary-cell filtered measurement | dBm | Level at the serving reference plane. |
| $O_{fn}$, $O_{fp}$ | Frequency-specific offsets | dB | Apply to neighbor and serving frequencies. |
| $O_{cn}$, $O_{cp}$ | Cell-specific offsets | dB | Apply to neighbor and serving cells. |
| $H_{ys}$ | Event hysteresis | dB | Makes entry harder and limits chattering. |
| $O_{ff}$ | Event A3 offset | dB | Configured comparison advantage. |

The measurement levels share the dBm reference, while offsets and the final margin are differences in dB. Time-to-trigger is a procedure parameter.
