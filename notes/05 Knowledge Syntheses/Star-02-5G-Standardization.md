---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 2
title: 5G Standardization
language: en
course_units: []
release_baseline: 18
---

# STAR-02 — 5G Standardization

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Nobody owns 5G. No company designed it, no government decreed it, and yet a phone made in Korea attaches to a base station made in Sweden in a network run from Germany, and it works on the first try. That only happens because the radio was written down, in exhausting detail, as a recipe that thousands of engineers from competing companies agreed on line by line. This chapter is about how that recipe gets written.

![[99 Attachments/5G/Concept Figures/STAR-02-5G-Standardization-Concept.png|How a 3GPP specification comes to exist, told as a recipe]]

*Concept figure: How a 3GPP specification comes to exist, told as a recipe.*

The kitchen has a fixed sequence. First a wish list: the ITU, a United Nations agency, says what the next generation must achieve — how fast, how quick, how many devices — but does not say how. Then a feasibility study inside 3GPP, the industry partnership that actually writes the recipe, asking whether the wish can be met at all. Then the writing, in three stages: what the system must do, how its parts fit together, and finally the exact bytes on the wire. Then an edition — a release — after which no new features are added. And then, for years, corrections: change requests that keep editing the text, each one raising the version number. Meanwhile vendors cook from the text, and testers check each product against it.

Why should a student care how the sausage is made? Because the recipe is the only thing that is true. A textbook explains it; a tutorial site illustrates it; an open-source stack approximates it. But when a demo does not work, the answer lives in a numbered clause of a numbered document at a specific version, and learning to open that document is the single most useful skill this course teaches. Every later note ends with a table of exactly which clauses to open. This chapter explains why those tables exist and how to read what they point to.

**The question this chapter answers.** How does a 5G idea become a versioned requirement, architecture, protocol, radio interface, and interoperable product?

!important[**The short answer.** No single organisation writes 5G end to end. ITU-R frames the IMT objectives and evaluates candidate radio interfaces; administrations regulate spectrum; 3GPP develops a staged specification set; companies implement it; and conformance, interoperability, and field validation test different boundaries. A release is a coordinated baseline, while each specification continues through fixed corrective versions.]

Names you will meet in this note: Fifth Generation (5G), International Telecommunication Union (ITU), ITU Radiocommunication Sector (ITU-R), International Mobile Telecommunications (IMT), International Mobile Telecommunications 2020 (IMT-2020), Third Generation Partnership Project (3GPP), Technical Specification (TS), Technical Report (TR), Radio Access Network (RAN), Service and System Aspects (SA), Core Network and Terminals (CT), User Equipment (UE).

This note follows Dahlman, Parkvall, and Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 2, pp. 7–26, DOI [chapter 2](https://doi.org/10.1016/B978-0-12-822320-8.00002-7), and the textbook Chapter 2 PDF. The book describes the process as it produced Releases 15 and 16; Section 6 attaches the current facts to fixed Release 18 documents.

## 2. Where you are in 5G

Section 1 described the kitchen where a specification is cooked. The map below shows where that kitchen sits relative to the system it produces: a strip along the edge, feeding every other box.

![[99 Attachments/5G/Locator Maps/STAR-02-Where-You-Are-in-5G.png|Where Star 02 sits in the whole 5G system]]

*Locator: Where Star 2 sits in the whole 5G system.*

This chapter lights the strip labelled standards and evolution: the process that produces every specification number written on every other box of the map. It is not part of the system the way a base station is; it is the reason the system exists in a form that different vendors can build. When any later note cites "TS 38.211 V18.9.0, clause 4.2", it is relying on what this chapter explains.

The Knowledge Structure Map draws the three separate authorities — ITU-R, 3GPP, and national regulators — as three columns rather than one hierarchy, each with what it can and cannot do, and the six working groups that write the specifications a reader will actually open. The mechanism diagram follows one feature from study item to functional freeze, with the change-request stream that keeps the text moving afterwards.

![[99 Attachments/5G/Knowledge Maps/STAR-02-5G-Standardization-Knowledge Structure Map.png]]

*Knowledge map: The three authorities behind a 5G specification.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-02-Standardization-to-Implementation-Chain.png|Star 02 mechanism and handoff diagram]]

*Mechanism: How a 3GPP feature travels, and why the document keeps changing.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TR 21.918 V18.0.0, clause 4, PDF page 9](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip). The reproduced image is omitted from this distribution.

