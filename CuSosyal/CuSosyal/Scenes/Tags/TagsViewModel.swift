//
//  TagsViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import Foundation

protocol TagsViewModelInterface {
    func saveTags(_ tags: [Tags]) async throws
}

class TagsViewModel {
    
    private let networkManager: any NetworkManagerInterface
    
    
    init(networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
}

extension TagsViewModel: TagsViewModelInterface {
    
    func saveTags(_ tags: [Tags]) async throws {
        try await networkManager.updateUserTags(tags)
    }
    
}
