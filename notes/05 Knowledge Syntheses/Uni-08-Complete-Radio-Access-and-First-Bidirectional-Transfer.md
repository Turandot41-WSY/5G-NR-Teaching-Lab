---
type: knowledge_synthesis
title: Uni-08 — Radio access, RRC establishment and the first bidirectional transport
  blocks
language: en
uni: 8
release_baseline: 18
cssclasses:
- research-note-tables
lab_run: uni08-results-20260907
---

# Uni-08 — Radio access, RRC establishment and the first bidirectional transport blocks

!important[The earlier experiments recover individual signals and blocks. This laboratory uses their outputs to advance a user equipment (UE) through discovery, random access, radio resource control (RRC) establishment and its first downlink (DL) and uplink (UL) test blocks. The next generation NodeB (gNB) must act on what it decodes at each stage: a preamble alone cannot identify a device, and a transport block CRC alone cannot establish an RRC connection.]

The system map identifies which endpoint receives each message and which decoded information permits the next stage. Keeping the bearer and core network limits visible prevents successful physical reception from being read as a completed application service.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - System Position v1.png|Radio access across the UE and gNB]]

*Original system schematic. Synchronization signal block (SSB), Master Information Block (MIB) and System Information Block 1 (SIB1) establish the cell context. The physical random access channel (PRACH), random access response (RAR), Msg3 and Msg4 establish timing and resolve identity. Actual Unaligned Packed Encoding Rules (UPER) bytes carry the RRC messages. Radio link control (RLC), packet data convergence protocol (PDCP) and subsequent scheduling are implemented only as the declared subset below. Non-access stratum (NAS) bytes are carried opaquely; core procedures are outside the experiment.*

Press Ctrl+F (Command+F on a Mac) to jump to any parameter, function or clause. Short forms are spelled out in [[#7.2 Abbreviation index]] and the maths letters in the symbol index; the lookup box in the right margin of the site explains any abbreviation as you type.

## 1. Engineering objective and source integration

**Stage — Textbook workflow.**

The overview above named the endpoints and the message each stage needs. This section says what the experiment delivers and where the knowledge comes from.

The output is an evidence record tying decoded messages to state transitions and six actual physical shared channel transmissions. The baseline uses one FR1 cell, one UE, normal cyclic prefix and 30 kHz data numerology. It makes the sequence in the [[Star-17-Random-Access|random access note]] of this knowledge base executable while keeping the protocol layers visible.

| Source note | Contribution | Used result or condition |
| --- | --- | --- |
| [[Uni-01-Cell-Search-Synchronization-and-MIB-Recovery\|Uni-01]] | Cell identity, frequency and timing acquisition | Run its receiver on the broadcast samples |
| [[Uni-02-Reference-Signals-Channel-Estimation-and-Equalization\|Uni-02]] | Reference signal measurement and equalization | Practical DM-RS receiver for each data stage |
| [[Uni-03-MIB-CORESET0-PDCCH-and-SIB1-Recovery\|Uni-03]] | Broadcast control and SIB1 recovery | Actual decoded SIB1 common configuration |
| [[Uni-04-PRACH-Timing-Advance-and-Uplink-Alignment\|Uni-04]] | Initial uplink arrival and command units | Apply measured TA at the new 30 kHz numerology |
| [[Uni-05-Transport-Blocks-LDPC-and-HARQ\|Uni-05]] | Transport coding and CRC interpretation | Fresh DL-SCH and UL-SCH decoders |
| [[Uni-06-PUSCH-Power-Control-and-Coverage\|Uni-06]] | Uplink power and coverage boundary | Separate timing success from adequate SNR |
| [[Uni-07-CSI-Feedback-and-Adaptive-MIMO\|Uni-07]] | Measured quality versus transmitter knowledge | Declare single antenna and fixed modulation here |
| [[Star-06-Radio-Interface-Architecture\|Star-06]] | Logical, transport and physical channels | Identify the message carried by each waveform |
| [[Star-17-Random-Access\|Star-17]] | Four step procedure | RAR matching and contention identity |
| [[Star-33-TS-38.321-Medium-Access-Control\|Star-33]] | MAC messages and timers | RAR/CCCH headers and transition guards |
| [[Star-36-TS-38.331-Radio-Resource-Control\|Star-36]] | RRC messages and connection state | UPER encode/decode and transaction checks |

The frozen Third Generation Partnership Project (3GPP) sources define the transmitted objects and state conditions. The laboratory's post SIB1 grant delivery, receive algorithms and noise scenarios are explicit engineering choices.

| Official source | Clauses | What enters the implementation |
| --- | --- | --- |
| [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip) | 4.1; 6.3.1; 6.3.3; 6.4.1.1; 7.3; 7.4 | Time unit, PRACH and shared channel/reference sequences |
| [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip) | 6.2; 7.1–7.3 | Uplink/downlink transport and broadcast/control coding |
| [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip) | 4.2; 8.1–8.4 | TA, access response and Msg3 timing |
| [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip) | 6.1.2.1.1; 6.1.2.2.2 | Msg3 time and frequency allocation |
| [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip) | 5.1; 6.1.3.3; 6.2.1–6.2.3 | Random access, contention identity, MAC headers and RAR |
| [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip) | 5.3.3; 6.2.2; 6.3.2 | RRC establishment and message/IE definitions |

Dahlman, Parkvall and Sköld, *5G NR: The Next Generation Wireless Access Technology*, second edition, Chapter 16, pp. 335–347 ([DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7)), and Chapter 17, pp. 349–370 ([DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9)), provide the discovery and access narrative. The book's Release 15/16 procedure is the starting point; the frozen Release 18 field and timing definitions govern this implementation. Two step access, RedCap and nonterrestrial timing extensions are not exercised by this configuration.

## 2. System position and the implemented boundary

**Stage — Textbook workflow.**

Section 1 gave the sources. This section fixes the boundary: which messages and waveforms are real, which parts are simplified, and the cell configuration.

This is an ordered integration of physical waveforms, real message encodings and a selected state machine. The broadcast includes actual physical downlink control channel (PDCCH) search and physical downlink shared channel (PDSCH) recovery. RAR and Msg4 PDCCH waveforms are also decoded, and Msg4 receives physical uplink control channel (PUCCH) feedback. Their control resources are configured explicitly in the laboratory. The RAR's recovered grant determines Msg3 resources; later completion and test data grants are supplied directly.

The scope table is part of interpreting every result in this note.

| Component | Executed and checked | Limitation |
| --- | --- | --- |
| Discovery and SIB1 | Unknown CFO/delay, MIB, blind DCI, transport CRC, UPER bytes | A known search band and a cropped baseband capture |
| Initial alignment | SIB1 occasion, actual PRACH, measured TA | One noiseless delayed preamble; impairment sweeps are in Uni-04 |
| RAR, Msg3 and Msg4 | Real shared channel payloads; RAR/Msg4 PDCCH and Msg4 PUCCH | Explicit control resources and one known PDCCH candidate |
| RRC establishment | Actual UPER request/setup/complete and canonical byte checks | Minimal cell group and one SRB1 header setup |
| RLC/PDCP | One complete unsegmented SRB1 payload | General retransmission, reordering and security engines absent |
| First bidirectional transfer | Two generated 256 bit payloads, CRC and exact bit checks | Test transport blocks; no user plane PDU session |
| Core network | Opaque NAS payload carried in SetupComplete | Registration, authentication and session creation not executed |

Signalling radio bearer 1 (SRB1) carries the RRC completion message. A data radio bearer (DRB) and an Internet Protocol (IP) service would require additional core and access stratum procedures. Successful test transport blocks establish the physical data path under the configured grant; they do not certify such a service.

The cell advertises 51 resource blocks (RB), equivalent to the selected 20 MHz, 30 kHz configuration. The receiver captures 28 RB around the broadcast and uses a 24 RB initial bandwidth part (BWP) for later stages. SIB1 places the downlink BWP at common RB 4 and the uplink BWP at common RB 0; the carrier and control configurations preserve those different origins. The run stores separate scheduled control and data bursts. It does not concatenate a continuous wideband radio capture across the complete procedure.

## 3. Protocol parameters and the access calendar

**Stage — 3GPP protocol.**

Section 2 fixed the cell. This section turns the recovered broadcast into a calendar: when to send the preamble, how to read the response, and where Msg3 goes.

Decoded SIB1 and the recovered SFN determine the next PRACH occasion. The RAR fields then supply the grant for Msg3; TA, RIV and k2 are interpreted using TS 38.213 and TS 38.214.

### 3.1 Recover the common cell configuration

The first step recovers the common configuration from the broadcast.

The baseline broadcast has physical cell identity 321, system frame number (SFN) 426 and SSB index zero. The channel adds 19 samples of delay, 3400 Hz carrier frequency offset (CFO) and 20 dB signal to noise ratio (SNR) per resource element. The receiver recovers MIB, uses control resource set zero (CORESET0) and decodes SIB1. The resulting transport block contains 528 bits; its first 50 bytes form the canonical UPER SIB1 message.

The broadcast generator places synchronization and scheduled system information in the same captured grid. Inspect their separate occupied regions below: acquisition supplies the cell context used to search the later control candidates.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Broadcast Resource Capture v1.png]]

