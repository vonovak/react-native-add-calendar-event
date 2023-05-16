"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_plugins_1 = require("expo/config-plugins");
const DEFAULT_CALENDAR_PERMISSION = "Allow $(PRODUCT_NAME) to access your calendar";
const DEFAULT_CONTACTS_PERMISSION = "Allow $(PRODUCT_NAME) to access your contacts";
const withAddCalendarEvent = (config, props) => {
    config = (0, config_plugins_1.withInfoPlist)(config, (config) => {
        if (!config.modResults.NSCalendarsUsageDescription) {
            config.modResults.NSCalendarsUsageDescription = props?.calendarPermission ?? DEFAULT_CALENDAR_PERMISSION;
        }
        if (!config.modResults.NSCalendarsUsageDescription) {
            config.modResults.NSContactsUsageDescription = props?.contactsPermission ?? DEFAULT_CONTACTS_PERMISSION;
        }
        return config;
    });
    return config;
};
exports.default = withAddCalendarEvent;
