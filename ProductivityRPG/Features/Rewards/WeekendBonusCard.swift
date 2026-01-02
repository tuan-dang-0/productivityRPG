import SwiftUI
import SwiftData

struct WeekendBonusCard: View {
    @Query private var weekendBonuses: [WeekendBonus]
    @Query private var wallets: [RewardWallet]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedMinutes: Int = 60
    @State private var showCelebration = false
    
    private var weekendBonus: WeekendBonus? {
        weekendBonuses.first
    }
    
    private var wallet: RewardWallet? {
        wallets.first
    }
    
    private var canClaim: Bool {
        weekendBonus?.canClaimBonus() ?? false
    }
    
    private var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 || weekday == 6 || weekday == 7
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Weekend Bonus")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    if canClaim {
                        Text("Claim your weekend reward!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if isWeekend {
                        Text("Already claimed this weekend")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Available Friday - Sunday")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let bonus = weekendBonus, let lastClaimed = bonus.lastClaimedDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(bonus.totalLifetimeBonusMinutes) min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("lifetime")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if canClaim {
                VStack(spacing: 12) {
                    Text("Select your bonus:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        BonusButton(minutes: 5, isSelected: selectedMinutes == 5) {
                            selectedMinutes = 5
                        }
                        BonusButton(minutes: 15, isSelected: selectedMinutes == 15) {
                            selectedMinutes = 15
                        }
                        BonusButton(minutes: 30, isSelected: selectedMinutes == 30) {
                            selectedMinutes = 30
                        }
                        BonusButton(minutes: 60, isSelected: selectedMinutes == 60) {
                            selectedMinutes = 60
                        }
                    }
                    
                    HStack(spacing: 12) {
                        BonusButton(minutes: 90, isSelected: selectedMinutes == 90) {
                            selectedMinutes = 90
                        }
                        BonusButton(minutes: 120, isSelected: selectedMinutes == 120) {
                            selectedMinutes = 120
                        }
                        BonusButton(minutes: 180, isSelected: selectedMinutes == 180) {
                            selectedMinutes = 180
                        }
                        BonusButton(minutes: 240, isSelected: selectedMinutes == 240) {
                            selectedMinutes = 240
                        }
                    }
                    
                    Button(action: claimBonus) {
                        HStack {
                            Image(systemName: "gift.circle.fill")
                            Text("Claim \(selectedMinutes) Minutes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            } else if !isWeekend {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Come back on Friday to claim your weekend bonus!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Bonus claimed! Enjoy your weekend 🎉")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .overlay(
            Group {
                if showCelebration {
                    CelebrationOverlay()
                }
            }
        )
    }
    
    private func claimBonus() {
        guard let bonus = weekendBonus, let wallet = wallet else { return }
        
        bonus.claimBonus(minutes: selectedMinutes)
        wallet.availableMinutes += selectedMinutes
        
        try? modelContext.save()
        
        withAnimation {
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCelebration = false
            }
        }
    }
}

struct BonusButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var displayText: String {
        if minutes >= 60 {
            let hours = minutes / 60
            return "\(hours)h"
        }
        return "\(minutes)m"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(displayText)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.orange : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct CelebrationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 20) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Bonus Claimed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Enjoy your weekend! 🎉")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 20)
        }
        .transition(.opacity)
    }
}
