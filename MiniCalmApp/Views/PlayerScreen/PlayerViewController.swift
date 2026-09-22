//
//  PlayerViewController.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import UIKit

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
   private let viewModel: PlayerViewModel
   
   init(session: Sessions) {
      self.session = session
      self.viewModel = PlayerViewModel(session: session)
      super.init(nibName: "PlayerViewController", bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      return nil
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      configureUI()
      configureProgress()
      loadArtwork()
      bindViewModel()
      
      Task {
         await viewModel.loadDuration()
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
   
   // Slider Initial Setup
   private func configureProgress() {
      progressSlider?.minimumValue = 0
//      progressSlider?.maximumValue = Float(session.durationSeconds)
      progressSlider?.value = 0
      //      remainingTimeLabel?.text = formatTime(session.durationSeconds)
      elapsedTimeLabel?.text = "00:00"
      remainingTimeLabel?.text = "--:--"
   }
   
   //  ViewModel Binding
   private func bindViewModel() {
      viewModel.onDurationChange = { [weak self] duration in

          self?.progressSlider?.minimumValue = 0
          self?.progressSlider?.maximumValue = Float(duration)
          self?.remainingTimeLabel?.text = self?.formatTime(Int(duration))
      }
      
      
      viewModel.onTimeUpdate = { [weak self] elapsed, remaining, progress in
         
         self?.elapsedTimeLabel?.text = self?.formatTime(elapsed)
         
//         self?.remainingTimeLabel?.text = "-\(self?.formatTime(remaining) ?? "00:00")"
         
         self?.progressSlider?.value = progress
      }
      
      
      viewModel.onPlaybackStateChange = {
         [weak self] isPlaying in
         
         self?.playPauseButton?.setTitle(
            isPlaying ? "Pause" : "Play",
            for: .normal
         )
      }
      
      viewModel.onSpeedChange = {
         [weak self] speed in
         
         switch speed {
         case 1.0:
            self?.speedButton?.setTitle("1x", for: .normal)
            
         case 1.5:
            self?.speedButton?.setTitle("1.5x", for: .normal)
            
         case 2.0:
            self?.speedButton?.setTitle("2x", for: .normal)
            
         default:
            break
         }
      }
      
      
      viewModel.onError = { errorMessage in
         print("Player Error:", errorMessage)
      }
      
      
   }
   
   // load hero Image
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
      viewModel.seek(to: sender.value)
   }
   
   @IBAction func playPauseTapped(_ sender: UIButton) {
//      viewModel.playPause()
      Task {
         await viewModel.playPause()
      }
   }
   
   @IBAction func speedTapped(_ sender: UIButton) {
      viewModel.changeSpeed()
   }
   
   // MARK: - Helper Methods
   private func formatTime(_ seconds: Int) -> String {
      
      let minutes = seconds / 60
      let seconds = seconds % 60
      
      return String(
         format: "%02d:%02d",
         minutes,
         seconds
      )
   }
   
   
}

