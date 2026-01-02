import SwiftUI

struct ScheduleBlockRow: View {
    @Bindable var block: TimeBlock
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDeleteFuture: (() -> Void)?
    
    @State private var iconImage: UIImage?
    
    private var backgroundColor: Color {
        return Color.black
    }
    
    private var textColor: Color {
        return Color.white
    }
    
    private var statIconName: String? {
        guard let category = block.subcategory?.category else { return nil }
        switch category.statType {
        case .strength: return "strength_icon"
        case .agility: return "agility_icon"
        case .intelligence: return "intelligence_icon"
        case .artistry: return "artistry_icon"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = iconImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(block.title)
                    .font(.headline)
                    .foregroundColor(textColor)
                
                Text(Formatters.formatTimeRange(start: block.startTime, end: block.endTime))
                    .font(.subheadline)
                    .foregroundColor(textColor.opacity(0.7))
                
                Text("\(block.tasks.count) tasks • \(block.baseRewardMinutes) min reward")
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.7))
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                if block.isRecurring {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete This Event", systemImage: "trash")
                    }
                    if let onDeleteFuture = onDeleteFuture {
                        Button(role: .destructive, action: onDeleteFuture) {
                            Label("Delete This and Future Events", systemImage: "trash.fill")
                        }
                    }
                } else {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .onAppear {
            loadOptimizedIcon()
        }
        .onDisappear {
            iconImage = nil
        }
    }
    
    private func loadOptimizedIcon() {
        guard let iconName = statIconName,
              let original = UIImage(named: iconName) else { return }
        
        let targetSize = CGSize(width: 56, height: 56)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        original.draw(in: CGRect(origin: .zero, size: targetSize))
        iconImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
