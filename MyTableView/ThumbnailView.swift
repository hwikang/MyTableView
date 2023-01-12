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
    lazy var borderColor = getRandomColor()
    
    var dataSource:[Int] = [] {
        didSet{
            print("Did set \(dataSource)")
            if let lastIndex = dataSource.last {
                if lastIndex == lastImageIndex { scrollEnded = true}
            }
            
            reloadData()

        }
    }
    var lastImageIndex = 50
    var scrollEnded = false
    var contentHeight: CGFloat = 0
    var changeOffset: CGFloat = 0
    
    public let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
//        view.spacing = 10
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
        
//        stackView.subviews.forEach{ $0.removeFromSuperview() }
        
        print("Draw \(dataSource)")
        for i in 1..<dataSource.count {
            
            guard let imageView = createImageView(index: i) else { continue }
            
            stackView.addArrangedSubview(imageView)
            

        }
        
        contentHeight = CGFloat(dataSource.count) * cellHeight


    }
    
    
    private func reloadData() {
            if let removeView = stackView.subviews.first {
                stackView.removeArrangedSubview(removeView)

            }
            if let lastIndex = dataSource.last, let imageView = createImageView(index: lastIndex) {
                print("Stackview add \(lastIndex)")
                stackView.addArrangedSubview(imageView)
            }

        
    }
    
    @objc func drag(with sender: UIPanGestureRecognizer) {
        let startPoint = self.bounds.origin.y
        let transition = sender.translation(in: self)
        self.bounds.origin.y = startPoint - transition.y
        
        print(self.bounds.origin.y )
       
        
        if self.bounds.origin.y < 0 {
            self.bounds.origin.y  = 0
            return
        }
        

        let maxY = contentHeight - self.safeAreaLayoutGuide.layoutFrame.height
        print("maxY \(maxY)")
        if  self.bounds.origin.y > maxY{
            self.bounds.origin.y = maxY
            return
        }
        
        if startPoint < self.bounds.origin.y {
            //scrollDown
            if scrollEnded { return }

            scrollDown(changeY: transition.y)

        } else {
            scrollUp(changeY: transition.y)

        }
        sender.setTranslation(.zero, in: self)
    }
    
    private func scrollDown(changeY: CGFloat) {
        changeOffset =  changeOffset - changeY
        print("changeOffset \(changeOffset)")
        if changeOffset > cellHeight {
            print("Trigger Down")
            changeOffset = 0
            let firstIndex = Int(self.bounds.origin.y / cellHeight) // 1
            
            if firstIndex+7 > 50 { return }
            
            var temp = dataSource
            temp.remove(at: 0)
            temp.append(firstIndex + 7)
            
            contentHeight = CGFloat(firstIndex + 6) * cellHeight

            dataSource = temp
//            reloadData()
        }
    }
    private func scrollUp(changeY: CGFloat) {
        changeOffset =  changeOffset - changeY
        print("changeOffset \(changeOffset)")
        if changeOffset < 0 {
            print("Trigger Up")
            changeOffset = cellHeight
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
