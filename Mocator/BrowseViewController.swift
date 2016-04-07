//
//  BrowseViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CloudKit

class BrowseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ModelDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewLayout: CustomImageFlowLayout!
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let model: Model = Model.sharedInstance()
    var locationManager: CLLocationManager!
    let refreshControl = UIRefreshControl()
    
    var selectedMormon : Mormon?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Go be free
        
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.delegate = self
        
        self.collectionViewLayout = CustomImageFlowLayout()
        self.collectionView.collectionViewLayout = collectionViewLayout
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.model.delegate = self
        model.refresh()
        refreshControl.addTarget(model, action: "refresh", forControlEvents: .ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailSegue" {
            let detailMormonViewController = segue.destinationViewController as! DetailMormonViewController
            detailMormonViewController.detailMormon = self.selectedMormon
        }
    }

// SetUp Locationn & Location Delegate
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500.0 //0.5km
        locationManager.delegate = self
        
        CLLocationManager.authorizationStatus()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)  {
        switch status {
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
            case .AuthorizedWhenInUse:
                manager.startUpdatingLocation()
        default:
            //do nothing
            print("Other status")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last as CLLocation? {
            model.fetchPersons(loc, radiusInMeters: 3000)
        }
    }

// Model Delegate
    
    func modelUpdated() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    func errorUpdating(error: NSError) {
       print("There was an error updating")
    }
    
// Collection View DataSource and Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedMormon = Model.sharedInstance().items[indexPath.row]
        performSegueWithIdentifier("showDetailSegue", sender: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.sharedInstance().items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let object = Model.sharedInstance().items[indexPath.row]
        object.loadCoverPhoto { image in
            dispatch_async(dispatch_get_main_queue()) {
                cell.imgView.image = image
            }
        }
        return cell
    }
    

}
