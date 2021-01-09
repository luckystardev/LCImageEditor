//
//  ColorSlider.swift
//  LCImageEditor
//

import UIKit

public protocol ColorSliderDelegate : class {
    func colorPicked(_ value: CGFloat)
}

public enum Orientation {
	case horizontal
	case vertical
}

public class ColorSlider: UIControl {
	/// The selected color.
	public var color: UIColor {
		get {
			return UIColor(hsbColor: internalColor)
		}
		set {
			internalColor = HSBColor(color: newValue)
			
			previewView?.colorChanged(to: color)
			previewView?.transition(to: .inactive)
			
			sendActions(for: .valueChanged)
		}
	}
	
    public weak var delegate: ColorSliderDelegate?
	/// The background gradient view.
	public let gradientView: GradientView
	
	/// The preview view, passed in the required initializer.
	public let previewView: PreviewView?
	
	/// The layout orientation of the slider, as defined in the required initializer.
	internal let orientation: Orientation
	
	/// The internal HSBColor representation of `color`.
	internal var internalColor: HSBColor

	@available(*, unavailable)
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) and storyboards are unsupported, use init(orientation:) instead.")
	}
	
	// MARK: - Init
	
	/// - parameter orientation: The orientation of the ColorSlider.
	/// - parameter side: The side of the ColorSlider on which to anchor the live preview.
	public convenience init(orientation: Orientation = .vertical, previewSide side: DefaultPreviewView.Side = .left) {
		// Check to ensure the side is valid for the given orientation
		switch orientation {
		case .horizontal:
			assert(side == .top || side == .bottom, "The preview must be on the top or bottom for orientation \(orientation).")
		case .vertical:
			assert(side == .left || side == .right, "The preview must be on the left or right for orientation \(orientation).")
		}
		
		// Create the preview view
		let previewView = DefaultPreviewView(side: side)
		self.init(orientation: orientation, previewView: previewView)
	}
	
	required public init(orientation: Orientation, previewView: PreviewView?) {
		self.orientation = orientation
		self.previewView = previewView
		
		gradientView = GradientView(orientation: orientation)
		internalColor = HSBColor(hue: 0, saturation: gradientView.saturation, brightness: 1)
		
		super.init(frame: .zero)
		
		addSubview(gradientView)
		
		if let currentPreviewView = previewView {
			currentPreviewView.isUserInteractionEnabled = false
			addSubview(currentPreviewView)
		}
	}
}

// MARK: - Layout
extension ColorSlider {
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientView.frame = bounds
		
		if let preview = previewView {
			switch orientation {
			
			// Initial layout pass, set preview center as needed
			case .horizontal where preview.center.y != bounds.midY,
			     .vertical where preview.center.x != bounds.midX:
				
				if internalColor.hue == 0 {
					// Initially set preview center to the top or left
					centerPreview(at: .zero)
				} else {
					// Set preview center from `internalColor`
					let sliderProgress = gradientView.calculateSliderProgress(for: internalColor)
					centerPreview(at: CGPoint(x: sliderProgress * bounds.width, y: sliderProgress * bounds.height))
				}
				
			// Adjust preview view size if needed
			case .horizontal where autoresizesSubviews:
				preview.bounds.size = CGSize(width: 25, height: bounds.height + 10)
			case .vertical where autoresizesSubviews:
				preview.bounds.size = CGSize(width: bounds.width + 10, height: 25)
				
			default:
				break
			}
		}
	}
	
	internal func centerPreview(at point: CGPoint) {
		switch orientation {
		case .horizontal:
			let boundedTouchX = (0..<bounds.width).clamp(point.x)
			previewView?.center = CGPoint(x: boundedTouchX, y: bounds.midY)
		case .vertical:
			let boundedTouchY = (0..<bounds.height).clamp(point.y)
			previewView?.center = CGPoint(x: bounds.midX, y: boundedTouchY)
		}
	}
}

// MARK: - UIControlEvents
extension ColorSlider {
	/// Begins tracking a touch when the user starts dragging.
	public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
		// Reset saturation to default value
		internalColor.saturation = gradientView.saturation

		update(touch: touch, touchInside: true)
		
		let touchLocation = touch.location(in: self)
		centerPreview(at: touchLocation)
		previewView?.transition(to: .active)
		
		sendActions(for: .touchDown)
		sendActions(for: .valueChanged)
		return true
	}
	
	/// Continues tracking a touch as the user drags.
	public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.continueTracking(touch, with: event)
		update(touch: touch, touchInside: isTouchInside)
        
		if isTouchInside {
			let touchLocation = touch.location(in: self)
			centerPreview(at: touchLocation)
		} else {
			previewView?.transition(to: .activeFixed)
		}
		
		sendActions(for: .valueChanged)
		return true
	}
	
	/// Ends tracking a touch when the user finishes dragging.
	public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
        
		guard let endTouch = touch else { return }
		update(touch: endTouch, touchInside: isTouchInside)
		
        self.delegate?.colorPicked(internalColor.hue)
        
		previewView?.transition(to: .inactive)
		
		sendActions(for: isTouchInside ? .touchUpInside : .touchUpOutside)
	}
	
	/// Cancels tracking a touch when the user cancels dragging.
	public override func cancelTracking(with event: UIEvent?) {
		sendActions(for: .touchCancel)
	}
}

// MARK: - Internal Calculations
fileprivate extension ColorSlider {
	/// Updates the internal color and preview view when a touch event occurs.
	/// - parameter touch: The touch that triggered the update.
	/// - parameter touchInside: Whether the touch that triggered the update was inside the control when the event occurred.
	func update(touch: UITouch, touchInside: Bool) {
		internalColor = gradientView.color(from: internalColor, after: touch, insideSlider: touchInside)
		previewView?.colorChanged(to: color)
	}
}

// MARK: - Increase Tappable Area
extension ColorSlider {
	/// Increase the tappable area of `ColorSlider` to a minimum of 44 points on either edge.
	override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		// If hidden, don't customize behavior
		guard !isHidden else { return super.hitTest(point, with: event) }
		
		// Determine the delta between the width / height and 44, the iOS HIG minimum tap target size.
		// If a side is already longer than 44, add 10 points of padding to either side of the slider along that axis.
		let minimumSideLength: CGFloat = 44
		let padding: CGFloat = -20
		let dx: CGFloat = min(bounds.width - minimumSideLength, padding)
		let dy: CGFloat = min(bounds.height - minimumSideLength, padding)
		
		// If an increased tappable area is needed, respond appropriately
		let increasedTapAreaNeeded = (dx < 0 || dy < 0)
		let expandedBounds = bounds.insetBy(dx: dx / 2, dy: dy / 2)
		
		if increasedTapAreaNeeded && expandedBounds.contains(point) {
			for subview in subviews.reversed() {
				let convertedPoint = subview.convert(point, from: self)
				if let hitTestView = subview.hitTest(convertedPoint, with: event) {
					return hitTestView
				}
			}
			return self
		} else {
			return super.hitTest(point, with: event)
		}
	}
}
