//
//  LibraryViewModel.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import Foundation

@MainActor
class LibraryViewModel {
    
   enum State {
       case loading
       case loaded
       case error(String)
   }
   
    private let service = SessionService.shared
    
    var sessions: [Sessions] = []
    var state: State = .loading
   
   var onStateChange: ((State) -> Void)?
    
    func fetchSessions() async {
        
        state = .loading
        onStateChange?(state)
       
        let result = await service.fetchSessions()
        
        switch result {
        case .success(let sessions):
            self.sessions = sessions
  //           print("fetchSessions Success:", sessions)
           self.state = .loaded
           onStateChange?(state)
            
        case .failure(let error):
           self.state = .error(error.localizedDescription)
//            print("ViewModel Error:", error.localizedDescription)
           onStateChange?(state)
        }
    }
      
}
