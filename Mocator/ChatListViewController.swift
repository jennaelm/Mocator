//
//  ChatListViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageHandlerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let messageHandler = MessageHandler()
    
    var chatBuddiesArray : [ChatBuddy]?
    var selectedChatBuddy : ChatBuddy?
    var meUserId : String?
    var profileImages : [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
    
        customizeNavBar()
        
        self.messageHandler.delegate = self
        self.meUserId = NSUserDefaults.standardUserDefaults().stringForKey("id")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setUpRevealController()
        fetchChatBuddies()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }

// Message Handler Delegate
    
    func newMessageReceived() {
        
    }
    
    func messagesDownloaded() {
        self.chatBuddiesArray = []
        fetchChatBuddies()
    }
    
// Core Data
    
    func fetchChatBuddies() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let request = NSFetchRequest(entityName: "ChatBuddy")
        var results : [AnyObject]?
        
        do {
            results = try context.executeFetchRequest(request)
        } catch {
            results = nil
            print("Error fetching chat buddies")
        }
        
        if results != nil {
            self.chatBuddiesArray = results as? [ChatBuddy]!
            self.chatBuddiesArray?.sortInPlace({ $0.lastMessageDate!.compare($1.lastMessageDate!) == .OrderedDescending })
            self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("chatListCell") as! ChatListTableViewCell
        
        if self.chatBuddiesArray?.count > 0 {
            let chatBuddy = self.chatBuddiesArray![indexPath.row]
            cell.nameLabel.text = chatBuddy.name
            let imageData = chatBuddy.profilePhotos
            cell.chatImage.image = UIImage(data: imageData!)

            for newMsgBuddy in self.messageHandler.newMessageBuddies {
                if cell.nameLabel.text == newMsgBuddy.name {
                    cell.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 128/255, blue: 255/255, alpha: 1.0)
                } else {
                    cell.backgroundColor = UIColor.whiteColor()
                }
            }
        } else {
            cell.nameLabel.text = "No chats to show #unpopular #misanthrope"
            cell.chatImage.image = UIImage(named: "sadblueface.png")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.chatBuddiesArray?.count > 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.backgroundColor = UIColor.whiteColor()
            
            self.selectedChatBuddy = self.chatBuddiesArray![indexPath.row]
            self.tableView.resignFirstResponder()
            self.performSegueWithIdentifier("goChat", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goChat" {
            let navController = segue.destinationViewController as! UINavigationController
            let chatViewController = navController.viewControllers.first as! ChatUpMormonViewController
                chatViewController.mormonChatBuddyID = self.selectedChatBuddy!.userID
                chatViewController.senderId = self.meUserId
                chatViewController.senderDisplayName = self.selectedChatBuddy!.name
        }
    }
    
// Model Delegate Methods
    
    func errorUpdating(error: NSError) {
        print("Error updating model in Chat List : \(error.localizedDescription)")
    }
    
    func modelUpdated() {
        // reload tableView.
    }
    
    
// User Interface
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func customizeNavBar() {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
        imgView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imgView
    }

}
