//
//  cameraProgressViewController.swift
//  SCRecorderExamples
//
//  Created by Jay on 7/28/16.
//
//

import Foundation

@objc class cameraProgressView: UIViewController {

    @IBOutlet weak var cameraProgress: DTProgressView!
    var progress:Double!
    var recorderView = SCRecorderViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProgress()
        getLevelFromCamera()
    }
    
    
    func setProgress() {
        cameraProgress.strokeColor = UIColor.greenColor()
        progress = 0.0
    }
    
    
    func getLevelFromCamera() {
        
        
        self.performSelector(#selector(self.getLevelFromCamera), withObject: nil, afterDelay: 0.15)


    }
    
}