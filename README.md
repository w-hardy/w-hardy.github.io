# w-hardy.github.io

Source for my academic website and CV, <https://w-hardy.github.io>, built with
[Quarto](https://quarto.org).

## Layout

| Path | Purpose |
|------|---------|
| `index.qmd`, `about.qmd`, `research.qmd` | Site pages |
| `academic_cv.qmd` | CV, rendered to HTML and to PDF (via Typst) |
| `publications.bib` | Every publication and presentation; the one source for the CV and Research page |
| `filters/publist.lua` | Renders publication lists from `publications.bib` (APA, newest first, my name in bold) |
| `filters/cv-date.lua` | Spaces CV dates in the PDF |
| `apa.csl` | APA 7th edition citation style |
| `_quarto.yml`, `theme.scss` | Site configuration and styling |
| `GLOSSARY.md`, `docs/adr/`, `CLAUDE.md` | Terms, design decisions and editing rules |

## Adding a publication

Add an entry to `publications.bib`; it appears on the CV (and on the Research
page if its key is listed there) at the next render. Use `@article`,
`@incollection`, `@report`, or `@unpublished` with `eventtitle` and `venue` for
presentations. Wrap proper nouns in `{braces}`, because titles are converted to
sentence case.

## Building locally

```bash
quarto preview   # live preview while editing
quarto render    # build the site and PDF CV into _site/
```

`_site/` is git-ignored.

## Publishing

`.github/workflows/publish.yml` renders the site and deploys it to GitHub Pages
on every push to `main`. The repository's Pages source must be set to
**GitHub Actions** (Settings → Pages → Build and deployment → Source).
