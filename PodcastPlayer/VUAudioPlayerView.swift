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
    
    var audioPlayer: AVPlayer?
    
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

    func loadAudio(audioFilePath: String, type: filePathType)
    {
        
        
        if let url = URL(string: audioFilePath) {
            self.audioPlayer = AVPlayer(url: url)
        }
        else
        {
            print("Error accessing URL")
        }
        
       
        
    }
    
    @IBAction func playAudio(sender: NSButton)
    {
        if let player = self.audioPlayer {
            player.play()
        }
    }
    
    @IBAction func stopPlayingAudio(sender: NSButton)
    {
        if let player = self.audioPlayer {
            player.pause()
            player.seek(to: CMTimeMake(value: 0, timescale: 1))
        }
    }
    
    @IBAction func seekForward30s(sender: NSButton)
    {
        if let player = self.audioPlayer {
            
            print("Current Time: \(player.currentTime())")
            
        }
    }
    @IBAction func seekBackwards30s(sender: NSButton)
    {
        if let player = self.audioPlayer {
            
            print("Current Time: \(player.currentTime())")
            
        }
        
    }
}
