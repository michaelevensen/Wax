//
//  PAUSCollectionViewFlowLayout.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import UIKit

class PAUSCollectionViewFlowLayout: UICollectionViewFlowLayout {
   
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // set horizontal scroll direction
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }    
}
