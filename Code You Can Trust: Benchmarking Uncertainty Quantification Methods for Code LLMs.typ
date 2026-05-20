#import "template.typ": template, numbering

#set page(margin: 0pt)
#image("title.pdf", width: 100%, height: 100%)
#pagebreak()

// Title has its own styles that differ from the template. Therefore, we apply template only after title
#show: template

// Start page counter from here
// #counter(page).update(1)

#include "sections/contents.typ"
#include "sections/list/tables.typ"
#include "sections/list/figures.typ"
#include "sections/abstract.typ"

// Start numbering pages from the first chapter.
// Mirrors LaTeX template's \setcounter{page}{7}: Title=1, Contents=2-3,
// LoT=4, LoF=5, Abstract=6, Chapter 1=7. Adjust if front matter length changes.
// #counter(page).update(7)
#show: numbering

#include "sections/chapters/1.typ"
#include "sections/chapters/2.typ"
#include "sections/chapters/3.typ"
#include "sections/chapters/4.typ"
#include "sections/chapters/5.typ"
#include "sections/chapters/6.typ"
#include "sections/chapters/7.typ"
#include "sections/chapters/8.typ"

// Do the rest for other chapters:
// #include "sections/chapters/n.typ"

#include "sections/bibliography.typ"

#include "sections/chapters/appendix.typ"