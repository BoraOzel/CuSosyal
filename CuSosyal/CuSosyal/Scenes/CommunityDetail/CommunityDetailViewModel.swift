//
//  CommunityDetailViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 19/4/26.
//

import Foundation
import FirebaseAuth

protocol CommunityDetailViewModelInterface {
    var community: Communities { get }
    var communityDescription: String { get }
    var isCurrentUserAdmin: Bool { get }
    var isFavourite: Bool { get }
    
    func getEvents() async
    func numberOfEvents() -> Int
    func getEvent(at index: Int) -> Events?
    func refreshCommunity() async
    func loadFavouriteStatus() async
    func toggleFavourite() async
}

final class CommunityDetailViewModel {
    
    private let networkManager: any NetworkManagerInterface
    private(set) var community: Communities
    private var events: [Events] = []
    private(set) var isFavourite: Bool = false
    
    init(community: Communities,
         networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.community = community
        self.networkManager = networkManager
    }
}

extension CommunityDetailViewModel: CommunityDetailViewModelInterface {
    
    var communityDescription: String {
        guard let description = community.description, !description.isEmpty else {
            return "Bu kulüp için açıklama metni girilmemiş."
        }
        return description
    }
    
    var isCurrentUserAdmin: Bool {
        guard let adminUid = community.adminUid,
              let currentUser = Auth.auth().currentUser?.uid else { return false }
        return adminUid == currentUser
    }
    
    func getEvents() async {
        do {
            let fetched = try await networkManager.fetchEvents(for: community.id ?? "")
            await MainActor.run { self.events = fetched }
        } catch {
            print("getEvents failed: \(error.localizedDescription)")
        }
    }
    
    func numberOfEvents() -> Int {
        events.count
    }
    
    func getEvent(at index: Int) -> Events? {
        guard events.indices.contains(index) else { return nil }
        return events[index]
    }
    
    func refreshCommunity() async {
        guard let communityId = community.id else { return }
        do {
            let updated = try await networkManager.fetchCommunity(communityId: communityId)
            await MainActor.run { self.community = updated }
        } catch {
            print("refreshCommunity failed: \(error.localizedDescription)")
        }
    }
    
    func loadFavouriteStatus() async {
        guard let communityId = community.id else { return }
        do {
            let user = try await networkManager.fetchCurrentUser()
            let favourite = user.favouriteClubs?.contains(communityId) ?? false
            await MainActor.run { self.isFavourite = favourite }
        }
        catch {
            print("loadFavouriteStatus failed: \(error.localizedDescription)")
        }
    }
    
    func toggleFavourite() async {
        guard let communityId = community.id else { return }
        do {
            if isFavourite {
                try await networkManager.removeFavouriteClub(clubId: communityId)
            }
            else {
                try await networkManager.addFavouriteClub(clubId: communityId)
            }
            await MainActor.run { self.isFavourite.toggle() }
        }
        catch {
            print("toggleFavourite failed: \(error.localizedDescription)")
        }
    }
}
