# Build the site with Quarto, not R Markdown

The site was an `rmarkdown::render_site` project on Bootstrap 3 whose committed
HTML had drifted from its source. We moved it to a Quarto website (Bootstrap 5,
SCSS theming, one `_quarto.yml`) because Quarto is the maintained successor for
R-based sites and can render the CV to both HTML and PDF from one file. Existing
page URLs (`index`, `about`, `research`, `academic_cv`) are kept; `rescue.html` is
retired and its content folded into About.
