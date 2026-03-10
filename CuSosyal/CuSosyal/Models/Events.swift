//
//  Events.swift
//  CuSosyal
//
//  Created by Bora Özel on 10/3/26.
//

import Foundation
import FirebaseFirestore

struct Events: Codable {
    @DocumentID var id: String?
    let clubId: String?
    let title: String
    let location: String
    let date: Date
}
