pub usingnamespace @cImport({
    @cInclude("adwaita.h");
});

const c = @cImport({
    @cInclude("adwaita.h");
});

pub fn toCString(str: []const u8) [*c]const u8 {
	return @ptrCast([*c]const u8, @constCast(str));
}

/// Could not get `g_signal_connect` to work. Zig says "use of undeclared identifier". Reimplemented here
pub fn g_signal_connect_(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) c.gulong {
    var zero: u32 = 0;
    const flags: *c.GConnectFlags = @ptrCast(*c.GConnectFlags, &zero);
    return c.g_signal_connect_data(instance, detailed_signal, c_handler, data, null, flags.*);
}

/// Could not get `g_signal_connect_swapped` to work. Zig says "use of undeclared identifier". Reimplemented here
pub fn g_signal_connect_swapped_(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) c.gulong {
    return c.g_signal_connect_data(instance, detailed_signal, c_handler, data, null, c.G_CONNECT_SWAPPED);
}
