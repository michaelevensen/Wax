//
//  PAUSPodcastDataManager.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import Foundation

class PAUSPodcastDataManager: NSObject, NSXMLParserDelegate {
    
    var delegate: PAUSPodcastDataManagerProtocol?
    
    // sources
    var result = [[PAUSPodcastModel]]()
    
    // from sources
    var sources = [String]() // sources
    
    override init() {
        //
    }
    
    // MARK: Data Loading
    private func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"com.pause", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    private func readFromURL(url: String, success: ((result: NSData!) -> Void)) {
        
        loadDataFromURL(NSURL(string: url)!, completion:{(data, error) -> Void in
            
            if let urlData = data {
                success(result: urlData)
            }
        })
    }
    
    // MARK: Data from external URL (JSON)
    func fetchFromSources(sources: [String: Int]) {
        
        // iterate through sources
        for (source, limit) in sources {
            
            // add to sources list
            self.sources.append(source)
            
            // get sources
            self.getSource(source, limitTo: limit)
        }
    }
    
    // generate random number
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    
    private func getSource(sourceURL: String, limitTo: Int?=5) {
        
        // url for fetching (through google feed api)
        var url = "https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&q=\(sourceURL)&num=\(limitTo!)"
        
        self.readFromURL(url, { (data) -> Void in
            
            // set up model array for sources
            var source = [PAUSPodcastModel]()
            
            // get
            let json = JSON(data: data)
            
            // load podcasts
            if let entries = json["responseData"]["feed"]["entries"].arrayValue {
            
                // loop through entries
                for entry in entries {
                    
                    var title: String? = escape(entry["author"].stringValue!)
                    var episodeTitle: String? = escape(entry["title"].stringValue!)
                    
                    // escape and process summary
                    var summaryRaw: String? = entry["content"].stringValue
                    var summaryStripped = escape(summaryRaw!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil))
                    
                    // random category
                    var category = ""
                    var categoryNum: Int? = entry["categories"].arrayValue?.count
                    
                    if categoryNum>0 {
                        var randomCategoryNum = Int(arc4random_uniform(UInt32(categoryNum!)))
                        var categoryString: String? = entry["categories"][randomCategoryNum].stringValue!
                        var escapedCategory = escape(categoryString!)
                        category = escapedCategory.capitalizedString
                    }
                    
                    // fetch media url
                    var mediaURL: String? = entry["mediaGroups"][0]["contents"][0]["url"].stringValue
                    
                    //pub date
//                    var pubDate: String? = entry["publishedDate"].stringValue
                    var publishedDate: NSDate? = NSDate()
                    
                    var length: Int? = self.randomInt(20, max: 60) // random time
                    var numberOfListeners: Int? = 0
                    var reviewScore: Double? = 0.0
                    var tags: NSArray? = []
                    
                    // check for staff pick, only the first feed
                    var staffPick: Bool = true
                    if json["responseData"]["feed"]["title"].stringValue == "Pause Staff Picks" {
                        staffPick = false // hidden is false
                    }
                    
                    // podcast model object
                    var podcastEntry = PAUSPodcastModel(title: title, episodeTitle: episodeTitle, publishedDate: publishedDate, summary: summaryStripped, category: category, length: length, numberOfListeners: numberOfListeners, reviewScore: reviewScore, tags: tags, staffPick: staffPick, mediaURL: mediaURL)
                    
                    // add podcast to array
                    source.append(podcastEntry)
                }
                
                // finished: add to global results array
                self.result.append(source)
                
                // wait until all sources have been processed
                if self.sources.count==self.result.count {
                    self.delegate?.didReceiveResults(self.result)
                }
            }
        })
    }
    
}

// protocol
protocol PAUSPodcastDataManagerProtocol {
    func didReceiveResults(results: [[PAUSPodcastModel]])
}



