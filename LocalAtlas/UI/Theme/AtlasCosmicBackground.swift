import SwiftUI

struct AtlasCosmicBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AtlasTheme.bgGradient
                    .ignoresSafeArea()

                Canvas { context, size in
                    for star in stars(in: size) {
                        let rect = CGRect(x: star.x * size.width,
                                          y: star.y * size.height,
                                          width: star.size,
                                          height: star.size)
                        context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(star.opacity)))
                    }
                }
                .blendMode(.screen)

                RadialGradient(colors: [Color.black.opacity(0), Color.black.opacity(0.65)],
                               center: .center,
                               startRadius: 0,
                               endRadius: min(proxy.size.width, proxy.size.height) * 0.8)
                    .ignoresSafeArea()
            }
        }
    }

    private func stars(in size: CGSize) -> [Star] {
        let seedList: [UInt64] = [12, 73, 114, 23, 91, 64, 55, 27, 48, 104, 210, 186, 137, 190, 210, 12, 88, 142, 171, 203, 234, 245, 5, 9, 18, 36, 72, 87, 121, 133]
        return seedList.enumerated().map { index, seed in
            var rng = SeededRandom(seed: UInt64(seed + UInt64(index) * 17))
            return Star(x: rng.next(),
                        y: rng.next(),
                        size: CGFloat(0.6 + rng.next() * 1.4),
                        opacity: 0.2 + rng.next() * 0.7)
        }
    }

    struct Star {
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }

    struct SeededRandom {
        private var state: UInt64

        init(seed: UInt64) {
            self.state = seed | 1
        }

        mutating func next() -> CGFloat {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let value = Double(state & 0xFFFFFFFF) / Double(UInt32.max)
            return CGFloat(value)
        }
    }
}
