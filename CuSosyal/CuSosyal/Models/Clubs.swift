//
//  Clubs.swift
//  CuSosyal
//
//  Created by Bora Özel on 10/3/26.
//

import Foundation
import FirebaseFirestore

struct Clubs: Codable {
    @DocumentID var id: String?
    let adminUid: String?
    let name: String
    let description: String?
    let logoUrl: String?
    let tags: [Tags]
}
