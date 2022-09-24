//
//  PostStruct.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/23/22.
//

import Foundation


// Post data.
struct Post: Codable {
    let created_time: String
    let creator_user: String
    let id: String
    let title: String
    let description: String
    let username: String
}
