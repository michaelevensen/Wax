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
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    // podcast pages
    var pageSize = CGSizeZero
    var pageSpacing: CGFloat = 20 // interitem spacing

    // page size margins
    var topMargin: CGFloat = 20
    var topBottomPageMargin:CGFloat = 40
    var leftRightPageMargin: CGFloat = 10

    // data
    var podcastResult = [PAUSPodcastModel]()
    var podcastData = PAUSPodcastDataManager() // data manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load from xib
        self.collectionView?.registerNib(UINib(nibName: "PAUSPodcastCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
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
        
        // get from sources
        self.podcastData.fetchFromSources(["http://feeds.feedburner.com/github/YjTd&num=10": 15])
        
        // animate activity indicator
        self.activity.startAnimating()
    }
    
    // MARK: Finished getting all Sources
   func didReceiveResults(results: [[PAUSPodcastModel]]) {

        dispatch_async(dispatch_get_main_queue(), {

            // appending
            for podcastArray in results {
                
                for podcast in podcastArray {
                    // set results
                    self.podcastResult.append(podcast)
                }
            }
            
            // shuffle
            self.podcastResult.shuffle()
            
            // stop animating activity indicator
            self.activity.stopAnimating()
            
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
        pageSize.width -= self.leftRightPageMargin
        pageSize.height -= self.topBottomPageMargin
        
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
        let scrollContentSize = ((self.pageSize.width + self.pageSpacing) * CGFloat(self.podcastResult.count))
        self.customCollectionViewScrollView.contentSize = CGSize(width: scrollContentSize, height: self.pageSize.height)
    }
    
    // MARK: ScrollView Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    
        // custom interitemspacing: this must be set in the view controller for proper scrollview content size
        return self.pageSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
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
        return self.podcastResult.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let podcastCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PAUSPodcastCell
    
        // setup content
        podcastCell.PAUSPodcastTitle.text = self.podcastResult[indexPath.row].title
        podcastCell.PAUSPodcastEpisodeTitle.text = self.podcastResult[indexPath.row].episodeTitle
        podcastCell.PAUSPodcastSummary.text = self.podcastResult[indexPath.row].summary
        podcastCell.PAUSPodcastDurationAndCategory.text = "\(self.podcastResult[indexPath.row].length) minutes of \(self.podcastResult[indexPath.row].category)"
        podcastCell.PAUSStaffPick.hidden = self.podcastResult[indexPath.row].staffPick
        
        // set media url
        podcastCell.url = self.podcastResult[indexPath.row].mediaURL
        
        return podcastCell
    }
    
    // MARK: Touch
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as PAUSPodcastCell
        
        // trigger read more
        cell.playPodcast(cell.url)
    }
}
