//
//  ViewController.swift
//  PodcastPlayer
//
//  Created by Venky Venkatakrishnan on 11/3/18.
//  Copyright © 2018 Venky Venkatakrishnan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController   {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet var audioPlayerView: VUAudioPlayerView!
    
    @IBOutlet var buttonPopupPodCast: NSPopUpButton!
    
    private var rssItems: [RSSItem]?
    
    private var podCasts: [String: String] = ["The Talk Show": "https://daringfireball.net/thetalkshow/rss",
                                              "ATP":"http://atp.fm/episodes?format=rss",
                                              "Swift Over Coffee": "https://anchor.fm/s/572fc68/podcast/rss"]
    
    
    
    
    var itemSizeFactor: CGFloat = 1.0
    {
        didSet {
            configureCollectionView()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        configureCollectionView()
    
        
        self.buttonPopupPodCast.addItems(withTitles: Array(self.podCasts.keys))
        
        self.buttonPopupPodCast.selectItem(at: 0)
        
    }

   
    private func fetchData(url: String) {
        
        let feedParser = FeedParser()
        feedParser.parseFeed(url: url) { (rssItems) in
            self.rssItems = rssItems
            
        
            
        OperationQueue.main.addOperation(
            { self.collectionView.reloadData()
                print(self.rssItems![0])
                self.collectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
                self.audioPlayerView.loadAudio(audioFilePath: rssItems[0].url, type: .url, title: rssItems[0].title)
                
        })
            
        }
    }
    
    private func configureCollectionView() {
       
        let flowLayout = NSCollectionViewFlowLayout()
        
        let hInset: CGFloat = 10.0
        let vInset: CGFloat = 10.0
        
        let itemWidth: CGFloat = 400.0
        
        let itemHeight: CGFloat = 200.0
        
        flowLayout.itemSize = NSSize(width: itemWidth,
                                     height: itemHeight)
        
       
        flowLayout.sectionInset = NSEdgeInsets(top: vInset,
                                               left: hInset,
                                               bottom: vInset,
                                               right: hInset)
        
        // flowLayout.minimumInteritemSpacing = collectionView.frame.width / 2000
        
        // flowLayout.minimumLineSpacing = collectionView.frame.height / 2000
        
        
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.wantsLayer = true
        
        collectionView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
    }
    
    // MARK:- ViewController: Actions
   
    @IBAction func podCastSelectionChange(_ sender: NSPopUpButton) {
        
        guard let item = sender.selectedItem else { return }
        
        let podCastTitle = item.title
        // print("Selected Item: \(item.title)")
        
        if let podCastUrl = podCasts[podCastTitle] {
            fetchData(url: podCastUrl )
        }
        else
        {
            print("Error selecting Pod Cast with title: \(podCastTitle)")
        }
        
    }


    
}

// MARK:- NSCollectionViewDataSource
extension ViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rssItems = rssItems else {
            return 0
        }
        
        return rssItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item  = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PodCastItem"), for: indexPath)
        
        guard let podCastItem = item as? PodCastItemView else { return item }
        
        
        if let feedItem = rssItems?[indexPath.item] {
            
           podCastItem.feedItem = feedItem
        }
        
   
        return podCastItem
        
    }
}

// MARK:- NSCollectionViewDelegate
extension ViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
      
        if let podCastItem =  collectionView.item(at: indexPaths.first!) as? PodCastItemView {
        
            self.audioPlayerView.loadAudio(audioFilePath: podCastItem.url!, type: .url, title: podCastItem.title)
        }
    
    
    }
    
   
}

