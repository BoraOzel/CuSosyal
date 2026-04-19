//
//  Clubs.swift
//  CuSosyal
//
//  Created by Bora Özel on 10/3/26.
//

import Foundation
import FirebaseFirestore

struct Communities: Codable {
    @DocumentID var id: String?
    let adminUid: String?
    let name: String
    let description: String?
    let logoUrl: String?

    let tags: [String]
    
  
    var validTags: [Tags] {
        return tags.compactMap { firebaseTag in
            return Tags.allCases.first { String(describing: $0) == firebaseTag }
        }
    }
}
