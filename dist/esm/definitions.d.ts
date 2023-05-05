export declare type CalendarEventOptions = {
    title?: string;
    startDate?: number;
    notes?: string;
    location?: string;
    endDate?: number;
    isAllDay?: boolean;
};
export declare type CalendarCreateEventOptions = CalendarEventOptions & {
    title: string;
    startDate: number;
};
export declare type CalendarUpdateEventOptions = CalendarEventOptions & {
    id: string;
};
export interface CalendarPlugin {
    /**
     * Returns true when provided id exists in the calendar
     *
     * @param options Event options
     */
    hasEvent(options: {
        id: string;
    }): Promise<{
        result: boolean;
    }>;
    /**
     * Open device calendar with pre-fill event using provided information
     *
     * @param options Event information
     */
    addEvent(options: CalendarCreateEventOptions): Promise<{
        id: string;
    }>;
    /**
     * Updates event with provided data by an id
     *
     * @param options Event information
     */
    updateEvent(options: CalendarUpdateEventOptions): Promise<{
        id: string;
    }>;
    /**
     * Removes an event by its id
     *
     * @param options Event options
     */
    removeEvent(options: {
        id: string;
    }): Promise<{
        result: boolean;
    }>;
}
