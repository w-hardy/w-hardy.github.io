# Publish with GitHub Actions; do not commit the rendered site

The old site went stale because publishing depended on remembering to re-render
and commit HTML. A GitHub Actions workflow now renders the Quarto project on every
push to `main` and deploys it to GitHub Pages, so the rendered output is
git-ignored. The alternative, rendering locally and committing `docs/`, was
rejected because it reintroduces the same manual step.

## Consequences

- The repository's Pages source must be set to "GitHub Actions"; serving from a
  branch will show nothing.
- Anyone looking for built HTML in the repo will not find it: it exists only in
  the Actions artifact and on the live site.
