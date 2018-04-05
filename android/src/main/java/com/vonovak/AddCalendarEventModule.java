package com.vonovak;

import android.app.Activity;
import android.content.ContentUris;
import android.content.CursorLoader;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.app.LoaderManager;
import android.content.Loader;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;


public class AddCalendarEventModule extends ReactContextBaseJavaModule implements ActivityEventListener, LoaderManager.LoaderCallbacks {

    public final String ADD_EVENT_MODULE_NAME = "AddCalendarEvent";
    public final int ADD_EVENT_REQUEST_CODE = 11;
    public static final String DATE_PARSING_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    private static final int PRIOR_ID = 1;
    private static final int POST_ID = 2;
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
        String eventIdString = config.getString("eventId");
        Uri eventUri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, Long.valueOf(eventIdString));

        boolean shouldUseEditIntent = config.hasKey("useEditIntent") && config.getBoolean("useEditIntent");
        // ACTION_EDIT does not work  even though it should according to
        // https://developer.android.com/guide/topics/providers/calendar-provider.html#intent-edit
        // or https://stuff.mit.edu/afs/sipb/project/android/docs/guide/topics/providers/calendar-provider.html#intent-edit
        // bug tracker: https://issuetracker.google.com/u/1/issues/36957942?pli=1

        Intent intent = new Intent(shouldUseEditIntent ? Intent.ACTION_EDIT : Intent.ACTION_VIEW)
                .setData(eventUri);

        Activity activity = getCurrentActivity();
        if (activity != null) {
            activity.startActivity(intent);
        }
        promise.resolve(eventIdString);
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

            if (config.hasKey("allDay")) {
                calendarIntent.putExtra("allDay", config.getBoolean("allDay"));
            }

            setPriorEventId(getCurrentActivity());
            getReactApplicationContext().startActivityForResult(calendarIntent, ADD_EVENT_REQUEST_CODE, Bundle.EMPTY);
        } catch (ParseException e) {
            rejectPromise(e);
        }
    }

    private void setPriorEventId(Activity activity) {
        if (activity != null) {
            activity.getLoaderManager().initLoader(PRIOR_ID, null, this);
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
            activity.getLoaderManager().initLoader(POST_ID, null, this);
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
            Log.d(ADD_EVENT_MODULE_NAME, "cursor was closed; loader probably wasn't destroyed previously (destroyLoader() failed)");
            rejectPromise("cursor was closed");
            return;
        }
        Long lastEventId = extractLastEventId(cursor);

        if (loader.getId() == PRIOR_ID) {
            eventPriorId = lastEventId;
        } else if (loader.getId() == POST_ID) {
            resolvePromise(lastEventId);
        }

        destroyLoader(loader);
    }

    // inspired by http://stackoverflow.com/questions/9761584/how-can-i-find-out-the-result-of-my-calendar-intent
    @Nullable
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

    private void resolvePromise(@Nullable Long eventPostId) {
        if (promise == null) {
            Log.e(ADD_EVENT_MODULE_NAME, "promise is null");
            return;
        }

        if (eventPriorId == null && eventPostId == null) {
            promise.reject(ADD_EVENT_MODULE_NAME, "event prior and post id were null, extractLastEventId probably encountered a problem");
        } else if (eventPriorId != null && eventPostId != null
                && eventPostId == eventPriorId + 1) {
            // react native bridge doesn't support passing longs
            // plus we pass a map of Strings to be consistent with ios
            WritableMap result = Arguments.createMap();
            String eventId = String.valueOf(eventPostId);
            result.putString("eventIdentifier", eventId);
            result.putString("calendarItemIdentifier", eventId);
            promise.resolve(result);
        } else {
            promise.resolve(false);
        }

        resetMembers();
    }

    private void rejectPromise(Exception e) {
        promise.reject(ADD_EVENT_MODULE_NAME, e);
        resetMembers();
    }

    private void rejectPromise(String e) {
        promise.reject(ADD_EVENT_MODULE_NAME, e);
        resetMembers();
    }

    private void destroyLoader(Loader loader) {
        // if loader isn't destroyed, onLoadFinished() gets called multiple times for some reason
        Activity activity = getCurrentActivity();
        if (activity != null) {
            activity.getLoaderManager().destroyLoader(loader.getId());
        } else {
            Log.d(ADD_EVENT_MODULE_NAME, "activity was null when attempting to destroy the loader");
        }
    }

    @Override
    public void onLoaderReset(Loader loader) {
    }

    @Override
    public void onNewIntent(Intent intent) {
    }
}
