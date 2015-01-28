//
//  PAUSPodcastModel.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import Foundation

class PAUSPodcastModel: NSObject, Printable {
    
    let title: String
    let episodeTitle: String
    let publishedDate: NSDate
    let summary: String
    let category: String
    let length: Int
    let numberOfListeners: Int
    let reviewScore: Double
    let tags: NSArray
    let staffPick: Bool
    let mediaURL: String
    
    // init
    init(title: String?, episodeTitle: String?, publishedDate: NSDate?, summary: String?, category: String?, length: Int?, numberOfListeners: Int?, reviewScore: Double?, tags: NSArray?, staffPick: Bool?, mediaURL: String?) {
        self.title = title ?? ""
        self.episodeTitle = episodeTitle ?? ""
        self.publishedDate = publishedDate ?? NSDate()
        self.summary = summary ?? ""
        self.length = length ?? 0
        self.numberOfListeners = numberOfListeners ?? 0
        self.category = category ?? ""
        self.reviewScore = reviewScore ?? 0.0
        self.tags = tags ?? []
        self.staffPick = staffPick ?? false
        self.mediaURL = mediaURL ?? ""
    }
}
