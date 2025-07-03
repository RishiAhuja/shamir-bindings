const std = @import("std");
const AppError = @import("app_errors.zig").AppError;

const FieldSize: u8 = 257;

pub const Share = struct {
    x: u8, // The x-coordinate of the share (typically 1-based index)
    y: u8, // The y-coordinate (the value of the share)
};

/// Each participant will recieve (x_i, [y_0,i, y_1,i, ..., y_31,i])
pub const ParticipantShare = struct {
    x: u8,
    y_values: []u8,

    pub fn deinit(self: ParticipantShare, allocator: std.mem.Allocator) void {
        allocator.free(self.y_values);
    }
};

const Shamir = struct {
    pub fn split(threshold: u32, num_shares: u32) ![][]u8 {
        if (threshold > num_shares or threshold == 0 or num_shares == 0) {
            return AppError.InvalidParameters;
        }
    }
};
