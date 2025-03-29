import SwiftUI
import CoreHaptics

struct ChallengeSelection: View {
    @Environment(\.colorScheme) var colorScheme
    
    let numberOfQuestions = [5, 10, 20]
    
    @State private var multiplyBy = 2
    @State private var selectedNumberOfQuestions = 0
    
    @State private var hasBegun = false
    
    @State private var withTimer = true
    
    // Animation related properties
    @State private var gradientStart = UnitPoint.leading
    @State private var gradientEnd = UnitPoint.trailing
    
    @State private var isMultiplierSelectionAnimating = false
    @State private var isNumberOfQuestionsSelectionAnimating = false
    
    @State private var shadowAnimationAmount = 1.0
    
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        let bindingSelection = Binding(
            get: { selectedNumberOfQuestions },
            set: { newValue in
                selectedNumberOfQuestions = newValue
                
                print("Selected Number of Questions: \(numberOfQuestions[newValue])")
                
                withAnimation {
                    isNumberOfQuestionsSelectionAnimating.toggle()
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNumberOfQuestionsSelectionAnimating = false
                }
            }
        )
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.indigo, .cyan] : [.red, .blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd)
                .ignoresSafeArea(.all)
                .blur(radius: colorScheme == .light ? 15: 30, opaque: true)
                .onAppear {
                    withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                        gradientStart = .trailing
                        gradientEnd = .leading
                    }
                }
            
            VStack {
                VStack(spacing: 10.0) {
                    VStack(spacing: 20.0) {
                        Text("Multiply by")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .fontDesign(.serif)
                        
                        HStack(alignment: .center, spacing: 60) {
                            
                            MultiplyBySelectionButton(multiplySelection: .decrease, multiplyBy: $multiplyBy, gradientStart: $gradientStart, gradientEnd: $gradientEnd)
                            
                            Text("\(multiplyBy)")
                                .font(.system(size: 80, weight: .medium, design: .none))
                                .fontWidth(.expanded)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: multiplyBy % 2 == 0 ? [.red, .orange, .yellow] : [.cyan, .teal, .green]), startPoint: gradientStart, endPoint: gradientEnd
                                    )
                                    .mask(
                                        Text("\(multiplyBy)")
                                            .font(.system(size: 80, weight: .medium, design: .none))
                                            .fontWidth(.expanded)
                                    )
                                    .shadow(radius: 10)
                                    
                                    
                                )
                                .scaleEffect(isMultiplierSelectionAnimating ? 1.2 : 1.0)
                                .animation(
                                    .spring(response: 0.2, dampingFraction: 0.4),
                                    value: isMultiplierSelectionAnimating
                                )
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                        gradientStart = .topLeading
                                        gradientEnd = .bottomTrailing
                                    }
                                }
                            
                            MultiplyBySelectionButton(multiplySelection: .increase, multiplyBy: $multiplyBy, gradientStart: $gradientStart, gradientEnd: $gradientEnd)
                            
                        }
                        
                        
//                        Stepper(value: $multiplyBy, in: 2...12, label: {
//                            Text("Select a multiplier")
//                                .textCase(.uppercase)
//                                .font(.subheadline)
//                                .fontWeight(.heavy)
//                                .fontWidth(.expanded)
//                        }, onEditingChanged: { _ in
//                            withAnimation {
//                                isMultiplierSelectionAnimating.toggle()
//                            }
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                                isMultiplierSelectionAnimating = false
//                            }
//                        })
                        
                    }
                    .onChange(of: multiplyBy) {
                        withAnimation {
                            isMultiplierSelectionAnimating.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isMultiplierSelectionAnimating = false
                        }
                    }
                    
                    VStack(spacing: 20.0) {
                        Text("Number of problems")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .fontDesign(.serif)
                        Text("\(numberOfQuestions[selectedNumberOfQuestions])")
                            .font(.system(size: 80, weight: .medium, design: .none))
                            .fontWidth(.expanded)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange, .yellow]), startPoint: gradientStart, endPoint: gradientEnd
                                )
                                .mask(
                                    Text("\(numberOfQuestions[selectedNumberOfQuestions])")
                                        .font(.system(size: 80, weight: .medium, design: .none))
                                        .fontWidth(.expanded)
                                )
                                .shadow(radius: 10)
                            )
                            .scaleEffect(isNumberOfQuestionsSelectionAnimating ? 1.2 : 1.0)
                            .animation(
                                .spring(response: 0.2, dampingFraction: 0.4), 
                                value: isNumberOfQuestionsSelectionAnimating
                            )
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                    gradientStart = .topLeading
                                    gradientEnd = .bottomTrailing
                                }
                            }
                        
