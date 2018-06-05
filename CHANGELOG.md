## 1.1.2

- fixes https://github.com/vonovak/react-native-add-calendar-event/issues/43

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