*MATLAB grid of the two captured 30 kHz slots, 336 subcarriers by 28 symbols: the SS/PBCH block in the first slot and the scheduled CORESET0 control plus SIB1 data burst in the second. The displayed extent is the numerical observation window around the broadcast, 28 of the cell's 51 resource blocks.*

The receiver attempts control decoding in the monitoring slots identified from MIB. The rejected candidates and accepted system information candidate below show where that search obtains the grant needed to recover the broadcast payload.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Broadcast Candidate Acceptance v1.png]]

*MATLAB result: the DCI CRC outcome of every blind control attempt in the two monitoring slots. Candidates in the empty first slot are rejected; the first slot-1 candidate masked with SI-RNTI 65535 passes, exactly as in the Uni-03 receiver this stage reuses.*

PDSCH decoding supplies the byte sequence below to the ASN.1 decoder. The plotted values document the recovered payload; canonical UPER validation gives those bytes their field meanings before the access configuration is used.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Decoded SIB1 Byte Values v1.png]]

*MATLAB result: the fifty bytes recovered from the SIB1 PDSCH transport block, plotted by value. The ASN.1 codec verifies their canonical UPER encoding of BCCH-DL-SCH-Message before the PRACH configuration inside them is used for access.*

Parsing that validated message produces the common configuration in the table. Its BWP origins, TDD directions and PRACH calendar constrain the later resource and timing calculations.

| Decoded parameter | Value | Engineering use |
| --- | --- | --- |
| Band and data spacing | n78; 30 kHz | FR1 time division duplexing (TDD) cell |
| Initial uplink BWP | 24 RB, starting RB 0 | Msg3 resource interpretation |
| Initial downlink BWP | 24 RB, starting common RB 4 | PDCCH and PDSCH frequency origin |
| TDD pattern | 5 ms: 4 DL slots, 1 flexible, 5 UL | Check every scheduled direction |
| PRACH configuration | Index 0, long length 839, root index 22 | Actual occasion and sequence generation |
| PRACH frequency allocation | One occasion in frequency; start 0 | Selected preamble placement |
| Zero correlation zone | Index 0 | Preamble cyclic shift configuration |
| Response window | 20 slots | 10 ms at 30 kHz data spacing |
| Contention resolution timer | 64 subframes | 64 ms after Msg3 completion in the state setup |

### 3.2 Find the next occasion from the recovered SFN

Section 3.1 recovered the frame number. This section uses it to find the next valid PRACH occasion.

!important[A PRACH configuration index encodes a calendar. For the selected FR1 TDD index zero, the long preamble occurs in subframe 9 of frames satisfying the specified 16 frame periodicity and offset. MATLAB reports an active `NPRACHSlot=19` when its calendar begins at SFN zero. Reusing that relative number after decoding SFN 426 would create an invalid occasion.]

