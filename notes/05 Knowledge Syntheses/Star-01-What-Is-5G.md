---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 1
title: What Is 5G?
language: en
course_units: []
release_baseline: 18
---

# STAR-01 — What Is 5G?

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Ask ten people what 5G is and most will say "faster internet on my phone". It is a reasonable answer and a misleading one, in the same way that "a faster van" is a misleading answer to "what is the postal service". The van is the part you see. Behind it are streets, a local sorting office, a national hub, an address system, and a rulebook that every country agreed to follow so that a letter posted in Germany arrives in China. 5G is that whole system. The radio — the thing this textbook is mostly about — is the street outside your house.

![[99 Attachments/5G/Concept Figures/STAR-01-What-Is-5G-Concept.png|5G explained as a postal system carrying three kinds of post]]
*Concept figure: 5G explained as a postal system carrying three kinds of post.*

What made 5G different from its predecessors is not that the van got faster, though it did. It is that the system was designed from the start to carry three very different kinds of post on the same streets. Bulk parcels — a film download, where volume matters and a ten-millisecond delay does not. An ambulance dispatch — a stop command to a factory robot, tiny but unforgiving of delay or loss. And millions of postcards — a city's water meters, each sending a few bytes a day on a battery that must last ten years. The engineering names for these are eMBB, URLLC, and mMTC, and almost everything that is configurable in 5G is configurable because these three could not share one fixed design.

This has a consequence for how you read any 5G number. A latency figure measured across the street says nothing about the sorting office or the hub behind it. A speed claim that does not say how many streets were used, in which weather, is not a claim about the system. The first skill this chapter teaches is to ask, of every number, which part of the system it was measured across and which kind of post it was carrying.

**The question this chapter answers.** What makes a system "5G", and which part of a performance claim belongs to the radio, the core, or the application path?

> [!important] **The short answer.** 5G is a system family rather than one speed, band, or waveform. NR supplies the radio interface; NG-RAN organises radio access; 5GC supplies the core functions; and service requirements describe scoped targets. A measured outcome is meaningful only when the workload, probability, reference points, and release are named.

Names you will meet in this note: Fifth Generation (5G), New Radio (NR), Fifth Generation System (5GS), Fifth Generation Core network (5GC), Next Generation Radio Access Network (NG-RAN), User Equipment (UE), enhanced Mobile Broadband (eMBB), Ultra-Reliable and Low-Latency Communications (URLLC), massive Machine-Type Communications (mMTC), Key Performance Indicator (KPI).

This note follows Dahlman, Parkvall, and Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 1, pp. 1–5, DOI [chapter 1](https://doi.org/10.1016/B978-0-12-822320-8.00001-5), and the textbook Chapter 1 PDF. The book explains the design as it was made in Releases 15 and 16; the fixed Release 18 documents cited in Section 6 supply the current clause-level facts.
## 2. Where you are in 5G

Section 1 turned 5G from "faster internet" into a postal system with streets, sorting offices and a rulebook. The map below places that whole system on one page, so that you can see which parts this chapter talks about before we zoom into any of them.

![[99 Attachments/5G/Locator Maps/STAR-01-Where-You-Are-in-5G.png|Where Star 01 sits in the whole 5G system]]
*Locator: Where Star 1 sits in the whole 5G system.*

This chapter lights the two ends of the top band: the device and the core, with the data network beyond. It is the only chapter that looks at the whole postal system at once. Every later chapter zooms into one box — most of them into the radio and the base station between these two ends. The same map appears in every note with different boxes lit; when you feel lost, come back to it.

The Knowledge Structure Map below draws the four things that get called "5G" — the system, the core, the access network, and the radio — as nested scopes, and puts the three service families beside them as lenses that cut across every scope. The mechanism diagram shows how a service requirement narrows, constraint by constraint, to a single radio configuration.

![[99 Attachments/5G/Knowledge Maps/STAR-01-What-Is-5G-Knowledge Structure Map.png]]
*Knowledge map: What the word 5G refers to, from the system down to the radio.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-01-5G-Requirement-to-System-Chain.png|Star 01 mechanism and handoff diagram]]
*Mechanism: How a service requirement narrows to one radio configuration.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 22.261 V18.19.0, clause 6, PDF page 18](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip). The reproduced image is omitted from this distribution.
*Source excerpt: TS 22.261 V 18.19.0, clause 6, PDF page 18, [official 3GPP archive](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip).*

