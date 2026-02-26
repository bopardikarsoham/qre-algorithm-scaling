/// # Hamiltonian Simulation — 1D Heisenberg XXX Chain
///
/// This version produces printed output so you can verify
/// the circuit runs correctly before switching to RE mode.
///
/// What it prints:
///   - Chain size and Trotter steps used
///   - Final measurement results of all qubits
///   - Magnetization (fraction of |1⟩ outcomes)
///
/// To verify: run with the ▶ Run button — you'll see real output.
/// To estimate resources: switch to "Estimate Resources" button.

import Std.Math.*;
import Std.Arrays.*;
import Std.Measurement.*;
import Std.Convert.*;

// ─────────────────────────────────────────────────────────────
//  e^{-i·theta·XX}
// ─────────────────────────────────────────────────────────────
operation ExpXX(theta : Double, q0 : Qubit, q1 : Qubit) : Unit is Adj + Ctl {
    within {
        H(q0); H(q1);
        CNOT(q0, q1);
    } apply {
        Rz(2.0 * theta, q1);
    }
}

// ─────────────────────────────────────────────────────────────
//  e^{-i·theta·YY}
// ─────────────────────────────────────────────────────────────
operation ExpYY(theta : Double, q0 : Qubit, q1 : Qubit) : Unit is Adj + Ctl {
    within {
        Adjoint S(q0); Adjoint S(q1);
        H(q0); H(q1);
        CNOT(q0, q1);
    } apply {
        Rz(2.0 * theta, q1);
    }
}

// ─────────────────────────────────────────────────────────────
//  e^{-i·theta·ZZ}
// ─────────────────────────────────────────────────────────────
operation ExpZZ(theta : Double, q0 : Qubit, q1 : Qubit) : Unit is Adj + Ctl {
    within {
        CNOT(q0, q1);
    } apply {
        Rz(2.0 * theta, q1);
    }
}

// ─────────────────────────────────────────────────────────────
//  One Trotter step across the full chain
// ─────────────────────────────────────────────────────────────
operation TrotterStep(qubits : Qubit[], J : Double, dt : Double) : Unit is Adj + Ctl {
    let n = Length(qubits);
    for i in 0..n - 2 {
        ExpXX(J * dt, qubits[i], qubits[i + 1]);
        ExpYY(J * dt, qubits[i], qubits[i + 1]);
        ExpZZ(J * dt, qubits[i], qubits[i + 1]);
    }
}

// ─────────────────────────────────────────────────────────────
//  Full simulation + measurement + printed summary
// ─────────────────────────────────────────────────────────────
operation HeisenbergXXX(nQubits : Int, J : Double,
                        totTime : Double, dt : Double) : Result[] {
    use qubits = Qubit[nQubits];

    let nSteps = Ceiling(totTime / dt);

    // Start in |+⟩^n so evolution is non-trivial
    for q in qubits { H(q); }

    // Trotter evolution
    for step in 1..nSteps {
        TrotterStep(qubits, J, dt);
    }

    // Measure all qubits
    let results = MResetEachZ(qubits);

    // Count |1⟩ outcomes for magnetization
    mutable ones = 0;
    for r in results {
        if r == One { set ones += 1; }
    }
    let magnetization = IntAsDouble(ones) / IntAsDouble(nQubits);

    // Print summary
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message($"  Heisenberg XXX Chain — n={nQubits} qubits");
    Message($"  Trotter steps : {nSteps}");
    Message($"  J={J}, totTime={totTime}, dt={dt}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    Message($"  Measurement results : {results}");
    Message($"  |1⟩ count           : {ones} / {nQubits}");
    Message($"  Magnetization       : {magnetization}");
    Message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return results;
}

// ─────────────────────────────────────────────────────────────
//  Entry points — one per chain size
//  Move @EntryPoint() to whichever you want to run/estimate
// ─────────────────────────────────────────────────────────────

@EntryPoint()
operation Run_4q() : Result[] {
    Message("Running 4-qubit Heisenberg XXX chain...");
    return HeisenbergXXX(4, 1.0, 5.0, 0.5);
}

// @EntryPoint()
operation Run_8q() : Result[] {
    Message("Running 8-qubit Heisenberg XXX chain...");
    return HeisenbergXXX(8, 1.0, 5.0, 0.5);
}

// @EntryPoint()
operation Run_12q() : Result[] {
    Message("Running 12-qubit Heisenberg XXX chain...");
    return HeisenbergXXX(12, 1.0, 5.0, 0.5);
}

// @EntryPoint()
operation Run_16q() : Result[] {
    Message("Running 16-qubit Heisenberg XXX chain...");
    return HeisenbergXXX(16, 1.0, 5.0, 0.5);
}

// @EntryPoint()
operation Run_20q() : Result[] {
    Message("Running 20-qubit Heisenberg XXX chain...");
    return HeisenbergXXX(20, 1.0, 5.0, 0.5);
}