The implementation searches absolute one millisecond PRACH slots starting after the recovered frame. The first valid one is 4339, corresponding to SFN 433, subframe 9, or 79 ms after the start of SFN 426. The code asserts this relationship. [TS 38.211 V18.9.0, §6.3.3.2, Table 6.3.3.2-3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip).

At the valid occasion, the transmitter generates the long preamble and the channel delays its arrival. The waveform below uses a local time axis for that burst; its displacement supplies the timing detector input after the absolute calendar has selected when to listen.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - PRACH Arrival Waveform v1.png]]

*MATLAB result: magnitude of the actual format 0 PRACH arriving at the gNB with 321 samples of delay at 15.36 Msample/s. Plot time is local to the uplink occasion, which itself sits at absolute PRACH slot 4339, SFN 433 subframe 9, 79 ms after the decoded frame origin.*

!warning[This sparse occasion accounts for most of the selected trace's waiting time. It is a teaching configuration chosen for traceability. The 93 ms nominal completion time below is consequently not a typical NR access latency claim.]

### 3.3 Interpret the recovered RAR

Section 3.2 sent the preamble. This section reads the response: the timing advance, the grant and the temporary identity.

At 30 kHz PUSCH spacing, the numerology index is $\mu=1$. The TA step and baseline sample arithmetic are

$$
\begin{aligned}
T_c&=(480000\times4096)^{-1}\ \mathrm{s},\\
\Delta T_{\mathrm{TA}}&=16\times64T_c/2^\mu=0.2604167\ \mu\mathrm{s},\\
T_A&=\operatorname{round}(321/4)=80,\\
d_{\mathrm{physical}}&=321-320=1\ \text{sample}.
\end{aligned}
$$

Here $T_c$ is the basic NR time unit, $\Delta T_{\mathrm{TA}}$ is one absolute command step, $\mu$ is the first uplink data numerology, $T_A$ is the command index, and $d_{\mathrm{physical}}$ is the actual residual arrival delay. The sample rate is 15.36 million samples/s, so one command step is four samples. This preamble's noiseless detector returns the true injected delay. A noisy estimate would require separate predicted and physical residuals, as demonstrated in Uni-04. [TS 38.213 V18.8.0, §4.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

The sample accounting plot compares the measured arrival delay with the advance represented by the quantized command. The residual is the timing error carried into the later uplink waveforms and their fixed receive windows.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Timing Advance Sample Accounting v1.png]]

*MATLAB result: the measured delay of 321 samples, the commanded advance of 320 samples from T_A = round(321/4) = 80 at four samples per step, and the one-sample physical residual at the integrated experiment's sample rate. The step follows TS 38.213 §4.2 at μ = 1.*

The RAR setup has a one byte subheader and a seven byte payload. Its random access preamble identifier (RAPID) must match the selected preamble. The temporary cell radio network temporary identifier (TC-RNTI) is 4660, and the encoded Msg3 allocation uses a resource indication value (RIV) of 264.

| RAR field | Width | Value | Interpretation |
| --- | --- | --- | --- |
| E / T / RAPID | 1 / 1 / 6 bits | 0 / 1 / 0 | One response for preamble zero |
| Reserved / TA | 1 / 12 bits | 0 / 80 | Initial timing advance |
| Uplink grant | 27 bits | Serialized subfields | Hopping, frequency, time, MCS, TPC and CSI request |
| TC-RNTI | 16 bits | 4660 | Identity for the first scheduled uplink |

The modulation and coding scheme (MCS) index is four. The transmit power control (TPC) field is three and the channel state information (CSI) request bit is zero. In this laboratory, SNR is externally set; the TPC bits are parsed as message evidence rather than used to reproduce the full power loop from Uni-06. [TS 38.321 V18.10.0, §6.2.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); [TS 38.213 V18.8.0, §§8.2–8.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

### 3.4 Turn the grant into Msg3 coordinates

Section 3.3 gave the grant fields. This section turns them into the slot and resource blocks of Msg3.

For the short allocation branch used here,

$$
\mathrm{RIV}=N_{\mathrm{BWP}}(L-1)+\mathrm{RB}_{\mathrm{start}}
=24(12-1)+0=264.
$$

Here $N_{\mathrm{BWP}}=24$ is BWP size in resource blocks, $L=12$ is allocation length, $\mathrm{RB}_{\mathrm{start}}=0$ is its first RB relative to that BWP, and RIV is the dimensionless encoded allocation. This branch applies when $L-1\le\lfloor N_{\mathrm{BWP}}/2\rfloor$. The RAR's frequency field is truncated to the applicable nine least significant bits for this BWP. [TS 38.214 V18.10.0, §6.1.2.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip); [TS 38.213 V18.8.0, §8.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

The time domain field selects default allocation A, row one: mapping type A, first symbol zero and length 14. At 30 kHz, Tables 6.1.2.1.1-4 and -5 give $k_2=1$ and $\Delta=3$ slots. With zero cell timing offset,

$$
n_{\mathrm{Msg3}}=n+k_2+\Delta=161+1+3=165.
$$

Here $n$ is the slot containing the received RAR, $k_2$ is its selected PUSCH scheduling offset, $\Delta$ is the additional random access offset, and $n_{\mathrm{Msg3}}$ is the scheduled uplink slot. All indices refer to the same 30 kHz calendar relative to the broadcast frame origin. Slot 165 is an uplink slot in the decoded TDD pattern. [TS 38.213 V18.8.0, §8.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip); [TS 38.214 V18.10.0, §6.1.2.1.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip).

## 4. Actual message and waveform sequence

**Stage — MATLAB experiment.**

Section 3 computed the calendar. This section runs it: every message and waveform in order, with its resource map, samples, symbols and decoder input.

Each stage below presents a resource map, received samples, equalized symbols and decoder reliability. The map identifies data and demodulation reference signals (DM-RS). The minimum mean square error (MMSE) equalizer estimates the channel from received DM-RS. Log likelihood ratios (LLR) carry reliability into low density parity check (LDPC) decoding; the cyclic redundancy check (CRC) then tests the recovered transport block. The 20 dB baseline produces zero bit errors at all six stages.

### 4.1 Receive the random access response

The first waveform is the response from the base station.

The downlink shared channel (DL-SCH) carries the serialized response. Its recovered RAPID selects the UE's response and the parsed TA/grant fields configure the next uplink.

The original RA-RNTI rule identifies the control response associated with this PRACH occasion.

External source: [5.1.3](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.321 V18.10.0, §5.1.3](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf#page=42), printed page 41. The RA-RNTI depends on the PRACH occasion symbol, slot, frequency and uplink carrier indices. The PRACH numerology determines the slot index. The index definitions continue in the linked official PDF.*

Before recovering that payload, `uni08_control("RAR", ...)` generates and decodes a DCI format 1_0 waveform. Its CRC is addressed by the random access RNTI (RA-RNTI). For this long preamble the PRACH timing convention uses $\mu=0$: the first occasion is in slot $t_{\mathrm{id}}=9$, symbol $s_{\mathrm{id}}=0$, frequency occasion $f_{\mathrm{id}}=0$, and normal uplink carrier $\mathrm{ul\_carrier\_id}=0$. Thus

$$
\mathrm{RA\text{-}RNTI}=1+s_{\mathrm{id}}+14t_{\mathrm{id}}+14\times80f_{\mathrm{id}}+14\times80\times8\mathrm{ul\_carrier\_id}=127.
$$

The indices describe the PRACH occasion, and RA-RNTI is dimensionless. The 30 kHz spacing used later for Msg3 does not change the long preamble's timing convention. [TS 38.211 V18.9.0, §5.3.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip); [TS 38.321 V18.10.0, §5.1.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).

The control table separates the explicitly configured search resources from the decoded grant fields. This distinction limits what the following successful control reception establishes about broadcast configuration.

| Control setting | Recovered or configured value | Implementation check |
| --- | --- | --- |
| CRC identity | RA-RNTI 127 | `nrDCIDecode` CRC mask equals zero |
| DCI payload | 37 bits, format 1_0 for RA-RNTI | RIV 264, time index 0, MCS 4, scaling 0 |
| CORESET and candidate | 24 RB, two symbols, aggregation level 4 | One known candidate, eight available CCEs |
| DL origin | Common RB 4 | Both carrier and PDCCH BWP start at 4 |

The control receiver first checks the configured PDCCH candidate. Its resource occupancy and equalized symbols below lead to a passing control CRC and a recovered grant, which selects the response data allocation.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - RAR Control Decode v1.png]]

