//
//  EventsViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 26/5/26.
//

import Foundation

protocol EventsViewModelInterface {
    func fetchEvents() async
    func numberOfEvents() -> Int
    func getEvent(at index: Int) -> Events?
    func getCommunity(for event: Events) -> Communities?
    func filterEvents(with query: String)
}

class EventsViewModel {
    
    private let networkManager: any NetworkManagerInterface
    private(set) var events: [Events] = []
    private var cachedCommunities: [Communities] = []
    private var filteredEvents: [Events] = []
    private var isSearching: Bool = false
    
    private var currentEvents: [Events] {
        isSearching ? filteredEvents : events
    }
    
    init(networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
}

extension EventsViewModel: EventsViewModelInterface {
    
    func fetchEvents() async {
        do {
            async let fetchedEvents = networkManager.fetchAllEvents()
            async let fetchedCommunities = networkManager.fetchCommunities()
            let (events, communities) = try await (fetchedEvents, fetchedCommunities)
            
            await MainActor.run {
                self.events = events
                self.cachedCommunities = communities
            }
        }
        catch {
            print("fetchEvents failed: \(error.localizedDescription)")
        }
    }
    
    func numberOfEvents() -> Int {
        return currentEvents.count
    }
    
    func getEvent(at index: Int) -> Events? {
        guard currentEvents.indices.contains(index) else { return nil }
        return currentEvents[index]
    }
    
    func getCommunity(for event: Events) -> Communities? {
        return cachedCommunities.first { $0.id == event.clubId }
    }
    
    func filterEvents(with query: String) {
        if query.isEmpty {
            isSearching = false
        }
        else {
            isSearching = true
            filteredEvents = events.filter {
                $0.title.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
}
