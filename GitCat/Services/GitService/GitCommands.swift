//
//  GitCommands.swift
//  GitCat
//
//  Created by Filip Čulig on 30.09.2023..
//

// MARK: - GitCommands-

/// Commands that take paths end with `--`, so the quoted paths can be appended directly.
enum GitCommands: String {
    case add = "git add --"
    /// Name of the current branch, also before the first commit. Prints nothing on a detached HEAD.
    case branchName = "git symbolic-ref --short -q HEAD"
    case cleanUntracked = "git clean -f --"
    case commit = "git commit"
    case commitCount = "git rev-list --count HEAD"
    case currentBranch = "git rev-parse --abbrev-ref HEAD"
    case diff = "git diff" // TODO: Replace this with git add -p, https://stackoverflow.com/questions/1085162/commit-only-part-of-a-files-changes-in-git
    /// Followed by `-- /dev/null <path>`, shows a whole untracked file as added. Exits with 1 whenever there is a
    /// difference.
    case diffUntracked = "git diff --no-index"
    /// Restores the index and the working tree to HEAD.
    case discardStaged = "git restore --staged --worktree --source=HEAD --"
    /// Restores the working tree to the index.
    case discardUnstaged = "git restore --"
    // Credentials can't be typed in anywhere, so git fails instead of waiting for them forever.
    case fetch = "GIT_TERMINAL_PROMPT=0 git fetch --prune"
    /// "<hash>\t<subject>" of the last commit.
    case lastCommit = "git log -1 --format=%h%x09%s"
    case localBranches = "git for-each-ref --format='%(refname:short)' refs/heads"
    /// "<added>\t<deleted>\t<path>" per file, NUL separated. Binary files have "-" instead of counts.
    case numstat = "git diff --numstat --no-renames -z"
    case pull = "GIT_TERMINAL_PROMPT=0 git pull --ff-only"
    case push = "GIT_TERMINAL_PROMPT=0 git push"
    case remotes = "git remote"
    /// Unstages files before the first commit, when there is no HEAD to restore them from.
    case removeFromIndex = "git rm --cached -q --"
    /// Removes a newly added file from both the index and the working tree.
    case removeAdded = "git rm -f --"
    /// Prints "<commits ahead>\t<commits behind>" compared to the current branch's upstream. Fails without an upstream.
    case upstreamComparison = "git rev-list --left-right --count 'HEAD...@{upstream}'"
    /// E.g. "origin/main". Fails without an upstream.
    case upstreamName = "git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'"
    case unstage = "git restore --staged --"
    /// NUL separated, so paths are never quoted. Lists files in untracked folders one by one.
    case status = "git status --porcelain=v1 -z --untracked-files=all"
}
