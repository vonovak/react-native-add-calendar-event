# Expo installation

> This package cannot be used in the "Expo Go" app because [it requires custom native code](https://docs.expo.io/workflow/customizing/).

First install the package with yarn, npm, or [`expo install`](https://docs.expo.io/workflow/expo-cli/#expo-install).

```sh
expo install react-native-add-calendar-event
```

After installing this npm package, add the [config plugin](https://docs.expo.io/guides/config-plugins/) to the [`plugins`](https://docs.expo.io/versions/latest/config/app/#plugins) array of your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": ["react-native-add-calendar-event"]
  }
}
```

Next, rebuild your app as described in the ["Adding custom native code"](https://docs.expo.io/workflow/customizing/) guide.

## Props

The plugin provides props for extra customization. Every time you change the props or plugins, you'll need to rebuild (and prebuild) the native app. If no extra properties are added, defaults will be used.

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-add-calendar-event",
        {
          "calendarPermission": "Our great calendar app wants to access your calendar",
          "contactsPermission": "Our great calendar app wants to access your contacts"
        }
      ]
    ]
  }
}
```

- `calendarPermission` (string, optional): Sets the iOS NSCalendarsUsageDescription permission message to the Info.plist. Defaults to `Allow $(PRODUCT_NAME) to access your calendar`.
- `contactsPermission` (string, optional): Sets the iOS NSContactsUsageDescription permission message to the Info.plist. Defaults to `Allow $(PRODUCT_NAME) to access your contacts`.

## Manual Setup

For bare workflow projects, you can follow the manual setup guides:

- [iOS](/ios/install.md)
- [Android](/android/install.md)
