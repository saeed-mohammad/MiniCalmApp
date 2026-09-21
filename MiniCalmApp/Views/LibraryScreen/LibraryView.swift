//
//  ContentView.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import SwiftUI

struct LibraryView: View {

   @State private var viewModel = LibraryViewModel()
   @State private var state: LibraryViewModel.State = .loading

   var body: some View {
      NavigationStack {
         Group{
            switch state {
               
            case .loading:
               skeletonView
               
            case .loaded:
               sessionList
               
            case .error(let message):
               errorView(message: message)
               
            }
         }
           .navigationTitle("MiniCalm")
           .onAppear {
              viewModel.onStateChange = { newState in
                 state = newState
              }
           }
           .task {
              await viewModel.fetchSessions()
           }
           .refreshable {
              await viewModel.fetchSessions()
           }
       }
   }

   private var skeletonView: some View {
        List(0..<18, id: \.self) { _ in
            SessionSkeletonRow()
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

   private var sessionList: some View {
      List(viewModel.sessions) { session in
         
         NavigationLink {
            PlayerView(session: session)
         } label: {
            SessionRow(sessions: session)
         }
         .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
   }

   // Error Handling UI
   private func errorView(message: String) -> some View {
       VStack(spacing: 16) {
           Image(systemName: "wifi.exclamationmark")
               .font(.system(size: 48))
               .foregroundStyle(.secondary)
           
           Text("Couldn't Load Sessions")
               .font(.title2.weight(.semibold))
               .multilineTextAlignment(.center)
           
           Text(message)
               .font(.body)
               .foregroundStyle(.secondary)
               .multilineTextAlignment(.center)
               .padding(.horizontal)
           
           Button("Try Again") {
               Task {
                   await viewModel.fetchSessions()
               }
           }
           .buttonStyle(.borderedProminent)
           .padding(.top, 8)
       }
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .padding()
   }
}

#Preview {
    LibraryView()
}
