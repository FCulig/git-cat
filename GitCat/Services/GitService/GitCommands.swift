//
//  GitCommands.swift
//  GitCat
//
//  Created by Filip Čulig on 30.09.2023..
//

// MARK: - GitCommands-
enum GitCommands: String {
    case add = "git add"
    case commit = "git commit -m"
    case diff = "git diff" // TODO: Replace this with git add -p, https://stackoverflow.com/questions/1085162/commit-only-part-of-a-files-changes-in-git
    case push = "git push origin main" // TODO: Ability to chose origin and branch to which to push
    case restore = "git restore --staged"
    case status = "git status --short"
}
