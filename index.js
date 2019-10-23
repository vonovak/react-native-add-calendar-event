import { NativeModules, Platform, PermissionsAndroid, processColor } from 'react-native';
const { WRITE_CALENDAR, READ_CALENDAR } = PermissionsAndroid.PERMISSIONS;

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
  if (Platform.OS === 'android' || !config || !config.navigationBarIOS) {
    return config;
  } else {
    return transformConfigColors(config);
  }
};

export const transformConfigColors = config => {
  const transformedKeys = ['tintColor', 'barTintColor', 'backgroundColor', 'titleColor'];
  const { navigationBarIOS } = config;
  const processedColors = Object.keys(navigationBarIOS)
    .filter(key => transformedKeys.includes(key))
    .reduce(
      (accumulator, key) => ({ ...accumulator, [key]: processColor(navigationBarIOS[key]) }),
      {}
    );

  const configCopy = { ...config };
  configCopy.navigationBarIOS = { ...configCopy.navigationBarIOS, ...processedColors };
  return configCopy;
};

const withPermissionsCheck = toCallWhenPermissionGranted => {
  if (Platform.OS === 'android') {
    return withPermissionsCheckAndroid(toCallWhenPermissionGranted);
  } else {
    return withPermissionsCheckIOS(toCallWhenPermissionGranted);
  }
};

const permissionNotGranted = 'permissionNotGranted';

const withPermissionsCheckAndroid = async toCallWhenPermissionGranted => {
  // it seems unnecessary to check first, but if permission is manually disabled
  // the PermissionsAndroid.request will return granted (a RN bug?)
  const [hasWritePermission, hasReadPermission] = await Promise.all([
    PermissionsAndroid.check(WRITE_CALENDAR),
    PermissionsAndroid.check(READ_CALENDAR),
  ]);

  if (hasWritePermission === true && hasReadPermission === true) {
    return toCallWhenPermissionGranted();
  }

  const results = await PermissionsAndroid.requestMultiple([WRITE_CALENDAR, READ_CALENDAR]);

  if (
    results[READ_CALENDAR] === PermissionsAndroid.RESULTS.GRANTED &&
    results[WRITE_CALENDAR] === PermissionsAndroid.RESULTS.GRANTED
  ) {
    return toCallWhenPermissionGranted();
  } else {
    return Promise.reject(permissionNotGranted);
  }
};

const withPermissionsCheckIOS = async toCallWhenPermissionGranted => {
  const hasPermission = await AddCalendarEvent.requestCalendarPermission();

  if (hasPermission) {
    return toCallWhenPermissionGranted();
  } else {
    return Promise.reject(permissionNotGranted);
  }
};
