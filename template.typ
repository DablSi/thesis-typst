#let template(body) = {
  set cite(style: "ieee.csl")
  set bibliography(style: "ieee.csl")
  set text(
    size: 14pt,
    lang: "en",
    top-edge: 0.7em,
    bottom-edge: -0.3em,
    // Match LaTeX template's \usepackage{tempora}; fall back to Liberation Serif
    // if the bundled Tempora .otf files are not installed.
    font: ("Tempora LGC Uni", "Liberation Serif"),
  )
  set par(
    leading: 0.7em,
    justify: true,
    // Match LaTeX template's \setlength{\parindent}{2em} at 14pt.
    first-line-indent: (
      amount: 1cm,
    ),
  )
  set list(
    marker: [•],
    indent: 1.1em,
    body-indent: 0.55em,
    spacing: 0.55em,
  )
  show list: it => {
    set par(
      leading: 0.48em,
      first-line-indent: (
        amount: 0cm,
        all: false,
      ),
    )
    it
  }
  set enum(
    indent: 1.1em,
    body-indent: 0.55em,
    spacing: 0.55em,
  )
  set page(
    "a4",
    // Mirror LaTeX template's setmarginsrb (left=2.5cm, body top=2.2cm,
    // headheight=32.0976pt, headsep=10mm, right=2.2cm, bottom=2.2cm).
    margin: (
      left: 2.5cm,
      top: 2.2cm + 32.0976pt + 10mm,
      right: 2.2cm,
      bottom: 2.2cm
    ),
    footer: context {},
    header: context {
      set par(
        first-line-indent: (
          amount: 0cm,
        ),
      )

      let headings-before = query(selector(heading.where(level: 2)).before(here()))

      let headings-on-page-top = query(selector(heading.where(level: 2)))
        .filter(h =>
          here().page() == h.location().page() and
          h.location().position().y < 5cm
        )

      if headings-before.len() == 0 and headings-on-page-top.len() == 0 {
        return
      }

      let current = if headings-on-page-top.len() > 0 {
        headings-on-page-top.first()
      } else {
        headings-before.last()
      }

      if counter(heading).get() == (0,) {
        return
      }

      let is-chapter-begin = query(selector(heading.where(level: 1)))
        .filter(h1 => here().page() == h1.location().page()).len() > 0

      if is-chapter-begin {
        return
      }

      
      let current-number = counter(heading)
        .at(current.location())
        .map(str)
        .join(".")

      strong(current-number + " " + current.body)
      h(1fr)
      strong[#counter(page).display("1")]

      line(length: 100%)

    }
  )

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
  
  show heading.where(level: 1): it => {
    pagebreak(weak: true)

    // Reset image figure counter at the start of each chapter so that figures
    // are numbered "1.1, 1.2" within Chapter 1, "2.1, 2.2" within Chapter 2, etc.
    // Mirrors LaTeX's \counterwithin{figure}{chapter}.
    counter(figure.where(kind: image)).update(0)

    set par(
      leading: 1em,
      first-line-indent: (
        amount: 0cm,
        all: false,
      ),
    )

    set text(size: 1.5em)

    v(2.5cm)
    if it.numbering != none {
      [
        Chapter #counter(heading).display()


        #text(size: 1.2em, it.body)
      ]
    } else { it }

    v(0.5cm)
  }
  
  set math.equation(numbering: "(1)")

  set ref(supplement: it => {
    if it.func() == heading {
      "Chapter"
    } else {
      it.supplement
    } 
  })
  
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
    } else {
      // Other references as usual.
      it
    }
  }

  show figure: set block(breakable: true)
  show figure: it => {
    v(2em)
    it
    v(2em)
  }
  show figure.where(kind: table): it => {
    align(center)[
      TABLE #it.counter.display("1") \
      #it.caption.body
    ]

    align(center, it.body)
  }
  
  // Image figures: "Fig. 1.1. Caption" — mirrors LaTeX
  // \captionsetup[figure]{name={Fig.}, labelsep=period} with
  // \counterwithin{figure}{chapter}.
  show figure.where(kind: image): set figure(supplement: "Fig.")
  show figure.where(kind: image): set figure.caption(separator: ". ")
  show figure.where(kind: image): set figure(numbering: n => {
    let chapter = counter(heading.where(level: 1)).at(here()).first()
    [#chapter.#n]
  })
  show figure.caption: it => {
    set align(left)
    it
  }
  
  set outline(indent: auto)

  show raw.where(block: true): block.with(
    fill: luma(249),
    inset: 10pt,
    radius: 2pt,
    stroke: 1pt,
  )


  body
}

#let numbering(body) = {
  set page(numbering: "1")
  // Mirror LaTeX template's default secnumdepth=2: chapter (level 1),
  // section (level 2), and subsection (level 3) are numbered;
  // subsubsection (level 4) and below are not.
  set heading(
    numbering: (..nums) => {
      if nums.pos().len() > 3 {
        return
      }
      nums.pos().map(str).join(".")
    }
  )

  body
}