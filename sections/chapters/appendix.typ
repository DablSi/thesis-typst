// Appendix: local overrides only, scoped via #[ ... ] so they do not leak
// into the bibliography that precedes.
#[
  // Map a 1-based chapter index to the letter "A", "B", ...
  // We avoid calling the stdlib `numbering` here because the template file
  // shadows that name with its own helper at template.typ:185.
  #let to-letter(n) = str.from-unicode(64 + n)

  // Reset the heading counter so the next "= ..." starts at 1, which we
  // then render as "A". The template's figure numbering reads from the
  // selector-scoped counter(heading.where(level: 1)), which is a separate
  // counter from counter(heading) — reset both.
  #counter(heading).update(0)
  #counter(heading.where(level: 1)).update(0)

  // Number headings as A, A.1, A.2, ...
  #set heading(numbering: (..n) => {
    let nums = n.pos()
    if nums.len() == 1 {
      to-letter(nums.at(0))
    } else if nums.len() > 3 {
      return
    } else {
      let parts = (to-letter(nums.at(0)),) + nums.slice(1).map(str)
      parts.join(".")
    }
  })

  // Render the level-1 heading as "Appendix A" instead of "Chapter 9".
  // Mirrors template.typ:69-83 but with a different prefix word.
  #show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    set par(leading: 1em, first-line-indent: (amount: 0cm, all: false))
    set text(size: 1.5em)
    v(2cm)
    if it.numbering != none {
      [
        Appendix #counter(heading).display()


        #text(size: 1.2em, it.body)
      ]
    } else { it }
    v(0.5cm)
  }

  // Number appendix figures as "A.1", "A.2", ...
  #show figure.where(kind: image): set figure(numbering: n => {
    let chap = counter(heading.where(level: 1)).at(here()).first()
    [#to-letter(chap).#n]
  })
  #show figure.where(kind: table): set figure(numbering: n => {
    let chap = counter(heading.where(level: 1)).at(here()).first()
    [#to-letter(chap).#n]
  })

  // The template renders the table label with `it.counter.display("1")`,
  // which forces numeric format and ignores the numbering function above.
  // Re-render in the same shape but honour the figure's numbering.
  #show figure.where(kind: table): it => {
    block(breakable: true, sticky: true, width: 100%)[
      #align(center)[
        TABLE #it.counter.display(it.numbering) \
        #it.caption.body
      ]
      #v(0.5em)
      #align(center, it.body)
    ]
  }

  = Appendices

  == Per-Model PR-AUC and PRR Tables <appendix_per_model>

  Full PR-AUC and PRR values for each method on each of the three models. The cross-model aggregates and visual summaries appear in chapter 6.

  #figure(
    table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      table.header([*Method*], [*PR-AUC*], [*PRR*]),
      [Functional Clustering SE],           [0.6068], [0.8038],
      [Functional Clustering CC],           [0.5935], [0.8034],
      [Lexical Similarity ROUGE-L],         [0.5854], [0.8299],
      [Claim-Conditioned Probability],      [0.5832], [0.7751],
      [Maximum Sequence Probability],       [0.5553], [0.7608],
      [DegMat Jaccard],                     [0.5483], [0.8103],
      [SAR],                                [0.5431], [0.8325],
      [Lexical Similarity BLEU],            [0.5280], [0.8081],
      [Perplexity],                         [0.4389], [0.7386],
      [TokenSAR],                           [0.4378], [0.7373],
      [Symbolic Clustering SE],             [0.4278], [0.8454],
      [Symbolic Clustering CC],             [0.4209], [0.8376],
      [DegMat NLI],                         [0.3449], [0.7285],
    ),
    caption: [PR-AUC and PRR on DeepSeek-Coder-6.7B-Instruct]
  ) <deepseek_prr>

  #figure(
    table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      table.header([*Method*], [*PR-AUC*], [*PRR*]),
      [Claim-Conditioned Probability],      [0.6433], [0.8581],
      [Maximum Sequence Probability],       [0.5570], [0.8586],
      [Lexical Similarity ROUGE-L],         [0.4800], [0.8180],
      [Lexical Similarity BLEU],            [0.4566], [0.8182],
      [Perplexity],                         [0.4521], [0.8402],
      [TokenSAR],                           [0.4483], [0.8399],
      [DegMat Jaccard],                     [0.4421], [0.8138],
      [SAR],                                [0.4368], [0.7996],
      [Symbolic Clustering SE],             [0.4268], [0.8460],
      [Symbolic Clustering CC],             [0.4083], [0.8455],
      [Functional Clustering SE],           [0.4004], [0.8359],
      [DegMat NLI],                         [0.3968], [0.7971],
      [Functional Clustering CC],           [0.3905], [0.8352],
    ),
    caption: [PR-AUC and PRR on Qwen2.5-Coder-7B-Instruct]
  ) <qwen_prr>

  #figure(
    table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      table.header([*Method*], [*PR-AUC*], [*PRR*]),
      [Lexical Similarity ROUGE-L],         [0.7131], [0.6784],
      [Claim-Conditioned Probability],      [0.7128], [0.6446],
      [Maximum Sequence Probability],       [0.6872], [0.6260],
      [DegMat Jaccard],                     [0.6849], [0.6545],
      [SAR],                                [0.6800], [0.6468],
      [Lexical Similarity BLEU],            [0.6537], [0.6538],
      [Perplexity],                         [0.6384], [0.6172],
      [TokenSAR],                           [0.6383], [0.6220],
      [Symbolic Clustering SE],             [0.5970], [0.6452],
      [Symbolic Clustering CC],             [0.5943], [0.6438],
      [Functional Clustering SE],           [0.5689], [0.4801],
      [Functional Clustering CC],           [0.5659], [0.4804],
      [DegMat NLI],                         [0.5398], [0.5417],
    ),
    caption: [PR-AUC and PRR on DeepSeek-Coder-1.3B-Instruct]
  ) <deepseek_small_prr>

  == Per-Category PR-AUC and PRR Curves <appendix_curves>

  These curves expand on the per-model summaries in chapter 6 by grouping methods into method families and plotting precision-recall and rejection curves for each family on each model.

  #figure(
    image("/figures/pr_curves_grouped_deepseek_code-specific.png"),
    caption: [Precision-recall curves for code-specific methods on DeepSeek-Coder-6.7B-Instruct]
  ) <ds67b_code_pr>

  On DeepSeek-6.7B, functional clustering achieves higher precision across a wide recall range than symbolic clustering, which is the source of its higher PR-AUC despite a lower PRR.

  #figure(
    image("/figures/prr_curves_grouped_qwen_information-theoretic.png"),
    caption: [PRR curves for information-theoretic methods on Qwen2.5-Coder-7B-Instruct]
  ) <qwen_info_prr>

  On Qwen, CCP and MSP provide stronger rejection across most coverage levels, consistent with their top PRR scores on this model.

  #figure(
    image("/figures/prr_curves_grouped_deepseek-1.3b_sample-diversity.png"),
    caption: [PRR curves for diversity-based methods on DeepSeek-Coder-1.3B-Instruct]
  ) <ds13b_div_prr>

  On DeepSeek-1.3B, lexical and structural diversity measures lead at moderate coverage levels, while functional clustering's PRR collapses (see also @deepseek_small_prr).
]
