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
    func fetchRegistrationStatus() async
    func toggleRegistration() async
}

class EventDetailViewModel {
    
    private(set) var event: Events
    private(set) var logoUrl: String?
    private(set) var isRegistered: Bool = false
    
    private let networkManager: any NetworkManagerInterface
    private var currentUser: Users?
    
    init(event: Events, logoUrl: String?, networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.event = event
        self.logoUrl = logoUrl
        self.networkManager = networkManager
    }
}

extension EventDetailViewModel: EventDetailViewModelInterface {
    
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
    
    func toggleRegistration() async {
        guard let userId = Auth.auth().currentUser?.uid,
              let eventId = event.id
        else { return }
        
        do {
            if isRegistered {
                try await networkManager.leaveEvent(userId: userId, eventId: eventId)
            }
            else {
                try await networkManager.joinEvent(userId: userId, eventId: eventId)
            }
            await MainActor.run {
                isRegistered.toggle()
            }
        }
        catch {
            print("toggleRegistration failed: \(error.localizedDescription)")
        }
    }
    
}
