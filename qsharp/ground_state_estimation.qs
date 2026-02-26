/// # VQE Ground State Estimation
///
/// Variational Quantum Eigensolver (VQE) ansatz circuits
/// for molecular ground state energy estimation.
///
/// Uses UCCSD (Unitary Coupled Cluster Singles and Doubles) ansatz
/// with Jordan-Wigner mapping and Hartree-Fock initial state.
///
/// Molecules (STO-3G minimal basis):
///   H₂   →  4 spin-orbitals →  4 qubits
///   LiH  → 12 spin-orbitals → 12 qubits
///   BeH₂ → 14 spin-orbitals → 14 qubits
///
/// Circuit structure:
///   1. Hartree-Fock reference state (X gates on occupied orbitals)
///   2. Single excitations  (1-body UCCSD terms)
///   3. Double excitations  (2-body UCCSD terms)
///
/// Note: In a real VQE run, theta parameters are optimized
/// classically. Here we use theta=0.1 as a representative
/// ansatz for resource estimation purposes.
///
/// To run    : ▶ Run — prints molecule info + measurement
/// To estimate: "Estimate Resources" in VS Code Web

import Std.Math.*;
import Std.Arrays.*;
import Std.Measurement.*;
import Std.Convert.*;

// ─────────────────────────────────────────────────────────────
//  Hartree-Fock state (Jordan-Wigner encoding)
//  Fills the lowest nElectrons spin-orbitals with |1⟩
// ─────────────────────────────────────────────────────────────
operation HartreeFock(qubits : Qubit[], nElectrons : Int) : Unit is Adj + Ctl {
    for i in 0..nElectrons - 1 {
        X(qubits[i]);
    }
}

// ─────────────────────────────────────────────────────────────
//  Single excitation: e^{θ(a†_p a_q - h.c.)}
//  Couples one occupied orbital p to one virtual orbital q
//  Decomposed via Givens rotation
// ─────────────────────────────────────────────────────────────
operation SingleExcitation(theta : Double, occ : Qubit, virt : Qubit) : Unit is Adj + Ctl {
    within {
        CNOT(occ, virt);
    } apply {
        Ry(2.0 * theta, occ);
    }
}

// ─────────────────────────────────────────────────────────────
//  Double excitation: e^{θ(a†_p a†_q a_r a_s - h.c.)}
//  Couples two occupied orbitals to two virtual orbitals
//  Standard 8-CNOT decomposition from Arrazola et al.
// ─────────────────────────────────────────────────────────────
operation DoubleExcitation(theta : Double,
                           occ0 : Qubit, occ1 : Qubit,
                           virt0 : Qubit, virt1 : Qubit) : Unit is Adj + Ctl {
    CNOT(occ0, occ1);
    CNOT(occ1, virt0);
    CNOT(virt0, virt1);
    Ry( theta / 8.0, virt1);
    CNOT(occ0, virt1);
    Ry(-theta / 8.0, virt1);
    CNOT(occ1, virt1);
    Ry( theta / 8.0, virt1);
    CNOT(occ0, virt1);
    Ry(-theta / 8.0, virt1);
    CNOT(virt0, virt1);
    CNOT(occ1, virt0);
    CNOT(occ0, occ1);
}

// ─────────────────────────────────────────────────────────────
//  H₂ — 4 qubits, 2 electrons (STO-3G)
//  1 double excitation (minimal UCCSD)
//  Orbitals: 0,1 = occupied  2,3 = virtual
// ─────────────────────────────────────────────────────────────
operation VQE_H2(theta : Double) : Result[] {
    use qubits = Qubit[4];

    HartreeFock(qubits, 2);
    DoubleExcitation(theta, qubits[0], qubits[1], qubits[2], qubits[3]);

    let results = MResetEachZ(qubits);

    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message("  VQE Ansatz — H₂  (4 qubits, 2 electrons)");
    Message("  Excitations: 0 singles + 1 double");
    Message($"  theta = {theta}");
    Message($"  Measurement : {results}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return results;
}

// ─────────────────────────────────────────────────────────────
//  LiH — 12 qubits, 4 electrons (STO-3G)
//  2 single excitations + 4 double excitations
//  Orbitals: 0-3 = occupied  4-11 = virtual
// ─────────────────────────────────────────────────────────────
operation VQE_LiH(theta : Double) : Result[] {
    use qubits = Qubit[12];

    HartreeFock(qubits, 4);

    // Single excitations
    SingleExcitation(theta, qubits[0], qubits[4]);
    SingleExcitation(theta, qubits[1], qubits[5]);

    // Double excitations
    DoubleExcitation(theta, qubits[0], qubits[1], qubits[4], qubits[5]);
    DoubleExcitation(theta, qubits[2], qubits[3], qubits[6], qubits[7]);
    DoubleExcitation(theta, qubits[0], qubits[2], qubits[4], qubits[6]);
    DoubleExcitation(theta, qubits[1], qubits[3], qubits[5], qubits[7]);

    let results = MResetEachZ(qubits);

    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message("  VQE Ansatz — LiH  (12 qubits, 4 electrons)");
    Message("  Excitations: 2 singles + 4 doubles");
    Message($"  theta = {theta}");
    Message($"  Measurement : {results}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return results;
}

// ─────────────────────────────────────────────────────────────
//  BeH₂ — 14 qubits, 6 electrons (STO-3G)
//  3 single excitations + 6 double excitations
//  Orbitals: 0-5 = occupied  6-13 = virtual
// ─────────────────────────────────────────────────────────────
operation VQE_BeH2(theta : Double) : Result[] {
    use qubits = Qubit[14];

    HartreeFock(qubits, 6);

    // Single excitations
    SingleExcitation(theta, qubits[0], qubits[6]);
    SingleExcitation(theta, qubits[1], qubits[7]);
    SingleExcitation(theta, qubits[2], qubits[8]);

    // Double excitations
    DoubleExcitation(theta, qubits[0], qubits[1], qubits[6],  qubits[7]);
    DoubleExcitation(theta, qubits[2], qubits[3], qubits[8],  qubits[9]);
    DoubleExcitation(theta, qubits[0], qubits[2], qubits[6],  qubits[8]);
    DoubleExcitation(theta, qubits[1], qubits[3], qubits[7],  qubits[9]);
    DoubleExcitation(theta, qubits[4], qubits[5], qubits[10], qubits[11]);
    DoubleExcitation(theta, qubits[0], qubits[4], qubits[6],  qubits[10]);

    let results = MResetEachZ(qubits);

    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message("  VQE Ansatz — BeH₂  (14 qubits, 6 electrons)");
    Message("  Excitations: 3 singles + 6 doubles");
    Message($"  theta = {theta}");
    Message($"  Measurement : {results}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return results;
}

// ─────────────────────────────────────────────────────────────
//  Entry points
//  Move @EntryPoint() to the molecule you want to run/estimate
// ─────────────────────────────────────────────────────────────

@EntryPoint()
operation RunH2() : Result[] {
    Message("Running VQE ansatz for H₂...");
    return VQE_H2(0.1);
}

// @EntryPoint()
operation RunLiH() : Result[] {
    Message("Running VQE ansatz for LiH...");
    return VQE_LiH(0.1);
}

// @EntryPoint()
operation RunBeH2() : Result[] {
    Message("Running VQE ansatz for BeH₂...");
    return VQE_BeH2(0.1);
}