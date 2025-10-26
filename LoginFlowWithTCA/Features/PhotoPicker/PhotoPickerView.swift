//
//  PhotoPickerView.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 22/10/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct PhotoPickerView<Content: View>: View {
    
    @Bindable var store: StoreOf<PhotoPickerReducer>
    
    @ViewBuilder
    var content: Content
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            PhotosPicker(
                selection: viewStore.binding(
                    get: \.selection,
                    send: { .itemSelected($0) }
                )
            ) {
                content
            }
        }
    }
}

#Preview {
    PhotoPickerView(
        store: Store(
            initialState: .init(),
            reducer: {
                PhotoPickerReducer()
            }
        )
    ) {
        
        Image(systemName: "person.crop.circle")
            .resizable()
    }
    .frame(width: 100, height: 100)
    .cornerRadius(50)
}
