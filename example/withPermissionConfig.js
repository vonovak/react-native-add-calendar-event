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
  updatedConfig = withAndroidManifest(updatedConfig, (config) => {
    if (!config.android) {
      config.android = {};
    }
    if (!config.android.permissions) {
      config.android.permissions = [];
    }
    config.android.permissions.push("android.permission.WRITE_CALENDAR");
    config.android.permissions.push("android.permission.READ_CALENDAR");

    return config;
  });

  return updatedConfig;
};
