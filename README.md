## Asymmetric Asyc FIFO:

This is a self taught attempt at making an Asynchronous FIFO. Decided to also make it asymmetric, because why not?

## Specifications:
This module was synthesized using Intel Quartus Lite for Cyclone V FPGA. Following are the specifications:

# Resource Utilization:
| Resource / Metric | Utilization / Value |
| :--- | :--- |
| **Top-level Entity Name** | fifo |
| **Family** | Cyclone V |
| **Device** | 5CSEMA5F31C6 |
| **Timing Models** | Final |
| **Logic utilization (in ALMs)** | 104 / 32,070 ( < 1 % ) |
| **Total registers** | 231 |
| **Total pins** | 53 / 457 ( 12 % ) |
| **Total virtual pins** | 0 |
| **Total block memory bits** | 2,368 / 4,065,280 ( < 1 % ) |
| **Total RAM Blocks** | 1 / 397 ( < 1 % ) |
| **Total DSP Blocks** | 0 / 87 ( 0 % ) |
| **Total HSSI RX PCSs** | 0 |
| **Total HSSI PMA RX Deserializers** | 0 |
| **Total HSSI TX PCSs** | 0 |
| **Total HSSI PMA TX Serializers** | 0 |
| **Total PLLs** | 0 / 6 ( 0 % ) |
| **Total DLLs** | 0 / 4 ( 0 % ) |

# Timing analysis:
| Slow 1100mV 85°C Model | | | | Slow 1100mV 0°C Model | | |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Clock Name** | **F_max** | **Restricted F_max** | | **Clock Name** | **F_max** | **Restricted F_max** |
| r_clk | 235.52 MHz | 235.52 MHz | | w_clk | 234.08 MHz | 234.08 MHz |
| w_clk | 242.13 MHz | 242.13 MHz | | r_clk | 241.84 MHz | 241.84 MHz |

## Compile and Simulate:

Two ways you can go about that. One is to use Icarus to compile and use a tool like GTKWave to see the waveforms. Verilator was used here just for linting purposes. Or make a project with any EDA tool of your choice and have fun. idk.
I initally started off with the first method. Switched to Quartus to synthesize it, and also Questa was a better simulator in the end of the day. 

## Disclosure of AI Usage:

# What AI didn't do:
* **Did not write the code.**
* **Did not make any architectural decisions.**

## What AI Did Do
* **Gave me resources** I can refer to.
* **Acted like my rubber ducky** for debugging and brainstorming.
