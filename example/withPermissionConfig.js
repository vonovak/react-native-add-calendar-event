const { withInfoPlist, withAndroidManifest } = require("@expo/config-plugins");

/**
 * Applies the necessary configuration for react-native-permissions via expo.
 */
module.exports = (config) => {
  // iOS: Info.plist configuration
  let updatedConfig = withInfoPlist(config, (config) => {
    if (!config.ios) {
      config.ios = {};
    }
    if (!config.ios.infoPlist) {
      config.ios.infoPlist = {};
    }

    config.ios.infoPlist["NSCalendarsFullAccessUsageDescription"] =
      "Calendar test";
    config.ios.infoPlist["NSCalendarsUsageDescription"] = "Calendar test";
    config.ios.infoPlist["NSCalendarsWriteOnlyAccessUsageDescription"] =
      "Calendar test";

    return config;
  });

  // Android manifest permission configuration
  updatedConfig = withAndroidManifest(updatedConfig, async (config) => {
    const androidManifest = config.modResults;
    const permissions = androidManifest.manifest["uses-permission"] || [];

    if (
      !isPermissionAlreadyRequested(
        "android.permission.READ_CALENDAR",
        permissions
      )
    ) {
      permissions.push({
        $: {
          "android:name": "android.permission.READ_CALENDAR",
        },
      });
    }
    if (
      !isPermissionAlreadyRequested(
        "android.permission.WRITE_CALENDAR",
        permissions
      )
    ) {
      permissions.push({
        $: {
          "android:name": "android.permission.WRITE_CALENDAR",
        },
      });
    }

    androidManifest.manifest["uses-permission"] = permissions;

    return config;
  });

  return updatedConfig;
};

function isPermissionAlreadyRequested(permission, manifestPermissions) {
  return manifestPermissions.some((e) => e.$["android:name"] === permission);
}
