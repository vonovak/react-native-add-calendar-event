import { NativeModules, Platform, PermissionsAndroid, processColor } from 'react-native';

const AddCalendarEvent = NativeModules.AddCalendarEvent;

export const presentEventViewingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventViewingDialog(processColorsIOS(options));
  return withPermissionsCheck(toCall);
};

export const presentEventEditingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventEditingDialog(processColorsIOS(options));
  return withPermissionsCheck(toCall);
};

export const presentEventCreatingDialog = options => {
  const toCall = () => AddCalendarEvent.presentEventCreatingDialog(processColorsIOS(options));
  return withPermissionsCheck(toCall);
};

const processColorsIOS = config => {
  if (Platform.OS === 'android' || !config) {
    return config;
  }
  const { navigationBarIOS } = config;
  if (navigationBarIOS) {
    const { tintColor, backgroundColor, barTintColor } = navigationBarIOS;
    navigationBarIOS.tintColor = tintColor && processColor(tintColor);
    navigationBarIOS.backgroundColor = backgroundColor && processColor(backgroundColor);
    navigationBarIOS.barTintColor = barTintColor && processColor(barTintColor);
  }
  return config;
};

const withPermissionsCheck = toCallWhenPermissionGranted => {
  if (Platform.OS === 'android') {
    return withPermissionsCheckAndroid(toCallWhenPermissionGranted);
  } else {
    return withPermissionsCheckIOS(toCallWhenPermissionGranted);
  }
};

const withPermissionsCheckAndroid = async toCallWhenPermissionGranted => {
  try {
    // it seems unnecessary to check first, but if permission is manually disabled
    // the PermissionsAndroid.request will return granted (a RN bug?)
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
};

const withPermissionsCheckIOS = async toCallWhenPermissionGranted => {
  try {
    const hasPermission = await AddCalendarEvent.requestCalendarPermission();

    if (hasPermission) {
      return toCallWhenPermissionGranted();
    }
  } catch (err) {
    return Promise.reject(err);
  }
};
