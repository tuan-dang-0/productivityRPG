import Foundation
import EventKit
import UIKit
import SwiftData

class CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestCalendarAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            print("Calendar access denied: \(error)")
            return false
        }
    }
    
    func hasCalendarAccess() -> Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }
    
    // MARK: - Calendar Management
    
    private func getOrCreateProductivityCalendar() -> EKCalendar? {
        // First, check if ProductivityRPG calendar already exists
        let calendars = eventStore.calendars(for: .event)
        if let existing = calendars.first(where: { $0.title == "ProductivityRPG" }) {
            return existing
        }
        
        // Try to create new calendar, but fall back to default if account doesn't allow it
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "ProductivityRPG"
        calendar.cgColor = UIColor.systemBlue.cgColor
        
        // Find a writable source (iCloud, local, etc.)
        if let source = eventStore.sources.first(where: { $0.sourceType == .calDAV || $0.sourceType == .local }) {
            calendar.source = source
        } else {
            calendar.source = eventStore.defaultCalendarForNewEvents?.source
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            return calendar
        } catch {
            print("Failed to create calendar: \(error)")
            // Fall back to default calendar if creation fails
            print("Using default calendar instead")
            return eventStore.defaultCalendarForNewEvents
        }
    }
    
    // MARK: - Event Operations
    
    func createEvent(for block: TimeBlock) -> String? {
        guard hasCalendarAccess(),
              let calendar = getOrCreateProductivityCalendar() else {
            return nil
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = block.title
        event.startDate = block.startTime
        event.endDate = block.endTime
        event.calendar = calendar
        
        // Add silent alarm at start time
        let alarm = EKAlarm(absoluteDate: block.startTime)
        // Note: Silent alarms are created by default in iOS (no sound property needed)
        event.addAlarm(alarm)
        
        // Add notes with block details
        if let subcategory = block.subcategory {
            event.notes = "📊 \(subcategory.emoji) \(subcategory.name)\n⏱️ \(block.baseRewardMinutes) min reward"
        }
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            return event.eventIdentifier
        } catch {
            print("Failed to create event: \(error)")
            return nil
        }
    }
    
    func updateEvent(eventId: String, for block: TimeBlock) -> Bool {
        guard hasCalendarAccess(),
              let event = eventStore.event(withIdentifier: eventId) else {
            return false
        }
        
        event.title = block.title
        event.startDate = block.startTime
        event.endDate = block.endTime
        
        // Update alarm
        event.alarms?.forEach { event.removeAlarm($0) }
        let alarm = EKAlarm(absoluteDate: block.startTime)
        // Note: Silent alarms are created by default in iOS (no sound property needed)
        event.addAlarm(alarm)
        
        // Update notes
        if let subcategory = block.subcategory {
            event.notes = "📊 \(subcategory.emoji) \(subcategory.name)\n⏱️ \(block.baseRewardMinutes) min reward"
        }
        
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            return true
        } catch {
            print("Failed to update event: \(error)")
            return false
        }
    }
    
    func deleteEvent(eventId: String) -> Bool {
        guard hasCalendarAccess(),
              let event = eventStore.event(withIdentifier: eventId) else {
            return false
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
            return true
        } catch {
            print("Failed to delete event: \(error)")
            return false
        }
    }
    
    // MARK: - Batch Operations
    
    func syncBlock(_ block: TimeBlock, modelContext: ModelContext) {
        if let eventId = block.calendarEventId {
            // Update existing event
            _ = updateEvent(eventId: eventId, for: block)
        } else {
            // Create new event
            if let newEventId = createEvent(for: block) {
                block.calendarEventId = newEventId
                // Save the event ID to database
                try? modelContext.save()
            }
        }
    }
    
    func removeBlockFromCalendar(_ block: TimeBlock) {
        if let eventId = block.calendarEventId {
            _ = deleteEvent(eventId: eventId)
            block.calendarEventId = nil
        }
    }
}
