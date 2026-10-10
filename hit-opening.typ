// HIT(SZ) 2026 undergraduate opening-report template for Typst 0.15.x.
// Geometry is calibrated against the official DOC template and hithesis PR #302.

#let hit-config(preview: false, cover-title-font: auto, toc-font: auto) = {
  let latin = if preview { "Liberation Serif" } else { "Times New Roman" }
  let cjk-body = if preview { "Noto Serif CJK SC" } else { "SimSun" }
  let cjk-heading = if preview { "Noto Sans CJK SC" } else { "SimHei" }
  let cjk-toc = if toc-font != auto { toc-font } else if preview { "Noto Serif CJK SC" } else { "FangSong" }
  let code = if preview { "DejaVu Sans Mono" } else { "JetBrains Mono" }
  let cover-title = if cover-title-font != auto {
    cover-title-font
  } else if preview {
    cjk-heading
  } else {
    "STXinwei"
  }

  (
    latin_font: latin,
    cjk_body_font: cjk-body,
    cjk_heading_font: cjk-heading,
    code_font: code,
    cover_title_font: cover-title,
    cover_title_fallback: preview,
    math_font: "STIX Math",
    body_font: (
      (name: latin, covers: "latin-in-cjk"),
      cjk-body,
    ),
    heading_font: (
      (name: latin, covers: "latin-in-cjk"),
      cjk-heading,
    ),
    toc_font: (
      (name: latin, covers: "latin-in-cjk"),
      cjk-toc,
    ),
    preview: preview,
  )
}

#let word-line-ratio = 19.45 / 12
#let line-top = 0.7 * word-line-ratio * 1em
#let line-bottom = -0.3 * word-line-ratio * 1em

// Word/WPS TOC styles use 1.25 multiple spacing, which resolves to a
// 21pt baseline step for the 12pt TOC text in the official document.
#let toc-line-ratio = 21 / 12
#let toc-line-top = 0.7 * toc-line-ratio * 1em
#let toc-line-bottom = -0.3 * toc-line-ratio * 1em

#let hit-numbering(..nums) = nums.pos().map(str).join(".")

#let heading-style(level) = {
  if level == 1 {
    (size: 18pt, before: 0pt, after: 11.09pt, gap: 18pt, alignment: center)
  } else if level == 2 {
    (size: 15pt, before: 6pt, after: 7.17pt, gap: 15pt, alignment: left)
  } else if level == 3 {
    (size: 14pt, before: 6.97pt, after: 7.17pt, gap: 3.5pt, alignment: left)
  } else {
    (size: 12pt, before: 0pt, after: 0pt, gap: 12pt, alignment: left)
  }
}

#let reset-chapter-counters() = {
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
}

