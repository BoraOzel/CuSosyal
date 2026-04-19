//
//  CommunitiesViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 18/4/26.
//

import Foundation

protocol CommunitiesViewModelInterface {
    func getCommunities() async
    func numberOfItems() -> Int
    func getItem(at index: Int) -> Communities?
    func filterCommunities(with query: String)
}

class CommunitiesViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    private var communities: [Communities] = []
    private var filteredCommunities: [Communities] = []
    private var isSearching: Bool = false
    
    private var currentCommunities: [Communities] {
        return isSearching ? filteredCommunities : communities
    }
    
    init(networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
}


extension CommunitiesViewModel: CommunitiesViewModelInterface {
    
    func getCommunities() async {
        do {
            let fetchedCommunities = try await networkManager.fetchCommunities()
            
            await MainActor.run {
                self.communities = fetchedCommunities
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func numberOfItems() -> Int {
        return currentCommunities.count
    }
    
    func getItem(at index: Int) -> Communities? {
        return currentCommunities[index]
    }
    
    func filterCommunities(with query: String) {
        if query.isEmpty {
            isSearching = false
        }
        else {
            isSearching = true
            filteredCommunities = communities.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
}
