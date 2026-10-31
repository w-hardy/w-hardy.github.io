--[[
cv-date.lua: in the PDF (Typst) CV, separate a [date]{.cv-date} span from the
text that follows it. In HTML the gap comes from CSS (theme.scss).
]]
function Span(span)
  if span.classes:includes("cv-date") and FORMAT:match("typst") then
    span.content:insert(pandoc.RawInline("typst", "#h(1em)"))
    return span
  end
end
