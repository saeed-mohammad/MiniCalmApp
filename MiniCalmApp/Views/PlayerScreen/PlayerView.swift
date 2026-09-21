//
//  PlayerView.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import SwiftUI

struct PlayerView: UIViewControllerRepresentable {

    let session: Sessions

    func makeUIViewController(context: Context) -> PlayerViewController {
       PlayerViewController(session: session)
    }

    func updateUIViewController(
        _ uiViewController: PlayerViewController,
        context: Context
    ) {
    }
}
