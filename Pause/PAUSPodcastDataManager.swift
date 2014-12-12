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
    var resultSourceNum = 1
    
    // converting rss (xml) to json
    let jsonURL = "https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&q="
    
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
    
    // MARK: Data from external URL (XML)
    func fromURLS(urls: [String], dataType: String) {
       
        switch dataType {
            
            case "json":
                //
                
            break
            
            case "xml":
                
                // get results
                self.sources = urls
//                self.getResults(urls)
                
                self.fetch(urls[1], completion: { (source) -> Void in
                    
                    println(source)
                    
                    })
                
                
            break
            
            default:
                println("Please provide a data type.")
            break
        }
    }
    
//    func getResultFromSource(num: Int, completion: () -> Void) {
//        
//        self.fetch(self.sources[num], completion: { (source) -> Void in
//            self.result.append(source!)
//            self.resultSourceNum++ // iterate source
//            
//            println(source)
//        })
//    }
//    
//    func getResults(urls: [String]) {
//        
//        // fetch sources
//        getResultFromSource(self.resultSourceNum, completion: { () -> Void in
//            
//            self.getResultFromSource(self.resultSourceNum, completion: { () })
//        })
//       
//    }
    
    // get items from url
    func fetch(url: String, completion:(itemsFromSource: [PAUSPodcastModel]?) -> Void) {
        
         self.readFromURL(url, { (data) -> Void in
        
            var xml = SWXMLHash.parse(data)
            var source = [PAUSPodcastModel]() // src
            
            for elem in xml["rss"]["channel"]["item"] {
                
                var title: String? = elem["show"].element?.text
                var episodeTitle: String? = escape((elem["title"].element?.text)!)
                
                // strip out html characters
                var summary: String? = escape((elem["description"].element?.text)!.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil))
                
                // category and tags
                var category: String? = elem["category"].element?.text
                var tags: NSArray? = []
                
                // get and convert length
                var length: Int? = 0
                
                var numberOfListeners: Int? = 0
                var reviewScore: Double? = 0.0
                
                // add object
                var item = PAUSPodcastModel(title: title, episodeTitle: episodeTitle, summary: summary, category: category, length: length, numberOfListeners: numberOfListeners, reviewScore: reviewScore, tags: tags)
                
                source.append(item)
            }
            
            // send to completion handler
            completion(itemsFromSource: source)
        })
    }
}

// protocol
protocol PAUSPodcastDataManagerProtocol {
    func didReceiveResults(results: [PAUSPodcastModel])
}



