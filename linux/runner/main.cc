#include "my_application.h"

static void maybe_force_x11_backend() {
  GSettingsSchemaSource* source = g_settings_schema_source_get_default();
  if (source == nullptr) {
    return;
  }
  GSettingsSchema* schema = g_settings_schema_source_lookup(
      source, "org.gnome.settings-daemon.plugins.xsettings", TRUE);
  if (schema == nullptr) {
    return;
  }
  const gboolean antialiasing_key_missing =
      !g_settings_schema_has_key(schema, "antialiasing");
  g_settings_schema_unref(schema);
  if (antialiasing_key_missing) {
    g_setenv("GDK_BACKEND", "x11", FALSE);
  }
}

int main(int argc, char** argv) {
  maybe_force_x11_backend();
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
