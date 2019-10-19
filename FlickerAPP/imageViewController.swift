//
//  imageViewController.swift
//  FlickerAPP
//
//  Created by Onur AKÇAY on 28.09.2019.
//  Copyright © 2019 Onur AKÇAY. All rights reserved.
//
import Foundation
import UIKit
import SDWebImage
class imageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedImageName = ""
    var selectedImage = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = selectedImageName
        imageView.sd_setImage(with: URL(string: selectedImage))
        
        /*let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("tapGesture:")))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true*/
        
        
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

   

}
