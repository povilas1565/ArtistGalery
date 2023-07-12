//
//  LoadingIndicatorView.swift
//  LilPictures
//
//
//

import UIKit

class LoadingIndicatorView: UIActivityIndicatorView {
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        self.hidesWhenStopped = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
