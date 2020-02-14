//
//  PodCastViewItem.swift
//  PodcastPlayer
//
//  Created by Venky Venkatakrishnan on 11/4/18.
//  Copyright © 2018 Venky Venkatakrishnan. All rights reserved.
//

import Cocoa

class PodCastItemView: NSCollectionViewItem {

    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblDatePub: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!

    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 1.0
        }
    }
    var url: String?
   
   
    
    var feedItem: RSSItem! {
        
        didSet {
            
            lblTitle.stringValue = feedItem.title
            lblDatePub.stringValue = feedItem.pubDate
            lblDescription.stringValue = feedItem.description
            
            // lblDescription.attributedStringValue
            url = feedItem.url
            title = feedItem.title
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.borderWidth = 1
        self.view.layer?.borderColor = NSColor.darkGray.cgColor
        self.view.layer?.cornerRadius = 10
        
       
    }
    
    
    
}
