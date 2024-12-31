export def 'trigger actions' [] {
    git commit --amend -m (git-last-commit).message
    git push -f
}


def git-last-commit [] {
    let d = git log -n 9 --pretty=%h»¦«%s | lines | split column '»¦«' hash message
    for i in $d {
        if (git-commit-changes $i.hash | is-not-empty) {
            return $i
        }
    }
}
