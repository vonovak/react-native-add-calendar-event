## 2.1.0

- this is mostly a maintenance release, there are no new features in the native module. The gradle plugin version was updated and you can specify version of buildTools used in the module, as seen in the [example app's build.gradle](https://github.com/vonovak/react-native-add-calendar-event/blob/35eb1226829f1c7aac1b727e2010bd673c189374/example/EventDemo/android/build.gradle#L35)
- the example app was upgraded to RN 0.56 (meaning the package itself can be used with it too)

## 2.0.2

- improves weak pointer initialization. You probably didn't have any issues with this.

## 2.0.1

- fixes [#45](https://github.com/vonovak/react-native-add-calendar-event/issues/45)

## 2.0.0

- adds ability to view event given its id, there are also new options for navbar appearance on iOS
- the module now exports three methods which is a breaking change, see readme for help on how to update

## 1.1.4

- fixes https://github.com/vonovak/react-native-add-calendar-event/issues/43

## 1.1.3

- do not use, a forgotten debug log call got into the release

## 1.1.2

- fix for android detection of whether or not a new event was added; see [issue](https://github.com/vonovak/react-native-add-calendar-event/issues/34) for more info

## 1.1.1

- fix for android crash: https://github.com/vonovak/react-native-add-calendar-event/issues/35

## 1.1.0

- `presentEventDialog` now returns an object with `calendarItemIdentifier` and `eventIdentifier` keys, both of type string.
  These are two different identifiers on iOS. On Android, where they are both equal and represent the event id, and are also passed as strings. This improves possible usage with https://github.com/wmcmahan/react-native-calendar-events
- all-day events are now supported
- other minor changes

## 1.0.0

- `presentNewCalendarEventDialog` was renamed to `presentEventDialog`; the module now has basic support for editing existing events. Pass `eventId` in the options object if you want to edit an event instead of creating it.

- the module now returns `eventId` as string on both platforms (it used to return number on Android and string on iOS)

- bugfix: iOS used to return `calendarItemIdentifier`, now returns `eventIdentifier`

- bugfix: added a check that prevents Android from crashing with `CursorIndexOutOfBoundsException`
