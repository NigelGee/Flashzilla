//
//  Stack-View.swift
//  Flashzilla
//
//  Created by Nigel Gee on 15/01/2022.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}
