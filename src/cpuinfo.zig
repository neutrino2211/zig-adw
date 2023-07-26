/// https://github.com/silversquirl/cpuinfo-zig/blob/main/cpuinfo.zig
const std = @import("std");
const builtin = @import("builtin");

const CpuInfo = struct {
    name: []const u8,
    count: usize,
    max_mhz: u64,

    pub fn deinit(self: CpuInfo, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
    }

    pub fn format(self: CpuInfo, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{s} ({} threads; ", .{ self.name, self.count });
        if (self.max_mhz >= 1000) {
            try writer.print("{d}GHz)", .{@intToFloat(f64, self.max_mhz) * 0.001});
        } else {
            try writer.print("{d}MHz)", .{self.max_mhz});
        }
    }
};

fn getLinux(allocator: std.mem.Allocator) !CpuInfo {
    const f = try std.fs.openFileAbsolute("/proc/cpuinfo", .{});
    defer f.close();
    const r = f.reader();

    var key_buf: [64]u8 = undefined;
    const name = while (r.readUntilDelimiter(&key_buf, ':')) |key_full| {
        const key = std.mem.trim(u8, key_full, " \t\n");
        if (' ' != try r.readByte()) { // Skip leading space
            return error.InvalidFormat;
        }

        if (std.mem.eql(u8, key, "model name")) {
            const value = try r.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096);
            break value orelse return error.InvalidFormat;
        } else {
            try r.skipUntilDelimiterOrEof('\n');
        }
    } else |err| switch (err) {
        error.EndOfStream, error.StreamTooLong => return error.InvalidFormat,
        else => |e| return e,
    };
    errdefer allocator.free(name);

    const max_khz_str = try std.fs.cwd().readFileAlloc(
        allocator,
        "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq",
        32,
    );
    defer allocator.free(max_khz_str);
    const max_khz = std.fmt.parseInt(
        u64,
        std.mem.trimRight(u8, max_khz_str, "\n"),
        10,
    ) catch return error.InvalidFormat;
    const max_mhz = (max_khz + 500) / 1000; // Rounded division to convert kHz to MHz

    return CpuInfo{
        .name = name,
        .count = try std.Thread.getCpuCount(),
        .max_mhz = max_mhz,
    };
}

