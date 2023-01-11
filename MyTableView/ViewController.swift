//
//  ViewController.swift
//  MyTableView
//
//  Created by Dumveloper on 2023/01/11.
//

import UIKit

class ViewController: UIViewController {
    let thumbnailView = ThumbnailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    
    private func setUI() {
        
        self.view.addSubview(thumbnailView)
        thumbnailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        thumbnailView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thumbnailView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
}



