//
//  CalendarError.swift
//  CuSosyal
//
//  Created by Bora Özel on 23/5/26.
//

import Foundation

enum CalendarError: LocalizedError {
    case accessDenied
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Takvim erişimi reddedildi. Ayarlar'dan izin verebilirsiniz."
        }
    }
}
