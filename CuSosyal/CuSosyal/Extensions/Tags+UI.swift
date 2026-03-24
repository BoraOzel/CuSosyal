//
//  Tags+UI.swift
//  CuSosyal
//
//  Created by Bora Özel on 17/3/26.
//

import UIKit

extension Tags {
    var icon: UIImage? {
        return UIImage(named: String(describing: self))
    }
}
