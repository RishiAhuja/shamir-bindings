const std = @import("std");
const cli = @import("cli.zig");
const AppError = @import("app_errors.zig").AppError;

pub fn main() !void {
    var args_iterator = std.process.args();
    const program_name = args_iterator.next().?;

    const parsed_args = cli.parseArgs(program_name, &args_iterator) catch |err| {
        std.debug.print("Exiting due to command-line argument error.\n", .{});
        return err;
    };

    std.debug.print("Secret: {d}\n", .{parsed_args.secret});
    std.debug.print("Creating {d} shares with threshold {d}\n", .{ parsed_args.num_shares, parsed_args.threshold });
}
