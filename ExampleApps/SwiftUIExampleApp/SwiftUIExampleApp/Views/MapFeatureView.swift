//
//  MapFeatureView.swift
//  SwiftUIExampleApp
//
//  Created by Tyler Thompson on 7/14/21.
//

import SwiftUI
import MapKit
import SwiftCurrent

struct MapFeatureView: View, FlowRepresentable {
    @State private var region = MKCoordinateRegion()

    // WWT Global Headquarters
    var coordinate = CLLocationCoordinate2D(latitude: 38.70196, // swiftlint:disable:this number_separator
                                            longitude: -90.44906) // swiftlint:disable:this number_separator

    weak var _workflowPointer: AnyFlowRepresentable?

    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
            }
    }
}
