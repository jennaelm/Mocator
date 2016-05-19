//
//  ChatListViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ModelDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let model: Model = Model.sharedInstance()
    var chatBuddiesArray : [ChatBuddy]?
    var selectedChatBuddy : ChatBuddy?
    var chatBuddyNames = [String]()
    var chatBuddyImages = [UIImage]()
    var meUserId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        self.model.delegate = self
        self.meUserId = model.meIDGlobal
        
        setUpRevealController()
        fetchChatBuddies()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        // TO DO : Query for new chats (?)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }
    
    func fetchChatBuddies() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "ChatBuddy")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch _ {
            results = nil
            // labor of love error handling
        }
        
        if results != nil {
            self.chatBuddiesArray = results as? [ChatBuddy]!
            self.chatBuddiesArray?.sortInPlace({ $0.lastMessageDate!.compare($1.lastMessageDate!) == .OrderedDescending })
            
            for eachChatBuddy in self.chatBuddiesArray! {
                self.chatBuddyNames.append(eachChatBuddy.name!)
                let profileImage = UIImage(data: eachChatBuddy.profilePhotos!)
                self.chatBuddyImages.append(profileImage!)
            }
            
        }
    }

// TableView DataSource & Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chatBuddiesArray?.count > 0 {
            return self.chatBuddiesArray!.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatListCell")
        
        if self.chatBuddiesArray?.count > 0 {
            cell!.textLabel!.text = self.chatBuddyNames[indexPath.row]
            cell!.imageView!.image = self.chatBuddyImages[indexPath.row]
            
        } else {
            cell!.textLabel!.text = "No chats to show :( #unpopular"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.chatBuddiesArray?.count > 0 {
            self.selectedChatBuddy = self.chatBuddiesArray![indexPath.row]
        }
        self.tableView.resignFirstResponder()
        self.performSegueWithIdentifier("goChat", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goChat" {
            super.prepareForSegue(segue, sender: self)
            let navController = segue.destinationViewController as! UINavigationController
            let chatViewController = navController.viewControllers.first as! ChatUpMormonViewController
            chatViewController.mormonChatBuddyID = self.selectedChatBuddy?.userID
            chatViewController.senderId = self.meUserId
            chatViewController.senderDisplayName = self.selectedChatBuddy?.name
        }
    }
    
// Model Delegate Methods
    func errorUpdating(error: NSError) {
        print("Error updating model in Chat List : \(error.localizedDescription)")
    }
    func modelUpdated() {
        // reload tableView.
    }
    
    func newMessages() {
        // Download messages (?)
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
