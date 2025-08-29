import SwiftUI

struct EffectsStatusView: View {
    let reverbAmount: Float
    let inputLevel: Float
    let hasSelectedDevice: Bool
    let setReverbAmount: (Float) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            effectsSection
            statusSection
        }
    }
    
    // MARK: - Effects Section
    private var effectsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("EFFECTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.cyan)
                
                Spacer()
            }
            
            reverbControl
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.cyan.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var reverbControl: some View {
        HStack(spacing: 12) {
            Text("Reverb:")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.cyan)
            
            reverbDisplay
            
            Spacer()
            
            reverbButtons
        }
    }
    
    private var reverbDisplay: some View {
        Text("\(Int(reverbAmount * 100))%")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(minWidth: 35)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(.cyan.opacity(0.2), in: RoundedRectangle(cornerRadius: 3))
    }
    
    private var reverbButtons: some View {
        HStack(spacing: 4) {
            ReverbButton(label: "0", value: 0.0, currentValue: reverbAmount, action: setReverbAmount)
            ReverbButton(label: "25", value: 0.25, currentValue: reverbAmount, action: setReverbAmount)
            ReverbButton(label: "50", value: 0.5, currentValue: reverbAmount, action: setReverbAmount)
            ReverbButton(label: "75", value: 0.75, currentValue: reverbAmount, action: setReverbAmount)
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack {
            inputLevelIndicator
            
            Spacer()
            
            connectionStatus
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private var inputLevelIndicator: some View {
        HStack(spacing: 4) {
            Text("INPUT")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(.gray.opacity(0.3))
                .frame(width: 40, height: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(inputLevel > 0.7 ? .red : (inputLevel > 0.5 ? .orange : .green))
                        .frame(width: max(2, CGFloat(inputLevel) * 40), height: 6)
                        .animation(.easeOut(duration: 0.1), value: inputLevel)
                    , alignment: .leading
                )
        }
    }
    
    private var connectionStatus: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(hasSelectedDevice ? .green : .orange)
                .frame(width: 6, height: 6)
            
            Text(hasSelectedDevice ? "Active" : "Select Input")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(hasSelectedDevice ? .green : .orange)
        }
    }
}

// MARK: - Reverb Button Component
struct ReverbButton: View {
    let label: String
    let value: Float
    let currentValue: Float
    let action: (Float) -> Void
    
    var body: some View {
        Button(label) {
            action(value)
        }
        .font(.system(size: 9, weight: .medium))
        .buttonStyle(.borderedProminent)
        .controlSize(.mini)
        .tint(abs(currentValue - value) < 0.01 ? .cyan : .secondary)
    }
}

// MARK: - Preview
struct EffectsStatusView_Previews: PreviewProvider {
    static var previews: some View {
        EffectsStatusView(
            reverbAmount: 0.25,
            inputLevel: 0.6,
            hasSelectedDevice: true,
            setReverbAmount: { _ in }
        )
        .padding()
    }
}