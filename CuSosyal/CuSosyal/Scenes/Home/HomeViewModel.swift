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
}

class HomeViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    private(set) var userName: String = ""
    private(set) var suggestedCommunities: [Communities] = []
    
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
    }
    
    func numberOfSuggestedCommunities() -> Int {
        return suggestedCommunities.count
    }
    
    func getSuggestedCommunity(at index: Int) -> Communities? {
        guard suggestedCommunities.indices.contains(index) else { return nil }
        return suggestedCommunities[index]
    }
}
