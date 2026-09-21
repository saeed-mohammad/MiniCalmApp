//
//  SessionService.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import Foundation

class SessionService {

    static let shared = SessionService()

    private init() {}

   func fetchSessions() async -> Result<[Sessions], Error> {
           
           guard let url = URL(
               string: "https://gist.githubusercontent.com/Manojsuthar2000/441d8e745e124afe601fb85fb1c49a31/raw/sessions.json"
           ) else {
               return .failure(URLError(.badURL))
           }
           
           do {
               let (data, response) = try await URLSession.shared.data(from: url)
               
               guard let response = response as? HTTPURLResponse else {
                   return .failure(URLError(.badServerResponse))
               }
               
               guard 200...299 ~= response.statusCode else {
                   return .failure(URLError(.badServerResponse))
               }
               
               let result = try JSONDecoder().decode(
                   SessionsResponse.self,
                   from: data
               )
               
               return .success(result.sessions)
               
           } catch {
               print("SessionService Error:", error.localizedDescription)
               return .failure(error)
           }
       }
}
