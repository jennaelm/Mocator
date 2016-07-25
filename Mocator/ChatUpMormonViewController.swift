//
//  ChatUpMormonViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 4/7/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ChatUpMormonViewController: JSQMessagesViewController, MessageHandlerDelegate {

    let messageHandler = MessageHandler()
    let mormonManager = MormonManager()
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView : JSQMessagesBubbleImage!
    var incomingBubbleImageView : JSQMessagesBubbleImage!
    var mormonChatBuddy : Mormon?
    var allReceivedMessages = [MessagePlainObject]()
    var allSentMessages = [MessagePlainObject]()
    var catText : Bool?
    var chatBuddyName : String?
    var mormonChatBuddyID : String?
    var meID : String?
    var loadingIndicator : MocatingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go be free
    
        self.meID = NSUserDefaults.standardUserDefaults().stringForKey("id")
        
        messageHandler.delegate = self
        messageHandler.downloadedMessages = []
        self.messages = []

        if self.mormonChatBuddyID == nil {
            self.mormonChatBuddyID = self.mormonChatBuddy!.mormonUserID
        }
        
        dispatch_async(dispatch_get_main_queue(),{
            self.loadingIndicator = MocatingIndicator(title: "Loading...", center: self.view.center)
            let loView = self.loadingIndicator.getViewActivityIndicator()
            self.view.addSubview(loView)
            self.view.bringSubviewToFront(loView)
            self.loadingIndicator.startAnimating()
            self.getTheMessages()
        })
        
        title = self.senderDisplayName
  
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
       
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.darkGrayColor())
    }
    
// Messages
    
    func addMessage(id: String, text: String) {
        let addedMessage = JSQMessage(senderId: id, displayName: "", text: text)
        self.messages.append(addedMessage)
    }
    
    func getTheMessages() {
        self.messageHandler.downloadSentMessagesFromCloudKit(self.mormonChatBuddyID!, senderID: self.meID!, completionClosure: { (success) in
            self.messageHandler.downloadReceivedMessagesFromCloudKit(self.mormonChatBuddyID!, senderID: self.meID!,
                completionClosure: { (success) in
                    self.messagesDownloaded()
            })
        })
    }
    
    func messagesDownloaded() {
        messageHandler.downloadedMessages.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
            
        if messageHandler.downloadedMessages.count > 0 {
            for msg in messageHandler.downloadedMessages {
                addMessage(msg.senderID, text: msg.value)
            }
            
            if self.catText == true {
                self.meowMeowMeow()
            }

            dispatch_async(dispatch_get_main_queue(),{
                self.finishReceivingMessageAnimated(true)
                self.loadingIndicator.stopAnimating()
        })

        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.loadingIndicator.stopAnimating()
            })
        }
    }
    
    func newMessageReceived() {
        self.messages = []
        self.collectionView.reloadData()
        getTheMessages()
        self.messageHandler.updateChatBuddyLastMessage(self.mormonChatBuddyID!)
    }

// JSQMessages Delegate

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

// JSQMessages DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        addMessage(senderId, text: text)
        messageHandler.sendMessage(self.mormonChatBuddyID!, senderID: senderId!, text: text, date: date)
        messageHandler.updateChatBuddyLastMessage(self.mormonChatBuddyID!)
        self.finishSendingMessageAnimated(true)
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

// Meow Meow
    
    func meowMeowMeow() {
        self.catText = false
        let date = NSDate()
        let text = "I LOVE YOU 😻😻"
        addMessage(self.meID!, text: text)
        messageHandler.sendMessage(self.mormonChatBuddyID!, senderID: senderId!, text: text, date: date)
        messageHandler.updateChatBuddyLastMessage(self.mormonChatBuddyID!)
        self.finishSendingMessageAnimated(true)
    }

// Button Taps
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toProfileSegue" {
            let profileViewController = segue.destinationViewController as! DetailMormonViewController
                profileViewController.detailMormon = self.mormonChatBuddy
                profileViewController.buddyUserID = self.mormonChatBuddyID
        }
    }
    

}
