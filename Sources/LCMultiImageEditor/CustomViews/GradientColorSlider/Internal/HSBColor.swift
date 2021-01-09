//
//  HSBColor.swift
//  LCImageEditor
//

import UIKit

internal struct HSBColor: Equatable {
	static let black = HSBColor(hue: 0, saturation: 1, brightness: 0)
	static let white = HSBColor(hue: 1, saturation: 0, brightness: 1)
	
	var hue: CGFloat = 0
	var saturation: CGFloat = 1
	var brightness: CGFloat = 1
	
	var isGrayscale: Bool {
		return saturation == 0
	}
	
	init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
		self.hue = hue
		self.saturation = saturation
		self.brightness = brightness
	}
	
	init(color: UIColor) {
		color.getHue(&self.hue, saturation: &self.saturation, brightness: &self.brightness, alpha: nil)
	}
	
	static func between(color: HSBColor, and otherColor: HSBColor, percent: CGFloat) -> HSBColor {
		let hue = min(color.hue, otherColor.hue) + (abs(color.hue - otherColor.hue) * percent)
		let saturation = min(color.saturation, otherColor.saturation) + (abs(color.saturation - otherColor.saturation) * percent)
		let brightness = min(color.brightness, otherColor.brightness) + (abs(color.brightness - otherColor.brightness) * percent)
		return HSBColor(hue: hue, saturation: saturation, brightness: brightness)
	}
	
	static func ==(lhs: HSBColor, rhs: HSBColor) -> Bool {
		return lhs.hue == rhs.hue &&
			   lhs.saturation == rhs.saturation &&
			   lhs.brightness == rhs.brightness
	}
}

internal extension UIColor {
	/// A convenience initializer to create a `UIColor` from an `HSBColor`.
	convenience init(hsbColor: HSBColor) {
		self.init(hue: hsbColor.hue, saturation: hsbColor.saturation, brightness: hsbColor.brightness, alpha: 1)
	}
}
