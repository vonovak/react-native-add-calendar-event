package com.vonovak;

import android.app.Activity;
import android.content.ContentResolver;
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

import java.util.HashMap;
import java.util.Map;

import static com.vonovak.Utils.doesEventExist;
import static com.vonovak.Utils.extractLastEventId;
import static com.vonovak.Utils.getTimestamp;


public class AddCalendarEventModule extends ReactContextBaseJavaModule implements ActivityEventListener, LoaderManager.LoaderCallbacks {

    public static final String ADD_EVENT_MODULE_NAME = "AddCalendarEvent";
    private static final int ADD_EVENT_REQUEST_CODE = 11;
    private static final int SHOW_EVENT_REQUEST_CODE = 12;
    private static final int PRIOR_RESULT_ID = 1;
    private static final int POST_RESULT_ID = 2;
    private Promise promise;
    private Long eventPriorId;
    private Long shownOrEditedEventId;

    private static final String DELETED = "DELETED";
    private static final String SAVED = "SAVED";
    private static final String CANCELED = "CANCELED";
    private static final String DONE = "DONE";
    private static final String RESPONDED = "RESPONDED";


    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(DELETED, DELETED);
        constants.put(SAVED, SAVED);
        constants.put(CANCELED, CANCELED);
        constants.put(DONE, DONE);
        constants.put(RESPONDED, RESPONDED);
        return constants;
    }


    public AddCalendarEventModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
        resetMembers();
    }

    private void resetMembers() {
        promise = null;
        eventPriorId = 0L;
        shownOrEditedEventId = 0L;
    }

    private boolean isEventBeingEdited() {
        return shownOrEditedEventId != 0L;
    }

    @Override
    public String getName() {
        return ADD_EVENT_MODULE_NAME;
    }

    @ReactMethod
    public void presentEventCreatingDialog(ReadableMap config, Promise eventPromise) {
        promise = eventPromise;

        this.presentEventAddingActivity(config);
    }

    private void presentEventAddingActivity(ReadableMap config) {
        try {
            setPriorEventId(getCurrentActivity());

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


            getReactApplicationContext().startActivityForResult(calendarIntent, ADD_EVENT_REQUEST_CODE, Bundle.EMPTY);
        } catch (Exception e) {
            rejectPromise(e);
        }
    }

    @ReactMethod
    public void presentEventEditingDialog(ReadableMap config, Promise eventPromise) {
        promise = eventPromise;
        boolean shouldUseEditIntent = config.hasKey("useEditIntent") && config.getBoolean("useEditIntent");

        // ACTION_EDIT does not work even though it should according to
        // https://developer.android.com/guide/topics/providers/calendar-provider.html#intent-edit
        // or https://stuff.mit.edu/afs/sipb/project/android/docs/guide/topics/providers/calendar-provider.html#intent-edit
        // bug tracker: https://issuetracker.google.com/u/1/issues/36957942?pli=1
        Intent intent = new Intent(shouldUseEditIntent ? Intent.ACTION_EDIT : Intent.ACTION_VIEW);

        this.presentEventEditingActivity(config, intent);
    }

    @ReactMethod
    public void presentEventViewingDialog(ReadableMap config, Promise eventPromise) {
        promise = eventPromise;

        Intent intent = new Intent(Intent.ACTION_VIEW);
        this.presentEventEditingActivity(config, intent);
    }

    private void presentEventEditingActivity(ReadableMap config, Intent intent) {
        String eventIdString = config.getString("eventId");
        if (!doesEventExist(getReactApplicationContext().getContentResolver(), eventIdString)) {
            rejectPromise("event with id " + eventIdString + " not found");
            return;
        }
        shownOrEditedEventId = Long.valueOf(eventIdString);
        Uri eventUri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, shownOrEditedEventId);

        setPriorEventId(getCurrentActivity());

        intent.setData(eventUri);

        try {
            getReactApplicationContext().startActivityForResult(intent, SHOW_EVENT_REQUEST_CODE, Bundle.EMPTY);
        } catch (Exception e) {
            rejectPromise(e);
        }
    }

    private void setPriorEventId(Activity activity) {
        if (activity != null) {
            activity.getLoaderManager().initLoader(PRIOR_RESULT_ID, null, this);
        }
    }

    @Override
    public void onActivityResult(Activity activity, final int requestCode, final int resultCode, final Intent intent) {
        if ((requestCode != ADD_EVENT_REQUEST_CODE && requestCode != SHOW_EVENT_REQUEST_CODE) || promise == null) {
            return;
        }
        setPostEventId(activity);
    }

    private void setPostEventId(Activity activity) {
        if (activity != null) {
            activity.getLoaderManager().initLoader(POST_RESULT_ID, null, this);
        }
    }

    // TODO get rid of the loaders?
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

        if (loader.getId() == PRIOR_RESULT_ID) {
            eventPriorId = lastEventId;
        } else if (loader.getId() == POST_RESULT_ID) {
            returnResultBackToJS(lastEventId);
        }

        destroyLoader(loader);
    }

    private void returnResultBackToJS(@Nullable Long eventPostId) {
        if (promise == null) {
            Log.e(ADD_EVENT_MODULE_NAME, "promise is null");
            return;
        }

        if (eventPriorId == null || eventPostId == null) {
            promise.reject(ADD_EVENT_MODULE_NAME, "event prior and/or post id were null, extractLastEventId probably encountered a problem");
        } else {
            determineActionAndResolve(eventPriorId, eventPostId);
        }
        resetMembers();
    }

    private void determineActionAndResolve(long priorId, long postId) {
        ContentResolver cr = getReactApplicationContext().getContentResolver();

        boolean wasNewEventCreated = postId > priorId;
        boolean doesPostEventExist = doesEventExist(cr, postId);

        WritableMap result = Arguments.createMap();
        String eventId = String.valueOf(postId);
        if (doesPostEventExist && wasNewEventCreated) {
            // react native bridge doesn't support passing longs
            // plus we pass a map of Strings to be consistent with ios
            result.putString("eventIdentifier", eventId);
            result.putString("calendarItemIdentifier", eventId);
            result.putString("action", SAVED);
        } else if (!isEventBeingEdited() || doesEventExist(cr, shownOrEditedEventId)) {
            // NOTE you'll get here even when you edit and save an existing event
            result.putString("action", CANCELED);
        } else {
            result.putString("action", DELETED);
        }
        promise.resolve(result);
    }

    private void rejectPromise(Exception e) {
        rejectPromise(e.getMessage());
    }

    private void rejectPromise(String e) {
        if (promise == null) {
            Log.e(ADD_EVENT_MODULE_NAME, "promise is null");
            return;
        }
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
