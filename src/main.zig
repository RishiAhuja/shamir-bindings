const std = @import("std");
const cli = @import("cli.zig");
const AppError = @import("app_errors.zig").AppError;
const Shamir = @import("shamir.zig").Shamir;
const shares_parser = @import("shares_parser.zig");

pub fn main() !void {
    var args_iterator = std.process.args();
    const program_name = args_iterator.next().?;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parsed_args = cli.parseArgs(program_name, &args_iterator) catch |err| {
        std.debug.print("Exiting due to command-line argument error.\n", .{});
        return err;
    };

    switch (parsed_args.command) {
        .split => {
            const secret = parsed_args.secret.?;
            const num_shares = parsed_args.num_shares.?;
            const threshold = parsed_args.threshold.?;

            std.debug.print("--- SPLIT OPERATION ---\n", .{});
            std.debug.print("Secret: {d}\n", .{secret});
            std.debug.print("Creating {d} shares with threshold {d}\n", .{ num_shares, threshold });

            var shares = try Shamir.split(secret, num_shares, threshold, allocator);
            defer shares.deinit();

            Shamir.printShares(shares);

            std.debug.print("Split operation completed successfully.\n", .{});
        },
        .reconstruct => {
            const threshold = parsed_args.threshold.?;
            const shares_input_str = parsed_args.shares_input_str.?;

            std.debug.print("--- RECONSTRUCT OPERATION ---\n", .{});
            std.debug.print("Threshold: {d}\n", .{threshold});
            std.debug.print("Shares Input String: \"{s}\"\n", .{shares_input_str});

            var participant_shares = try shares_parser.parseSharesString(shares_input_str, allocator);
            defer {
                for (participant_shares.items) |ps| {
                    ps.deinit(allocator);
                }
                participant_shares.deinit();
            }

            var simple_shares = std.ArrayList(Shamir.Share).init(allocator);
            defer simple_shares.deinit();

            for (participant_shares.items) |ps| {
                if (ps.y_values.len != 1) {
                    std.debug.print("Error: Expected single y_value per share for single-byte secret reconstruction, but got {d} for x={d}.\n", .{ ps.y_values.len, ps.x });
                    return AppError.InvalidArgument;
                }
                try simple_shares.append(.{ .x = ps.x, .y = ps.y_values[0] });
            }

            const reconstructed_secret = try Shamir.reconstruct(simple_shares.items);
            std.debug.print("Reconstructed Secret: {d}\n", .{reconstructed_secret});
            std.debug.print("Reconstruct operation completed successfully.\n", .{});
        },
    }
}
