package com.vonovak;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.support.annotation.Nullable;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

public class Utils {

  static final String DATE_PARSING_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  static long getTimestamp(String dateAsString) throws ParseException {
    SimpleDateFormat datetimeFormatter = new SimpleDateFormat(DATE_PARSING_FORMAT);
    datetimeFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
    return datetimeFormatter.parse(dateAsString).getTime();
  }

  // inspired by http://stackoverflow.com/questions/9761584/how-can-i-find-out-the-result-of-my-calendar-intent
  @Nullable
  static Long extractLastEventId(Cursor cursor) {
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

  static boolean doesEventExist(ContentResolver cr, long eventId) {
    Uri uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, (eventId));

    String selection = "((" + CalendarContract.Events.DELETED + " != 1))";

    Cursor cursor = cr.query(uri, new String[]{
            CalendarContract.Events._ID,
    }, selection, null, null);

    if (cursor != null && cursor.getCount() > 0) {
      cursor.close();
      return true;
    } else {
      return false;
    }
  }

  static boolean doesEventExist(ContentResolver cr, String eventId) {
    try {
      long longId = Long.valueOf(eventId);
      return doesEventExist(cr, longId);
    } catch(NumberFormatException e) {
      return false;
    }
  }
}
