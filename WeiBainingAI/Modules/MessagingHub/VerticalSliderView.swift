//
//  VerticalSliderView.swift
//  WeiBainingAI
//
//  Created by Daniel ° on 2023/12/7.
//

import SwiftUI

struct VerticalSliderView<T: BinaryFloatingPoint>: View {
    @Binding var value: T
    let inRange: ClosedRange<T>
    let fillColor: Color
    let emptyColor: Color
    let width: CGFloat
    let onEditingChanged: (Double) -> Void

    // private variables
    @State private var localRealProgress: T = 0
    @State private var localTempProgress: T = 0
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(emptyColor)
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(fillColor)
                            .mask {
                                VStack {
                                    Spacer(minLength: 0)
                                    Rectangle()
                                        .frame(height: max(geo.size.height * CGFloat(localRealProgress + localTempProgress), 0),
                                               alignment: .leading)
                                }
                            }
                    }
                    .clipped()
                }
                .frame(height: bounds.size.height, alignment: .center)
            }
            .frame(width: bounds.size.width, height: bounds.size.height, alignment: .center)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { gesture in
                    localTempProgress = T(-gesture.translation.height / bounds.size.height)
                    value = max(min(getPrgValue(), inRange.upperBound), inRange.lowerBound)
                }.onEnded { _ in
                    localRealProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    localTempProgress = 0
                    onEditingChanged(Double(localRealProgress))
                })
            .onAppear {
                localRealProgress = getPrgPercentage(value)
            }
            .onChange(of: value) { newValue in
                localRealProgress = getPrgPercentage(newValue)
            }
        }
        .frame(width: width, alignment: .center)
        .offset(x: 0)
    }

    private var animation: Animation {
        return .spring()
    }

    private func getPrgPercentage(_ value: T) -> T {
        let range = inRange.upperBound - inRange.lowerBound
        let correctedStartValue = value - inRange.lowerBound
        let percentage = correctedStartValue / range
        return percentage
    }

    private func getPrgValue() -> T {
        return ((localRealProgress + localTempProgress) * (inRange.upperBound - inRange.lowerBound)) + inRange.lowerBound
    }
}

#Preview {
    VerticalSliderView(
        value: .constant(0.5),
        inRange: 0 ... 1,
        fillColor: Color.blue,
        emptyColor: Color.white,
        width: 64,
        onEditingChanged: {
            print($0)
        }
    )
}
