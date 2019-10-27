//
//  ViewController.swift
//  TexturedPopoverBackgroundDemo
//
//  Created by Siarhei Ladzeika on 10/27/19.
//  Copyright © 2019 Siarhei Ladzeika. All rights reserved.
//

import UIKit
import TexturedPopoverBackgroundView

extension UIViewController {
    func showAsPopover(on vc: UIViewController, rect: CGRect, in view: UIView) {
        
        modalPresentationStyle = .popover
        
        let popoverController = self.popoverPresentationController!
        
        //        popoverController.delegate = self
        popoverController.sourceRect = rect
        popoverController.sourceView = view
        
        popoverController.popoverBackgroundViewClass = TexturedPopoverBackgroundView.self
        
        vc.present(self, animated: true, completion: nil)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderedSwitch.isOn = false
        
        TexturedPopoverBackgroundView.setBorderColor(.red)
        TexturedPopoverBackgroundView.setBackgroundImageGetter { UIImage(named: "popover-bg")! }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showOn(_:)))
        view.addGestureRecognizer(tap)
        
        TexturedPopoverBackgroundView.setBorderWidth(borderedSwitch.isOn ? 5 : 0)
    }
    
    @IBOutlet weak var borderedSwitch: UISwitch!
    
    @IBAction func borderedDidChanged() {
        TexturedPopoverBackgroundView.setBorderWidth(borderedSwitch.isOn ? 5 : 0)
    }

    @IBAction func showOn(_ sender: UITapGestureRecognizer) {
        show(at: sender.location(in: view))
    }
    
    private func show(at point: CGPoint) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        vc.showAsPopover(on: self,
                         rect: CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2),
                         in: view)
    }

}

