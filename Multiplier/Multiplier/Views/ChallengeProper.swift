import SwiftUI
import CoreHaptics

struct ChallengeProper: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var hadStarted = false
    @State private var backButtonDidTapped = false
    
    public var multiplyBy = 2
    public var numberOfQuestions = 5
    public var hasTimer : Bool = false
    
    @State private var timeRemaining = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRanOut = false
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var isTimerActive = false
    @State private var startTime = Date()
    
    @State private var selectedAnswer = 0
    @State private var currentQuestionNumber = 1
    @State private var isDone = false
    
    @State private var randomQuestion = 0
    @State private var answeredRandomQuestion: Set<Int> = []
    
    var actualAnswer: Int {
        multiplyBy * randomQuestion
    }
    
    @State private var choices : Set<Int> = []
    
    @State private var isMultipleChoice : Bool = true
    
    @State private var score = 0
    
    @State private var isCorrect = false
    @State private var hasAnswered = false
    
    @FocusState private var userTextIsFocused: Bool
    @State private var userTextAnswer = ""
    
    var submitButtonLabel : String {
        
        if hasAnswered {
            
            if isCorrect {
                
                "Correct"
                
            } else {
                
                "Wrong | \(actualAnswer)"
                
            }
            
        } else {
            "Submit"
        }
        
    }
    
    var submitButtonForegroundColor : Color {
        
        if hasAnswered {
            
            if isCorrect {
                Color.green
            } else {
                Color.red
            }
            
        } else {
            Color.white
        }
        
    }
    
    var foregroundTextColor : (Int, Int, Int, Bool) -> Color = { number, chosenAnswer, correctAnswer, hasAnswered in
        
        if hasAnswered {
            
            if number == correctAnswer && number == chosenAnswer {
                
                .green
                
            } else if number != correctAnswer && number == chosenAnswer {
                
                .red
                
            } else if number == correctAnswer && number != chosenAnswer {
                
                .green
                
            } else {
                
                .white
                
            }
            
        } else {
            .white
        }
    }
    
    // Animation related properties
    // Background
    @State private var gradientStart = UnitPoint.leading
    @State private var gradientEnd = UnitPoint.trailing
    
    // Buttons
    @State private var buttonSpinAmount = 0.0
    @State private var buttonOpacity = 1.0
    @State private var unChosenButtonScale = 1.0
    @State private var chosenButtonScale = 1.0
    @State private var floatOffset: CGFloat = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.cyan, .mint, .yellow, .orange] : [.red, .blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd)
                .ignoresSafeArea(.all)
                .blur(radius: colorScheme == .light ? 15: 30, opaque: true)
                .onAppear {
                    withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                        gradientStart = .topLeading
                        gradientEnd = .bottomTrailing
                    }
                }
            
            
            VStack {
                
                
                Text(hasTimer ? isTimerActive || (isTimerActive == false && timeRemaining > 0) ? "\(timeRemaining)" : "Time's Up!" : "Multiply by \(multiplyBy)")
                    .font(.largeTitle)
                    .fontWidth(.expanded)
                    .foregroundStyle(hasTimer ? isTimerActive || (isTimerActive == false && timeRemaining > 0) ? .primary : Color.red : .primary)
                    .padding()
                    .animation(.snappy, value: timeRemaining)
                    .offset(y: userTextIsFocused && UIDevice.current.userInterfaceIdiom == .phone ? 25 : 0)
                

                VStack{
                    Group {
                        Text(String(multiplyBy))
                            .font(.system(size: 75))
                            .fontWidth(.expanded)
                            .fontDesign(.serif)
                        Text("x")
                            .font(.system(size: 50))
                            .fontWidth(.expanded)
                            .fontDesign(.serif)
                        Text(String(randomQuestion))
                            .font(.system(size: 75))
                            .fontWidth(.expanded)
                            .fontDesign(.serif)
                        Text("=")
                            .font(.system(size: 50))
                            .fontWidth(.expanded)
                            .fontDesign(.serif)
                    }
                    .accessibilityElement()
                    .accessibilityLabel(Text("The question is: What is \(multiplyBy) times \(randomQuestion)?"))
                    
                    if (hasTimer && timeRanOut == false) || (hasTimer == false) {
                        if isMultipleChoice {
                            HStack {
                                ForEach(Array(choices), id: \.self) { number in
                                    Button {
                                        print("\(number) selected")
                                        selectedAnswer = number
                                        determineUserAnswer()
                                        
                                        withAnimation(.spring(duration: 1, bounce: 0.5)) {
                                            buttonSpinAmount += 360
                                            buttonOpacity -= 0.5
                                            unChosenButtonScale -= 0.25
                                            chosenButtonScale += 0.25
                                            floatOffset = 0
                                        }
                                        
                                    } label: {
                                        Text("\(number)")
                                            .font(.system(size: 40))
                                            .fontWidth(.expanded)
                                            .fontDesign(.serif)
                                    }
                                    .frame(minWidth: 50, maxHeight: 40)
                                    .padding()
                                    .scaleEffect(CGSize(width: chosenButtonScale, height: chosenButtonScale))
                                    .scaleEffect(
                                        CGSize(
                                            width: selectedAnswer == number ? chosenButtonScale : unChosenButtonScale,
                                            height: selectedAnswer == number ? chosenButtonScale : unChosenButtonScale
                                        )
                                    )
                                    .background(.orange)
                                    .clipShape(.circle)
                                    .foregroundStyle(foregroundTextColor(number, selectedAnswer, actualAnswer, hasAnswered))
                                    .shadow(
                                        radius: 3
                                    )
                                    .offset(y: floatOffset * CGFloat(Int.random(in: 1...choices.count)))
                                    .opacity(selectedAnswer == number ? 1.0 : buttonOpacity)
                                    .onAppear {
                                        withAnimation(
                                            Animation.easeInOut(duration: 2.5)
                                                .repeatForever(autoreverses: true)
                                        ) {
                                            floatOffset = CGFloat.random(in: -6...0)
                                        }
                                    }
                                    .rotation3DEffect(
                                        .degrees(selectedAnswer == number ? buttonSpinAmount : 0),
                                        axis: (x: 1, y: 0, z: 0)
                                    )
                                    .disabled(isAnimating)
                                    .sensoryFeedback(isCorrect ? .success : .error, trigger: selectedAnswer)
                                }
                                
                            }
                            
                        } else {
                            
                            VStack(spacing: 20) {
                                TextField(userTextIsFocused ? "" : "Type your answer", text: $userTextAnswer)
                                    .multilineTextAlignment(.center)
                                    .frame(width:
                                            userTextIsFocused || userTextAnswer.isEmpty == false ? textWidth() :
                                            UIDevice.current.userInterfaceIdiom == .pad ? 350 : .infinity,
                                           height: 40
                                    )
                                    .padding()
                                    .background(.white)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 40))
                                    .fontWidth(.expanded)
                                    .fontDesign(.serif)
                                    .clipShape(.rect(cornerRadius: 25))
                                    .shadow(radius: 3)
                                    .keyboardType(.decimalPad)
                                    .focused($userTextIsFocused)
                                    .animation(.easeInOut, value: userTextAnswer)
                                    .animation(.bouncy, value: userTextIsFocused)
                                    .accessibilityLabel("Type your answer")
                                    
                                Button {
                                    print("Answer is \(userTextAnswer)")
                                    selectedAnswer = Int(userTextAnswer.trimmingCharacters(in: .whitespaces)) ?? 0
                                    userTextIsFocused = false
                                    
                                    determineUserAnswer()
                                    
                                    withAnimation(.spring(duration: 1, bounce: 0.5)) {
                                        buttonSpinAmount += 360
                                        chosenButtonScale += 0.25
                                    }
                                } label: {
                                    Text(submitButtonLabel)
                                        .font(.system(size: 30))
                                        .fontWidth(.expanded)
                                        .fontDesign(.serif)
                                        
                                }
                                .foregroundStyle(submitButtonForegroundColor)
                                .padding()
                                .background(.orange)
                                .clipShape(.rect(cornerRadius: 25))
                                .scaleEffect(CGSize(width: chosenButtonScale, height: chosenButtonScale))
                                .shadow(radius: 3)
                                .rotation3DEffect(
                                    .degrees(buttonSpinAmount),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .animation(.default, value: submitButtonLabel)
                                .disabled(isAnimating)
                                .sensoryFeedback(isCorrect ? .success : .error, trigger: selectedAnswer)
                                    
                            }
                            .padding()
                            
                        }
                    }
                    
                    if hasTimer && timeRanOut {
                        Text("\(actualAnswer)")
                            .font(.system(size: 75))
                            .fontWidth(.expanded)
                            .fontDesign(.serif)
                            .animation(.easeInOut, value: timeRanOut)
                    }

                    
                    VStack(spacing: 10.0) {
                        HStack {
                            Text("\(currentQuestionNumber) / \(numberOfQuestions)")
                        }
                        .font(.system(size: 30))
                        .fontDesign(.serif)
                        Text("Score: \(score)")
                            .textCase(.uppercase)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .fontWidth(.expanded)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        backButtonDidTapped.toggle()
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear(perform: {
                determineRandomQuestion()
            })
            .alert("Are you sure you want to go back?", isPresented: $backButtonDidTapped) {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) { dismiss() }
                
            } message: {
                Text("Your current score will be lost. This cannot be undone.")
            }
            .alert("Result", isPresented: $isDone) {
                Button("Choose another Challenge") {
                    dismiss()
                }
                Button("Retry") { 
                    isDone = false
                    score = 0
                    currentQuestionNumber = 1
                    determineRandomQuestion()
                }
            } message: {
                Text("Your score is \(score) out of \(numberOfQuestions)")
            }

            
        }
        .sensoryFeedback(.error, trigger: timeRanOut)
        .onAppear {
            if hasTimer {
                resetTimer()
            }
        }
        .onReceive(timer) { time in
            guard isTimerActive else { return }
            
            DispatchQueue.main.async {
                withAnimation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                ) {
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                }
                
                withAnimation(.bouncy) {
                    if timeRemaining == 0 {
                        timesUp()
                    }
                }
                
            }
            
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                isTimerActive = true
            } else {
                isTimerActive = false
            }
        }
                    
    }
    
    // Timer related methods
    private func resetTimer() {
        timeRemaining = isMultipleChoice ? 5 : 10
        isTimerActive = true
    }
    
    func determineChoices() -> Set<Int> {
        var set: Set<Int> = []

        
        for x in 0..<4 {
            
            if x == 0 {
                set.insert(actualAnswer)
            } else {
                set.insert(getRandomNumberForSet(excluding: set) ?? Int.random(in: 2...15))
            }
            
        }
        
        return set
    }
    
    func determineUserAnswer() {
        
        if hasTimer { isTimerActive = false }
        
        hasAnswered = true
        isAnimating = true
        
        if selectedAnswer == actualAnswer {
            score += 1
            isCorrect = true
        } else {
            isCorrect = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            
            isAnimating = false
            determineChallenge()
            
        }
        
    }
    
    func timesUp() {
        
        userTextIsFocused = false
        timeRanOut = true
        
        isTimerActive = false
        
        isAnimating = true
        isCorrect = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            
            isAnimating = false
            determineChallenge()
            
        }
        
    }
    
    func determineChallenge() {
        
        withAnimation(.spring(duration: 1.0, bounce: 0.5)) {
            buttonSpinAmount = 0.0
            buttonOpacity = 1.0
            unChosenButtonScale = 1.0
            chosenButtonScale = 1.0
        } completion: {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                hasAnswered = false
                
                if currentQuestionNumber < numberOfQuestions {
                    currentQuestionNumber += 1 
                    determineRandomQuestion()
                } else {
                    isDone = true
                }
            }
        }
        
        
        
    }
    
    func determineRandomQuestion() {
        
        if hadStarted {
            withAnimation(.spring(duration: 1.0, bounce: 0.5)) {
                randomQuestion = randomIntWithException(in: 2...30, excluding: answeredRandomQuestion) ?? Int.random(in: 2...30)
                answeredRandomQuestion.insert(randomQuestion)
                
                isMultipleChoice = Bool.random()
                
                if isMultipleChoice {
                    choices = determineChoices()
                } else {
                    userTextAnswer.removeAll()
                }
                
                if hasTimer {
                    timeRanOut = false
                    resetTimer()
                }
                
            }
        } else {
            randomQuestion = Int.random(in: 2...30)
            answeredRandomQuestion.insert(randomQuestion)
            
            isMultipleChoice = Bool.random()
            
            if isMultipleChoice {
                choices = determineChoices()
            } else {
                userTextAnswer.removeAll()
            }
            
            if hasTimer { resetTimer() }
            
            hadStarted = true
        }
        
        
    }
    
    func getRandomNumber(excluding excludedNumbers: [Int]) -> Int? {
        let range = 2...(multiplyBy * 15)
        let availableNumbers = range.filter { !excludedNumbers.contains($0) }
        
        guard !availableNumbers.isEmpty else {
            return nil
        }
        
        return availableNumbers.randomElement()
    }
    
    func getRandomNumberForSet(excluding excludedNumbers: Set<Int>) -> Int? {
        let range = 2...(multiplyBy * 15)
        let availableNumbers = range.filter { choices.contains($0) == false }
        
        guard !availableNumbers.isEmpty else {
            return nil
        }
        
        return availableNumbers.randomElement()
    }
    
    private func randomIntWithException(in range: ClosedRange<Int>, excluding exceptions: Set<Int>) -> Int? {
        let validNumbers = Array(range).filter { !exceptions.contains($0) }
        return validNumbers.randomElement()
    }
    
    private func textWidth() -> CGFloat {
        let font = UIFont.systemFont(ofSize: 40)
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = (userTextAnswer as NSString).size(withAttributes: attributes)
        return max(50, textSize.width + 20)
    }
    
}

#Preview {
    ChallengeProper(multiplyBy: 4, numberOfQuestions: 10, hasTimer: true)
}
