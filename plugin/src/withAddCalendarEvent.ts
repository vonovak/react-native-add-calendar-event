import { ConfigPlugin, withInfoPlist } from "expo/config-plugins";

const DEFAULT_CALENDAR_PERMISSION = "Allow $(PRODUCT_NAME) to access your calendar";
const DEFAULT_CONTACTS_PERMISSION = "Allow $(PRODUCT_NAME) to access your contacts";

interface ConfigPluginProps {
    calendarPermission?: string
    contactsPermission?: string
}

const withAddCalendarEvent: ConfigPlugin<void | ConfigPluginProps> = (config, props) => {
    config = withInfoPlist(config, (config) => {
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

export default withAddCalendarEvent;
