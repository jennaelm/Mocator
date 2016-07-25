//
//  BrowseViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CloudKit

class BrowseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MormonManagerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    let mormonManager = MormonManager()
    
    var collectionViewLayout: CustomImageFlowLayout!
    var locationManager: CLLocationManager!
    var selectedMormon : Mormon?
    var discoveryPreferences : DiscoveryPreferences?
    var location : CLLocation?
    var genderPreferences : [String]?
    var lookingForPreferences : [String]?
    var mocatingIndicator : MocatingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        self.mormonManager.delegate = self

        customizeNavBar()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionViewLayout = CustomImageFlowLayout()
        self.collectionView.collectionViewLayout = collectionViewLayout
        
        self.mocatingIndicator = MocatingIndicator(title: "Mocating...", center: self.view.center)
        let miView = self.mocatingIndicator.getViewActivityIndicator()
        self.view.addSubview(miView)
        self.view.bringSubviewToFront(miView)
        self.mocatingIndicator.startAnimating()
        
        setUpRevealController()
        setupLocationManager()
        
        self.locationManager.startUpdatingLocation()
        
        if let disPref = DiscoveryPreferences.loadSaved() {
            self.discoveryPreferences = disPref
        } else {
            setUpDiscoveryPreferences()
        }
        
        self.genderPreferences = self.discoveryPreferences!.returnArrayOfGenders()
        self.lookingForPreferences = self.discoveryPreferences!.returnArrayOfTypes()
        
        refreshMormons()
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
            self.mormonManager.updateLocationInCloudKit(self.location!)
            self.mormonManager.fetchPersons(self.location!, genders: self.genderPreferences!, lookingFor: self.lookingForPreferences!)
        } else {
            self.location = CLLocation(latitude: 37, longitude: 122)
            self.mormonManager.fetchPersons(self.location!, genders: self.genderPreferences!, lookingFor: self.lookingForPreferences!)
        }
    }
    
// Discovery Preferences
    
    func setUpDiscoveryPreferences() {
        if NSUserDefaults.standardUserDefaults().stringForKey("gender") == "male" {
            discoveryPreferences = DiscoveryPreferences(maleBool: false, femaleBool: true, datesBool: true, friendsBool: true)
        } else if NSUserDefaults.standardUserDefaults().stringForKey("gender") == "female" {
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
        locationManager.distanceFilter = 500.0
        locationManager.delegate = self
        
        CLLocationManager.authorizationStatus()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)  {
        switch status {
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
            case .Denied:
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
            locationManager.stopUpdatingLocation()
        }
    }

// Model Delegate
    
    func modelUpdated() {
         self.collectionView.reloadData()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.mocatingIndicator.stopAnimating()
        
    }
    
    func errorUpdating(error: NSError) {
        self.mocatingIndicator.stopAnimating()
        let errorAlertController = UIAlertController(title: "Could Not Mocate", message: "Network error. Please try again later.", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "I Still Love You", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        errorAlertController.addAction(dismissAction)
        self.presentViewController(errorAlertController, animated: true, completion: nil)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
// Collection View DataSource and Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedMormon = self.mormonManager.items[indexPath.row]
        performSegueWithIdentifier("showDetailSegue", sender: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mormonManager.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        if self.mormonManager.items.count > 0 {
            let object = self.mormonManager.items[indexPath.row]
            
            object.loadCoverPhoto { image in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imgView.image = image
                }
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
            self.mormonManager.continueScrolling()
           print("reached end of content : scroll view did scroll called")
        }
    }

// User Interface
    
    func customizeNavBar() {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
        imgView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imgView
    }
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

}
