--[[
publist.lua — render publication lists from one BibTeX file.

Usage in a .qmd page (front matter):
  publications: publications.bib
  publist-csl: apa.csl    # optional, defaults to apa.csl
  filters: [filters/publist.lua]

Then, in the body, a div per list:
  ::: {.publist types="article-journal"}
  :::
  ::: {.publist keys="hardy2022extrapolating,marsden2023expo"}
  :::

Entries are formatted with the CSL style, ordered newest first, and Will
Hardy's name is set in bold (CSL cannot style a single author).
]]

local refs_meta = {}   -- id -> MetaMap entry (for citeproc)
local refs_info = {}   -- id -> plain table (type, date)
local csl_path = "apa.csl"

local function split(s)
  local out = {}
  for item in string.gmatch(s or "", "[^,%s]+") do out[#out + 1] = item end
  return out
end

local function sort_key(info)
  local parts = info.issued and info.issued["date-parts"] and info.issued["date-parts"][1] or {}
  local y, m, d = tonumber(parts[1]) or 0, tonumber(parts[2]) or 0, tonumber(parts[3]) or 0
  return y * 10000 + m * 100 + d
end

local function load_bib(path)
  local fh = io.open(path, "r")
  if not fh then
    error("publist: cannot read bibliography '" .. path .. "'")
  end
  local text = fh:read("a")
  fh:close()
  local bibdoc = pandoc.read(text, "biblatex")
  for _, entry in ipairs(bibdoc.meta.references or {}) do
    local id = pandoc.utils.stringify(entry.id)
    refs_meta[id] = entry
  end
  for _, info in ipairs(pandoc.utils.references(bibdoc)) do
    refs_info[info.id] = info
  end
end

-- Bold "Hardy, W." followed by any further initials, leaving Lew Hardy alone.
local function is_initial(s)
  return s:match("^%u%.[,]?$") ~= nil
end

local function bold_own_name(inlines)
  local out = pandoc.Inlines{}
  local i = 1
  while i <= #inlines do
    local el = inlines[i]
    local nxt = inlines[i + 2]
    if el.t == "Str" and el.text == "Hardy,"
       and inlines[i + 1] and (inlines[i + 1].t == "Space")
       and nxt and nxt.t == "Str" and nxt.text:match("^W%.[,]?$") then
      local name = pandoc.Inlines{ el, inlines[i + 1], nxt }
      local j = i + 3
      while not name[#name].text:match(",$")
            and inlines[j] and inlines[j].t == "Space"
            and inlines[j + 1] and inlines[j + 1].t == "Str"
            and is_initial(inlines[j + 1].text) do
        name:insert(inlines[j]); name:insert(inlines[j + 1])
        j = j + 2
      end
      local trailing = nil
      local last = name[#name]
      if last.text:match(",$") then
        name[#name] = pandoc.Str(last.text:sub(1, -2))
        trailing = pandoc.Str(",")
      end
      out:insert(pandoc.Strong(name))
      if trailing then out:insert(trailing) end
      i = j
    else
      out:insert(el)
      i = i + 1
    end
  end
  return out
end

local function format_entry(id)
  local doc = pandoc.Pandoc({}, pandoc.Meta{
    references = pandoc.MetaList{ refs_meta[id] },
    nocite = pandoc.MetaInlines{ pandoc.Cite({ pandoc.Str("@" .. id) },
                                 { pandoc.Citation(id, "NormalCitation") }) },
    csl = csl_path,
    ["link-citations"] = false,
  })
  doc = pandoc.utils.citeproc(doc)
  local entry = nil
  doc:walk({
    Div = function(div)
      if div.classes:includes("csl-entry") then entry = div end
    end
  })
  if not entry then
    error("publist: citeproc produced no entry for '" .. id .. "'")
  end
  return entry:walk({ Inlines = bold_own_name })
end

local function build_list(div)
  local ids = {}
  if div.attributes.keys then
    for _, id in ipairs(split(div.attributes.keys)) do
      if not refs_meta[id] then error("publist: unknown key '" .. id .. "'") end
      ids[#ids + 1] = id
    end
  else
    local wanted = {}
    for _, t in ipairs(split(div.attributes.types)) do wanted[t] = true end
    for id, info in pairs(refs_info) do
      if wanted[info.type] then ids[#ids + 1] = id end
    end
  end
  table.sort(ids, function(a, b)
    local ka, kb = sort_key(refs_info[a]), sort_key(refs_info[b])
    if ka ~= kb then return ka > kb end
    return a < b
  end)
  local body = pandoc.Blocks{}
  for _, id in ipairs(ids) do
    body:insert(format_entry(id))
  end
  return pandoc.Div(body, pandoc.Attr("", { "references", "csl-bib-body", "hanging-indent", "publist" }))
end

function Pandoc(doc)
  local bib = doc.meta.publications
  if not bib then return nil end
  if doc.meta["publist-csl"] then
    csl_path = pandoc.utils.stringify(doc.meta["publist-csl"])
  end
  load_bib(pandoc.utils.stringify(bib))
  doc.blocks = doc.blocks:walk({
    Div = function(div)
      if div.classes:includes("publist") then return build_list(div) end
    end
  })
  return doc
end
