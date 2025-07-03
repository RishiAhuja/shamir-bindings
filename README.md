# Shamir's Secret Sharing in Zig with WASM Bindings

A learning project implementing Shamir's Secret Sharing algorithm in Zig, designed to be compiled to WebAssembly for use in browsers and Node.js.

## Current Implementation Status

### Completed Features

**Core Mathematical Operations:**
- Finite field arithmetic (addition, subtraction, multiplication, division, modular inverse)
- Field size: 257 (prime number for proper field properties)
- Polynomial evaluation using Horner's method

**Secret Splitting Algorithm:**
- `Shamir.split()` function that generates shares from a secret
- Cryptographically secure random coefficient generation
- Proper error handling for invalid inputs
- Memory management with Zig allocators

**Data Structures:**
- `Share` struct: Basic (x, y) coordinate pair
- `ParticipantShare` struct: Extended structure for future multi-byte secrets
- Comprehensive error definitions

### In Progress
- Secret reconstruction algorithm (Lagrange interpolation)
- Command-line interface for testing
- Unit test suite

### Planned Features
- WebAssembly compilation configuration
- JavaScript bindings and memory management
- Browser and Node.js integration examples
- Multi-byte secret support

### Key Algorithms
1. **Modular Inverse**: Uses Fermat's Little Theorem (a^(p-2) ≡ a^(-1) mod p)
2. **Polynomial Evaluation**: Horner's method for efficient computation
3. **Random Generation**: Cryptographically secure seeding with fast PRNG

## Development Setup

### Prerequisites
- Zig 0.13+ installed
- Basic understanding of command-line operations

### Current Testing
```bash
# Navigate to project directory
cd shamir-bindings

# Run the main CLI program (when implemented)
zig run src/main.zig -- <secret> <num_shares> <threshold>

# Test the core algorithm
zig run src/main.zig -- 42 5 3
```

### Project Structure
```
shamir-bindings/
├── src/
│   ├── main.zig           # CLI application entry point
│   ├── root.zig           # WASM library root (for future use)
│   ├── shamir.zig         # Core secret sharing algorithm
│   ├── cli.zig            # Command-line argument parsing
│   └── app_errors.zig     # Error definitions
├── build.zig              # Build configuration
├── build.zig.zon          # Project metadata
└── README.md
```

This project prioritizes **understanding over completion**:
- Each component is thoroughly explained before implementation
- Mathematical foundations are explored alongside code
- Memory management and security implications are carefully considered
- Step-by-step progression from simple concepts to complex integrations

---

*This is a learning project focused on understanding systems programming, cryptographic algorithms, and cross-language integration. The implementation prioritizes educational value and code clarity.*
