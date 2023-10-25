# Example app for react-native-add-calendar-event

A simple example that shows how to add, view, and edit events with this library. Permissions are handled via [react-native-permissions](https://www.npmjs.com/package/react-native-permissions)

## Quick Start

```sh

npm install

# Run in iOS
cd ../ios
bundle install
bundle exec pod install
cd ..

npm ios

# Run on Android
npm android

```

## Notable Parts

### Android Setup

You need to add the following to `android/app/src/main/AndroidManifest.xml`, in order to request calendar permissions with `react-native-permissions`.

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

### iOS Setup

Follow [these instructions](https://github.com/zoontek/react-native-permissions/tree/v4#ios), and then make sure `Calendars` and `CalendarsWriteOnly` are included in the permissions list.

```
setup_permissions([
   'Calendars',
   'CalendarsWriteOnly',
])
```

### App JS

In order to add an event to a user's calendar, you first must request permissions:

```tsx
import {Platform} from 'react-native';
import {
  request,
  PERMISSIONS,
  RESULTS,
  Permission,
} from 'react-native-permissions';
import * as AddCalendarEvent from 'react-native-add-calendar-event';

request(
  Platform.select({
    ios: PERMISSIONS.IOS.CALENDARS_WRITE_ONLY,
    android: PERMISSIONS.ANDROID.WRITE_CALENDAR,
  }) as Permission,
).then(result => {
  if (result !== RESULTS.GRANTED) {
    throw new Error(`No permission: ${result}`);
  }
  return AddCalendarEvent.presentEventCreatingDialog(eventConfig);
});
```
