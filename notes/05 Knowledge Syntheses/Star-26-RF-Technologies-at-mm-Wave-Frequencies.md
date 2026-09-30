---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 26
title: RF Technologies at mm-Wave Frequencies
language: en
course_units:
- U01
- U02
release_baseline: 18
---

# STAR-26 — RF Technologies at mm-Wave Frequencies

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#11. Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#12. Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Star 25 wrote the rulebook. This chapter is about building a transmitter and receiver that can pass it at 28 GHz, where the wavelength is the size of a fingernail and every part of the radio fights the same power and heat budget. Five things get harder at once.

![[99 Attachments/5G/Concept Figures/STAR-26-RF-Technologies-at-mm-Wave-Frequencies-Concept.png|Millimetre-wave RF technology explained as five parts fighting one power and heat budget]]

*Concept figure: Millimetre-wave RF technology explained as five parts fighting one power and heat budget.*

The converter must turn 400 MHz of signal into numbers, sampling billions of times a second, and each extra bit of precision and each extra megahertz costs power, steeply. The oscillator must produce a 28 GHz tone that does not jitter, because a jittering tone smears every subcarrier into its neighbours; the higher the carrier, the harder a clean tone is, and the phone tracks the wobble with a reference signal. The amplifier faces OFDM's ten-decibel peaks: run it hot and the peaks clip, back it off and it wastes battery, and predistortion buys some of both within limits. The filter, the package, and the antenna become one object at these wavelengths; a sharp filter is lossy or narrow, and loss before the first amplifier is noise that can never be recovered. The receiver must hear a faint signal from the edge of a beam and a moment later survive a loud one from the next, and low noise and high linearity pull in opposite directions.

Everything ends in heat. A hot amplifier loses efficiency and gain, a hot oscillator drifts, a hot receiver gets noisier, and the package can shed only so many watts, a ceiling shared by all five. The antenna array does not rescue any of them: sixty-four small amplifiers pointed together give the directional power of one big one, but each still clips, drifts, and heats, and now they must all agree on phase, which adds a calibration the single amplifier never needed. And 3GPP fixes only outcomes, error vector magnitude, emissions, radiated power, sensitivity, and blocking; it never names a converter, an oscillator topology, or a transistor. The chapter is precedent for how designers meet the rules.

**The question this chapter answers.** Why is a wideband millimetre-wave radio a coupled converter, oscillator, amplifier, filter, receiver, and thermal problem, and which of those does the standard actually constrain?

!important[**The short answer.** Bandwidth consumes conversion and baseband power; phase noise erodes orthogonality and modulation quality; amplifier back-off improves linearity but reduces efficiency; filtering protects coexistence but adds loss; a low receiver noise figure improves sensitivity while high linearity protects against blockers; and every active solution creates heat. Beamforming adds array gain but removes none of these; it distributes them across many elements and adds calibration. 3GPP specifies the measurable outcomes in TS 38.101-2 and TS 38.104.]

Names you will meet in this note: radio frequency (RF), frequency range 2 (FR2), analog-to-digital and digital-to-analog converter (ADC, DAC), local oscillator (LO), power amplifier (PA), low-noise amplifier (LNA), signal-to-noise-and-distortion ratio (SNDR), error vector magnitude (EVM), effective isotropic radiated power (EIRP), total radiated power (TRP), equivalent isotropic sensitivity (EIS), phase-tracking reference signal (PT-RS), common phase error (CPE), inter-carrier interference (ICI), peak-to-average power ratio (PAPR), digital predistortion (DPD).

## 2. Where you are in 5G

Section 1 set the fight between power, heat and a fingernail wavelength. The map below shows where the millimetre-wave radio sits in 5G: the last box before the antenna, on both sides of the link.

![[99 Attachments/5G/Locator Maps/STAR-26-Where-You-Are-in-5G.png|Where Star 26 sits in the whole 5G system]]

*Locator: Where Star 26 sits in the whole 5G system.*

