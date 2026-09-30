---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 3
title: Spectrum for 5G
language: en
course_units:
- U01
- U02
release_baseline: 18
---

# STAR-03 — Spectrum for 5G

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Choosing a frequency is choosing how big your waves are. At 700 MHz a radio wave is about 43 centimetres long — the size of a large cushion. At 3.5 GHz it is under 9 centimetres, the width of a hand. At 28 GHz it is one centimetre, a fingernail. That single number explains most of what this chapter is about, because a wave interacts with the world according to its size. Long waves roll around buildings, bend over hills, and pass through walls with modest loss; they reach for tens of kilometres. Short waves are stopped by a window pane, a leaf, or the hand holding the phone — but they can carry far more information, and the antennas that steer them fit on a chip.

![[99 Attachments/5G/Concept Figures/STAR-03-Spectrum-for-5G-Concept.png|Three 5G frequencies shown as wavelengths drawn to scale]]

*Concept figure: Three 5G frequencies shown as wavelengths drawn to scale.*

So every spectrum decision is a trade between reach and capacity, and 5G is the first generation to make that trade across the whole range at once — from below 1 GHz, where LTE and 2G still live, up to millimetre wave, where nothing mobile had ever operated. Two frequency ranges, FR1 below 7.125 GHz and FR2 above 24 GHz, carry the same radio with different settings.

There is a third party in the picture who is not an engineer. Waves do not stop at borders and do not know who paid for them, so someone has to decide who may transmit where, at what power, and for how long. That someone is a regulator, and the decision comes before any engineering. A band that 3GPP has standardised grants nobody the right to use it; a licence that a regulator has issued defines no radio. This chapter is where law and physics meet, and the rest of the course is built on the result.

**The question this chapter answers.** How do regulation, carrier frequency, bandwidth, duplex arrangement, and propagation combine into a defensible 5G spectrum choice?

!important[**The short answer.** Spectrum choice is layered. ITU-R and national administrations define legal availability; 3GPP defines operating bands and RF requirements; frequency and bandwidth shape propagation, antenna, and capacity conditions; and paired or unpaired allocations support different duplex arrangements. No one band is intrinsically "the 5G band".]

Names you will meet in this note: Fifth Generation (5G), International Telecommunication Union Radiocommunication Sector (ITU-R), International Mobile Telecommunications (IMT), New Radio (NR), User Equipment (UE), Base Station (BS), Frequency Range 1 (FR1), Frequency Range 2 (FR2), Frequency Division Duplex (FDD), Time Division Duplex (TDD), Supplementary Downlink (SDL), Supplementary Uplink (SUL).

This note follows Dahlman, Parkvall, and Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 3, pp. 27–37, DOI [chapter 3](https://doi.org/10.1016/B978-0-12-822320-8.00003-9), and the textbook Chapter 3 PDF. The book describes the spectrum landscape of Releases 15 and 16; Section 6 attaches current band and bandwidth facts to fixed Release 18 documents.

## 2. Where you are in 5G

Section 1 turned frequency into wavelength and wavelength into what a wave can and cannot do. The map below shows where spectrum sits: at the very start of every chain, before a single symbol is transmitted.

![[99 Attachments/5G/Locator Maps/STAR-03-Where-You-Are-in-5G.png|Where Star 03 sits in the whole 5G system]]

*Locator: Where Star 3 sits in the whole 5G system.*

This chapter lights the first box of the physical foundations — spectrum and RF — and the standards strip above, because spectrum is where law enters the system. It comes before numerology and the grid (Star 07), because the grid is built inside a carrier and the carrier is placed inside a band. Stars 25 and 26 return to the same box to cover the RF requirements and millimetre-wave hardware in detail.

The Knowledge Structure Map draws the two frequency ranges on a logarithmic axis, so that FR2 appears as the sliver it really is against FR1's decades, with the channel bandwidths and subcarrier spacings each range supports. The mechanism diagram follows a frequency from allocation, through assignment and operating band, to a configured carrier, marking where law ends and engineering begins.

![[99 Attachments/5G/Knowledge Maps/STAR-03-Spectrum-for-5G-Knowledge Structure Map.png]]

*Knowledge map: The NR frequency ranges and what changes across them.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-03-Spectrum-to-Radio-Design-Chain.png|Star 03 mechanism and handoff diagram]]

