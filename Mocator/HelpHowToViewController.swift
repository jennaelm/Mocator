//
//  HelpHowToViewController.swift
//  Mocator
//
//  Created by Jenna Miller on 5/17/16.
//  Copyright © 2016 Jenna Miller. All rights reserved.
//

import UIKit
import StoreKit

class HelpHowToViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let productIdentifiers = Set(["mocatorsupport"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    var collectionViewLayout : CustomImageFlowLayout!
    var transactionInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go be free
        
        customizeUI()
        requestProductInfo()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        self.collectionViewLayout = CustomImageFlowLayout()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = collectionViewLayout
    }

// In-App Purchase
    
    func requestProductInfo() {
        let productRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            productRequest.delegate = self
            productRequest.start()
      
    }

    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
                successAlert()
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
                failureAlert()
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
            self.productsArray.append(p)
        }
    }
    
    func successAlert() {
        print("ALERT : transaction successful")
    }
    
    func failureAlert() {
        print("ALERT : transaction failed")
    }
    
    @IBAction func donatePressed(sender: AnyObject) {
        if transactionInProgress {
            return
        }
        if self.productsArray.count != 0 {
            let payment = SKPayment(product: self.productsArray[0] as SKProduct)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            self.transactionInProgress = true
        } else {
            print("products array count is zero")
        }
    }
    
// About the Team
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("teamCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let profileImgs = [UIImage(named: "Jenna"), UIImage(named: "Brett"), UIImage(named: "Rachel")]
        cell.imgView.image = profileImgs[indexPath.row]
        
        return cell
    }

// User Interface
    
    func customizeUI() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .ScaleAspectFill
        self.navigationItem.titleView = imageView
        
        self.donateButton.layer.cornerRadius = self.donateButton.frame.size.width/50
        self.donateButton.clipsToBounds = true
    }
    
}
