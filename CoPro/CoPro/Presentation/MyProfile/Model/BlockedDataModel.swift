//
//  BlockedDataModel.swift
//  CoPro
//
//  Created by 박신영 on 5/13/24.
//

import Foundation

struct BlockedDataModel: Codable {
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
