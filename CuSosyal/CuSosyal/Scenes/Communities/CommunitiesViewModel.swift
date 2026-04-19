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
}

class CommunitiesViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    private var communities: [Communities] = []
    
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
        return communities.count
    }
    
    func getItem(at index: Int) -> Communities? {
        return communities[index]
    }
    
}
