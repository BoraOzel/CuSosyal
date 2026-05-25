//
//  EditCommunityViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 25/5/26.
//

import Foundation

protocol EditCommunityViewModelInterface {
    var community: Communities { get }
    
    func save(name: String, description: String, imageData: Data?) async throws
}

class EditCommunityViewModel {
    private let networkManager: any NetworkManagerInterface
    private(set) var community: Communities
    
    init(community: Communities,
         networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.community = community
        self.networkManager = networkManager
    }
}

extension EditCommunityViewModel: EditCommunityViewModelInterface {
    
    func save(name: String, description: String, imageData: Data?) async throws {
        guard let communityId = community.id else {
            throw NSError(domain: "EditCommunity", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Kulüp ID bulunamadı."])
        }
        
        var logoUrl: String? = community.logoUrl
        
        if let imageData {
            logoUrl = try await networkManager.updateCommunityLogo(
                communityId: communityId,
                imageData: imageData
            )
        }
        
        try await networkManager.updateCommunity(
            communityId: communityId,
            name: name,
            description: description,
            logoUrl: logoUrl
        )
    }
    
}
