import { NativeModules, Platform, PermissionsAndroid } from 'react-native';

const AddCalendarEvent = NativeModules.AddCalendarEvent;

const withPermissionsCheck = async toCallWhenPermissionGranted => {
  if (Platform.OS === 'android') {
    // it seems unnecessary to check first, but if permission is manually disabled
    // the PermissionsAndroid.request will return granted (a RN bug?)
    try {
      const hasPermission = await PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR
      );

      if (hasPermission === true) {
        return toCallWhenPermissionGranted();
      } else {
        const result = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR
        );
        if (result === PermissionsAndroid.RESULTS.GRANTED) {
          return toCallWhenPermissionGranted();
        } else {
          return Promise.reject('permissionNotGranted');
        }
      }
    } catch (err) {
      return Promise.reject(err);
    }
  } else {
    // ios permissions resolved within the native module
    return toCallWhenPermissionGranted();
  }
};

// needs event id
export const presentEventViewingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventViewingDialog(options);
  return withPermissionsCheck(toCall);
};

// needs event id and optionally new event details?
export const presentEventEditingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventEditingDialog(options);
  return withPermissionsCheck(toCall);
};

// needs event just event details
export const presentEventCreatingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventCreatingDialog(options);
  return withPermissionsCheck(toCall);
};
