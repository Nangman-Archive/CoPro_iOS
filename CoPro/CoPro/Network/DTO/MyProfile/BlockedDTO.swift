//
//  BlockedDTO.swift
//  CoPro
//
//  Created by 박신영 on 5/13/24.
//

import Foundation

// MARK: - BlockedDTO
struct BlockedDTO: Codable {
   let statusCode: Int
   let message: String
   let data: BlockedDataClass
}

// MARK: - DataClass
struct BlockedDataClass: Codable {
   let totalPages, totalElements, size: Int
   let content: [BlockedContent]
   let number: Int
   let sort: BlockedSort
   let numberOfElements: Int
   let pageable: BlockedPageable
   let first, last, empty: Bool
}

// MARK: - Content
struct BlockedContent: Codable {
   let blockedMemberID: Int
   let name, email, picture, occupation: String
   let language: String
   let career: Int
   let gitHubURL: String
   let isBlocked: Bool
   
   enum CodingKeys: String, CodingKey {
      case blockedMemberID = "blockedMemberId"
      case name, email, picture, occupation, language, career
      case gitHubURL = "gitHubUrl"
      case isBlocked
   }
}

// MARK: - Pageable
struct BlockedPageable: Codable {
   let pageNumber, offset: Int
   let sort: Sort
   let unpaged, paged: Bool
   let pageSize: Int
}

// MARK: - Sort
struct BlockedSort: Codable {
   let empty, unsorted, sorted: Bool
}

