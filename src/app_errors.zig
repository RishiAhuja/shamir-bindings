const std = @import("std");

pub const AppError = error{
// CLI-related errors
InvalidArgument, TooFewArguments, TooManyArguments, InvalidUsage,

// Shamir's Secret Sharing specific errors
InvalidThreshold, SecretTooLarge, NotEnoughShares, DuplicateShareXCoordinate, AllocationFailed,

// General errors
FileSystemError, NetworkError };

pub fn printError(err: AppError, context: anytype) void {
    _ = context;
    std.debug.print("Error: {s}\n", .{@errorName(err)});
}
