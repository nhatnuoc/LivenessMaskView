//
//  ViewController.swift
//  Sample
//
//  Created by Nguyễn Thanh Bình on 15/2/25.
//

import UIKit
import LivenessMask

class ViewController: UIViewController {
    @IBOutlet weak var livenessView: LivenessMaskView!
    
    @IBAction func onPressMessage(_ sender: Any) {
        self.livenessView.showMessage("message")
    }
    @IBAction func onPressDetected(_ sender: Any) {
        self.livenessView.showDetected("detected")
    }
    
    @IBAction func onPressProcessing(_ sender: Any) {
        self.livenessView.showProcessing("processing")
    }
    @IBAction func onPressError(_ sender: Any) {
        self.livenessView.showError("error")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

