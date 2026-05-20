//
//  ChatMessage.swift
//  CuSosyal
//
//  Created by Bora Özel on 12/5/26.
//

import Foundation

struct ChatMessage {
    let id: UUID = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date = Date()
}