*Source excerpt: TR 21.918 V18.0.0, clause 4, PDF page 9, [official 3GPP archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip), accessed 2026-08-04.*

External source: [5G agreements and standardization history](https://www.sharetechnote.com/html/5G/5G_Agreements.html). The reproduced image is omitted from this distribution.

*Source excerpt: 5G agreements and standardization history, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_Agreements.html), accessed 2026-08-04.*

> [!note] Searchable structure
> Global policy → IMT requirements → 3GPP stages and groups → release freeze → conformance and deployment.

Read the map along its arrows: each region is a different kind of thing, and an arrow only says that one depends on the other.

## 3. Foundations and prerequisites

Section 2 placed standardisation beside the system. Before following a feature through the process, four things need to be clear: who has authority over what, what ITU-R supplies, how 3GPP writes in stages, and how its groups divide the work.

### 3.1 Regulation and standardization have different authority

The map showed three columns of authority. This section starts with the two that are most often confused, the regulator and the standards body, and asks what each can compel.

!important[Two kinds of authority are easy to confuse and never overlap. A regulator decides whether, where, and under what conditions spectrum may be used in its country; that is law, and it can be enforced. A standards body decides what interoperable equipment must do; that is agreement, and it binds only those who choose to build to it. A standardised band grants nobody permission to transmit, and a national licence defines no radio protocol. Between them sits ITU-R, coordinating international allocations so that neighbouring countries do not interfere, but even it cannot compel a national regulator.]

### 3.2 ITU-R supplies the global IMT frame

Between regulator and standards body sits ITU-R. This section explains what its IMT frame contributes and where it deliberately stops.

ITU-R's contribution is the frame. Its recommendations and reports for IMT-2020 state the requirements a candidate technology must meet, the method by which it will be evaluated, and — after evaluation — which technologies are accepted as IMT. This creates a common comparison boundary that every proposal must cross. It says nothing about how a base station or a phone is built. That detail is left, deliberately, to 3GPP.

### 3.3 3GPP uses staged specifications

ITU-R hands the frame to 3GPP. This section shows how 3GPP fills it in three stages and why the stages exist.

3GPP writes in three stages, and the stages are a discipline rather than a bureaucracy. Stage 1 records service requirements from the user's and operator's point of view. Stage 2 defines architecture and functional behaviour: which entities exist and what each does. Stage 3 defines protocols: messages, fields, timers, and the exact encoding on the wire. The point is traceability. Every field in a stage 3 message should trace back to a stage 2 procedure and a stage 1 need, so that when someone asks "why is this bit here", there is an answer.

### 3.4 Groups divide the system

Three stages describe when things are written; this section describes who writes them, and why one feature ends up spread across several groups.

The work is divided by system area into three technical domains. RAN covers radio access and RF: the working groups RAN1 through RAN4 own the physical layer, the radio protocols, the architecture and interfaces, and the RF and conformance requirements respectively. SA covers services and system architecture. CT covers core-network and terminal protocols. A feature almost always crosses these boundaries — a new radio capability needs a physical-layer definition, a protocol to configure it, and an architecture change to support it — which is why one feature lands in several specifications owned by several groups.

## 4. Mechanism and derivation

Section 3 gave the authorities, the stages and the groups. Section 4 follows one feature through them, from a question to a frozen document that keeps changing.

### 4.1 From study item to work item

A feature does not start as a specification. This section follows it from the first agreed question to the documents it finally touches.

A feature begins as a study item: an agreed question, explored through contributions, ending in a Technical Report that says what is feasible and which alternatives exist. A Technical Report is not official; it may recommend but cannot require. If the study succeeds, a work item follows, with a defined scope and target release. Contributions refine the text, and plenary decisions approve a baseline. The result is spread across several Technical Specifications rather than gathered into one feature manual, which is why finding a feature means knowing which specifications it touched.

### 4.2 Release freeze is not the last file

Section 4.1 ended with a work item entering a release. This section asks what "frozen" means, and why a frozen release is still not the last version you will read.

!important[A release passes through milestones: functional freeze, when no new features are accepted; ASN.1 freeze, when the message syntax stops changing; and protocol stability. After the freeze, corrections and clarifications continue for years. This is why "Rel-18" identifies a feature family, while "V18.9.0" identifies the exact document you read — and why two engineers quoting Rel-18 can be reading different text.]

### 4.3 Change requests preserve traceability

