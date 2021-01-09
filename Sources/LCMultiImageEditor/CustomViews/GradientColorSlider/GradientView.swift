//
//  GradientView.swift
//  LCImageEditor
//

import UIKit

public final class GradientView: UIView {
	/// Whether the gradient should adjust its corner radius based on its bounds.
	/// When `true`, the layer's corner radius is set to `min(bounds.width, bounds.height) / 2.0` in `layoutSubviews`.
	public var automaticallyAdjustsCornerRadius: Bool = true {
		didSet {
			setNeedsLayout()
		}
	}
	
	/// The saturation of all colors in the view.
	/// Defaults to `1`.
	public var saturation: CGFloat = 1 {
		didSet {
			gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
		}
	}
	
	/// The percent of space at the beginning (top for orientation `.vertical` and left for orientation `.horizontal`) end of the slider reserved for the color white.
	/// Defaults to `0.15`.
	public var whiteInset: CGFloat = 0.15 {
		didSet {
			gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
		}
	}
	
	/// The percent of space at the end (bottom for orientation `.vertical` and right for orientation `.horizontal`) end of the slider reserved for the color black.
	/// Defaults to `0.15`.
	public var blackInset: CGFloat = 0.15 {
		didSet {
			gradient = Gradient.colorSliderGradient(saturation: saturation, whiteInset: whiteInset, blackInset: blackInset)
		}
	}

	/// The internal gradient used to draw the view.
	fileprivate var gradient: Gradient {
		didSet {
			setNeedsDisplay()
		}
	}
	
	/// The orientation of the gradient view. This is always equal to the value of `orientation` in the corresponding `ColorSlider` instance.
	fileprivate let orientation: Orientation
	
	/// - parameter orientation: The orientation of the gradient view.
	required public init(orientation: Orientation) {
		self.orientation = orientation
		self.gradient = Gradient.colorSliderGradient(saturation: 1, whiteInset: 0.15, blackInset: 0.15)
		
		super.init(frame: .zero)
		
		backgroundColor = .clear
		isUserInteractionEnabled = false
		
		// By default, show a border
		layer.masksToBounds = true
		layer.borderColor = UIColor.systemBlue.cgColor
		layer.borderWidth = 1
		
		// Set up based on orientation
		switch orientation {
		case .vertical:
			gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
			gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
		case .horizontal:
			gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
			gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		}
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Layer and Internal Drawing
public extension GradientView {
	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
	fileprivate var gradientLayer: CAGradientLayer {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			fatalError("Layer must be a gradient layer.")
		}
		return gradientLayer
	}
	
	override func draw(_ rect: CGRect) {
		gradientLayer.colors = gradient.colors.map({ (hsbColor) -> CGColor in
			return UIColor(hsbColor: hsbColor).cgColor
		})
		gradientLayer.locations = gradient.locations as [NSNumber]
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Automatically adjust corner radius if needed
		if automaticallyAdjustsCornerRadius {
			let shortestSide = min(bounds.width, bounds.height)
			let automaticCornerRadius = shortestSide / 2.0
			if layer.cornerRadius != automaticCornerRadius {
				layer.cornerRadius = automaticCornerRadius
			}
		}
	}
}

// MARK: - Math

internal extension GradientView {
    
	func color(from oldColor: HSBColor, after touch: UITouch, insideSlider: Bool) -> HSBColor {
		var color = oldColor

		if insideSlider {
			// Determine the progress of a touch along the slider given self.orientation
			let progress = touch.progress(in: self, withOrientation: orientation)
			
			// Set hue based on percent
			color = calculateColor(for: progress)
		} else {
			
			guard let containingView = touch.view?.superview else { return color }
			let horizontalPercent = touch.progress(in: containingView, withOrientation: .horizontal)
			let verticalPercent = touch.progress(in: containingView, withOrientation: .vertical)
			
			switch orientation {
			case .vertical:
				color.saturation = horizontalPercent
				color.brightness = 1 - verticalPercent
			case .horizontal:
				color.saturation = 1 - verticalPercent
				color.brightness = horizontalPercent
			}
			
			if oldColor.isGrayscale {
				color.saturation = 0
			}
		}
		
		return color
	}
	
	func calculateColor(for sliderProgress: CGFloat) -> HSBColor {
		return gradient.color(at: sliderProgress)
	}
    
	func calculateSliderProgress(for color: HSBColor) -> CGFloat {
		var sliderProgress: CGFloat = 0.0
		if color.isGrayscale {
			if color.brightness > 0.5 {
				sliderProgress = whiteInset / 2
			} else {
				sliderProgress = 1 - (blackInset / 2)
			}
		} else {
			let spaceForNonGrayscaleColors = 1 - blackInset - whiteInset
			sliderProgress = ((1 - color.hue) * spaceForNonGrayscaleColors) + whiteInset
		}
		return sliderProgress
	}
}

fileprivate extension Gradient {
	static func colorSliderGradient(saturation: CGFloat, whiteInset: CGFloat, blackInset: CGFloat) -> Gradient {
		// Values from 0 to 1 at intervals of 0.1
		let values: [CGFloat] = [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99]
		
		// Use these values as the hues for non-white and non-black colors
		let hues = values
		let nonGrayscaleColors = hues.map({ (hue) -> HSBColor in
			return HSBColor(hue: hue, saturation: saturation, brightness: 1)
		}).reversed()
		
		// Black and white are at the top and bottom of the slider, insert colors in between
		let spaceForNonGrayscaleColors = 1 - whiteInset - blackInset
		let nonGrayscaleLocations = values.map { (location) -> CGFloat in
			return whiteInset + (location * spaceForNonGrayscaleColors)
		}
		
		// Add black and white to locations and colors, set up gradient layer
		let colors = [HSBColor.white] + nonGrayscaleColors + [HSBColor.black]
		let locations = [0] + nonGrayscaleLocations + [1]
		return Gradient(colors: colors, locations: locations)
	}
}
