import SwiftUI
import UIKit

/// A reusable bottom sheet view with smooth gestures and physics-based animations
struct BottomSheetView<Content: View>: View {
    // Content to display in the sheet
    let content: Content
    
    // Customization options
    var showHandle: Bool = true
    var handleColor: Color = Color.gray.opacity(0.3)
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = 20
    
    // Available snap positions (measured from bottom)
    var snapPositions: [SnapPosition] = [.closed, .half, .open]
    
    // Gesture state
    @Binding var position: SnapPosition
    @State private var offset: CGFloat = 0
    @State private var previousOffset: CGFloat = 0
    
    // Thresholds for physics-based gestures
    var velocityThreshold: CGFloat = 300
    var resistanceFactor: CGFloat = 0.3
    
    enum SnapPosition: Equatable {
        case closed
        case half
        case open
        case custom(CGFloat)
        
        var height: CGFloat {
            switch self {
            case .closed: return 0
            case .half: return 300
            case .open: return 600
            case .custom(let height): return height
            }
        }
    }
    
    init(position: Binding<SnapPosition>, @ViewBuilder content: () -> Content) {
        self._position = position
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Optional handle at top of sheet
                if showHandle {
                    Rectangle()
                        .fill(handleColor)
                        .frame(width: 40, height: 4)
                        .cornerRadius(2)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                }
                
                // Content
                content
            }
            .frame(width: geometry.size.width)
            .background(backgroundColor)
            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
            .offset(y: geometry.size.height - offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Get the drag amount
                        let dragAmount = value.translation.height
                        let newOffset = previousOffset - dragAmount
                        
                        // Get the maximum height based on configured snap positions
                        let maxHeight = snapPositions.map { $0.height }.max() ?? 600
                        
                        // Apply resistance when pulling beyond boundaries
                        if newOffset < 0 {
                            offset = newOffset * resistanceFactor
                        } else if newOffset > maxHeight {
                            let extraPull = newOffset - maxHeight
                            offset = maxHeight + (extraPull * resistanceFactor)
                        } else {
                            offset = newOffset
                        }
                    }
                    .onEnded { value in
                        // Save position before gesture ended
                        previousOffset = offset
                        
                        // Calculate velocity for physics-based interactions
                        let predictedEndPosition = value.predictedEndTranslation.height
                        let velocity = predictedEndPosition - value.translation.height
                        
                        // Get all heights from the configured snap positions
                        let snapHeights = snapPositions.map { $0.height }.sorted()
                        
                        // Find the target position based on velocity or proximity
                        let targetHeight: CGFloat
                        
                        if abs(velocity) > velocityThreshold {
                            // If strong velocity, move in that direction to the nearest snap point
                            if velocity < 0 {
                                // Moving up - find next snap point higher than current
                                targetHeight = snapHeights.first(where: { $0 > offset }) ?? snapHeights.last ?? 0
                            } else {
                                // Moving down - find next snap point lower than current
                                targetHeight = snapHeights.last(where: { $0 < offset }) ?? snapHeights.first ?? 0
                            }
                        } else {
                            // Otherwise, snap to the closest position
                            targetHeight = snapHeights.min(by: { abs($0 - offset) < abs($1 - offset) }) ?? 0
                        }
                        
                        // Find the corresponding SnapPosition
                        let targetPosition = snapPositions.first(where: { $0.height == targetHeight }) ?? .closed
                        
                        // Animate to the target position
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            offset = targetHeight
                            position = targetPosition
                        }
                        
                        // Store the new position for next gesture
                        previousOffset = targetHeight
                        
                        // Provide haptic feedback
                        UIImpactFeedbackGenerator.generateFeedback(style: .medium)
                    }
            )
            .onAppear {
                // Initialize with the proper position
                offset = position.height
                previousOffset = position.height
            }
            .onChange(of: position) { oldValue, newValue in
                // Update offset when position changes programmatically
                if oldValue != newValue {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                        offset = newValue.height
                    }
                    previousOffset = newValue.height
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        BottomSheetView(position: .constant(.half)) {
            VStack(spacing: 20) {
                Text("Bottom Sheet")
                    .font(.headline)
                
                Text("Drag me up and down")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ForEach(1...5, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 60)
                        .overlay(
                            Text("Item \(item)")
                                .foregroundColor(.black)
                        )
                }
            }
            .padding()
            .padding(.bottom, 50)
        }
    }
} 