External source: [5G topic index](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html). The reproduced image is omitted from this distribution.
*Source excerpt: 5G topic index, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html).*

> [!note] Searchable structure
> Mobile generations → service families → NR and 5GC → flexible mechanisms → measured outcome.

Read the Knowledge Structure Map along its arrows. Each region is a different kind of object — a condition, a standardised mechanism, an observation, an engineering result — and an arrow only says that one depends on the other. This gives a debugging rule you will use all course: when a result looks wrong, step one box upstream and inspect the object at that boundary. Do not jump from a final KPI straight to a waveform explanation. Most radio errors are category errors before they are arithmetic errors.
## 3. Foundations and prerequisites

Section 2 showed the boxes and lit two of them, the device and the core. Before the mechanisms, four words need settling: what a "generation" is, what a requirement promises, which object NR, NG-RAN and the core each name, and what the three service families are.

### 3.1 Generations are architectural packages

The map spoke of "generations" as if everyone agreed what one is. This section fixes that word first, because every comparison in the course rests on it.

A mobile generation is a package. The first generation carried analogue voice. The second digitised voice and added messaging. The third made packet data a native service, and the fourth moved everything — including voice — onto an all-IP broadband system. At each step the radio changed, but so did the network behind it, the devices in front of it, and the assumptions about what people would do with it. Comparing two generations therefore means comparing four things at once, and a single number such as peak rate captures only one of them.

> [!note] A test that will serve you throughout the course: when someone uses a term like "5G" or "4G", you can think: what physical signal, protocol unit, regulatory decision, or receiver observation they actually mean.
### 3.2 Requirements are conditional

A generation is a package; the numbers quoted for it are requirements. This section asks what a requirement actually promises, and under which conditions.

!important[Every requirement is a sentence with conditions attached. Peak data rate describes an ideal upper situation: one device, perfect channel, all resources. User-experienced rate describes what a typical user sees at a stated percentile. Latency, reliability, mobility, connection density, and energy efficiency each describe a different observation under a different scenario. None can stand in for another, and — the confusion that matters most in practice — a radio transmission interval cannot stand in for end-to-end application latency, because the radio is one queue among several.]

### 3.3 Radio access and core are different objects

Requirements are met by a system, and the system goes by three different names depending on which part you mean. This section separates NR, NG-RAN and the core so that a claim can be pinned to one of them.

Three names are used loosely and mean different things. NR is the air interface between a device and a base station: the waveform, the channels, the procedures. NG-RAN is the access network: the base stations, the functions inside them, and the interfaces between them. The 5G Core handles what a radio cannot — registration, sessions, policy, mobility support, and routing of the user's packets to and from the internet. A standalone 5G deployment joins NG-RAN to the 5G Core. 
### 3.4 Three service families are lenses

With the three objects named, the last foundation is the three kinds of post from Section 1. This section explains why the families are lenses on requirements and why they are not three separate radios.

The three families from the opening — bulk parcels, ambulance dispatch, postcards — are lenses through which requirements are organised. eMBB emphasises capacity and user data rate; URLLC emphasises bounded latency and a very high probability of delivery; mMTC emphasises enormous device counts and efficient tiny transactions. They are not three physical layers. One deployment, on one carrier, can serve features associated with more than one family, and most real networks do.
## 4. Mechanism and derivation

Section 3 gave the vocabulary: generation, requirement, the three objects and the three families. Section 4 puts them in motion and asks how a service need becomes one radio configuration, and why every step costs something.

### 4.1 From need to configuration

The families of Section 3.4 say what a service needs. This section follows one need through the constraints that turn it into a concrete configuration.

Nothing in a 5G configuration is chosen freely. A service need passes through a sequence of constraints, and each removes options. Coverage and the operator's licensed spectrum constrain which carrier can be used. Traffic and latency targets constrain numerology and scheduling. Reliability targets constrain coding, retransmission, and diversity. Device capability — bandwidth, antennas, processing, battery — constrains everything that survived so far. The configuration is whatever is left, and it is one configuration among many.

When you do implementation or experimental work, keep a small ledger for every value you use: where the configuration came from, which release and version, what object it applies to, what it produces, at which reference plane, and how you checked it. This is the habit that stops an inferred number from being reported as a measured or standardised one.

