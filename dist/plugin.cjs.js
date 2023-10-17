'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

exports.CalendarPermissionResult = void 0;
(function (CalendarPermissionResult) {
    CalendarPermissionResult[CalendarPermissionResult["NotDetermined"] = 0] = "NotDetermined";
    CalendarPermissionResult[CalendarPermissionResult["Authorized"] = 1] = "Authorized";
    CalendarPermissionResult[CalendarPermissionResult["Restricted"] = 2] = "Restricted";
    CalendarPermissionResult[CalendarPermissionResult["Denied"] = 3] = "Denied";
})(exports.CalendarPermissionResult || (exports.CalendarPermissionResult = {}));

const Calendar = core.registerPlugin('Calendar', {});

exports.Calendar = Calendar;
//# sourceMappingURL=plugin.cjs.js.map
