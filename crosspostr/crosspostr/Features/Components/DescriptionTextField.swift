import SwiftUI

struct DescriptionTextField: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .frame(height: 150)
            .textEditorStyle(.plain)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.cardGradient, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") {
                        Utils.shared.hideKeyboard()
                    }
                }
            }
    }
}
