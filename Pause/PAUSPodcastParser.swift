//
//  PAUPodcastParser.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import UIKit

class PAUSPodcastParser: PAUSXMLParserDelegate {

    var podcasts = [PAUSPodcastModel]()
    
    var xmlTag = "item" // this should reference the important xml tag
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        // make podcast
        if elementName == self.xmlTag {
            self.makeChild(PAUSPodcastParser.self, elementName: elementName, parser: parser)
        }
    }
    
    override func finishedChild(s: String) {
        self.podcasts.append((self.child as PAUSPodcastShowParser).podcast)
    }

}