*MATLAB result: resource occupancy of the RAR PDCCH in the 24 RB CORESET and its equalized control symbols. The DCI format 1_0 masked with RA-RNTI 127 passes its CRC and yields RIV 264, time index 0 and MCS 4; the search space is an explicit experimental input because the SIB1 setup does not signal it.*

Mapping the response under that grant produces the RAR data grid. The occupied subcarriers and DM-RS positions identify the samples that the UE must extract within the initial downlink BWP.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 01 Resource Grid v1.png]]

*MATLAB result: the RAR PDSCH allocation in the initial downlink BWP with its DM-RS positions, the twelve resource blocks and fourteen symbols selected by the decoded grant.*

The received envelope places this data burst at its supplied slot origin. Its empty opening symbols reflect the selected allocation, so they should be interpreted as resource occupancy rather than failed reception.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 01 Received Waveform v1.png]]

*MATLAB result: received RAR samples at the supplied scheduled origin in slot 161. The empty opening symbols are the control region left free by the selected PDSCH allocation.*

After DM-RS estimation and MMSE equalization, compare the RAR symbols with the transmitted constellation crosses. The compact clusters are consistent with the successful block decode that supplies the response fields.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 01 Equalized Symbols v1.png]]

*MATLAB result: RAR data symbols after DM-RS estimation and MMSE equalization at 20 dB, with crosses at the transmitted QPSK values. Tight clusters give a passing DL-SCH CRC and the parsed RAPID, timing advance and grant.*

Soft demodulation converts those symbol positions into the bit preferences and confidence magnitudes below. LDPC decoding consumes this information before CRC acceptance and response parsing permit the UE to apply the grant and timing command.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 01 Decoder Reliability v1.png]]

*MATLAB result: the first 160 coded-bit log likelihood ratios of the RAR before LDPC decoding. Sign gives the bit preference and magnitude the confidence; the decoder consumes both.*

### 4.2 Decode Msg3 and retain the contention identity

Section 4.1 received the response. This section sends Msg3 and keeps the identity that contention resolution will echo.

RRCSetupRequest is a real 48 bit common control channel (CCCH) message encoded with UPER. The setup uses a 39 bit random UE identity and establishment cause `mo-Signalling`. An uplink MAC subheader with logical channel identifier (LCID) 52 announces the 48 bit CCCH payload for this ordinary UE. The six CCCH bytes are `10 24 68 ac f1 26` in hexadecimal. [TS 38.331 V18.10.0, §6.2.2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip); [TS 38.321 V18.10.0, §6.2.1, Table 6.2.1-2](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).

The recovered RAR allocation now controls the Msg3 transmit grid. Inspect its uplink resource origin and reference signal occupancy as the first check that decoded response fields have reached the waveform configuration.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 02 Resource Grid v1.png]]

*MATLAB result: the Msg3 PUSCH generated from the recovered twelve RB grant in the uplink BWP starting at common RB 0, with its DM-RS positions.*

Applying the timing command shifts the arriving Msg3 burst into the fixed gNB receive window. The received waveform tests the command's physical consequence with the remaining quantization residual retained.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 02 Received Waveform v1.png]]

*MATLAB result: the Msg3 waveform arriving at the gNB after the UE applied the 320-sample timing advance, leaving one sample of physical residual inside the receiver's fixed window.*

The gNB then estimates and equalizes Msg3 using its own received DM-RS. The constellation and passing decoder result establish payload recovery after the grant and timing calculations have both been applied.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 02 Equalized Symbols v1.png]]

*MATLAB result: Msg3 symbols equalized with the practical DM-RS estimate and descrambled with TC-RNTI 4660. The UL-SCH CRC passes and the 48 CCCH bits of RRCSetupRequest recover exactly.*

