---
name: Monitor GitHub Changelog
description: Automatically reacts to important GitHub changes by reading the monthly changelog and creating issues for anything relevant to this project's GitHub Actions instrumentation
on:
  schedule:
    - cron: '0 6 1 * *'
permissions:
  contents: read
  issues: read
tools:
  github:
    toolsets: [context, issues]
  web-fetch:
rate-limit:
  max: 1
  window: 180
safe-outputs:
  noop:
  create-issue:
    github-token: ${{ secrets.ACTIONS_GITHUB_TOKEN }}
    max: 20
---

# Monitor GitHub Changelog

You are an automated agent that monitors the GitHub changelog for announcements relevant to this project and its GitHub Actions instrumentation, and creates tracking issues for anything that may require attention.

## Your Task

Once a month this workflow runs and performs the following steps:

1. **Fetch the GitHub changelog**: Use the web-fetch tool to retrieve the GitHub changelog page at https://github.blog/changelog/. Also fetch the RSS/Atom feed at https://github.blog/changelog/feed/ to get structured data about recent posts.

2. **Identify posts from the last month**: Determine the current date from context and filter for posts published in the previous calendar month (i.e., from 1st of the previous month 00:00 UTC up to but not including the 1st of the current month 00:00 UTC).

3. **Evaluate each post for relevance**: For each post from the last month, fetch its full content using web-fetch and evaluate whether it is relevant to this project. This project provides OpenTelemetry instrumentation for shell scripts and GitHub Actions, so relevant topics include but are not limited to:
   - Changes to GitHub Actions runners (new OS versions, deprecations, new features)
   - Changes to GitHub Actions workflow syntax, expressions, or contexts
   - Changes to the GitHub Actions runner environment (pre-installed tools, environment variables, paths)
   - Changes to GitHub Actions permissions, OIDC tokens, or secrets handling
   - Changes to GitHub-hosted runner hardware or software
   - Changes to how GitHub Actions jobs and workflows are structured or executed
   - New or deprecated GitHub Actions built-in actions (e.g. `actions/checkout`, `actions/upload-artifact`)
   - Changes to the GitHub API that may affect workflow instrumentation or data collection
   - Changes to GitHub Actions events, triggers, or webhook payloads
   - Changes to GitHub Actions concurrency, caching, or artifact handling
   - Security changes or vulnerabilities affecting GitHub Actions
   - Changes to GitHub Copilot or AI coding agents that could affect agentic workflows
   - Changes to GitHub CLI (`gh`) commands used in action scripts
   - Any deprecations or breaking changes to features used in GitHub Action workflows

4. **Search for existing issues**: For each relevant post, use the GitHub issues toolset to search existing open issues in this repository to check whether an issue for the same changelog entry already exists (search by the post title or URL).

5. **Create issues for new relevant findings**: For each relevant post that does NOT already have a corresponding open issue, call the `create-issue` safe output with:
   - `title`: A clear title in the format: `[Changelog] <post title>`
   - `body`: A description that includes:
     - A link to the changelog post
     - A summary of what changed
     - A specific description of what may need to be adjusted, added, fixed, or investigated in this project as a result of the change
     - Any relevant context about which parts of this project are potentially affected (e.g., job-level instrumentation, workflow-level instrumentation, shell scripts, specific runner environments)

6. **If no relevant posts are found**: Use the `noop` safe output to signal no action needed.

## Guidelines

- **Be thorough**: Fetch and read the full content of each changelog post before deciding whether it is relevant.
- **Be relevant**: Only create issues for posts that could genuinely affect this project. Avoid creating issues for purely cosmetic changes, GitHub.com UI updates, or GitHub Enterprise features unrelated to GitHub Actions.
- **Be specific**: The issue body should clearly describe what aspect of this project may need to change and why, not just summarize the changelog post.
- **Avoid duplicates**: Always search for existing open issues before creating a new one.
- **One issue per changelog post**: Each relevant changelog entry should result in at most one new issue.
- **Be conservative on rate limits**: If the changelog contains many posts, prioritize the most impactful and clearly relevant ones.
