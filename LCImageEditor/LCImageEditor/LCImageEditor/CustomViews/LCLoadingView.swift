//
//  LCLoadingView.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/18/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit
import Foundation

public class LCLoadingView {

    private let transparentView: UIView
    private let indicator: UIActivityIndicatorView
    
    static let shared = LCLoadingView()
    
    private init() {
        
        transparentView = UIView()
        transparentView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        transparentView.translatesAutoresizingMaskIntoConstraints = false
        
        indicator = UIActivityIndicatorView()
        indicator.color = .white
        
        transparentView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: transparentView.topAnchor),
            indicator.leftAnchor.constraint(equalTo: transparentView.leftAnchor),
            indicator.bottomAnchor.constraint(equalTo: transparentView.bottomAnchor),
            indicator.rightAnchor.constraint(equalTo: transparentView.rightAnchor),
        ])
    }
    
    func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        keyWindow.addSubview(transparentView)
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: keyWindow.topAnchor),
            transparentView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor),
            transparentView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor),
            transparentView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor),
        ])
        
        transparentView.alpha = 0
        indicator.startAnimating()
        UIView.animate(withDuration: kEnteringAnimationDuration, animations: {
            self.transparentView.alpha = 1
        })
    }
    
    func hide() {
        DispatchQueue.main.sync {
            UIView.animate(
                withDuration: kLeavingAnimationDuration,
                animations: {
                    self.transparentView.alpha = 0
            },
                completion: { completed in
                    self.transparentView.removeFromSuperview()
                    self.indicator.stopAnimating()
            })
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
