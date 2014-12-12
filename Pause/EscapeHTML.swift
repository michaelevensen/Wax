//
//  EscapeHTML.swift
//  EscapeHTML
//
//  Created by Matt Warren on 2014-06-12.
//  Copyright (c) 2014 Matt Warren. All rights reserved.
//

import Foundation

func escape(html: String) -> String{
    var result = html.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString("&mdash;", withString: "—", options: nil, range: nil)
    result = result.stringByReplacingOccurrencesOfString("&#039;", withString: "'", options: nil, range: nil)
    return result
}
