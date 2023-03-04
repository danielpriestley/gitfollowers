//
//  ErrorMessage.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 04/03/2023.
//

import Foundation

enum ErrorMessage: String {
    // these are RAW Values, they all conform to one type, an associated value would have the type declared on the respective lines
    case invalidUsername = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection"
    case invalidResponse = "Invalid response from the server, please try again"
    case invalidData = "The data received from the server was invalid. Please try again"
}