If the text keeps changing after the freeze, something has to keep track. This section explains change requests, the mechanism that makes every edit traceable.

Every edit to a frozen specification arrives as a change request: the affected specification, the clauses, the reason, and the proposed new text. Approved change requests enter the next version. Nothing changes silently, so the history of any clause can be reconstructed — which is what allows a course like this one to fix its citations to specific versions and know exactly what changed since.

### 4.4 Conformance is scoped evidence

A specification says what equipment must do; testing checks whether it does. This section separates the three kinds of testing and what each proves.

Testing happens at three boundaries and proves three different things. Conformance tests check that a product behaves as specified under controlled conditions. Interoperability tests check that products from different vendors work together. Field trials expose the effects of real deployment and real traffic. Passing one boundary does not prove the others; each is a distinct stage of evidence, and a product claim should say which stage it rests on.

### 4.5 A practical reading route

With the process understood, this section turns it into a reading route you can follow the first time you meet an unfamiliar feature.

!note[To read a feature you have never met: start with the stage 1 requirement, find the stage 2 architecture owner, follow the stage 3 procedure, locate the data structures and timers, and only then look at RF and conformance. Record the version of every document you open. Reading in this order avoids most dead ends, and recording versions prevents a tutorial or an outdated draft from silently becoming your evidence.]

## 5. Worked example

Section 4.5 gave a reading route with several required links. Section 5 makes the state of such a review countable with one small fraction.

### 5.1 Worked numerical example

The calculation below counts verified evidence links against required ones, the smallest way to say how far a review has come.

A feature review has five required evidence links. Four are verified and one conformance link is still missing. A simple coverage fraction makes the review state explicit.

**What we are working out.** Verified evidence-chain coverage for one feature review, dimensionless, measured at the document-audit.

$$
\begin{aligned}
C_{trace} &= \frac{N_{verified}}{N_{required}} \\ &= \frac{4}{5} \\ &= 0.80
\end{aligned}
$$

Where:

- $C_{trace}$ = 0.80, calculated (local audit); it belongs to the feature evidence chain.
- $N_{verified}$ = 4 links, measured (review checklist); it belongs to the document set.
- $N_{required}$ = 5 links, assumed (review contract); it belongs to the document set.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $C_{trace}$ | 0.80 | calculated | local audit | feature evidence chain |
| $N_{verified}$ | 4 links | measured | review checklist | document set |
| $N_{required}$ | 5 links | assumed | review contract | document set |

The ratio is dimensionless because both counts use the same unit. It is a completeness indicator. The feature cannot be called fully traced until the missing conformance link is recorded.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. The 3GPP protocol: which document, and what it says

The example counted documents; this section explains how to find them. Four naming conventions turn thousands of files into something you can navigate in seconds.

The process produces thousands of files, and four conventions let you find the right one in seconds. A document number tells you its series: 21 is process, 22 requirements, 23 architecture, 24 the non-access stratum, 36 LTE, 38 NR; within the 38 series, the 2xx documents are the physical layer and the 3xx the protocols. A version string decodes as release, technical revision, editorial revision, so V18.9.0 is the ninth technical revision of the Release 18 text. The archive name on the 3GPP server encodes the same thing in base 36: 38211-i90.zip is TS 38.211 V18.9.0. And behind every difference between two revisions there is a change request that names the clause and the reason.

![[99 Attachments/5G/Protocol Figures/STAR-02-5G-Standardization-Protocol.png|How 3GPP document numbers, version strings and releases are read]]

