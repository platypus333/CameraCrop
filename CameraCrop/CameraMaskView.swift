//
//  CameraMaskView.swift
//
//  Created by Paris on 2022/6/30.
//

import Foundation
import UIKit

class CameraMaskView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .black

        let radius : CGFloat = 130
        let ringDiameter : CGFloat = 270
                
        // 渐变色圆环
        let path1 = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: ringDiameter, height: ringDiameter))
        let gradient = CAGradientLayer() //只能在此组件上设置渐变色
        gradient.frame = CGRect(x: (UIScreen.main.bounds.size.width - ringDiameter) / 2, y:(rect.size.height - ringDiameter) / 2, width: ringDiameter, height: ringDiameter)
        let satrtColor = UIColor(red: 94/255.0, green: 202/255.0, blue: 203/255.0, alpha: 1).cgColor
        let endColor = UIColor(red: 224/255.0, green: 155/255.0, blue: 189/255.0, alpha: 1).cgColor
        gradient.colors = [satrtColor, endColor]
        gradient.startPoint = CGPoint(x: 0.2, y: 0.3)
        gradient.endPoint = CGPoint(x: 0.8, y: 0.7)
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = path1.cgPath
        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
        
        // 镂空圆
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let roundPath = UIBezierPath(arcCenter: CGPoint(x: UIScreen.main.bounds.size.width / 2, y: rect.size.height / 2), radius: radius, startAngle: 0, endAngle: .pi*2, clockwise: false)
        roundPath.lineWidth = 10
        UIColor(red: 0, green: 0, blue: 0, alpha: 1).setStroke()
        roundPath.stroke()
        path.append(roundPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        self.layer.mask = shapeLayer
    }
    
}
