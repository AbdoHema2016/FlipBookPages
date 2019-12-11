/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class BookPageCell: UICollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	var book: Book?
	var isRightPage: Bool = false
	var shadowLayer: CAGradientLayer = CAGradientLayer()
	
	override var bounds: CGRect {
		didSet {
			shadowLayer.frame = bounds
		}
	}
	
	var image: UIImage? {
		didSet {
			var corners: UIRectCorner = isRightPage ? .topRight : .topLeft //| .bottomLeft
            imageView.image = image!.imageByScalingAndCroppingForSize(targetSize: bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupAntialiasing()
		initShadowLayer()
	}
	
	
	func setupAntialiasing() {
		layer.allowsEdgeAntialiasing = true
		imageView.layer.allowsEdgeAntialiasing = true
	}
	
	func initShadowLayer() {
		var shadowLayer = CAGradientLayer()
		
		shadowLayer.frame = bounds
        shadowLayer.startPoint = CGPoint(x:0,y: 0.5)
        shadowLayer.endPoint = CGPoint(x:1,y: 0.5)
		
		self.imageView.layer.addSublayer(shadowLayer)
		self.shadowLayer = shadowLayer
	}
	
	func getRatioFromTransform() -> CGFloat {
		var ratio: CGFloat = 0
		
        var rotationY = CGFloat((layer.value(forKeyPath: "transform.rotation.y")! as AnyObject).floatValue!)
		if !isRightPage {
			var progress = -(1 - rotationY / CGFloat(M_PI_2))
			ratio = progress
		}
			
		else {
			var progress = 1 - rotationY / CGFloat(-M_PI_2)
			ratio = progress
		}
		
		return ratio
	}
	
	func updateShadowLayer(animated: Bool = false) {
		var ratio: CGFloat = 0
		
		// Get ratio from transform. Check BookCollectionViewLayout for more details
		var inverseRatio = 1 - abs(getRatioFromTransform())
		
		if !animated {
			CATransaction.begin()
			CATransaction.setDisableActions(!animated)
		}
		
		if isRightPage {
			// Right page
			shadowLayer.colors = [
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
			]
			shadowLayer.locations = [
                NSNumber(value: 0.00),
				NSNumber(value: 0.02),
				NSNumber(value: 1.00)
			]
		} else {
			// Left page
			shadowLayer.colors = [
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.30).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.50).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
			]
			shadowLayer.locations = [
				NSNumber(value: 0.00),
				NSNumber(value: 0.50),
				NSNumber(value: 0.98),
				NSNumber(value: 1.00)
			]
		}
		
		if !animated {
			CATransaction.commit()
		}
	}
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.apply(layoutAttributes)
        //1
        if layoutAttributes.indexPath.item % 2 == 0 {
            //2
            layer.anchorPoint = CGPoint(x:0,y: 0.5)
            isRightPage = true
        } else { //3
            //4
            layer.anchorPoint = CGPoint(x:1,y: 0.5)
            isRightPage = false
        }
        //5
        self.updateShadowLayer()
    }
	
}