//                        VStack {
//                            Text("Select a number of questions")
//                                .textCase(.uppercase)
//                                .font(.subheadline)
//                                .fontWeight(.heavy)
//                                .fontWidth(.expanded)
//                            
//                            Picker("Select a number of questions", selection: bindingSelection) {
//                                ForEach(0..<numberOfQuestions.count) {
//                                    Text("\(numberOfQuestions[$0])")
//                                }
//                            }
//                            .pickerStyle(.segmented)
//                        }
                        
                        HStack {
                            ForEach(numberOfQuestions.indices, id: \.self) { index in
                                
                                Button {
                                    bindingSelection.wrappedValue = index
                                } label: {
                                    Text("\(numberOfQuestions[index])")
                                        .frame(width: 70, height: 70)
                                        .font(.system(size: 60, weight: .medium, design: .none))
                                        .fontWidth(.expanded)
                                        .fontDesign(.serif)
                                        .padding(20)
                                        .foregroundStyle(.white)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: numberOfQuestions[selectedNumberOfQuestions] == numberOfQuestions[index] ? [.red, .orange, .yellow] : [.blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd
                                            )
                                        )
                                        .clipShape(.circle)
                                        .shadow(radius: 10)
                                        .offset(y: floatOffset)
                                        .onAppear {
                                            withAnimation(
                                                Animation.easeInOut(duration: 2.5)
                                                    .repeatForever(autoreverses: true)
                                            ) {
                                                floatOffset = CGFloat.random(in: -12...0)
                                            }
                                        }
                                        .scaleEffect(numberOfQuestions[selectedNumberOfQuestions] == numberOfQuestions[index] ? 1 : 0.75)
                                        .animation(
                                            .default,
                                            value: selectedNumberOfQuestions
                                        )
                                }
                                .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: bindingSelection.wrappedValue)
                            }

                        }
                        
                        HStack(spacing: 10) {
                            Text("With timer")
                                .font(.largeTitle)
                                .fontWeight(.light)
                                .fontDesign(.serif)
                            
                            
                            Button {
                                withTimer = true
                            } label: {
                                Text("Yes")
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25, weight: .medium, design: .none))
                                    .fontWidth(.expanded)
                                    .fontDesign(.serif)
                                    .padding(10)
                                    .foregroundStyle(.white)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: withTimer ? [.red, .orange, .yellow] : [.blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd
                                        )
                                    )
                                    .clipShape(.circle)
                                    .shadow(radius: 10)
                                    .offset(y: floatOffset * -0.5)
                                    .onAppear {
                                        withAnimation(
                                            Animation.easeInOut(duration: 2.5)
                                                .repeatForever(autoreverses: true)
                                        ) {
                                            floatOffset = CGFloat.random(in: 0...20)
                                        }
                                    }
                                    .scaleEffect(withTimer ? 1 : 0.75)
                                    .animation(
                                        .default,
                                        value: withTimer
                                    )
                            }
                            .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: withTimer)
                            
                            Button {
                                withTimer = false
                            } label: {
                                Text("No")
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 25, weight: .medium, design: .none))
                                    .fontWidth(.expanded)
                                    .fontDesign(.serif)
                                    .padding(10)
                                    .foregroundStyle(.white)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: !withTimer ? [.red, .orange, .yellow] : [.blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd
                                        )
                                    )
                                    .clipShape(.circle)
                                    .shadow(radius: 10)
                                    .offset(x: floatOffset * 1)
                                    .onAppear {
                                        withAnimation(
                                            Animation.easeInOut(duration: 2.5)
                                                .repeatForever(autoreverses: true)
                                        ) {
                                            floatOffset = CGFloat.random(in: 0...20)
                                        }
                                    }
                                    .scaleEffect(!withTimer ? 1 : 0.75)
                                    .animation(
                                        .default,
                                        value: withTimer
                                    )
                            }
                            .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: withTimer)

                            
                            
                        }
                        
                    }
                }
                .disabled(hasBegun)
                .opacity(hasBegun ? 0.5 : 1.0)
                
                
                Spacer()
                    .frame(height: 30)
                
                Button() {
                    print("The Game Began")
                    withAnimation {
                        hasBegun.toggle()
                    }
                    
                } label: {
                    Text("💪 Let the Game Begins! 💪")
                }
                .padding()
                .background(.orange)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .shadow(color: .accentColor, radius: (shadowAnimationAmount - 1) * 3) //static radius is 8
                .animation(
                    .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                    value: shadowAnimationAmount
                )
                .opacity(hasBegun ? 0.0 : 1.0)
                .hidden(hasBegun)
                .onAppear {
                    shadowAnimationAmount = 4
                }
                .sensoryFeedback(.start, trigger: hasBegun)
                
                
            }
            .navigationDestination(isPresented: $hasBegun) {
                ChallengeProper(multiplyBy: multiplyBy, numberOfQuestions: numberOfQuestions[selectedNumberOfQuestions], hasTimer: withTimer)
            }
            .navigationBarBackButtonHidden()
            .padding()
        }
            
    }
    
    enum MultiplySelection {
        case increase, decrease
    }
    
    struct MultiplyBySelectionButton: View {
        
        var multiplySelection: MultiplySelection

        @Binding var multiplyBy: Int
        @Binding var gradientStart: UnitPoint
        @Binding var gradientEnd: UnitPoint
        
        // Haptic related properties
        @State private var increaseMultiplyBy = 0
        @State private var decreseMultiplyBy = 0
        
        var body: some View {
            
            Button {
                
                switch multiplySelection {
                case .increase:
                    increaseMultiplyBy += 1
                    multiplyBy += 1
                case .decrease:
                    decreseMultiplyBy += 1
                    multiplyBy -= 1
                }
                
                
            } label: {
                Image(systemName: multiplySelection == .increase ? "plus.circle" : "minus.circle")
                    .font(.largeTitle)
                    .padding(5)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: multiplyBy % 2 == 0 ? [.red, .orange, .yellow] : [.green, .blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd
                        )
                        .mask(
                            Image(systemName: multiplySelection == .increase ? "plus.circle" : "minus.circle")
                                .font(.largeTitle)
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.primary)
                                .clipShape(.circle)
                        )
                    )
                    .clipShape(.circle)
                    .shadow(radius: 10)
            }
            .hidden(multiplySelection == .increase ? multiplyBy + 1 == 13 : multiplyBy - 1 == 1)
            .disabled(multiplySelection == .increase ? multiplyBy + 1 == 13 : multiplyBy - 1 == 1)
            .animation(.easeInOut, value: multiplyBy)
            .sensoryFeedback(multiplySelection == .increase ? .increase : .decrease, trigger: multiplySelection == .increase ? increaseMultiplyBy : decreseMultiplyBy)
            
        }
        
    }
    
}

#Preview {
    ChallengeSelection()
}
