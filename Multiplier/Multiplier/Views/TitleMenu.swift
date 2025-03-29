import SwiftUI

struct TitleMenu: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Animation related property
    @State private var gradientStart = UnitPoint.leading
    @State private var gradientEnd = UnitPoint.trailing
    
    @State private var shadowAnimationAmount = 1.0
    @State private var isJumping = false
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: colorScheme == .light ? [.orange, .yellow, .mint, .cyan] : [.red, .blue, .indigo, .purple]), startPoint: gradientStart, endPoint: gradientEnd)
            .ignoresSafeArea(.all)
            .blur(radius: colorScheme == .light ? 15: 30, opaque: true)
            .onAppear {
                withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                    gradientStart = .bottomLeading
                    gradientEnd = .topTrailing
                }
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 50.0) {
                    VStack(spacing: 15.0) {
                        HStack {
                            Image(systemName: "book")
                                .offset(y: isJumping ? -20 : 0)
                            Image(systemName: "multiply")
                                .offset(y: isJumping ? -10 : 0)
                            Image(systemName: "equal")
                                .offset(y: isJumping ? -5 : 0)
                        }
                        .animation(
                            .spring(duration: 0.3, bounce: 0.5)
                            .repeatForever(autoreverses: true),
                            value: isJumping
                        )
                        .imageScale(.large)
                        .foregroundColor(.primary)
                        .onAppear {
                            isJumping = true
                        }
                        
                        Text("Multiplier")
                            .font(.largeTitle)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .fontDesign(.serif)
                    }
                    
                    Text("A random and awesome \nmultiplication challenge")
                        .fontDesign(.serif)
                }
                .shadow(radius: 10, x: 0, y: 12)
                
                Spacer()
                
                NavigationLink(destination: ChallengeSelection()) {
                    
                    Text("Start Game 🥳")
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
                        .onAppear {
                            shadowAnimationAmount = 4
                        }
                    
                }
                .simultaneousGesture( 
                    TapGesture().onEnded {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                )
                
                
                Spacer()
                
                Text("©️ 2024 Jem Canaya. All Rights Reserved")
                    .font(.caption)
                
            }
            .padding()

        }
        
    }
    
    
}

#Preview {
    TitleMenu()
}
