import { registerPlugin } from '@capacitor/core';

import type { CalendarPlugin } from './definitions';

const Calendar = registerPlugin<CalendarPlugin>('Calendar', {});

export * from './definitions';
export { Calendar };
