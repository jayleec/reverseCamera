//
//  videoPlayerViewOverride.swift
//  SCRecorderExamples
//
//  Created by Jay on 7/17/16.
//
//

import Foundation
import GoogleMobileAds

class fullAdView : UIViewController {
    
    
    var interstitial: GADInterstitial!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        
        interstitial = GADInterstitial(adUnitID: "Google Admob Code")
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "TEST DEVICE ID"]
        interstitial.loadRequest(request)
        
        

    }
    
    
    func showFullAd(){
        
        
        if(interstitial.isReady){
            interstitial.presentFromRootViewController(self)
        }else{
            print("ad is not ready")
        }
        
        createAndLoadInterstitial()
    }
    
    
    
    func createAndLoadInterstitial(){
        interstitial = GADInterstitial(adUnitID: "Google Admob Code")
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "TEST DEVICE ID"]
        interstitial.loadRequest(request)
    }
}