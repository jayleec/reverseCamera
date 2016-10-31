//
//  shopViewController.swift
//  SCRecorderExamples
//
//  Created by Jay on 7/17/16.
//
//

import Foundation
import StoreKit


class shopViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate
 {
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! SCAppDelegate).managedObjectContext
    
    @IBOutlet weak var priceLabel: UILabel!
    
    var IAPPurchaed = false
    
    var bannerViewController  = bannerAdView()
    var videoPlayerViewController = SCVideoPlayerViewController()

    var products = [SKProduct]()
    var currentProduct = SKProduct()
    
    
    
    override func viewDidLoad() {
        //print("current Product: \(currentProduct)")
//        print("IAPPurchased: \(IAPPurchaed)")
        prepareForPurchase()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

    }
    
    //RESTORE
    @IBAction func restore(sender: AnyObject) {
        //USE to restore button
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let payment = SKPayment(product: currentProduct)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        print("Restoring")
        
        
    }
    
    //load product
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("products: \(response.products.count)")
        print(response.invalidProductIdentifiers.count)
        self.products = response.products
        
       
        for product in self.products{
           if product.productIdentifier == "instaBack.IAP.01"{
                currentProduct = product
            }
        }

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = currentProduct.priceLocale
        
        let priceString = formatter.stringFromNumber(currentProduct.price)
        
        priceLabel.text = String(priceString!)

        print("currentProduct productIdentifier\(currentProduct.productIdentifier)")
        
        
    }
    
    
    

    func prepareForPurchase(){
        let productSet : Set<String> = ["instaBack.IAP.01"]
        let request = SKProductsRequest(productIdentifiers: productSet)
        request.delegate = self
        request.start()
    }
    
    
    @IBAction func buyNow(sender: AnyObject) {
        
            if(IAPPurchaed){ //if user already bought
                showAleadyBoughtAlert()
                return
                
            }else{
                let payment = SKPayment(product: currentProduct)
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }


    }

    func showAleadyBoughtAlert(){
        let alertView = UIAlertView(title: "Warning", message: "You already bought this product", delegate: self, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    func setCoreData(){
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Product] {
          
            let obj = fetchResults[0] as NSManagedObject
            
            obj.setValue(1, forKey: "purchased")
            
            do {
                try obj.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        
        }
        
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState{
            case .Purchased:
                print("purchased")
                setCoreData()
                SKPaymentQueue().finishTransaction(transaction)
                break
            case .Failed:
                print("Failed")
                break
            case .Restored:
                print("Restored")
                SKPaymentQueue().finishTransaction(transaction)
                break
            case .Purchasing:
                print("Purchasing")
                setCoreData()
                break
            case .Deferred:
                print("Deferred")
                break
            }
        }
        
        
        
    }
    


}
