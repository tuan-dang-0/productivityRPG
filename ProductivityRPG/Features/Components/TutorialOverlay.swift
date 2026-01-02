import SwiftUI

struct TutorialOverlay: View {
    let step: TutorialStep
    let onSkip: () -> Void
    @State private var isInteractive = false
    @State private var autoAdvanceTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.opacity(isInteractive ? 0.0 : 0.7)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.5), value: isInteractive)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isInteractive = true
                    }
                    
                    // Auto-advance viewSettings to tutorialComplete after 8 seconds
                    if step == .viewSettings {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                            onSkip()
                        }
                    }
                }
                .onDisappear {
                    autoAdvanceTimer?.invalidate()
                }
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(step.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // X button for tutorialComplete step (top-right)
                                if step == .tutorialComplete {
                                    Button(action: onSkip) {
                                        Image(systemName: "xmark")
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(8)
                                    }
                                }
                            }
                            
                            Text(step.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    // Skip button for non-complete steps
                    if step != .tutorialComplete {
                        HStack {
                            Spacer()
                            
                            Button(action: onSkip) {
                                Text("Skip Tutorial")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, step == .viewSettings ? 20 : 140)
                .allowsHitTesting(true)
            }
        }
        .transition(.opacity)
    }
}

struct TutorialPointer: View {
    let position: CGPoint
    let direction: PointerDirection
    
    var body: some View {
        VStack(spacing: 0) {
            if direction == .down {
                pointerShape
                    .frame(width: 30, height: 30)
            }
            
            Circle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "hand.tap.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                )
                .shadow(color: .blue.opacity(0.5), radius: 10)
            
            if direction == .up {
                pointerShape
                    .rotationEffect(.degrees(180))
                    .frame(width: 30, height: 30)
            }
        }
        .position(position)
    }
    
    private var pointerShape: some View {
        Triangle()
            .fill(Color.blue)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

enum PointerDirection {
    case up
    case down
}