#let render-heading(cfg, it) = {
  if it.level == 1 {
    pagebreak(weak: true)
    if it.numbering != none {
      reset-chapter-counters()
    }
    // Word/WPS template: every level-1 heading shares the same first baseline.
    // 10.812pt moves the Typst baseline from 128.139pt to about 138.951pt.
    v(10.812pt)
  }

  context {
    let style = heading-style(it.level)
    let numbered = it.numbering != none
    let number = if numbered { counter(heading).display(it.numbering) } else { none }

    block(width: 100%, above: style.before, below: style.after, sticky: true)[
      #set text(font: cfg.heading_font, size: style.size, weight: "regular")
      #set par(first-line-indent: 0pt, justify: false)

      #if it.level == 1 {
        let title-line = if numbered { [#number#h(style.gap)#it.body] } else { it.body }
        align(style.alignment)[#title-line]
      } else {
        let prefix = if numbered { box[#number#h(style.gap)] } else { box[] }
        let prefix-width = measure(prefix).width
        par(hanging-indent: prefix-width)[#prefix#it.body]
      }
    ]
  }
}

#let toc-spec(cfg, level) = {
  // Match the official Word TOC geometry: 0 / 17 / 34 pt left indents.
  // Level-1 reserves enough room for â€œç¬¬ x ç« â€; lower levels reserve only
  // their numeric prefix (x.x / x.x.x).
  if level == 1 {
    (indent: 0pt, num-width: 40.8pt, font: cfg.toc_font)
  } else if level == 2 {
    (indent: 17pt, num-width: 21pt, font: cfg.toc_font)
  } else {
    (indent: 34pt, num-width: 30pt, font: cfg.toc_font)
  }
}

#let render-toc-entry(cfg, it) = context {
  let spec = toc-spec(cfg, it.level)
  // FangSong commonly has no real bold face. In preview mode Noto Serif can use
  // its true bold face; in formal mode emulate Word/WPS faux-bold with a small
  // outline stroke. Apply the emphasis only to the prefix + title, not to the
  // dotted leader or page number.
  let entry-weight = if it.level == 1 and cfg.preview { "bold" } else { "regular" }
  let entry-stroke = if it.level == 1 and not cfg.preview { 0.20pt + black } else { none }
  let emphasize(body) = if it.level == 1 {
    text(weight: entry-weight, stroke: entry-stroke, body)
  } else {
    body
  }
  let raw-prefix = it.prefix()
  let prefix = if raw-prefix == none {
    none
  } else if it.level == 1 {
    [#text[ç¬¬]#raw-prefix#text[ç« ]]
  } else {
    raw-prefix
  }
  let prefix-width = if prefix == none { 0pt } else { spec.num-width }

  link(
    it.element.location(),
    block(width: 100%, above: 0pt, below: 0pt)[
      #set text(
        font: spec.font,
        fallback: false,
        size: 12pt,
        weight: "regular",
        stroke: none,
        top-edge: toc-line-top,
        bottom-edge: toc-line-bottom,
      )
      #set par(first-line-indent: 0pt, spacing: 0pt, leading: 0pt, justify: false)
      #pad(left: spec.indent)[
        #grid(
          columns: (prefix-width, 1fr),
          column-gutter: 0pt,
          [#emphasize(prefix)],
          [
            #grid(
              columns: (auto, 1fr, auto),
              column-gutter: 0pt,
              [#emphasize(it.body())],
              [#box(width: 100%)[#text(font: cfg.latin_font, weight: "regular", stroke: none, repeat([.], gap: 0pt))]],
              [#text(font: cfg.latin_font, weight: "regular", stroke: none, it.page())],
            )
          ],
        )
      ]
    ],
  )
}

#let hit-toc(cfg) = {
  show outline.entry: it => render-toc-entry(cfg, it)
  show outline.entry: set outline.entry(fill: repeat([.], gap: 0pt))

  // Calibrated against the Word/WPS TOC page: title baseline â‰ˆ 140.60pt,
  // first entry baseline â‰ˆ 175.45pt, then 21pt per entry.
  v(12.462pt)
  block(width: 100%, below: 11.397pt)[
    #set text(font: cfg.heading_font, size: 18pt, weight: "regular")
    #set par(first-line-indent: 0pt, justify: false)
    #align(center)[ç›® å½•]
  ]
  outline(title: none, depth: 3)
}

#let header-text(cfg, body) = text(
  font: cfg.body_font,
  size: 9pt,
  lang: "zh",
  top-edge: 0.7em,
  bottom-edge: -0.3em,
  body,
)

#let report-header(cfg) = {
  // Text is raised slightly to match the Word/WPS visual top edge.
  place(
    top + center,
    dy: 81.66pt,
    header-text(cfg)[å“ˆå°”æ»¨å·¥ä¸šå¤§å­¦æ·±åœ³æ ¡åŒºæ¯•ä¸šè®ºæ–‡ï¼ˆè®¾è®¡ï¼‰å¼€é¢˜æŠ¥å‘Š],
  )
  // Word/WPS uses a thin line above a thick line, aligned to the 30 mm body margins.
  place(top + left, dx: 85.10pt, dy: 97.35pt, line(length: 425.15pt, stroke: 0.75pt))
  place(top + left, dx: 85.10pt, dy: 99.95pt, line(length: 425.15pt, stroke: 3pt))
}

#let report-footer(cfg, pattern: "1", dashed: true) = context {
  let n = counter(page).get().first()
  let num = numbering(pattern, n)
  let body = if dashed { [-#h(4.5pt)#num#h(4.5pt)-] } else { num }

  place(
    top + center,
    dy: 271.12mm,
    text(
      font: cfg.latin_font,
      size: 9pt,
      top-edge: 0.7em,
      bottom-edge: -0.3em,
      body,
    ),
  )
}

#let report-decoration(cfg, front: false) = context {
  report-header(cfg)
  if front {
    report-footer(cfg, pattern: "I", dashed: false)
  } else {
    report-footer(cfg, pattern: "1", dashed: true)
  }
}

// ---------------- Figures / tables / equations ----------------

#let chapter-number() = counter(heading).get().first()

#let chaptered-numbering(n) = context {
  numbering("1-1", chapter-number(), n)
}