### 4.2 Flexible radio does not remove trade-offs

Section 4.1 ended with a configuration that is whatever survived the constraints. The natural next question is whether NR's flexibility lets you escape those constraints; this section shows that every knob has a price.

Flexibility is not free. Wider bandwidth raises capacity but does nothing for propagation; the signal does not reach further because it is wider. Larger subcarrier spacing shortens symbols and slots, which helps latency and high frequencies, but reduces tolerance of delay spread. More antennas can create spatial gain, and cost calibration, channel estimation, and control overhead to obtain it. Every gain in NR has an accounting boundary, and the chapters that follow are largely about where those boundaries lie.

### 4.3 End-to-end service crosses domains

Sections 4.1 and 4.2 stayed inside the radio. A user's packet does not; this section follows it across every domain it crosses, because that is where latency claims go wrong.

A packet leaving an application waits to be scheduled, crosses the radio, is processed in the base station, travels the transport network, passes a user-plane function in the core, and reaches a server that takes its own time to answer. Each stage has a queue and a failure mode of its own. That is why a credible latency statement names both endpoints and a percentile, and why a reliability statement names what was delivered and by which deadline. The worked example in Section 5 makes this concrete.

### 4.4 Release evolution accumulates capability

The domains of Section 4.3 are described in specifications that keep changing. This section explains how releases accumulate and why a version string matters more than a release name.

Release 15 created the first complete NR baseline. Release 16 added the industrial, sidelink, positioning, unlicensed, and relay capabilities. Release 18, branded 5G-Advanced, extends the same family again. Nothing was thrown away between them. But specifications keep being corrected after a release freezes, so two documents from the same release can differ in detail. Reproducible reading needs the full version string. Star 02 explains the process; Star 27 traces the evolution.

### 4.5 How to test a 5G claim

Everything so far builds toward one skill. With the objects, the domains and the versions in hand, this section gives the two-step test for any 5G claim.

> !important[Two steps. First, classify the claim: is it a requirement, a configuration, a calculation, a simulation, a conformance result, or a field measurement? These are different kinds of evidence and are not interchangeable. Second, name its conditions: link direction, band, bandwidth, device capability, channel, traffic, reference points, percentile, and release. A number that arrives without these may illustrate what is possible, but it cannot characterise 5G — and most numbers in marketing arrive without them.]

## 5. Worked example

Section 4.5 gave a test; Section 5 applies it to one number. The example takes a vendor's latency figure and shows what a full end-to-end budget adds to it.

### 5.1 Worked numerical example

The budget below is the smallest calculation that makes the chain of Section 4.3 concrete: five delays on one path, added in milliseconds.

A vendor demonstration reports only the radio interval, while the engineering question concerns application-to-application latency. Use an illustrative budget to expose the missing terms.

**What we are working out.** End-to-end latency from application request to application response, in milliseconds, at the application endpoints.

$$
\begin{aligned}
T_{e2e} &= T_{air}+T_{proc}+T_{queue}+T_{transport}+T_{app} \\ &= 0.5+0.4+1.1+4.0+2.0 \\ &= 8.0\ \mathrm{ms}
\end{aligned}
$$

Where:

- $T_{e2e}$ = 8.0 ms, calculated (local sum); it belongs to the application endpoints.
- $T_{air}$ = 0.5 ms, assumed (illustrative radio interval); it belongs to the radio interface.
- $T_{proc}$ = 0.4 ms, assumed (illustrative gNB/UE processing); it belongs to the radio endpoints.
- $T_{queue}$ = 1.1 ms, assumed (illustrative scheduling/queue delay); it belongs to the radio system.
- $T_{transport}$ = 4.0 ms, assumed (illustrative transport delay); it belongs to the gNB–core–server path.
- $T_{app}$ = 2.0 ms, assumed (illustrative server time); it belongs to the application server.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $T_{e2e}$ | 8.0 ms | calculated | local sum | application endpoints |
| $T_{air}$ | 0.5 ms | assumed | illustrative radio interval | radio interface |
| $T_{proc}$ | 0.4 ms | assumed | illustrative gNB/UE processing | radio endpoints |
| $T_{queue}$ | 1.1 ms | assumed | illustrative scheduling/queue delay | radio system |
| $T_{transport}$ | 4.0 ms | assumed | illustrative transport delay | gNB–core–server path |
| $T_{app}$ | 2.0 ms | assumed | illustrative server time | application server |

