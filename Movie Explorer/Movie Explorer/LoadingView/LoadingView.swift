//
//  LoadingView.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    static func instantiate() -> LoadingView {
        let nib = UINib(nibName: "LoadingView", bundle: nil)
        guard let v = nib.instantiate(withOwner: nil, options: nil).first as? LoadingView else {
            return LoadingView(frame: UIScreen.main.bounds)
        }
        v.frame = UIScreen.main.bounds
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }

    func show(in parent: UIView) {
        DispatchQueue.main.async {
            parent.addSubview(self)
            self.indicator.startAnimating()
            self.alpha = 0
            UIView.animate(withDuration: 0.18) { self.alpha = 1 }
        }
    }

    func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.18, animations: { self.alpha = 0 }) { _ in
                self.indicator.stopAnimating()
                self.removeFromSuperview()
            }
        }
    }
}

