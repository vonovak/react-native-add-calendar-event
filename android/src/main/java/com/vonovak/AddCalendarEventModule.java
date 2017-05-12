package com.vonovak;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.CalendarContract;

import com.facebook.react.bridge.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;

public class AddCalendarEventModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    public final String ADD_EVENT_MODULE_NAME = "AddCalendarEvent";
    public final int ADD_EVENT_REQUEST_CODE = 11;
    public static final String DATE_PARSING_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    private Promise promise;
    private Long lastEventIdPrior;


    public AddCalendarEventModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
        resetMembers();
    }

    private void resetMembers() {
        promise = null;
        lastEventIdPrior = 0L;
    }

    @Override
    public String getName() {
        return ADD_EVENT_MODULE_NAME;
    }

    private static long getTimestamp(String dateAsString) throws ParseException {
        SimpleDateFormat datetimeFormatter = new SimpleDateFormat(DATE_PARSING_FORMAT);
        return datetimeFormatter.parse(dateAsString).getTime();
    }

    @ReactMethod
    public void presentNewEventDialog(ReadableMap config, Promise eventPromise) {
        this.promise = eventPromise;

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

            lastEventIdPrior = AddCalendarEventModule.getLastEventId(getReactApplicationContext().getContentResolver());
            getReactApplicationContext().startActivityForResult(calendarIntent, ADD_EVENT_REQUEST_CODE, Bundle.EMPTY);
        } catch (ParseException e) {
            promise.reject(ADD_EVENT_MODULE_NAME, e);
        }
    }

    @Override
    public void onActivityResult(Activity activity, final int requestCode, final int resultCode, final Intent intent) {
        if (requestCode != ADD_EVENT_REQUEST_CODE || promise == null) {
            return;
        }
        Long lastEventIdPost = AddCalendarEventModule.getLastEventId(activity.getContentResolver());

        // lastEventIdPost == lastEventIdPrior + 1 means there is new event created
        if (lastEventIdPrior != null && lastEventIdPost != null && lastEventIdPost == lastEventIdPrior + 1) {
            // react native bridge doesn't support passing long values
            promise.resolve(lastEventIdPost.doubleValue());
        } else {
            promise.resolve(false);
        }

        resetMembers();
    }

    // inspired by http://stackoverflow.com/questions/9761584/how-can-i-find-out-the-result-of-my-calendar-intent
    public static Long getLastEventId(ContentResolver cr) {
        Cursor cursor = cr.query(CalendarContract.Events.CONTENT_URI, new String[]{"MAX(_id) as max_id"}, null, null, "_id");
        if (cursor != null) {
            cursor.moveToFirst();
            long maxId = cursor.getLong(cursor.getColumnIndex("max_id"));
            cursor.close();
            return maxId;
        } else {
            return null;
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
    }


}