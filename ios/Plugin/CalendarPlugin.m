#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CalendarPlugin, "Calendar",
           CAP_PLUGIN_METHOD(hasEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(updateEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removeEvent, CAPPluginReturnPromise);
)
