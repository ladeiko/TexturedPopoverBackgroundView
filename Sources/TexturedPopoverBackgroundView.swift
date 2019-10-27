//
//  TexturedPopoverBackgroundView.swift
//  TexturedPopoverBackgroundView
//
//  Created by Siarhei Ladzeika on 27 Oct 2019.
//  Copyright (c) 2019-present Siarhei Ladzeika. All rights reserved.
//

import UIKit

public typealias TexturedPopoverBackgroundViewImageGetter = () -> UIImage

@objc
open class TexturedPopoverBackgroundView : UIPopoverBackgroundView {
    
    open override var arrowDirection: UIPopoverArrowDirection {
        get { return _arrowDirection }
        set { _arrowDirection = newValue }
    }
    
    open override var arrowOffset: CGFloat {
        get { return _arrowOffset }
        set { _arrowOffset = newValue }
    }
    
    @objc
    open class func setCornerRadius(_ newValue: CGFloat) {
        saveValue(newValue, forKey: "cornerRadius")
        update([.size])
    }
    
    @objc
    open class var cornerRadius: CGFloat {
        return loadValue(forKey: "cornerRadius") ?? 0
    }

    @objc
    open class func setBorderWidth(_ newValue: CGFloat) {
        saveValue(newValue, forKey: "borderWidth")
        update([.size])
    }
    
    @objc
    open class var borderWidth: CGFloat {
        return loadValue(forKey: "borderWidth") ?? 0
    }

    @objc
    open class func setBorderColor(_ newValue: UIColor) {
        saveValue(newValue, forKey: "borderColor")
        update([.size])
    }
    
    @objc
    open class var borderColor: UIColor {
        return loadValue(forKey: "borderColor") ?? .black
    }

    @objc
    open class func setBackgroundImageGetter(_ newValue: @escaping TexturedPopoverBackgroundViewImageGetter) {
        saveValue(newValue, forKey: "backgroundImageGetter")
        update([.background])
    }
    
    @objc
    open class var backgroundImageGetter: TexturedPopoverBackgroundViewImageGetter? {
        return loadValue(forKey: "backgroundImageGetter")
    }
    
    @objc
    open class func setContentViewInsets(_ value: UIEdgeInsets) {
        saveValue(value, forKey: "contentViewInsets")
    }
    
    @objc
    open class func setArrowBase(_ value: CGFloat) {
        saveValue(value, forKey: "arrowBase")
    }
    
    @objc
    open class func setArrowHeight(_ value: CGFloat) {
        saveValue(value, forKey: "arrowHeight")
    }
    
    // MARK: - Methods of UIPopoverBackgroundView
    
    open override class func arrowBase() -> CGFloat {
        return loadValue(forKey: "arrowBase") ?? 40
    }

    open override class func arrowHeight() -> CGFloat {
        return loadValue(forKey: "arrowHeight") ?? 20
    }
    
    open override class func contentViewInsets() -> UIEdgeInsets {
        return loadValue(forKey: "contentViewInsets") ?? .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // MARK: - View Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        TexturedPopoverBackgroundView.alive.addPointer(Unmanaged.passUnretained(self).toOpaque())
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        TexturedPopoverBackgroundView.alive.addPointer(Unmanaged.passUnretained(self).toOpaque())
        configure()
    }
    
    deinit {
        removeObservers()
        DispatchQueue.main.async {
            TexturedPopoverBackgroundView.alive.compact()
        }
    }
    
    // MARK: - Private vars

    private static var props = [String: Any]()
    private static let alive = NSPointerArray.weakObjects()

