//
//  PhotoPickerFeatureTests.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 23/10/25.
//

import Testing
import UIKit
import PhotosUI
import SwiftUI
import ComposableArchitecture

@testable import LoginFlowWithTCA

@MainActor
struct PhotoPickerFeatureTests {
    
    @Test
    func itemSelectionSuccess() async {
        
        let expectedImage = UIImage()
        let store = TestStore(
            initialState: PhotoPickerReducer.State(),
            reducer: {
                PhotoPickerReducer()
            },
            withDependencies: {
                $0.photosLoader = PhotosPickerItemLoader { _ in
                    return expectedImage
                }
            }
        )
        
        await store.send(.itemSelected(PhotosPickerItem(itemIdentifier: "foo"))) {
            $0.selectionState = .loading
        }
        await store.receive(.imageLoaded(.success(expectedImage))) {
            $0.selectionState = .loaded(expectedImage)
        }
    }
    
    @Test(arguments: [PhotosPickerItemLoader.Error.couldntLoadImage,
                      PhotosPickerItemLoader.Error.couldntTransferData])
    func itemSelectionFailure(error: PhotosPickerItemLoader.Error) async {
        
        let store = TestStore(
            initialState: PhotoPickerReducer.State(),
            reducer: {
                PhotoPickerReducer()
            },
            withDependencies: {
                $0.photosLoader = PhotosPickerItemLoader { _ in
                    throw error
                }
            }
        )
        
        await store.send(.itemSelected(PhotosPickerItem(itemIdentifier: "foo"))) {
            $0.selectionState = .loading
        }
        await store.receive(.imageLoaded(.failure(error))) {
            $0.selectionState = .error(error)
        }
    }
    
    @Test
    func selectingNilItem() async {
        
        let store = TestStore(
            initialState: PhotoPickerReducer.State(),
            reducer: {
                PhotoPickerReducer()
            }
        )
        
        await store.send(.itemSelected(nil))
    }
}

