/// # Quantum Phase Estimation (QPE)
///
/// Estimates the phase φ of U|ψ⟩ = e^{2πiφ}|ψ⟩
///
/// U = Rz(1.0) → phase φ = 1.0 / (4π) ≈ 0.07958
///
/// Why Rz(θ) with irrational θ:
///   - U^{2^k} = Rz(2^k · θ) — never becomes identity
///   - Every counting qubit does real work → honest scaling
///   - Phase is irrational so more qubits = better approximation
///   - This is the most realistic QPE use case
///
/// Expected behavior:
///   More counting qubits → phase estimate converges closer to true value
///   Error shrinks as ~1/2^n (one extra bit of precision per qubit)
///
/// Qubit sweep:
///   Run 1 →  4 counting qubits  ( 5 total)
///   Run 2 →  6 counting qubits  ( 7 total)
///   Run 3 →  8 counting qubits  ( 9 total)
///   Run 4 → 10 counting qubits  (11 total)
///   Run 5 → 12 counting qubits  (13 total)

import Std.Math.*;
import Std.Arrays.*;
import Std.Measurement.*;
import Std.Convert.*;

// ─────────────────────────────────────────────────────────────
//  Inverse QFT
// ─────────────────────────────────────────────────────────────
operation InverseQFT(qubits : Qubit[]) : Unit is Adj + Ctl {
    let n = Length(qubits);
    for i in 0..n - 1 {
        H(qubits[i]);
        for j in i + 1..n - 1 {
            Controlled R1Frac([qubits[j]], (-1, 2^(j - i), qubits[i]));
        }
    }
    for i in 0..n / 2 - 1 {
        SWAP(qubits[i], qubits[n - 1 - i]);
    }
}

// ─────────────────────────────────────────────────────────────
//  Controlled-U^{2^k}  where U = Rz(theta)
//  Rz(theta)^{2^k} = Rz(2^k * theta)
//  This NEVER becomes identity for irrational theta
// ─────────────────────────────────────────────────────────────
operation ControlledUPow(k : Int, theta : Double,
                         control : Qubit, target : Qubit) : Unit is Adj + Ctl {
    let angle = IntAsDouble(2^k) * theta;
    Controlled Rz([control], (angle, target));
}

// ─────────────────────────────────────────────────────────────
//  Full QPE circuit
// ─────────────────────────────────────────────────────────────
operation QPE(nCounting : Int, theta : Double) : Result[] {
    use countReg   = Qubit[nCounting];
    use eigenQubit = Qubit();

    // Prepare eigenstate |1⟩ (eigenstate of Rz)
    X(eigenQubit);

    // Hadamard on counting register
    for q in countReg { H(q); }

    // Controlled-U^{2^k} — qubit k (LSB=0) gets power 2^k
    for k in 0..nCounting - 1 {
        ControlledUPow(k, theta, countReg[k], eigenQubit);
    }

    // Inverse QFT
    InverseQFT(countReg);

    // Measure
    let results = MResetEachZ(countReg);
    Reset(eigenQubit);

    return results;
}

// ─────────────────────────────────────────────────────────────
//  Phase readout: LSB-first binary fraction
// ─────────────────────────────────────────────────────────────
function ResultsToPhase(results : Result[]) : Double {
    let n = Length(results);
    mutable phase = 0.0;
    for i in 0..n - 1 {
        if results[i] == One {
            set phase += IntAsDouble(2^i) / IntAsDouble(2^n);
        }
    }
    return phase;
}

// ─────────────────────────────────────────────────────────────
//  Run QPE and print output
//  True phase = theta / (4π)  since Rz(θ)|1⟩ = e^{-iθ/2}|1⟩
//  and QPE convention is e^{2πiφ} → φ = θ/(4π)
// ─────────────────────────────────────────────────────────────
operation RunAndPrint(nCounting : Int) : Result[] {
    let theta     = 1.0;
    let truePhase = theta / (4.0 * PI());
    let results   = QPE(nCounting, theta);
    let phase     = ResultsToPhase(results);
    let error     = AbsD(phase - truePhase);

    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message($"  QPE — n={nCounting} counting qubits ({nCounting+1} total)");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message($"  Measurement results : {results}");
    Message($"  Estimated phase     : {phase}");
    Message($"  True phase          : {truePhase}");
    Message($"  Estimation error    : {error}");
    Message($"  Resolution (1/2^n)  : {1.0 / IntAsDouble(2^nCounting)}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return results;
}

// ─────────────────────────────────────────────────────────────
//  Entry points
// ─────────────────────────────────────────────────────────────

@EntryPoint()
operation Run_4counting() : Result[] {
    Message("Running QPE with 4 counting qubits...");
    return RunAndPrint(4);
}

// @EntryPoint()
operation Run_6counting() : Result[] {
    Message("Running QPE with 6 counting qubits...");
    return RunAndPrint(6);
}

// @EntryPoint()
operation Run_8counting() : Result[] {
    Message("Running QPE with 8 counting qubits...");
    return RunAndPrint(8);
}

// @EntryPoint()
operation Run_10counting() : Result[] {
    Message("Running QPE with 10 counting qubits...");
    return RunAndPrint(10);
}

// @EntryPoint()
operation Run_12counting() : Result[] {
    Message("Running QPE with 12 counting qubits...");
    return RunAndPrint(12);
}