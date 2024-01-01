import { NativeModules, Platform, processColor } from 'react-native';

const AddCalendarEvent = NativeModules.AddCalendarEvent;

export const presentEventViewingDialog = options => {
  return AddCalendarEvent.presentEventViewingDialog(processColorsIOS(options));
};

export const presentEventEditingDialog = options => {
  return AddCalendarEvent.presentEventEditingDialog(processColorsIOS(options));
};

export const presentEventCreatingDialog = options => {
  return AddCalendarEvent.presentEventCreatingDialog(processColorsIOS(options));
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
