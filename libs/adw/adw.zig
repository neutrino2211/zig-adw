pub usingnamespace @cImport({
    @cInclude("adwaita.h");
});

const c = @cImport({
    @cInclude("adwaita.h");
});

const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const BuilderError = error {
	UiLoadFailed,
};

fn toCString(str: []const u8) [*c]const u8 {
	return @ptrCast([*c]const u8, @constCast(str));
}

pub fn print_hello(_: *c.GtkWidget, _: c.gpointer) void {
    c.g_print("Hello World\n");
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

pub const Window = struct {
	const Self = @This();

	ui: []const u8,
	gtk_window: *c.GtkWindow,
	allocator: Allocator,
	window_builder: *c.GtkBuilder,

	pub fn fromUiFile(allocator: Allocator, ui_file: []const u8, window_id: []const u8) BuilderError!Self {
		const builder: ?*c.GtkBuilder = c.gtk_builder_new();
		var err: ?*c.GError = null;

		// Construct a GtkBuilder instance and load our UI description
		if (c.gtk_builder_add_from_file(builder, toCString(ui_file), &err) == 0) {
			c.g_printerr("Error loading UI: %s\n", err.?.*.message);
			c.g_clear_error(&err);
			return BuilderError.UiLoadFailed;
		}

		const window: *c.GtkWindow = @ptrCast(*c.GtkWindow, c.gtk_builder_get_object(builder, toCString(window_id)));

		return Self {
			.ui = ui_file,
			.allocator = allocator,
			.gtk_window = window,
			.window_builder = builder.?,
		};
	}

	pub fn set_title(self: *Self, title: []u8) void {
		c.gtk_window_set_title(self.gtk_window, title);
	}

	pub fn present(self: *Self) void {
		c.gtk_window_present(self.gtk_window);
	}

	pub fn get_gtk_window(self: *Self) *c.GtkWindow {
		return self.gtk_window;
	}

	pub fn get_builder(self: *Self) *c.GtkBuilder {
		return self.window_builder;
	}
};



