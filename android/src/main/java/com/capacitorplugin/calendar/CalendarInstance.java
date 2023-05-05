package com.capacitorplugin.calendar;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.provider.CalendarContract.Events;
import android.provider.CalendarContract.Calendars;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;

import java.util.TimeZone;

public class CalendarInstance
{
    private final AppCompatActivity activity;

    public CalendarInstance(AppCompatActivity activity)
    {
        this.activity = activity;
    }

    public Boolean hasEvent(Long id)
    {
        ContentResolver cr = this.activity.getContentResolver();

        String[] proj = new String[]{Events._ID, Events.DTSTART, Events.DTEND, Events.RRULE, Events.TITLE};
        Cursor cursor = cr.query(Events.CONTENT_URI, proj, Events._ID + " = ? ", new String[]{Long.toString(id)}, null);
        if (cursor.moveToFirst())
        {
            cursor.close();
            return true;
        }

        return false;
    }

    public Boolean removeEvent(Long id)
    {
        ContentResolver cr = this.activity.getContentResolver();
        Uri deleteUri = null;
        deleteUri = ContentUris.withAppendedId(Events.CONTENT_URI, id);
        int rows = cr.delete(deleteUri, null, null);

        return rows == 1;
    }

    public Intent addEvent(CalendarOptions options)
    {
        Intent intent = new Intent(Intent.ACTION_EDIT);
        intent.setType("vnd.android.cursor.item/event");
        intent.putExtra(Events.TITLE, options.Title);
        intent.putExtra(Events.DESCRIPTION, options.Description);
        intent.putExtra(Events.EVENT_LOCATION, options.Location);
        intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, options.StartDate);
        intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, options.EndDate);
        intent.putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, options.IsAllDay);

        return intent;
    }

    public Long getEventIdFromResult(CalendarOptions options)
    {
        ContentResolver cr = this.activity.getContentResolver();
        Long eventId = null;

        String[] projection = new String[]{Events._ID, Events.DTSTART, Events.EVENT_LOCATION};
        String selection = "((" + Events.DTSTART + " = ?) AND (" + Events.EVENT_LOCATION + " = ?))";
        Cursor cursor = cr.query(Events.CONTENT_URI, projection, selection, new String[]{Long.toString(options.StartDate), options.Location}, null);
        if (cursor.moveToFirst())
        {
            int col = cursor.getColumnIndex(Events._ID);
            eventId = cursor.getLong(col);

            cursor.close();
        }

        return eventId;
    }

    public void updateEvent(Long id, CalendarOptions options)
    {
        ContentResolver cr = this.activity.getContentResolver();
        ContentValues values = new ContentValues();
        Uri updateUri = null;

        if (options.Title != null) values.put(Events.TITLE, options.Title);
        if (options.Description != null) values.put(Events.DESCRIPTION, options.Description);
        if (options.Location != null) values.put(Events.EVENT_LOCATION, options.Location);
        if (options.StartDate != null) values.put(Events.DTSTART, options.StartDate);
        if (options.EndDate != null) values.put(Events.DTEND, options.EndDate);
        if (options.IsAllDay != null) values.put(Events.ALL_DAY, options.IsAllDay);

        updateUri = ContentUris.withAppendedId(Events.CONTENT_URI, id);
        cr.update(updateUri, values, null, null);
    }
}