The five terms are parallel delays on one causal path, so milliseconds add. The example shows why a 0.5 ms radio interval does not imply 0.5 ms end-to-end latency. Changing any queue or endpoint changes the total even when NR is unchanged.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. The 3GPP protocol: which document, and what it says

The example used illustrative numbers. This section names the documents where the real definitions live: what 5G must do, how the system is built, and how the radio is described from the top down.

The textbook explains the system; four documents define it. TS 22.261 states what 5G must do, family by family. TS 23.501 defines the system architecture — the core, the access network, and the interfaces between them. TS 38.300 gives the radio side from the top down. And TS 38.306 contains the one formula behind every peak-rate claim you will ever read. The figure lays them out, with the equations they state and what each one looks like when you run a demo.

![[99 Attachments/5G/Protocol Figures/STAR-01-What-Is-5G-Protocol.png|The specifications that define 5G and the peak-data-rate formula]]

*Protocol figure: The specifications that define 5G and the peak-data-rate formula.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| Service objectives | [TS 22.261 V18.19.0, clause 6](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip) | The requirement families and their targets, as the official wording. |
| 5GS architecture | [TS 23.501 V18.12.0, clauses 4–5](https://www.3gpp.org/ftp/Specs/archive/23_series/23.501/23501-ic0.zip) | What the core, the access network, and the device are, and what connects them. |
| NR and NG-RAN | [TS 38.300 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | The radio access network described top-down; the entry point for every later chapter. |
| Release delta | [TR 21.918 V18.0.0, clauses 5–7](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | What Release 18 added, feature by feature. |

!note[**When you build or run a demo.** A first 5G demo — an open-source core, an open-source gNB, and one phone or a software device — exercises exactly the boxes in this chapter. The phone registers with the core: that is the registration procedure of TS 23.502 clause 4.2. It opens a session: clause 4.3. You run a throughput test and get a number: check it against the TS 38.306 data-rate formula for your bandwidth, numerology, and layers, and you will find out whether the demo is radio-limited or limited somewhere else. You ping a server and get a round trip: that is the end-to-end sum of Section 5, and the radio slot was a fraction of it. When the demo does not work, the first question is which of the four boxes failed, and this table tells you which document describes that box.]

Release 15 established NR and the 5G System; Release 16 broadened them to industrial, unlicensed, positioning, sidelink, and relay use; Release 18 adds further system features while keeping requirement, architecture, radio procedure, and measurement as separate things. The textbook's generational story remains the right way to understand the design; present-tense claims must be attached to the fixed versions above. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

### 6.1 Supplement: three scenarios and eight targets

The four documents above are 3GPP's view. The course's training deck opens with the ITU's view, the three scenarios and eight targets that the documents were written to meet; this subsection redraws that opening.

The course's training deck opens where every 5G course does. The figure is that opening, redrawn; the table is the deck's 4G-to-5G comparison with the ITU's own numbers.

![[99 Attachments/5G/Supplement Figures/STAR-01-Saar-Scenarios-and-Targets.png|Three ITU scenarios and the eight IMT-2020 targets against 4G]]

*Supplement figure: Three scenario cards for eMBB, mMTC and URLLC above a table of eight IMT-2020 capability targets compared with IMT-Advanced, and two notes.*
*Figure 6.1 — eMBB, mMTC and URLLC, and the IMT-2020 capability targets beside IMT-Advanced.*

| Capability | 4G (IMT-Advanced) | 5G (IMT-2020) | Factor |
|---|---|---|---|
| Peak data rate | 1 Gb/s | 20 Gb/s | × 20 |
| User-experienced rate | 10 Mb/s | 100 Mb/s | × 10 |
| Air-interface latency | 10 ms | 1 ms | ÷ 10 |
| Connection density | 10⁵ per km² | 10⁶ per km² | × 10 |
| Area traffic capacity | 0.1 Mb/s/m² | 10 Mb/s/m² | × 100 |

- The eight targets are design requirements a candidate technology had to meet; a real deployment trades peak rate, density and latency against each other.
- Each later Star is a mechanism aimed at one petal: numerology and beam management at latency and mobility, massive MIMO at spectral efficiency, RRC_INACTIVE and bandwidth parts at energy.

Source: Supplementary material, *5G key technologies and applications* (training deck, 2018), slides 9–14; ITU-R M.2410.

## 7. ShareTechnote engineering intuition

Specifications state rules; they rarely show what a rule looks like on a screen. This section points to the engineering page that fills that gap and explains how to use it beside the clauses.

ShareTechnote's [5G topic index](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html) is the best single page for a beginner, because it is organised the way a practitioner meets the system: by the thing on the screen — a log line, a message name, a measurement — rather than by specification number. Use it to learn which fields and signals to look for. Then return to the 3GPP clause for the definition and the allowed range, because the tutorial shows one example and the clause states the rule. A good lab notebook keeps four columns: what you configured, what you observed, what you think it means, and which clause you checked it against.

## 8. Course alignment

With the sources placed, this section says where the chapter sits in the Saar course and how to read its sections in order.

This chapter is orientation rather than a direct Saar unit. Use it before U01 to learn the evidence vocabulary—requirement, mechanism, and measured result—then revisit it whenever a later unit presents a performance number. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

## 9. Common confusions

Section 8 told you when to use the chapter. The five sentences below are what students most often say after reading it; each is followed by the fix.

### 9.1 “5G means millimeter wave”

!warning[5G operates across several frequency ranges. High-frequency operation is one deployment option. The fix is to name the frequency range and the deployment option before comparing two systems.]

### 9.2 “A short slot guarantees low latency”

!warning[A slot is one radio timing object. Scheduling, processing, retransmission, transport, and application time remain. The fix is to name the endpoints and the percentile before calling a latency figure a guarantee.]

### 9.3 “eMBB, URLLC, and mMTC are three waveforms”

!warning[They are requirement families. The radio combines configurable mechanisms for a concrete service. The fix is to ask which mechanism was configured.]

### 9.4 “NR is the whole 5G network”

!warning[NR is the radio interface. NG-RAN and 5GC supply other system functions. Name which object the claim is about — radio interface, access network, or core — before accepting it.]

### 9.5 “One peak result describes users”

!warning[Peak, average, percentile, coverage-edge, and application results answer different questions. The fix is to name the statistic and the reference point before treating one result as typical.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 1, pp. 1–5, 2021, DOI [chapter 1](https://doi.org/10.1016/B978-0-12-822320-8.00001-5).
2. textbook Chapter 1 PDF.
4. 3GPP, *TS 22.261 V18.19.0, clause 6*, [Service objectives](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip).
5. 3GPP, *TS 23.501 V18.12.0, clauses 4–5*, [5GS architecture](https://www.3gpp.org/ftp/Specs/archive/23_series/23.501/23501-ic0.zip).
6. 3GPP, *TS 38.300 V18.10.0, clauses 4–6*, [NR and NG-RAN](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
7. 3GPP, *TR 21.918 V18.0.0, clauses 5–7*, [Release delta](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
8. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
9. ShareTechnote, [5G topic index](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html), accessed 2026-08-03.
10. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| 5G | Fifth Generation | Section 1; fixed specification set in Section 6 |
| NR | New Radio | Section 1; fixed specification set in Section 6 |
| 5GS | Fifth Generation System | Section 1; fixed specification set in Section 6 |
| 5GC | Fifth Generation Core network | Section 1; fixed specification set in Section 6 |
| NG-RAN | Next Generation Radio Access Network | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| eMBB | enhanced Mobile Broadband | Section 1; fixed specification set in Section 6 |
| URLLC | Ultra-Reliable and Low-Latency Communications | Section 1; fixed specification set in Section 6 |
| mMTC | massive Machine-Type Communications | Section 1; fixed specification set in Section 6 |
| KPI | Key Performance Indicator | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $T_{e2e}$ | End-to-end latency | ms |
| $T_{air}$ | Radio-interface interval | ms |
| $T_{proc}$ | Radio processing delay | ms |
| $T_{queue}$ | Queue and scheduling delay | ms |
| $T_{transport}$ | Transport/core path delay | ms |
| $T_{app}$ | Application processing delay | ms |

The symbols mean what they mean in this note; another note may use the same letter for something else.
