//
//  ViewController.swift
//  Example
//
//  Created by Nguyễn Thanh Bình on 27/1/25.
//

import UIKit
import NDA

class ViewController: UIViewController {
    @IBOutlet weak var livenessMaskView: LivenessMaskView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onProcessingPressed(_ sender: Any) {
        self.livenessMaskView.showProcessing("Vui lòng đưa khuôn mặt vào\nchính giữa khung hình để bắt đầu xác thực - processing")
    }
    
    @IBAction func onShowMessagePressed(_ sender: Any) {
        self.livenessMaskView.showMessage("Vui lòng đưa khuôn mặt vào\nchính giữa khung hình để bắt đầu xác thực - message")
    }
    
    @IBAction func onShowErrorPressed(_ sender: Any) {
        self.livenessMaskView.showError("Vui lòng đưa khuôn mặt vào\nchính giữa khung hình để bắt đầu xác thực - error")
    }
}

