//
//  NetworkManager.swift
//  CuSosyal
//
//  Created by Bora Özel on 18/4/26.
//

import FirebaseFirestore

protocol NetworkManagerInterface: AnyObject {
    func fetchCommunities() async throws -> [Communities]
}

class NetworkManager: NetworkManagerInterface {
    
    static let shared = NetworkManager()
    private init() { }
    
    private let db = Firestore.firestore()
    
    func fetchCommunities() async throws -> [Communities] {
        let snapshot = try await db.collection("clubs").getDocuments()
        
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Communities.self)
            } catch {
                print("⚠️ fetchCommunities failed: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
}
