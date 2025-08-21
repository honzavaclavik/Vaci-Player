import SwiftUI

struct FavoriteFolderRowView: View {
    let folder: FavoriteFolder
    let isSelected: Bool
    let onSelect: () -> Void
    let onRemove: () -> Void
    let onRename: (String) -> Void
    
    @State private var isHovered = false
    @State private var showingRenameAlert = false
    @State private var newName = ""
    
    var body: some View {
        HStack(spacing: 8) {
            // Folder icon
            Image(systemName: isSelected ? "folder.fill" : "folder")
                .foregroundStyle(isSelected ? .blue : .secondary)
                .font(.caption)
                .frame(width: 16)
            
            // Folder name
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .blue : .primary)
                    .lineLimit(1)
                
                // Show path if name is custom
                if folder.name != folder.url.lastPathComponent {
                    Text(folder.url.path)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Action buttons (shown on hover)
            if isHovered {
                HStack(spacing: 4) {
                    // Rename button
                    Button(action: {
                        newName = folder.name
                        showingRenameAlert = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    // Remove button
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.blue.opacity(0.1) : (isHovered ? Color.secondary.opacity(0.1) : Color.clear))
        )
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering && !isSelected
            }
        }
        .alert("Rename Folder", isPresented: $showingRenameAlert) {
            TextField("Folder name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onRename(newName.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } message: {
            Text("Enter a new name for this folder")
        }
    }
}