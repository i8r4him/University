import SwiftUI

struct WhatsNewView: View {
    @StateObject private var viewModel = WhatsNewViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header section
                VStack(spacing: 16) {
                    Image(systemName: "star.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                    
                    Text("Latest Updates")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Stay up to date with all the new features and improvements")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Updates Timeline
                VStack(spacing: 24) {
                    ForEach(Array(viewModel.updates.enumerated()), id: \.element.id) { index, update in
                        VStack(alignment: .leading, spacing: 16) {
                            // Version Header with Arrow Button
                            HStack {
                                Text("Version \(update.version)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(update.date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.toggleExpansion(for: index)
                                    }
                                }) {
                                    Image(systemName: update.isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .imageScale(.large)
                                }
                            }
                            
                            // Features List
                            if update.isExpanded {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(update.features.indices, id: \.self) { featureIndex in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(.accentColor)
                                                .padding(.top, 6)
                                            
                                            Text(update.features[featureIndex])
                                                .font(.subheadline)
                                        }
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .opacity)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.2), value: update.isExpanded)
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("What's New")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WhatsNewView()
    }
}
