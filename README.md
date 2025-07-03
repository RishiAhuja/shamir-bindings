# Shamir's Secret Sharing (SSS) in Zig

This project provides a command-line interface (CLI) tool for demonstrating Shamir's Secret Sharing algorithm implemented in Zig. It allows you to split a secret (currently a single byte) into multiple shares and then reconstruct the original secret using a specified threshold of those shares.

### What is Shamir's Secret Sharing?

Shamir's Secret Sharing is a cryptographic algorithm that allows a secret to be divided into multiple unique pieces, called "shares". The secret can only be reconstructed when a minimum number of these shares (the "threshold") are brought together. Individual shares reveal no information about the original secret.

This implementation operates over a finite field (Galois Field) of size 251.

### Features

- Split Secret: Divide a single-byte secret into a specified number of shares with a given threshold.
- Reconstruct Secret: Recover the original single-byte secret from a sufficient number of shares.

### Prerequisites
- Zig (Version 0.13.0 or later recommended)

### Building the Project
Navigate to the root directory of the project in your terminal and run:

```bash
zig build
```

This will compile the executable. You can then run it using zig run src/main.zig for development, or execute the compiled binary directly from zig-out/bin/shamir-sss (or whatever your build.zig names it).

For simplicity in these instructions, we'll use zig run src/main.zig.

## Usage

The tool supports two main commands: split and reconstruct.
### General Command Structure

```bash
zig run src/main.zig -- <command> [arguments...]
```

1. Splitting a Secret

Splits a secret byte into multiple shares.

#### Command:
```bash
zig run src/main.zig -- split <secret> <num_shares> <threshold>
```

- <secret>: The single byte secret to split (a number between 0 and 250, inclusive, due to the field size).
- <num_shares>: The total number of shares to generate.
- <threshold>: The minimum number of shares required to reconstruct the secret. Must be less than or equal to num_shares and at least 1.

#### Example:

Let's split the secret `234` into `5` shares, requiring `3` shares to reconstruct.

```bash
zig run src/main.zig -- split 234 5 3
```

#### Expected Output (shares will vary due to randomness):

```bash
--- SPLIT OPERATION ---
Secret: 234
Creating 5 shares with threshold 3

=== SHAMIR'S SECRET SHARES ===
Total shares generated: 5
Share format: (x, y) where x=participant_id, y=share_value
----------------------------------------
Share 1: (x=1, y=109)
Share 2: (x=2, y=19)
Share 3: (x=3, y=215)
Share 4: (x=4, y=195)
Share 5: (x=5, y=210)
----------------------------------------
Note: Any 5 shares can reconstruct the secret
=======================================

Split operation completed successfully.
```

2. Reconstructing a Secret

Reconstructs the original secret from a sufficient number of shares.

#### Command:

```bash
zig run src/main.zig -- reconstruct <threshold> <shares_string>
```

- <threshold>: The threshold used when the secret was split. (While not strictly used in the reconstruction logic itself, it's part of the CLI contract).
- <shares_string>: A string containing the shares to use for reconstruction.

    - Format: "x1:y1;x2:y2;x3:y3;..."
    - Each share is x:y. Shares are separated by semicolons ;.
    - You must provide at least threshold number of shares.

#### Example:

Using the shares from the previous split example, let's reconstruct the secret using the first three shares: (1, 109), (2, 19), and (3, 215).

```bash
zig run src/main.zig -- reconstruct 3 "1:109;2:19;3:215"
```
#### Expected Output:

```bash
--- RECONSTRUCT OPERATION ---
Threshold: 3
Shares Input String: "1:109;2:19;3:215"
Reconstructed Secret: 234
Reconstruct operation completed successfully.
```bash

### Technical Details

- Finite Field: The implementation uses a prime field of size FieldSize = 251. All arithmetic operations (addition, subtraction, multiplication, division, inverse) are performed modulo 251.
- Polynomials: The secret is embedded as the constant term (P(0)) of a polynomial, and random coefficients are chosen for the higher-order terms up to the degree of threshold - 1.
- Lagrange Interpolation: The reconstruction process uses Lagrange interpolation evaluated at x=0 to find the original secret.

### Future Enhancements

- Support for multi-byte secrets (e.g., strings, arbitrary byte arrays).
- More robust error handling and input validation.
- Comprehensive unit tests for all mathematical and SSS functions.
- Option to output shares to a file and read shares from a file.