The Msg3 LLR trace records the soft input from which the uplink decoder recovers the request. Exact CCCH byte recovery supplies the identity for the later contention comparison; CRC success alone would not document which request was recovered.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 02 Decoder Reliability v1.png]]

*MATLAB result: Msg3 soft values entering the UL-SCH decoder. The decoded six CCCH bytes 10 24 68 ac f1 26 become the contention identity the UE compares against Msg4's echo.*

!important[The contention identity is the first 48 bits of the transmitted CCCH service data unit (SDU). It includes message encoding around the random identity, so copying only the 39 bit random value would compare the wrong object. [TS 38.321 V18.10.0, §§5.1.5, 6.1.3.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip).]

### 4.3 Receive Msg4 and configure SRB1

Section 4.2 sent the request. This section receives Msg4, resolves contention and installs the first bearer.

The gNB constructs a downlink MAC protocol data unit (PDU) with LCID 62 for the contention identity, followed by a CCCH RRCSetup message. The UE compares the echoed six bytes with its own request. RRCSetup transaction identifier one then installs the minimal cell group and SRB1 setup. The ASN.1 decoder checks recovered bytes, including the nested master cell group encoding.

The gNB carries the echoed identity and setup message in the Msg4 downlink allocation below. Its placement in a permitted downlink slot is checked before the message is transmitted.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 03 Resource Grid v1.png]]

*MATLAB result: the Msg4 PDSCH allocation carrying the contention resolution identity and the RRCSetup message in slot 170, a downlink slot in the decoded TDD pattern.*

The received Msg4 envelope documents the scheduled burst after that direction check. This view verifies the waveform presented to the UE receiver; identity and setup acceptance require decoding its contents.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 03 Received Waveform v1.png]]

*MATLAB result: received Msg4 samples in slot 170. The scheduled slot direction is checked against the 5 ms TDD pattern before the receiver runs.*

Practical equalization gives the Msg4 constellation below. The subsequent CRC and byte comparisons connect these received symbols to the echoed request and the RRCSetup message that changes UE state.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 03 Equalized Symbols v1.png]]

*MATLAB result: Msg4 data symbols after practical equalization, followed by a passing transport CRC and an exact byte comparison of the echoed identity and the RRCSetup encoding.*

Msg4 decoding starts with fresh soft input and decoder state. The reliability trace belongs to this downlink block; no soft information from the earlier uplink request is combined with it.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 03 Decoder Reliability v1.png]]

*MATLAB result: Msg4 coded-bit reliability, computed with fresh decoder state independent of Msg3, because each transport block has its own HARQ process.*

A matching identity resolves the ordinary contention branch exercised here. The UE enters RRC_CONNECTED upon the applicable RRCSetup processing and prepares RRCSetupComplete. The gNB's receipt of completion is a later observable event. [TS 38.321 V18.10.0, §5.1.5](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip); [TS 38.331 V18.10.0, §5.3.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip).

Msg4's DCI format 1_0 uses TC-RNTI 4660. Its 37 recovered bits select RIV 264, MCS 4, redundancy version zero and feedback timing field four. With the default feedback mapping, this field gives $k_1=5$ slots, so a Msg4 in slot 170 receives feedback in slot $170+5=175$. Here $k_1$ is the dimensionless count of slots between the PDSCH and its HARQ feedback. [TS 38.212 V18.8.0, §7.3.1.2.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip); [TS 38.213 V18.8.0, §9.2.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

The control decode recorded below precedes that data reception and supplies its feedback timing. Compare the recovered timing field with the slot calculation to connect successful Msg4 decoding to the scheduled acknowledgement.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - MSG4 Control Decode v1.png]]

*MATLAB result: the Msg4 PDCCH decoded with TC-RNTI 4660 before the data burst, giving RIV 264, MCS 4, RV 0 and feedback timing field 4. That field maps to k1 = 5 slots, so the ACK for slot 170 is due in slot 175.*

The common PUCCH resource is configured as index zero. With first CCE zero, eight CCEs and resource indicator zero, the selected format zero resource occupies symbols 12–13 and hops from uplink PRB 0 to PRB 23. `nrPUCCH` creates the ACK waveform and `nrPUCCHDecode` recovers its bit. Separate tests also exercise NACK and absent feedback. These tests use aligned AWGN reception and an explicitly configured common resource. [TS 38.213 V18.8.0, §9.2.1, Table 9.2.1-1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip).

The feedback grid makes the configured PUCCH hop visible across the uplink BWP. Recovery of the ACK from this resource closes the physical feedback step, while the separate NACK and absent feedback tests check other receiver outcomes.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Msg4 Feedback Resource Grid v1.png]]

*MATLAB result: the PUCCH format 0 resource in slot 175, symbols 12 and 13, hopping from uplink PRB 0 to PRB 23 under common resource index 0 of TS 38.213 Table 9.2.1-1. nrPUCCHDecode recovers the ACK bit; NACK and absent feedback are tested separately.*

### 4.4 Deliver RRCSetupComplete

Section 4.3 established the connection. This section delivers the completion message over that bearer.

The completion message echoes transaction identifier one and selects public land mobile network (PLMN) identity one. Its dedicated NAS field contains a declared opaque teaching string. A single unsegmented SRB1 setup supplies a PDCP sequence number zero, four zero integrity placeholder octets before security activation, and an acknowledged mode (AM) RLC header with sequence number zero. General bearer operation is outside this setup.

The completion setup is mapped onto the supplied PUSCH grant below. The gNB receives this allocation after the UE has already processed setup, so the resource check belongs to a later event in the connection sequence.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 04 Resource Grid v1.png]]

*MATLAB result: the PUSCH allocation in slot 176 carrying the SRB1 setup with RRCSetupComplete, one unsegmented RLC AM PDU with PDCP sequence number 0.*

The completion waveform retains the advance derived from PRACH. Its arrival tests continued use of that timing value when carrying the bearer setup in a later uplink slot.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 04 Received Waveform v1.png]]

