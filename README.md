#### Maintenance notice

The author of this package does not use it in production and does not have free time to maintain it. There are open issues that the author does not plan to fix. PRs may or may not be accepted. If you need help or do any development on the package, you can [hire the author](https://react-native-training.eu/). You can also maintain your own fork.

# react-native-add-calendar-event

This package alows you to start an activity (Android) or show a modal window (iOS) for adding, viewing or editing events in device's calendar. Through a promise, you can find out if a new event was added and get its ID, or if it was removed. The functionality is provided through native modules and won't therefore work with Expo.

For managing calendar events without the UI for user to interact with, see [react-native-calendar-events](https://github.com/wmcmahan/react-native-calendar-events).

<img src="https://raw.githubusercontent.com/vonovak/react-native-add-calendar-event/master/images/ios.gif" width="300" hspace="60" /> <img src="https://raw.githubusercontent.com/vonovak/react-native-add-calendar-event/master/images/android.gif" width="300" />

## Getting started

`npm install react-native-add-calendar-event --save`

or

`yarn add react-native-add-calendar-event`

## Permissions

You'll also need to install and setup [react-native-permissions](https://github.com/zoontek/react-native-permissions/), or similar, to request calendar permissions for your app/

## Expo Support

This package is not available in the [Expo Go](https://expo.io/client) app. Learn how you can use it with [custom dev clients](/plugin/install.md).

## Mostly automatic installation

1. (only RN < 0.60) `react-native link react-native-add-calendar-event`

(only RN >= 0.60) run `pod install` in the ios folder

2. add `NSCalendarsWriteOnlyAccessUsageDescription` or `NSCalendarsFullAccessUsageDescription` (for edit/view access) to your `Info.plist` file. The string value associated with the key will be used when asking user for calendar permission.

3. rebuild your project

iOS note for RN < 0.60: If you use pods, `react-native link` will probably add the podspec to your podfile, in which case you need to run `pod install`. If not, please verify that the library is under `link binary with libraries` in the build settings in Xcode (see manual installation notes).

## Quick example

See the example folder for a demo app.

Using `react-native-permissions` to request calendar permission before creating a calendar event.

```js
import { Platform } from 'react-native';
import * as AddCalendarEvent from 'react-native-add-calendar-event';
import * as Permissions from 'react-native-permissions';


const eventConfig = {
  title,
  // and other options
};

Permissions.request(
  Platform.select({
    ios: Permissions.PERMISSIONS.IOS.CALENDARS_WRITE_ONLY,
    android: Permissions.PERMISSIONS.ANDROID.WRITE_CALENDAR,
  })
)
  .then(result => {
    if (result !== Permissions.RESULTS.GRANTED) {
      throw new Error(`No permission: ${result}`);
    }
    return AddCalendarEvent.presentEventCreatingDialog(eventConfig)
  })
  .then((eventInfo: { calendarItemIdentifier: string, eventIdentifier: string }) => {
    // handle success - receives an object with `calendarItemIdentifier` and `eventIdentifier` keys, both of type string.
    // These are two different identifiers on iOS.
    // On Android, where they are both equal and represent the event id, also strings.
    // when { action: 'CANCELED' } is returned, the dialog was dismissed
    console.warn(JSON.stringify(eventInfo));
  })
  .catch((error: string) => {
    // handle error such as when user rejected permissions
    console.warn(error);
  });
```

### Creating an event

call `presentEventCreatingDialog(eventConfig)`

eventConfig object:

| Property         | Value   | Note                                                                |
| :--------------- | :------ | :------------------------------------------------------------------ |
| title            | String  |                                                                     |
| startDate        | String  | in UTC, format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'                          |
| endDate          | String  | in UTC, format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'                          |
| location         | String  |                                                                     |
| allDay           | boolean |                                                                     |
| url              | String  | iOS only                                                            |
| notes            | String  | The notes (iOS) or description (Android) associated with the event. |
| navigationBarIOS | Object  | config object for the navbar, see below                             |

The dates passed to this module are strings. If you use moment, you may get the right format via `momentInUTC.format('YYYY-MM-DDTHH:mm:ss.SSS[Z]')` the string may look eg. like this: `'2017-09-25T08:00:00.000Z'`.

More options can be easily added, PRs are welcome!

### Editing an event

call `presentEventEditingDialog(eventConfig)`

eventConfig object:

| Property      | Value   | Note                                 |
| :------------ | :------ | :----------------------------------- |
| eventId       | String  | Id of edited event.                  |
| useEditIntent | boolean | Android only, see description below. |

useEditIntent: `ACTION_EDIT` should work for editing events, according to [android docs](https://developer.android.com/guide/topics/providers/calendar-provider.html#intent-edit) but this doesn't always seem to be the case as reported in the [bug tracker](https://issuetracker.google.com/u/1/issues/36957942?pli=1). This option leaves the choice up to you. By default, the module will use `ACTION_VIEW` which will only show the event, but from there it is easy for the user to tap the edit button and make changes.

### Viewing an event

call `presentEventViewingDialog(eventConfig)`

eventConfig object:

| Property              | Value   | Note                                                                                                                                     |
| :-------------------- | :------ | :--------------------------------------------------------------------------------------------------------------------------------------- |
| eventId               | String  | Id of edited event.                                                                                                                      |
| allowsEditing         | boolean | iOS only; [docs](https://developer.apple.com/documentation/eventkitui/ekeventviewcontroller/1613964-allowsediting?language=objc)         |
| allowsCalendarPreview | boolean | iOS only; [docs](https://developer.apple.com/documentation/eventkitui/ekeventviewcontroller/1613956-allowscalendarpreview?language=objc) |

### Interpreting the results

The aforementioned functions all return a promise that resolves with information about what happened or rejects with an error.

Due to the differences in the underlying native apis, it is not trivial to come up with a unified interface that could be exposed to JS and the module therefore returns slightly different results on each platform (we _can_ do better though, PRs are welcome!). The rules are:

- presentEventCreatingDialog

| situation                   | result on both platforms                                                       |
| :-------------------------- | :----------------------------------------------------------------------------- |
| event is created            | `{ action: 'SAVED', eventIdentifier: string, calendarItemIdentifier: string }` |
| event creation is cancelled | `{ action: 'CANCELED' }`                                                       |

- presentEventEditingDialog

| situation                  | result on iOS                                                                  | result on Android        |
| :------------------------- | :----------------------------------------------------------------------------- | ------------------------ |
| event is edited            | `{ action: 'SAVED', eventIdentifier: string, calendarItemIdentifier: string }` | `{ action: 'CANCELED' }` |
| event editing is cancelled | `{ action: 'CANCELED' }`                                                       | `{ action: 'CANCELED' }` |
| event is deleted           | `{ action: 'DELETED' }`                                                        | `{ action: 'DELETED' }`  |

- presentEventViewingDialog

On Android, this will lead to same situation as calling `presentEventEditingDialog`; the following table describes iOS only:

| situation                                              | result on iOS             |
| :----------------------------------------------------- | :------------------------ |
| event modal is dismissed                               | `{ action: 'DONE' }`      |
| user responded to and saved a pending event invitation | `{ action: 'RESPONDED' }` |
| event is deleted                                       | `{ action: 'DELETED' }`   |

### Configuring the navigation bar (iOS only)

The navigation bar appearance for all calls can be customized by providing a `navigationBarIOS` object in the config. The object has the following shape:

```
navigationBarIOS: {
  tintColor: string,
  barTintColor: string,
  backgroundColor: string,
  translucent: boolean,
  titleColor: string,
}
```

Please see the docs on [tintColor](https://developer.apple.com/documentation/uikit/uinavigationbar/1624937-tintcolor?language=objc), [barTintColor](https://developer.apple.com/documentation/uikit/uinavigationbar/1624931-bartintcolor?language=objc), [backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor?language=objc), [translucent](https://developer.apple.com/documentation/uikit/uinavigationbar/1624928-translucent?language=objc), [titleTextAttributes](https://developer.apple.com/documentation/uikit/uinavigationbar/1624953-titletextattributes?language=objc) (NSForegroundColorAttributeName)

### Exported constants

Please note that `SAVED`, `CANCELED`, `DELETED`, `DONE` and `RESPONDED` constants are exported from the module. The constants are borrowed from iOS and are covered in [EKEventViewAction docs](https://developer.apple.com/documentation/eventkitui/ekeventviewaction?language=objc) and [EKEventEditViewAction docs](https://developer.apple.com/documentation/eventkitui/ekeventeditviewaction?language=objc).

#### Note on the `Date` JS Object

It is recommended to not rely on the standard `Date` object and instead use some third party library for dealing with dates, such as moment.js because JavaScriptCore (which is used to run react-native on devices) handles dates differently from V8 (which is used when debugging, when the code runs on your computer).

#### Changing the language of the iOS dialog

see [StackOverflow answer](https://stackoverflow.com/questions/18425945/xcode-5-and-localization-of-xib-files)

### Manual installation

#### iOS

1.  In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2.  Go to `node_modules` ➜ `react-native-add-calendar-event` and add `RNAddCalendarEvent.xcodeproj`
3.  In XCode, in the project navigator, select your project. Add `libRNAddCalendarEvent.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4.  Run your project (`Cmd+R`)<

#### Android

1.  Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import com.vonovak.AddCalendarEventPackage;` to the imports at the top of the file
- Add `new AddCalendarEventPackage()` to the list returned by the `getPackages()` method

2.  Append the following lines to `android/settings.gradle`:
    ```
    include ':react-native-add-calendar-event'
    project(':react-native-add-calendar-event').projectDir = new File(rootProject.projectDir,   '../node_modules/react-native-add-calendar-event/android')
    ```
3.  Insert the following lines inside the dependencies block in `android/app/build.gradle`:
    ```
      compile project(':react-native-add-calendar-event')
    ```
