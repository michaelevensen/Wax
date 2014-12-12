//
//  PAUXMLParserDelegate.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import Foundation

class PAUSXMLParserDelegate: NSObject {

    var name: String!
    var text = ""
    
    weak var parent: PAUSXMLParserDelegate?
    var child: PAUSXMLParserDelegate!
    
    required init(name: String, parent:PAUSXMLParserDelegate?) {

        self.name = name
        self.parent = parent
        super.init()
    }
    
    func makeChild(klass: PAUSXMLParserDelegate.Type, elementName: String, parser: NSXMLParser) {
        
        let del = klass(name: elementName, parent: self)
        self.child = del
        
        parser.delegate = del
    }
    
    func finishedChild(s: String) { // subclasses must override!
    
        fatalError("Subclass must implement finishedChild:!")
    }
    
}

extension PAUSXMLParserDelegate: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        
        self.text = self.text + string
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        if self.parent != nil {
            
            self.parent!.finishedChild(self.text)
            parser.delegate = self.parent
        }
    }
}
