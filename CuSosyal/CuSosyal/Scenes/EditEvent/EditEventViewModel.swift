//
//  EditEventViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 25/5/26.
//

import Foundation

enum EditEventMode {
    case create(communityId: String)
    case edit(event: Events)
}

protocol EditEventViewModelInterface {
    var isEditMode: Bool { get }
    var existingEvent: Events? { get }
    
    func save(title: String, location: String, date: Date, description: String) async throws
}

class EditEventViewModel {
    
    private let networkManager: any NetworkManagerInterface
    private let mode: EditEventMode
    
    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    var existingEvent: Events? {
        if case .edit(let event) = mode { return event }
        return nil
    }
    
    init(mode: EditEventMode,
         networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.mode = mode
        self.networkManager = networkManager
    }
    
}

extension EditEventViewModel: EditEventViewModelInterface {
    
    func save(title: String, location: String, date: Date, description: String) async throws {
        switch mode {
        case .create(let communityId):
            let newEvent = Events(clubId: communityId,
                                  title: title,
                                  location: location,
                                  date: date,
                                  description: description)
            try await networkManager.createEvent(newEvent)
        case .edit(let existingEvent):
            guard let eventId = existingEvent.id else {
                throw NSError(domain: "EditEvent", code: 400,
                              userInfo: [NSLocalizedDescriptionKey: "Etkinlik ID bulunamadı."])
            }
            try await networkManager.updateEvent(
                eventId: eventId,
                title: title,
                location: location,
                date: date,
                description: description
            )
        }
    }
    
}
