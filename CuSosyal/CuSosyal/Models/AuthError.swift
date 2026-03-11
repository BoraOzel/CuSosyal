//
//  AuthError.swift
//  CuSosyal
//
//  Created by Bora Özel on 11/3/26.
//

import Foundation

enum AuthError: Error {
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case unknown
    case blank
    
    var localizedDescription: String {
        switch self {
        case .invalidEmail: return "Geçersiz email formatı."
        case .weakPassword: return "Zayıf şifre. Lütfen daha güçlü bir şifre giriniz."
        case .wrongPassword: return "Şifrenizi hatalı girdiniz."
        case .userNotFound: return "Bu emaile kayıtlı hesap bulunamadı. Lütfen kayıt olunuz."
        case .emailAlreadyInUse: return "Bu email kullanılıyor."
        case .unknown: return "Bilinmeyen bir hata meydana geldi."
        case .blank: return "Lütfen tüm boşlukları doldurunuz."
        }
    }
}
