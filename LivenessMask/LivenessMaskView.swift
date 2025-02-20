//
//  LivenessMaskView.swift
//  LivenessMask
//
//  Created by Nguyễn Thanh Bình on 15/2/25.
//

import UIKit
import Lottie

public class LivenessMaskView: UIView {
    enum Status {
        case normal
        case detected
        case processing
        case success
        case error
    }
    let ovalBorderProcessingAnimKey = "ovalBorderProcessingAnimKey"
    var textLayer: CATextLayer?
    var status: Status = .normal
    public var instructionText: String? {
        didSet {
            if oldValue != self.instructionText {
                self.textLayer?.string = self.instructionText
//                    self.textLayer?.frame = self.bounds
                self.updateTextLayerLayout(text: self.instructionText ?? "")
//                    self.setNeedsLayout()
            }
        }
    }
    public var previewFrame: CGRect = .zero {
        didSet {
            if self.animView.superview == nil {
                self.superview?.addSubview(self.animView)
            }
            self.animView.frame = self.convert(self.previewFrame.inset(by: .init(top: -25, left: -34, bottom: -25, right: -32)), to: self.superview)
            if self.detectedView.superview == nil {
                self.superview?.insertSubview(self.detectedView, belowSubview: self)
            }
            self.detectedView.frame = self.convert(self.previewFrame.insetBy(dx: -25, dy: 0), to: self.superview)
        }
    }
    public var processingOvalBorderColor = UIColor.processing
    public var errorOvalBorderColor = UIColor.error
    public var normalOvalBorderColor = UIColor.clear
    public var processingAnimDuration: TimeInterval = 2.0
    public var instructionTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
    ]
    var ovalBorderLayer: CAShapeLayer?
    var bgImgLayer: CALayer?
    lazy var detectedView: LottieAnimationView = {
        let detectedView = LottieAnimationView(name: "anim-detected", bundle: Bundle(for: LivenessMaskView.self))
        detectedView.contentMode = .scaleAspectFill
        detectedView.backgroundColor = .black.withAlphaComponent(0.4)
        return detectedView
    }()
    lazy var animView: LottieAnimationView = {
        let detectedView = LottieAnimationView()
        detectedView.contentMode = .scaleToFill
        if #available(iOS 13.0, *) {
            detectedView.scalesLargeContentImage = true
        } else {
            // Fallback on earlier versions
        }
        return detectedView
    }()
    
    public override func draw(_ rect: CGRect) {
        self.layer.sublayers?.forEach({ (l) in
            l.removeFromSuperlayer()
        })
        
        let width: CGFloat = rect.width * 227 / 375
//        let height = width * 402 / 227
        let height = width * 330 / 227
        let xPos = rect.width / 2 - width / 2
//            let yPos = rect.height / 6
        let yPos = rect.height * 152 / 812
        
        let areaViewFrame = CGRect(x: xPos, y: yPos, width: width, height: height)
        let areaViewPath = self.drawAreaViewPath(areaViewFrame)
        
        let path = UIBezierPath(rect: rect)
        path.append(areaViewPath.reversing())
        let color = UIColor.white
        color.setFill()
        path.fill()
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        
        self.layer.mask = shapeLayer
        self.previewFrame = areaViewFrame
        
        self.textLayer = self.drawTextLayer(withText: self.instructionText ?? "", rect: CGRect(x: 13.0, y: areaViewFrame.maxY + 24, width: rect.width - 32, height: 30))
        self.layer.addSublayer(self.textLayer!)
//        self.textLayer?.isHidden = true
        
        let bgLayer = CAShapeLayer()
        let bgImg = UIImage(resource: .bgFlash)
        let bgImgSize = bgImg.size
        bgLayer.contents = bgImg.cgImage
        bgLayer.frame = CGRect(origin: CGPoint(x: rect.width - bgImgSize.width, y: rect.height - bgImgSize.height), size: bgImgSize)
        self.layer.addSublayer(bgLayer)
        self.bgImgLayer = bgLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = areaViewPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor // Không có màu nền
        borderLayer.strokeColor = UIColor.normal.cgColor // Màu border
        borderLayer.lineWidth = 8.0 // Độ dày đường viền

        // Thêm border layer lên view (ở trên layer cha)
        self.layer.addSublayer(borderLayer)
        self.ovalBorderLayer = borderLayer
        
        let countDownLayer = CAShapeLayer()
        countDownLayer.path = UIBezierPath(ovalIn: areaViewFrame).cgPath
        countDownLayer.fillColor = UIColor.red.cgColor
        countDownLayer.strokeColor = UIColor.clear.cgColor
        countDownLayer.lineWidth = 8.0
        self.layer.addSublayer(countDownLayer)
    }
    
    func updateTextLayerLayout(text: String) {
        guard !text.isEmpty else {
            self.textLayer?.isHidden = true
            return
        }
        self.textLayer?.isHidden = false
        guard let textLayer = self.textLayer else {
            self.textLayer = self.drawTextLayer(withText: text, rect: CGRect(x: 13.0, y: self.previewFrame.maxY + 24, width: self.previewFrame.width, height: 30))
            self.layer.addSublayer(self.textLayer!)
            return
        }
        // Calculate the size of the text
        
        
        // Update the background layer's frame
        let padding: CGFloat = 10
        
        // Update the text layer's frame
        let rect = self.bounds
        let sizeOfText = (text as NSString).boundingRect(with: CGSize(width: rect.width - 32, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: self.instructionTextAttributes, context: nil)
        let textLayerWidth = sizeOfText.width
        textLayer.frame = CGRect(
            x: rect.width / 2 - textLayerWidth / 2,
            y: textLayer.frame.origin.y,
            width: textLayerWidth,
            height: sizeOfText.height + (padding / 2)
        )
        
        // Center the text
        textLayer.alignmentMode = .center
    }
    
    func drawAreaViewPath(_ rect: CGRect) -> UIBezierPath {
        // Tạo đường dẫn hình oval, bắt đầu từ đỉnh (y nhỏ nhất)
        let areaViewPath = UIBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        
        let steps = 100 // Độ mịn của oval
        let startAngle = -CGFloat.pi / 2 // Góc bắt đầu từ đỉnh trên cùng
        for i in 0...steps {
            let angle = startAngle + CGFloat(i) * 2 * .pi / CGFloat(steps)
            let x = center.x + radiusX * cos(angle)
            let y = center.y + radiusY * sin(angle)
            if i == 0 {
                areaViewPath.move(to: CGPoint(x: x, y: y))
            } else {
                areaViewPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        areaViewPath.lineWidth = 1
        UIColor.white.setStroke()
        areaViewPath.stroke()
        areaViewPath.close()
        return areaViewPath
    }
    
    func drawTextLayer(withText text: String, rect: CGRect) -> CATextLayer {
        let textlayer = CATextLayer()
        let font = self.instructionTextAttributes[.font] as! UIFont
        let sizeOfText = (text as NSString).boundingRect(with: CGSize(width: rect.width - 32, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: self.instructionTextAttributes, context: nil)
        textlayer.frame = CGRect(origin: CGPoint(x: rect.width / 2 - sizeOfText.width / 2 - 15, y: rect.origin.y), size: CGSize(width: sizeOfText.width, height: sizeOfText.height + 8))
        textlayer.fontSize = font.pointSize
        textlayer.font = font
        textlayer.alignmentMode = .center
        textlayer.string = text
        textlayer.isWrapped = true
        textlayer.truncationMode = .end
        textlayer.foregroundColor = UIColor.black.cgColor
        textlayer.contentsScale = UIScreen.main.scale
//            textlayer.backgroundColor = UIColor.black.cgColor
        return textlayer
    }
    
    func runOvalBorderProcessingAnim(fromValue: CGFloat = 0.0, toValue: CGFloat = 0.75, repeateCount: Float = 1) {
        guard let borderLayer = self.ovalBorderLayer else { return }
        let animKey = self.ovalBorderProcessingAnimKey
        borderLayer.removeAnimation(forKey: animKey)
        borderLayer.strokeColor = self.processingOvalBorderColor.cgColor
//        borderLayer.strokeStart = 0.0
        borderLayer.strokeEnd = fromValue // Chưa vẽ viền
        // Tạo animation cho strokeEnd
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = fromValue // Bắt đầu từ đỉnh oval
        strokeAnimation.toValue = toValue // Kết thúc tại cuối oval (hoàn thành 1 vòng)
        strokeAnimation.duration = self.processingAnimDuration // Thời gian chạy animation (1 giây)
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.fillMode = .forwards
        strokeAnimation.repeatCount = repeateCount

        // Áp dụng animation lên layer
        borderLayer.add(strokeAnimation, forKey: animKey)

        // Cập nhật giá trị cuối cùng để giữ trạng thái
//        borderLayer.strokeEnd = 1.0
//        borderLayer.strokeStart = 1.25
    }
    
    func resetOvalBorderAnim() {
        self.ovalBorderLayer?.removeAllAnimations()
        self.ovalBorderLayer?.strokeEnd = 1.0
    }
}

extension LivenessMaskView {
    public func showError(_ message: String) {
        self.resetOvalBorderAnim()
        self.ovalBorderLayer?.strokeColor = self.errorOvalBorderColor.cgColor
        self.instructionText = message
        self.animView.isHidden = true
        self.detectedView.isHidden = true
        self.status = .error
    }
    
    public func showDetected(_ message: String?) {
        self.ovalBorderLayer?.strokeColor = self.normalOvalBorderColor.cgColor
        self.instructionText = message
        self.animView.isHidden = true
        self.detectedView.isHidden = false
        if self.status != .detected {
            self.detectedView.loopMode = .loop
            self.detectedView.play()
        }
        self.status = .detected
    }
    
    public func showProcessing(_ message: String?) {
        self.ovalBorderLayer?.strokeColor = self.normalOvalBorderColor.cgColor
        self.instructionText = message
        self.detectedView.isHidden = false
        self.detectedView.stop()
        self.animView.isHidden = false
        if self.status != .processing {
            let anim = LottieAnimation.named("anim-processing", bundle: Bundle(for: LivenessMaskView.self))
            self.animView.loopMode = .loop
            self.animView.animation = anim
            self.animView.play()
        }
        self.status = .processing
    }
    
    public func showMessage(_ message: String) {
        self.instructionText = message
        self.resetOvalBorderAnim()
        self.ovalBorderLayer?.strokeColor = self.normalOvalBorderColor.cgColor
        self.animView.isHidden = true
        self.detectedView.isHidden = true
        self.status = .normal
    }
    
    public func showSuccess(_ message: String) {
        self.resetOvalBorderAnim()
        self.ovalBorderLayer?.strokeColor = self.normalOvalBorderColor.cgColor
        self.instructionText = ""
        self.animView.isHidden = false
        self.detectedView.isHidden = false
        self.detectedView.stop()
        self.animView.loopMode = .playOnce
        let anim = LottieAnimation.named("anim-success", bundle: Bundle(for: LivenessMaskView.self))
        self.animView.animation = anim
        self.animView.play()
        self.status = .success
    }
}

