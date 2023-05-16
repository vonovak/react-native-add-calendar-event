import { ConfigPlugin } from "expo/config-plugins";
interface ConfigPluginProps {
    calendarPermission?: string;
    contactsPermission?: string;
}
declare const withAddCalendarEvent: ConfigPlugin<void | ConfigPluginProps>;
export default withAddCalendarEvent;
