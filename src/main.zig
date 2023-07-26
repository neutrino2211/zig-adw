const std = @import("std");
const adw = @import("adw");

const CounterWindow = @import("./windows/CounterWindow.zig").CounterWindow;
const FirstRunWindow = @import("./windows/FirstRunWindow.zig").FirstRunWindow;

pub fn main() !void {
    adw.adw_init();

    const app: [*c]adw.AdwApplication = adw.adw_application_new("app.neutrino2211.SimpleTodo.Dev", adw.G_APPLICATION_FLAGS_NONE);
    var fake: [*c]u8 = @ptrCast(
    	[*c]u8,
    	@constCast(&[_]u8{ 'f', 'a', 'k', 'e', 0 })
	);

    const settings: [*c]adw.GSettings = adw.g_settings_new("app.neutrino2211.SimpleTodo");
    const first_run = adw.g_settings_get_boolean(settings, "first-run");

    if (first_run != 1) {
    	_ = adw.g_signal_connect_(app, "activate", @ptrCast(adw.GCallback, &CounterWindow.activate), null);
    } else {
		_ = adw.g_signal_connect_(app, "activate", @ptrCast(adw.GCallback, &FirstRunWindow.activate), null);
    }

    _ = adw.g_application_run(@ptrCast(*adw.GApplication, app), 1, &fake);

    while (adw.g_list_model_get_n_items(adw.gtk_window_get_toplevels()) > 0) {
        _ = adw.g_main_context_iteration(null, 1);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
