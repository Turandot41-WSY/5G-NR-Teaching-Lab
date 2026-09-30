---
type: course_index
course: Saar University 5G
language: en
release_baseline: 18
---

# Saarland University 5G NR Teaching Knowledge Base

**Author:** Shiyi Wang. E-mail: shiyi.wang@it-u.at
			
> [!important] Dedication
> This note is a gift to Prof. Dr.-Ing. Thorsten Herfet and the 5G teaching team at Saarland University, with gratitude for the encouragement and teaching materials from which these notes grew. Having struggled along that route myself, I wanted to make it easier for those who come after me. 
>
>  I enjoyed our conversations very much, and his encouragement strengthened my resolve to pursue a PhD in Europe. I had hoped to take up the offers from Saarland University and CISPA. Political circumstances prevented me from obtaining a German research visa, and after six months of waiting I had to write to both professors to withdraw. During that wait, I asked Thorsten whether I could begin contributing to teaching. He shared the Jupyter notebooks used in Saarland's 5G course. Reading them gave me a way to contribute while my own plans were uncertain.
>
> During my master's research, learning 5G had often been painful. I read the textbook and ShareTechnote, struggling to connect abstract mechanisms and difficult equations to signals I could observe or systems I could build. Even after I thought I understood a topic, implementing it from the 3GPP specifications could take me a whole day to understand one or two pages. The details of a single mechanism were often spread across several documents, each sending me elsewhere before I could work out what to do.
>
> Saarland's use of Jupyter to bring code into the course suggested a way to help students through those difficulties. Over the past year, I have worked on these notes to address two gaps I knew from experience: the gap between an introductory understanding of 5G and the knowledge needed for research, and the gap between understanding the system as a whole and implementing its mechanisms. I wanted students to be able to follow an idea into the relevant specification, turn its parameters and equations into code, and see the result. 
>
> Thorsten continued to offer advice after I could no longer take up the position. I give these notes to him and the Saarland 5G teaching team in thanks for that kindness, and in the hope that they will help students find their footing in a subject I once found so difficult to learn.

This knowledge base follows Dahlman, Parkvall, and Sköld’s *5G NR: The Next Generation Wireless Access Technology*, 2nd ed. Normative behaviour is frozen to specific 3GPP Release 18 versions.

The notes are organised into three layers that connect textbook knowledge, 3GPP specifications and engineering practice. A view of the whole 5G system runs through them: each topic is placed in context so you can see what you are studying, where it operates and how it relates to other functions. The textbook notes build that understanding, the protocol notes help you locate the relevant rules, and nine engineering studies show how those ideas and rules become MATLAB code and observable results.
	
## Three levels of notes

| Layer | Notes | What the notes explain | When to use them |
| --- | --- | --- | --- |
| Textbook knowledge in the 5G system | Star-01 to Star-27 | Follows the textbook chapter by chapter, adding system maps that locate each mechanism and explain its role. Diagrams and explanations are supplemented by ShareTechnote and other teaching materials. | Learn a topic while keeping its place in the wider system in view. |
| Reading the 3GPP specifications | Star-28 to Star-37 | Explains ten core Release 18 specifications: what each covers, which clauses define a mechanism, and how related requirements are distributed across documents. | Find the specification and clause needed to generate a signal, configure a procedure or check an implementation. |
| Integrated engineering studies | Uni-01 to Uni-09 | Develops nine representative engineering tasks, from cell search to access and multiuser operation. Each connects the required textbook knowledge to specific 3GPP clauses, MATLAB implementation and results. System diagrams and protocol excerpts accompany plots of signals, intermediate processing and performance. | Follow an engineering task through its inputs, processing stages and outputs; use the code and figures to understand how it works and where it can fail. |

> [!note] It is easy to get lost in 5G: you can understand a page of equations and still struggle to picture what your phone and the base station are doing. The Star notes give you three things to hold on to as you read:

1. **What this is, and why it exists.** We start with the problem that needs solving. A concept picture and familiar analogies help you get a feel for the idea before working through the maths, so the mechanism has a reason to exist in your mind.
2. **Where you are in 5G.** The same system panorama follows you through the notes, with the relevant functions marked “you are here”. You can zoom out whenever the details get confusing, see which part belongs to the phone or the network, and then use the topic map to follow how those parts work together.
3. **The textbook road, then the 3GPP protocol.** We follow the book's explanation and draw out things you cannot see, such as signals taking their places on a resource grid. Alongside that picture, you will find the 3GPP clauses, equations and parameters that define the mechanism, giving you somewhere specific to turn when you want to build it yourself.

The Uni notes take that last step with you in MATLAB. You can follow a signal through the code, compare what comes out with the figures, and try changing a parameter to see why reception improves or breaks down.

## How to use the site

