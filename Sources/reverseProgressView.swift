//
//  reverseProgressView.swift
//  SCRecorderExamples
//
//  Created by Jay on 7/27/16.
//
//

import Foundation

class reverseProgressView: UIViewController {
    
    @IBOutlet weak var progressView: DTProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setProgress()
        increseProgress()
        
    }
    
    func setProgress() {
        progressView.strokeColor = UIColor.greenColor()
    }
    
    func increseProgress() {
        if (progressView.progress == 1){
            progressView.setProgress(0, animated: false)
        }
        var progress = progressView.progress + 0.3
        progressView.setProgress(progress, animated: true)
        
        self.performSelector(#selector(self.increseProgress), withObject: nil, afterDelay: 0.15)

    }
}