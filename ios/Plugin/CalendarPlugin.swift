import Foundation
import Capacitor
import EventKit
import EventKitUI

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CalendarPlugin)
public class CalendarPlugin: CAPPlugin, EKEventEditViewDelegate {
    private let store = EKEventStore()
    private var createCall: CAPPluginCall?
    
    @objc func requestAccess(_ call: CAPPluginCall) {
        getAccess(call, fullAccess: call.getBool("fullAccess", false)) { granted in
            self.hasAccess(call)
        }
    }
    
    @objc func hasAccess(_ call: CAPPluginCall) {
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        let fullAccess = call.getBool("fullAccess", false)
        
        var result = CalendarPermissionResult.notDetermined
        switch authorizationStatus {
        case .restricted:
            result = .restricted
        case .denied:
            result = .denied
        case .authorized, .fullAccess:
            result = .authorized
        case .writeOnly:
            result = fullAccess ? .denied : .authorized
        case .notDetermined:
            result = .notDetermined
        @unknown default:
            result = .notDetermined
        }
        
        call.resolve(["result": result.rawValue])
    }
    
    @objc func hasEvent(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Id is required")
            return
        }
        
        getAccess(call, fullAccess: true) { granted in
            if !granted {
                return
            }
            
            let event = self.store.event(withIdentifier: id)
            call.resolve(["result": event != nil])
        }
    }
    
    @objc func removeEvent(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Id is required")
            return
        }
        
        getAccess(call, fullAccess: true) { granted in
            if !granted {
                return
            }
        
            var deleted = true
            if let event = self.store.event(withIdentifier: id) {
                do {
                   try self.store.remove(event, span: .thisEvent);
                   call.resolve()
               } catch let error as NSError {
                   print("Couldn't remove event: \(error)")
                   deleted = false
               }
            }
            
            call.resolve(["result": deleted])
        }
    }
    
    @objc func addEvent(_ call: CAPPluginCall) {
        guard let title = call.getString("title") else {
            call.reject("Title is required")
            return
        }
        
        guard let startDate = call.getDouble("startDate"), startDate > 0 else {
            call.reject("Start is required")
            return
        }
        let location = call.getString("location") ?? ""
        let notes = call.getString("notes") ?? ""
        
        
        let allDay = call.getBool("isAllDay") ?? false
        let endDate = call.getDouble("endDate") ?? 0
        if (!allDay && endDate <= 0) {
            call.reject("End date is required")
            return
        }
        
        getAccess(call, fullAccess: call.getBool("fullAccess", false)) { granted in
            if !granted {
                return
            }
            
            let event = EKEvent(eventStore: self.store)
            event.title = title
            event.startDate = Date(timeIntervalSince1970: startDate / 1000)
            event.location = location
            event.notes = notes
            
            if (allDay) {
                event.endDate = event.startDate
                event.isAllDay = true
            }
            else {
                event.endDate = Date(timeIntervalSince1970: endDate / 1000)
            }
            
            self.createCall = call

            DispatchQueue.main.async {
                let eventController = EKEventEditViewController()
                
                eventController.event = event
                eventController.eventStore = self.store
                eventController.editViewDelegate = self
                
                self.bridge!.viewController!.present(eventController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func updateEvent(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Id is required")
            return
        }
        
        getAccess(call, fullAccess: false) { granted in
            if !granted {
                return
            }
        
            guard let event = self.store.event(withIdentifier: id) else {
                call.reject("Event not found to update")
                return
            }
            
            let title = call.getString("location") ?? event.title
            let startDate = call.getDouble("startDate") ?? event.startDate.timeIntervalSinceReferenceDate * 1000
            let location = call.getString("location") ?? event.location
            let notes = call.getString("notes") ?? event.notes
            let allDay = call.getBool("isAllDay") ?? event.isAllDay
            let endDate = call.getDouble("endDate") ?? event.endDate.timeIntervalSinceReferenceDate * 1000
            if (!allDay && endDate <= 0) {
                call.reject("End date is required")
                return
            }
            
            event.title = title
            event.startDate = Date(timeIntervalSince1970: startDate / 1000)
            event.location = location
            event.notes = notes
            
            if (allDay) {
                event.endDate = event.startDate
                event.isAllDay = true
            }
            else {
                event.endDate = Date(timeIntervalSince1970: endDate / 1000)
            }
            
            do {
                try self.store.save(event, span: .thisEvent)
                call.resolve(["id": id])
            } catch let error as NSError {
                call.reject("Couldn't update event: \(error)")
            }
        }
    }
    
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if let call = createCall {
            call.resolve(["id": controller.self.event?.eventIdentifier ?? ""])
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func getAccess(_ call: CAPPluginCall, fullAccess: Bool, action: @escaping ((Bool)->())) -> Void {
        func handleResult (granted: Bool, error: Error?) -> Void {
            if !granted || error != nil {
                call.reject("Access to calendar denied: \(String(describing: error?.localizedDescription))")
                action(false)
            } else {
                action(true)
            }
        }
        
        if #available(iOS 17.0, *) {
            if fullAccess {
                store.requestFullAccessToEvents { accessGranted, error in
                    handleResult(granted: accessGranted, error: error)
                }
            } else {
                store.requestWriteOnlyAccessToEvents { accessGranted, error in
                    handleResult(granted: accessGranted, error: error)
                }
            }
        } else {
            // Fallback on earlier versions
            store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
                handleResult(granted: accessGranted, error: error)
            }
        }
    }
}
