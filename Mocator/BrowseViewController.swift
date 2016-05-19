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
    
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let model: Model = Model.sharedInstance()
    let refresher = UIRefreshControl()
    
    var collectionViewLayout: CustomImageFlowLayout!
    var locationManager: CLLocationManager!
    var selectedMormon : Mormon?
    var discoveryPreferences : DiscoveryPreferences?
    var location : CLLocation?
    var genderPreferences : [String]?
    var lookingForPreferences : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        setUpRevealController()
        setupLocationManager()
        
        self.locationManager.startUpdatingLocation()
        
        if let disPref = DiscoveryPreferences.loadSaved() {
            self.discoveryPreferences = disPref
        } else {
            setUpDiscoveryPreferences()
        }
        
        var refreshControl = UIRefreshControl()
        refreshControl = refresher
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        self.collectionViewLayout = CustomImageFlowLayout()
        self.collectionView.collectionViewLayout = collectionViewLayout
   
        self.model.delegate = self
        self.model.fetchSelfFromCoreData()
        
        refresher.addTarget(self, action: #selector(BrowseViewController.refreshMormons), forControlEvents: .ValueChanged)
        
        self.genderPreferences = self.discoveryPreferences!.returnArrayOfGenders()
        self.lookingForPreferences = self.discoveryPreferences!.returnArrayOfTypes()
        
        if self.location != nil {
            model.updateLocationInCloudKit(self.location!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailSegue" {
            let detailMormonViewController = segue.destinationViewController as! DetailMormonViewController
            detailMormonViewController.detailMormon = self.selectedMormon
        }
    }

// Refreshing
    
    func refreshMormons() {
        if self.location != nil {
            model.updateLocationInCloudKit(self.location!)
            model.fetchPersons(self.location!, radiusInMeters: 300000, genders: self.genderPreferences!, lookingFor: self.lookingForPreferences!)
        }
        refresher.endRefreshing()
    }
    
// Discovery Preferences
    
    func setUpDiscoveryPreferences() {
        print(self.model.userGenderGlobal)
        if self.model.userGenderGlobal == "male" {
            discoveryPreferences = DiscoveryPreferences(maleBool: false, femaleBool: true, datesBool: true, friendsBool: true)
        } else if self.model.userGenderGlobal == "female" {
            discoveryPreferences = DiscoveryPreferences(maleBool: true, femaleBool: false, datesBool: true, friendsBool: true)
        } else {
            discoveryPreferences = DiscoveryPreferences(maleBool: true, femaleBool: true, datesBool: true, friendsBool: true)
        }
        
        discoveryPreferences!.save()
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
            print("Other status")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last as CLLocation? {
            self.location = loc
            model.fetchPersons(self.location!, radiusInMeters: 30000000, genders: self.genderPreferences!, lookingFor: self.lookingForPreferences!)
            locationManager.stopUpdatingLocation()
        }
    }

// Model Delegate
    
    func modelUpdated() {
         self.collectionView.reloadData()
    }
    
    func errorUpdating(error: NSError) {
       print("There was an error updating while browsing: \(error.localizedDescription)")
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
        if Model.sharedInstance().items.count > 0 {
            let object = Model.sharedInstance().items[indexPath.row]
            
            object.loadCoverPhoto { image in
                dispatch_async(dispatch_get_main_queue()) {
                cell.imgView.image = image
                }
            }
        }
        return cell
    }

// Side Bar Menu
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

}
