//
//  Common.swift
//  PodcastPlayer
//
//  Created by Venky Venkatakrishnan on 8/25/19.
//  Copyright © 2019 Venky Venkatakrishnan. All rights reserved.
//

import Foundation

func formattedTime(seconds inSeconds: Int) -> String {
    
   let hours = Int(inSeconds)/3600
   let minutes =  Int(inSeconds)/60 % 60
   let seconds = Int(inSeconds) % 60
    
   return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
}
