Copilot Instructions: Zig Shamir's Secret Sharing with WASM Bindings

Project Goal: Develop a Shamir's Secret Sharing tool implemented in Zig, which can then be used in a browser environment via WebAssembly (WASM) and Node.js bindings.

My Background:

    I have a basic understanding of Zig concepts (e.g., types, functions, comptime, error handling).

    I have never implemented a full Zig project before, especially not one involving WASM or bindings.

Instructions for Copilot:

    Go Slow and Be Detailed: Assume I am a beginner with Zig project structure and the intricacies of WASM/JavaScript interop. Break down each step into manageable parts.

    Focus on "Why" and "How": Explain why certain files or commands are needed, and how they contribute to the overall goal.

    Step-by-Step Guidance: When suggesting a task, provide clear, actionable steps.

    No Unsolicited Code Implementation (Unless Specifically Asked): For now, please focus on high-level explanations, conceptual guidance, and instructions on what to do. If I need code, I will explicitly ask for it.

    Clarify Terminology: If you use Zig-specific or WASM-specific jargon, please provide a brief explanation.

    Prioritize Learning: The primary goal is for me to understand the process, not just to get a working solution.

Project Breakdown (Areas where I'll need guidance):

    Project Setup:

        Confirming the correct zig init command.

        Understanding the initial file structure (src/root.zig, build.zig, build.zig.zon).

    Zig Core Logic (src/root.zig):

        Implementing Shamir's Secret Sharing (basic modular arithmetic, polynomial evaluation, Lagrange interpolation).

        Understanding how to handle the "secret" (e.g., as a u8 for simplicity initially).

        Considerations for random number generation in Zig.

    WASM Exporting/Bindings:

        How to mark Zig functions for export (pub export fn).

        Crucial: How memory is managed between JavaScript and WASM (e.g., the need for alloc and dealloc functions).

        Passing data types (numbers, arrays of numbers) between Zig and JavaScript.

    build.zig (The Build Script):

        Configuring the build.zig file to compile to wasm32-wasi.

        Understanding the addSharedLibrary function and its parameters.

        How to ensure the .wasm file is placed where JavaScript can find it.

    JavaScript/Node.js Interaction:

        Loading the .wasm module in JavaScript (browser context).

        Accessing the exported Zig functions from JavaScript.

        The JavaScript side of memory management (reading/writing to WebAssembly.Memory).

        Marshaling data (converting JavaScript types to Zig-compatible bytes and vice-versa).

    Testing:

        How to write and run unit tests for the Zig code.

        Basic integration testing (JavaScript calling WASM).

I'm ready to start when you are. Let's take it one step at a time!