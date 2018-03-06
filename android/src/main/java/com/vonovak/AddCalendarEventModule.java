package com.vonovak;

import android.app.Activity;
import android.content.ContentUris;
import android.content.CursorLoader;
import android.content.Intent;
import android.database.Cursor;
import android.database.CursorIndexOutOfBoundsException;
import android.net.Uri;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.app.LoaderManager;
import android.content.Loader;
import android.util.Log;

import com.facebook.react.bridge.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

public class AddCalendarEventModule extends ReactContextBaseJavaModule implements ActivityEventListener, LoaderManager.LoaderCallbacks {

    public final String ADD_EVENT_MODULE_NAME = "AddCalendarEvent";
    public final int ADD_EVENT_REQUEST_CODE = 11;
    public static final String DATE_PARSING_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    private Promise promise;
    private Long eventPriorId;


    public AddCalendarEventModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
        resetMembers();
    }

    private void resetMembers() {
        promise = null;
        eventPriorId = 0L;
    }

    @Override
    public String getName() {
        return ADD_EVENT_MODULE_NAME;
    }

    private static long getTimestamp(String dateAsString) throws ParseException {
        SimpleDateFormat datetimeFormatter = new SimpleDateFormat(DATE_PARSING_FORMAT);
        datetimeFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        return datetimeFormatter.parse(dateAsString).getTime();
    }

    @ReactMethod
    public void presentEventDialog(ReadableMap config, Promise eventPromise) {
        promise = eventPromise;

        if (config.hasKey("eventId")) {
            this.presentEventEditingActivity(config);
        } else {
            this.presentEventAddingActivity(config);
        }
    }

    private void presentEventEditingActivity(ReadableMap config) {
        String eventId = config.getString("eventId");
        long eventID = Long.valueOf(eventId);
        Uri eventUri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventID);

        boolean shouldUseViewIntent = config.getBoolean("useViewIntent");
        // ACTION_EDIT does not work  even though it should according to
        // https://stuff.mit.edu/afs/sipb/project/android/docs/guide/topics/providers/calendar-provider.html#intent-edit
        // bug tracker: https://issuetracker.google.com/u/1/issues/36957942?pli=1

        Intent intent = new Intent(shouldUseViewIntent ? Intent.ACTION_VIEW : Intent.ACTION_EDIT)
                .setData(eventUri);

        Activity activity = getCurrentActivity();
        if (activity != null) {
            activity.startActivity(intent);
        }
        promise.resolve(eventID);
    }

    private void presentEventAddingActivity(ReadableMap config) {
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
            setPriorEventId(getCurrentActivity());
            getReactApplicationContext().startActivityForResult(calendarIntent, ADD_EVENT_REQUEST_CODE, Bundle.EMPTY);
        } catch (ParseException e) {
            promise.reject(ADD_EVENT_MODULE_NAME, e);
        }
    }

    private void setPriorEventId(Activity activity) {
        if (activity != null) {
            activity.getLoaderManager().initLoader(1, null, this);
        }
    }

    @Override
    public void onActivityResult(Activity activity, final int requestCode, final int resultCode, final Intent intent) {
        if (requestCode != ADD_EVENT_REQUEST_CODE || promise == null) {
            return;
        }
        setPostEventId(activity);
    }

    private void setPostEventId(Activity activity) {
        if (activity != null) {
            activity.getLoaderManager().initLoader(2, null, this);
        }
    }

    @Override
    public Loader onCreateLoader(int id, Bundle args) {
        return new CursorLoader(getReactApplicationContext(),
                CalendarContract.Events.CONTENT_URI,
                new String[]{"MAX(_id) as max_id"}, null, null, "_id");
    }

    @Override
    public void onLoadFinished(Loader loader, Object data) {
        Cursor cursor = (Cursor) data;
        if (cursor.isClosed()) {
            // if the destroyLoader function failed
            Log.d(ADD_EVENT_MODULE_NAME, "warning: cursor was closed; loader probably wasn't destroyed previously");
            return;
        }
        Long lastEventId = extractLastEventId(cursor);

        if (loader.getId() == 1) {
            this.eventPriorId = lastEventId;
        } else if (loader.getId() == 2) {
            resolvePromise(lastEventId);
        }

        destroyLoader(loader);
    }

    // inspired by http://stackoverflow.com/questions/9761584/how-can-i-find-out-the-result-of-my-calendar-intent
    private Long extractLastEventId(Cursor cursor) {
        Long lastEventId = null;

        if (cursor != null) {
            cursor.moveToFirst();
            int index = cursor.getColumnIndex("max_id");
            if (index != -1) {
                lastEventId = cursor.getLong(index);
            }
            cursor.close();
        }

        return lastEventId;
    }

    private void resolvePromise(Long eventPostId) {
        if (promise == null) {
            Log.e(ADD_EVENT_MODULE_NAME, "promise is null");
            return;
        }

        if (eventPriorId != null && eventPostId != null
                && eventPostId == eventPriorId + 1) {
            // react native bridge doesn't support passing longs
            promise.resolve(String.valueOf(eventPostId));
        } else {
            promise.resolve(false);
        }

        resetMembers();
    }

    private void destroyLoader(Loader loader) {
        // if loader isn't destroyed, onLoadFinished() gets called multiple times for some reason
        Activity activity = getCurrentActivity();
        if (activity != null) {
            activity.getLoaderManager().destroyLoader(loader.getId());
        } else {
            Log.d(ADD_EVENT_MODULE_NAME, "warning: activity was null when attempting to destroy the loader");
        }
    }

    @Override
    public void onLoaderReset(Loader loader) {
    }

    @Override
    public void onNewIntent(Intent intent) {
    }
}
