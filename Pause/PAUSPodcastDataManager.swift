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
    
    // podcast results
    var results: [PAUSPodcastModel]?
    
    override init() {
        // for delegate
    }
    
    // MARK: Data from external URL (JSON / XML)
    func fromURL(url: String, dataType: String) {
       
        switch dataType {
            
            case "json":
            
                self.readFromURL(url, { (data) -> Void in
                    
                    let json = JSON(data: data)
                    
                    // load podcasts
                    if let podcastArray = json.arrayValue {
                        
                        for podcastDict in podcastArray {
                            
                            var title: String? = podcastDict["showName"].stringValue
                            var episodeTitle: String? = podcastDict["episodeTitle"].stringValue
                            var summary: String? = podcastDict["description"].stringValue
                            var category: String? = podcastDict["category"].stringValue
                            var length: Int? = podcastDict["length"].integerValue
                            var numberOfListeners: Int? = podcastDict["numberOfListeners"].integerValue
                            var reviewScore: Double? = podcastDict["reviewScore"].doubleValue
                            var tags: NSArray? = []
                            
                            // podcast model object
                            var podcast = PAUSPodcastModel(title: title, episodeTitle: episodeTitle, summary: summary, category: category, length: length, numberOfListeners: numberOfListeners, reviewScore: reviewScore, tags: tags)
                            
                            // add podcast to array
                            self.results?.append(podcast)
                        }
                        
                        // finished - push to delegate
                        self.delegate?.didReceiveResults(self.results!)
                    }
                })
                
            break
            
            case "xml":
                
                // parse xml
                self.parseXML(url)
                
            break
            
            default:
                println("Please provide a data type.")
            break
        }
    }
    
    private func parseXML(url: String) {
        
        if let xmlURL = NSURL(string: url) {
            if let parser = NSXMLParser(contentsOfURL: xmlURL) {
                let podcasts = PAUSPodcastParser(name:"", parent: nil)
                
                parser.delegate = podcasts
                parser.parse()
                
                // finished parsing - push to delegate
                self.delegate?.didReceiveResults(podcasts.podcasts)
            }
            
        }
    }
    
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

    // MARK: Data from File
    func fromFile(path: String) {
        
        self.readFromFile(path, { (data) -> Void in
            
            self.results = []
            
            // SwiftyJSON
            let json = JSON(data: data)
            
            if let podcastArray = json.arrayValue {
                
                for podcastDict in podcastArray {
                    
                    var title: String? = podcastDict["showName"].stringValue
                    var episodeTitle: String? = podcastDict["episodeTitle"].stringValue
                    var summary: String? = podcastDict["description"].stringValue
                    var category: String? = podcastDict["category"].stringValue
                    var length: Int? = podcastDict["length"].integerValue
                    var numberOfListeners: Int? = podcastDict["numberOfListeners"].integerValue
                    var reviewScore: Double? = podcastDict["reviewScore"].doubleValue
                    var tags: NSArray? = []
                    
                    // podcast model object
                    var podcast = PAUSPodcastModel(title: title, episodeTitle: episodeTitle, summary: summary, category: category, length: length, numberOfListeners: numberOfListeners, reviewScore: reviewScore, tags: tags)
                    
                    // add podcast to array
                    self.results?.append(podcast)
                }
                
                // finished - push to delegate
                self.delegate?.didReceiveResults(self.results!)
            }
        })
    }
    
    // read JSON from file
    private func readFromFile(filePath: String, success: ((data: NSData) -> Void)) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // note: searches by Default the Resources directory
            let filePath = NSBundle.mainBundle().pathForResource(filePath, ofType: "json", inDirectory: nil)
            
            var readError:NSError?
            
            if let data = NSData(contentsOfFile: filePath!,
                options: NSDataReadingOptions.DataReadingUncached,
                error:&readError) {
                    success(data: data)
            }
        })
    }
}

// protocol
protocol PAUSPodcastDataManagerProtocol {
    func didReceiveResults(results: [PAUSPodcastModel])
}



