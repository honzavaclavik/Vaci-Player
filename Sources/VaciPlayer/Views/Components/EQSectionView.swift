import SwiftUI

struct EQSectionView: View {
    @ObservedObject var eqManager: GuitarEQManager
    @State private var isExpanded = false
    @State private var selectedPreset = "Flat"
    
    let bandColors: [Color] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red, .pink]
    
    var body: some View {
        VStack(spacing: 8) {
            headerSection
            
            if isExpanded {
                expandedEQSection
            } else {
                compactEQSection
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.green.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("EQUALIZER")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
            
            Spacer()
            
            presetSelector
            expandToggleButton
        }
    }
    
    private var presetSelector: some View {
        Menu {
            ForEach(eqManager.availablePresets, id: \.self) { preset in
                Button(preset) {
                    selectedPreset = preset
                    eqManager.applyPreset(preset)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedPreset)
                    .font(.system(size: 10, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
            }
            .foregroundColor(.green)
        }
    }
    
    private var expandToggleButton: some View {
        Button(isExpanded ? "Less" : "More") {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .font(.system(size: 10, weight: .medium))
        .buttonStyle(.bordered)
        .controlSize(.mini)
        .tint(.green)
    }
    
    // MARK: - Expanded EQ Section
    private var expandedEQSection: some View {
        VStack(spacing: 12) {
            eqBandsGrid
            quickActionsRow
        }
    }
    
    private var eqBandsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 12) {
            ForEach(0..<eqManager.bandCount, id: \.self) { index in
                if let config = eqManager.getBandConfiguration(at: index) {
                    EQBandControlView(
                        frequency: config.displayName,
                        value: eqManager.getBand(at: index),
                        color: bandColors[index]
                    ) { newValue in
                        eqManager.setBand(at: index, gain: newValue)
                    }
                }
            }
        }
    }
    
    private var quickActionsRow: some View {
        HStack {
            Button("Reset All") { 
                selectedPreset = "Flat"
                eqManager.resetAllBands()
            }
            .font(.system(size: 10))
            .buttonStyle(.bordered)
            .controlSize(.mini)
            
            Spacer()
            
            quickPresetButtons
        }
    }
    
    private var quickPresetButtons: some View {
        HStack(spacing: 4) {
            ForEach(["Flat", "Rock", "Jazz"], id: \.self) { preset in
                Button(preset) {
                    selectedPreset = preset
                    eqManager.applyPreset(preset)
                }
                .font(.system(size: 10))
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .tint(selectedPreset == preset ? .green : .secondary)
            }
        }
    }
    
    // MARK: - Compact EQ Section
    private var compactEQSection: some View {
        HStack(spacing: 4) {
            ForEach(0..<eqManager.bandCount, id: \.self) { index in
                if let config = eqManager.getBandConfiguration(at: index) {
                    CompactEQBarView(
                        frequency: shortFrequencyName(config.displayName),
                        value: eqManager.getBand(at: index),
                        color: bandColors[index]
                    )
                }
            }
        }
    }
    
    private func shortFrequencyName(_ freq: String) -> String {
        switch freq {
        case "60Hz": return "60"
        case "170Hz": return "170"
        case "310Hz": return "310"
        case "600Hz": return "600"
        case "1kHz": return "1k"
        case "3kHz": return "3k"
        case "6kHz": return "6k"
        case "12kHz": return "12k"
        default: return freq
        }
    }
}

// MARK: - EQ Band Control Component
struct EQBandControlView: View {
    let frequency: String
    let value: Float
    let color: Color
    let setter: (Float) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(frequency)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.primary)
            
            Text("\(value, specifier: "%.1f")")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Button("+") {
                    setter(min(15, value + 1.5))
                }
                .font(.system(size: 10, weight: .bold))
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .tint(color)
                
                Button("0") {
                    setter(0)
                }
                .font(.system(size: 8))
                .buttonStyle(.bordered)
                .controlSize(.mini)
                
                Button("-") {
                    setter(max(-15, value - 1.5))
                }
                .font(.system(size: 10, weight: .bold))
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .tint(color)
            }
        }
        .padding(6)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Compact EQ Bar Component
struct CompactEQBarView: View {
    let frequency: String
    let value: Float
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(frequency)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.3))
                .frame(width: 12, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color)
                        .frame(width: 8, height: max(2, CGFloat(abs(value)) * 1.2))
                        .offset(y: value > 0 ? -6 : 6)
                )
        }
    }
}

// MARK: - Preview
struct EQSectionView_Previews: PreviewProvider {
    static var previews: some View {
        EQSectionView(eqManager: GuitarEQManager())
            .padding()
    }
}