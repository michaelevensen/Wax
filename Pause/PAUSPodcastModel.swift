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
    let summary: String
    let category: String
    let length: Int
    let numberOfListeners: Int
    let reviewScore: Double
    let tags: NSArray
    
    init(title: String?, episodeTitle: String?, summary: String?, category: String?, length: Int?, numberOfListeners: Int?, reviewScore: Double?, tags: NSArray?) {
        self.title = title ?? ""
        self.episodeTitle = episodeTitle ?? ""
        self.summary = summary ?? ""
        self.length = length ?? 0
        self.numberOfListeners = numberOfListeners ?? 0
        self.category = category ?? ""
        self.reviewScore = reviewScore ?? 0.0
        self.tags = tags ?? []
    }
}
