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
    // 1. Firebase'den veriyi olduğu gibi ham kelimeler ("Istatistik", "SosyalSorumluluk") olarak alıyoruz
    let tags: [String]
    
    // 2. Uygulama içinde çökmeksizin kullanmak için dönüştürücü yazıyoruz
    var validTags: [Tags] {
        return tags.compactMap { firebaseTag in
            // String(describing:) komutu, enum'un rawValue'sunu ("İstatistik") değil,
            // doğrudan kod adını ("Istatistik") verir. Bu da Firebase ile %100 eşleşir!
            return Tags.allCases.first { String(describing: $0) == firebaseTag }
        }
    }
}
