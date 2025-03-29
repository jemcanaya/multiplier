import SwiftUI

struct HideModifier: ViewModifier {
    var isHidden: Bool
    
    func body(content: Content) -> some View {
        Group {
            if isHidden {
                content.hidden()
            } else {
                content
            }
        }
    }
}

extension View {
    func hidden(_ isHidden: Bool) -> some View {
        self.modifier(HideModifier(isHidden: isHidden))
    }
}
