//
//  FavouriteClubsViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 19/6/26.
//

import Foundation

protocol FavouriteClubsViewModelInterface {
    func getFavouriteCommunities() async
    func numberOfItems() -> Int
    func getItem(at index: Int) -> Communities?
    func logoURLs() -> [URL]
}

class FavouriteClubsViewModel {
    
    private let networkManager: any NetworkManagerInterface
    private var favouriteCommunities: [Communities] = []
    
    init(networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
}

extension FavouriteClubsViewModel: FavouriteClubsViewModelInterface {
    func getFavouriteCommunities() async {
        do {
            let favCommunities = try await networkManager.fetchFavouriteClubs()

            await MainActor.run {
                self.favouriteCommunities = favCommunities
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func numberOfItems() -> Int {
        favouriteCommunities.count
    }
    
    func getItem(at index: Int) -> Communities? {
        guard favouriteCommunities.indices.contains(index) else { return nil }
        return favouriteCommunities[index]
    }
    
    func logoURLs() -> [URL] {
        return favouriteCommunities.compactMap { URL(string: $0.logoUrl ?? "")}
    }
    
}
