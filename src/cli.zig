const std = @import("std");
const AppError = @import("app_errors.zig").AppError;

pub const CliArgs = struct {
    secret: u8,
    num_shares: u8,
    threshold: u8,
};

pub fn parseArgs(program_name: []const u8, args_iterator: *std.process.ArgIterator) !CliArgs {
    const secret_str = args_iterator.next() orelse {
        std.debug.print("Usage: {s} <secret> <num_shares> <threshold>\n", .{program_name});
        return AppError.TooFewArguments;
    };
    const num_shares_str = args_iterator.next() orelse {
        std.debug.print("Usage: {s} <secret> <num_shares> <threshold>\n", .{program_name});
        return AppError.TooFewArguments;
    };

    const threshold_str = args_iterator.next() orelse {
        std.debug.print("Usage: {s} <secret> <num_shares> <threshold>\n", .{program_name});
        return AppError.TooFewArguments;
    };

    if (args_iterator.next() != null) {
        std.debug.print("Error: Too many arguments provided.\n", .{});
        std.debug.print("Usage: {s} <secret> <num_shares> <threshold>\n", .{program_name});
        return AppError.TooManyArguments;
    }

    const secret: u8 = std.fmt.parseInt(u8, secret_str, 10) catch {
        std.debug.print("Error: Invalid secret value '{s}'. Must be a number.\n", .{secret_str});
        return AppError.InvalidArgument;
    };
    const num_shares: u8 = std.fmt.parseInt(u8, num_shares_str, 10) catch {
        std.debug.print("Error: Invalid number of shares '{s}'. Must be a number.\n", .{num_shares_str});
        return AppError.InvalidArgument;
    };
    const threshold: u8 = std.fmt.parseInt(u8, threshold_str, 10) catch {
        std.debug.print("Error: Invalid threshold value '{s}'. Must be a number.\n", .{threshold_str});
        return AppError.InvalidArgument;
    };

    return CliArgs{
        .secret = secret,
        .num_shares = num_shares,
        .threshold = threshold,
    };
}