- **Search.** The box at the top of the chapter list searches every page.
- **Abbreviation lookup.** The small box in the right margin (or the key `a`) explains any abbreviation from the database as you type, without leaving the page.
- **Section list.** The right margin always shows the sections of the page you are reading; click one to jump.
- **Parallel reading.** Press `Split` in the top bar (or the key `s`) to open a second note beside the one you are reading: choose it from the list in the black bar, or hold Alt (Option) and click any chapter. Both windows keep their own section list and share the one abbreviation lookup. `Swap` exchanges the two windows; the edge between them can be dragged.
- **Figures.** Click any figure to see it at full size; click again to close.
- **Reading tools.** `Night` switches to a dark page, `A−` and `A+` change the text size, `Normal` cycles the reading width, and the chapter list can be dragged wider or narrower by its edge. `?` lists every keyboard shortcut.
## Colour tells you the source

Every coloured title bar, section chip and label on the site names where the knowledge comes from, so you always know whether you are reading the book, the standard, an engineering commentary, or the author's own summary.

| Colour | Source | Where you see it |
| --- | --- | --- |
| Sage green | Textbook: Dahlman, Parkvall and Sköld | Book expansion callouts; the textbook stage of a Uni note |
| Dell red | 3GPP protocol: frozen Release 18 clauses | 3GPP reality checks; the protocol stage of a Uni note; the chapter code in the banner |
| Sky blue | ShareTechnote engineering view | ShareTechnote callouts and section headings |
| Peach | Supplement: course slides, handouts and other materials | Supplement sections and course alignment |
| Steel blue | MATLAB experiment | MATLAB callouts; the experiment stage of a Uni note |
| Lime | Measured result from a saved run | Verified result callouts; the results stage of a Uni note |
| Salmon | Failure case | Failure callouts in the Uni notes |
| Periwinkle | The author's own summary and analysis | Analysis asides; the reproduction and reference stage of a Uni note |
| Olive | Section purpose | The first paragraph of every numbered section |
| Sticker yellow | Reading notes and highlights | Reading order callouts and highlighted text |

## Book Chapters

| Star | Chapter | Status | Course alignment |
| --- | --- | --- | --- |
| 01 | [[Star-01-What-Is-5G|What Is 5G?]] | Complete | no direct current course unit |
| 02 | [[Star-02-5G-Standardization|5G Standardization]] | Complete | no direct current course unit |
| 03 | [[Star-03-Spectrum-for-5G|Spectrum for 5G]] | Complete | U01–U02 |
| 04 | [[Star-04-LTE-An-Overview|LTE: An Overview]] | Complete | U03–U05, U09–U10 |
| 05 | [[Star-05-NR-Overview|NR Overview]] | Complete | U03–U05 |
| 06 | [[Star-06-Radio-Interface-Architecture|Radio-Interface Architecture]] | Complete | no direct current course unit |
| 07 | [[Star-07-Overall-Transmission-Structure|Overall Transmission Structure]] | Complete | U03–U05 |
| 08 | [[Star-08-Channel-Sounding|Channel Sounding]] | Complete | U06–U08 |
| 09 | [[Star-09-Transport-Channel-Processing|Transport-Channel Processing]] | Complete | U03–U05, U11–U14 |
| 10 | [[Star-10-Physical-Layer-Control-Signaling|Physical-Layer Control Signaling]] | Complete | U11–U14 |
| 11 | [[Star-11-Multi-Antenna-Transmission|Star 11 — Multi-Antenna Transmission]] | Complete | U06–U08 |
| 12 | [[Star-12-Beam-Management|Star 12 — Beam Management]] | Complete | U06–U08 |
| 13 | [[Star-13-Retransmission-Protocols|Star 13 — Retransmission Protocols]] | Complete | U11–U14 |
| 14 | [[Star-14-Scheduling|Star 14 — Scheduling]] | Complete | U03–U05 |
| 15 | [[Star-15-Uplink-Power-and-Timing-Control|Star 15 — Uplink Power and Timing Control]] | Complete | U03–U05 |
| 16 | [[Star-16-Cell-Search-and-System-Information|Star 16 — Cell Search and System Information]] | Complete | U09–U10 |
| 17 | [[Star-17-Random-Access|Random Access]] | Complete | U09–U10 |
| 18 | [[Star-18-LTE-NR-Interworking-and-Coexistence|Star 18 — LTE–NR Interworking and Coexistence]] | Complete | U03–U05 |
| 19 | [[Star-19-NR-in-Unlicensed-Spectrum|Star 19 — NR in Unlicensed Spectrum]] | Complete | U03–U05 |
| 20 | [[Star-20-Industrial-IoT-and-URLLC-Enhancements|Industrial IoT and URLLC Enhancements]] | Complete | no direct current course unit |
| 21 | [[Star-21-Interference-Handling-in-TDD-Networks|Interference Handling in TDD Networks]] | Complete | U03–U05 |
| 22 | [[Star-22-Integrated-Access-Backhaul|Integrated Access Backhaul]] | Complete | no direct current course unit |
| 23 | [[Star-23-Sidelink-Communication|Sidelink Communication]] | Complete | no direct current course unit |
| 24 | [[Star-24-Positioning|Positioning]] | Complete | no direct current course unit |
| 25 | [[Star-25-RF-Characteristics|RF Characteristics]] | Complete | U01–U02 |
| 26 | [[Star-26-RF-Technologies-at-mm-Wave-Frequencies|RF Technologies at mm-Wave Frequencies]] | Complete | U01–U02 |
| 27 | [[Star-27-5G-Further-Evolution|5G Further Evolution]] | Complete | no direct current course unit |

