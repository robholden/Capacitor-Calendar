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

    @objc func hasEvent(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Id is required")
            return
        }
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            if !accessGranted || error != nil {
                call.reject("Access to calendar denied: \(String(describing: error?.localizedDescription))")
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
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            if !accessGranted || error != nil {
                call.reject("Access to calendar denied: \(String(describing: error?.localizedDescription))")
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
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            if !accessGranted || error != nil {
                call.reject("Access to calendar denied: \(String(describing: error?.localizedDescription))")
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
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            if !accessGranted || error != nil {
                call.reject("Access to calendar denied: \(String(describing: error?.localizedDescription))")
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
}
