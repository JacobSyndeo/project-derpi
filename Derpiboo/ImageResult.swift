//
//  ImageResult.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/30/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

struct ImageResult: ResultItem {
    var id: String { return metadata.id }
    
    private(set) var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: String
        
        let created_at: String
        let updated_at: String
        
        let duplicate_reports: [AnyObject]
        
        let first_seen_at: String
        
        let file_name: String
        let description: String
        
        let uploader_id: String?
        let uploader: String
        
        let image: String
        
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let faves: Int
        
        let comment_count: Int
        
        let tags: String
        let tag_ids: [String]
        
        //let rating: Ratings
        
        let width: Int
        let height: Int
        let aspect_ratio: Double
        
        let original_format: String
        let mime_type: String
        var original_format_enum: File_Ext? {
            return File_Ext(rawValue: original_format) ?? nil
        }
        
        let sha512_hash: String
        let orig_sha512_hash: String?
        let source_url: String
        
        let representations: Representations
        
        struct Representations {
            let thumb_tiny: String
            let thumb_small: String
            let thumb: String
            let small: String
            let medium: String
            let large: String
            let tall: String
            let full: String
        }
        
        let is_rendered: Bool
        let is_optimized: Bool
        
        enum ImageSize: String {
            case thumb, large, full
        }
        enum File_Ext: String {
            case jpg = "jpg", png = "png", gif = "gif", swf = "swf", webm = "webm"
        }
        enum Ratings: String {
            case safe, suggestive, explicit = "26707"
        }
    }
    
    private func url(forSize size: Metadata.ImageSize) -> String {
        switch size {
        case .thumb: return "https:" + metadata.representations.thumb
        case .large: return "https:" + metadata.representations.large
        case .full: return "https:" + metadata.representations.full
        }
    }
    
    func imageData(forSize size: Metadata.ImageSize) -> Promise<Data> {
        if metadata.original_format_enum == .webm || metadata.original_format_enum == .webm {
            #if DEBUG
                print("[Verbose] imageResult(\(id)) is trying to get imageData for size (\(size)), BUT image is of type \(String(describing: metadata.original_format_enum)).")
            #endif
            return Promise<Data>(error: ImageResultError.imageTypeNotSupported(id: id, type: metadata.original_format_enum))
        }
        
        #if DEBUG
            print("[Verbose] imageResult(\(id)) is trying to get imageData for size (\(size)).")
        #endif
        return imageDataFromCache(size: size)
            .recover { error -> Promise<Data> in
                if case ImageCache.CacheError.noImageInStore(_) = error {
                    #if DEBUG
                        print("[Verbose] imageResult(\(self.id)) can't find cached data for size (\(size)), will attempt download.")
                    #endif
                    return self.downloadImageData(forSize: size)
                } else {
                    #if DEBUG
                        print("[Verbose] imageResult(\(self.id)) got into error for size (\(size)): \(error)")
                    #endif
                    throw error
                }
        }
    }
    
    func imageDataFromCache(size: Metadata.ImageSize) -> Promise<Data> {
        #if DEBUG
            print("[Verbose] imageResult(\(id)) is trying to get imageData FROM CACHE for size (\(size)).")
        #endif
        return Cache.image.getImageData(for: self.id, size: size)
    }
    
    func downloadImageData(forSize size: Metadata.ImageSize) -> Promise<Data> {
        #if DEBUG
            print("[Verbose] imageResult(\(id)) is trying to get imageData FROM DOWNLOAD for size (\(size)). URL: \(url(forSize: size))")
        #endif
        
        return Network.get(url: url(forSize: size))
            .then { data -> Promise<Data> in
                _ = Cache.image.setImageData(data, id: self.id, size: size)
                return Promise(value: data)
        }
    }
    
    enum ImageResultError: Error {
        case downloadFailed(id: String, url: String)
        case imageTypeNotSupported(id: String, type: Metadata.File_Ext?)
    }
}