*Mechanism: From spectrum allocation to a configured NR carrier.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.104 V18.14.0, clause 5, PDF page 36](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.104 V18.14.0, clause 5, PDF page 36, [official 3GPP archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip), accessed 2026-08-04.*

External source: [Operating-frequency overview](https://www.sharetechnote.com/html/5G/5G_FR_Bandwidth.html). The reproduced image is omitted from this distribution.

*Source excerpt: Operating-frequency overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/5G/5G_FR_Bandwidth.html), accessed 2026-09-06.*

> [!note] Searchable structure
> Allocation and licence → FR1/FR2 band → FDD/TDD arrangement → bandwidth and propagation → deployment choice.

Read the map along its arrows: each region is a different kind of thing, and an arrow only says that one depends on the other.

## 3. Foundations and prerequisites

Section 2 placed spectrum at the root of the map. Four foundations follow: the legal states a frequency passes through, what an operating band fixes, how frequency changes the link budget, and how spectrum decides the duplex mode.

### 3.1 Allocation is not assignment

Before any engineering, a frequency must be allowed. This section separates the three legal states that the one word "allocated" usually hides.

!important[Three legal states are often collapsed into one word. An allocation reserves a frequency range for one or more radio services under stated conditions; it is international and general. An IMT identification signals that a range may be used by mobile systems; it is a recommendation. A national assignment or licence authorises a specific operator in a specific geography, usually after an auction, and it is the only one of the three that lets a base station be switched on. Treating these as one technical parameter is the most common category error in spectrum discussions.]

### 3.2 Operating bands are standardized configurations

Once a range is licensed, the equipment must agree on it. This section explains what an NR operating band is: a row in a table, and nothing more.

An NR operating band — n78, say — is a row in a 3GPP table. It fixes the uplink and downlink frequency ranges, the duplex mode, the channel bandwidths allowed, and the RF requirements equipment must meet there. Its purpose is compatibility: a phone that supports n78 will work with any base station that supports n78. It does not say that n78 is licensed in your country, nor that every phone implements it. A band number is a configuration agreement.

### 3.3 Frequency changes the link budget

A band is a legal and engineering agreement; physics does not read it. This section asks what happens to the link when the frequency rises with everything else held fixed.

!note[Hold everything else fixed — distance, transmit power, antenna gains — and raise the frequency. Free-space path loss grows with the square of frequency, so doubling it costs six decibels before a single wall is in the way. Real coverage then adds clutter, penetration, diffraction, and above about 10 GHz atmospheric absorption. Higher frequency does buy two things: wider contiguous bandwidth, because there is simply more of it up there, and compact antenna arrays, because the elements shrink with the wavelength. Neither erases the propagation loss; the array partly compensates for it, and that compensation is the subject of Stars 11, 12, and 26.]

### 3.4 Duplex follows spectrum and traffic

Section 3.3 was about reach. The last foundation is direction: whether uplink and downlink share time or frequency, and why the spectrum grant decides that first.

Whether uplink and downlink are separated in frequency or in time is decided first by the spectrum grant. Paired spectrum — two ranges, one for each direction — supports frequency division duplex, where both directions run at once. Unpaired spectrum supports time division duplex, where one carrier alternates direction. Supplementary downlink and supplementary uplink add one direction to an anchor carrier elsewhere. Within what the grant allows, the engineering choice weighs traffic asymmetry, guard resources, synchronisation between cells, interference, and device complexity — and TDD in particular turns a local choice into a neighbourhood problem, which Star 21 takes up.

## 4. Mechanism and derivation

Section 3 gave the legal states, the band tables, the physics and the duplex modes. Section 4 connects them into the chain an operator actually walks, and the trade-offs waiting along it.

### 4.1 Policy-to-carrier chain

This section walks the chain from a national frequency table to a live carrier, in the only order that works.

The chain runs in one direction. Begin with the national frequency table and the operator's licence. Match an NR band to the licensed range. Check that the base station and the devices support that band. Choose a channel bandwidth the band allows. Meet the emission mask and any coexistence obligation to neighbours. Only then does a carrier exist. Skip the legal step and the deployment is impossible; skip the RF step and it is nominally legal but nonconforming, and it will fail certification.

### 4.2 Coverage and capacity separate

The chain ends with a carrier in one band. This section asks what that band buys, coverage or capacity, and why the two are different questions.

Coverage and capacity are different questions with different answers. Low bands usually give the best wide-area and indoor coverage, and little bandwidth. Mid bands balance the two, which is why 3.5 GHz carries most 5G traffic today. High bands offer very large bandwidth and need dense sites and directional antennas to close the link at all. These are tendencies under typical deployment assumptions, and an operator's network is usually a layer of each.

### 4.3 Bandwidth is useful only when link closure survives

Section 4.2 said that mid bands balance coverage and capacity. This section looks closer at the capacity side and shows where extra bandwidth stops helping.

!important[More bandwidth means more time–frequency resources, but a receiver that opens a wider bandwidth also collects more thermal noise, so the signal-to-noise ratio per resource falls. Past the point where the link no longer closes, extra bandwidth adds noise rather than rate. The scheduler's job is to trade bandwidth, modulation, code rate, layers, and time against each other; a capacity claim therefore needs evidence of both resource availability and received quality.]

### 4.4 TDD adds a network coordination problem

Section 3.4 introduced TDD as a duplex choice for one cell. This section shows why, once neighbours exist, the choice becomes a coordination problem.

A flexible uplink/downlink pattern can follow one cell's traffic. But a neighbouring cell transmitting downlink while this one receives uplink creates cross-link interference that FDD never sees, and a guard period is needed at every switch to cover propagation delay. The pattern is therefore a system coordination choice — often agreed between operators or imposed by the regulator — rather than a setting one cell picks alone.

### 4.5 Spectrum aggregation is not one wide carrier

Operators rarely hold one clean block. This section explains why several blocks combined are not the same as one wide carrier.

An operator with 20 MHz here and 40 MHz there does not have 60 MHz of spectrum in the sense that matters. Carrier aggregation combines component carriers that may sit in different bands with different propagation and different power limits; dual connectivity may even split traffic across two base stations. Each component keeps its own frequency, bandwidth, power, and coverage, and a report that quotes only the summed bandwidth has thrown away the information that determines what the sum can do.

## 5. Worked example

Section 3.3 claimed that raising the frequency costs decibels before a wall is in the way. Section 5 computes exactly how many between two common 5G bands.

### 5.1 Worked numerical example

The calculation compares free-space loss at 700 MHz and 3.5 GHz with distance and antenna gains held constant.

Compare free-space frequency-dependent loss at 700 MHz and 3.5 GHz while holding distance and antenna gains constant.

**What we are working out.** Additional free-space path loss at 3.5 GHz relative to 0.7 GHz, in decibels, measured at the same distance and antenna-gain.

$$
\begin{aligned}
\Delta L_f &= 20\log_{10}\!\left(\frac{f_{high}}{f_{low}}\right) \\ &= 20\log_{10}\!\left(\frac{3.5\ \mathrm{GHz}}{0.7\ \mathrm{GHz}}\right) \\ &= 13.98\ \mathrm{dB}
\end{aligned}
$$

Where:

- $\Delta L_f$ = 13.98 dB, calculated (free-space ratio); it belongs to the equal-distance isotropic path.
- $f_{high}$ = 3.5 GHz, assumed (illustrative mid-band carrier); it belongs to the transmit frequency.
- $f_{low}$ = 0.7 GHz, assumed (illustrative low-band carrier); it belongs to the transmit frequency.

**The numbers at a glance**

| Symbol | Value and unit | How we got it | Source | Where it applies |
|---|---|---|---|---|
| $\Delta L_f$ | 13.98 dB | calculated | free-space ratio | equal-distance isotropic path |
| $f_{high}$ | 3.5 GHz | assumed | illustrative mid-band carrier | transmit frequency |
| $f_{low}$ | 0.7 GHz | assumed | illustrative low-band carrier | transmit frequency |

The frequency ratio is dimensionless, so GHz cancels. The coefficient 20 follows because received power in free space scales with the inverse square of frequency for fixed antenna gains: ten times the logarithm of a squared amplitude factor becomes twenty times the logarithm. The result excludes antenna-aperture gain, clutter, penetration, and power differences.

This is a small illustration and nothing more; a claim about a real network needs a real measurement made under stated conditions.

## 6. The 3GPP protocol: which document, and what it says

The example used physics; deployment uses tables. This section names the document where the legal grant becomes three integers in a configuration file.

Spectrum arrives as a legal grant and leaves as three integers in a configuration file, and TS 38.104 is where the translation is written. Clause 5.2 lists the operating bands. Clause 5.3 gives, for each channel bandwidth and subcarrier spacing, the number of resource blocks a carrier holds — a table that cannot be computed, only looked up. Clause 5.4.2 defines the ARFCN, the single integer by which every frequency in NR is named, and the formula that converts it back. The figure lays these out, works the formula once for band n78, and shows the configuration lines they become.

![[99 Attachments/5G/Protocol Figures/STAR-03-Spectrum-for-5G-Protocol.png|The spectrum clauses, the ARFCN formula, and the three numbers a gNB configuration needs]]

*Protocol figure: The spectrum clauses, the ARFCN formula, and the three numbers a gNB configuration needs.*

| Topic | Where the rule is written | Why it is used |
|---|---|---|
| BS operating bands | [TS 38.104 V18.14.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) | Band table, channel bandwidths, resource-block counts, and the ARFCN definition. |
| UE FR1 requirements | [TS 38.101-1 V18.14.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip) | What a device must support in FR1, band by band. |
| UE FR2 requirements | [TS 38.101-2 V18.13.0, clauses 5–6](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) | The same for FR2, where requirements are radiated rather than conducted. |
| NR spectrum context | [TS 38.300 V18.10.0, clause 5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip) | FR1 and FR2 as the radio overview sees them. |

!note[**When you build or run a demo.** A gNB configuration needs a band, a downlink ARFCN, and a channel bandwidth, and every one of them is checked against TS 38.104. The band must be in Table 5.2-1 and must match the duplex mode your hardware supports. The ARFCN converts to a frequency through the clause 5.4.2 formula — for the 3 to 24 GHz range, 3000 MHz plus 15 kHz for every step above 600 000, so 632 628 is 3489.42 MHz — and that frequency must lie inside the band. The bandwidth must be one the band allows, and Table 5.3.2-1 then gives the resource-block count the whole grid is built from: 273 blocks for 100 MHz at 30 kHz. The synchronisation block has its own coarser raster in clause 5.4.3, and if its ARFCN is not on a raster point no phone will ever find the cell. Most first-demo failures are one of these four numbers being outside its table.]

The textbook centres the Release 15 and 16 spectrum landscape. Release 18 keeps the FR1 and FR2 concept and expands the band, bandwidth, and capability tables; FR2 in particular must be read from the exact UE and base-station parts, because informal labels such as "millimetre wave" do not substitute for the official ranges. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

### 6.1 Supplement: large-scale fading

The specification's tables assume you know how the signal fades on the way. The handout's three propagation models, drawn on one axis, supply that background.

Spectrum choice is a propagation choice. The handout's three models are drawn on one log-distance axis so the exponent is visible as a slope.

![[99 Attachments/5G/Supplement Figures/STAR-03-Saar-Large-Scale-Fading.png|Large-scale fading: mechanisms, the log-distance path-loss plot and the three formulas]]

*Supplement figure: Large-scale fading: three propagation mechanisms, a log-distance path-loss plot with exponents 2, 3.5 and 4 and a shadowing band, and the three formulas.*
*Figure 6.1 — Free space, two-ray and log-distance with shadowing, with the exponent by environment and the fade-margin rule.*

| Model | Formula | Slope | Use |
|---|---|---|---|
| Free space | PL = (4πd/λ)² | 20 dB per decade | Line of sight, first estimate |
| Two-ray, far field | Pr ∝ (ht·hr)²/d⁴ | 40 dB per decade | Flat ground, no λ dependence |
| Log-distance | PL(d0) + 10·n·log10(d/d0) + Xσ | 10·n dB per decade | Any environment once n and σ are known |

- σ of 5–12 dB is why coverage is quoted as a probability; 90 % edge reliability at σ = 8 dB costs roughly 10 dB of margin.
- The f² in free-space loss is the arithmetic behind the coverage-layer versus capacity-layer split of Section 3: 900 MHz to 3.5 GHz is about 12 dB before any wall.

Source: Supplementary material, *Large-scale fading models* (handout); 3GPP TR 38.901 for the standardised channel models.

## 7. ShareTechnote engineering intuition

The band tables are easier to scan on the engineering pages than in the specification itself. This section says which pages to use and what to check against the clause afterwards.

ShareTechnote's [operating frequency page](https://www.sharetechnote.com/html/5G/5G_FR_Bandwidth.html) reproduces the band tables in a form that is easier to scan than the specification, and its [UE millimetre-wave page](https://www.sharetechnote.com/html/5G/5G_UE_mmWave.html) explains why the millimetre-wave requirements are written differently. Both are reading aids: use them to find the right row quickly, then confirm the numbers in TS 38.104 at the version you are building against, because band tables are among the most frequently corrected clauses in the whole series.

## 8. Course alignment

With the physics, the tables and the pages in place, this section positions the chapter in the course.

This is a primary foundation for U01–U02. Use the calculation to connect RF scale with band choice, then carry the legal/standardized/licensed distinction into later RF and deployment work. The course alignment page shows how every note maps onto the Saar course units.

It helps to have met complex baseband signals, probability, decibels and the idea of a packet before you start. Section 3 gives you the definitions, Section 4 the chain of cause and effect, Section 5 a small calculation you can redo by hand, and Section 6 the place in the standard where the rule is written. When you are done, try the common confusions at the end against a real configuration or a trace.

## 9. Common confusions

The five sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

### 9.1 “FR2 means every millimeter-wave frequency”

!warning[FR2 is a official 3GPP range. The broad scientific term millimeter wave has a different boundary. The fix is to quote the defined frequency range rather than the informal label.]

### 9.2 “A standardized band is usable everywhere”

!warning[National allocation, licensing, and local conditions still govern operation. The fix is to check the national allocation before assuming a band can be deployed.]

### 9.3 “More bandwidth always increases coverage”

!warning[Bandwidth increases resource supply and noise power. Coverage still needs link closure. The fix is to ask whether the link still closes at the wider bandwidth.]

### 9.4 “FDD belongs below 3 GHz and TDD above”

!warning[Common deployments follow that tendency, but duplex mode is defined by the band and configuration. The fix is to ask how the spectrum was granted — paired or unpaired — before naming a duplex mode.]

### 9.5 “Path loss alone determines cell radius”

!warning[Antenna gain, clutter, penetration, power, sensitivity, interference, and service threshold also matter. The fix is to state the whole link budget.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 3, pp. 27–37, 2021, DOI [chapter 3](https://doi.org/10.1016/B978-0-12-822320-8.00003-9).
2. textbook Chapter 3 PDF.
4. 3GPP, *TS 38.104 V18.14.0, clauses 5–6*, [BS operating bands](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip).
5. 3GPP, *TS 38.101-1 V18.14.0, clauses 5–6*, [UE FR1 requirements](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip).
6. 3GPP, *TS 38.101-2 V18.13.0, clauses 5–6*, [UE FR2 requirements](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip).
7. 3GPP, *TS 38.300 V18.10.0, clause 5*, [NR spectrum context](https://www.3gpp.org/ftp/Specs/archive/38_series/38.300/38300-ia0.zip).
8. 3GPP, [Release 18 overview](https://www.3gpp.org/specifications-technologies/releases/release-18).
9. ShareTechnote, [operating frequency](https://www.sharetechnote.com/html/5G/5G_FR_Bandwidth.html), accessed 2026-08-03.
10. ShareTechnote, [UE millimetre-wave page](https://www.sharetechnote.com/html/5G/5G_UE_mmWave.html), accessed 2026-08-03.
11. Saar University 5G course alignment.

## 11. Abbreviation index

The short forms used in this note, spelled out, with the section where each first appears.

| Abbreviation | Full term | First location and authority |
|---|---|---|
| 5G | Fifth Generation | Section 1; fixed specification set in Section 6 |
| ITU-R | International Telecommunication Union Radiocommunication Sector | Section 1; fixed specification set in Section 6 |
| IMT | International Mobile Telecommunications | Section 1; fixed specification set in Section 6 |
| NR | New Radio | Section 1; fixed specification set in Section 6 |
| UE | User Equipment | Section 1; fixed specification set in Section 6 |
| BS | Base Station | Section 1; fixed specification set in Section 6 |
| FR1 | Frequency Range 1 | Section 1; fixed specification set in Section 6 |
| FR2 | Frequency Range 2 | Section 1; fixed specification set in Section 6 |
| FDD | Frequency Division Duplex | Section 1; fixed specification set in Section 6 |
| TDD | Time Division Duplex | Section 1; fixed specification set in Section 6 |
| SDL | Supplementary Downlink | Section 1; fixed specification set in Section 6 |
| SUL | Supplementary Uplink | Section 1; fixed specification set in Section 6 |

If a short form trips you up, look it up here, or type it into the lookup box in the right margin of the site (key `a`).

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit or domain |
|---|---|---|
| $\Delta L_f$ | Frequency-dependent loss difference | dB |
| $f_{high}$ | Higher comparison frequency | GHz |
| $f_{low}$ | Lower comparison frequency | GHz |

The symbols mean what they mean in this note; another note may use the same letter for something else.
