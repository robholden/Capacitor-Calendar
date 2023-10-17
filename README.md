# capacitor-plugin-calendar

A plugin for Android to detect and watch for system theme changes. Currently the WebView does not populate the `prefers-calendar` property with their system dark mode.

## TODO: Install

```bash
npm install capacitor-plugin-calendar
npx cap sync
```

## Example

```typescript
// Prompt to create event
const { id } = await Calendar.addEvent({
  title: 'Event Name',
  location: 'The World',
  startDate: new Date(),
  isAllDay: true,
});

// Update event
await Calendar.updateEvent({
  id,
  location: 'North Pole',
});

// Check event exists
const { result } = await Calendar.hasEvent({ id });

// Delete event
await Calendar.deleteEvent({ id });
```

## Android Manifest

Ensure that you have the following permissions added

```xml
<?xml version='1.0' encoding='utf-8'?>
<manifest ...>
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />
</manifest>
```

## API

<docgen-index>

* [`requestAccess(...)`](#requestaccess)
* [`hasAccess(...)`](#hasaccess)
* [`hasEvent(...)`](#hasevent)
* [`addEvent(...)`](#addevent)
* [`updateEvent(...)`](#updateevent)
* [`removeEvent(...)`](#removeevent)
* [Type Aliases](#type-aliases)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### requestAccess(...)

```typescript
requestAccess(options: { fullAccess?: boolean; }) => Promise<{ result: CalendarPermissionResult; }>
```

Request access to the calendar

| Param         | Type                                   | Description   |
| ------------- | -------------------------------------- | ------------- |
| **`options`** | <code>{ fullAccess?: boolean; }</code> | Event options |

**Returns:** <code>Promise&lt;{ result: <a href="#calendarpermissionresult">CalendarPermissionResult</a>; }&gt;</code>

--------------------


### hasAccess(...)

```typescript
hasAccess(options: { fullAccess?: boolean; }) => Promise<{ result: CalendarPermissionResult; }>
```

Returns access level

| Param         | Type                                   | Description   |
| ------------- | -------------------------------------- | ------------- |
| **`options`** | <code>{ fullAccess?: boolean; }</code> | Event options |

**Returns:** <code>Promise&lt;{ result: <a href="#calendarpermissionresult">CalendarPermissionResult</a>; }&gt;</code>

--------------------


### hasEvent(...)

```typescript
hasEvent(options: { id: string; }) => Promise<{ result: boolean; }>
```

Returns true when provided id exists in the calendar

| Param         | Type                         | Description   |
| ------------- | ---------------------------- | ------------- |
| **`options`** | <code>{ id: string; }</code> | Event options |

**Returns:** <code>Promise&lt;{ result: boolean; }&gt;</code>

--------------------


### addEvent(...)

```typescript
addEvent(options: CalendarCreateEventOptions) => Promise<{ id: string; }>
```

Open device calendar with pre-fill event using provided information

| Param         | Type                                                                              | Description       |
| ------------- | --------------------------------------------------------------------------------- | ----------------- |
| **`options`** | <code><a href="#calendarcreateeventoptions">CalendarCreateEventOptions</a></code> | Event information |

**Returns:** <code>Promise&lt;{ id: string; }&gt;</code>

--------------------


### updateEvent(...)

```typescript
updateEvent(options: CalendarUpdateEventOptions) => Promise<{ id: string; }>
```

Updates event with provided data by an id

| Param         | Type                                                                              | Description       |
| ------------- | --------------------------------------------------------------------------------- | ----------------- |
| **`options`** | <code><a href="#calendarupdateeventoptions">CalendarUpdateEventOptions</a></code> | Event information |

**Returns:** <code>Promise&lt;{ id: string; }&gt;</code>

--------------------


### removeEvent(...)

```typescript
removeEvent(options: { id: string; }) => Promise<{ result: boolean; }>
```

Removes an event by its id

| Param         | Type                         | Description   |
| ------------- | ---------------------------- | ------------- |
| **`options`** | <code>{ id: string; }</code> | Event options |

**Returns:** <code>Promise&lt;{ result: boolean; }&gt;</code>

--------------------


### Type Aliases


#### CalendarCreateEventOptions

<code><a href="#calendareventoptions">CalendarEventOptions</a> & { title: string; startDate: number; fullAccess?: boolean; }</code>


#### CalendarEventOptions

<code>{ title?: string; startDate?: number; notes?: string; location?: string; endDate?: number; isAllDay?: boolean; }</code>


#### CalendarUpdateEventOptions

<code><a href="#calendareventoptions">CalendarEventOptions</a> & { id: string; }</code>


### Enums


#### CalendarPermissionResult

| Members             | Value          |
| ------------------- | -------------- |
| **`NotDetermined`** | <code>0</code> |
| **`Authorized`**    | <code>1</code> |
| **`Restricted`**    | <code>2</code> |
| **`Denied`**        | <code>3</code> |

</docgen-api>
