const std = @import("std");
const AppError = @import("app_errors.zig").AppError;

pub const CommandType = enum {
    split,
    reconstruct,
};

pub const CliArgs = struct {
    command: CommandType,
    secret: ?u8 = null,
    num_shares: ?u8 = null,
    threshold: ?u8 = null,
    shares_input_str: ?[]const u8 = null,
};

pub fn parseArgs(program_name: []const u8, args_iterator: *std.process.ArgIterator) !CliArgs {
    const command_str = args_iterator.next() orelse {
        std.debug.print("Usage: {s} <command> [args...]\n", .{program_name});
        std.debug.print("Commands:\n", .{});
        std.debug.print("  split <secret> <num_shares> <threshold>\n", .{});
        std.debug.print("  reconstruct <threshold> <shares_string>\n", .{});
        return AppError.TooFewArguments;
    };

    if (std.mem.eql(u8, command_str, "split")) {
        const secret_str = args_iterator.next() orelse {
            std.debug.print("Usage: {s} split <secret> <num_shares> <threshold>\n", .{program_name});
            return AppError.TooFewArguments;
        };
        const num_shares_str = args_iterator.next() orelse {
            std.debug.print("Usage: {s} split <secret> <num_shares> <threshold>\n", .{program_name});
            return AppError.TooFewArguments;
        };
        const threshold_str = args_iterator.next() orelse {
            std.debug.print("Usage: {s} split <secret> <num_shares> <threshold>\n", .{program_name});
            return AppError.TooFewArguments;
        };

        if (args_iterator.next() != null) {
            std.debug.print("Error: Too many arguments provided for 'split' command.\n", .{});
            std.debug.print("Usage: {s} split <secret> <num_shares> <threshold>\n", .{program_name});
            return AppError.TooManyArguments;
        }

        const secret: u8 = std.fmt.parseInt(u8, secret_str, 10) catch {
            std.debug.print("Error: Invalid secret value '{s}'. Must be a number (0-250 for FieldSize 251).\n", .{secret_str});
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
            .command = .split,
            .secret = secret,
            .num_shares = num_shares,
            .threshold = threshold,
        };
    } else if (std.mem.eql(u8, command_str, "reconstruct")) {
        const threshold_str = args_iterator.next() orelse {
            std.debug.print("Usage: {s} reconstruct <threshold> <shares_string>\n", .{program_name});
            std.debug.print("Shares string format: \"x1:y1_0,y1_1,...;x2:y2_0,y2_1,...;...\"\n", .{});
            return AppError.TooFewArguments;
        };
        const shares_input_str = args_iterator.next() orelse {
            std.debug.print("Usage: {s} reconstruct <threshold> <shares_string>\n", .{program_name});
            std.debug.print("Shares string format: \"x1:y1_0,y1_1,...;x2:y2_0,y2_1,...;...\"\n", .{});
            return AppError.TooFewArguments;
        };

        if (args_iterator.next() != null) {
            std.debug.print("Error: Too many arguments provided for 'reconstruct' command.\n", .{});
            std.debug.print("Usage: {s} reconstruct <threshold> <shares_string>\n", .{program_name});
            return AppError.TooManyArguments;
        }

        const threshold: u8 = std.fmt.parseInt(u8, threshold_str, 10) catch {
            std.debug.print("Error: Invalid threshold value '{s}'. Must be a number.\n", .{threshold_str});
            return AppError.InvalidArgument;
        };

        return CliArgs{
            .command = .reconstruct,
            .threshold = threshold,
            .shares_input_str = shares_input_str,
        };
    } else {
        std.debug.print("Error: Unknown command '{s}'.\n", .{command_str});
        std.debug.print("Usage: {s} <command> [args...]\n", .{program_name});
        std.debug.print("Commands:\n", .{});
        std.debug.print("  split <secret> <num_shares> <threshold>\n", .{});
        std.debug.print("  reconstruct <threshold> <shares_string>\n", .{});
        return AppError.InvalidUsage;
    }
}
