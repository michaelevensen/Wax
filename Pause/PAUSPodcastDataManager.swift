//
//  PAUSPodcastDataManager.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import Foundation

class PAUSPodcastDataManager {
    
    var delegate: PAUSPodcastDataManagerProtocol?
    
    // podcast results
    var results: [PAUSPodcastModel]?
    
    init() {
        // for delegate
    }

    // MARK: Data from URL
    private func readFromURL() {
        // read from url
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