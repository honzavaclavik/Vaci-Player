import SwiftUI
import AVFoundation

struct WaveformView: View {
    let song: Song
    @ObservedObject var audioManager: AudioManager
    @State private var waveformData: [Float] = []
    @State private var isLoading = false
    @State private var loopStart: TimeInterval? = nil
    @State private var loopEnd: TimeInterval? = nil
    @State private var isSelectingLoop = false
    @State private var dragStart: CGPoint?
    @State private var dragEnd: CGPoint?
    
    // Zoom and pan functionality
    @State private var zoomLevel: CGFloat = 1.0 // 1.0 = no zoom, 10.0 = max zoom
    @State private var panOffset: CGFloat = 0.0 // Horizontal offset when zoomed
    @State private var isPanning = false
    
    private let waveformHeight: CGFloat = 120
    private let maxSamples = 2000 // Optimize for performance
    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 20.0
    
    var body: some View {
        VStack(spacing: 8) {
            // Waveform header with controls
            HStack {
                Text("Waveform")
                    .font(.headline)
                
                // Zoom controls
                HStack(spacing: 8) {
                    Button(action: { zoomOut() }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    .disabled(zoomLevel <= minZoom)
                    
                    Text("\(Int(zoomLevel))x")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 30)
                    
                    Button(action: { zoomIn() }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .disabled(zoomLevel >= maxZoom)
                    
                    if zoomLevel > minZoom {
                        Button("Reset") {
                            resetZoom()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .buttonStyle(.plain)
                .controlSize(.small)
                
                Spacer()
                
                if let start = loopStart, let end = loopEnd {
                    HStack(spacing: 12) {
                        Text("Loop: \(formatTime(start)) - \(formatTime(end))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button("Zrušit loop") {
                            clearLoop()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } else {
                    Text("Přetáhni myší = loop, ⌥+drag = posun")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Waveform visualization
            ZStack {
                // Background
                Rectangle()
                    .fill(.regularMaterial)
                    .frame(height: waveformHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                if isLoading {
                    ProgressView("Načítání waveformu...")
                        .frame(height: waveformHeight)
                } else if waveformData.isEmpty {
                    Text("Waveform není dostupný")
                        .foregroundStyle(.secondary)
                        .frame(height: waveformHeight)
                } else {
                    GeometryReader { geometry in
                        ZStack {
                            // Create zoomed and panned view
                            let zoomedWidth = geometry.size.width * zoomLevel
                            let maxPan = max(0, zoomedWidth - geometry.size.width)
                            let clampedPanOffset = max(-maxPan / 2, min(maxPan / 2, panOffset))
                            
                            ZStack {
                                // Loop selection background
                                if let start = loopStart, let end = loopEnd, song.duration > 0 {
                                    let startX = CGFloat(start / song.duration) * zoomedWidth + clampedPanOffset
                                    let endX = CGFloat(end / song.duration) * zoomedWidth + clampedPanOffset
                                    let width = endX - startX
                                    
                                    Rectangle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: width, height: waveformHeight)
                                        .position(x: startX + width / 2, y: geometry.size.height / 2)
                                }
                                
                                // Current drag selection - show relative to screen coordinates
                                if let dragStart = dragStart, let dragEnd = dragEnd {
                                    let startX = min(dragStart.x, dragEnd.x)
                                    let endX = max(dragStart.x, dragEnd.x)
                                    let width = endX - startX
                                    
                                    Rectangle()
                                        .fill(.blue.opacity(0.3))
                                        .frame(width: width, height: waveformHeight)
                                        .position(x: startX + width / 2, y: geometry.size.height / 2)
                                }
                                
                                // Waveform bars
                                HStack(alignment: .center, spacing: 0) {
                                    ForEach(Array(getVisibleWaveformData(geometry: geometry).enumerated()), id: \.offset) { index, amplitude in
                                        Rectangle()
                                            .fill(getBarColor(for: index, geometry: geometry, isZoomed: true))
                                            .frame(width: zoomedWidth / CGFloat(waveformData.count))
                                            .frame(height: CGFloat(amplitude) * waveformHeight * 0.8)
                                    }
                                }
                                .frame(width: zoomedWidth, height: waveformHeight, alignment: .center)
                                .offset(x: clampedPanOffset)
                                
                                // Current playback position
                                if song.duration > 0 {
                                    let currentX = CGFloat(audioManager.currentTime / song.duration) * zoomedWidth + clampedPanOffset
                                    
                                    Rectangle()
                                        .fill(.red)
                                        .frame(width: 2, height: waveformHeight)
                                        .position(x: currentX, y: geometry.size.height / 2)
                                }
                            }
                            .clipped()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isPanning {
                                        handleDragChanged(value, in: geometry)
                                    }
                                }
                                .onEnded { value in
                                    if !isPanning {
                                        handleDragEnded(value, in: geometry)
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .modifiers(.option)
                                .onChanged { value in
                                    handlePan(value, in: geometry)
                                }
                                .onEnded { _ in
                                    isPanning = false
                                }
                        )
                        .onTapGesture { location in
                            handleTap(at: location, in: geometry)
                        }
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newZoom = max(minZoom, min(maxZoom, value))
                                    zoomLevel = newZoom
                                }
                        )
                    }
                    .frame(height: waveformHeight)
                }
            }
            
            // Time markers below waveform
            if !waveformData.isEmpty && song.duration > 0 {
                createTimeMarkers()
            }
        }
        .onAppear {
            loadWaveformData()
        }
        .onChange(of: song.id) { _, _ in
            // Clear loop when song changes
            clearLoop()
            loadWaveformData()
        }
    }
    
    private func getBarColor(for index: Int, geometry: GeometryProxy, isZoomed: Bool = false) -> Color {        
        // Check if bar is in loop range
        if let start = loopStart, let end = loopEnd, song.duration > 0 {
            let barTime = Double(index) / Double(waveformData.count) * song.duration
            
            if barTime >= start && barTime <= end {
                return .blue
            }
        }
        
        return .primary
    }
    
    private func getVisibleWaveformData(geometry: GeometryProxy) -> [Float] {
        // For now, return all data. Could optimize later to only return visible portion
        return waveformData
    }
    
    // MARK: - Zoom and Pan Functions
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomLevel = min(maxZoom, zoomLevel * 1.5)
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomLevel = max(minZoom, zoomLevel / 1.5)
            if zoomLevel <= minZoom {
                panOffset = 0
            }
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.3)) {
            zoomLevel = minZoom
            panOffset = 0
        }
    }
    
    
    private func handlePan(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        if !isPanning {
            // Clear any drag selection when starting to pan
            dragStart = nil
            dragEnd = nil
        }
        isPanning = true
        let maxPan = (geometry.size.width * zoomLevel - geometry.size.width) / 2
        panOffset = max(-maxPan, min(maxPan, value.translation.width * 0.5))
    }
    
    private func handleDragChanged(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        if dragStart == nil {
            dragStart = value.startLocation
        }
        dragEnd = value.location
    }
    
    private func handleDragEnded(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        guard let start = dragStart, song.duration > 0 else {
            dragStart = nil
            dragEnd = nil
            return
        }
        
        // Account for zoom and pan
        let zoomedWidth = geometry.size.width * zoomLevel
        let maxPan = max(0, zoomedWidth - geometry.size.width)
        let clampedPanOffset = max(-maxPan / 2, min(maxPan / 2, panOffset))
        
        // Convert screen coordinates to time coordinates  
        // The pan offset moves content left/right, so subtract it from screen coordinates
        let adjustedStartX = start.x - clampedPanOffset
        let adjustedEndX = value.location.x - clampedPanOffset
        
        let startTimeRatio = adjustedStartX / zoomedWidth
        let endTimeRatio = adjustedEndX / zoomedWidth
        
        // Clamp ratios to valid range [0, 1]
        let clampedStartRatio = max(0, min(1, startTimeRatio))
        let clampedEndRatio = max(0, min(1, endTimeRatio))
        
        let startTime = Double(clampedStartRatio) * song.duration
        let endTime = Double(clampedEndRatio) * song.duration
        
        // Ensure minimum loop length of 0.1 seconds for precise looping
        let minLoopLength = 0.1
        if abs(endTime - startTime) >= minLoopLength {
            loopStart = min(startTime, endTime)
            loopEnd = max(startTime, endTime)
            
            // Set loop in audio manager
            audioManager.setLoop(start: loopStart!, end: loopEnd!)
            
            // Jump to loop start for immediate playback
            audioManager.seek(to: loopStart!)
        }
        
        dragStart = nil
        dragEnd = nil
    }
    
    private func handleTap(at location: CGPoint, in geometry: GeometryProxy) {
        guard song.duration > 0 else { return }
        
        // Account for zoom and pan
        let zoomedWidth = geometry.size.width * zoomLevel
        let maxPan = max(0, zoomedWidth - geometry.size.width)
        let clampedPanOffset = max(-maxPan / 2, min(maxPan / 2, panOffset))
        
        // Convert screen coordinates to time coordinates
        let adjustedX = location.x - clampedPanOffset
        let timeRatio = adjustedX / zoomedWidth
        let clampedTimeRatio = max(0, min(1, timeRatio))
        let seekTime = Double(clampedTimeRatio) * song.duration
        
        audioManager.seek(to: seekTime)
    }
    
    private func clearLoop() {
        loopStart = nil
        loopEnd = nil
        audioManager.clearLoop()
    }
    
    private func loadWaveformData() {
        guard !isLoading else { return }
        
        isLoading = true
        waveformData = []
        
        Task {
            let data = await generateWaveformData(for: song)
            
            await MainActor.run {
                self.waveformData = data
                self.isLoading = false
            }
        }
    }
    
    private func generateWaveformData(for song: Song) async -> [Float] {
        do {
            let audioFile = try AVAudioFile(forReading: song.url)
            let format = audioFile.processingFormat
            let frameCount = AVAudioFrameCount(audioFile.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return []
            }
            
            try audioFile.read(into: buffer)
            
            guard let channelData = buffer.floatChannelData else {
                return []
            }
            
            let samples = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
            
            // Downsample for visualization
            let samplesPerPixel = max(1, samples.count / maxSamples)
            var waveform: [Float] = []
            
            for i in stride(from: 0, to: samples.count, by: samplesPerPixel) {
                let endIndex = min(i + samplesPerPixel, samples.count)
                let chunk = samples[i..<endIndex]
                
                // Calculate RMS (Root Mean Square) for better visualization
                let rms = sqrt(chunk.map { $0 * $0 }.reduce(0, +) / Float(chunk.count))
                waveform.append(min(1.0, rms * 3)) // Scale for visibility
            }
            
            return waveform
            
        } catch {
            print("Error loading waveform data: \(error)")
            return []
        }
    }
    
    private func createTimeMarkers() -> some View {
        GeometryReader { geometry in
            let duration = song.duration
            let markerInterval = calculateMarkerInterval(duration: duration)
            
            let totalMarkers = Int(duration / markerInterval) + 1
            
            // Account for zoom and pan
            let zoomedWidth = geometry.size.width * zoomLevel
            let maxPan = max(0, zoomedWidth - geometry.size.width)
            let clampedPanOffset = max(-maxPan / 2, min(maxPan / 2, panOffset))
            
            ZStack(alignment: .topLeading) {
                ForEach(0..<totalMarkers, id: \.self) { index in
                    let time = Double(index) * markerInterval
                    let timeRatio = time / duration
                    let position = timeRatio * zoomedWidth + clampedPanOffset
                    
                    // Only show if visible on screen
                    if position >= -20 && position <= geometry.size.width + 20 {
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(.secondary)
                                .frame(width: 1, height: 6)
                            
                            Text(formatTimeShort(time))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .position(x: position, y: 15)
                    }
                }
            }
            .clipped()
        }
        .frame(height: 30)
    }
    
    private func calculateMarkerInterval(duration: TimeInterval) -> TimeInterval {
        // Choose appropriate interval based on duration and zoom - made more dense
        let visibleDuration = duration / Double(zoomLevel)
        
        if visibleDuration <= 5 {
            return 0.5 // Every 0.5 seconds
        } else if visibleDuration <= 15 {
            return 1.0 // Every 1 second
        } else if visibleDuration <= 45 {
            return 2.0 // Every 2 seconds
        } else if visibleDuration <= 120 {
            return 5.0 // Every 5 seconds
        } else if visibleDuration <= 300 {
            return 10.0 // Every 10 seconds  
        } else if visibleDuration <= 600 {
            return 30.0 // Every 30 seconds
        } else {
            return 60.0 // Every minute
        }
    }
    
    private func formatTimeShort(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let totalSeconds = time.truncatingRemainder(dividingBy: 60)
        
        if minutes > 0 {
            let seconds = Int(totalSeconds)
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else if totalSeconds >= 1 {
            let seconds = Int(totalSeconds)
            return "\(seconds)s"
        } else {
            // Show decimal for sub-second intervals
            return String(format: "%.1fs", totalSeconds)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}