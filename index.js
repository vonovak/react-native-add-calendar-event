import { NativeModules, Platform, PermissionsAndroid } from 'react-native';

const AddCalendarEvent = NativeModules.AddCalendarEvent;

const _presentCalendarEventDialog = function(eventConfig) {
  return AddCalendarEvent.presentNewEventDialog(eventConfig);
};

export const presentNewCalendarEventDialog = function(options) {
  if (Platform.OS === 'android') {
    // it seems unnecessary to check first, but if permission is manually disabled
    // the PermissionsAndroid.request will return granted (a RN bug?)
    return PermissionsAndroid.check(
      PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR
    ).then(function(hasPermission) {
      if (hasPermission === true) {
        return _presentCalendarEventDialog(options);
      } else {
        return PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR)
          .then(function(granted) {
            if (granted === PermissionsAndroid.RESULTS.GRANTED) {
              return _presentCalendarEventDialog(options);
            } else {
              return Promise.reject('permissionNotGranted');
            }
          })
          .catch(function(err) {
            return Promise.reject(err);
          });
      }
    });
  } else {
    // ios permissions resolved within the native module
    return _presentCalendarEventDialog(options);
  }
};
