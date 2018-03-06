/**
 * Sample React Native App with adding events to calendar
 * @flow
 */

import React, { Component } from 'react';
import { StyleSheet, Text, View, Button, TextInput } from 'react-native';
import * as AddCalendarEvent from 'react-native-add-calendar-event';
import moment from 'moment';

const utcDateToString = (momentInUTC: moment): string => {
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
      </View>
    );
  }

  static addToCalendar = (title: string, startDateUTC: moment) => {
    const eventConfig = {
      title,
      startDate: utcDateToString(startDateUTC),
      endDate: utcDateToString(moment.utc(startDateUTC).add(1, 'hours')),
    };

    AddCalendarEvent.presentEventDialog(eventConfig)
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

  static editCalendarEventWithId = (eventId: string) => {
    const eventConfig = {
      eventId,
    };

    AddCalendarEvent.presentEventDialog(eventConfig)
      .then(eventId => {
        // eventId is always returned when editing events
        console.warn(eventId);
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
