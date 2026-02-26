# Quantum Resource Estimation — Comparative Study

A systematic quantum resource estimation (QRE) study across four algorithm families using the **Microsoft Azure Quantum Resource Estimator**. Circuits are implemented in **Q#** and **Qiskit (Python)**, with resource analysis across two physical qubit models.

---

## Algorithms Studied

| Algorithm | Tool | Sizes |
|---|---|---|
| Grover's Search | Q# | 5, 10, 15, 20, 25 qubits |
| Heisenberg XXX Hamiltonian Simulation | Q# | 4, 8, 12, 16, 20 qubits |
| Quantum Phase Estimation (QPE) | Q# | 4, 6, 8, 10, 12 counting qubits |
| VQE Ground State Estimation (H₂, LiH, BeH₂) | Q# | 4, 12, 14 qubits |

---

## Key Findings

- **T-factory distillation consumes 75–98%** of all physical qubits across every algorithm studied
- **Improving physical error rate from 10⁻³ → 10⁻⁴** reduces physical qubit cost by **5–17×**
- **Logical resources are hardware-independent** — physical resources are entirely driven by QEC assumptions
- **VQE is the most resource-efficient** algorithm for near-term fault-tolerant hardware
- **Grover's search** shows the steepest resource scaling — up to 752,318 physical qubits at 25 qubits

---

## Project Structure

```
quantum-resource-estimation/
│
├── qsharp/                         # Q# circuit implementations
│   ├── Grover.qs                   # Grover search (5q–25q)
│   ├── Heisenberg.qs               # Heisenberg XXX simulation (4q–20q)
│   ├── QPE.qs                      # Quantum phase estimation (4–12 counting)
│   └── Chemistry.qs                # VQE ansatz (H₂, LiH, BeH₂)
│
├── results/                        # Azure RE output screenshots
│   ├── grover_re.png
│   ├── heisenberg_re.png
│   ├── qpe_re.png
│   └── chemistry_re.png
│
├── report/
│   └── azure_re_report.md          # Full analysis report
│
└── README.md
```

---

## Hardware Configurations

All circuits estimated under two physical qubit models using **surface code** QEC and **error budget = 0.001**:

| Parameter | qubit_gate_ns_e3 | qubit_gate_ns_e4 |
|---|---|---|
| Gate time | 1 ns | 1 ns |
| Physical error rate | 10⁻³ | 10⁻⁴ |
| QEC scheme | Surface code | Surface code |

---

## How to Run

1. Install the [QDK extension](https://marketplace.visualstudio.com/items?itemName=quantum.qsharp-lang-vscode) in VS Code
2. Open any `.qs` file in `qsharp/`
3. Move `@EntryPoint()` to the circuit size you want
4. Press `Ctrl+Shift+P` → **Q#: Calculate Resource Estimates**
5. Select `qubit_gate_ns_e3` and/or `qubit_gate_ns_e4`

No installation or Python environment required.

---

## Results Summary

### Physical Qubits Required (e3 / e4)

| Algorithm | Min | Max (e3) | Max (e4) |
|---|---|---|---|
| Grover | 19,400 | 752,318 | 77,598 |
| Heisenberg XXX | 14,470 | 1,041,210 | 105,252 |
| QPE | 22,900 | 513,084 | 76,244 |
| VQE Chemistry | 13,750 | 232,320 | 25,000 |

---

## Tools & Stack

| Component | Technology |
|---|---|
| Circuit implementation | Q# (Microsoft QDK) |
| Resource estimation | Azure Quantum Resource Estimator |
| QEC model | Surface code |
| Development environment | VS Code Web (vscode.dev/quantum) |

---

## References

- [Azure Quantum Resource Estimator](https://learn.microsoft.com/en-us/azure/quantum/intro-to-resource-estimation)
- [Microsoft QDK Documentation](https://learn.microsoft.com/en-us/azure/quantum/overview-what-is-qsharp-and-qdk)
- [Qiskit Documentation](https://docs.quantum.ibm.com/)
- Babbush et al., "Encoding Electronic Spectra in Quantum Circuits with Linear T Complexity" (2018)
- Bauer et al., "Quantum Algorithms for Quantum Chemistry and Quantum Biology" (2020)
