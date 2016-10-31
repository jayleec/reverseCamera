//
//  videoPlayerViewSwift.swift
//  SCRecorderExamples
//
//  Created by Jay on 7/13/16.
//
//

import Foundation
import GoogleMobileAds


class bannerAdView: UIViewController, UIAlertViewDelegate{

    @IBOutlet weak var bannerView: GADBannerView!
    var purchased = false
    
    var intAd = GADInterstitial(adUnitID: "Google Admob Code")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if(purchased){
            showAd()
        }
        
        
    }
    
    func showAd(){

            print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            bannerView.adUnitID = "Google Admob Code"
            bannerView.rootViewController = self
            bannerView.loadRequest(GADRequest())

    }

    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if intAd.isReady {
            intAd.presentFromRootViewController(self)
        } else {
            print("Ad wasn't ready")
        }
    }
    func createAd() -> GADInterstitial{
        let intAd = GADInterstitial(adUnitID: "Google Admob Code")
        intAd.loadRequest(GADRequest())
        return intAd
    }
    
}