This chapter lights the RF band at its high-frequency end, beneath everything else. It is the hardware behind the beams of Star 12 and the FR2 spectrum of Star 03, the outcomes of Star 25 pushed to where they are hardest, and the reason the phase-tracking reference signal of Star 08 exists. Star 27 places FR2 among the later releases.

The Knowledge Structure Map draws the causal path from requested bandwidth to radiated beam. The mechanism diagram traces the front-end chain.

![[99 Attachments/5G/Knowledge Maps/STAR-26-RF-Technologies-at-mm-Wave-Frequencies-Knowledge Structure Map.png|STAR-26 system-position map]]

*Knowledge map: The millimetre-wave link budget as a waterfall of gains and losses.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-26-mmWave-RF-Front-End-Chain.png|Star 26 mechanism and handoff diagram]]

*Mechanism: The millimetre-wave RF front end, with the stages that multiply per element.*

*Both diagrams are original teaching figures drawn for this course.*

External source: [TS 38.101-2 V18.13.0, clause 6, PDF page 53](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip). The reproduced image is omitted from this distribution.

*Source excerpt: TS 38.101-2 V18.13.0, clause 6, PDF page 53, [official 3GPP archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

External source: [Millimetre-wave engineering overview](https://www.sharetechnote.com/html/RF_Handbook_MillimeterWave.html). The reproduced image is omitted from this distribution.

*Source excerpt: Millimetre-wave engineering overview, [ShareTechnote topic page (explanatory)](https://www.sharetechnote.com/html/RF_Handbook_MillimeterWave.html), accessed 2026-08-04. Retained with attribution for course review and later redrawing.*

**Searchable structure.** Requested bandwidth → ADC/DAC and LO phase noise → PA linearity and filtering / receiver noise figure and dynamic range → power and heat → calibrated beam output.

Requested bandwidth fans into two pressures. The conversion path raises sample rate, data movement, and digital load. The frequency-generation path exposes oscillator phase noise, which broadens tones and produces common phase error and inter-carrier interference after demodulation. On transmit, the amplifier must supply element power with acceptable efficiency and linearity while filters suppress images, leakage, and blockers. On receive, front-end loss and device noise set the noise figure, and the swing between wanted and unwanted power sets dynamic-range and compression demands. All paths converge on power and heat, and the beam is a system outcome of element count, per-element power, array factor, losses, calibration, and the radio requirements.

 The map is qualitative because component figures of merit evolve quickly and are not 3GPP limits.

## 3. Foundations and prerequisites

Section 2 placed the radio. Three foundations follow: how fast the converters must run, how clean the oscillator must be, and what the amplifier and receiver chain cost.

### 3.1 Bandwidth and data conversion

The first foundation is data conversion: how fast and how finely the signal must be sampled.

A baseband converter must sample fast enough for the occupied bandwidth and its transition bands. More resolution distinguishes smaller amplitudes but raises complexity, data rate, and usually power. The signal-to-noise-and-distortion ratio summarises quantisation noise, thermal noise, non-linearity, clock jitter, and other impairments over a defined input and bandwidth, and the effective number of bits is derived from it rather than read from the register width. Converter figures of merit compare energy, sample rate, bandwidth, and resolution, but different formulas emphasise different regimes, and a trend fitted to published prototypes guides architecture without promising that every future converter follows one exponent.

> [!book] Book expansion
> Chapter 26 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 527–550, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00026-X)) presents converter performance as a research frontier of around 2020, valuable for its shape, that power rises steeply with bandwidth and resolution above some speed, rather than for its numbers.

### 3.2 Oscillator phase noise

Section 3.1 sampled the signal; this section asks how stable the oscillator behind it is, and what its noise does to OFDM.

!important[An ideal oscillator is one spectral line. A real one fluctuates in phase and spreads energy around the carrier. After frequency translation and OFDM demodulation, a common rotation affects all subcarriers together and faster fluctuations leak energy between subcarriers. At higher carrier frequency, or higher multiplication factor, low phase noise for a given power and area is hard. The phase-tracking reference signal and receiver algorithms remove the common part; they do not create a perfect oscillator.]

> [!spec] 3GPP reality check
> The phase-tracking reference signal is [TS 38.211 V18.9.0, clause 7.4.1.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), with its time and frequency density configured by TS 38.331; phase noise itself is never specified, only the error vector magnitude it contributes to.

### 3.3 PA linearity, efficiency, and receiver noise

Sections 3.1 and 3.2 covered conversion and clock. This section covers the amplifier and the receiver front end, where efficiency and linearity pull in opposite directions.

!important[OFDM has a varying envelope with occasional high peaks. Driving an amplifier near saturation improves efficiency but compresses peaks, raising error vector magnitude and spectral regrowth; backing off preserves linearity at the cost of average output and efficiency; digital predistortion compensates a learned non-linearity within bandwidth and memory limits. On receive, the noise figure is the signal-to-noise degradation the receiver adds, and loss before the first low-noise amplifier hurts it directly. Dynamic range spans the weakest detectable input to the strongest before compression, desensitisation, or intermodulation, and beamforming changes both wanted and unwanted spatial coupling.]

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [millimetre-wave handbook page](https://www.sharetechnote.com/html/RF_Handbook_MillimeterWave.html) gives the path-loss and array-gain arithmetic that explains why per-element power can be modest, which is the starting point for every amplifier decision.

## 4. Mechanism and derivation

Section 3 gave the foundations. Section 4 follows the design decisions that trade them against each other.

### 4.1 Converter architecture and clock quality

The first decision is the converter architecture and the clock that feeds it.

Direct conversion of a very wide bandwidth demands fast converters and high-rate digital interfaces. Hybrid architectures partition bandwidth among converters, trade analogue complexity for digital power, or move conversion nearer each subarray. Clock jitter matters because a small timing error becomes a large phase error at a high input frequency. The architecture follows occupied bandwidth, required signal-to-noise-and-distortion, chain count, beamforming split, and calibration plan. The textbook's converter plots capture an era; their values must not be copied forward as requirements or forecasts.

### 4.2 Frequency generation and distribution

Section 4.1 chose converters. This section generates and distributes the oscillator across an array.

An oscillator may be generated directly, multiplied from a lower reference, or synthesised and distributed across the array. Multiplication multiplies phase deviation; long distribution networks consume power and accumulate mismatch. Centralised generation simplifies coherence but complicates routing, distributed oscillators shorten routes but need synchronisation and calibration, and temperature drift changes phase, so calibration must hold across beam states and conditions. Phase noise contributes to error vector magnitude and adjacent leakage; the wide subcarrier spacing of FR2 shortens symbols and changes which phase-noise components matter, but does not make phase noise irrelevant, and receiver tracking removes only the common error within its estimator bandwidth.

### 4.3 Amplification, filtering, and array integration

Section 4.2 delivered a clean carrier. This section amplifies, filters and integrates it into an array.

An amplifier technology is chosen for gain, output power, efficiency, linearity, bandwidth, voltage, thermal handling, cost, and integration. Arraying many moderate amplifiers creates high directional power, but phase and amplitude error reduces coherent gain, and distorted element outputs still combine. Back-off and predistortion trade average efficiency against error vector magnitude and emissions. Filters must pass a wide band with acceptable loss and reject unwanted signals; at millimetre waves the package, interconnect, antenna, and filter become one electromagnetic structure, a sharp filter may be lossy or narrow relative to the tuning range, and filtering before gain improves blocker tolerance at the cost of noise figure while filtering later protects less.

> [!spec] 3GPP reality check
> The outcomes all of this must meet are [TS 38.101-2 V18.13.0, clauses 6 and 7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) for devices, radiated power by power class, EVM, ACLR and masks on total radiated power, and sensitivity as equivalent isotropic sensitivity, and TS 38.104 clauses 9 and 10 for FR2 base stations.

### 4.4 Receiver dynamic range and heat closure

Section 4.3 transmitted. This section receives, and closes the loop with heat.

The receiver alternates between weak edge-of-beam signals and strong nearby beams; low-noise gain helps the former and compresses on the latter. Variable gain, multiple paths, high-linearity devices, and spatial nulling widen the operating region at a cost in power and complexity. Thermal design closes the loop: hot devices lose amplifier efficiency, gain, and noise performance, forcing power reduction or recalibration. A complete budget includes converters, oscillator distribution, data interfaces, baseband, power and low-noise amplifiers, and cooling.

## 5. Worked example

Section 3.1 said converter power rises with bandwidth. Section 5 puts one number on it.

**What we are working out.** Illustrative ADC power when bandwidth increases from 100 MHz to 400 MHz under a quadratic scaling assumption.

**Worked numerical example.** Apply the explicitly assumed exponent as a sensitivity calculation.

Assume one converter consumes 0.10 W at 100 MHz for a fixed SNDR target and architecture, and use a quadratic high-speed envelope solely for sensitivity analysis:

$$
\begin{aligned}
P_2 &= P_1\left(\frac{B_2}{B_1}\right)^2 \\
&= 0.10\ \mathrm{W}\left(\frac{400\ \mathrm{MHz}}{100\ \mathrm{MHz}}\right)^2 \\
&= 0.10\ \mathrm{W}\,(4)^2 \\
&= 1.60\ \mathrm{W}.
\end{aligned}
$$

Here $P_1$ and $P_2$ are converter powers in watts, $B_1$ and $B_2$ are processed bandwidths in megahertz, W means watts, and MHz means megahertz.

The fourfold bandwidth produces sixteenfold power under this assumed exponent. The result is not a universal scaling law, a Rel-18 limit, or a prediction for a specific ADC. Process technology, resolution, architecture, sample rate, input frequency, interleaving, calibration, and figure-of-merit regime can change both the coefficient and exponent. The textbook motivates why the scaling can become severe above roughly hundred-megahertz-class bandwidths; actual selection requires contemporary device data and measured SNDR.

**Sanity check.** The model predicts no change when the bandwidth ratio is one and sixteenfold power for a ratio of four, matching the stated square-law assumption.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $P_1$ | Assumed converter power at baseline bandwidth | 0.10 | W | Assumed illustration |
| $P_2$ | Scaled converter power | 1.60 | W | Derived under quadratic model |
| $B_1$ | Baseline bandwidth | 100 | MHz | Assumed |
| $B_2$ | Wider bandwidth | 400 | MHz | Assumed |

## 6. The 3GPP protocol: which document, and what it says

The example used a scaling assumption. This section names the document that fixes the outcomes a millimetre-wave radio must reach.

3GPP fixes the FR2 outcomes and leaves the circuits to the designer. TS 38.101-2 states what a millimetre-wave phone must achieve, measured in the air: a peak radiated power and a spherical-coverage floor by power class, a total-power cap, error vector magnitude by modulation, leakage and masks on total radiated power, and sensitivity as equivalent isotropic sensitivity. TS 38.104 does the same for type 2-O base stations. TS 38.211 defines the phase-tracking reference signal that lets the receiver follow an imperfect oscillator. The figure sets the physics of each part beside the outcome it threatens and the configuration or test line it lands on.

![[99 Attachments/5G/Protocol Figures/STAR-26-RF-Technologies-at-mm-Wave-Frequencies-Protocol.png|The FR2 radiated outcomes 3GPP fixes, the physics that makes each hard, and the configuration and test lines they become]]

*Protocol figure: The FR2 radiated outcomes 3GPP fixes, the physics that makes each hard, and the configuration and test lines they become.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| Textbook, 2021 | Chapter 26, pp. 527–550, [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) | whole chapter | converter, oscillator, amplifier, filter, and receiver trade-offs |
| TS 38.101-2 | V18.13.0, [38101-2-id0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) | 6–7; Annex F | FR2 device transmitter and receiver outcomes; the EVM measurement model |
| TS 38.104 | V18.14.0, [38104-ie0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) | 4.3; 9–10 | reference planes and radiated outcomes for FR2 base stations |
| TS 38.211 | V18.9.0, [38211-i90.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 7.4.1.2 | the phase-tracking reference signal |
| TS 21.918 | V18.0.0, [21918-i00.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | 23.1.11 | Release 18 FR2 RF requirement enhancement |

!note[**When you build or run a demo.** A millimetre-wave demo is rarely a software radio; it is a commercial phone or a vendor front end plus an anechoic box, and the numbers that matter are the ones in the test log. The phone's declared power class and band select the row of radiated limits it must meet. Peak radiated power and the spherical-coverage percentile say whether the array is doing its job in every direction. Error vector magnitude at the highest modulation is where oscillator phase noise and amplifier compression show up first, and the phase-tracking reference signal's density is the one configuration line on the radio side that changes it. Leakage on total radiated power is the amplifier's back-off made visible. And a demo that passes cold and fails after ten minutes has met the heat ceiling.]

Release 15 made FR2 possible with radiated device and base-station requirements; Release 16 extended the bands and combinations while implementations matured; Release 18 evolves the FR2 requirements further. Across all of them 3GPP states externally testable behaviour and never a transistor process, converter topology, oscillator distribution, amplifier class, or filter material. Chapter 26 is engineering precedent for how designers meet the requirements. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

### 6.1 Supplement: antenna parameters before beamforming

The outcomes are measured on arrays; this supplement lists the single-panel vocabulary the course slides use for them.

Massive MIMO arrays are still measured with a single panel's vocabulary. The course slides list it; the figure draws it.

![[99 Attachments/5G/Supplement Figures/STAR-26-Saar-Antenna-Basics.png|Antenna pattern, tilt, parameters and the AAU stack]]

*Supplement figure: Antenna basics: a horizontal radiation pattern with the half-power beamwidth marked, a vertical downtilt sketch, six parameter cards, and a layered view of an active antenna unit.*
*Figure 6.1 — Pattern with the half-power beamwidth, downtilt and its two failure modes, six parameters, and the AAU stack.*

| Parameter | Meaning | Typical | Why it matters |
|---|---|---|---|
| Gain | concentration in the main direction; 0 dBd = 2.15 dBi | 15–18 dBi per panel | narrower beam, larger aperture |
| Beamwidth (H/V) | −3 dB angular width | 65° horizontal | sector overlap and edge coverage |
| Downtilt | electrical (phase) or mechanical | 2–8° | too little overshoots, too much leaves a hole |
| VSWR · isolation · PIM | port match, port leakage, mixing products | ≤ 1.5 · ≥ 30 dB | power that never leaves the tower |

Source: Supplementary material, *Antenna theory and 5G antennas* (slides); 3GPP TS 38.104 clause 9.

## 7. ShareTechnote engineering intuition

The specification states limits; the engineering pages give the intuition behind them.

ShareTechnote's [millimetre-wave handbook page](https://www.sharetechnote.com/html/RF_Handbook_MillimeterWave.html) and [UE mmWave page](https://www.sharetechnote.com/html/5G/5G_UE_mmWave.html) give the intuition a beginner needs: how much path loss a fingernail wavelength suffers, how an array of small elements makes it back, what a handset's antenna module looks like, and how an over-the-air test box is set up. They help a student relate a block such as the amplifier or the oscillator to a real module in a phone. The exact limits stay in TS 38.101-2 and TS 38.104.

For a design review, keep one spreadsheet row per chain and record occupied bandwidth, sample rate, signal-to-noise-and-distortion, phase noise, amplifier output and back-off, filter loss, receiver noise figure, blocker headroom, calibration power, and peak temperature. The missing entry is usually more informative than a polished block diagram.

## 8. Course alignment

With the physics, the limits and the pages in place, this section positions the chapter in the course.

Course Alignment maps Chapter 26 to U01–U02 with spectrum and RF constraints. It supplies the physical explanation behind those constraints: emissions arise from nonlinear and noisy hardware, radiated power costs heat, and receiver robustness needs headroom and filtering.

A strong assignment asks students to increase bandwidth and then trace which budgets change—converter power, clock jitter sensitivity, phase noise, PA linearity, filter fractional bandwidth, noise figure, data movement, and heat. The answer should identify tradeoffs.

## 9. Common confusions

The three sentences below are the misreadings this chapter is meant to prevent; each is followed by its fix.

!warning[Higher carrier frequency does not by itself set ADC power. The ADC sees an input bandwidth, sample rate, amplitude distribution, and SNDR requirement determined by the receiver architecture. A 28 GHz radio can downconvert before digitization; the converter need not sample the carrier directly.]

!warning[Beamforming gain does not make PA efficiency or receiver noise figure irrelevant. Coherent array gain depends on per-element signal quality and calibration. More elements add PAs, phase shifters, routing, converters or data paths, and thermal density. A beam can reject a spatially separated interferer, but a blocker inside the beam or a front-end nonlinear product remains.]

!warning[Finally, the textbook's plots summarize published designs from a particular period. They should guide causal reasoning and order-of-magnitude checks, then be refreshed with contemporary component data for a product decision. 3GPP conformance tells whether the final radio meets required outcomes.]

## 10. References

Everything cited above is collected here, so that you can open the exact chapter, clause or page.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 26, pp. 527–550, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00026-X).
2. 3GPP TS 38.101-2 V18.13.0, clauses 6–7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip).
3. 3GPP TS 38.104 V18.14.0, clauses 4.3, 6.5–6.7, and 7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip).
4. 3GPP TS 21.918 V18.0.0, clause 23.1.11. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
5. ShareTechnote, “RF Handbook — Millimeter Wave” and “5G UE mmWave,” accessed 2026-08-03. [Handbook](https://www.sharetechnote.com/html/RF_Handbook_MillimeterWave.html); [UE page](https://www.sharetechnote.com/html/5G/5G_UE_mmWave.html).
6. Course Alignment, local course crosswalk, accessed 2026-08-03.

## 11. Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| ADC | Analog-to-Digital Converter | Circuit converting received analog samples to digital values. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| DAC | Digital-to-Analog Converter | Circuit converting digital transmit samples to an analog waveform. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| EIRP | Effective Isotropic Radiated Power | Directional equivalent isotropic transmit power. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| EVM | Error Vector Magnitude | Modulation-quality metric combining several impairments. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| FR2 | Frequency Range 2 | NR millimetre-wave operating range. | Section 1; [TS 38.101-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) |
| LO | Local Oscillator | Frequency-generation source used for conversion. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| OFDM | Orthogonal Frequency-Division Multiplexing | Multicarrier waveform used by NR. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| PA | Power Amplifier | Transmit-stage amplifier delivering antenna-element power. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| RF | Radio Frequency | Circuit and spectrum domain carrying the modulated waveform. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| SNDR | Signal-to-Noise-and-Distortion Ratio | Converter performance ratio including noise and distortion. | Section 1; [textbook chapter](https://doi.org/10.1016/B978-0-12-822320-8.00026-X) |
| UE | User Equipment | Radio terminal subject to FR2 outcomes. | Section 1; [TS 38.101-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) |

## 12. Mathematical and physical symbol index

The letters used in the worked example, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $P_1$, $P_2$ | Converter power at baseline and wider bandwidth | W |
| $B_1$, $B_2$ | Baseline and wider processed bandwidth | Hz or MHz |
| W | Watt | J/s |
| MHz | Megahertz | $10^6$ Hz |
