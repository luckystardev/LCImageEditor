//
//  DefaultPreviewView.swift
//  LCImageEditor
//


import UIKit

/// The default preview view of a `ColorSlider`.

public class DefaultPreviewView: UIView {
	/// The animation duration when showing the preview. Defaults to `0.15`.
	public var animationDuration: TimeInterval = 0.15
	
	/// The side of the `ColorSlider` on which to show the preview view.
	public enum Side {
		case left
		case right
		case top
		case bottom
	}
	
	/// The side of the ColorSlider that the preview should show on. Defaults to `.left`.
	public var side: Side {
		didSet {
			calculateOffset()
		}
	}
	
	/// The scale of the slider for each preview state.
	/// Defaults to:
	/// * `.inactive`: `1`
	/// * `.activeFixed`: `1.2`
	/// * `.active`: `1.6`
	public var scaleAmounts: [PreviewState: CGFloat] = [.inactive: 1.0,
	                                                    .activeFixed: 1.2,
	                                                    .active: 1.6]
	
	/// The number of points to offset the preview view from the slider when the state is set to `.active`. Defaults to `20`.
	public var offsetAmount: CGFloat = 20 {
		didSet {
			calculateOffset()
		}
	}
	
	public var offset: CGPoint
	
	/// The view that displays the current color as its `backgroundColor`.
	public let colorView: UIView = UIView()
	
	/// Enable haptics on iPhone 7 and above for state transitions to/from `.activeFixed`. Defaults to `true`.
	public var hapticsEnabled: Bool = true
	
	/// The last state that occurred, used to trigger haptic feedback when a selection occurs.
	fileprivate var lastState: PreviewState = .inactive
	
	/// Initialize with a specific side.
	/// - parameter side: The side of the `ColorSlider` to show on. Defaults to `.left`.
	required public init(side: Side = .left) {
		self.side = side
		colorView.backgroundColor = .systemBlue
		offset = CGPoint(x: -offsetAmount, y: 0)
		
		super.init(frame: .zero)
		
		backgroundColor = .white
		
		// Outer shadow
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 2, height: 2)
		
		// Borders
		colorView.clipsToBounds = true
		colorView.layer.borderWidth = 1.0
		colorView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
		addSubview(colorView)
		
		calculateOffset()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		
		// Automatically set the preview view corner radius based on the shortest side
		layer.cornerRadius = min(bounds.width, bounds.height) / 2
		
		// Inset the color view by 3 points, round the corners
		let colorViewFrame = bounds.insetBy(dx: 3, dy: 3)
		colorView.frame = colorViewFrame
		colorView.layer.cornerRadius = min(colorViewFrame.width, colorViewFrame.height) / 2
	}
	
	/// Calculate the offset of the preview view when `offset` or `side` are set.
	public func calculateOffset() {
		switch side {
		case .left:
			offset = CGPoint(x: -offsetAmount, y: 0)
		case .right:
			offset = CGPoint(x: offsetAmount, y: 0)
		case .top:
			offset = CGPoint(x: 0, y: -offsetAmount)
		case .bottom:
			offset = CGPoint(x: 0, y: offsetAmount)
		}
	}
}

extension DefaultPreviewView: ColorSliderPreviewing {
	
	public func colorChanged(to color: UIColor) {
		colorView.backgroundColor = color
	}
	
	public func transition(to state: PreviewState) {
		// The `.beginFromCurrentState` option allows there to be no delay when another touch occurs and a previous transition hasn't finished.
		UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
			// Only show the outer shadow when the state is inactive.
			self.colorView.layer.borderWidth = (state == .inactive ? 0 : 1)
			
			switch state {

			// Set the transform based on `scaleAmounts`.
			case .inactive,
			     .activeFixed:
				let scaleAmount = self.scaleAmounts[state] ?? 1
				let scaleTransform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
				self.transform = scaleTransform
				
			// Set the transform based on `scaleAmounts` and `offset`.
			case .active:
				let scaleAmount = self.scaleAmounts[state] ?? 1
				let scaleTransform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
				let translationTransform = CGAffineTransform(translationX: self.offset.x, y: self.offset.y)
				self.transform = scaleTransform.concatenating(translationTransform)
				
			}
		}, completion: nil)
		
		// Haptics
		if hapticsEnabled, #available(iOS 10.0, *) {
			switch (lastState, state) {
				
			// Medium impact haptic when first drag outside bounds occurs.
			case (.active, .activeFixed):
				let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
				impactFeedback.impactOccurred()
				
			// Light impact haptic when color selection outside bounds occurs.
			case (.activeFixed, .inactive):
				let impactFeedback = UIImpactFeedbackGenerator(style: .light)
				impactFeedback.impactOccurred()
			
			// No haptic feedback for other state transitions.
			default:
				break
				
			}
		}
		
		lastState = state
	}
}
