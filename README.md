
# react-native-add-calendar-event

## Getting started

`npm install react-native-add-calendar-event --save`
`yarn add react-native-add-calendar-event`

### Mostly automatic installation

`$ react-native link react-native-add-calendar-event`

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
  	project(':react-native-add-calendar-event').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-add-calendar-event/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-add-calendar-event')
  	```


## Usage
```javascript
import AddCalendarEvent from 'react-native-add-calendar-event';

// TODO: What to do with the module?
AddCalendarEvent;
```
  