#let chaptered-equation-numbering(cfg, n) = context {
  let ch = chapter-number()
  text(font: cfg.latin_font, size: 12pt, "(" + str(ch) + "-" + str(n) + ")")
}

#let render-figure-caption(cfg, it) = context {
  let num = if it.numbering == none { none } else { it.counter.display(it.numbering) }
  align(center)[#it.supplement#num#it.separator#it.body]
}

#let hit-table-header-cell(body) = table.cell(
  inset: (x: 6pt, top: 3.189pt, bottom: 1.967pt),
  align: center,
)[#body]

#let hit-table-first-cell(body) = table.cell(
  inset: (x: 6pt, top: 3.04pt, bottom: 0pt),
  align: center,[#body])

#let hit-table-body-cell(body) = table.cell(
  inset: (x: 6pt, y: 0pt),
  align: center,
)[#body]

#let hit-table-last-cell(body) = table.cell(
  inset: (x: 6pt, top: 0pt, bottom: 2.116pt),
  align: center,[#body])

#let hit-three-line-table(columns, header, rows) = {
  let heads = header.map(x => hit-table-header-cell(x))
  let cells = ()

  for (i, row) in rows.enumerate() {
    let first = i == 0
    let last = i == rows.len() - 1
    for x in row {
      let c = if first and last {
        table.cell(inset: (x: 6pt, top: 3.04pt, bottom: 2.116pt), align: center)[#x]
      } else if first {
        hit-table-first-cell(x)
      } else if last {
        hit-table-last-cell(x)
      } else {
        hit-table-body-cell(x)
      }
      cells.push(c)
    }
  }

  table(
    columns: columns,
    stroke: none,
    inset: 0pt,
    table.hline(stroke: 0.797pt),
    ..heads,
    table.hline(stroke: 0.4982pt),
    ..cells,
    table.hline(stroke: 0.797pt),
  )
}

#let hit-numbered-paragraph(n, body) = par(
  first-line-indent: (amount: 2em, all: true),
  spacing: 0pt,
[#box[#n.#h(3pt)]#body]

#let hit-runin-heading(title, body, preview: false) = {
  let cfg = hit-config(preview: preview)
  context {
    let cur = counter(heading).get()
    let a = cur.at(0, default: 0)
    let b = cur.at(1, default: 0)
    let c = cur.at(2, default: 0)
    let d = cur.at(3, default: 0) + 1
    let vals = (a, b, c, d)
    let num = vals.map(str).join(".")
    counter(heading).update(vals)

    par(first-line-indent: 0pt, leading: 0pt, spacing: 0pt)[
      #text(font: cfg.latin_font, size: 12pt)[#num]
      #h(12pt)
      #text(font: cfg.heading_font, size: 12pt, weight: "regular")[#title]
      #text(font: cfg.body_font, size: 12pt)[#body]
    ]
  }
}

// ---------------- Cover -----------------

#let cover-hline(x, y, len, stroke-width) = place(
  top + left,
  dx: x,
  dy: y,
  line(length: len, stroke: stroke-width),
)

#let cover-empty-checkbox(x) = place(
  top + left,
  dx: x,
  dy: 89.121pt,
  rect(width: 10pt, height: 10pt, stroke: 0.72pt),
)

#let cover-text(size, font, body) = text(
  font: font,
  size: size,
  weight: "regular",
  top-edge: 0.8em,
  bottom-edge: -0.2em,
  lang: "zh",
  body,
)

#let cover-big-title(cfg, body) = {
  layout(size => {
    set text(
      font: cfg.cover_title_font,
      fallback: cfg.cover_title_fallback,
      size: 36pt,
      weight: "regular",
      top-edge: 1.0em,
      bottom-edge: -0.05em,
    )
    scale(x: 90%, origin: left + top, box(body))
  })
}

#let cover-checkbox(x, checked: false) = {
  if checked {
    place(
      top + left,
      dx: x,
      dy: 89.121pt,
      image("szbachelor-checked.svg", width: 10pt, height: 10pt),
    )
  } else {
    cover-empty-checkbox(x)
  }
}

// The right-hand cover values are centered on the underline while preserving
// the original 166.32pt text wrapping width used for Word/WPS calibration.
#let cover-topic-block(cfg, body) = block(width: 173.76pt)[
  #align(center)[
    #block(width: 166.32pt)[
      #set align(center)
      #set text(font: cfg.heading_font, size: 18pt, top-edge: 0.88em, bottom-edge: -0.12em)
      #set par(first-line-indent: 0pt, leading: 16.98pt, spacing: 0pt, justify: false, linebreaks: "simple")
      #body
    ]
  ]
}

