package com.capacitorplugin.calendar;

import com.getcapacitor.PluginCall;

public class CalendarOptions
{
    public String Title;
    public String Description;
    public String Location;
    public Long StartDate;
    public Long EndDate;
    public Boolean IsAllDay;

    public void PopulateFromCall(PluginCall call) {
        Title = call.getString("title");
        Description = call.getString("notes");
        Location = call.getString("location");
        StartDate = call.getLong("startDate");
        EndDate = call.getLong("endDate");
        IsAllDay = call.hasOption("isAllDay") ? call.getBoolean("isAllDay") : Boolean.FALSE;
    }
}
