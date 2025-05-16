//
//  ContentView.swift
//  On-device ML
//
//  Created by Pratiksha on 15/05/25.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct ContentView: View {
    @State private var image: UIImage?
    @State private var prediction: String = "No image selected"
    @State private var showPicker = false

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            Text(prediction)
                .padding()

            Button("Select Image") {
                showPicker = true
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $image, onImagePicked: classifyImage)
        }
    }

    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            prediction = "Failed to load model"
            return
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            if let result = request.results?.first as? VNClassificationObservation {
                prediction = "Prediction: \(result.identifier) (\(String(format: "%.2f", result.confidence * 100))%)"
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
#Preview {
    ContentView()
}