*MATLAB result: the received completion waveform with the maintained one-sample timing residual, the same advance measured at PRACH still applied.*

The equalized completion symbols provide the gNB decoder input. A passing transport CRC permits the receiver to inspect the completion message; acceptance still requires the transaction identifier to match.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 04 Equalized Symbols v1.png]]

*MATLAB result: completion symbols after MMSE equalization. The UL-SCH CRC must pass before the gNB accepts the completion event and compares the transaction identifier.*

The soft values below precede transport decoding and header removal. Recovering canonical completion bytes after those operations verifies the declared bearer setup and its message handling within the implemented subset.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 04 Decoder Reliability v1.png]]

*MATLAB result: soft values of the completion block. After decoding, the script strips the MAC, RLC and PDCP headers and decodes the actual UPER RRCSetupComplete with pycrate.*

The codec records canonical byte equality for all three RRC messages. Its pycrate 0.8.1 schema is an implementation dependency; that version is recorded separately from TS 38.331 V18.10.0. These base message tests do not establish compatibility for every Release 18 extension.

### 4.5 Check the first bidirectional transport blocks

Section 4.4 completed setup. This section checks the first test block in each direction.

After the gNB has accepted completion, the laboratory generates one 256 bit test payload in each direction. The received payloads must equal the corresponding generated bit vectors. These tests exercise the transport path using the established identity; they make no DRB or application service claim.

The first downlink test uses the supplied allocation after completion acceptance. Its grid verifies where the generated payload and reference symbols enter the established physical data path.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 05 Resource Grid v1.png]]

*MATLAB result: the PDSCH allocation of the first downlink test block in slot 180, granted after the gNB accepted RRCSetupComplete.*

The downlink envelope records the received burst at the chosen test slot. Its time belongs to the nominal access calendar and does not measure software execution latency.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 05 Received Waveform v1.png]]

*MATLAB result: received downlink test samples at slot 180, 90 ms after the broadcast frame origin in the nominal calendar.*

Equalization produces the test constellation below before payload decoding. Exact comparison with the generated bit vector establishes successful downlink transfer under this grant in addition to the CRC result.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 05 Equalized Symbols v1.png]]

*MATLAB result: downlink test symbols after equalization; all 256 meaningful payload bits recover correctly and the CRC passes, establishing the downlink data path under the configured grant.*

The downlink reliability trace covers coded bits of the allocated transport block, which also contains padding. The meaningful payload comparison therefore remains separate from the amount of capacity the grant provides.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 05 Decoder Reliability v1.png]]

*MATLAB result: downlink test block soft values before DL-SCH decoding, in a 984-bit transport block whose unused capacity is filled with padding.*

The uplink uses the maintained TA and the next selected uplink slot. Its resource grid below checks the corresponding allocation in the uplink BWP before testing the reverse data path.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 06 Resource Grid v1.png]]

*MATLAB result: the PUSCH allocation of the first uplink test block in slot 185, the next selected uplink slot of the TDD pattern.*

The final uplink waveform reaches the fixed receive window with the retained timing residual. It checks the same timing command over the full sequence of scheduled uplink transmissions.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 06 Received Waveform v1.png]]

*MATLAB result: received uplink test samples at slot 185 with the maintained one-sample residual, 92.5 ms after the frame origin.*

The equalized uplink symbols lead to a second exact payload comparison, now at the gNB. Successful recovery in both directions establishes the configured transport paths after the recorded RRC completion event.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 06 Equalized Symbols v1.png]]

*MATLAB result: uplink test symbols after equalization; all 256 meaningful payload bits recover correctly, completing the first bidirectional transfer.*

The final LLR trace comes from a fresh uplink decoder input. Together, the test constellations, soft values and exact bit checks document independent transport recovery in each direction within the declared access subset.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Stage 06 Decoder Reliability v1.png]]

*MATLAB result: uplink test block soft values before UL-SCH decoding, with fresh decoder state, in an 1128-bit transport block.*

The size comparison below shows why the transport blocks contain more bits than the message payloads alone. The selected grant determines capacity. A padding subheader and padding fill unused space in the message setups.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Message and Transport Sizes v1.png]]

*MATLAB result: message payload length beside transport block size for each stage. Downlink stages use 984-bit blocks and uplink stages 1128-bit blocks under the selected grants; a padding subheader fills the difference, because the grant decides capacity.*

## 5. Validation, failures and engineering choices

**Stage — Measured results.**

Section 4 showed the sequence working. This section validates it: the calendar, injected failures, transport reliability, and how to reproduce the run.

### 5.1 Read the event trace in one calendar

The first check places every event on one calendar.

The calendar plot places all scheduled events after the valid 79 ms PRACH occasion. Comparing the official three-message RRC sequence with this experimental timeline locates establishment within the longer access procedure; empty waiting time comes from configuration and selected processing margins.


External source: [5.3.3.1; Figure 5.3.3.1-1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf). The reproduced image is omitted from this distribution.

*Official protocol excerpt, © ETSI 2026. [3GPP TS 38.331 V18.10.0, §5.3.3.1; Figure 5.3.3.1-1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf#page=81), printed page 80. The official successful RRC establishment sequence is RRCSetupRequest, RRCSetup and RRCSetupComplete. The laboratory implements the documented message subset and configured transport resources.*


![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Scheduled Access Event Times v1.png]]

*MATLAB result: the scheduled slot of each event after the valid PRACH occasion: RAR 161, Msg3 165, Msg4 170, feedback 175, completion 176 and test blocks 180 and 185. These nominal times come from configuration and processing margins; they are neither software nor UE latencies.*


The event table pairs each scheduled slot with the receiver or message check that permits the next action. It distinguishes UE setup processing, physical acknowledgement and the later gNB completion event.

| Stage | Slot | Nominal time | Baseline check |
| --- | --- | --- | --- |
| RAR | 161 | 80.5 ms | CRC passes; RAPID and grant parse |
| Msg3 request | 165 | 82.5 ms | 48 CCCH bits recover exactly |
| Msg4 setup | 170 | 85 ms | Contention identity and RRCSetup recover |
| Msg4 feedback | 175 | 87.5 ms | PUCCH ACK recovered |
| Completion | 176 | 88 ms | UPER completion and transaction match |
| First DL block | 180 | 90 ms | 256/256 meaningful bits correct |
| First UL block | 185 | 92.5 ms | 256/256 meaningful bits correct |

