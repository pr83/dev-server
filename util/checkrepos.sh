#!/bin/bash

function sendEmail {
    subject="$1"
    emailAddress="$2"
    mail -s "${subject}" "${emailAddress}"
}

function processRepositoryWithChanges {
    emailAddress="$1"

    if [ -f .gitsync ]; then
        git add "*"
        git commit -m "automatic synchronization"
        git push
    else
        subject="Uncommitted changes in $(pwd)"
        git status | sendEmail "${subject}" "${emailAddress}"
    fi
}

function processGitRepository {
    emailAddress="$1"

    echo Inspecting $(pwd)
    uncommittedChanges=$(git status --porcelain)
    unpushedChanges=$(git rev-list HEAD@{upstream}..HEAD)

    if [[ ${uncommittedChanges} ]] || [[ ${unpushedChanges} ]]; then
        processRepositoryWithChanges "${emailAddress}"
    fi
}

function processDotGitDirectory {
    dotGitDirectory="$1"
    emailAddress="$2"
    cd ${dotGitDirectory}
    cd ..
    processGitRepository "${emailAddress}"
}

function listDotGitDirectories {
    find / -name ".git" -type d 2>/dev/null
}

emailAddress="$1"
listDotGitDirectories | while read dotGitDirectory;
do
    processDotGitDirectory "${dotGitDirectory}" "${emailAddress}"
done