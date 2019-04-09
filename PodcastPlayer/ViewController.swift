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
    
    private var rssItems: [RSSItem]?
    
    var itemSizeFactor: CGFloat = 1.0
    {
        didSet {
            configureCollectionView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        
        // fetchData("https://developer.apple.com/news/rss/news.rss")
        
        fetchData(url: "https://daringfireball.net/thetalkshow/rss")
    }

   
    private func fetchData(url: String) {
        
        let feedParser = FeedParser()
        feedParser.parseFeed(url: url) { (rssItems) in
            self.rssItems = rssItems
            
        OperationQueue.main.addOperation(
            { self.collectionView.reloadData()
                
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
   



    
}

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

extension ViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        if let podCastItem =  collectionView.item(at: indexPaths.first!) as? PodCastItemView {
        
            self.audioPlayerView.loadAudio(audioFilePath: podCastItem.url!, type: .url)
        }
    
    
    }
    
   
}

