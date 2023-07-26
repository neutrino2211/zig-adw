const std = @import("std");
const adw = @import("adw");

pub const FirstRunWindow = struct {
	const Self = @This();

	const allocator = std.heap.page_allocator;

	pub fn activate() !void {
		var window: adw.Window = try adw.Window.fromUiFile(Self.allocator, "/app/data/ui/first-start.ui", "window");

		window.present();
	}
};