//
//  HelpFAQViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 5/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import MessageUI

class HelpFAQViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        customizeNavBar()
    }
    
    func customizeNavBar() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imageView
    }
    
// In-App Email
    
    @IBAction func contactUsTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["contactmocator@gmail.com"])
            mailComposerVC.setSubject("")
            mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let emailAlertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check email configuration in settings and try again.", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        emailAlertController.addAction(dismissAction)
        
        self.presentViewController(emailAlertController, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
