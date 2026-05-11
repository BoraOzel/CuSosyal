//
//  NetworkManager.swift
//  CuSosyal
//
//  Created by Bora Özel on 18/4/26.
//

import FirebaseFirestore
import FirebaseAuth

protocol NetworkManagerInterface: AnyObject {
    func fetchCommunities() async throws -> [Communities]
    func fetchEvents(for communityId: String) async throws -> [Events]
    func fetchCurrentUser() async throws -> Users
    func joinEvent(userId: String, eventId: String) async throws
    func leaveEvent(userId: String, eventId: String) async throws
    func fetchSavedEvents(eventIds: [String]) async throws -> [Events]
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
                print("fetchCommunities failed: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func fetchEvents(for communityId: String) async throws -> [Events] {
        let snapshot = try await db
            .collection("events")
            .whereField("clubId", isEqualTo: communityId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Events.self)
            } catch {
                print("fetchEvents failed: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func fetchCurrentUser() async throws -> Users {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "Auth", code: 401)
        }
        
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: Users.self)
    }
    
    func joinEvent(userId: String, eventId: String) async throws {
        try await db.collection("users").document(userId).updateData(["reservedEvents" : FieldValue.arrayUnion([eventId])])
    }
    
    func leaveEvent(userId: String, eventId: String) async throws {
        try await db.collection("users").document(userId).updateData(["reservedEvents" : FieldValue.arrayRemove([eventId])])
    }
    
    func fetchSavedEvents(eventIds: [String]) async throws -> [Events] {
        guard !eventIds.isEmpty else { return [] }
        
        var events: [Events] = []
        for eventId in eventIds {
            let document = try await db.collection("events").document(eventId).getDocument()
            if let event = try? document.data(as: Events.self) {
                events.append(event)
            }
        }
        return events
    }
    
}
