export type CalendarEventOptions = {
  title?: string;
  startDate?: number;
  notes?: string;
  location?: string;
  endDate?: number;
  isAllDay?: boolean;
};

export type CalendarCreateEventOptions = CalendarEventOptions & {
  title: string;
  startDate: number;
  fullAccess?: boolean;
};

export type CalendarUpdateEventOptions = CalendarEventOptions & {
  id: string;
};

export enum CalendarPermissionResult {
  NotDetermined = 0,
  Authorized = 1,
  Restricted = 2,
  Denied = 3,
}

export interface CalendarPlugin {
  /**
   * Request access to the calendar
   *
   * @param options Event options
   */
  requestAccess(options: {
    fullAccess?: boolean;
  }): Promise<{ result: CalendarPermissionResult }>;

  /**
   * Returns access level
   *
   * @param options Event options
   */
  hasAccess(options: {
    fullAccess?: boolean;
  }): Promise<{ result: CalendarPermissionResult }>;

  /**
   * Returns true when provided id exists in the calendar
   *
   * @param options Event options
   */
  hasEvent(options: { id: string }): Promise<{ result: boolean }>;

  /**
   * Open device calendar with pre-fill event using provided information
   *
   * @param options Event information
   */
  addEvent(options: CalendarCreateEventOptions): Promise<{ id: string }>;

  /**
   * Updates event with provided data by an id
   *
   * @param options Event information
   */
  updateEvent(options: CalendarUpdateEventOptions): Promise<{ id: string }>;

  /**
   * Removes an event by its id
   *
   * @param options Event options
   */
  removeEvent(options: { id: string }): Promise<{ result: boolean }>;
}
