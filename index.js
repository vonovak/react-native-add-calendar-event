import { NativeModules, Platform, PermissionsAndroid } from 'react-native';

const { AddCalendarEvent } = NativeModules;

const _presentCalendarEventDialog = eventConfig => {
  return AddCalendarEvent.presentNewEventDialog(eventConfig)
    .then(eventId => {
      return Promise.resolve(eventId);
    })
    .catch(error => {
      return Promise.reject(error);
    });
};

export const presentNewCalendarEventDialog = options => {
  if (Platform.OS === 'android') {
    return PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR)
      .then(() => {
        return _presentCalendarEventDialog(options);
      })
      .catch(() => {
        return Promise.reject("user didn't grant permissions to access calendar");
      });
  } else {
    // ios permissions resolved within the native module
    return _presentCalendarEventDialog(options);
  }
};
