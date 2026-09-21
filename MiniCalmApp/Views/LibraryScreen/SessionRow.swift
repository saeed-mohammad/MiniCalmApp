//
//  SessionRow.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import SwiftUI

struct SessionRow: View {

    let sessions: Sessions

    var body: some View {

        HStack(spacing: 12) {

            if let artworkUrl = sessions.artworkUrl,
               let url = URL(string: artworkUrl) {

                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "photo")
                }
                .frame(width: 70, height: 70)


            } else {

                Image(systemName: "photo")
                    .frame(width: 70, height: 70)
                    .background(.gray.opacity(0.2))
            }
           

            VStack(alignment: .leading, spacing: 5) {

                Text(sessions.title)
                    .font(.headline)

                Text(sessions.teacher)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {

                    Text("\(sessions.durationSeconds / 60) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if sessions.isPremium {
                        Text("Premium")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
   SessionRow(
      sessions: Sessions(
         id: "s1",
         title: "Morning Calm",
         teacher: "Ranveer",
         durationSeconds: 600,
         artworkUrl: "https://picsum.photos/200?1",
         audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
         isPremium: true
     )
   )
}
