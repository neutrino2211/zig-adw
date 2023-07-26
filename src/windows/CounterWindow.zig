const std = @import("std");
const adw = @import("adw");

pub const CounterWindow = struct {

	const Self = @This();

	const allocator: std.mem.Allocator = std.heap.page_allocator;

	var number_label: ?*adw.GtkLabel = null;
	var number: i64 = 0;

	var plus_button: ?*adw.GtkButton = null;
	var minus_button: ?*adw.GtkButton = null;
	var reset_button: ?*adw.GtkButton = null;

	var builder: ?*adw.GtkBuilder = null;

	pub fn activate() !void {
		var window: adw.Window = try adw.Window.fromUiFile(std.heap.page_allocator, "/app/data/ui/main.ui", "window");
		Self.builder = window.get_builder();

		Self.plus_button = @ptrCast([*c]adw.GtkButton, adw.gtk_builder_get_object(Self.builder, "plus"));
		Self.minus_button = @ptrCast([*c]adw.GtkButton, adw.gtk_builder_get_object(Self.builder, "minus"));
		Self.reset_button = @ptrCast([*c]adw.GtkButton, adw.gtk_builder_get_object(Self.builder, "reset"));
		Self.number_label = @ptrCast(*adw.GtkLabel, adw.gtk_builder_get_object(Self.builder, "number"));

		_ = adw.g_signal_connect_(Self.plus_button, "clicked", @ptrCast(adw.GCallback, &Self.plus_callback), null);
		_ = adw.g_signal_connect_(Self.minus_button, "clicked", @ptrCast(adw.GCallback, &Self.minus_callback), null);
		_ = adw.g_signal_connect_(Self.reset_button, "clicked", @ptrCast(adw.GCallback, &Self.reset_callback), null);

		window.present();
	}

	fn reset_callback() !void {
		Self.number = 0;

		var buf = try std.fmt.allocPrint(Self.allocator, &[_]u8{ '{', '}', 0 }, .{Self.number});
		defer Self.allocator.free(buf);

		adw.gtk_label_set_text(Self.number_label, buf.ptr);
	}

	fn plus_callback() !void {
		Self.number += 1;

		var buf = try std.fmt.allocPrint(Self.allocator, &[_]u8{ '{', '}', 0 }, .{Self.number});
		defer Self.allocator.free(buf);

		adw.gtk_label_set_text(Self.number_label, buf.ptr);
	}

	fn minus_callback() !void {
		Self.number -= 1;

		var buf = try std.fmt.allocPrint(Self.allocator, &[_]u8{ '{', '}', 0 }, .{Self.number});
		defer Self.allocator.free(buf);

		adw.gtk_label_set_text(Self.number_label, buf.ptr);
	}

};