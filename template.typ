#let template(body) = {
  set cite(style: "ieee.csl")
  set bibliography(style: "ieee.csl")

  set text(
    size: 14pt,
    lang: "en",
    font: "Times New Roman",
  )

  set par(
    justify: true, 
    linebreaks: "optimized",
    first-line-indent: (amount: 1em, all: true), // Абзацный отступ. Должен быть одинаковым по всему тексту и равен пяти знакам (ГОСТ Р 7.0.11-2011, 5.3.7).
    leading: 1em, // Полуторный интервал (ГОСТ 7.0.11-2011, 5.3.6)
  )

  set list(marker: [•], indent: 0.5em, body-indent: 0.5em, spacing: 1em)
  set enum(indent: 1.25cm, body-indent: 0.5em, spacing: 1em)
  show list: it => {
    set par(leading: 1em, first-line-indent: (amount: 0cm, all: false))
    it
  }
  show enum: it => {
    set par(leading: 1em, first-line-indent: (amount: 0cm, all: false))
    it
  }

  set page(
    "a4",
    margin: (left: 2.5cm, top: 1in + 2cm, right: 2cm, bottom: 2cm),
    // header-ascent: 1cm,
    footer: none,
    header: context {
      set par(first-line-indent: (amount: 0cm))

      let chapter-start = query(selector(heading.where(level: 1)))
        .filter(h => here().page() == h.location().page()).len() > 0
      if chapter-start { return }

      let bib = query(selector(bibliography))
      let bib-page = if bib.len() > 0 { bib.first().location().page() } else { 0 }
      // Treat as "in appendix" if a level-1 heading exists on or after the
      // bibliography page and on or before the current page. Otherwise the
      // appendix would inherit the "Bibliography" header.
      let l1-after-bib = query(selector(heading.where(level: 1)))
        .filter(h =>
          h.location().page() > bib-page and
          h.location().page() <= here().page())
      let in-appendix = l1-after-bib.len() > 0
      let in-bib = bib.len() > 0 and bib-page < here().page() and not in-appendix

      let label = if in-bib {
        [Bibliography]
      } else {
        let before = query(selector(heading.where(level: 2)).before(here()))
        let on-top = query(selector(heading.where(level: 2)))
          .filter(h =>
            here().page() == h.location().page() and
            h.location().position().y < 5cm)
        if before.len() == 0 and on-top.len() == 0 { return }

        let current = if on-top.len() > 0 { on-top.first() } else { before.last() }
        let nums = counter(heading).at(current.location())
        let num = if in-appendix {
          let parts = (str.from-unicode(64 + nums.at(0)),) + nums.slice(1).map(str)
          parts.join(".")
        } else {
          nums.map(str).join(".")
        }
        [#num #current.body]
      }

      pad(left: 0.5em, right: 0.5em)[
        #strong(label)
        #h(1fr)
        #strong[#counter(page).display("1")]
      ]
      v(0.2em)
      line(length: 100%, stroke: 0.5pt)
    },
  )

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter(figure.where(kind: image)).update(0)
    set par(leading: 1em, first-line-indent: (amount: 0cm, all: false))
    set text(size: 1.5em)
    v(2cm)
    if it.numbering != none {
      [
        Chapter #counter(heading).display()


        #text(size: 1.2em, it.body)
      ]
    } else { it }
    v(0.5cm)
  }
  show heading.where(level: 2): it => {
    set text(size: 1.3em)
    it
    v(.5cm)
  }
  show heading.where(level: 3): it => {
    set text(size: 1.25em)
    it
    v(.2cm)
  }

  set math.equation(numbering: "(1)")

  set ref(supplement: it => {
    if it.func() == heading { "Chapter" } else { it.supplement }
  })
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      numbering(el.numbering, ..counter(math.equation).at(el.location()))
    } else { it }
  }

  show figure: set block(breakable: true)
  show figure: it => {
      v(1em)
      if it.kind == image {
        block(breakable: false, sticky: true, width: 100%, align(center, it.body))
        it.caption
      } else {
        it
      }
      v(1em)
    }
  show figure.where(kind: table): it => {
    align(center)[
      TABLE #it.counter.display("1") \
      #it.caption.body
    ]
    align(center, it.body)
  }
  show figure.where(kind: image): set figure(supplement: "Fig.")
  show figure.where(kind: image): set figure.caption(separator: ". ")
  show figure.where(kind: image): set figure(numbering: n => {
    let chapter = counter(heading.where(level: 1)).at(here()).first()
    [#chapter.#n]
  })

  // 2. Apply explicit paragraph block styling ONLY to image captions
  show figure.caption: cap => {
    if cap.kind == image {
      set align(left)
      set par(justify: true, leading: 1em)
      
      // Evaluate the counter to get the visual prefix (e.g., "Fig. 1.1. ")
      let number = context cap.counter.display(cap.numbering)
      
      // Force a structural 1em horizontal indent right at the start
      [#h(1em)#cap.supplement #number#cap.separator#cap.body]
    }
  }

  set outline(indent: auto)

  show raw.where(block: true): block.with(
    fill: luma(249),
    inset: 10pt,
    radius: 2pt,
    stroke: 1pt,
  )

  show table: set table(
    inset: 9pt,
    fill: (col, row) => {
      if row == 0 {
        rgb("ffffff")
      } else if calc.odd(row) {
        rgb("f3f4f6")
      } else {
        rgb("ffffff")
      }
    }
  )

  show figure.where(kind: table): it => {
    // Разрешаем фигуре разрываться, но управляем внутренними блоками
    block(breakable: true, sticky: true, width: 100%)[
      // sticky: true привязывает заголовок к первой строке таблицы
        #align(center)[
          TABLE #it.counter.display("1") \
          #it.caption.body
        ]
        #v(0.5em) // Небольшой отступ между заголовком и таблицей
      #align(center, it.body)
    ]
  }

  body
}

#let numbering(body) = {
  set page(numbering: "1")
  set heading(numbering: (..nums) => {
    if nums.pos().len() > 3 { return }
    nums.pos().map(str).join(".")
  })
  body
}
