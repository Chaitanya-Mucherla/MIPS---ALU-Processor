# **MIPS20 – Pipelined ALU Processor (Verilog HDL)**

This repository contains the complete Verilog HDL implementation of a **custom 5-stage pipelined MIPS processor**, designed with a **20×32 register file** instead of the standard MIPS 32×32 architecture.
The project demonstrates core concepts of processor design, pipelining, hazard management, datapath construction, and HDL-based digital system implementation.

---

## **🚀 Features**

* 5-stage pipelined architecture

  * IF → ID → EX → MEM → WB
* Custom **20×32 register file**
* Fully synthesizable Verilog modules
* ALU supporting essential arithmetic & logical operations
* Pipeline latches: IF/ID, ID/EX, EX/MEM, MEM/WB
* Instruction memory & data memory modules
* Modular and scalable codebase
* Testbenches with simulation waveforms
* Designed for educational and FPGA experimentation

---

## **📁 Project Structure**

```
│── ALU.v
│── RegisterFile_20x32.v
│── ControlUnit.v
│── InstructionMemory.v
│── DataMemory.v
│── Pipeline_IF_ID.v
│── Pipeline_ID_EX.v
│── Pipeline_EX_MEM.v
│── Pipeline_MEM_WB.v
│── Datapath.v
│── MIPS20_Top.v
│── Testbench.v
└── README.md
```

---

## **🧠 Architecture Overview**

The processor follows a classical **RISC/MIPS design philosophy** with simplified instruction flow and high-speed execution through pipelining.
Key architectural components include:

* **Program Counter (PC)**
* **Instruction Memory**
* **20×32 Register File**
* **Sign Extend Unit**
* **ALU**
* **Data Memory**
* **MUX-based control datapath**
* **Pipeline registers for stage separation**

---

## **⚙️ Implemented Instructions**

The processor supports a subset of essential MIPS instructions used for ALU operations, memory operations, and branching.

### **Arithmetic Operations**

* ADD, SUB, MUL, DIV, EXP

### **Logical Operaations**

* AND, OR, XOR

### **Comparision Operations**

* SLT, SGT

### **Immediate Operations**

* ADDI, SUBI

### **Memory Operations**

* LW, SW

### **Branch Operations**

* BEQ, BNE

---

## **✨ Pipeline Features**

* Instruction overlap using 5-stage pipeline
* Pipeline registers store intermediate results
* Stable two-phase clock (clk1 & clk2) for hazard-free operation
* Basic hazard handling (manual NOP insertion)

---

## **📈 Future Enhancements**

* Automatic hazard detection & forwarding unit
* Support for advanced instructions
* Cache memory integration
* Pipelined multiplier unit
* FPGA deployment & real-time testing

---

## **🧪 Simulation**

All modules are tested using Verilog testbenches.
Simulation waveforms verify:

* Correct instruction execution
* Pipeline timing and behavior
* Register file updates
* ALU output correctness

---

## **🔧 Tools Used**

* **Verilog HDL**
* **ModelSim / Vivado Simulator**
* **Xilinx Vivado / Intel Quartus (optional)**

---

## **📜 How to Run**

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/MIPS20-Processor.git
   ```
2. Open the project in your Verilog simulator (ModelSim/Vivado).
3. Compile all `.v` files.
4. Run **Testbench.v** to view the pipeline execution and waveforms.

---

## **📄 License**

This project is released under the **MIT License**.
Feel free to use, modify, or extend the design for academic or research purposes.

---

## **👨‍💻 Author**

**Chaitanya Mucherla**

**B.Tech** – Electronics and Communication Engineering

**Project** – *Pipelined MIPS20 – ALU Processor Design*

