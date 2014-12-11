//
//  PAUSPodcastShowParser.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import UIKit

class PAUSPodcastShowParser: PAUSXMLParserDelegate {

    var podcast = PAUSPodcastModel(title: "", episodeTitle: "", summary: "", category: "", length: 0, numberOfListeners: 0, reviewScore: 0.0, tags: [])
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        self.makePodcast(PAUSXMLParserDelegate.self, elementName: elementName, parser: parser)
    }
    
    override func finishedPodcast(s: String) {
//        self.podcast.setValue(s, forKey: self.child.name)
        
        println(s)
    }
    
}
