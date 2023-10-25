/**
 * Sample React Native App with adding events to calendar
 * @flow
 */

import React, { Component } from 'react';
import { StyleSheet, Text, View, Button, TextInput, Platform } from 'react-native';
import {check, PERMISSIONS, RESULTS} from 'react-native-permissions';
import * as AddCalendarEvent from 'react-native-add-calendar-event';
import moment, { Moment } from 'moment';

const utcDateToString = (momentInUTC: Moment): string => {
  let s = moment.utc(momentInUTC).format('YYYY-MM-DDTHH:mm:ss.SSS[Z]');
  // console.warn(s);
  return s;
};

export default class EventDemo extends Component {
  state = { text: '' };
  render() {
    const eventTitle = 'Lunch';
    const nowUTC = moment.utc();
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Event title: {eventTitle}</Text>
        <Text>
          date:{' '}
          {moment
            .utc(nowUTC)
            .local()
            .format('lll')}
        </Text>

        <Button
          onPress={() => {
            EventDemo.addToCalendar(eventTitle, nowUTC);
          }}
          title="Add to calendar"
        />
        <TextInput
          style={{ height: 40, width: '100%', marginTop: 30, marginHorizontal: 15 }}
          placeholder="enter event id"
          onChangeText={text => this.setState({ text })}
          value={this.state.text}
        />
        <Button
          onPress={() => {
            EventDemo.editCalendarEventWithId(this.state.text);
          }}
          title="Edit event with this id"
        />
        <Button
          onPress={() => {
            EventDemo.showCalendarEventWithId(this.state.text);
          }}
          title="Show event with this id"
        />
      </View>
    );
  }

  static addToCalendar = (title: string, startDateUTC: Moment) => {
    const eventConfig: AddCalendarEvent.CreateOptions = {
      title,
      startDate: utcDateToString(startDateUTC),
      endDate: utcDateToString(moment.utc(startDateUTC).add(1, 'hours')),
      notes: 'tasty!',
      navigationBarIOS: {
        translucent: false,
        tintColor: 'orange',
        barTintColor: 'orange',
        backgroundColor: 'green',
        titleColor: 'blue',
      },
    };

    check(Platform.select({
      ios: PERMISSIONS.IOS.CALENDARS_WRITE_ONLY,
      android: PERMISSIONS.ANDROID.WRITE_CALENDAR,
    }))
      .then((result) => {
        if (result == RESULTS.GRANTED) {
          return AddCalendarEvent.presentEventCreatingDialog(eventConfig);
        }
        throw new Error(`This app doesn't have permission`);
      })
      .then((eventInfo) => {
        // handle success - receives an object with `calendarItemIdentifier` and `eventIdentifier` keys, both of type string.
        // These are two different identifiers on iOS.
        // On Android, where they are both equal and represent the event id, also strings.
        // when { action: 'CANCELED' } is returned, the dialog was dismissed
        console.warn(JSON.stringify(eventInfo));
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  };

  static editCalendarEventWithId = (eventId: string) => {
    const eventConfig = {
      eventId,
    };

    check(Platform.select({
      ios: PERMISSIONS.IOS.CALENDARS,
      android: PERMISSIONS.ANDROID.WRITE_CALENDAR,
    }))
      .then((result) => {
        if (result == RESULTS.GRANTED) {
          return AddCalendarEvent.presentEventEditingDialog(eventConfig);
        }
        throw new Error(`This app doesn't have permission`);
      })
      .then(eventInfo => {
        console.warn(JSON.stringify(eventInfo));
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  };

  static showCalendarEventWithId = (eventId: string) => {
    const eventConfig: AddCalendarEvent.ViewOptions = {
      eventId,
      allowsEditing: true,
      allowsCalendarPreview: true,
      navigationBarIOS: {
        translucent: false,
        tintColor: 'orange',
        barTintColor: 'orange',
        backgroundColor: 'green',
        titleColor: 'blue',
      },
    };

    check(Platform.select({
      ios: PERMISSIONS.IOS.CALENDARS,
      android: PERMISSIONS.ANDROID.READ_CALENDAR,
    }))
      .then((result) => {
        if (result == RESULTS.GRANTED) {
          return AddCalendarEvent.presentEventViewingDialog(eventConfig);
        }
        throw new Error(`This app doesn't have permission`);
      })
      .then(eventInfo => {
        console.warn(JSON.stringify(eventInfo));
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  };
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
