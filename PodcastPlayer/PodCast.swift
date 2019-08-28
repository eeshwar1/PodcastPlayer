//
//  PodCast.swift
//  PodcastPlayer
//
//  Created by Venky Venkatakrishnan on 11/4/18.
//  Copyright © 2018 Venky Venkatakrishnan. All rights reserved.
//

import Foundation

struct RSSItem {
    
    var title: String
    var description: String
    var pubDate: String
    var url: String
}

// download xml from a server
// parse xml to foundation objects
// call back
class FeedParser : NSObject, XMLParserDelegate {
    
    private var rssItems: [RSSItem] = []
    private var currentElement: String = ""
    private var attributeDict: [String: String] = [:]
    private var currentTitle: String = ""
    {
        didSet {
            
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = ""
    {
        didSet {
            
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = "" {
        
        didSet {
            
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentUrl: String = "" {
        
        didSet {
            
            currentUrl = currentUrl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)? )
    {
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                if let error = error {
                    
                    print("ERROR: \(error.localizedDescription)")
                }
                
                return
            }
            
            // Parse XML data
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        
        
        task.resume()
     
    }
    
    
    // MARK: XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        self.currentElement = elementName
        // print("elementName: \(elementName)")
        if self.currentElement == "item" {
            self.currentTitle = ""
            self.currentDescription = ""
            self.currentPubDate = ""
            self.currentUrl = ""
        }
        self.attributeDict = attributeDict
        
    }
  
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
       // print("currentElement: \(currentElement)")
        switch currentElement
        {
            
            case "title": currentTitle  += string
            case "description": currentDescription += string
            case "pubDate": currentPubDate += string
            default: break
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "enclosure" {
            self.currentUrl += self.attributeDict["url"] ?? ""
        }
        if elementName == "item" {
            
            let rssItem = RSSItem(title: currentTitle, description: currentDescription, pubDate: currentPubDate, url: currentUrl)
            self.rssItems.append(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        parserCompletionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("ERROR: \(parseError.localizedDescription)")
    }
    
}
