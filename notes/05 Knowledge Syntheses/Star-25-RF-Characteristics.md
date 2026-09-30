---
type: knowledge_synthesis
cssclasses:
- research-note-tables
star: 25
title: RF Characteristics
language: en
course_units:
- U01
- U02
release_baseline: 18
---

# STAR-25 — RF Characteristics

> [!note] Finding your way
> Press Ctrl+F (Command+F on a Mac) to jump to any word. Every short form used here is spelled out in [[#7.2 Abbreviation index|the abbreviation index]] at the end, the maths letters in [[#7.3 Mathematical and physical symbol index|the symbol index]], and the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. What this is, and why it exists

Every earlier chapter assumed a perfect transmitter and a perfect receiver. Real ones are not: an amplifier bends the signal, a filter leaks, an antenna radiates where it should not. This chapter is the rulebook that says how far a real radio may fall short, written so that two links can share a band without ruining each other.

![[99 Attachments/5G/Concept Figures/STAR-25-RF-Characteristics-Concept.png|RF characteristics explained as the rulebook for a radio that is not perfect]]

*Concept figure: RF characteristics explained as the rulebook for a radio that is not perfect.*

Think of the transmitter as a singer in a hotel room. The rulebook measures how loud it may sing, with permitted reductions when the song is hard to sing cleanly. It measures how clean the notes are, as error vector magnitude, and how far the pitch drifts, as frequency error. And it measures how far the sound spills: into the next room, as the adjacent-channel leakage ratio and a spectrum mask, and into distant rooms, as spurious emissions. Out-of-band spill comes from the song itself; spurious spill comes from the plumbing. The receiver is the listener next door. The rulebook measures how faint a voice it can still follow, which is really a bound on the noise it adds; how well it ignores a loud neighbour in the next room or further away; and whether two loud neighbours mix into a ghost inside the wanted channel.

There are two ways to measure. Below 7 GHz a radio has an antenna socket and every rule is measured there, conducted. At millimetre waves the antenna is a sealed array with no socket, so the rules are measured in the air, radiated, as total power over a sphere or power in one direction. That split is why the specifications come in FR1 and FR2 volumes. NR made all of this harder than LTE by filling up to 98 percent of its channel with subcarriers, leaving a guard band of a few hundred kilohertz for the filter to work in, at any of a dozen bandwidths and four subcarrier spacings; so a rule cannot be one mask but must be a formula in bandwidth and numerology. The key fact to carry is that every number here exists because two links must share a band: leakage from one and selectivity of the other add up to the interference between them.

**The question this chapter answers.** Why does a radio specification need hundreds of pages about amplifiers and filters, and how are the requirements organised so that one device can work in many bands and regions?

!important[**The short answer.** Because real hardware is not ideal and spectrum is shared. The requirements are grouped into transmitter families, output power, signal quality, and unwanted emissions, and receiver families, sensitivity, dynamic range, and susceptibility to interferers. They are parameterised by band, channel bandwidth, numerology, power class, base-station class, and frequency range, measured conducted at a connector in FR1 and radiated over the air in FR2, and split across TS 38.104 for base stations and the TS 38.101 series for devices.]

Names you will meet in this note: frequency ranges (FR1, FR2), error vector magnitude (EVM), adjacent channel leakage ratio (ACLR), adjacent channel selectivity (ACS), adjacent channel interference ratio (ACIR), spectrum emission mask (SEM), operating band unwanted emissions (OBUE), maximum power reduction (MPR, A-MPR), network signalling value (NS_x), active antenna system (AAS), transceiver array boundary (TAB), radiated interface boundary (RIB), total radiated power (TRP), equivalent isotropic radiated power (EIRP), equivalent isotropic sensitivity (EIS), multi-standard radio (MSR).

## 2. Where you are in 5G

Section 1 said this chapter is the rulebook for how far a real radio may fall short. The map below shows where the rules sit in 5G: at the antenna connector and in the air, on both the device and the base station.

![[99 Attachments/5G/Locator Maps/STAR-25-Where-You-Are-in-5G.png|Where Star 25 sits in the whole 5G system]]

*Locator: Where Star 25 sits in the whole 5G system.*

This chapter lights the RF band beneath the physical layer: the hardware that Star 07's waveform is finally transmitted through. It takes the bands of Star 03, the numerologies of Star 05, and the power control of Star 15, and turns them into limits. Star 26 continues at millimetre waves, where the radiated measurements become the whole story.

The Knowledge Structure Map draws the requirement structure by frequency range and node type. The mechanism diagram traces one conformance measurement from waveform to verdict.

![[99 Attachments/5G/Knowledge Maps/STAR-25-RF-Characteristics-Knowledge Structure Map.png|STAR-25 system-position map]]

*Knowledge map: The transmitter RF requirements drawn as an emission mask around the carrier.*

![[99 Attachments/5G/Mechanism Diagrams/STAR-25-RF-Conformance-Measurement-Chain.png|Star 25 mechanism and handoff diagram]]

*Mechanism: The power amplifier transfer curve and the back-off trade it forces.*

*Both diagrams are original teaching figures drawn for this course.*

Searchable path: 25.1 Spectrum Flexibility Implications → 25.2 RF Requirements in Different Frequency Ranges → 25.3 Channel Bandwidth and Spectrum Utilization → 25.4 Overall Structure of Device RF Requirements → 25.5 Overall Structure of Base-Station RF Requirements.


## 3. The textbook road

Section 2 placed the requirements at the edges of the radio. The road below walks through the chapter in the book's order: what spectrum flexibility demands, the two frequency ranges, bandwidth, the structure of device and base-station requirements, then each family of conducted and radiated requirements.

The sections below follow the textbook chapter in the same order, as kept in the chapter notes of this knowledge base. Book, 3GPP, and ShareTechnote callouts are additions.

### 3.1 **25.1 Spectrum Flexibility Implications**

The road begins with the reason the rules are so many: NR must work in every band, every block size and every aggregation.

!important[NR's RF characteristics are designed around spectrum flexibility. NR must support frequencies from 600 MHz to above 40 GHz, spectrum blocks of every size, and aggregation of fragments. The requirements therefore have to anticipate diverse allocations, paired and unpaired, with carriers placed flexibly inside real licence blocks; coexistence with LTE inside one carrier, which constrains the carrier raster; several numerologies, whose different roll-offs change guard bands and emission masks; base-station and device bandwidths defined independently, since a device often uses only a bandwidth part; and bands added after a release, so that devices designed earlier still work. The rules are not one mask for all; they anticipate coexistence, migration, and dynamic bandwidth.]

> [!book] Book expansion
> Chapter 25 of Dahlman, Parkvall, and Sköld (2nd ed., pp. 487–528, [chapter DOI](https://doi.org/10.1016/B978-0-12-822320-8.00025-8)) is the longest in the book because each requirement family must be stated for base stations and devices, conducted and radiated, and in both frequency ranges.

> [!spec] 3GPP reality check
> Base-station requirements are [TS 38.104 V18.14.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip); device requirements are TS 38.101-1 for FR1, 38.101-2 for FR2, 38.101-3 for interworking, and 38.101-4 for performance.

> [!engineering] ShareTechnote engineering view
> ShareTechnote's [power class page](https://www.sharetechnote.com/html/5G/5G_PowerClass.html) tabulate the bands, bandwidths, and power classes from the specifications, which is the quickest lookup when a configuration value must match a table row.

### 3.2 **25.2 RF Requirements in Different Frequency Ranges**

Section 3.1 asked for flexibility across frequency. This section splits the requirements into two frequency ranges, because what can be built and tested changes at millimetre waves.

The requirements split by frequency range because what can be built and tested changes completely at millimetre waves. Release 16 defines FR1 as 410 to 7125 MHz and FR2 as 24 250 to 52 600 MHz. Figure 25.1 places them on a logarithmic axis with the corresponding IMT identifications.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.1 places them on a logarithmic axis with the corresponding IMT identifications.*

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.1 places them on a logarithmic axis with the corresponding IMT identifications.*

FR1 holds most legacy cellular bands; FR2 holds the millimetre-wave IMT bands, where higher path loss is compensated by more antenna elements, narrower beams, and massive MIMO, which changes coexistence and RF constraints. The partition is the standard's acknowledgement that limits, definitions, and tests cannot be uniform from 0.4 to 50 GHz.

> [!spec] 3GPP reality check
> The frequency ranges and the operating bands within them are TS 38.104 clause 5.2 for base stations and TS 38.101-1 and 38.101-2 clause 5.2 for devices.

### 3.3 **25.3 Channel Bandwidth and Spectrum Utilization**

Within a range, a carrier has a width. This section separates the channel bandwidth from the part of it a signal may use.

A carrier's RF bandwidth is the channel bandwidth $BW_{Channel}$, but its usable resource-block allocation is capped at a maximum $N_{RB}$, leaving a guard band at each edge:

$$
W_{Guard} = \frac{BW_{Channel} - N_{RB} \cdot 12 \cdot \Delta f - \Delta f}{2}
$$

The guard depends on numerology and on the maximum block count, and the extra half-subcarrier on each side accounts for the channel raster, since carriers cannot always be centred perfectly in a block. Figure 25.2 shows the channel bandwidth, the occupied blocks, and the guard bands with their half-subcarrier margins.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.2 shows the channel bandwidth, the occupied blocks, and the guard bands with their half-subcarrier margins.*

Inside the allocated blocks, requirements such as error vector magnitude apply; outside, in the guard and beyond, unwanted-emission requirements apply. NR pushes utilisation to about 98 percent for wide channels, so guard-band design becomes an anchor of the RF specification and is numerology-dependent. Table 25.2 gives the channel bandwidths: up to 100 MHz in FR1 and 400 MHz in FR2, where the widest channels need the largest subcarrier spacing to keep the FFT size manageable.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Table 25.2 gives the channel bandwidths: up to 100 MHz in FR1 and 400 MHz in FR2, where the widest channels need the largest subcarrier spacing to keep the FFT size manageable.*

> [!spec] 3GPP reality check
> The transmission-bandwidth tables, resource blocks per channel bandwidth and numerology, and the minimum guard bands are [TS 38.104 V18.14.0, clause 5.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) and TS 38.101-1 clause 5.3.

### 3.4 **25.4 Overall Structure of Device RF Requirements**

Sections 3.1 to 3.3 gave the physical quantities. This section shows how the device requirements are organised into four documents.

Device requirements are split into four documents: TS 38.101-1 for FR1, conducted; TS 38.101-2 for FR2, radiated; TS 38.101-3 for interworking, such as carrier aggregation across ranges and LTE–NR dual connectivity; and TS 38.101-4 for demodulation performance. The split follows feasibility: FR1 requirements are conducted at the antenna port in the traditional way, while FR2 requirements are radiated because integrated millimetre-wave arrays make a conducted port impractical. Device standardisation is as much about testability as about physics.

### 3.5 **25.5 Overall Structure of Base-Station RF Requirements**

Section 3.4 organised the device side. This section does the same for base stations, with their types and classes.

#### 3.5.1 **25.5.1 Conducted and Radiated RF Requirements for NR BS**

NR supports radiated requirements because active antenna systems integrate the RF chains into the array. Requirements can be conducted, at connectors or at the transceiver array boundary, or radiated, measured over the air in the far field at a defined boundary. Figure 25.3 shows the generalised architecture and its reference points.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.3 shows the generalised architecture and its reference points.*

The transceiver array boundary connectors are the conducted reference, like antenna connectors on a passive design. The composite antenna includes a passive distribution network and the array. The radiated interface boundary is the far-field surface where over-the-air requirements are assessed. The figure justifies why one base station may be specified with conducted, radiated, or hybrid requirements depending on integration.

#### 3.5.2 **25.5.2 BS Types in Different Frequency Ranges for NR**

Four types exist. Type 1-C is FR1, conducted only. Type 1-O is FR1, radiated only. Type 1-H is FR1, hybrid, with conducted requirements at the array boundary and some radiated ones. Type 2-O is FR2, radiated only. The requirements are organised around interfaces and integration level rather than around the base station as one hardware category.

> [!spec] 3GPP reality check
> The base-station types, the array boundary, and the radiated boundary are [TS 38.104 V18.14.0, clauses 4.3 to 4.9](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip).

### 3.6 **25.6 Overview of Conducted RF Requirements for NR**

With the structure in place, this section opens the conducted requirements: what is measured at a connector and why NR's flexibility makes it harder.

Conducted requirements apply mainly in FR1, to devices and some base-station types. Transmitter characteristics cover output power, signal quality, and unwanted emissions; receiver characteristics cover sensitivity and dynamic range, susceptibility to interferers, and receiver emissions. NR's flexible bandwidth and numerology make it harder to define emission limits tied to bandwidth, modulation quality, and receiver selectivity.

#### 3.6.1 **25.6.1 Conducted Transmitter Characteristics**

Three blocks: output power, transmitted signal quality, and unwanted emissions. Figure 25.4 lists them, with the adjacent-channel leakage ratio and error vector magnitude as the critical measures of a clean signal that does not leak.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.4 lists them, with the adjacent-channel leakage ratio and error vector magnitude as the critical measures of a clean signal that does not leak.*

#### 3.6.2 **25.6.2 Conducted Receiver Characteristics**

Three blocks: sensitivity and dynamic range, susceptibility to interferers at various offsets, and receiver unwanted emissions, mainly with the transmitter inactive. Figure 25.5 lists them, including reference sensitivity, how weak a signal can be heard, and blocking, resistance to strong interference.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.5 lists them, including reference sensitivity, how weak a signal can be heard, and blocking, resistance to strong interference.*

#### 3.6.3 **25.6.3 Regional Requirements**

Base stations may have optional regional requirements, while devices roam and must often satisfy several regions at once, which drives the need for signalled applicability.

#### 3.6.4 **25.6.4 Band-Specific Device Requirements Through Network Signaling**

Device requirements can depend on network signalling values, which trigger constraints such as additional power reduction or block restrictions to satisfy a region's or band's limits.

#### 3.6.5 **25.6.5 Base-Station Classes for BS Type 1-C and 1-H**

Wide-area, medium-range, and local-area classes reflect different assumed coupling losses, which change the maximum power of the smaller classes, the frequency-error and emission limits, and the receiver sensitivity and selectivity targets. The conducted requirements are modular: the same families as LTE, with NR's bandwidth and numerology flexibility and regional signalling hooks added.

### 3.7 **25.7 Conducted Output Power Level Requirements**

The first conducted family is output power. This section gives the limits for base stations and devices.

#### 3.7.1 **25.7.1 Base-Station Output Power and Dynamic Range**

There is no universal maximum for a wide-area base station, but the medium and local classes have explicit limits; TDD adds an on-off power mask and transient constraints.

#### 3.7.2 **25.7.2 Device Output Power and Dynamic Range**

Device power is a power class, typically 23 dBm, minus a maximum power reduction that depends on modulation, block allocation, aggregation, supplementary uplink, and uplink MIMO, minus an additional regional reduction tied to network signalling. Device output power is a negotiated capability under RF constraints.

> [!spec] 3GPP reality check
> Base-station output power is TS 38.104 clause 6.2; device power classes and the reduction tables are [TS 38.101-1 V18.14.0, clause 6.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip).

### 3.8 **25.8 Transmitted Signal Quality**

Power says how much is transmitted; this section asks how clean it is: error vector magnitude and frequency error.

!important[Signal quality is error vector magnitude and frequency error, reflecting amplifier non-linearity and other impairments and their effect on the receiver's achievable signal-to-noise ratio.]

#### 3.8.1 **25.8.1 EVM and Frequency Error**

EVM is measured after cyclic-prefix removal and equalisation in a standardised receiver model, and the estimated frequency offset feeds the frequency-error metric.

#### 3.8.2 **25.8.2 Device In-Band Emissions**

The limit bounds a device's leakage inside the channel into blocks it was not allocated, evaluated after cyclic-prefix removal and the FFT, as a receiver would see it.

#### 3.8.3 **25.8.3 Base-Station Time Alignment**

Multi-antenna features require a bounded time-alignment error between transmitter branches so that a device can coherently receive diversity, MIMO, and aggregated signals. NR's quality metrics model what a receiver would measure.

> [!spec] 3GPP reality check
> EVM, frequency error, and time alignment for base stations are TS 38.104 clause 6.5; for devices, EVM and in-band emissions are TS 38.101-1 clause 6.4.

### 3.9 **25.9 Conducted Unwanted Emissions Requirements**

Section 3.8 measured the wanted signal. This section measures what leaks outside it, and why the boundary between near and far emissions is hard to draw.

Unwanted emissions split into out-of-band emissions, close in and caused by modulation, and spurious emissions, farther out and caused by harmonics, intermodulation, and frequency conversion. ITU-R places the boundary near 2.5 times the necessary bandwidth, which flexible bandwidth makes ambiguous, so 3GPP treats base stations and devices differently.

#### 3.9.1 **25.9.1 Implementation Aspects**

OFDM spectra decay slowly and NR occupies up to about 98 percent of its channel, so meeting the limits needs time-domain windowing, digital and analogue filtering, and amplifier back-off or linearisation such as predistortion. Compliance is an implementation problem under high utilisation, especially for base stations, where advanced linearisation is expected.

### 3.10 **25.9.2 Emission Mask in the OOB Domain**

The nearest emissions are limited by a mask. This section explains why base stations and devices get different masks.

The emission mask limits what may be emitted outside the necessary bandwidth, and NR treats base stations and devices differently to cope with variable bandwidth.

#### 3.10.1 **25.9.2.1 Base-Station Operating Band Unwanted Emission Limits**

Instead of a bandwidth-dependent classic mask, base stations use operating-band unwanted emissions, which avoid an explicit out-of-band-to-spurious boundary. They apply over the whole operating band plus 10 to 40 MHz on each side, with regulatory spurious limits beyond. Figure 25.6 shows the spans.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.6 shows the spans.*

Because the band-wide limit can reach into what regulation calls the spurious domain for a small channel, its shape is aligned with regulatory expectations from about 10 to 40 MHz beyond the channel edges. For aggregation it is referenced to the outermost carriers, and for non-contiguous aggregation the emissions in gaps sum contributions.

#### 3.10.2 **25.9.2.2 Device Spectrum Emission Mask**

For devices a single generic mask is not feasible, so the mask varies with channel bandwidth and extends to an offset from the channel edge that is 250 percent of the necessary bandwidth at 5 MHz, per ITU-R, and closer than that for wider channels. Figure 25.7 shows the mask region and the transition to spurious limits.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.7 shows the mask region and the transition to spurious limits.*

The device mask has a general form plus regional forms activated by network signalling.

> [!spec] 3GPP reality check
> Operating-band unwanted emissions are TS 38.104 clause 6.6.4; the device spectrum emission mask and its regional variants are TS 38.101-1 clause 6.5.2.

### 3.11 **25.9.3 Adjacent Channel Leakage Ratio**

The mask is one limit on the neighbour's channel; this section adds the leakage ratio and shows how it combines with the receiver's selectivity.

Besides the mask, NR constrains adjacent-channel impact through the leakage ratio, the ratio of in-channel power to what leaks into the adjacent channel. Coexistence depends on both transmitter leakage and receiver selectivity, combined as the adjacent-channel interference ratio:

$$
\text{ACIR}=\frac{1}{\frac{1}{\text{ACLR}}+\frac{1}{\text{ACS}}}
$$

Either side can dominate. Figure 25.8 shows the signal view and the receiver view: leakage is a transmitter property, selectivity a receiver property, and together they set the interference.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.8 shows the signal view and the receiver view: leakage is a transmitter property, selectivity a receiver property, and together they set the interference.*

For base stations the ratio is strict, 45 dB, which pushes complexity to the base-station side as a cost-efficient system choice. For aggregation it applies as to any multicarrier transmission, and for non-contiguous aggregation with small gaps a cumulative ratio is defined for the gap with the same limit. For devices it is defined against assumed NR and UTRA receivers, applies to the aggregated bandwidth under aggregation, and is 30 dB, so the uplink interference ratio is device-transmitter limited.

### 3.12 **25.9.4 Spurious Emissions**

Section 3.11 stayed close to the carrier. This section moves far away, to spurious emissions.

Base-station spurious limits are defined outside the range covered by the band-wide limit, about 10 to 40 MHz from the band, so their range does not exactly match the regulatory spurious domain, though the limits are aligned. Extra limits may protect systems NR coexists or is co-located with, such as GSM, UTRA, LTE, and PHS. Device spurious limits are defined outside the mask's range and are largely regulatory, with extra roaming constraints sometimes signalled. Receiver spurious limits apply mainly when the transmitter is off, since otherwise the transmit signal dominates, with an exception for an FDD base station with a separate receive antenna connector.

### 3.13 **25.9.5 Occupied Bandwidth**

Some regions regulate occupied bandwidth directly. This section gives its definition and NR's value.

Occupied bandwidth is a regulatory requirement in some regions, defined by ITU-R as the width outside which emissions must not exceed a set fraction of the total. For NR it equals the channel bandwidth, with one percent of emissions allowed outside, half on each side.

### 3.14 **25.9.6 Transmitter Intermodulation**

The last emission requirement involves a second transmitter next door: this section tests intermodulation.

> [!important] 💡
> **What transmitter intermodulation is:** mixing products generated by transmitter non-linearity when the transmitter's own signal interacts with another strong nearby signal; the products can land on sensitive frequencies and act as extra unwanted emissions, which is why 3GPP has a dedicated requirement.
> **Why it matters:** the chapter motivates it by intermodulation between the transmitted signal and another strong signal transmitted near the base station or device.

For a base station the test places a co-located transmitter's signal at the antenna connector attenuated by 30 dB, and the station must still meet its unwanted-emission limits with that interferer present. For a device the other signal is attenuated by 40 dB, and the requirement is a minimum attenuation of the resulting product below the transmitted signal.

> [!spec] 3GPP reality check
> Base-station ACLR, spurious emissions, occupied bandwidth, and transmitter intermodulation are TS 38.104 clauses 6.6.3, 6.6.5, 6.6.1, and 6.7; the device counterparts are TS 38.101-1 clauses 6.5.2.4, 6.5.3, 6.5.1, and 6.5.4.

### 3.15 **25.10 Conducted Sensitivity and Dynamic Range**

Sections 3.7 to 3.14 were the transmitter. This section turns to the receiver and its sensitivity.

!note[Reference sensitivity verifies the receiver's noise figure, how much the chain degrades the signal-to-noise ratio. A low-rate QPSK reference channel is used, and sensitivity is the input level at which throughput reaches 95 percent of that channel's maximum; for a device, it is defined for the full channel with all blocks allocated. Dynamic range ensures operation well above sensitivity: the base-station scenario raises both interference and wanted level, using 16QAM with added white noise 20 dB above the noise floor, while a device's dynamic range is a maximum level at which throughput is still met.]

### 3.16 **25.11 Receiver Susceptibility to Interfering Signals**

Sensitivity assumes a quiet band. This section adds interferers at various offsets and the requirements for each.

Several requirements exist because the dominant impairment changes with the interferer's offset. Base stations and devices have the same families at different levels, and no device counterpart of in-channel selectivity. Figure 25.9 maps them: blocking, adjacent-channel selectivity, narrowband blocking, and in-channel selectivity for base stations only.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.9 maps them: blocking, adjacent-channel selectivity, narrowband blocking, and in-channel selectivity for base stations only.*

Blocking covers strong interferers not adjacent to the wanted signal, out of band or in band, with in-band blocking reaching 20 to 60 MHz beyond the band for base stations and 15 MHz for devices; out-of-band interferers are modelled as continuous waves and in-band ones as NR signals, with optional co-location requirements for base stations and a limited number of spurious-response exceptions for devices. Adjacent-channel selectivity is a strong adjacent NR interferer, closely related to the leakage ratio, specified for two levels for devices.

> [!important] 💡
> **Narrowband blocking:**
> **What it is here:** a scenario with an adjacent strong narrowband interferer; for a base station modelled as a single-block NR signal, for a device as a continuous wave.
> **So is it a guard band to block leakage?** Not exactly. It is not a transmitter guard mechanism; it is a receiver robustness test against a narrow adjacent interferer, which can be more peaky and stress selectivity and non-linearity differently from a wideband one.

In-channel selectivity, for base stations only, verifies reception of a weaker wanted signal beside a stronger in-channel one. Receiver intermodulation places two interferers, one continuous wave and one NR, so that their product lands in the wanted channel, testing linearity; base stations also have a narrowband variant.

> [!spec] 3GPP reality check
> Base-station sensitivity, dynamic range, selectivity, blocking, and intermodulation are [TS 38.104 V18.14.0, clause 7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip); the device counterparts are TS 38.101-1 clause 7.

### 3.17 **25.12 Radiated RF Requirements for NR**

Everything so far was conducted. This section moves to radiated requirements, because an active antenna has no connector to measure at.

With active antenna systems, requirements at a connector may be unsuitable, so radiated requirements assess spatial characteristics. Total radiated power is used for unwanted emissions partly because in an active system the directional power need not be proportional to the total, so substituting one for the other can be wrong.

### 3.18 **25.12.1 Base-Station Classes for BS Type 1-O and 2-O**

Radiated base stations need classes too. This section defines them by distance rather than by coupling loss.

With no connector, classes rest on minimum base-station-to-device distance rather than coupling loss: 35 m for wide area, 5 m for medium range, 2 m for local area. Smaller distances mean lower minimum coupling loss and modified limits, and the total radiated power per antenna and carrier is capped at 47 dBm for medium range and 33 dBm for local area, with no cap for wide area.

### 3.19 **25.12.2 Radiated Device Requirements in FR2**

Section 3.18 covered base stations. This section covers devices in FR2, the only radiated device requirements.

No radiated device requirements exist for FR1; the FR2 ones sit in a separate document because of the many elements and high integration at millimetre waves. They mostly mirror the conducted FR1 requirements with different limits, often looser because coexistence is easier at millimetre waves. Output power is of similar order but expressed as total and directional radiated power, with higher minimum and off powers, a directional transmit-power requirement, and spherical coverage based on the 85th-percentile minimum directional power over the sphere. Quality is as in FR1. Unwanted emissions are defined similarly on total radiated power with looser limits, the leakage ratio relaxed by about 10 dB. Beam correspondence is a new requirement tied to uplink beam sweeping. Sensitivity and dynamic range are radiated, based on equivalent isotropic sensitivity. Selectivity and blocking are radiated likewise, with no narrowband blocking since FR2 holds only wideband systems.

> [!important] 💡
> **EIRP vs TRP (and does TRP include interference?):**
> **EIRP** is directional: equivalent isotropic radiated power in a given direction or beam, capturing beamforming gain toward it. This matches the text's emphasis that some radiated requirements, such as radiated transmit power, are directional.
> **TRP** is total: radiated power integrated over all directions, used as the basis for some unwanted-emission requirements.
> **TRP does not include external interference.** It is a transmitter-output metric. The chapter says TRP is used for unwanted emissions partly because it better represents, and can limit, the total interference the transmitter injects into the network, whereas EIRP can vary unpredictably against TRP in active systems.

### 3.20 **25.12.3 Radiated Base-Station Requirements in FR1**

Back to base stations, this section gives the radiated requirements in FR1.

Type 1-O is fully radiated; type 1-H is mostly conducted plus two radiated requirements shared with 1-O. Radiated transmit power is defined from the array's beam pattern as directional power for each declared beam, and the requirement is on the accuracy of the declared level. Over-the-air sensitivity rests on manufacturer declarations of one or more sensitivity directions: sensitivity is defined as equivalent isotropic sensitivity toward a receiver target and must hold over a declared range of arrival angles, tested at five directions within a redirection range if the receiver is adaptive, or at a single declared range if not. It is in addition to the reference sensitivity requirement.

### 3.21 **25.12.4 Radiated Base-Station Requirements in FR2**

Section 3.20 was FR1. This section gives the FR2 set with its different limits.

Type 2-O covers FR2, in the same document as the FR1 radiated requirements. The set is the same as in FR1 with different limits, some relaxed by millimetre-wave coexistence. Output power is scaled and expressed as total radiated power with a directional requirement; quality is as in FR1; unwanted emissions are on total radiated power with looser limits, the leakage ratio relaxed by about 15 dB; sensitivity and dynamic range are defined similarly at non-comparable levels with directional sensitivity; and selectivity and blocking are as in FR1, without narrowband blocking, with selectivity relaxed.

> [!spec] 3GPP reality check
> The radiated base-station requirements for types 1-O, 1-H, and 2-O are TS 38.104 clauses 9 and 10; the radiated device requirements are [TS 38.101-2 V18.13.0, clauses 6 and 7](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip).

### 3.22 **25.13 Multi-Standard Radio Base Stations**

The remaining sections concern base stations that carry more than one thing. This section starts with several radio technologies through one active RF.

A multi-standard radio base station transmits several radio technologies, NR, LTE, UTRA, or GSM, through common active RF rather than as separate radios in one cabinet. It matters because operators migrate spectrum gradually and need NR to coexist with legacy technologies in one band, sometimes on shared hardware, under controlled compliance. The RF bandwidth describes the span over which such a station can transmit carriers of several technologies through common RF. Figure 25.10 shows carriers of two technologies through one chain.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.10 shows carriers of two technologies through one chain.*

### 3.23 **25.14 Multi-Carrier or Non-Contiguous Spectrum Operation**

Section 3.22 mixed technologies. This section mixes carriers, possibly with gaps between them.

Base stations may transmit several carriers, possibly non-contiguous within one band, which is common with fragmented spectrum and aggregation and improves utilisation without a single wide block. The station supports a radio bandwidth spanning the carriers; a sub-block gap is the gap between the RF bandwidths of two sub-blocks; and fragmented spectrum is the special case of a gap larger than about 35 MHz. Figure 25.11 shows two sub-blocks, the gap, and the overall radio bandwidth, the geometry that decides which limits apply in the gap.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.11 shows two sub-blocks, the gap, and the overall radio bandwidth, the geometry that decides which limits apply in the gap.*

### 3.24 **25.15 Multiband-Capable Base Stations**

The road ends with base stations that span several bands through one radio.

A true multiband base station transmits and receives across bands through common active RF, unlike older dual-band cabinets with co-located independent radios.

#### 3.24.1 **25.15.1 Multiband architectures and parameters**

Multiband can be a multiband transmitter and receiver, a multiband transmitter with single-band receivers, or the reverse. Figure 25.12 shows a common multiband transmitter and receiver through a duplex filter to one antenna connector, with two bands and possibly several technologies.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.12 shows a common multiband transmitter and receiver through a duplex filter to one antenna connector, with two bands and possibly several technologies.*

The terms are the RF bandwidth per band, the inter-RF-bandwidth gap between the bands, which may contain other operators or services, and the radio bandwidth covering both. Figure 25.13 shows separate connectors per band with the RF still common inside and split by filtering before the connectors.

The reproduced source image is omitted from this distribution. Consult the chapter citation below.

*Textbook figure 25.13 shows separate connectors per band with the RF still common inside and split by filtering before the connectors.*

The architecture decides which multiband exceptions apply.

#### 3.24.2 **25.15.2 What RF requirements change in multiband operation (notable exceptions)**

With common RF and possibly wide, overlapping RF bandwidths, some requirements need special handling because emissions and susceptibility interact across the gap. Transmitter spurious emissions use a joint exclusion band across both operating bands. The band-wide emission limit may apply cumulatively when the gap is small. The leakage ratio applies inside the gap, cumulatively where channels overlap. Transmitter intermodulation applies when the gap is small and the interferers fit inside it. Blocking and receiver intermodulation apply for both bands and inside the gap with joint exclusion. Receiver spurious emissions use a joint exclusion band likewise. When the bands have separate antenna connectors, several of these exceptions do not apply and each connector is treated as single-band.

> [!spec] 3GPP reality check
> Multi-standard, multi-carrier, non-contiguous, and multiband operation and their exceptions are defined through the RF bandwidth, sub-block gap, and inter-RF-bandwidth gap terms of TS 38.104 clause 4 and applied throughout its clauses 6 and 7.

## 4. The 3GPP protocol: which document, and what it says

The road followed the book; this section names the documents: one for base stations, a series for devices, each holding the same families of requirements.

Base stations are one document, TS 38.104, and devices are the TS 38.101 series, split by frequency range. Each holds the same families: channel bandwidth and its guard, output power, signal quality, unwanted emissions, sensitivity, and susceptibility. The figure draws the guard-band formula, the error-vector limits by modulation, the leakage ratio and its combination with selectivity, where the base-station and device masks apply, and the device power class with the reference-sensitivity criterion, with the configuration and test lines each becomes.

![[99 Attachments/5G/Protocol Figures/STAR-25-RF-Characteristics-Protocol.png|The RF requirement families for base stations and devices, with their clauses, limits and the configuration lines they become]]

*Protocol figure: The RF requirement families for base stations and devices, with their clauses, limits and the configuration lines they become.*

| Specification | Version and direct artifact | Clause anchor | Teaching use |
|---|---|---|---|
| TS 38.104 | V18.14.0, [38104-ie0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) | 4.3–4.9; 5.3; 6; 7; 9–10 | base-station reference points, bandwidth, transmitter, receiver, radiated |
| TS 38.101-1 | V18.14.0, [38101-1-ie0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip) | 5.3; 6; 7 | FR1 device bandwidth, transmitter, and receiver requirements |
| TS 38.101-2 | V18.13.0, [38101-2-id0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) | 5.3; 6; 7 | FR2 device bandwidth and radiated requirements |
| TS 38.101-3 | V18.14.0, [38101-3-ie0.zip](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-3/38101-3-ie0.zip) | 6–7 | interworking and multi-range combinations |
| TS 21.918 | V18.0.0, [21918-i00.zip](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip) | 23.1.11 | Release 18 FR2 RF requirement evolution |

!note[**When you build or run a demo.** A software radio demo lives inside these tables even when nobody reads them. The band, the channel bandwidth, and the subcarrier spacing together select a row that fixes how many resource blocks the carrier may hold, and a block count that does not match the row is the commonest configuration error. The transmit gain sets output power, and a device that transmits above its power class or a base station above its class limit violates its licence. A spectrum analyser on the output shows the mask, the leakage ratio, and the error vector magnitude, and a demo that decodes at short range but not across a room usually fails one of them. On the receiver side, the reference sensitivity of a laboratory radio is far worse than a commercial one, and it sets how far the demo reaches.]

Release 15 established the bands, bandwidths, transmitter and receiver requirements, and the FR1 conducted versus FR2 radiated distinction. Release 16 expanded bands, combinations, and active-antenna capabilities. Release 18 adds FR2 and multiband evolution. Every requirement remains conditional on band, bandwidth, power class, base-station class, and declared configuration, and release progression cannot be reduced to one universal limit. Exact versions, official URLs, and SHA-256 hashes are fixed in [[Protocol/Rel-18/spec-manifest.yml|the Rel-18 specification manifest]].

## 5. Worked teaching trace

The documents fix leakage and selectivity separately; this trace combines them into the interference ratio you can compute by hand.

**What we are working out.** Adjacent-channel interference ratio for ACLR 45 dB and ACS 46 dB.

**Worked numerical example.** Combine transmitter leakage and receiver selectivity after converting their inverse ratios to linear space.

ACLR and ACS are converted through their inverse linear leakage terms. The combined ratio is then returned to decibels:

$$
\begin{aligned}
\mathrm{ACIR}_{\mathrm{dB}} &= -10\log_{10}\!\left(10^{-\mathrm{ACLR}_{\mathrm{dB}}/10}+10^{-\mathrm{ACS}_{\mathrm{dB}}/10}\right) \\
&= -10\log_{10}\!\left(10^{-45/10}+10^{-46/10}\right) \\
&= -10\log_{10}\!\left(5.674\times10^{-5}\right) \\
&\approx 42.46\ \mathrm{dB}.
\end{aligned}
$$

Here $\mathrm{ACLR}_{\mathrm{dB}}$ is transmitter leakage ratio in dB, $\mathrm{ACS}_{\mathrm{dB}}$ is receiver selectivity in dB, $\mathrm{ACIR}_{\mathrm{dB}}$ is their combined interference ratio in dB, and dB means decibels.

The combined performance is lower than either 45 dB or 46 dB because both transmitter leakage and receiver response contribute interference. The numbers are illustrative and are not asserted as a particular band/equipment conformance requirement. A real compatibility study also includes antenna coupling, path loss, bandwidth correction, loading, power control, and the exact reference planes.

**Sanity check.** A combination containing two impairment terms must produce an ACIR below both individual isolation ratios, and 42.46 dB satisfies that limit.

| Symbol | Meaning | Value in example | Unit | Evidence / source plane |
| --- | --- | ---: | --- | --- |
| $\mathrm{ACLR}_{\mathrm{dB}}$ | Transmitter adjacent-channel leakage ratio | 45 | dB | Assumed illustration |
| $\mathrm{ACS}_{\mathrm{dB}}$ | Receiver adjacent-channel selectivity | 46 | dB | Assumed illustration |
| $\mathrm{ACIR}_{\mathrm{dB}}$ | Combined adjacent-channel interference ratio | 42.46 | dB | Derived |

## 6. Course alignment and common confusions

The trace closed the technical part. This section places the chapter in the course and lists the sentences students most often get wrong about it.

**Course alignment.** Course Alignment maps Chapter 25 to U01–U02 together with spectrum and RF constraints. It supports early teaching on why a nominal carrier allocation is not the same as occupied spectrum, how nonlinear emissions affect neighbors, and why mm-wave arrays require radiated testing.

A suitable problem gives one transmitter ACLR, one victim ACS, and explicit conducted/radiated boundaries. Students calculate ACIR and then explain what additional coupling information is required for interference power at the victim.

> What does transmitter intermodulation mean?

!warning[It is unwanted emission produced when an external interfering signal and the transmitter's own signal(s) pass through nonlinear circuitry and generate mixing products. The standardized test specifies interferer placement and level. It is related to, but not identical with, ordinary spectral regrowth from the wanted waveform.]

> Is narrowband blocking a guard-band mechanism?

!warning[No. It is a receiver test using a strong narrowband interferer at specified frequency offsets. The result assesses filtering, linearity, gain-control, and dynamic-range robustness. A guard band is a spectrum-planning separation; it is not what the blocking requirement names.]

> How do EIRP and TRP differ, and does TRP include external interference?

!warning[EIRP is directional—the equivalent isotropic power producing the observed power density in a direction. TRP integrates the device's transmitted radiation over direction. TRP includes the device's own emissions under the defined transmit test. Directional peak EIRP can be high while TRP remains bounded; neither number replaces the other.]

## 7. References and lookup indexes

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

1. E. Dahlman, S. Parkvall, and J. Sköld, *5G NR*, 2nd ed., Chapter 25, pp. 487–525, 2021. [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00025-8).
2. 3GPP TS 38.101-1 V18.14.0, clauses 5.3, 6, and 7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip).
3. 3GPP TS 38.101-2 V18.13.0, clauses 5.3, 6, and 7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip).
4. 3GPP TS 38.104 V18.14.0, clauses 4.3–4.9, 5.3, 6.5–6.7, and 7. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip).
5. 3GPP TS 21.916 V16.2.0, clauses 19.1.13–19.1.14. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.916/21916-g20.zip).
6. 3GPP TS 21.918 V18.0.0, clause 23.1.11. [Direct archive](https://www.3gpp.org/ftp/Specs/archive/21_series/21.918/21918-i00.zip).
7. ShareTechnote, “5G FR/Bandwidth” and “5G OTA,” accessed 2026-08-03. [FR/Bandwidth](https://www.sharetechnote.com/html/5G/5G_FR_Bandwidth.html); [OTA](https://www.sharetechnote.com/html/5G/5G_OTA.html).
8. Course Alignment, local course crosswalk, accessed 2026-08-03.

### 7.2 Abbreviation index

Canonical expansion policy follows [[5G Abbreviation Database]].

| Abbreviation | Full term | Explanation | First location and source |
|---|---|---|---|
| ACIR | Adjacent-Channel Interference Ratio | Combined transmitter-leakage and receiver-selectivity ratio. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| ACLR | Adjacent-Channel Leakage Ratio | Assigned-channel power relative to adjacent-channel leakage. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| ACS | Adjacent-Channel Selectivity | Receiver rejection of an adjacent-channel interferer. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| EIRP | Effective Isotropic Radiated Power | Directional equivalent isotropic transmit power. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| EIS | Equivalent Isotropic Sensitivity | Directional radiated receiver-sensitivity metric. | Section 1; [TS 38.101-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) |
| EVM | Error Vector Magnitude | In-channel modulation-quality metric. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| FR1 | Frequency Range 1 | NR lower-frequency operating range defined by specification. | Section 1; [TS 38.101-1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-1/38101-1-ie0.zip) |
| FR2 | Frequency Range 2 | NR millimetre-wave operating range defined by specification. | Section 1; [TS 38.101-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) |
| RF | Radio Frequency | Circuit and spectrum domain carrying the radio waveform. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| RIB | Radiated Interface Boundary | Boundary for radiated base-station requirements. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| TAB | Transceiver Array Boundary | Defined boundary associated with active antenna systems. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| TRP | Total Radiated Power | Transmit power integrated over direction. | Section 1; [TS 38.104](https://www.3gpp.org/ftp/Specs/archive/38_series/38.104/38104-ie0.zip) |
| UE | User Equipment | Radio endpoint subject to UE RF requirements. | Section 1; [TS 38.101-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.101-2/38101-2-id0.zip) |

### 7.3 Mathematical and physical symbol index

The letters used in the worked trace, with their meaning and unit.

| Symbol | Meaning | Unit |
| --- | --- | --- |
| $\mathrm{ACLR}_{\mathrm{dB}}$ | Adjacent-channel leakage ratio in decibels | dB |
| $\mathrm{ACS}_{\mathrm{dB}}$ | Adjacent-channel selectivity in decibels | dB |
| $\mathrm{ACIR}_{\mathrm{dB}}$ | Combined adjacent-channel interference ratio | dB |
| dB | Decibel, a logarithmic power-ratio unit | dimensionless logarithmic unit |
| $f$ | Frequency | Hz |
