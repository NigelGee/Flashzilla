//
//  CardView.swift
//  Flashzilla
//
//  Created by Nigel Gee on 10/01/2022.
//

import SwiftUI

struct CardView: View {
    let card: Card
    @Binding var isShowingAnswer: Bool
    var removal: ((Bool) -> Void)? = nil
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled

//    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero

    @State private var feedBack = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? .white
                    : .white.opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(using: offset)
                )
                .shadow(radius: 10)
            
            VStack {
                if voiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)

            if differentiateWithoutColor {
                if offset.width > 0 {
                    Image(systemName: "checkmark.circle")
                        .padding()
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .background(.black.opacity(0.7))
                        .clipShape(Circle())

                } else if offset.width < 0 {
                    Image(systemName: "xmark.circle")
                        .padding()
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .background(.black.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    isShowingAnswer = false
                    offset = gesture.translation
                    feedBack.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        if offset.width > 0 {
                            feedBack.notificationOccurred(.success)
                            removal?(false)
                        } else {
                            feedBack.notificationOccurred(.error)
                            removal?(true)
                            offset = .zero
                        }
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.spring(), value: offset)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example, isShowingAnswer: .constant(false))
    }
}