## Core 3GPP Specifications

| Star | Specification | Scope | Status |
| --- | --- | --- | --- |
| 28 | [[Star-28-TS-38.300-NR-and-NG-RAN-Overall-Description|TS 38.300 NR and NG-RAN Overall Description]] | NR and NG-RAN Overall Description | Complete |
| 29 | [[Star-29-TS-38.211-Physical-Channels-and-Modulation|TS 38.211 Physical Channels and Modulation]] | Physical Channels and Modulation | Complete |
| 30 | [[Star-30-TS-38.212-Multiplexing-and-Channel-Coding|TS 38.212 Multiplexing and Channel Coding]] | Multiplexing and Channel Coding | Complete |
| 31 | [[Star-31-TS-38.213-Physical-Layer-Procedures-for-Control|TS 38.213 Physical-Layer Procedures for Control]] | Physical-Layer Procedures for Control | Complete |
| 32 | [[Star-32-TS-38.214-Physical-Layer-Procedures-for-Data|Star 32 — TS 38.214 — Physical Layer Procedures for Data]] | Star 32 — TS 38.214 — Physical Layer Procedures for Data | Complete |
| 33 | [[Star-33-TS-38.321-Medium-Access-Control|Star 33 — TS 38.321 — Medium Access Control]] | Star 33 — TS 38.321 — Medium Access Control | Complete |
| 34 | [[Star-34-TS-38.322-Radio-Link-Control|Star 34 — TS 38.322 — Radio Link Control]] | Star 34 — TS 38.322 — Radio Link Control | Complete |
| 35 | [[Star-35-TS-38.323-Packet-Data-Convergence-Protocol|TS 38.323 Packet Data Convergence Protocol]] | Packet Data Convergence Protocol | Complete |
| 36 | [[Star-36-TS-38.331-Radio-Resource-Control|TS 38.331 Radio Resource Control]] | Radio Resource Control | Complete |
| 37 | [[Star-37-TS-38.401-NG-RAN-Architecture-Description|TS 38.401 NG-RAN Architecture Description]] | NG-RAN Architecture Description | Complete |

## Engineering Situations

| Uni | Situation                                                                                                                               | Star chapters combined | Measured evidence                                                |
| --- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- | ---------------------------------------------------------------- |
| 01  | [[Uni-01-Cell-Search-Synchronization-and-MIB-Recovery\|Cell search, synchronization and MIB recovery]]                                  | 07, 09, 16, 29, 30     | 320 synchronization trials over eight SNR points                 |
| 02  | [[Uni-02-Reference-Signals-Channel-Estimation-and-Equalization\|Reference signals, channel estimation and equalization]]                | 07, 08, 09, 25, 29, 32 | 1,260 receiver trials and a coded transport check                |
| 03  | [[Uni-03-MIB-CORESET0-PDCCH-and-SIB1-Recovery\|MIB, CORESET0, PDCCH and SIB1 recovery]]                                                 | 10, 16, 29, 30, 31, 36 | 120 conditional trials, five negative cases, a real 50-byte SIB1 |
| 04  | [[Uni-04-PRACH-Timing-Advance-and-Uplink-Alignment\|PRACH detection, timing advance and uplink alignment]]                              | 15, 17, 29, 31, 33     | 3,200 PRACH trials, 100 paired uplink tests, 25 delay points     |
| 05  | [[Uni-05-Transport-Blocks-LDPC-and-HARQ\|Transport blocks, LDPC coding and HARQ]]                                                       | 09, 13, 30, 32         | 1,260 transport trials and 5,040 decoder attempts                |
| 06  | [[Uni-06-PUSCH-Power-Control-and-Coverage\|PUSCH power control and coverage]]                                                           | 15, 25, 29, 31, 32     | 768 PUSCH trials over eight path losses                          |
| 07  | [[Uni-07-CSI-Feedback-and-Adaptive-MIMO\|CSI feedback and adaptive MIMO]]                                                               | 08, 11, 12, 29, 32     | 720 CSI-RS and PDSCH trials in five feedback modes               |
| 08  | [[Uni-08-Complete-Radio-Access-and-First-Bidirectional-Transfer\|Radio access, RRC establishment and the first bidirectional transfer]] | 16, 17, 33, 36         | Six shared-channel stages, seven state cases, 120 DL/UL pairs    |
| 09  | [[Uni-09-Connected-Multiuser-TDD-Cell\|A connected multiuser TDD cell]]                                                                 | 14, 13, 21, 33, 34     | 36 simulator runs, 144 user records                              |
