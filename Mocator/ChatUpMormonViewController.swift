//
//  ChatUpMormonViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 4/7/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import CoreData

class ChatUpMormonViewController: JSQMessagesViewController, ModelDelegate {

    var messages = [JSQMessage]()
    var outgoingBubbleImageView : JSQMessagesBubbleImage!
    var incomingBubbleImageView : JSQMessagesBubbleImage!
    var mormonChatBuddy : Mormon?
    var allReceivedMessages = [MessagePlainObject]()
    var allSentMessages = [MessagePlainObject]()
    var catText : Bool?
    var chatBuddyName : String?
    
    let model : Model = Model.sharedInstance()
    var mormonChatBuddyID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go be free
        
        model.delegate = self
        model.downloadedMessages = []
        self.messages = []
        
        if self.mormonChatBuddyID == nil {
            self.mormonChatBuddyID = self.mormonChatBuddy!.mormonUserID
        }
        
        title = self.senderDisplayName
  
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        model.downloadMessagesFromCloudKit(self.mormonChatBuddyID!, senderID: senderId)
  
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.darkGrayColor())
    }
    
    func addMessage(id: String, text: String) {
        let addedMessage = JSQMessage(senderId: id, displayName: "", text: text)
        self.messages.append(addedMessage)
        print("messages : \(self.messages)")
    }
    
// Model Delegate
    
    func modelUpdated() {
        if model.downloadedMessages.count > 0 {
            for msg in model.downloadedMessages {
                addMessage(msg.senderID, text: msg.value)
            }
            
            if self.catText == true {
               meowMeowMeow()
            }
            
            self.finishReceivingMessageAnimated(true)
        } else {
            print("no downloaded messages")
        }
    }
    
    func errorUpdating(error: NSError) {
        print("error updating: \(error.localizedDescription)")
        // labor of love error handling---retry (?)
    }
    
    func newMessages() {
        model.downloadedMessages = []
        self.messages = []
        model.downloadMessagesFromCloudKit(self.mormonChatBuddyID!, senderID: senderId)
        model.updateChatBuddy(self.mormonChatBuddyID!)
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
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text)
        self.messages += [message]
        model.sendMessage(self.mormonChatBuddyID!, senderID: senderId!, text: text, date: date)
        model.updateChatBuddy(self.mormonChatBuddyID!)
        self.finishSendingMessageAnimated(true)
    }
    
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

// Meow Meow Meow
    
    func meowMeowMeow() {
        let date = NSDate()
        let text = "😻I😻L😻O😻V😻E😻Y😻O😻U😻"
        addMessage(senderId, text: text)
        model.sendMessage(self.mormonChatBuddyID!, senderID: senderId!, text: text, date: date)
        model.updateChatBuddy(self.mormonChatBuddyID!)
        self.catText = false
    }


}
