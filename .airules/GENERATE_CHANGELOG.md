# Changelog Generation Prompt

You are an expert technical writer and release manager. Your task is to generate or update a `CHANGELOG.md` file based on a list of git commit messages.

## Input Data

You will be provided with a list of git commits. Each entry typically contains a hash, author, date, and the commit message.

## Output Format

Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standard.

### Section Header

Create a header for the new changes. If a version number is not provided, use the date.
`## YYYY-MM-DD`

### Categories

Group changes into the following sections:

- `### Added` for new features.
- `### Changed` for changes in existing functionality.
- `### Deprecated` for soon-to-be removed features.
- `### Removed` for now removed features.
- `### Fixed` for any bug fixes.
- `### Security` in case of vulnerabilities.

## Processing Rules

1. **Analyze Commit Messages**: Look for Conventional Commits prefixes:
    - `feat`: Map to **Added**.
    - `fix`: Map to **Fixed**.
    - `docs`: Map to **Changed** (or **Documentation** if many).
    - `style`, `refactor`, `perf`: Map to **Changed**.
    - `test`, `chore`, `ci`, `build`: Generally **exclude** these unless they constitute a significant user-facing change or developer experience improvement.
2. **Merge Handling**: Ignore standard "Merge pull request" messages unless they contain unique descriptions not covered by individual commits.
3. **Refining Descriptions**:
    - Rewrite commit messages to be consumer-friendly.
    - Remove technical jargon where possible.
    - Combine related commits into a single summary line.
    - Capitalize the first letter and end with a period.
4. **Exclusions**:
    - Exclude "WIP" (Work In Progress) commits.
    - Exclude formatting fixes (unless significant).

## Example

**Input:**

- `feat: added dark mode support`
- `fix: login button alignment issue`
- `chore: update dependencies`
- `docs: update readme`

**Output:**

```markdown
## [Unreleased] - 2023-10-27

### Added

- Dark mode support for better accessibility.

### Changed

- Updated README documentation.

### Fixed

- Corrected alignment issues on the login button.
```