### 5.2 Inject procedural failures

Section 5.1 showed the successful timeline. This section injects failures into the state machine and records what each does.

The deterministic state tests inject the conditions below into transition guards. Their result is a state outcome. Response monitoring after SIB1 is supplied by the setup; its 20 slot window is anchored to the selected first response monitoring time. A complete PDCCH implementation would derive that start from the configured search space and the end of the PRACH occasion.

| Injected condition | Required behavior | Saved terminal result |
| --- | --- | --- |
| Missing RAR | Wait for a matching response until window end | `RAR_WINDOW_EXPIRED` |
| Wrong RAPID | Do not accept another preamble's response | `RAR_WINDOW_EXPIRED` |
| Msg3 CRC failure | No decoded identity to resolve | `CONTENTION_TIMER_EXPIRED` |
| Wrong echoed identity | UE does not accept another request's identity | `CONTENTION_TIMER_EXPIRED` |
| Completion transaction mismatch | gNB does not accept that completion | `GNB_AWAITS_MATCHING_COMPLETE` |
| Completion CRC failure | gNB cannot read completion | `GNB_AWAITS_COMPLETE` |

The ordinary random access response and contention conditions follow [TS 38.321 V18.10.0, §5.1](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip). RRC establishment uses [TS 38.331 V18.10.0, §5.3.3](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip). The experiment makes no claim that failed gNB completion rolls the UE automatically back from RRC_CONNECTED; the two endpoint states are distinct.

### 5.3 Measure transport reliability after access

Section 5.2 tested states. This section measures the data path after access, with intervals.

!warning[Access success supplies a configured data path. The conditional sweep then runs 20 fresh downlink/uplink pairs at each of six SNR values, with 120 pairs overall. Each result is based on actual waveform generation, additive white Gaussian noise (AWGN), DM-RS estimation and transport decoding.]

Counting pairs in which both CRCs pass produces the probability curve below. Inspect the joint outcome and its interval as a test of the configured data path after access; earlier acquisition and message failures are outside this conditional sample.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Bidirectional Transport Probability v1.png]]

*MATLAB result: fraction of the 20 downlink/uplink pairs per SNR in which both CRCs pass, with 95% Wilson intervals, conditional on successful access. Zero failed pairs in 20 trials still leaves an upper error bound near 0.16.*

A future reliability study can sample each earlier receiver stage, apply retries, and calculate a complete access success distribution. That study would also need collisions, power ramping, response monitoring and processing deadlines. [[Uni-09-Connected-Multiuser-TDD-Cell|Uni-09]] instead starts with connected UEs to study scheduling and load; its system simulator assumptions should be interpreted independently from these waveform results.