    private var backgroundImageView: UIView!
    private var _arrowDirection: UIPopoverArrowDirection = .any
    private var _arrowOffset: CGFloat = 0
    private var backgroundImageViewBorderLayer: CAShapeLayer?
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "arrowDirection" || keyPath == "arrowOffset") {
            self.setNeedsLayout()
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    // MARK: - Helpers
    
    private static func propKey(for key: String) -> String {
        return "\(NSStringFromClass(self)):\(key)"
    }
    
    private static func saveValue<T>(_ value: T?, forKey key: String) {
        props[propKey(for: key)] = value
    }
    
    private static func loadValue<T>(forKey key: String) -> T? {
        return props[propKey(for: key)] as? T
    }
    
    private struct UpdateComponents: OptionSet {
        let rawValue: Int
        static let background = UpdateComponents(rawValue: 1 << 0)
        static let size = UpdateComponents(rawValue: 1 << 1)
    }
    
    private static func update(_ components: UpdateComponents) {
        alive.allObjects.forEach {
            
            guard let view = $0 as? TexturedPopoverBackgroundView else {
                return
            }
            
            view.update(components)
        }
    }
    
    private func update(_ components: UpdateComponents) {
        
        if components.contains(.background) {
            updateBgColor()
        }
        
        if components.contains(.size) {
            setNeedsLayout()
        }
    }
    
    private func configure() {
        
        addObservers()
        
        backgroundImageView = UIView(frame: .zero)
        backgroundImageView.clipsToBounds = true
        
        updateBgColor()
        
        addSubview(backgroundImageView)
    }
    
    private func updateBgColor() {
        if let backgroundImageGetter = TexturedPopoverBackgroundView.backgroundImageGetter {
            let bgImage = backgroundImageGetter()
            backgroundImageView.backgroundColor = UIColor(patternImage: bgImage)
        }
        else {
            backgroundImageView.backgroundColor = .white
        }
    }

    private func addObservers() {
        addObserver(self, forKeyPath: "arrowDirection", options:[], context:nil)
        addObserver(self, forKeyPath: "arrowOffset", options:[], context:nil)
    }
    
    private func removeObservers() {
        removeObserver(self, forKeyPath: "arrowDirection")
        removeObserver(self, forKeyPath: "arrowOffset")
    }
    
    // MARK: - Subviews Layout

    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let bgRect = self.bounds
        let path = UIBezierPath()
        
        switch (arrowDirection) {
        case .up:
            let leftTopCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.width / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2.0 ))
            
            let leftBottomCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            let rightTopCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.width - (bgRect.size.width / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2) ))
            
            let rightBottomCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            // left top
            path.move(to: CGPoint(x: 0, y: TexturedPopoverBackgroundView.arrowHeight() + leftTopCornerRadius))
            
            path.addArc(withCenter: CGPoint(x: leftTopCornerRadius, y: TexturedPopoverBackgroundView.arrowHeight() + leftTopCornerRadius ),
                        radius: leftTopCornerRadius,
                        startAngle: .pi,
                        endAngle: .pi * 3 / 2,
                        clockwise: true)
            
            
            // top - lefter arrow
            path.addLine(to: CGPoint(x: max(0, min(bgRect.size.width, bgRect.size.width / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2 )),
                                     y: TexturedPopoverBackgroundView.arrowHeight()))
            
            
            
            // arrow
            path.addLine(to: CGPoint(x: bgRect.size.width / 2 + self.arrowOffset,
                                     y: 0 ))
            
            path.addLine(to: CGPoint(x: max(0, min(bgRect.size.width, bgRect.size.width / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2)),
                                     y: TexturedPopoverBackgroundView.arrowHeight()))
            
            
            // right top
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightTopCornerRadius, y: rightTopCornerRadius + TexturedPopoverBackgroundView.arrowHeight() ),
                        radius: rightTopCornerRadius,
                        startAngle: .pi * 3 / 2,
                        endAngle: .pi * 2,
                        clockwise: true)
            
            // right
            path.addLine(to: CGPoint(x: bgRect.size.width, y: bgRect.size.height - rightBottomCornerRadius))
            
            // right bottom
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightBottomCornerRadius, y: bgRect.size.height - rightBottomCornerRadius ),
                        radius: rightBottomCornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            
            // bottom
            path.addLine(to: CGPoint(x: leftBottomCornerRadius, y: bgRect.size.height))
            
            // left bottom
            path.addArc(withCenter: CGPoint(x: leftBottomCornerRadius, y: bgRect.size.height - leftBottomCornerRadius),
                        radius: leftBottomCornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            
            // left
            path.addLine(to: CGPoint(x: 0,
                                     y: TexturedPopoverBackgroundView.arrowHeight() + leftTopCornerRadius))
            
        case .down:
            let leftTopCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            let leftBottomCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.width / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2.0 ))
            
            let rightTopCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            let rightBottomCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.width - (bgRect.size.width / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2) ))
            
            // left top
            path.move(to: CGPoint(x: 0, y: leftTopCornerRadius))
            
            path.addArc(withCenter: CGPoint(x: leftTopCornerRadius, y: leftTopCornerRadius),
                        radius: leftTopCornerRadius,
                        startAngle: .pi,
                        endAngle: .pi * 3 / 2,
                        clockwise: true)
            
            
            // top
            path.addLine(to: CGPoint(x: bgRect.size.width - rightTopCornerRadius,
                                     y: 0))
            
            // right top
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightTopCornerRadius, y: rightTopCornerRadius ),
                        radius: rightTopCornerRadius,
                        startAngle: .pi * 3 / 2,
                        endAngle: .pi * 2,
                        clockwise: true)
            
            // right
                
            path.addLine(to: CGPoint(x: bgRect.size.width,
                                     y: bgRect.size.height - rightBottomCornerRadius - TexturedPopoverBackgroundView.arrowHeight()))
            
            // right bottom
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightBottomCornerRadius,
                                            y: bgRect.size.height - rightBottomCornerRadius - TexturedPopoverBackgroundView.arrowHeight()),
                        radius: rightBottomCornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            
            // bottom - righter arrow
            path.addLine(to: CGPoint(x: max(0, min(bgRect.size.width, bgRect.size.width / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2)),
                                     y: bgRect.size.height - TexturedPopoverBackgroundView.arrowHeight()))
            
                
            // arrow
            path.addLine(to: CGPoint(x: max(0, min(bgRect.size.width, bgRect.size.width / 2 + self.arrowOffset)),
                                     y: bgRect.size.height ))
            
            path.addLine(to: CGPoint(x: max(0, min(bgRect.size.width, bgRect.size.width / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2)),
                                     y: bgRect.size.height - TexturedPopoverBackgroundView.arrowHeight()))

            
            // left bottom
            path.addArc(withCenter: CGPoint(x: leftBottomCornerRadius,
                                            y: bgRect.size.height - leftBottomCornerRadius - TexturedPopoverBackgroundView.arrowHeight()),
                        radius: leftBottomCornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            
            // left
            path.addLine(to: CGPoint(x: 0,
                                     y: leftTopCornerRadius))
            
        case .left:
            
            let leftTopCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.height / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2.0 ))
            
            let leftBottomCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.height - (bgRect.size.height / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2) ))
            
            let rightTopCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            let rightBottomCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            // left top
            path.move(to: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight(), y: leftTopCornerRadius))

            path.addArc(withCenter: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight() + leftTopCornerRadius, y: leftTopCornerRadius ),
                        radius: leftTopCornerRadius,
                        startAngle: .pi,
                        endAngle: .pi * 3 / 2,
                        clockwise: true)
            
            // top
            path.addLine(to: CGPoint(x: bgRect.size.width - rightTopCornerRadius, y: 0))
            
            // right top
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightTopCornerRadius, y: rightTopCornerRadius ),
                        radius: rightTopCornerRadius,
                        startAngle: .pi * 3 / 2,
                        endAngle: .pi * 2,
                        clockwise: true)
            
            // right
            path.addLine(to: CGPoint(x: bgRect.size.width, y: bgRect.size.height - rightBottomCornerRadius))
            
            // right bottom
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightBottomCornerRadius, y: bgRect.size.height - rightBottomCornerRadius ),
                        radius: rightBottomCornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            
            // bottom
            path.addLine(to: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight() + leftBottomCornerRadius, y: bgRect.size.height))
            
            // left bottom
            path.addArc(withCenter: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight() + leftBottomCornerRadius, y: bgRect.size.height - leftBottomCornerRadius),
                        radius: leftBottomCornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            
            // left - under arrow
            path.addLine(to: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight(),
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2))))
            
            // arrow
            path.addLine(to: CGPoint(x: 0,
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset)) ))
            
            path.addLine(to: CGPoint(x: TexturedPopoverBackgroundView.arrowHeight(),
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2))))
                
        case .right:
            
            let leftTopCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            let leftBottomCornerRadius = TexturedPopoverBackgroundView.cornerRadius
            
            let rightTopCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.height / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2.0 ))
            let rightBottomCornerRadius = max(0, min(TexturedPopoverBackgroundView.cornerRadius, bgRect.size.height - (bgRect.size.height / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2) ))
            
            // left top
            path.move(to: CGPoint(x: 0, y: leftTopCornerRadius))
            
            path.addArc(withCenter: CGPoint(x: leftTopCornerRadius, y: leftTopCornerRadius ),
                        radius: leftTopCornerRadius,
                        startAngle: .pi,
                        endAngle: .pi * 3 / 2,
                        clockwise: true)
            
            // top
            path.addLine(to: CGPoint(x: bgRect.size.width - rightTopCornerRadius - TexturedPopoverBackgroundView.arrowHeight(), y: 0))
            
            // right top
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightTopCornerRadius - TexturedPopoverBackgroundView.arrowHeight(),
                                            y: rightTopCornerRadius),
                        radius: rightTopCornerRadius,
                        startAngle: .pi * 3 / 2,
                        endAngle: .pi * 2,
                        clockwise: true)
            
            // right - above arrow
            path.addLine(to: CGPoint(x: bgRect.size.width - TexturedPopoverBackgroundView.arrowHeight(),
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2))))
            
            // arrow
            path.addLine(to: CGPoint(x: bgRect.size.width,
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset)) ))
            
            path.addLine(to: CGPoint(x: bgRect.size.width - TexturedPopoverBackgroundView.arrowHeight(),
                                     y: max(0, min(bgRect.size.height, bgRect.size.height / 2 + self.arrowOffset + TexturedPopoverBackgroundView.arrowBase() / 2))))
            
            // right - below arrow
            path.addLine(to: CGPoint(x: bgRect.size.width - TexturedPopoverBackgroundView.arrowHeight(),
                                     y: bgRect.size.height + self.arrowOffset - TexturedPopoverBackgroundView.arrowBase() / 2))
            
            // right bottom
            path.addArc(withCenter: CGPoint(x: bgRect.size.width - rightBottomCornerRadius - TexturedPopoverBackgroundView.arrowHeight(), y: bgRect.size.height - rightBottomCornerRadius ),
                        radius: rightBottomCornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            
            // bottom
            path.addLine(to: CGPoint(x: leftBottomCornerRadius, y: bgRect.size.height))
            
            // left bottom
            path.addArc(withCenter: CGPoint(x: leftBottomCornerRadius, y: bgRect.size.height - leftBottomCornerRadius),
                        radius: leftBottomCornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            
            
        default:
            fatalError()
        }
        
        path.close()
        
        let rectShape = CAShapeLayer()
        rectShape.frame = bgRect
        rectShape.path = path.cgPath
        
        backgroundImageView.frame = bgRect
        backgroundImageView.layer.mask = rectShape
        
        backgroundImageViewBorderLayer?.removeFromSuperlayer()
        backgroundImageViewBorderLayer = nil
        
        if TexturedPopoverBackgroundView.borderWidth > 0 {
            let borderLayer = CAShapeLayer()
            borderLayer.path = path.cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = TexturedPopoverBackgroundView.borderColor.cgColor
            borderLayer.lineWidth = TexturedPopoverBackgroundView.borderWidth
            borderLayer.frame = bgRect
            backgroundImageView.layer.addSublayer(borderLayer)
        }

    }
}

