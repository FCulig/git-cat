//
//  AppIcons.swift
//  GitCat
//
//  Created by Filip Čulig on 23.05.2024..
//

import SwiftUI

enum AppIcon {
    case branch
    
    var image: Image {
        switch self {
        case .branch:
            Image("git-branch")
        }
    }
}
