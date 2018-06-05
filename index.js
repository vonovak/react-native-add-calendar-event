import { NativeModules, Platform, PermissionsAndroid } from 'react-native';

const AddCalendarEvent = NativeModules.AddCalendarEvent;

const _presentCalendarEventDialog = eventConfig => {
  return AddCalendarEvent.presentEventDialog(eventConfig);
};

export const presentEventDialog = async options => {
  if (Platform.OS === 'android') {
    // it seems unnecessary to check first, but if permission is manually disabled
    // the PermissionsAndroid.request will return granted (a RN bug?)
    const [hasWritePermission, hasReadPermission] = await Promise.all([
      PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR),
      PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.READ_CALENDAR),
    ]);

    if (hasWritePermission === true && hasReadPermission === true) {
      return _presentCalendarEventDialog(options);
    }

    const writeAccessResult = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR
    );
    const readAccessResult = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.READ_CALENDAR
    );

    if (
      writeAccessResult === PermissionsAndroid.RESULTS.GRANTED &&
      readAccessResult === PermissionsAndroid.RESULTS.GRANTED
    ) {
      return _presentCalendarEventDialog(options);
    } else {
      return Promise.reject('permissionNotGranted');
    }
  } else {
    // ios permissions resolved within the native module
    return _presentCalendarEventDialog(options);
  }
};
