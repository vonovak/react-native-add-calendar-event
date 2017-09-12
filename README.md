
# react-native-add-calendar-event

This package alows you to start an activity (Android) or show a modal window (iOS) for adding events to calendar. Through a promise, you can find out if a new event was added and get its id. See the usage section for more information.


<img src="https://raw.githubusercontent.com/vonovak/react-native-add-calendar-event/master/example/ios.gif" width="300" hspace="60" /> <img src="https://raw.githubusercontent.com/vonovak/react-native-add-calendar-event/master/example/android.gif" width="300" />


## Getting started

`npm install react-native-add-calendar-event --save`

`yarn add react-native-add-calendar-event`

### Mostly automatic installation

1. `react-native link react-native-add-calendar-event`

2. add `NSCalendarsUsageDescription` key to your `Info.plist` file. The string value associated with the key will be used when asking user for calendar permission.

3. rebuild your project



## Usage

see the example for a demo app

```javascript
import * as AddCalendarEvent from 'react-native-add-calendar-event';

const eventConfig = {
  title,
  // and other options
};

AddCalendarEvent.presentNewCalendarEventDialog(eventConfig)
  .then(eventId => {
    //handle success (receives event id) or dismissing the modal (receives false)
    if (eventId) {
      console.warn(eventId);
    } else {
      console.warn('dismissed');
    }
  })
  .catch((error: string) => {
    // handle error such as when user rejected permissions
    console.warn(error);
  });
};
```

### supported options:


| Property        | Value            | Note |
| :--------------- | :---------------- | :----------- |
| title           | String             |  |
| startDate       | String             | format: 'YYYY-MM-DDTHH:mm:ss.SSSZZ'  |
| endDate         | String             | format: 'YYYY-MM-DDTHH:mm:ss.SSSZZ'  |
| location        | String           |   |
| url             | String           | iOS only  |
| notes           | String           | The notes (iOS) or description (Android) associated with the event. |


The dates passed to this module are strings. If you use moment, you may get the right format via `moment(momentInUTC).local().format('YYYY-MM-DDTHH:mm:ss.SSSZZ')`.

More options can be easily added, PRs are welcome!

It is reccomended to not rely on the standard `Date` object and instead use some third party library for dealing with dates, such as moment.js because JavaScriptCore (which is used to run react-native on devices) handles dates differently from V8 (which is used when debugging, when the code runs on your computer).

#### Changing language of dialog

see [StackOverflow answer](https://stackoverflow.com/questions/18425945/xcode-5-and-localization-of-xib-files)

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-add-calendar-event` and add `AddCalendarEvent.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libAddCalendarEvent.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.vonovak.AddCalendarEventPackage;` to the imports at the top of the file
  - Add `new AddCalendarEventPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
    ```
    include ':react-native-add-calendar-event'
    project(':react-native-add-calendar-event').projectDir = new File(rootProject.projectDir,   '../node_modules/react-native-add-calendar-event/android')
    ```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
    ```
      compile project(':react-native-add-calendar-event')
    ```

  
