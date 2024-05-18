//
//  UIView.swift
//  SideMenu
//
//  Created by 奥江英隆 on 2024/05/17.
//

import Foundation
import UIKit

extension UIView {
    
    @discardableResult
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        guard let view = UINib(nibName: String(describing: Self.self), bundle: bundle).instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Invalid view")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        sameToPosition(view: view)
        return view
    }
    
    func sameToPosition(view: UIView) {
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}
