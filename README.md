# DAC Project

This project implements a **Digital to Analog Converter (DAC) interface** on an FPGA and includes a function generator-style UI to observe the output voltage.

---

## 📁 Project Structure
top.xpr -- Vivado project file (open this to run the design)

top.v -- Top-level Verilog module to upload to FPGA

Wiring Image.png -- Wiring diagram for hardware connections

Function generator UI/ -- Qt-based oscilloscope interface

---

## 🚀 Getting Started

### 1. **Open the Vivado Project**
Open the Vivado project file:

top.xpr

This loads the project with all required sources.

### 2. **Synthesize and Upload the Design**
Within Vivado:

1. Synthesize the project  
2. Implement the design  
3. Generate the bitstream  
4. Program the FPGA using `top.v` as the top module  

---

## 🔌 Hardware Setup

Wiring is shown in the included diagram:

**Wiring Image.png**

The diagram includes:

- DAC → FPGA pin connections 

Ensure wiring matches the diagram before powering the system.

---

## 📊 Function Generator UI

The folder `Function_generator_UI/` contains a Qt-based graphical interface that:

- Allows users to input the output voltage for the DAC  

### Running the UI

If using Qt Creator:

1. Open the `Function generator UI` project  
2. Build and run

---

## 🛠 Requirements

### Hardware
- FPGA development board  
- External DAC module  
- USB-UART interface  

### Software
- Vivado  
- Qt (Qt Creator recommended)

---
