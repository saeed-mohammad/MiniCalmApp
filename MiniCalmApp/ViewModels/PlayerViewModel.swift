//
//  PlayerViewModel.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 22/09/26.
//

import Foundation
import AVFoundation

class PlayerViewModel {
   
   private let session: Sessions
   
   private var player: AVPlayer?
   private var timeObserver: Any?
   private var finishObserver: Any?
   
   private var playbackSpeed: Float = 1.0
   private var duration: Double = 0
   
   var onTimeUpdate: ((Int, Int, Float) -> Void)?
   var onPlaybackStateChange: ((Bool) -> Void)?
   var onSpeedChange: ((Float) -> Void)?
   var onError: ((String) -> Void)?
   var onDurationChange: ((Double) -> Void)?
   
   init(session: Sessions) {
      self.session = session
      
      configureAudioSession()
   }
   
   
   // AVFoundation Configuration
   private func configureAudioSession() {
      do {
         try AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default
         )
         
         try AVAudioSession.sharedInstance().setActive(true)
         
      } catch {
         print("Audio session error:", error.localizedDescription)
      }
   }

   // MARK: - Play Pause setup
   func playPause() async {

       if player == nil {
           let playerCreated = await createPlayer()

           guard playerCreated else { return }
       }

       guard let player else {
           return
       }

       if player.timeControlStatus == .playing {

           player.pause()
           onPlaybackStateChange?(false)

       } else {

           player.playImmediately(atRate: playbackSpeed)
           onPlaybackStateChange?(true)
       }
   }
   
   private func createPlayer() async -> Bool {

       guard let url = URL(string: session.audioUrl) else {
           onError?("Invalid audio URL")
           return false
       }

       let asset = AVURLAsset(url: url)

       do {
           let audioDuration = try await asset.load(.duration)

           guard audioDuration.seconds > 0 else {
               onError?("Invalid audio duration")
               return false
           }

           duration = audioDuration.seconds

           let playerItem = AVPlayerItem(asset: asset)

           player = AVPlayer(playerItem: playerItem)

           addTimeObserver()
           addFinishObserver()

           print("Actual duration:", duration)

           onDurationChange?(duration)

           return true

       } catch {
           onError?(error.localizedDescription)
           return false
       }
   }

   private func addTimeObserver() {

       guard let player else { return }

       let interval = CMTime(seconds: 0.5, preferredTimescale: 600)

       timeObserver = player.addPeriodicTimeObserver(
           forInterval: interval,
           queue: .main
       ) { [weak self] time in

           guard let self else { return }

           let elapsed = max(Int(time.seconds), 0)

//           let remaining = max(
//               self.session.durationSeconds - elapsed,
//               0
//           )
          let remaining = max(
              Int(self.duration) - elapsed,
              0
          )

           self.onTimeUpdate?(
               elapsed,
               remaining,
//               Float(elapsed)
               Float(time.seconds)
           )
       }
   }

   private func addFinishObserver() {

       finishObserver = NotificationCenter.default.addObserver(
           forName: .AVPlayerItemDidPlayToEndTime,
           object: player?.currentItem,
           queue: .main
       ) { [weak self] _ in

           guard let self else { return }

//           self.onPlaybackStateChange?(false)

//           self.onTimeUpdate?(
//               self.session.durationSeconds,
//               0,
//               Float(self.session.durationSeconds)
//           )
          
          // reset the slider after reach the end
          self.player?.seek(to: .zero) { _ in
             
             self.onPlaybackStateChange?(false)
             
             self.onTimeUpdate?(
               0,
               Int(self.duration),
               0
             )
          }
       }
   }

   // MARK: - Change Audio playback speed
    func changeSpeed() {

        switch playbackSpeed {
        case 1.0:
            playbackSpeed = 1.5

        case 1.5:
            playbackSpeed = 2.0

        default:
            playbackSpeed = 1.0
        }

        if let player,
           player.timeControlStatus == .playing {
            player.rate = playbackSpeed
        }

        onSpeedChange?(playbackSpeed)
    }

//   MARK: - Slider speed setup
    func seek(to value: Float) {

        guard let player else { return }

        let time = CMTime(
            seconds: Double(value),
            preferredTimescale: 600
        )

        player.seek(to: time)
    }

    
    deinit {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        if let finishObserver {
            NotificationCenter.default.removeObserver(finishObserver)
        }
    }
}
