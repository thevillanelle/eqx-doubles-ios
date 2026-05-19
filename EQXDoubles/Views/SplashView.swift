import SwiftUI

struct SplashView: View {
    @State private var opacity = 0.0
    @State private var offset  = 12.0
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 6) {
                Text("EQUINOX NYC")
                    .font(.system(size: 11, weight: .bold))
                    .kerning(6)
                    .foregroundColor(.gray)
                Text("DOUBLES")
                    .font(.system(size: 58, weight: .black))
                    .kerning(10)
                    .foregroundColor(Color(red: 0.78, green: 0.95, blue: 0.23))
                Text("finding the best pairs...")
                    .font(.system(size: 11))
                    .kerning(2)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.top, 6)
            }
            .opacity(opacity)
            .offset(y: offset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.65)) { opacity = 1; offset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation(.easeIn(duration: 0.45)) { opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
            }
        }
    }
}
