//
//  PlayerViewController.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
   
   @IBOutlet private weak var artworkImageView: UIImageView!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var teacherLabel: UILabel!
   @IBOutlet private weak var elapsedTimeLabel: UILabel!
   @IBOutlet private weak var remainingTimeLabel: UILabel!
   @IBOutlet private weak var progressSlider: UISlider!
   @IBOutlet private weak var playPauseButton: UIButton!
   @IBOutlet private weak var speedButton: UIButton!
   
   private let session: Sessions
   private var player: AVPlayer?
   private var timeObserver: Any?
   private var playbackSpeed: Float = 1.0
   
   init(session: Sessions) {
      self.session = session
      super.init(nibName: "PlayerViewController", bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      return nil
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      configureAudioSession()
      configureUI()
      configureProgress()
      loadArtwork()
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
   
   // UI Initial Setup
   private func configureUI() {
      titleLabel?.text = session.title
      teacherLabel?.text = session.teacher
      
      elapsedTimeLabel?.text = "00:00"
      playPauseButton?.setTitle("Play", for: .normal)
      speedButton?.setTitle("1x", for: .normal)
   }
   
   
   private func configureProgress() {
      progressSlider?.minimumValue = 0
      progressSlider?.maximumValue = Float(session.durationSeconds)
      progressSlider?.value = 0
      
      remainingTimeLabel?.text = formatTime(session.durationSeconds)
   }
   
   // load Image
   private func loadArtwork() {

       artworkImageView?.image = UIImage(systemName: "music.quarternote.3")

       guard let artworkUrl = session.artworkUrl,
             let url = URL(string: artworkUrl) else {
           return
       }

       Task {
           do {
               let (data, _) = try await URLSession.shared.data(from: url)

               guard let image = UIImage(data: data) else {
                   return
               }

               artworkImageView?.image = image

           } catch {
               print("Artwork error:", error.localizedDescription)
           }
       }
   }
   
   
   @IBAction func sliderValueChanged(_ sender: UISlider) {
      guard let player else {
         return
      }
      
      let seconds = Double(sender.value)
      
      let time = CMTime(
         seconds: seconds,
         preferredTimescale: 600
      )
      
      player.seek(to: time)
      
      elapsedTimeLabel?.text = formatTime(Int(seconds))
      
      let remaining = max(
         session.durationSeconds - Int(seconds),
         0
      )
      
      remainingTimeLabel?.text = "-\(formatTime(remaining))"
   }
   
   @IBAction func playPauseTapped(_ sender: UIButton) {
      if player == nil {
         createPlayer()
      }
      
      guard let player else {
         print("Player could not be created")
         return
      }
      
      if player.timeControlStatus == .playing {
         player.pause()
         playPauseButton?.setTitle("Play", for: .normal)
         
      } else {
         player.playImmediately(atRate: playbackSpeed)
         playPauseButton?.setTitle("Pause", for: .normal)
      }
   }
   
   @IBAction func speedTapped(_ sender: UIButton) {
      switch playbackSpeed {
      case 1.0:
         playbackSpeed = 1.5
         
      case 1.5:
         playbackSpeed = 2.0
         
      default:
         playbackSpeed = 1.0
      }
      
      speedButton?.setTitle(
         "\(playbackSpeed)x",
         for: .normal
      )
      
      if let player,
         player.timeControlStatus == .playing {
         player.rate = playbackSpeed
      }
   }
   
   
   private func createPlayer() {
      
      guard let url = URL(string: session.audioUrl) else {
         print("Invalid audio URL")
         return
      }
      
      let player = AVPlayer(url: url)
      
      self.player = player
      
      addTimeObserver()
      
      NotificationCenter.default.addObserver(
         self,
         selector: #selector(playerDidFinish),
         name: .AVPlayerItemDidPlayToEndTime,
         object: player.currentItem
      )
   }
   
   private func addTimeObserver() {
      
      guard let player else {
         return
      }
      
      let interval = CMTime(
         seconds: 0.5,
         preferredTimescale: 600
      )
      
      timeObserver = player.addPeriodicTimeObserver(
         forInterval: interval,
         queue: .main
      ) { [weak self] time in
         
         guard let self else {
            return
         }
         
         let elapsed = max(time.seconds, 0)
         
         self.elapsedTimeLabel?.text =
         self.formatTime(Int(elapsed))
         
         let remaining = max(
            self.session.durationSeconds - Int(elapsed),
            0
         )
         
         self.remainingTimeLabel?.text =
         "-\(self.formatTime(remaining))"
         
         self.progressSlider?.value =
         Float(elapsed)
      }
   }
   
   @objc private func playerDidFinish() {
      
      playPauseButton?.setTitle("Play", for: .normal)
      
      progressSlider?.value = Float(session.durationSeconds)
      
      elapsedTimeLabel?.text = formatTime(session.durationSeconds)
      
      remainingTimeLabel?.text = "-00:00"
   }
   
   private func formatTime(_ seconds: Int) -> String {
      
      let minutes = seconds / 60
      let seconds = seconds % 60
      
      return String(
         format: "%02d:%02d",
         minutes,
         seconds
      )
   }
   
   deinit {
      
      if let timeObserver {
         player?.removeTimeObserver(timeObserver)
      }
      
      NotificationCenter.default.removeObserver(self)
   }
   
}

