//
//  HelpTableViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 4/6/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import MessageUI

class HelpTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go be free
        
        customizeNavBar()
        setUpRevealController()
    }
    
    func customizeNavBar() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imageView
    }

    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
// In-App Email
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["contactmocator@gmail.com"])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                showSendMailErrorAlert()
            }
        }
        
        if indexPath.row == 3 {
            let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            self.performSegueWithIdentifier("toLoginScreen", sender: self)
        }
    }
    
    func showSendMailErrorAlert() {
        let emailAlertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        emailAlertController.addAction(dismissAction)
        
        self.presentViewController(emailAlertController, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    

// TableView DataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    

}
