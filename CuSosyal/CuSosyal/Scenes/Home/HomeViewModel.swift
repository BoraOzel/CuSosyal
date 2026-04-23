//
//  HomeViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import Foundation

protocol HomeViewModelInterface {
    var userName: String { get }
    
    func fetchUser() async
}

class HomeViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    private(set) var userName: String = ""
    
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
    
}