#let cover-field-block(cfg, body) = block(width: 173.76pt)[
  #align(center)
    #block(width: 166.32pt)[
      #set align(center)
      #set text(font: cfg.body_font, size: 15pt, top-edge: 0.88em, bottom-edge: -0.12em)
      #set par(first-line-indent: 0pt, leading: 14.16pt, spacing: 0pt, justify: false, linebreaks: "simple")
      #body
    ]
  ]
}

#let cover-topic-lines(cfg, body) = {
  let h = measure(cover-topic-block(cfg, body)).height
  int(calc.round((h - 18pt) / 34.98pt)) + 1
}

#let cover-field-lines(cfg, body) = {
  // Match the Word/TeX cover field's implicit strut: even an empty field
  // occupies one line. Without this floor, blank name/student/supervisor
  // fields measure as zero lines and collapse all following rows upward.
  let h = measure(cover-field-block(cfg, body)).height
  calc.max(1, int(calc.round((h - 15pt) / 29.16pt)) + 1)
}

#let hit-cover(
  cfg,
  reporttype: "none",
  title: [é£å‘å®å­§ç”¨æˆ·ç¨‹åºè¿è¡Œçš„ Rust æ“ä½œç³»ç»Ÿå†…æ ¸è®¾è§£ä¸å®ä¸°],
  author: [],
  student-id: [],
  affiliation: [æ·±åœ³æ ¡åŒºè®¡ç®—æœºç§‘å­§ä¸æŠ€æœ¯å­¦é™¢],
  subject: [è®¡ç®—æœºç§‘å­§ä¸æŠ€æœ¯],
  supervisor: [],
  date: [],
) = context {
  let topic-lines = cover-topic-lines(cfg, title)
  let topic-rule-lines = calc.max(2, topic-lines)
  let topic-extra = calc.max(0pt, topic-lines * 34.98pt + 9.06pt - 109.44pt)

  let author-lines = cover-field-lines(cfg, author)
  let sid-lines = cover-field-lines(cfg, student-id)
  let affiliation-lines = cover-field-lines(cfg, affiliation)
  let subject-lines = cover-field-lines(cfg, subject)
  let supervisor-lines = cover-field-lines(cfg, supervisor)
  let date-lines = cover-field-lines(cfg, date)

  // The formal SimSun/Times New Roman field text sits slightly lower than
  // the Word/WPS cover at the same baseline. Lift only the right-hand field
  // values, leaving labels and underline geometry untouched.
  let field-text-lift = 0.72pt

  let name-y = 437.157pt + topic-extra
  let sid-y = name-y + 17pt + (author-lines - 1) * 29.16pt + 24.16pt
  let affiliation-y = sid-y + 17pt + (sid-lines - 1) * 29.16pt + 24.16pt
  let subject-y = affiliation-y + 17pt + (affiliation-lines - 1) * 29.16pt + 24.28pt
  let supervisor-y = subject-y + 17pt + (subject-lines - 1) * 29.16pt + 24.16pt
  let date-y = supervisor-y + 17pt + (supervisor-lines - 1) * 29.16pt + 24.16pt

  let field-rules(y, lines) = {
    for i in range(lines) {
      cover-hline(266.998pt, y + 14.16pt + i * 29.16pt, 173.76pt, 0.72pt)
    }
  }

  page(width: 595.35pt, height: 842pt, margin: 0pt, header: none, footer: none)[
    #cover-checkbox(91pt, checked: reporttype == "thesis")
    #cover-checkbox(161.679pt, checked: reporttype == "design")
    #place(top + left, dx: 100.68pt, dy: 88.56pt, cover-text(12pt, cfg.body_font)[æ¯•ä¸šè®ºæ–‡])
    #place(top + left, dx: 171.359pt, dy: 88.56pt, cover-text(12pt, cfg.body_font)[æ¯•ä¸šè®¾è®¡])

    #place(top + left, dx: 108.25pt, dy: 148.569pt, cover-big-title(cfg, [å“ˆå°”æ»¨å·¥ä¸šå¤§å­¦æ·±åœ³æ ¡åŒº]))
    #place(top + left, dx: 90.95pt, dy: 205.668pt, cover-big-title(cfg, [æ¯•ä¸šè®¾è®¡å¼€é¢˜æŠ•å‘Š]))

    #place(top + left, dx: 154.559pt, dy: 325.077pt, cover-text(18pt, cfg.heading_font)[é¢˜])
    #place(top + left, dx: 224.993pt, dy: 325.077pt, cover-text(18pt, cfg.heading_font)[ç›®ï¼š])
    // Keep the title glyphs clear of the underline. In the Word/WPS cover the
    // underline sits about 2.70pt below the text baseline; Typst previously left
    // only about 1.02pt with SimHei, so glyphs such as â€œè¡Œâ€ touched the rule.
    #place(top + left, dx: 267pt, dy: 323.397pt, cover-topic-block(cfg, title))
    #for i in range(topic-rule-lines) {
      cover-hline(267pt, 341.937pt + i * 34.98pt, 173.76pt, 0.84pt)
    }

    #place(top + left, dx: 154.559pt, dy: name-y, cover-text(15pt, cfg.heading_font)[å®“])
    #place(top + left, dx: 221.999pt, dy: name-y, cover-text(15pt, cfg.heading_font)[åï¼š])
    #place(top + left, dx: 266.998pt, dy: name-y - field-text-lift, cover-field-block(cfg, author))
    #field-rules(name-y, author-lines)

    #place(top + left, dx: 154.559pt, dy: sid-y, cover-text(15pt, cfg.heading_font)[å­¦])
    #place(top + left, dx: 221.999pt, dy: sid-y, cover-text(15pt, cfg.heading_font)[å·ï¼š])
    #place(top + left, dx: 266.998pt, dy: sid-y - field-text-lift, cover-field-block(cfg, student-id))
    #field-rules(sid-y, sid-lines)

    #place(top + left, dx: 154.559pt, dy: affiliation-y, cover-text(15pt, cfg.heading_font)[å­¦])
    #place(top + left, dx: 221.999pt, dy: affiliation-y, cover-text(15pt, cfg.heading_font)[é™Šï¼š])
    #place(top + left, dx: 266.998pt, dy: affiliation-y - field-text-lift, cover-field-block(cfg, affiliation))
    #field-rules(affiliation-y, affiliation-lines)

    #place(top + left, dx: 154.559pt, dy: subject-y, cover-text(15pt, cfg.heading_font)[ä¸“])
    #place(top + left, dx: 221.999pt, dy: subject-y, cover-text(15pt, cfg.heading_font)[ä¸šï¼š])
    #place(top + left, dx: 266.998pt, dy: subject-y - field-text-lift, cover-field-block(cfg, subject))
    #field-rules(subject-y, subject-lines)

    #place(top + left, dx: 154.559pt, dy: supervisor-y, cover-text(15pt, cfg.heading_font)[æŒ‡])
    #place(top + left, dx: 177.029pt, dy: supervisor-y, cover-text(15pt, cfg.heading_font)[å¯¼])
    #place(top + left, dx: 199.514pt, dy: supervisor-y, cover-text(15pt, cfg.heading_font)[æ•¦])
    #place(top + left, dx: 221.999pt, dy: supervisor-y, cover-text(15pt, cfg.heading_font)[å¸ˆ~òit¤(€€€€Á±…”¡Ñ½À€¬±•™Ğ°‘àè€ÈØØ¸ääáÁĞ°‘äèÍÕÁ•ÉÙ¥Í½Èµä€´™¥•±µÑ•áĞµ±¥™Ğ°½Ù•Èµ™¥•±µ‰±½¬¡™œ°ÍÕÁ•ÉÙ¥Í½È¤¤(€€€€™¥•±µÉÕ±•Ì¡ÍÕÁ•ÉÙ¥Í½Èµä°ÍÕÁ•ÉÙ¥Í½Èµ±¥¹•Ì¤((€€€€Á±…”¡Ñ½À€¬±•™Ğ°‘àè€ÄÔĞ¸ÔÔåÁĞ°‘äè‘…Ñ”µä°½Ù•ÈµÑ•áĞ ÄÕÁĞ°™œ¹¡•…‘¥¹}™½¹Ğ¥oš^•t¤(€€€€Á±…”¡Ñ½À€¬±•™Ğ°‘àè€ÈÈÄ¸ääåÁĞ°‘äè‘…Ñ”µä°½Ù•ÈµÑ•áĞ ÄÕÁĞ°™œ¹¡•…‘¥¹}™½¹Ğ¥ošr¾òit¤(€€€€Á±…”¡Ñ½À€¬±•™Ğ°‘àè€ÈØØ¸ääáÁĞ°‘äè‘…Ñ”µä€´™¥•±µÑ•áĞµ±¥™Ğ°½Ù•Èµ™¥•±µ‰±½¬¡™œ°‘…Ñ”¤¤(€€€€™¥•±µÉÕ±•Ì¡‘…Ñ”µä°‘…Ñ”µ±¥¹•Ì¤(€t)ô((¼¼€´´´´´´´´´´´´´´´´½µÁ±•Ñ”É•Á½ÉĞÑ•µÁ±…Ñ”€´´´´´´´´´´´´´´´´((±•Ğ¡¥Ğµ½Á•¹¥¹œ (€ÁÉ•Ù¥•Üè™…±Í”°(€½Ù•ÈµÑ¥Ñ±”µ™½¹Ğè…ÕÑ¼°(€Ñ½Œµ™½¹Ğè…ÕÑ¼°(€É•Á½ÉÑÑåÁ”è€‰¹½¹”ˆ°(€Ñ¥Ñ±”èo¦v‹–BG–º{¦fR£š"ß¢/–ê?¢şC¢†3jIÕÍĞƒšN7’ösÎïî–š‚ã¢ºû¢º‡’â;–º{:Át°(€…ÕÑ¡½Èèmt°(€ÍÑÕ‘•¹Ğµ¥èmt°(€…™™¥±¥…Ñ¥½¸èošŞÇ–rÏš‚‡–2ë¢º‡º_šrëG–¶›’â;š*šr¿–¶›¦f‰t°(€ÍÕ‰©•Ğèo¢º‡º_šrëG–¶›’â;š*šr½t°(€ÍÕÁ•ÉÙ¥Í½Èèmt°(€‘…Ñ”èmt°(€Ñ½ŒèÑÉÕ”°(€‰±…¹¬µ…™Ñ•Èµ½Ù•Èè™…±Í”°(€‰½‘ä°(¤€ôì(€±•Ğ™œ€ô¡¥Ğµ½¹™¥œ¡ÁÉ•Ù¥•ÜèÁÉ•Ù¥•Ü°½Ù•ÈµÑ¥Ñ±”µ™½¹Ğè½Ù•ÈµÑ¥Ñ±”µ™½¹Ğ°Ñ½Œµ™½¹ĞèÑ½Œµ™½¹Ğ¤((€Í•ĞÁ…” (€€€Á…Á•Èè€‰„Ğˆ°(€€€µ…É¥¸è€¡±•™Ğè€ÌÁµ´°É¥¡Ğè€ÌÁµ´°Ñ½Àè€Ìáµ´°‰½ÑÑ½´è€ÌÁµ´¤°(€€¤(€Í•ĞÑ•áĞ (€€€™½¹Ğè™œ¹‰½‘å}™½¹Ğ°(€€€Í¥é”è€ÄÉÁĞ°(€€€±…¹œè€‰é ˆ°(€€€Ñ½Àµ•‘”è±¥¹”µÑ½À°(€€€‰½ÑÑ½´µ•‘”è±¥¹”µ‰½ÑÑ½´°(€€€©¬µ±…Ñ¥¸µÍÁ…¥¹œè…ÕÑ¼°(€€€½Ù•É¡…¹œè™…±Í”°(€€€¡åÁ¡•¹…Ñ”è™…±Í”°(€€¤(€Í•ĞÁ…È (€€€©ÕÍÑ¥™äèÑÉÕ”°(€€€±•…‘¥¹œè€ÁÁĞ°(€€€ÍÁ…¥¹œè€ÁÁĞ°(€€€™¥ÉÍĞµ±¥¹”µ¥¹‘•¹Ğè€¡…µ½Õ¹Ğè€É•´°…±°èÑÉÕ”¤°(€€€±¥¹•‰É•…­Ìè€‰Í¥µÁ±”ˆ°(€€¤(€Í•Ğ¡•…‘¥¹œ¡¹Õµ‰•É¥¹œè¡¥Ğµ¹Õµ‰•É¥¹œ¤(€Í¡½Ü¡•…‘¥¹œè¥Ğ€ôøÉ•¹‘•Èµ¡•…‘¥¹œ¡™œ°¥Ğ¤((€Í•Ğ™¥ÕÉ”¡¹Õµ‰•É¥¹œè¡…ÁÑ•É•µ¹Õµ‰•É¥¹œ¤(€Í•Ğ™¥ÕÉ”¹…ÁÑ¥½¸¡Í•Á…É…Ñ½Èèlt¤(€Í¡½Ü™¥ÕÉ”¹…ÁÑ¥½¸èÍ•ĞÑ•áĞ¡™½¹Ğè™œ¹‰½‘å}™½¹Ğ°Í¥é”è€ÄÉÁĞ°İ•¥¡Ğè€‰É•Õ±…Èˆ¤(€Í¡½Ü™¥ÕÉ”¹…ÁÑ¥½¸èÍ•ĞÁ…È¡™¥ÉÍĞµ±¥¹”µ¥¹‘•¹Ğè€ÁÁĞ°©ÕÍÑ¥™äè™…±Í”°ÍÁ…¥¹œè€ÁÁĞ°±•…‘¥¹œè€ÁÁĞ¤(€Í¡½Ü™¥ÕÉ”¹…ÁÑ¥½¸è¥Ğ€ôøÉ•¹‘•Èµ™¥ÕÉ”µ…ÁÑ¥½¸¡™œ°¥Ğ¤(€Í¡½Ü™¥ÕÉ”¹İ¡•É”¡­¥¹è¥µ…”¤èÍ•Ğ™¥ÕÉ”¡ÍÕÁÁ±•µ•¹Ğèo–nùt°…Àè€ÄÁÁĞ¤(€Í¡½Ü™¥ÕÉ”¹İ¡•É”¡­¥¹è¥µ…”¤è¥Ğ€ôø‰±½¬¡…‰½Ù”è€Ü¸ÄÀÕÁĞ°‰•±½Üè€ÄØ¸àÀÙÁĞ¥l¥Ñt(€Í¡½Ü™¥ÕÉ”¹İ¡•É”¡­¥¹èÑ…‰±”¤èÍ•Ğ™¥ÕÉ”¡ÍÕÁÁ±•µ•¹Ğèo¢†¡t°…Àè€Ä¸åÁĞ¤(€Í¡½Ü™¥ÕÉ”¹İ¡•É”¡­¥¹èÑ…‰±”¤èÍ•Ğ™¥ÕÉ”¹…ÁÑ¥½¸¡Á½Í¥Ñ¥½¸èÑ½À¤(€Í¡½Ü™¥ÕÉ”¹İ¡•É”¡­¥¹èÑ…‰±”¤è¥Ğ€ôø‰±½¬¡…‰½Ù”è€Ü¸ÔàÑÁĞ°‰•±½Üè€ÄØ¸ÜÈÑÁĞ¥l¥Ñt((€Í•Ğµ…Ñ ¹•ÅÕ…Ñ¥½¸ (€€€¹Õµ‰•É¥¹œè¸€ôø¡…ÁÑ•É•µ•ÅÕ…Ñ¥½¸µ¹Õµ‰•É¥¹œ¡™œ°¸¤°(€€€¹Õµ‰•Èµ…±¥¸èÉ¥¡Ğ€¬¡½É¥é½¸°(€€€ÍÕÁÁ±•µ•¹Ğèo–ò=t°(€€¤(€Í¡½Üµ…Ñ ¹•ÅÕ…Ñ¥½¸èÍ•ĞÑ•áĞ¡™½¹Ğè™œ¹µ…Ñ¡}™½¹Ğ¤(€Í¡½Üµ…Ñ ¹•ÅÕ…Ñ¥½¸¹İ¡•É”¡‰±½¬èÑÉÕ”¤èÍ•Ğ‰±½¬¡…‰½Ù”è€ÈÜ¸ĞÉÁĞ°‰•±½Üè€Ü¸äÜÅÁĞ¤((€Í¡½ÜÉ…Ü¹İ¡•É”¡‰±½¬è™…±Í”¤èÍ•ĞÑ•áĞ¡™½¹Ğè™œ¹½‘•}™½¹Ğ°Í¥é”è€ÄÀ¸ÕÁĞ¤(€€¼¼¥ÍÁ±…ä½‘”‰±½­Ì…ÌÉ•ÍÑÉ…¥¹•Ñ¡•Í¥ÌµÍÑå±”±¥ÍÑ¥¹Ìèİ¡¥Ñ”‰…­É½Õ¹°(€€¼¼ÍÅÕ…É”½É¹•ÉÌ°…¹„Ñ¡¥¸¹•ÕÑÉ…°‰½É‘•È¸%¹±¥¹”½‘”ÍÑ…åÌÕ¹‰½á•¸(€Í¡½ÜÉ…Ü¹İ¡•É”¡‰±½¬èÑÉÕ”¤è¥Ğ€ôø‰±½¬ (€€€İ¥‘Ñ è€ÄÀÀ”°(€€€…‰½Ù”è€ÙÁĞ°(€€€‰•±½Üè€ÙÁĞ°(€€€¥¹Í•Ğè€¡àè€İÁĞ°äè€ÕÁĞ¤°(€€€ÍÑÉ½­”è€À¸ÕÁĞ€¬±Õµ„ ÄÈÀ¤°(€€€™¥±°èİ¡¥Ñ”°(€€€É…‘¥ÕÌè€ÁÁĞ°(€€€‰É•…­…‰±”èÑÉÕ”°(€€¥l(€€€€Í•ĞÑ•áĞ¡™½¹Ğè™œ¹½‘•}™½¹Ğ°Í¥é”è€åÁĞ°Ñ½Àµ•‘”è€À¸á•´°‰½ÑÑ½´µ•‘”è€´À¸É•´¤(€€€€Í•ĞÁ…È¡™¥ÉÍĞµ±¥¹”µ¥¹‘•¹Ğè€ÁÁĞ°©ÕÍÑ¥™äè™…±Í”°ÍÁ…¥¹œè€ÁÁĞ°±•…‘¥¹œè€À¸ÈÕ•´¤(€€€€¥Ğ(€t((€¡¥Ğµ½Ù•È (€€€™œ°(€€€É•Á½ÉÑÑåÁ”èÉ•Á½ÉÑÑåÁ”°(€€€Ñ¥Ñ±”èÑ¥Ñ±”°(€€€…ÕÑ¡½Èè…ÕÑ¡½È°(€€€ÍÑÕ‘•¹Ğµ¥èÍÑÕ‘•¹Ğµ¥°(€€€…™™¥±¥…Ñ¥½¸è…™™¥±¥…Ñ¥½¸°(€€€ÍÕ‰©•ĞèÍÕ‰©•Ğ°(€€€ÍÕÁ•ÉÙ¥Í½ÈèÍÕÁ•ÉÙ¥Í½È°(€€€‘…Ñ”è‘…Ñ”°(€€¤((€€¼¼=ÁÑ¥½¹…°Ù•ÉÍ¼‰±…¹¬…™Ñ•ÈÑ¡”½Ù•È¸Q¡¥Ì¥ÌÕÍ•™Õ°™½È‘ÕÁ±•àÁÉ¥¹Ñ¥¹œè(€€¼¼½Ù•È€ôÉ•Ñ¼°‰±…¹¬€ôÙ•ÉÍ¼°Í¼Ñ¡”Q=ÍÑ…ÉÑÌ½¸„™É•Í É•Ñ¼Í¡••Ğ¸(€€¼¼Q¡”‰±…¹¬Á…”¥¹Ñ•¹Ñ¥½¹…±±ä¡…Ì¹¼¡•…‘•È°™½½Ñ•È°½ÈÁ…”¹Õµ‰•È¸(€¥˜‰±…¹¬µ…™Ñ•Èµ½Ù•Èì(€€€Á…” (€€€€€İ¥‘Ñ è€ÔäÔ¸ÌÕÁĞ°(€€€€€¡•¥¡Ğè€àĞÉÁĞ°(€€€€€µ…É¥¸è€ÁÁĞ°(€€€€€¡•…‘•Èè¹½¹”°(€€€€€™½½Ñ•Èè¹½¹”°(€€€€€¹Õµ‰•É¥¹œè¹½¹”°(€€€€¥mt(€ô((€¥˜Ñ½Œì(€€€Á…•‰É•…¬¡İ•…¬èÑÉÕ”¤(€€€½Õ¹Ñ•È¡Á…”¤¹ÕÁ‘…Ñ” Ä¤(€€€Í•ĞÁ…”¡¹Õµ‰•É¥¹œè€‰$ˆ°™½½Ñ•Èè¹½¹”°™½É•É½Õ¹èÉ•Á½ÉĞµ‘•½É…Ñ¥½¸¡™œ°™É½¹ĞèÑÉÕ”¤¤(€€€¡¥ĞµÑ½Œ¡™œ¤(€ô((€Á…•‰É•…¬¡İ•…¬èÑÉÕ”¤(€½Õ¹Ñ•È¡Á…”¤¹ÕÁ‘…Ñ” Ä¤(€Í•ĞÁ…”¡¹Õµ‰•É¥¹œè€ˆÄˆ°™½½Ñ•Èè¹½¹”°™½É•É½Õ¹èÉ•Á½ÉĞµ‘•½É…Ñ¥½¸¡™œ°™É½¹Ğè™…±Í”¤¤(€‰½‘ä)ô(