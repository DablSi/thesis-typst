= Introduction

Large Language Models (LLMs) are increasingly used to generate code. The Stack Overflow Developer Surveys @stackoverflow_survey show adoption rising from 43.8% to 78.5% between 2023 and 2025, while the share of developers who distrust AI accuracy grew from 27.2% to 45.7% over the same period (@stack2). The 2025 survey reports that 87% of respondents are concerned about the accuracy of LLM output.

// #figure(
//   image("stackoverflow_graph1.png", width: 90%),
//   caption: [AI Adoption in Software Development (2023-2025) @stackoverflow_survey],
// ) <stack1>

#figure(
  image("../../figures/stackoverflow_graph2.png"),
  caption: [Developer Trust in AI Accuracy (2023-2025) @stackoverflow_survey],
) <stack2>

Developers are relying more on tools they trust less. The root cause is LLM hallucinations: models produce plausible but incorrect code. Uncertainty Quantification (UQ) methods can detect when a model is likely wrong, flagging suspicious outputs before they reach production. Most existing UQ methods were developed for natural language and do not transfer well to code. Recent studies @sharma2025assessingcorrectnessllmbasedcode @Ravuri2025EliminatingHE show that standard text-similarity and token-probability methods have no statistically significant correlation with code correctness, while methods that run generated programs perform far better. These findings are discussed more thoroughly in the Literature Review.

For natural language tasks, like question answering, UQ methods are already compared systematically through the LM-Polygraph benchmark @lm-polygraph2025. For code, no equivalent benchmark exists. Research is fragmented: different studies use different models, tasks, and metrics.

This thesis aims to fill that gap with two objectives:

- *First*, to evaluate the best-performing unsupervised lm-polygraph methods on code generation and determine how well they transfer from natural language.
- *Second*, to compare them against code-specific execution-based methods (functional clustering @Ravuri2025EliminatingHE and symbolic clustering @sharma2025assessingcorrectnessllmbasedcode) on a shared benchmark.

The goal is a direct, quantitative answer to which UQ strategies work for code.