*Protocol figure: How 3GPP document numbers, version strings and releases are read.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| Release description | [TR 21.918 V18.0.0, clauses 4–7](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | What Release 18 contains, feature by feature; the index to everything else. |
| Service requirements | [TS 22.261 V18.19.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip) | Stage 1: the requirements, as the official wording. |
| 5GS architecture | [TS 23.501 V18.12.0, clauses 4–5](https://www.3gpp.org/ftp/Specs/archive/23_series/23.501/23501-ic0.zip) | Stage 2: the architecture the protocols implement. |
| NR overview | [TS 38.300 V18.10.0, clauses 4–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | Stage 2 for the radio side; the entry point into the 38 series. |

!note[**When you build or run a demo.** Open-source stacks implement a subset of one edition of the recipe. srsRAN and OpenAirInterface both state which release their features follow, usually Release 15 with selected Release 16 items; a log line or a version banner tells you. A packet capture decodes RRC messages only against the ASN.1 of the right version of TS 38.331, so a Wireshark profile must match the stack. When a demo fails, open the clause at the version your stack claims. A Release 18 clause may describe a field your Release 15 software has never heard of. The archive-name convention is what lets you fetch that exact version.]

Release 15 delivered the first 5G baseline; Release 16 completed a broad second phase; Release 18 is branded 5G-Advanced. The branding does not change the stages or the groups; what changes is the size of the feature inventory and the number of accumulated corrections. Exact versions, official URLs, and SHA-256 hashes for every document cited in this course are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 7. ShareTechnote engineering intuition

The official server gives you the files; the practitioner's pages give you the story of how the releases arrived. This section says how to use the two together.

ShareTechnote's [5G topic index](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html) and its [5G agreements page](https://www.sharetechnote.com/html/5G/5G_Agreements.html) tell the story of the releases as a practitioner experienced it: which meeting agreed what, and when the features arrived in real equipment. Read them for the timeline and the feel of the process, then use the 3GPP server itself for anything you intend to cite. A useful habit from the start: whenever you save a specification, keep the archive name, because it is the only thing that pins the version.

## 8. Course alignment

With the process and the sources in hand, this section places the chapter in the course.

No Saar unit directly teaches standards governance. Use this note as a method layer for every unit: locate the requirement, architecture, protocol, and conformance owners before accepting a claim. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “3GPP is a regulator”

!warning[3GPP develops specifications. National and international regulatory bodies govern spectrum use. The fix is to ask who can compel the behaviour and who can only describe it.]

### 9.2 “One TS contains one feature”

!warning[A feature usually crosses requirement, architecture, protocol, RF, and testing documents. The fix is to look for the feature across the specification set rather than in one document.]

### 9.3 “Release 18 has one date and version”

!warning[A release has milestones; each specification has its own corrective version. The fix is to quote the exact version string.]

### 9.4 “A TR is automatically official”

!warning[A TR often records study material. Official behavior belongs in the applicable TS unless explicitly incorporated. The fix is to check the document class before treating a sentence as binding.]

### 9.5 “Conformance proves field performance”

!warning[Conformance proves a scoped test condition. Deployment and application performance require additional evidence. The fix is to name the test case and its conditions before generalising the result.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 2, pp. 7–26, 2021, DOI [chapter 2](https://doi.org/10.1016/B978-0-12-822320-8.00002-7).
2. textbook Chapter 2 PDF.
4. 3GPP, *TR 21.918 V18.0.0, clauses 4–7*, [Release description](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
5. 3GPP, *TS 22.261 V18.19.0, clauses 4–6*, [Service requirements](https://www.3gpp.org/ftp/Specs/archive/22_series/22.261/22261-ij0.zip).
6. 3GPP, *TS 23.501 V18.12.0, clauses 4–5*, [5GS architecture](https://www.3gpp.org/ftp/Specs/archive/23_series/23.501/23501-ic0.zip).
7. 3GPP, *TS 38.300 V18.10.0, clauses 4–6*, [NR overview](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
8. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
9. ShareTechnote, [5G topic index](https://www.sharetechnote.com/html/5G/Handbook_5G_Index.html), accessed 2026-08-03.
10. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| 5G | Fifth Generation | Section 1; fixed specification set in Section 6 |
| ITU | International Telecommunication Union | Section 1; fixed specification set in Section 6 |
| ITU-R | ITU Radiocommunication Sector | Section 1; fixed specification set in Section 6 |
| IMT | International Mobile Telecommunications | Section 1; fixed specification set in Section 6 |
| IMT-2020 | International Mobile Telecommunications 2020 | Section 1; fixed specification set in Section 6 |
| 3GPP | Third Generation Partnership Project | Section 1; fixed specification set in Section 6 |
| TS | Technical Specification | Section 1; fixed specification set in Section 6 |
| TR | Technical Report | Section 1; fixed specification set in Section 6 |
| RAN | Radio Access Network | Section 1; fixed specification set in Section 6 |
| SA | Service and System Aspects | Section 1; fixed specification set in Section 6 |
| CT | Core Network and Terminals | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $C_{trace}$ | Verified trace coverage | dimensionless |
| $N_{verified}$ | Verified evidence links | count |
| $N_{required}$ | Required evidence links | count |

The symbols mean what they mean in this note; another note may use the same letter for something else.
