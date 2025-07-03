const std = @import("std");
const cli = @import("cli.zig");
const AppError = @import("app_errors.zig").AppError;
const Shamir = @import("shamir.zig");

pub fn main() !void {
    var args_iterator = std.process.args();
    const program_name = args_iterator.next().?;

    const parsed_args = cli.parseArgs(program_name, &args_iterator) catch |err| {
        std.debug.print("Exiting due to command-line argument error.\n", .{});
        return err;
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    try Shamir.testSplit(allocator, parsed_args.secret, parsed_args.threshold, parsed_args.num_shares);
}
