//
//  EventDetailViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 23/4/26.
//

import Foundation
import FirebaseAuth

protocol EventDetailViewModelInterface {
    var event: Events { get }
    var logoUrl: String? { get }
    var isRegistered: Bool { get }
    var isCurrentUserAdmin: Bool { get }
    var capacityText: String { get }
    
    func fetchRegistrationStatus() async
    func toggleRegistration() async throws
    func addToCalendar() async throws
    func deleteEvent() async throws
    func refreshEvent() async
}

class EventDetailViewModel {
    
    private(set) var event: Events
    private(set) var logoUrl: String?
    private(set) var isRegistered: Bool = false
    private let adminUid: String?
    
    private let networkManager: any NetworkManagerInterface
    private let calendarManager: any CalendarManagerInterface
    private var currentUser: Users?
    
    var capacityText: String {
        if let capacity = event.capacity {
            return "👥 \(event.currentAttendees) / \(capacity)"
        }
        return "👥 \(event.currentAttendees) katılımcı"
    }
    var isFull: Bool { event.isFull }
    
    init(event: Events,
         logoUrl: String?,
         adminUid: String?,
         networkManager: any NetworkManagerInterface = NetworkManager.shared,
         calendarManager: any CalendarManagerInterface = CalendarManager.shared) {
        self.event = event
        self.logoUrl = logoUrl
        self.adminUid = adminUid
        self.networkManager = networkManager
        self.calendarManager = calendarManager
    }
}

extension EventDetailViewModel: EventDetailViewModelInterface {
    
    var isCurrentUserAdmin: Bool {
        guard let adminUid = adminUid,
              let currentUser = Auth.auth().currentUser?.uid else { return false }
        return adminUid == currentUser
    }
    
    func fetchRegistrationStatus() async {
        do {
            let user = try await networkManager.fetchCurrentUser()
            await MainActor.run {
                self.currentUser = user
                self.isRegistered = user.reservedEvents?.contains(event.id ?? "") ?? false
            }
        }
        catch {
            print("fetchRegistrationStatus failed: \(error.localizedDescription)")
        }
    }
    
    func toggleRegistration() async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let eventId = event.id
        else { return }
        
        if isRegistered {
            try await networkManager.leaveEvent(userId: userId, eventId: eventId)
        }
        else {
            guard !event.isFull else {
                throw NSError(domain: "Event", code: 409, userInfo: [NSLocalizedDescriptionKey: "Etkinlik kontenjani dolu."])
            }
            try await networkManager.joinEvent(userId: userId, eventId: eventId)
        }
        await refreshEvent()
        await MainActor.run { isRegistered.toggle() }
    }
    
    func addToCalendar() async throws {
        try await calendarManager.addEventToCalendar(title: event.title, date: event.date, location: event.location)
    }
    
    func deleteEvent() async throws {
        guard let eventId = event.id else {
            throw NSError(domain: "EventDetail", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Etkinlik ID bulunamadı."])
        }
        try await networkManager.deleteEvent(eventId: eventId)
    }
    
    func refreshEvent() async {
        guard let eventId = event.id else { return }
        do {
            let updated = try await networkManager.fetchEvent(eventId: eventId)
            await MainActor.run { self.event = updated }
        } catch {
            print("refreshEvent failed: \(error.localizedDescription)")
        }
    }
    
}
