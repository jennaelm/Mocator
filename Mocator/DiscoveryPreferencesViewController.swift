//
//  DiscoveryPreferencesViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit

class DiscoveryPreferencesViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var friendsButton: SettingButton!
    @IBOutlet weak var datesButton: SettingButton!
    @IBOutlet weak var maleButton: SettingButton!
    @IBOutlet weak var femaleButton: SettingButton!
    
    let model: Model = Model.sharedInstance()
    var discoveryPreferences : DiscoveryPreferences?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        setUpRevealController()
       
        if let disPref = DiscoveryPreferences.loadSaved() {
            self.discoveryPreferences = disPref
            updateButtons()
        } else {
            setUpDiscoveryPreferences()
        }
    }
    
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
        updateButtons()
    }
    
// Button Taps
    
    func updateButtons() {
        dispatch_after(1, dispatch_get_main_queue(), {
            self.maleButton.isChecked! = self.discoveryPreferences!.maleBool!
            self.femaleButton.isChecked! = self.discoveryPreferences!.femaleBool!
            self.friendsButton.isChecked! = self.discoveryPreferences!.friendsBool!
            self.datesButton.isChecked! = self.discoveryPreferences!.datesBool!
        })
    }
    
    @IBAction func maleButtonTapped(sender: AnyObject) {
        let newMaleBool = !self.discoveryPreferences!.maleBool!
        discoveryPreferences!.maleBool = newMaleBool
        discoveryPreferences!.save()
        preventFromCrashing("male")
    }
    
    @IBAction func femaleButtonTapped(sender: AnyObject) {
        let newFemaleBool = !self.discoveryPreferences!.femaleBool!
        discoveryPreferences!.femaleBool = newFemaleBool
        discoveryPreferences!.save()
        preventFromCrashing("female")
    }
    
    @IBAction func friendsButtonTapped(sender: AnyObject) {
        let newFriendsBool = !self.discoveryPreferences!.friendsBool!
        discoveryPreferences!.friendsBool = newFriendsBool
        discoveryPreferences!.save()
        preventFromCrashing("friends")
    }
    
    @IBAction func dateButtonTapped(sender: AnyObject) {
        let newDatesBool = !self.discoveryPreferences!.datesBool!
        discoveryPreferences!.datesBool = newDatesBool
        discoveryPreferences!.save()
        preventFromCrashing("dates")
    }
    
    func preventFromCrashing(button : String) {
        if discoveryPreferences!.maleBool == false && discoveryPreferences!.maleBool == false {
            if button == "male" {
                 discoveryPreferences!.femaleBool = true
            } else if button == "female" {
                discoveryPreferences!.maleBool = true
            }
        }
        
        if discoveryPreferences!.friendsBool == false && discoveryPreferences!.datesBool == false {
            if button == "friends" {
                discoveryPreferences!.datesBool = true
            } else if button == "dates" {
                discoveryPreferences!.friendsBool = true
            }
        }
        
        discoveryPreferences!.save()
        updateButtons()
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
