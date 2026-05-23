//
//  CalendarManager.swift
//  CuSosyal
//
//  Created by Bora Özel on 23/5/26.
//

import Foundation
import EventKit

protocol CalendarManagerInterface {
    func addEventToCalendar(title: String, date: Date, location: String?) async throws
}

final class CalendarManager {
    
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    private init() { }
    
}

extension CalendarManager: CalendarManagerInterface {
    
    func addEventToCalendar(title: String, date: Date, location: String?) async throws {
        let granted: Bool
        if #available(iOS 17.0, *) {
            granted = try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            granted = try await eventStore.requestAccess(to: .event)
        }
        
        guard granted else {
            throw CalendarError.accessDenied
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600) // 1 saat
        event.location = location
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
    }
}
