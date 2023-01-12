//
//  ThumbnailView.swift
//  MyTableView
//
//  Created by Dumveloper on 2023/01/11.
//

import Foundation
import UIKit


final class ThumbnailView: UIView {
    lazy var deviceHeight = self.safeAreaLayoutGuide.layoutFrame.height
    lazy var cellHeight = deviceHeight / 4
    lazy var bgColor = getRandomColor()
    
    var dataSource:[Int] = []
    var lastImageIndex = 50
    var scrollDownEnded = false
    var scrollUpEnded = true

    var changeOffset: CGFloat = 0
    
    public let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    init() {
        super.init(frame: .zero)
        setUI()
        
        for i in 1...7 {
            dataSource.append(i)
        }
     
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(drag(with:)))
        self.addGestureRecognizer(gesture)
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            self.backgroundColor = bgColor
            self.backgroundColor?.setFill()
            context.fill(rect);
        }
        for i in 1..<dataSource.count {
            guard let imageView = createImageView(index: i) else { continue }
            stackView.addArrangedSubview(imageView)
        }
    }
    
    @objc func drag(with sender: UIPanGestureRecognizer) {
        let startPoint = self.bounds.origin.y
        let transition = sender.translation(in: self)
        self.bounds.origin.y = startPoint - transition.y
        
        if startPoint < self.bounds.origin.y {
            if scrollDownEnded {
                self.bounds.origin.y = cellHeight
                return
            }
            scrollUpEnded = false
            scrollDown(changeY: transition.y)

        } else {
            if scrollUpEnded {
                self.bounds.origin.y = 0
            }
            scrollDownEnded = false
            scrollUp(changeY: transition.y)

        }
        sender.setTranslation(.zero, in: self)
    }
    
    private func scrollDown(changeY: CGFloat) {
     
        changeOffset =  changeOffset - changeY
        if changeOffset > cellHeight {
            var temp = dataSource
            if let last = dataSource.last {
                if last > lastImageIndex-1 {
                    scrollDownEnded = true
                    return }
                temp.remove(at: 0)
                temp.append(last + 1)
                changeOffset -= cellHeight

            }

            dataSource = temp
            self.bounds.origin.y -= cellHeight
            reloadData()
        }
    }
    
   
    private func scrollUp(changeY: CGFloat) {
        changeOffset =  changeOffset - changeY
        if changeOffset < 0 {
            var temp = dataSource
            if let first = dataSource.first {
                if first < 2 {
                    
                    print("scrollUpEnded")
                    scrollUpEnded = true
                    return }
                temp.removeLast()
                temp.insert(first - 1, at: 0)
                changeOffset += cellHeight

            }
            dataSource = temp
            self.bounds.origin.y += cellHeight
            reloadData()
            
        }
    }
    
    private func reloadData() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        for i in 0..<dataSource.count {
            if let imageView = createImageView(index: dataSource[i]) {
                stackView.addArrangedSubview(imageView)
            }

        }
    }
    
    private func createImageView(index:Int) -> UIImageView? {
        guard let image = UIImage(named: "image\(index)") else {return nil}
        let imageView = UIImageView(image: image)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true

        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = getRandomColor().cgColor
        imageView.layer.cornerRadius = 8
        return imageView

    }
    
    private func getRandomColor() -> UIColor{
            
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    private func setUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
      
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
