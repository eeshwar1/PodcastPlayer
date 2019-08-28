//
//  VUAudioPlayerView.swift
//  PodcastPlayer
//
//  Created by Venky Venkatakrishnan on 8/24/19.
//  Copyright © 2019 Venky Venkatakrishnan. All rights reserved.
//


import Cocoa
import AVFoundation

enum filePathType: Int {
    case url
    case file
}

@IBDesignable

class VUAudioPlayerView: NSView {
    
    @IBOutlet var contentView: NSView!
    
    @IBOutlet var playbackSlider: NSSlider!
    
    @IBOutlet var buttonPlay: NSButton!
    
    @IBOutlet var labelTimeElapsed: NSTextField!
    @IBOutlet var labelTimeLeft: NSTextField!
    
    @IBOutlet var labelTitle: NSTextField!
    
    
    var audioPlayer: AVPlayer?
    
    var playbackTimer: Timer?
    
    var currentItemDurationSeconds: Int = 0
    
    var formattedTimeZero = formattedTime(seconds: 0)
    
    required init?(coder decoder: NSCoder) {
        
        super.init(coder: decoder)
        
        /// Extract our name string from the multi-level class name. We need it to reference the NIB name
        /// This is just Best Practice. The NIB may be named anything you like but makes sense to be named
        /// the same as the class that drives it.
        
        let myName = type(of: self).className().components(separatedBy: ".").last!
        
        /// Get our NIB. This should never fail but it always pays to be careful
        /// In this case it gets the main Bundle but if this code is in a Framework then it might be another one,
        /// that's why we use that form of Bundle call
        
        if let nib = NSNib.init(nibNamed: myName, bundle: Bundle(for: type(of: self)))
        {
            
            /// You must instantiate a new view from the NIB attached to you as the owner,
            /// this will replace the one originally built at app start-up
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            
            /// Now create a new array of constraints by copying the old ones.
            /// We replace ourself as either the first or second item as appropriate in place of topView.
            /// We grab these now to apply after we add our sub-views
            
            var newConstraints: [NSLayoutConstraint] = []
            
            for oldConstraint in contentView.constraints {
                let firstItem = oldConstraint.firstItem === contentView ? self: oldConstraint.firstItem!
                let secondItem = oldConstraint.secondItem === contentView ? self: oldConstraint.secondItem
                newConstraints.append(NSLayoutConstraint(item: firstItem, attribute: oldConstraint.firstAttribute, relatedBy: oldConstraint.relation, toItem: secondItem, attribute: oldConstraint.secondAttribute, multiplier: oldConstraint.multiplier, constant: oldConstraint.constant))
            }
            for newView in contentView.subviews {
                self.addSubview(newView)
            }
            
            self.addConstraints(newConstraints)
        }
        
        
    
        
    }

    func loadAudio(audioFilePath: String, type: filePathType, title: String?)
    {
        
        if let url = URL(string: audioFilePath) {
            
            let playerItem: AVPlayerItem = AVPlayerItem(url: url)
            self.audioPlayer = AVPlayer(playerItem: playerItem)
            
            let duration: CMTime = playerItem.asset.duration
            self.currentItemDurationSeconds = Int(duration.seconds)
            print("Loaded Audio file with duration: \(formattedTime(seconds: self.currentItemDurationSeconds)).")
            self.labelTimeLeft.stringValue = formattedTime(seconds: self.currentItemDurationSeconds)
            self.labelTimeElapsed.stringValue = formattedTimeZero
            self.buttonPlay.title = "Play"
            
            if let title = title {
                labelTitle.stringValue = title
            }
            else {
                labelTitle.stringValue = ""
            }
        }
        else
        {
            print("Error accessing URL: \(audioFilePath)")
        }
        
       
        
    }
    
    @IBAction func playAudio(sender: NSButton)
    {
        
        if let player = self.audioPlayer {
            
            if let currentItem =  player.currentItem {
                
                if player.rate == 0 {
                    player.play()
                    playbackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlaybackSlider), userInfo: nil, repeats: true)
                    self.playbackSlider.doubleValue = 0.0
                    self.playbackSlider.maxValue = 100.0
                
                    self.labelTimeLeft.stringValue =  formattedTime(seconds: Int(currentItem.duration.seconds))
                    buttonPlay.title = "Pause"
                    }
                 else {
                        player.pause()
                        buttonPlay.title = "Play"
                        playbackTimer?.invalidate()
                 }
            }
        }
        
     }
    

    
    @IBAction func stopPlayingAudio(sender: NSButton)
    {
        if let player = self.audioPlayer {
            player.pause()
            player.seek(to: CMTimeMake(value: 0, timescale: 1))
            if let timer = self.playbackTimer {
                timer.invalidate()
            }
            self.playbackSlider.floatValue = 0.0
            self.labelTimeLeft.stringValue = formattedTime(seconds: self.currentItemDurationSeconds)
            self.labelTimeElapsed.stringValue = formattedTimeZero
        }
    }
    
    @objc func updatePlaybackSlider()
    {
        if let player = self.audioPlayer {
            
            if let currentItem = player.currentItem {
                let currentValue: Double = player.currentTime().seconds * 100/currentItem.duration.seconds
                
                self.playbackSlider.doubleValue = currentValue
                let durationElapsed = Int(player.currentTime().seconds)
                let durationLeft = self.currentItemDurationSeconds - durationElapsed
                labelTimeElapsed.stringValue = formattedTime(seconds: durationElapsed )
                labelTimeLeft.stringValue = "-" + formattedTime(seconds: durationLeft)
                
            }
            
        }
        
    }
    
    @IBAction func playbackSliderValueChanged(_ playbackSlider: NSSlider) {
        
        let newTime =  (currentItemDurationSeconds * Int(playbackSlider.intValue))/100
        if let player = self.audioPlayer {
            player.seek(to: CMTimeMake(value: Int64(newTime), timescale: 1))
        }
        print("Slider Value: \(playbackSlider.intValue)")
    
    }
    @IBAction func seekForward30s(sender: NSButton)
    {
        if let player = self.audioPlayer {
            
            let currentTime = player.currentTime()
            let seekToTime = currentTime + CMTimeMake(value: 30, timescale: 1)
            player.seek(to: seekToTime)
            
            
        }
    }
    @IBAction func seekBackwards30s(sender: NSButton)
    {
        if let player = self.audioPlayer {
            
            let currentTime = player.currentTime()
            let seekToTime = currentTime - CMTimeMake(value: 30, timescale: 1)
            player.seek(to: seekToTime)
            
        }
        
    }
}
