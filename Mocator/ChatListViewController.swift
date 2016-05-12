//
//  ChatListViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 2/15/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var chatBuddiesArray : [ChatBuddy]?
    var selectedChatBuddy : ChatBuddy?
    var chatBuddyNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Go be free
        
        setUpRevealController()
        fetchChatBuddies()
        
        print("chat buddies are: \(self.chatBuddiesArray)")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
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
            
            for eachChatBuddy in self.chatBuddiesArray! {
                self.chatBuddyNames.append(eachChatBuddy.name!)
            }
        }
    }
    
    func setUpRevealController() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
        let cell = UITableViewCell()
        if self.chatBuddiesArray?.count > 0 {
            cell.textLabel!.text = self.chatBuddyNames[indexPath.row]
        } else {
            cell.textLabel!.text = "No chats to show :( #unpopular"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Take user to conversation with this mormon")
        if self.chatBuddiesArray?.count > 0 {
            self.selectedChatBuddy = self.chatBuddiesArray![indexPath.row]
        }
        // perform segue
    }

}
