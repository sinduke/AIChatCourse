//
//  FirebaseImageUploadService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftUI
import FirebaseStorage

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}

struct FirebaseImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.dataNotAllowed)
        }
        // upload Image
        try await saveImage(data: data, path: path)
        // get image path
        return try await imageReference(path: path).downloadURL()
        
    }
    
    private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    @discardableResult
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let returnMetadata = try await imageReference(path: path).putDataAsync(data, metadata: meta)
        
        guard let returnPath = returnMetadata.path, let url = URL(string: returnPath) else {
            throw URLError(.badServerResponse)
        }
        
        return url
    }
    
}
