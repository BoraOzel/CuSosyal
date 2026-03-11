//
//  Users.swift
//  CuSosyal
//
//  Created by Bora Özel on 10/3/26.
//

import Foundation
import FirebaseFirestore

enum UserRole: String, Codable {
    case student = "student"
    case clubAdmin = "club_admin"
}

struct Users: Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let interestedTags: [String]?
}
