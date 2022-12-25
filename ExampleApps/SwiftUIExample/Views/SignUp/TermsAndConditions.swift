//
//  TermsAndConditions.swift
//  TermsAndConditions
//
//  Created by Richard Gist on 8/25/21.
//  Copyright © 2021 WWT and Tyler Thompson. All rights reserved.
//  swiftlint:disable line_length closure_body_length

import SwiftUI
import SwiftCurrent_SwiftUI

struct TermsAndConditions: View {
    @State private var shouldProceed = false

    let inspection = Inspection<Self>() // ViewInspector
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.icon)
                Text("Last Update 08/25/2021")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.8))
                Spacer()
            }
            .padding(.horizontal)

            ScrollView {
                Text(verbatim: .loremIpsum)
            }
            .padding(.leading)
            .background(Color.card.opacity(0.3))
            .cornerRadius(5)
            .padding()

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.icon)
                    Text("I agree with the Terms of Service")
                }
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.icon)
                    Text("I agree with the Privacy Policy")
                }
            }
            .padding(.bottom)

            HStack {
                SecondaryButton(title: "Decline") {
                    #warning("Abandon not a thing")
                }

                PrimaryButton(title: "Accept") {
                    shouldProceed = true
                }
            }
        }
        .navigationTitle("Terms of Service")
        .workflowLink(isPresented: $shouldProceed)
        .onReceive(inspection.notice) { inspection.visit(self, $0) } // ViewInspector
    }
}

extension String {
    fileprivate static var loremIpsum: String {
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dignissim convallis aenean et tortor at risus viverra adipiscing. Velit euismod in pellentesque massa placerat. Erat imperdiet sed euismod nisi porta lorem. Quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis. Commodo quis imperdiet massa tincidunt nunc. Aliquam vestibulum morbi blandit cursus. Tempor id eu nisl nunc mi. Justo donec enim diam vulputate ut pharetra sit. Urna nunc id cursus metus. Blandit libero volutpat sed cras ornare. Faucibus turpis in eu mi bibendum neque egestas congue. Morbi tristique senectus et netus et. Odio euismod lacinia at quis. Risus feugiat in ante metus dictum at tempor commodo. Nam libero justo laoreet sit amet cursus sit amet.

            Convallis posuere morbi leo urna molestie at elementum eu. Egestas fringilla phasellus faucibus scelerisque eleifend donec pretium vulputate. Et magnis dis parturient montes nascetur ridiculus. Sed felis eget velit aliquet sagittis id consectetur purus. Tristique senectus et netus et malesuada. Nisi vitae suscipit tellus mauris a. Tempor id eu nisl nunc mi ipsum faucibus. Mi eget mauris pharetra et ultrices neque ornare. Tempor orci eu lobortis elementum nibh tellus molestie nunc. Morbi tincidunt ornare massa eget egestas purus viverra. Arcu vitae elementum curabitur vitae nunc sed velit dignissim sodales. Sed nisi lacus sed viverra tellus in. Pretium viverra suspendisse potenti nullam ac tortor vitae purus. Magna sit amet purus gravida quis blandit turpis cursus. Gravida in fermentum et sollicitudin ac orci phasellus. Neque laoreet suspendisse interdum consectetur libero. Pharetra massa massa ultricies mi quis hendrerit dolor. Quis viverra nibh cras pulvinar mattis. Nunc mi ipsum faucibus vitae. Quam id leo in vitae turpis massa sed elementum tempus.

            Consectetur adipiscing elit duis tristique sollicitudin nibh. Sed blandit libero volutpat sed cras ornare arcu dui vivamus. Scelerisque in dictum non consectetur a erat nam. Non curabitur gravida arcu ac tortor dignissim convallis. Risus in hendrerit gravida rutrum quisque non tellus orci ac. At risus viverra adipiscing at in tellus integer feugiat. Eget aliquet nibh praesent tristique magna sit amet purus. Volutpat lacus laoreet non curabitur gravida arcu ac tortor dignissim. Morbi enim nunc faucibus a pellentesque sit amet porttitor eget. Tristique senectus et netus et malesuada fames ac. Sit amet commodo nulla facilisi nullam vehicula ipsum a.

            Fringilla est ullamcorper eget nulla facilisi etiam dignissim diam. Purus ut faucibus pulvinar elementum integer. Leo urna molestie at elementum eu facilisis sed odio morbi. Quis varius quam quisque id diam vel quam. Blandit libero volutpat sed cras ornare arcu dui vivamus arcu. Curabitur vitae nunc sed velit dignissim sodales ut eu sem. Nec dui nunc mattis enim ut. Velit laoreet id donec ultrices. Lacus sed turpis tincidunt id. Fermentum odio eu feugiat pretium nibh ipsum consequat. Purus sit amet luctus venenatis lectus magna fringilla. Lectus mauris ultrices eros in cursus turpis massa tincidunt dui. Aliquet nibh praesent tristique magna sit amet. Porta lorem mollis aliquam ut. Quis lectus nulla at volutpat diam ut venenatis tellus in. At varius vel pharetra vel turpis nunc. Erat nam at lectus urna duis convallis.

            Arcu cursus vitae congue mauris rhoncus aenean. Quam lacus suspendisse faucibus interdum. Amet nisl suscipit adipiscing bibendum est ultricies. Adipiscing diam donec adipiscing tristique risus. Varius quam quisque id diam. Dictum varius duis at consectetur lorem. Mollis nunc sed id semper risus in hendrerit gravida rutrum. Vitae proin sagittis nisl rhoncus mattis rhoncus. Donec ac odio tempor orci dapibus. In fermentum et sollicitudin ac orci. Turpis egestas integer eget aliquet nibh praesent tristique. Nunc scelerisque viverra mauris in aliquam sem fringilla ut. Montes nascetur ridiculus mus mauris vitae. Tincidunt tortor aliquam nulla facilisi cras fermentum odio eu feugiat.

            """
    }
}

struct TermsAndConditions_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsAndConditions()
                .preferredColorScheme(.dark)
                .background(Color.primaryBackground)
        }
    }
}
