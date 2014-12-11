//
//  PAUSPodcastCell.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import UIKit

class PAUSPodcastCell: UICollectionViewCell {

    @IBOutlet weak var PAUSPodcastTitle: UILabel!
    @IBOutlet weak var PAUSPodcastEpisodeTitle: UILabel!
    @IBOutlet weak var PAUSPodcastDurationAndCategory: UILabel!
    @IBOutlet weak var PAUSPodcastSummary: UITextView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // read more
    @IBAction func touchReadMore(sender: AnyObject) {
        
        println("Read more: \(self)")
        
        
        
    }
    
    // play podcast
    func playPodcast() {
        println("Play Podcast: \(self)")
    }
}
