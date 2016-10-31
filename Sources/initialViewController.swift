//
//  initialViewController.swift
//  SCRecorderExamples
//
//  Created by Jay on 8/1/16.
//
//

import Foundation

class initialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func showExamples(sender: AnyObject) {
        var instagramURL: NSURL = NSURL(string: "instagram://tag?name=reversecamera")!
        if UIApplication.sharedApplication().canOpenURL(instagramURL) {
            UIApplication.sharedApplication().openURL(instagramURL)
        }

    }
}
