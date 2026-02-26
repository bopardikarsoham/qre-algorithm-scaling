
/// # Grover's Search — Resource Estimation Sweep
/// Runs Grover search across 5 qubit sizes (5, 10, 15, 20, 25)
/// to observe how physical qubits, T-count, and runtime scale.
///
/// Marked state: alternating 0s and 1s (|010...⟩)
/// To run: move @EntryPoint() to the size you want, then
///         click "Estimate Resources" in VS Code Web.

import Std.Convert.*;
import Std.Math.*;
import Std.Arrays.*;
import Std.Measurement.*;
import Std.Diagnostics.*;

// ─────────────────────────────────────────────────────────────
//  Optimal iteration count  ≈  π/4 · √(2^n)
// ─────────────────────────────────────────────────────────────
function IterationsToMarked(nQubits : Int) : Int {
    let nItems = 2.0 ^ IntAsDouble(nQubits);
    let angle  = ArcSin(1.0 / Sqrt(nItems));
    Round(0.25 * PI() / angle - 0.5)
}

// ─────────────────────────────────────────────────────────────
//  Oracle: marks the alternating state |010101...⟩
// ─────────────────────────────────────────────────────────────
operation ReflectAboutMarked(inputQubits : Qubit[]) : Unit {
    use outputQubit = Qubit();
    within {
        X(outputQubit);
        H(outputQubit);
        // Flip every other qubit to target |010101...⟩
        for q in inputQubits[...2...] {
            X(q);
        }
    } apply {
        Controlled X(inputQubits, outputQubit);
    }
}

// ─────────────────────────────────────────────────────────────
//  Standard building blocks
// ─────────────────────────────────────────────────────────────
operation PrepareUniform(qubits : Qubit[]) : Unit is Adj + Ctl {
    for q in qubits { H(q); }
}

operation ReflectAboutAllOnes(qubits : Qubit[]) : Unit {
    Controlled Z(Most(qubits), Tail(qubits));
}

operation ReflectAboutUniform(qubits : Qubit[]) : Unit {
    within {
        Adjoint PrepareUniform(qubits);
        for q in qubits { X(q); }
    } apply {
        ReflectAboutAllOnes(qubits);
    }
}

// ─────────────────────────────────────────────────────────────
//  Core Grover search (no measurement — RE doesn't need it)
// ─────────────────────────────────────────────────────────────
operation GroverSearch(nQubits : Int) : Unit {
    let nIterations = IterationsToMarked(nQubits);
    Message($"n={nQubits}  optimal iterations={nIterations}");

    use qubits = Qubit[nQubits];
    PrepareUniform(qubits);

    for _ in 1..nIterations {
        ReflectAboutMarked(qubits);
        ReflectAboutUniform(qubits);
    }

    ResetAll(qubits);
}

// ─────────────────────────────────────────────────────────────
//  Entry points — one per qubit size
//  Move @EntryPoint() to whichever you want to estimate,
//  comment out the rest, then click "Estimate Resources"
//
//  Expected optimal iterations:
//    5q  →  4
//    10q →  25
//    15q →  181
//    20q → 1448
//    25q → 11585
// ─────────────────────────────────────────────────────────────

@EntryPoint()
operation Run_5Qubits()  : Unit { GroverSearch(5);  }

// @EntryPoint()
operation Run_10Qubits() : Unit { GroverSearch(10); }

// @EntryPoint()
operation Run_15Qubits() : Unit { GroverSearch(15); }

// @EntryPoint()
operation Run_20Qubits() : Unit { GroverSearch(20); }

// @EntryPoint()
operation Run_25Qubits() : Unit { GroverSearch(25); }