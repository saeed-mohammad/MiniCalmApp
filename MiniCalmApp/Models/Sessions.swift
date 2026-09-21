//
//  Session.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import Foundation

struct Sessions: Codable, Identifiable {
    let id: String
    let title: String
    let teacher: String
    let durationSeconds: Int
    let artworkUrl: String?
    let audioUrl: String
    let isPremium: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case teacher
        case durationSeconds = "duration_seconds"
        case artworkUrl = "artwork_url"
        case audioUrl = "audio_url"
        case isPremium = "is_premium"
    }
}

struct SessionsResponse: Codable {
    let sessions: [Sessions]
}
