import SwiftUI
import UIKit

// Move enum outside of the generic struct
enum CardPosition {
    case collapsed, half, expanded
    
    var offset: CGFloat {
        switch self {
        case .collapsed: return 0
        case .half: return 200
        case .expanded: return 450
        }
    }
}

struct IntegratedTabCardView<CardContent: View>: View {
    // Tab bar binding
    @Binding var selectedTab: TabItem
    let addAction: () -> Void
    
    // Card content and state
    let cardContent: CardContent
    @Binding var cardPosition: CardPosition
    
    // Position state
    @State private var offset: CGFloat = 0
    @State private var previousOffset: CGFloat = 0
    
    // Define snap points
    var collapsedPosition: CGFloat = 0
    var halfPosition: CGFloat = 200
    var expandedPosition: CGFloat = 450
    
    // Configure physics
    var velocityThreshold: CGFloat = 300
    var resistanceFactor: CGFloat = 0.3
    
    init(selectedTab: Binding<TabItem>, 
         cardPosition: Binding<CardPosition>,
         addAction: @escaping () -> Void,
         @ViewBuilder cardContent: () -> CardContent) {
        self._selectedTab = selectedTab
        self._cardPosition = cardPosition
        self.addAction = addAction
        self.cardContent = cardContent()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Card content - positioned above tab bar when visible
                if offset > 0 {
                    VStack(spacing: 0) {
                        // Handle indicator
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .cornerRadius(2)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        
                        // Dynamic card content
                        cardContent
                            .padding(.bottom, 24)
                    }
                    .background(Color.white)
                    .cornerRadius(Constants.Layout.cornerRadius, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
                    .offset(y: -offset)
                    .zIndex(1)
                }
                
                // Tab bar with plus button - always visible at bottom
                TabBarWithContextualAdd(
                    selectedTab: $selectedTab,
                    addAction: addAction
                )
                .background(Color.white)
                .cornerRadius(Constants.Layout.cornerRadius, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.05), radius: 3, y: -2)
                .zIndex(0)
            }
            .frame(height: geometry.size.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Follow finger precisely during drag
                        let dragAmount = value.translation.height
                        let newOffset = previousOffset - dragAmount
                        
                        // Add resistance when pulling beyond boundaries
                        if newOffset < collapsedPosition {
                            offset = newOffset * resistanceFactor
                        } else if newOffset > expandedPosition {
                            let extraPull = newOffset - expandedPosition
                            offset = expandedPosition + (extraPull * resistanceFactor)
                        } else {
                            offset = newOffset
                        }
                    }
                    .onEnded { value in
                        // Previous position before gesture ended
                        previousOffset = offset
                        
                        // Calculate velocity of movement
                        let predictedEndPosition = value.predictedEndTranslation.height
                        let velocity = predictedEndPosition - value.translation.height
                        
                        // Determine which position to snap to based on position and velocity
                        var targetPosition: CardPosition
                        
                        // If velocity is significant, prioritize direction
                        if abs(velocity) > velocityThreshold {
                            targetPosition = velocity < 0 ? .expanded : .collapsed
                        } else {
                            // Otherwise snap to nearest position
                            if offset < halfPosition / 2 {
                                targetPosition = .collapsed
                            } else if offset < (halfPosition + expandedPosition) / 2 {
                                targetPosition = .half
                            } else {
                                targetPosition = .expanded
                            }
                        }
                        
                        // Get target position value
                        let targetOffset: CGFloat
                        switch targetPosition {
                        case .collapsed:
                            targetOffset = collapsedPosition
                        case .half:
                            targetOffset = halfPosition
                        case .expanded:
                            targetOffset = expandedPosition
                        }
                        
                        // Animate to target position with spring and velocity
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            offset = targetOffset
                            cardPosition = targetPosition
                        }
                        
                        // Store the new position
                        previousOffset = targetOffset
                        
                        // Generate haptic feedback when snapping
                        UIImpactFeedbackGenerator.generateFeedback(style: .medium)
                    }
            )
            .onAppear {
                // Initialize with proper card position
                offset = cardPosition.offset
                previousOffset = cardPosition.offset
            }
            .onChange(of: cardPosition) { oldValue, newValue in
                if oldValue != newValue {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                        offset = newValue.offset
                        previousOffset = newValue.offset
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        
        IntegratedTabCardView(
            selectedTab: .constant(.calories),
            cardPosition: .constant(.half),
            addAction: {}
        ) {
            VStack(spacing: 16) {
                ForEach(1...3, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 80)
                        .overlay(
                            Text("Content Item \(item)")
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }
} 