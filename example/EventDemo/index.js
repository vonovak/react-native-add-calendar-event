/**
 * Sample React Native App with adding events to calendar
 * @flow
 */

import React, { Component } from 'react';
import { StyleSheet, Text, View, Button } from 'react-native';
import * as AddCalendarEvent from 'react-native-add-calendar-event';
import moment from 'moment';

const utcDateToLocalString = (momentDate: moment): string => {
  return moment.utc(momentDate).local().format('YYYY-MM-DDTHH:mm:ss.sssZ');
};

export default class EventDemo extends Component {
  render() {
    const eventTitle = 'Lunch';
    const nowUTC = moment.utc();
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Event title: {eventTitle}
        </Text>
        <Text>date: {moment.utc(nowUTC).local().format('lll')}</Text>

        <Button
          onPress={() => {
            EventDemo.addToCalendar(eventTitle, nowUTC);
          }}
          title="Add to calendar"
        />
      </View>
    );
  }

  static addToCalendar = (title: string, startDateUTC: moment) => {
    const eventConfig = {
      title,
      startDate: utcDateToLocalString(startDateUTC),
      endDate: utcDateToLocalString(moment.utc(startDateUTC).add(1, 'hours')),
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
