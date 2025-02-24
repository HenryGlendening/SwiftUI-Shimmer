//
//  Shimmer.swift
//
//  Created by Vikram Kriplaney on 23.03.21.
//

import SwiftUI

/// A view modifier that applies an animated "shimmer" to any view, typically to show that
/// an operation is in progress.
public struct Shimmer: ViewModifier {
	@State private var phase: CGFloat = 0
	var duration = 1.5
	var bounce = false
	
	public func body(content: Content) -> some View {
		content
			.modifier(AnimatedMask(phase: phase).animation(
				Animation.linear(duration: duration)
					.repeatForever(autoreverses: bounce)
			))
			.onAppear { phase = 0.75 }
	}
	
	/// An animatable modifier to interpolate between `phase` values.
	struct AnimatedMask: AnimatableModifier {
		var phase: CGFloat = 0
		
		var animatableData: CGFloat {
			get { phase }
			set { phase = newValue }
		}
		
		func body(content: Content) -> some View {
			content
				.mask(GradientMask(phase: phase).scaleEffect(3))
		}
	}
	
	/// A slanted, animatable gradient between transparent and opaque to use as mask.
	/// The `phase` parameter shifts the gradient, moving the opaque band.
	struct GradientMask: View {
		let phase: CGFloat
		let baseColor: Color = Color.clear
		let shimmerColor: Color = Color.black
		
		var body: some View {
			LinearGradient(gradient:
											Gradient(stops: [
												.init(color: baseColor, location: phase),
												.init(color: shimmerColor, location: phase + 0.1),
												.init(color: baseColor, location: phase + 0.25)
											]), startPoint: .topLeading, endPoint: .bottomTrailing)
		}
	}
}

public extension View {
	/// Adds an animated shimmering effect to any view, typically to show that
	/// an operation is in progress.
	/// - Parameters:
	///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
	///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
	///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
	@ViewBuilder func shimmering(
		active: Bool = true, duration: Double = 1.5, bounce: Bool = false) -> some View {
		if active {
			modifier(Shimmer(duration: duration, bounce: bounce))
		} else {
			self
		}
	}
}

#if DEBUG
struct Shimmer_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			Text("SwiftUI Shimmer")
			if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
				Text("SwiftUI Shimmer").preferredColorScheme(.light)
				Text("SwiftUI Shimmer").preferredColorScheme(.dark)
				VStack(alignment: .leading) {
					Text("Loading...").font(.title)
					Text(String(repeating: "Shimmer", count: 12))
						.redacted(reason: .placeholder)
				}.frame(maxWidth: 200)
			}
		}
		.padding()
		.shimmering()
		.previewLayout(.sizeThatFits)
	}
}
#endif
