//
//  PAUSCollectionViewController.swift
//  Pause
//
//  Created by Michael Nino Evensen on 11/12/14.
//  Copyright (c) 2014 Pause. All rights reserved.
//

import UIKit

let reuseIdentifier = "PAUSPodcastCell"

class PAUSCollectionViewController: UICollectionViewController, PAUSPodcastDataManagerProtocol {
    
    @IBOutlet var customCollectionViewScrollView: UIScrollView!

    // podcast pages
    var pageSize = CGSizeZero
    var pageSpacing: CGFloat = 20 // interitem spacing
    var pageMargin: CGFloat = 50 // page size margins

    // data
    var podcastResults: [PAUSPodcastModel] = []
    var podcastData = PAUSPodcastDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load from xib
        self.collectionView?.registerNib(UINib(nibName: "PAUSPodcastCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        println(self.podcastResults.count)
        
        // set page sizing
        if let size = self.setupPages((self.collectionView?.frame.size)!) {
        
            self.setupCollectionViewInsetWithSize(size) // inset
            self.setupScrollViewWithSize() // scrollview
        }
        
        // set scrollview delegate
        self.customCollectionViewScrollView.delegate = self
    
        // disable default recognizer
        self.collectionView?.addGestureRecognizer(self.customCollectionViewScrollView.panGestureRecognizer)
        self.collectionView?.panGestureRecognizer.enabled = false
        
        // podcast data
        self.podcastData.delegate = self
        self.podcastData.fromFile("Podcasts") // Podcasts.json
    }
    
    // MARK: Get Podcasts
    func didReceiveResults(results: [PAUSPodcastModel]) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            // set results
            self.podcastResults = results
            
            // reload
            self.setupScrollViewWithSize() // update scrollview
            self.collectionView?.reloadData()
        })
    }
    
    // MARK: Pages Sizing Setup
    func setupPages(size: CGSize) -> CGSize? {
        
        // set page size
        pageSize.width = size.width - self.pageSpacing
        pageSize.height = size.height
        
        // margin
        pageSize.width -= self.pageMargin
        pageSize.height -= self.pageMargin
      
        return pageSize
    }
    
    // MARK: Set CollectionViewInset
    func setupCollectionViewInsetWithSize(size: CGSize) {

        let calculatedContentInset = ((self.collectionView?.frame.size.width)! - size.width) / 2
        self.collectionView?.contentInset = UIEdgeInsetsMake(0, calculatedContentInset, 0, calculatedContentInset)
    }
    
    // MARK: ScrollView Sizing Setup
    func setupScrollViewWithSize() {
        
        // setup scrollview with page size
        self.customCollectionViewScrollView.bounds = CGRect(origin: CGPointZero, size: CGSize(width: self.pageSize.width + self.pageSpacing, height: self.pageSize.height))
        
        // set proper content size
        let scrollContentSize = ((self.pageSize.width + self.pageSpacing) * CGFloat(self.podcastResults.count))
        self.customCollectionViewScrollView.contentSize = CGSize(width: scrollContentSize, height: self.pageSize.height)
    }
    
    // MARK: ScrollView Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    
        // custom interitemspacing: this must be set in the view controller for proper scrollview content size
        return self.pageSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // set a pagesize defined by the collectionview.bounds.width
        // needs to be set and calculated here
        
        return pageSize
    }
    

    // MARK: Overriding default UICollectionViewScroll behavior
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (scrollView==self.customCollectionViewScrollView) { //ignore collection view scrolling callbacks
            
            var contentOffset = scrollView.contentOffset
            
            contentOffset.x = contentOffset.x - (self.collectionView?.contentInset.left)!
            self.collectionView?.contentOffset = contentOffset
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.podcastResults.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let podcastCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PAUSPodcastCell
    
        // setup content
        podcastCell.PAUSPodcastTitle.text = self.podcastResults[indexPath.row].title
        podcastCell.PAUSPodcastEpisodeTitle.text = self.podcastResults[indexPath.row].episodeTitle
        podcastCell.PAUSPodcastSummary.text = self.podcastResults[indexPath.row].summary
        podcastCell.PAUSPodcastDurationAndCategory.text = "\(self.podcastResults[indexPath.row].length) minutes of \(self.podcastResults[indexPath.row].category)"
        
        return podcastCell
    }
    
    // MARK: Touch
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as PAUSPodcastCell
        
        // trigger read more
        cell.playPodcast()
    }
}
