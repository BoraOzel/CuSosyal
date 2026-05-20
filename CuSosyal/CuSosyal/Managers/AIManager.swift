//
//  AIManager.swift
//  CuSosyal
//
//  Created by Bora Özel on 12/5/26.
//

import Foundation
import GoogleGenerativeAI

protocol AIManagerInterface: AnyObject {
    func startChatSession(userName: String, userTags: [Tags], clubs: [String], events: [String])
    func sendMessage(text: String) async throws -> String
    static func loadApiKey() -> String
}

class AIManager {
    
    static let shared = AIManager()
    
    private init() { }
    
    private var chat: Chat?
    
}

extension AIManager: AIManagerInterface {
    
    func startChatSession(userName: String, userTags: [Tags], clubs: [String], events: [String]) {
        let apiKey = Self.loadApiKey()

        let tagsString = userTags.isEmpty ? "Belirtilmemiş" : userTags.map({ $0.rawValue }).joined(separator: ", ")
        let clubsString = clubs.isEmpty ? "Henüz kulüp bulunmuyor." : clubs.map({ "- \($0)" }).joined(separator: "\n")
        let eventsString = events.isEmpty ? "Henüz etkinlik bulunmuyor." : events.joined(separator: "\n")

        let systemPrompt = """
        Sen "Çü Sosyal" uygulamasının resmi kampüs yapay zeka asistanısın.
        Karşındaki kullanıcının adı: \(userName).
        Kullanıcının ilgi alanları: \(tagsString).

        Uygulamada kayıtlı kulüpler (YALNIZCA bu listedeki kulüpleri öner, listede olmayan hiçbir kulübü uydurma veya isim değiştirme):
        \(clubsString)

        Uygulamada kayıtlı etkinlikler (YALNIZCA bu listedeki etkinlikleri öner, listede olmayan hiçbir etkinliği uydurma):
        \(eventsString)

        Görevlerin ve Kuralların:
        1. Kullanıcıya sadece yukarıdaki listedeki kulüpler ve etkinlikler hakkında yardım et.
        2. Yanıtlarını verirken kullanıcının ilgi alanlarını (\(tagsString)) göz önünde bulundur.
        3. Kampüsteki enerjik, samimi ve yardımsever bir öğrenci gibi konuş. Resmi dilden uzak dur, emojiler kullanabilirsin.
        4. Kampüs dışı (örneğin siyaset, tıp, karmaşık matematik vb.) sorular sorulursa kibarca konuyu kampüse ve etkinliklere geri getir.
        5. Listede olmayan bir kulüp veya etkinlik sorulursa, uygulamada kayıtlı olmadığını açıkça belirt.
        """
        
        let model = GenerativeModel(
            name: "gemini-2.5-flash",
            apiKey: apiKey,
            systemInstruction: ModelContent(role: "system", parts: systemPrompt)
        )
        
        self.chat = model.startChat()
    }
    
    func sendMessage(text: String) async throws -> String {
        guard let chat = chat else {
            throw NSError(domain: "AIManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Chat henüz başlatılmadı."])
        }
        
        let response = try await chat.sendMessage(text)
        
        return response.text ?? "Üzgünüm, ne demek istediğini tam anlayamadım."
    }
    
    static func loadApiKey() -> String {
        guard
            let path = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict["API_KEY"] as? String
        else {
            fatalError("GenerativeAI-Info.plist bulunamadı veya API_KEY eksik")
        }
        return key
    }
    
}


