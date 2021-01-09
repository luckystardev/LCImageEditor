//
//  Gradient.swift
//  LCImageEditor
//

import UIKit

/// A gradient value type.
internal struct Gradient {
	public let colors: [HSBColor]
	public let locations: [CGFloat]
	
	init(colors: [HSBColor], locations: [CGFloat]) {
		assert(locations.count >= 2, "There must be at least two locations to create a gradient.")
		assert(colors.count == locations.count, "The number of colors and number of locations must be equal.")
		
		locations.forEach { (location) in
			assert(location >= 0.0 && location <= 1.0, "Location must be between 0 and 1.")
		}
		
		// Create a sequence of the pairings, sorted ascending by location
		let pairs = zip(colors, locations).sorted { $0.1 < $1.1 }
		
		// Assign the internal colors and locations from the pairs
		self.colors = pairs.map { $0.0 }
		self.locations = pairs.map { $0.1 }
	}
	
	func color(at percent: CGFloat) -> HSBColor {
		assert(percent >= 0.0 && percent <= 1.0, "Percent must be between 0 and 1.")

		// Find the indices that contain the closest values below and above `percent`
		guard let maxIndex = locations.firstIndex (where: { (location) -> Bool in
			return location >= percent
		}) else { return colors[locations.endIndex] }
		guard maxIndex > locations.startIndex else { return colors[maxIndex] }
		let minIndex = locations.index(before: maxIndex)
		
		// Get the two locations
		let minLocation = locations[minIndex]
		let maxLocation = locations[maxIndex]
		
		// Get the two colors
		let leftColor = colors[minIndex]
		let rightColor = colors[maxIndex]
		
		// Calculate the percentage between the two colors that we want to find
		var scaledPercentage = (percent - minLocation) / (maxLocation - minLocation)
		if leftColor.hue > rightColor.hue && !leftColor.isGrayscale {
			scaledPercentage = 1 - scaledPercentage
		}
		
		return HSBColor.between(color: leftColor, and: rightColor, percent: scaledPercentage)
	}
}
