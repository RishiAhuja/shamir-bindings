const std = @import("std");
const AppError = @import("app_errors.zig").AppError;
const shamir_module = @import("shamir.zig");

/// Expected format: "x1:y1_0,y1_1,...;x2:y2_0,y2_1,...;..."
pub fn parseSharesString(shares_str: []const u8, allocator: std.mem.Allocator) !std.ArrayList(shamir_module.Shamir.ParticipantShare) {
    var participant_shares = std.ArrayList(shamir_module.Shamir.ParticipantShare).init(allocator);

    var shares_iter = std.mem.split(u8, shares_str, ";");

    while (shares_iter.next()) |share_item_str| {
        if (share_item_str.len == 0) continue;

        var x_and_y_iter = std.mem.split(u8, share_item_str, ":");

        const x_str = x_and_y_iter.next() orelse {
            std.debug.print("Error parsing shares: Missing x-coordinate in '{s}'\n", .{share_item_str});
            return AppError.InvalidArgument;
        };
        const y_values_str = x_and_y_iter.next() orelse {
            std.debug.print("Error parsing shares: Missing y-values in '{s}'\n", .{share_item_str});
            return AppError.InvalidArgument;
        };

        if (x_and_y_iter.next() != null) {
            std.debug.print("Error parsing shares: Malformed share '{s}' (too many colons)\n", .{share_item_str});
            return AppError.InvalidArgument;
        }

        const x_coord: u8 = std.fmt.parseInt(u8, x_str, 10) catch {
            std.debug.print("Error parsing shares: Invalid x-coordinate '{s}'\n", .{x_str});
            return AppError.InvalidArgument;
        };

        var y_val_iter = std.mem.split(u8, y_values_str, ",");
        var y_values_list = std.ArrayList(u8).init(allocator);
        defer y_values_list.deinit();

        while (y_val_iter.next()) |y_str| {
            if (y_str.len == 0) continue;
            const y_val: u8 = std.fmt.parseInt(u8, y_str, 10) catch {
                std.debug.print("Error parsing shares: Invalid y-value '{s}' in '{s}'\n", .{ y_str, share_item_str });
                return AppError.InvalidArgument;
            };
            try y_values_list.append(y_val);
        }

        if (y_values_list.items.len == 0) {
            std.debug.print("Error parsing shares: No y-values found for share '{s}'\n", .{share_item_str});
            return AppError.InvalidArgument;
        }

        const y_values_slice = try allocator.alloc(u8, y_values_list.items.len);
        for (y_values_list.items, 0..) |y_val, i| {
            y_values_slice[i] = y_val;
        }

        try participant_shares.append(.{
            .x = x_coord,
            .y_values = y_values_slice,
        });
    }

    if (participant_shares.items.len == 0) {
        std.debug.print("Error parsing shares: No valid shares found in input string.\n", .{});
        return AppError.NotEnoughShares;
    }

    return participant_shares;
}
