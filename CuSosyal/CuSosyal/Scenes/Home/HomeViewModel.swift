//
//  HomeViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import Foundation

protocol HomeViewModelInterface {
    var userName: String { get }
    var suggestedCommunities: [Communities] { get }
    
    func fetchUser() async
    func fetchSuggestedCommunities() async
    func fetchHomeData() async
    func numberOfSuggestedCommunities() -> Int
    func getSuggestedCommunity(at index: Int) -> Communities?
    func numberOfSavedEvents() -> Int
    func getSavedEvent(at index: Int) -> Events?
    func fetchSavedEvents() async
    func getCommunity(for event: Events) -> Communities?
}

class HomeViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    private(set) var userName: String = ""
    private(set) var suggestedCommunities: [Communities] = []
    private(set) var savedEvents: [Events] = []
    private var cachedCommunities: [Communities] = []
    
    init(networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
}

extension HomeViewModel: HomeViewModelInterface {
    
    func fetchUser() async {
        do {
            let user = try await networkManager.fetchCurrentUser()
            await MainActor.run {
                self.userName = user.name
            }
        }
        catch {
            print("fetchUser failed: \(error.localizedDescription)")
        }
    }
    
    func fetchSuggestedCommunities() async {
        do {
            let user = try await networkManager.fetchCurrentUser()
            let allCommunities = try await networkManager.fetchCommunities()
            let userTags = Set(user.interestedTags ?? [])
            
            let matched = allCommunities.filter { community in
                let communityTags = Set(community.validTags)
                return !communityTags.intersection(userTags).isEmpty
            }
            await MainActor.run { self.suggestedCommunities = matched }
        } catch {
            print(" fetchSuggestedCommunities failed: \(error.localizedDescription)")
        }
    }
    
    func fetchHomeData() async {
        await fetchUser()
        await fetchSuggestedCommunities()
        await fetchSavedEvents()
    }
    
    func numberOfSuggestedCommunities() -> Int {
        return suggestedCommunities.count
    }
    
    func getSuggestedCommunity(at index: Int) -> Communities? {
        guard suggestedCommunities.indices.contains(index) else { return nil }
        return suggestedCommunities[index]
    }
    
    func numberOfSavedEvents() -> Int {
        return savedEvents.count
    }
    
    func getSavedEvent(at index: Int) -> Events? {
        guard savedEvents.indices.contains(index) else { return nil }
        return savedEvents[index]
    }
    
    func fetchSavedEvents() async {
        do {
            let user = try await networkManager.fetchCurrentUser()
            let eventIds = user.reservedEvents ?? []
            guard !eventIds.isEmpty else {
                await MainActor.run { self.savedEvents = [] }
                return
            }
            
            async let events = networkManager.fetchSavedEvents(eventIds: eventIds)
            async let communities = networkManager.fetchCommunities()
            let (fetchedEvents, fetchedCommunities) = try await (events, communities)
            
            await MainActor.run {
                self.savedEvents = fetchedEvents
                self.cachedCommunities = fetchedCommunities
            }
        } catch {
            print("fetchSavedEvents failed: \(error.localizedDescription)")
        }
    }
    
    func getCommunity(for event: Events) -> Communities? {
        return cachedCommunities.first { $0.id == event.clubId }
    }
    
}
