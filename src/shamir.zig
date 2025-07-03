const std = @import("std");
const AppError = @import("app_errors.zig").AppError;

const FieldSize: u8 = 257;

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

fn add(a: u8, b: u8) u8 {
    return (a + b) % FieldSize;
}

fn sub(a: u8, b: u8) u8 {
    return (a + FieldSize - b) % FieldSize;
}

fn mul(a: u8, b: u8) u8 {
    return (a * b) % FieldSize;
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

const Shamir = struct {
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
        var rng = std.rand.DefaultPrng.init(std.crypto.random.bytes(8));
        var rand_val_gen = rng.random();

        for (0..(threshold - 1)) |_| {
            try coeffs.append(rand_val_gen.intRange(u8, 0, FieldSize));
        }

        var shares = std.ArrayList(Share).init(allocator);

        defer {
            if (@errorReturnTrace() != null) {
                shares.deinit();
            }
        }

        for (1..(num_shares + 1)) |i| {
            const x_coord: u8 = @intCast(i);
            const y_coord = poly_eval(coeffs.items, x_coord);
            try shares.append(.{ .x = x_coord, .y = y_coord });
        }
        return shares;
    }
};
