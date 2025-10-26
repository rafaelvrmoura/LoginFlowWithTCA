//
//  PhotoPickerFeature.swift
//  LoginFlowWithTCA
//
//  Created by Rafael Vieira Moura on 22/10/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct PhotosPickerItemLoader {
    
    enum Error: Swift.Error, Equatable {
        
        case couldntLoadImage
        case couldntTransferData
    }
    
    var loadImage: (PhotosPickerItem) async throws -> UIImage
    
    static var live = PhotosPickerItemLoader { item in
        
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw Error.couldntTransferData
        }
        
        guard let image = UIImage(data: data) else {
            throw Error.couldntLoadImage
        }
        
        return image
    }
}

extension PhotosPickerItemLoader: DependencyKey {
    
    static var liveValue: PhotosPickerItemLoader = .live
}

extension DependencyValues {
    
    var photosLoader: PhotosPickerItemLoader {
        get { self[PhotosPickerItemLoader.self] }
        set { self[PhotosPickerItemLoader.self] = newValue }
    }
}

@Reducer
struct PhotoPickerReducer {
    
    @Dependency(\.photosLoader) var photosLoader
    
    enum SelectionState: Equatable {
        
        case empty
        case loading
        case loaded(UIImage)
        case error(PhotosPickerItemLoader.Error)
    }
    
    @ObservableState
    struct State: Equatable {
        
        var selection: PhotosPickerItem? = nil
        var selectionState: SelectionState = .empty
    }
    
    enum Action: Equatable {
        
        case itemSelected(PhotosPickerItem?)
        case imageLoaded(Result<UIImage, PhotosPickerItemLoader.Error>)
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action{
                
            case .itemSelected(let item):
                
                guard let item else { return .none }
                state.selectionState = .loading
                return .run { send in
                    do {
                        
                        let image = try await photosLoader.loadImage(item)
                        return await send(.imageLoaded(.success(image)))
                        
                    } catch PhotosPickerItemLoader.Error.couldntLoadImage {
                        
                        return await send(.imageLoaded(.failure(.couldntLoadImage)))
                        
                    } catch {
                        
                        return await send(.imageLoaded(.failure(.couldntTransferData)))
                    }
                }
                
            case .imageLoaded(let result):
                switch result {
                case .success(let image):
                    state.selectionState = .loaded(image)
                case .failure(let error):
                    state.selectionState = .error(error)
                }
                return .none
            }
        }
    }
}