!note[The [ShareTechnote RACH page](https://www.sharetechnote.com/html/5G/5G_RACH.html), accessed 2026-09-07, provides an engineering view of the message progression. Its discussion helps connect a field to the next receiver action. Official sizes, timers and command meanings in this note come from the frozen 3GPP documents.]

### 5.4 Reproduce the run

Section 5.3 gave the statistics. This section gives the commands and environment that reproduce them.

Open the laboratory README. MATLAB R2026a, 5G Toolbox 26.1, the existing Uni01/03/04 helpers and Uni03's pycrate 0.8.1 environment are required.

```matlab
cd('path/to/02 5G Notebook/matlab/uni08')
test_uni08
run_uni08
```

The run stores every baseline waveform and receiver array, including the `controls` structure, in `results/run.mat`. `events.csv`, `failures.csv` and `trials.csv` retain the six shared channel stages, deterministic guard tests and conditional pairs. `sib1-decoded.json` and `rrc-decoded.json` retain decoded messages. `figure-list.json` lists 35 MATLAB figures. The two original diagrams are separate explanatory assets. `test_uni08_control` checks control CRC failures, ACK, NACK and missing feedback independently of the procedural guard tests.

The baseline seed is 2026090801. Trial seeds are `base+10000+serial` with MATLAB `twister`. The run records software versions, actual elapsed execution time, and a timestamped source snapshot with SHA-256 hashes. Rerunning replaces this lab's generated result files. A bit comparison against the generated payload is always evaluated separately from the CRC outcome.

## 6. Implementation flow and remaining integration boundary

**Stage — Reproduce and references.**

Section 5 validated. This section draws the implementation flow and names what remains outside the experiment.

The implementation flow relates decoded parameters to the next waveform and the resulting state checks. The TA equation applies to the first uplink numerology; the Msg3 slot calculation must use the same absolute frame calendar as the recovered broadcast. The shorter RIV branch determines the twelve RB allocation.

![[99 Attachments/5G/Uni Labs/Uni-08/UNI-08 - Implementation Flow v2.png|Access implementation and official formulas]]

*Original implementation diagram generated with image_gen. The copyable formulas and their conditions are in §3. Step four groups Msg3 identity recovery with the later comparison against Msg4's echoed identity. Control resources are explicit, and the general bearer and core procedures remain outside this experiment.*

The saved baseline recovers SIB1, selects a valid absolute PRACH occasion, decodes RAR and Msg4 control, recovers all three UPER RRC messages, acknowledges Msg4 and transfers the first two test blocks with exact payload equality. Further integration must derive every control resource and monitoring window from broadcast configuration, combine control and data into a continuous scheduled waveform, and implement the general SRB1 bearer and later scheduling. Those additions are needed before calling this an interoperable full access stack.

## 7. References and lookup indexes

**Stage — Reproduce and references.**

Everything cited above is collected here: the sources first, then the short forms and the symbols used in this note.

### 7.1 References

The sources, in the order the note used them.

- Dahlman, E., Parkvall, S. and Sköld, J. *5G NR: The Next Generation Wireless Access Technology*, 2nd ed., Chapter 16, pp. 335–347, [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00016-7); Chapter 17, pp. 349–370, [DOI](https://doi.org/10.1016/B978-0-12-822320-8.00017-9).
- 3GPP, [TS 38.211 V18.9.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip), §§4.1,6.3.1,6.3.3,6.4.1.1,7.3,7.4.
- 3GPP, [TS 38.212 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip), §§6.2,7.1–7.3.
- 3GPP, [TS 38.213 V18.8.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip), §§4.2,8.1–8.4.
- 3GPP, [TS 38.214 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.214/38214-ia0.zip), §§6.1.2.1.1,6.1.2.2.2.
- 3GPP, [TS 38.321 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.321/38321-ia0.zip), §§5.1,6.1.3.3,6.2.1–6.2.3.
- 3GPP, [TS 38.331 V18.10.0](https://www.3gpp.org/ftp/Specs/archive/38_series/38.331/38331-ia0.zip), §§5.3.3,6.2.2,6.3.2.
- MathWorks, [NR Cell Search and MIB and SIB1 Recovery](https://www.mathworks.com/help/5g/ug/nr-cell-search-and-mib-and-sib1-recovery.html), accessed 2026-09-07. Installed R2026a helper functions underpin Uni03's broadcast implementation.
- [pycrate source and documentation](https://github.com/pycrate-org/pycrate), version 0.8.1 used for the ASN.1 codec; implementation dependency recorded separately from official specification versions.
- ShareTechnote, [5G/NR RACH](https://www.sharetechnote.com/html/5G/5G_RACH.html), accessed 2026-09-07.

- Official ETSI publications of the frozen 3GPP specifications, reproduced as focused protocol excerpts above: [TS 38.321 V18.10.0, §5.1.3](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf#page=42); [TS 38.331 V18.10.0, §5.3.3.1; Figure 5.3.3.1-1](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf#page=81). Accessed 2026-09-08.

### 7.2 Abbreviation index

The short forms used in this note, spelled out.

| Abbreviation | Full term |
| --- | --- |
| 3GPP | Third Generation Partnership Project |
| AM | Acknowledged mode |
| ASN.1 | Abstract Syntax Notation One |
| AWGN | Additive white Gaussian noise |
| BWP | Bandwidth part |
| CCCH | Common control channel |
| CFO | Carrier frequency offset |
| CORESET | Control resource set |
| CRC | Cyclic redundancy check |
| CCE | Control channel element |
| CSI | Channel state information |
| DCI | Downlink control information |
| DL | Downlink |
| DL-SCH | Downlink shared channel |
| DM-RS | Demodulation reference signal |
| DRB | Data radio bearer |
| FR1 | Frequency range 1 |
| gNB | Next generation NodeB |
| IP | Internet Protocol |
| LCID | Logical channel identifier |
| LDPC | Low density parity check |
| LLR | Log likelihood ratio |
| MAC | Medium access control |
| MCS | Modulation and coding scheme |
| MIB | Master Information Block |
| MMSE | Minimum mean square error |
| NAS | Non-access stratum |
| PDCCH | Physical downlink control channel |
| PUCCH | Physical uplink control channel |
| RA-RNTI | Random access radio network temporary identifier |
| PDCP | Packet data convergence protocol |
| PDSCH | Physical downlink shared channel |
| PDU | Protocol data unit |
| PLMN | Public land mobile network |
| PRACH | Physical random access channel |
| PUSCH | Physical uplink shared channel |
| QPSK | Quadrature phase shift keying |
| RAPID | Random access preamble identifier |
| RAR | Random access response |
| RB | Resource block |
| RIV | Resource indication value |
| RLC | Radio link control |
| RRC | Radio resource control |
| SDU | Service data unit |
| SFN | System frame number |
| SIB1 | System Information Block 1 |
| SI-RNTI | System information radio network temporary identifier |
| SNR | Signal to noise ratio |
| SRB1 | Signalling radio bearer 1 |
| SSB | Synchronization signal block |
| TA | Timing advance |
| TC-RNTI | Temporary cell radio network temporary identifier |
| TDD | Time division duplexing |
| TPC | Transmit power control |
| UE | User equipment |
| UL | Uplink |
| UL-SCH | Uplink shared channel |
| UPER | Unaligned Packed Encoding Rules |

### 7.3 Mathematical and physical symbol index

The letters used in the calculations above, with their meaning and unit.

| Symbol | Meaning | Unit or condition | Origin |
| --- | --- | --- | --- |
| $T_c$ | Basic NR time unit | Seconds | 38.211 §4.1 |
| $\mu$ | First uplink numerology | One here | 30 kHz PUSCH |
| $\Delta T_{\mathrm{TA}}$ | Absolute TA command step | Seconds | 38.213 §4.2 |
| $T_A$ | Timing command index | 80 in baseline | Recovered RAR |
| $d_{\mathrm{physical}}$ | Actual residual arrival delay | Samples | Channel evaluation |
| $N_{\mathrm{BWP}}$ | Initial BWP width | 24 RB | Recovered SIB1 |
| $L,\mathrm{RB}_{\mathrm{start}}$ | Allocation length and start | RB | Recovered RAR grant |
| $\mathrm{RIV}$ | Encoded frequency allocation | Dimensionless | 38.214 §6.1.2.2.2 |
| $n,n_{\mathrm{Msg3}}$ | RAR and Msg3 slot indices | Same 30 kHz calendar | Scheduling trace |
| $k_2,\Delta$ | Selected PUSCH and added access offsets | Slots | 38.214 §6.1.2.1.1 |
| $k_1$ | PDSCH to HARQ feedback offset | Five slots here | 38.213 §9.2.3 |
| $s_{\mathrm{id}},t_{\mathrm{id}}$ | First PRACH symbol and slot within the frame | Indices; long PRACH uses the §5.3.2 timing convention | 38.321 §5.1.3; 38.211 §5.3.2 |
| $f_{\mathrm{id}},\mathrm{ul\_carrier\_id}$ | PRACH frequency occasion and uplink carrier selector | Zero for both here | 38.321 §5.1.3 |
