---
type: course_index
language: en
release_baseline: 18
---

# 5G Uni engineering laboratories

These nine notes turn the Star explanations into experiments. Each links the source contributions and frozen 3GPP clauses to MATLAB parameters, intermediate arrays, receiver checks and measured results. Read the experiment's assumptions before interpreting its plots.

| Note | Engineering task | Main output |
| --- | --- | --- |
| [[Uni-01-Cell-Search-Synchronization-and-MIB-Recovery\|Uni-01]] | Search and synchronize from I/Q | Cell identity, frequency, timing and MIB |
| [[Uni-02-Reference-Signals-Channel-Estimation-and-Equalization\|Uni-02]] | Generate references and recover a faded PDSCH | Channel estimates, equalized symbols and decoded bits |
| [[Uni-03-MIB-CORESET0-PDCCH-and-SIB1-Recovery\|Uni-03]] | Use MIB to locate and decode SIB1 | Blind DCI decisions and actual broadcast message bytes |
| [[Uni-04-PRACH-Timing-Advance-and-Uplink-Alignment\|Uni-04]] | Detect PRACH and align the first uplink | Timing command, residual error and PUSCH CRC |
| [[Uni-05-Transport-Blocks-LDPC-and-HARQ\|Uni-05]] | Code and retransmit transport blocks | LDPC decisions, redundancy versions and HARQ comparisons |
| [[Uni-06-PUSCH-Power-Control-and-Coverage\|Uni-06]] | Relate uplink power to coverage | Power limits and measured transport failures |
| [[Uni-07-CSI-Feedback-and-Adaptive-MIMO\|Uni-07]] | Measure CSI and adapt transmission | Precoder selection, rank and delivered bits |
| [[Uni-08-Complete-Radio-Access-and-First-Bidirectional-Transfer\|Uni-08]] | Integrate radio access and RRC establishment | Recovered messages, control feedback and first bidirectional test blocks |
| [[Uni-09-Connected-Multiuser-TDD-Cell\|Uni-09]] | Operate a connected cell under load | Throughput, delay, retransmissions and fairness |

For the access sequence, follow Uni-01 → Uni-03 → Uni-04 → Uni-08. Uni-02 and Uni-05 explain the receivers and transport processing used along that route. Uni-06 and Uni-07 introduce coverage and adaptation; Uni-09 studies their system context through a separate connected cell simulator.

## Experiment scope

Uni-08 executes a selected radio and RRC procedure using actual encoded messages and waveform decoders. Some control resources and later grants are explicitly supplied, and the bearer implementation covers the stated message subset. Its final payloads are transport tests; core registration and an IP service are outside the experiment.

Uni-09 uses the Wireless Network Toolbox abstract physical layer. Its performance observations come from actual simulator delivery events and protocol counters. It starts with connected users and must be interpreted separately from waveform reception in the other laboratories.

## Reading and reproduction

- [[5G Abbreviation Database]] contains the longer definitions; each Uni has a two column local index.
- Each note links its laboratory README under `matlab/uniXX` and its paired engineering ledger.
- MATLAB results retain configuration, random seeds, software versions, raw arrays and CSV records.
- [[Uni Engineering Delivery 2026-09-07]] records the eight newly delivered notes, figure counts, validation and limitations.
- [[Course Index]] returns to the textbook and protocol Star notes.
