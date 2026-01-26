//
//  FloatyAnimationModifier.swift
//  Chall4
//
//  Created by Bassel Taleb on 1/22/26.
//

import SwiftUI

struct FloatyAnimationModifier: ViewModifier {
    let intensity: CGFloat
    
    func body(content: Content) -> some View {
        let randomTimeOffset = Double.random(in: 0...50)
        
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate + randomTimeOffset
        }
        return TimelineView(.animation) {
            context in
            let time = context.date.timeIntervalSinceReferenceDate
            let angle = intensity * Self.rotationFactor * sin(time)
            let offsetX = intensity * Self.motionFactor * cos(time)
            let offsetY = intensity * Self.motionFactor * sin(time * 1.5)
            return content
                .rotationEffect(.degrees(angle))
                .offset(x: offsetX, y: offsetY)
        }
    }
    static let rotationFactor: CGFloat = 2
    static let motionFactor: CGFloat = 4
}

extension View {
    func withFloatyAnimation(_ intensity: CGFloat? = 1) -> some View {
        modifier(FloatyAnimationModifier(intensity: intensity ?? 0))
    }
}
