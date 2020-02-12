//
//  ContentView.swift
//  Gauge
//
//  Created by Arturo Rivas on 11/02/2020.
//  Copyright © 2020 Arturo Rivas. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var thickness: CGFloat = 40
    @State private var dashGap: CGFloat = 5
    
    let radius: CGFloat = 200
    
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            
            ZStack {
                GaugeView(thickness: thickness, dashGap: dashGap)
                    .frame(width: radius * 2, height: radius * 2)
                    .padding(24)
                
                ForEach(0...11, id: \.self) { i in
                    Text("\(i != 0 ? i : 12)")
                        .font(.headline)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                
                Circle()
                    .frame(width: 16, height: 16)
                
                Rectangle()
                    .frame(width: 10, height: radius / 2)
                    .offset(x: 0, y: -radius / 4)
                    .rotationEffect(.degrees(Double(hours) * 30))
                
                Rectangle()
                    .frame(width: 5, height: radius)
                    .offset(x: 0, y: -radius / 2)
                    .rotationEffect(.degrees(Double(minutes) * 6))
                
                Rectangle()
                    .frame(width: 2, height: radius)
                    .offset(x: 0, y: -radius / 2)
                    .rotationEffect(.degrees(Double(seconds) * 6))
            }
            .animation(.linear)
            
            Spacer(minLength: 50)
            
            Slider(value: $thickness, in: 0...radius) {
                Text("Thickness")
            }
            .padding(.horizontal)
            
            Slider(value: $dashGap, in: 1...25) {
                Text("Dash gap")
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onReceive(timer.currentTimePublisher) { date in
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            self.hours = components.hour ?? 0
            self.minutes = components.minute ?? 0
            self.seconds = components.second ?? 0
        }
    }
}

class MyTimer {
    let currentTimePublisher = Timer.TimerPublisher(interval: 0.5, runLoop: .main, mode: .default)
    let cancellable: Cancellable?

    init() {
        self.cancellable = currentTimePublisher.connect()
    }

    deinit {
        self.cancellable?.cancel()
    }
}

let timer = MyTimer()

struct GaugeView: View {
    let thickness: CGFloat
    let dashGap: CGFloat

    var body: some View {
        AngularGradient(
            gradient: Gradient(colors: [.blue, .green, .yellow, .red]),
            center: .center
        )
            .rotationEffect(Angle(degrees: -100))
            .mask(
                GeometryReader { geo in
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: self.thickness, dash: [self.dashGap, self.spacing(for: geo.size.width, with: self.dashGap)], dashPhase: self.dashGap / 2))
                        .rotationEffect(Angle(degrees: -90))
                        .padding(self.thickness/2)
                }
                
        )
    }
    
    private func spacing(for diameter: CGFloat, with tickWitdh: CGFloat) -> CGFloat {
        return ((diameter - thickness) * CGFloat(Double.pi) - tickWitdh * 12) / 12
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
