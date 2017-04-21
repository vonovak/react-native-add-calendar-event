package com.vonovak;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.text.ParseException;
import java.text.SimpleDateFormat;

public class AddCalendarEventModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    //private final ReactApplicationContext reactContext;
    public final String MODULE_NAME = "AddCalendarEvent";
    public final int ADD_EVENT_REQUEST_CODE = 1;
    public static final String DATE_PARSING_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";


    public AddCalendarEventModule(ReactApplicationContext reactContext) {
        super(reactContext);
        //this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }

    private static long getTimestamp(String dateAsString) throws ParseException {
        SimpleDateFormat datetimeFormatter = new SimpleDateFormat(DATE_PARSING_FORMAT);
        return datetimeFormatter.parse(dateAsString).getTime();
    }


    @ReactMethod
    public void presentNewEventDialog(ReadableMap config, Promise promise) {
        Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(MODULE_NAME, "Activity doesn't exist");
            return;
        }
        try {
            final Intent calendarIntent = new Intent(Intent.ACTION_EDIT);
            calendarIntent
                    .setType("vnd.android.cursor.item/event")
                    .putExtra("title", config.getString("title"));

            if (config.hasKey("startDate")) {
                calendarIntent.putExtra("beginTime", getTimestamp(config.getString("startDate")));
            }

            if (config.hasKey("endDate")) {
                calendarIntent.putExtra("endTime", getTimestamp(config.getString("endDate")));
            }

            if (config.hasKey("location")
                    && config.getString("location") != null) {
                calendarIntent.putExtra("eventLocation", config.getString("location"));
            }

            if (config.hasKey("description")
                    && config.getString("description") != null) {
                calendarIntent.putExtra("description", config.getString("description"));
            }

//        currentActivity.startActivity(calendarIntent);
            currentActivity.startActivityForResult(calendarIntent, ADD_EVENT_REQUEST_CODE);
        } catch (ParseException e) {
            promise.reject(e.getMessage());
        }
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

    }

    @Override
    public void onNewIntent(Intent intent) {

    }
}