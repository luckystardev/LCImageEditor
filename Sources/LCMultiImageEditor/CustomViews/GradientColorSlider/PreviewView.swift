//
//  PreviewView.swift
//  LCImageEditor
//


import UIKit

public typealias PreviewView = UIView & ColorSliderPreviewing

/// The display state of a preview view.
public enum PreviewState {
	case inactive
	case activeFixed
	case active
}

public protocol ColorSliderPreviewing {
	func colorChanged(to color: UIColor)
	func transition(to state: PreviewState)
}
