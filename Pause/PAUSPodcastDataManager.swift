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
    
    // google feed api
    let googleFeedApiURL = "https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&q="
    
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
    func fetchFromSources(sources: [String]) {
        
        // feed limit
        var limitTo = 2
        
        // set sources
        self.sources = sources
        
        for source in sources {
            var feed = "\(googleFeedApiURL)\(source)&num=\(limitTo)"
            
            // get feed
            getSource(feed)
        }
    }
    
    
    private func getSource(url: String) {
        
        var source = [PAUSPodcastModel]()
        
        self.readFromURL(url, { (data) -> Void in
            
            let json = JSON(data: data)
            
            // load podcasts
            if let entries = json["responseData"]["feed"]["entries"].arrayValue {
            
                var title: String? = json["responseData"]["feed"]["title"].stringValue
            
                // loop through entries
                for entry in entries {
                    
                    var episodeTitle: String? = escape(entry["title"].stringValue!)
                    
                    // escape and process summary
                    var summaryRaw: String? = entry["content"].stringValue?
                    var summaryStripped = escape(summaryRaw!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil))
                    
                    // random category
                    var categoryNum = entry["categories"].arrayValue?.count
                    var randomCategoryNum = Int(arc4random_uniform(UInt32(categoryNum!)))
                    var category: String? = entry["categories"][randomCategoryNum].stringValue
                    
                    var length: Int? = 0
                    var numberOfListeners: Int? = 0
                    var reviewScore: Double? = 0.0
                    var tags: NSArray? = []
                    
                    // podcast model object
                    var podcastEntry = PAUSPodcastModel(title: title, episodeTitle: episodeTitle, summary: summaryStripped, category: category, length: length, numberOfListeners: numberOfListeners, reviewScore: reviewScore, tags: tags)
                    
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



