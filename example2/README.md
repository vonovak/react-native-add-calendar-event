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

`Podfile`

```js
def node_require(script)
  # Resolve script with node to allow for hoisting
  require Pod::Executable.execute_command('node', ['-p',
    "require.resolve(
      '#{script}',
      {paths: [process.argv[1]]},
    )", __dir__]).strip
end

node_require('react-native/scripts/react_native_pods.rb')
node_require('react-native-permissions/scripts/setup.rb')

...

target 'EventsDemo' do
  setup_permissions([
    'Calendars',
    'CalendarsWriteOnly'
  ]);
end
```

`Info.plist'

```plist
<key>NSCalendarsUsageDescription</key>
<string> YOUR DESCRIPTION HERE - why do you need this permission </string>

<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string> YOUR DESCRIPTION HERE - why do you need this permission </string>

<key>NSCalendarsFullAccessUsageDescription</key>
<string> YOUR DESCRIPTION HERE - why do you need this permission </string>
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
