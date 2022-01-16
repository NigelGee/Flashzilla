//
//  ContentView.swift
//  Flashzilla
//
//  Created by Nigel Gee on 09/01/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @AccessibilityFocusState var focus: Bool

    @State private var isShowingAnswer = false

    @State private var cards = [Card]()

    @State private var timeRemaining = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var isActive = true
    @State private var showingEditScreen = false

    var formattedTime: String {
        let minute = timeRemaining / 60
        let seconds = String(format: "%02d", timeRemaining % 60)
        return "\(minute):\(seconds)"
    }

    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()


            VStack {
                HStack {
                    if cards.isEmpty || timeRemaining == 0 {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(.white)
                            .clipShape(Capsule())


                    }
                    Spacer()

                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .font(.largeTitle)
                            .background(.black.opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Add New Card")
                }
                Spacer()
            }
            .padding()
            
            VStack {

                Text("Time: \(formattedTime)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())

                ZStack {
                    ForEach(Array(cards.enumerated()), id: \.element) { item in
                        CardView(card: item.element, isShowingAnswer: $isShowingAnswer) { reinsert in
                            withAnimation {
                                removeCard(at: item.offset, reinsert: reinsert)
                            }
                        }
                        .stacked(at: item.offset, in: cards.count)
                        .allowsHitTesting(item.offset == cards.count - 1)
                        .accessibilityHidden(item.offset < cards.count - 1)
                        .accessibilityFocused($focus)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
            }

            if voiceOverEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1, reinsert: true)
                            }
                        } label: {

                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being wrong.")

                        Spacer()

                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1, reinsert: false)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isNotEmpty {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCardView.init)
        .onAppear(perform: resetCards)
    }

    func removeCard(at index: Int, reinsert: Bool) {
        guard index >= 0 else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            focus = true
        }

        if reinsert {
            cards.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        } else {
            cards.remove(at: index)
        }


        isShowingAnswer = false

        if cards.isEmpty {
            isActive = false
        }
    }

    func resetCards() {
        timeRemaining = 120
        isActive = true
        cards = DataManager.load()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
