//
//  Shape-Fill.swift
//  Flashzilla
//
//  Created by Nigel Gee on 15/01/2022.
//

import SwiftUI

extension Shape {
    func fill(using offset: CGSize) -> some View {
        if offset.width == 0 {
            return self.fill(.white)
        } else if offset.width < 0 {
            return self.fill(.red)
        } else {
            return self.fill(.green)
        }
    }
}
