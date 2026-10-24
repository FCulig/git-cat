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
    case currentBranch = "git rev-parse --abbrev-ref HEAD"
    case diff = "git diff" // TODO: Replace this with git add -p, https://stackoverflow.com/questions/1085162/commit-only-part-of-a-files-changes-in-git
    /// Local and remote branch names, one per line. Symbolic refs such as `origin/HEAD` end with a tab and their target.
    case listOfBranches = "git for-each-ref --format='%(refname:short)%09%(symref)' refs/heads refs/remotes"
    case push = "git push origin main" // TODO: Ability to chose origin and branch to which to push
    /// Prints "<commits ahead>\t<commits behind>" compared to the current branch's upstream. Fails without an upstream.
    case upstreamComparison = "git rev-list --left-right --count 'HEAD...@{upstream}'"
    case restore = "git restore --staged"
    case status = "git status"
}
