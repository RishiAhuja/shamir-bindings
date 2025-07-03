const std = @import("std");
const AppError = @import("app_errors.zig").AppError;

const FieldSize: u8 = 251;

fn add(a: u8, b: u8) u8 {
    return @intCast((@as(u16, a) + @as(u16, b)) % FieldSize);
}

fn sub(a: u8, b: u8) u8 {
    return @intCast((@as(u16, a) + FieldSize - @as(u16, b)) % FieldSize);
}

fn mul(a: u8, b: u8) u8 {
    return @intCast((@as(u16, a) * @as(u16, b)) % FieldSize);
}

fn inv(a: u8) u8 {
    if (a == 0) {
        return 0;
    }

    var res: u8 = 1;
    var base: u8 = a;
    var exp: u8 = FieldSize - 2; // Exponent for Fermat's Little Theorem (P-2)

    // This is the "Exponentiation by Squaring" algorithm.
    // computes base^exp % FieldSize.
    while (exp > 0) {
        if ((exp % 2) == 1) {
            res = mul(res, base);
        }
        base = mul(base, base);
        exp /= 2;
    }
    return res;
}

fn div(a: u8, b: u8) u8 {
    return mul(a, inv(b));
}

fn poly_eval(coeffs: []const u8, x: u8) u8 {
    if (coeffs.len == 0) return 0;

    var result: u8 = coeffs[coeffs.len - 1];
    var i: usize = coeffs.len - 1;

    // Iterate downwards, applying Horner's method: P(x) = a0 + x(a1 + x(a2 + ...))
    while (i > 0) {
        i -= 1;
        result = add(mul(result, x), coeffs[i]);
    }
    return result;
}

pub const Shamir = struct {
    pub const Share = struct {
        x: u8,
        y: u8,
    };

    /// Each participant will recieve (x_i, [y_0,i, y_1,i, ..., y_31,i])
    pub const ParticipantShare = struct {
        x: u8,
        y_values: []u8,

        pub fn deinit(self: ParticipantShare, allocator: std.mem.Allocator) void {
            allocator.free(self.y_values);
        }
    };

    pub fn split(secret: u8, num_shares: u8, threshold: u8, allocator: std.mem.Allocator) !std.ArrayList(Share) {
        if (threshold == 0 or num_shares == 0 or threshold > num_shares) {
            return AppError.InvalidThreshold;
        }
        if (secret >= FieldSize) {
            return AppError.SecretTooLarge;
        }

        var coeffs = std.ArrayList(u8).init(allocator);
        defer coeffs.deinit();

        try coeffs.append(secret);

        // Initialize a cryptographically secure random number generator (CSPRNG).
        var seed_buffer: [8]u8 = undefined;
        std.crypto.random.bytes(&seed_buffer);
        const seed = std.mem.readInt(u64, &seed_buffer, .little);
        var rng = std.rand.DefaultPrng.init(seed);
        var rand_val_gen = rng.random();

        for (0..(threshold - 1)) |_| {
            try coeffs.append(rand_val_gen.uintLessThan(u8, FieldSize));
        }

        var shares = std.ArrayList(Share).init(allocator);

        for (1..(num_shares + 1)) |i| {
            const x_coord: u8 = @intCast(i);
            const y_coord = poly_eval(coeffs.items, x_coord);
            try shares.append(.{ .x = x_coord, .y = y_coord });
        }
        return shares;
    }

    pub fn reconstruct(shares: []const Share) !u8 {
        if (shares.len == 0) {
            return AppError.NotEnoughShares;
        }

        var secret: u8 = 0;

        for (shares) |share_j| {
            const xj = share_j.x;
            const yj = share_j.y;

            var Lj_at_0: u8 = 1;

            // product ( (-x_m) / (x_j - x_m) ) for all m != j
            for (shares) |share_m| {
                const xm = share_m.x;
                if (xj == xm) {
                    if (share_j.y != share_m.y) {
                        return AppError.DuplicateShareXCoordinate;
                    }
                    continue;
                }

                const numerator = sub(0, xm);
                const denominator = sub(xj, xm);
                Lj_at_0 = mul(Lj_at_0, div(numerator, denominator));
            }
            secret = add(secret, mul(yj, Lj_at_0));
        }

        return secret;
    }

    pub fn printShares(shares: std.ArrayList(Share)) void {
        std.debug.print("\n=== SHAMIR'S SECRET SHARES ===\n", .{});
        std.debug.print("Total shares generated: {}\n", .{shares.items.len});
        std.debug.print("Share format: (x, y) where x=participant_id, y=share_value\n", .{});
        std.debug.print("----------------------------------------\n", .{});

        for (shares.items, 0..) |share, index| {
            std.debug.print("Share {}: (x={}, y={})\n", .{ index + 1, share.x, share.y });
        }

        std.debug.print("----------------------------------------\n", .{});
        std.debug.print("Note: Any {} shares can reconstruct the secret\n", .{shares.items.len});
        std.debug.print("=======================================\n\n", .{});
    }

    pub fn testSplit(allocator: std.mem.Allocator, secret: u8, threshold: u8, num_shares: u8) !void {
        std.debug.print("Testing Shamir's Secret Sharing...\n\n", .{});

        std.debug.print("Input Parameters:\n", .{});
        std.debug.print("- Secret: {}\n", .{secret});
        std.debug.print("- Threshold: {} (minimum shares needed to reconstruct)\n", .{threshold});
        std.debug.print("- Total shares: {}\n", .{num_shares});
        std.debug.print("- Field size: {} (prime modulus)\n\n", .{FieldSize});

        // Generate shares
        var shares = Shamir.split(secret, num_shares, threshold, allocator) catch |err| {
            std.debug.print("Error generating shares: {}\n", .{err});
            return err;
        };
        defer shares.deinit();

        // Print the generated shares
        printShares(shares);

        // Demonstrate that shares are different each time (due to random coefficients)
        std.debug.print("Generating shares again (should be different due to random coefficients):\n", .{});
        var shares2 = Shamir.split(secret, num_shares, threshold, allocator) catch |err| {
            std.debug.print("Error generating second set of shares: {}\n", .{err});
            return err;
        };
        defer shares2.deinit();

        printShares(shares2);
    }
};
