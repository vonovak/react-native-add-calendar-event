/**
 * Sample React Native App with adding events to calendar
 */

import React, { useState, useCallback, useEffect } from "react";
import {
  StyleSheet,
  Text,
  View,
  Button,
  TextInput,
  Platform,
} from "react-native";
import { request, PERMISSIONS, RESULTS } from "react-native-permissions";
import * as AddCalendarEvent from "react-native-add-calendar-event";
import moment, { Moment } from "moment";

const utcDateToString = (momentInUTC: Moment): string => {
  let s = moment.utc(momentInUTC).format("YYYY-MM-DDTHH:mm:ss.SSS[Z]");
  return s;
};

export default function EventDemo() {
  const [eventId, setEventId] = useState("");
  const [eventTitle] = useState("Lunch");
  const [nowUTC] = useState(moment.utc());

  useEffect(() => {
    if (Platform.OS === "android") {
      request(PERMISSIONS.ANDROID.READ_CALENDAR).then((result) => {
        console.warn(`android calendar read permission: ${result}`);
      });
    }
  }, []);

  const addToCalendar = useCallback(() => {
    const eventConfig: AddCalendarEvent.CreateOptions = {
      title: eventTitle,
      startDate: utcDateToString(nowUTC),
      endDate: utcDateToString(moment.utc(nowUTC).add(1, "hours")),
      notes: "tasty!",
      navigationBarIOS: {
        translucent: false,
        tintColor: "orange",
        barTintColor: "orange",
        backgroundColor: "green",
        titleColor: "blue",
      },
    };

    request(
      Platform.select({
        ios: PERMISSIONS.IOS.CALENDARS,
        default: PERMISSIONS.ANDROID.WRITE_CALENDAR,
      })
    )
      .then((result) => {
        if (result !== RESULTS.GRANTED) {
          throw new Error(`No permission: ${result}`);
        }
        return AddCalendarEvent.presentEventCreatingDialog(eventConfig);
      })
      .then((eventInfo) => {
        // handle success - receives an object with `calendarItemIdentifier` and `eventIdentifier` keys, both of type string.
        // These are two different identifiers on iOS.
        // On Android, where they are both equal and represent the event id, also strings.
        // when { action: 'CANCELED' } is returned, the dialog was dismissed
        console.warn(JSON.stringify(eventInfo));

        if ("eventIdentifier" in eventInfo) {
          setEventId(eventInfo.eventIdentifier);
        }
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  }, [eventTitle, nowUTC]);

  const editCalendarEvent = useCallback(() => {
    const eventConfig = {
      eventId,
    };

    request(
      Platform.select({
        ios: PERMISSIONS.IOS.CALENDARS,
        default: PERMISSIONS.ANDROID.WRITE_CALENDAR,
      })
    )
      .then((result) => {
        if (result !== RESULTS.GRANTED) {
          throw new Error(`No permission: ${result}`);
        }
        return AddCalendarEvent.presentEventEditingDialog(eventConfig);
      })
      .then((eventInfo) => {
        console.warn(JSON.stringify(eventInfo));
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  }, [eventId]);

  const showCalendarEvent = useCallback(() => {
    const eventConfig: AddCalendarEvent.ViewOptions = {
      eventId,
      allowsEditing: true,
      allowsCalendarPreview: true,
      navigationBarIOS: {
        translucent: false,
        tintColor: "orange",
        barTintColor: "orange",
        backgroundColor: "green",
        titleColor: "blue",
      },
    };

    request(
      Platform.select({
        ios: PERMISSIONS.IOS.CALENDARS,
        default: PERMISSIONS.ANDROID.READ_CALENDAR,
      })
    )
      .then((result) => {
        if (result !== RESULTS.GRANTED) {
          throw new Error(`No permission: ${result}`);
        }
        return AddCalendarEvent.presentEventViewingDialog(eventConfig);
      })
      .then((eventInfo) => {
        console.warn(JSON.stringify(eventInfo));
      })
      .catch((error: string) => {
        // handle error such as when user rejected permissions
        console.warn(error);
      });
  }, [eventId]);

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>Event title: {eventTitle}</Text>
      <Text>date: {moment.utc(nowUTC).local().format("lll")}</Text>

      <Button onPress={addToCalendar} title="Add to calendar" />
      <TextInput
        style={styles.input}
        placeholder="enter event id"
        onChangeText={setEventId}
        value={eventId}
      />
      <Button onPress={editCalendarEvent} title="Edit event with this id" />
      <Button onPress={showCalendarEvent} title="Show event with this id" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF",
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10,
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5,
  },
  input: {
    height: 40,
    width: "80%",
    marginTop: 30,
    padding: 10,
    marginHorizontal: 15,
    borderWidth: 1,
    borderColor: "#666",
  },
  button: {
    marginVertical: 10,
  },
});
