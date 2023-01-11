//
//  ThumbnailView.swift
//  MyTableView
//
//  Created by Dumveloper on 2023/01/11.
//

import Foundation
import UIKit


final class ThumbnailView: UIView {
    
    public let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    
    init() {
        super.init(frame: .zero)
        setUI()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(drag(with:)))
        self.addGestureRecognizer(gesture)

    }
    
    private func setUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
      
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
    }
    
    @objc func drag(with sender: UIPanGestureRecognizer) {
        let transition = sender.translation(in: self)
        self.bounds.origin.y = self.bounds.origin.y - transition.y

        if self.bounds.origin.y < 0 {
            self.bounds.origin.y  = 0
        }
        let maxY = self.stackView.frame.size.height - self.safeAreaLayoutGuide.layoutFrame.height


        if  self.bounds.origin.y > maxY{
            self.bounds.origin.y = maxY
        }
        sender.setTranslation(.zero, in: self)
    }
    
    
    override func draw(_ rect: CGRect) {

        if let context = UIGraphicsGetCurrentContext() {
            print(context)
            self.backgroundColor = getRandomColor()
            self.backgroundColor?.setFill()
            context.fill(rect);
        }
        
        let deviceHeight = UIScreen.main.bounds.size.height

        for i in 1...50 {
            
            guard let image = UIImage(named: "image\(i)") else { continue }
            let imageView = UIImageView(image: image)
            
            stackView.addArrangedSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: deviceHeight/4).isActive = true

            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = getRandomColor().cgColor
            imageView.layer.cornerRadius = 8
            
        }

    }
    
    private func getRandomColor() -> UIColor{
            
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
