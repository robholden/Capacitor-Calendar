package com.capacitorplugin.calendar;

import android.Manifest;
import android.content.Intent;
import android.util.Log;

import androidx.activity.result.ActivityResult;

import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;

import java.time.temporal.Temporal;

@CapacitorPlugin(
        name = "Calendar",
        permissions = {
                @Permission(strings = {Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR}, alias = "calendar")
        }
)
public class CalendarPlugin extends Plugin
{
    private CalendarInstance implementation;

    @Override
    public void load()
    {
        implementation = new CalendarInstance(getActivity());
    }

    protected void requestPermissionsCalendar(PluginCall call)
    {
        requestPermissionForAlias("calendar", call, "calendarPermsCallback");
    }

    @PermissionCallback
    private void calendarPermsCallback(PluginCall call)
    {
        if (!(getPermissionState("calendar") == PermissionState.GRANTED))
        {
            call.reject("Permission is required");
        }
    }

    @PluginMethod
    public void hasEvent(PluginCall call)
    {
        if (!(getPermissionState("calendar") == PermissionState.GRANTED))
        {
            requestPermissionsCalendar(call);
            return;
        }

        if (!hasEventId(call))
        {
            call.reject("An id is required");
            return;
        }

        Long eventId = getEventIdFromCall(call);
        if (eventId == null)
        {
            call.reject("Id must be a number");
            return;
        }

        JSObject ret = new JSObject();
        ret.put("result", implementation.hasEvent(eventId));
        call.resolve(ret);
    }

    @PluginMethod
    public void removeEvent(PluginCall call)
    {
        if (!(getPermissionState("calendar") == PermissionState.GRANTED))
        {
            requestPermissionsCalendar(call);
            return;
        }

        if (!hasEventId(call))
        {
            call.reject("An id is required");
            return;
        }

        Long eventId = getEventIdFromCall(call);
        if (eventId == null)
        {
            call.reject("Id must be a number");
        }

        JSObject ret = new JSObject();
        ret.put("result", implementation.removeEvent(eventId));
        call.resolve(ret);
    }

    @PluginMethod
    public void addEvent(PluginCall call)
    {
        if (!(getPermissionState("calendar") == PermissionState.GRANTED))
        {
            requestPermissionsCalendar(call);
            return;
        }

        Long eventId = null;
        if (hasEventId(call))
        {
            eventId = getEventIdFromCall(call);
            if (eventId == null)
            {
                call.reject("Id must be a number");
                return;
            }
        }

        CalendarOptions options = new CalendarOptions();
        options.PopulateFromCall(call);

        if (options.Title == null || options.Title.equals(""))
        {
            call.reject("A title is required");
            return;
        }

        if (options.StartDate == null)
        {
            call.reject("A start date is required");
            return;
        }

        var intent = implementation.addEvent(options);
        startActivityForResult(call, intent, "createEventResult");
    }

    @PluginMethod
    public void updateEvent(PluginCall call)
    {
        if (!(getPermissionState("calendar") == PermissionState.GRANTED))
        {
            requestPermissionsCalendar(call);
            return;
        }

        if (!hasEventId(call))
        {
            call.reject("An id is required");
            return;
        }

        Long eventId = getEventIdFromCall(call);
        if (eventId == null)
        {
            call.reject("Id must be a number");
            return;
        }

        CalendarOptions options = new CalendarOptions();
        options.PopulateFromCall(call);

        implementation.updateEvent(eventId, options);

        JSObject ret = new JSObject();
        ret.put("id", eventId.toString());
        call.resolve(ret);
    }

    @ActivityCallback
    private void createEventResult(PluginCall call, ActivityResult result)
    {
        if (call == null)
        {
            return;
        }

        CalendarOptions options = new CalendarOptions();
        options.PopulateFromCall(call);

        Long eventId = implementation.getEventIdFromResult(options);

        JSObject ret = new JSObject();
        ret.put("id", eventId == null ? null : eventId.toString());
        call.resolve(ret);
    }

    private Boolean hasEventId(PluginCall call)
    {
        if (!call.hasOption("id"))
        {
            return false;
        }

        Long longId = call.getLong("id");
        if (longId != null)
        {
            return true;
        }

        Integer intId = call.getInt("id");
        if (intId != null)
        {
            return true;
        }

        String id = call.getString("id");
        return id != null && !id.equals("");
    }

    private Long getEventIdFromCall(PluginCall call)
    {
        Long longId = call.getLong("id");
        if (longId != null)
        {
            return longId;
        }

        Integer intId = call.getInt("id");
        if (intId != null)
        {
            return intId.longValue();
        }

        try
        {
            String id = call.getString("id");
            if (id != null)
            {
                return Long.parseLong(id);
            }
        }
        catch (Exception ignored)
        {
        }

        return null;
    }
}
