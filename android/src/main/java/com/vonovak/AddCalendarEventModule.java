
package com.vonovak;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class AddCalendarEventModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    public final String MODULE_NAME = "AddCalendarEvent";
    public final int ADD_EVENT_REQUEST_CODE = 1;

    public AddCalendarEventModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }


    @ReactMethod
    public void addEvent(ReadableMap config, Promise promise) {
        Activity currentActivity = getCurrentActivity();

        if (currentActivity == null) {
            promise.reject(MODULE_NAME, "Activity doesn't exist");
            return;
        }

        final Intent calendarIntent = new Intent(Intent.ACTION_EDIT);
        calendarIntent
                .setType("vnd.android.cursor.item/event")
                .putExtra("title", config.getString("title"));

        if (config.hasKey("startDate")) {
            calendarIntent.putExtra("beginTime", (long) config.getDouble("startDate"));
        }

        if (config.hasKey("endDate")) {
            calendarIntent.putExtra("endTime", (long) config.getDouble("endDate"));
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
    }
}