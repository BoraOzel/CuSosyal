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
    
    func getEvents() async
    func numberOfEvents() -> Int
    func getEvent(at index: Int) -> Events?
}

final class CommunityDetailViewModel {
    
    private(set) var community: Communities
    private let networkManager: any NetworkManagerInterface
    private var events: [Events] = []
    
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
}
