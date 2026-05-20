//
//  AIChatViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 12/5/26.
//

import Foundation

protocol AIChatViewModelInterface {
    var messages: [ChatMessage] { get }
    
    func initializeChat() async
    func sendMessage(text: String) async
}

class AIChatViewModel {
    
    var onMessagesUpdated: (() -> Void)?
    private(set) var messages: [ChatMessage] = []
    private let aiManager: any AIManagerInterface
    private let networkManager: any NetworkManagerInterface
    
    init(aiManager: any AIManagerInterface = AIManager.shared,
         networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.aiManager = aiManager
        self.networkManager = networkManager
    }
    
}

extension AIChatViewModel: AIChatViewModelInterface {
    
    func initializeChat() async {
        async let userResult = networkManager.fetchCurrentUser()
        async let clubsResult = networkManager.fetchCommunities()
        async let eventsResult = networkManager.fetchAllEvents()

        let user = try? await userResult
        let communities = (try? await clubsResult) ?? []
        let allEvents = (try? await eventsResult) ?? []

        let clubNames = communities.map { $0.name }

        let clubLookup = Dictionary(uniqueKeysWithValues: communities.compactMap { c -> (String, String)? in
            guard let id = c.id else { return nil }
            return (id, c.name)
        })

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"

        let eventStrings = allEvents.map { event -> String in
            let clubName = event.clubId.flatMap { clubLookup[$0] } ?? "Bilinmeyen Kulüp"
            let dateString = dateFormatter.string(from: event.date)
            return "- \(event.title) | Kulüp: \(clubName) | Tarih: \(dateString) | Yer: \(event.location)"
        }

        aiManager.startChatSession(
            userName: user?.name ?? "Kullanıcı",
            userTags: user?.interestedTags ?? [],
            clubs: clubNames,
            events: eventStrings
        )
    }
    
    func sendMessage(text: String) async {
        let userMessage = ChatMessage(content: text, isUser: true)
        await MainActor.run {
            messages.append(userMessage)
            onMessagesUpdated?()
        }
        
        do {
            let response = try await aiManager.sendMessage(text: text)
            let aiMessage = ChatMessage(content: response, isUser: false)
            await MainActor.run {
                messages.append(aiMessage)
                onMessagesUpdated?()
            }
        }
        catch {
            let description = error.localizedDescription + "\(error)"
            let content: String
            if description.contains("429") || description.contains("quota") || description.contains("resourceExhausted") {
                content = "Şu an çok fazla istek gönderildi, biraz bekleyip tekrar dene. ⏳"
            } else {
                content = "Bir hata oluştu, tekrar dene."
            }
            let errorMessage = ChatMessage(content: content, isUser: false)
            await MainActor.run {
                messages.append(errorMessage)
                onMessagesUpdated?()
            }
        }
    }
    
}
