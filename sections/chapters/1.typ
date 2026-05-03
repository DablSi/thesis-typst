= Introduction

Large Language Models (LLMs) are now widely used to generate code. The Stack Overflow Developer Surveys @stackoverflow_survey show adoption rising from 43.8% to 78.5% between 2023 and 2025, while the share of developers who distrust AI accuracy grew from 27.2% to 45.7% over the same period (@stack2). According to the 2025 survey @stackoverflow_survey, 87% of respondents are concerned about the accuracy of LLM outputs.

// #figure(
//   image("stackoverflow_graph1.png", width: 90%),
//   caption: [AI Adoption in Software Development (2023-2025) @stackoverflow_survey],
// ) <stack1>

#figure(
  image("../../figures/stackoverflow_graph2.png"),
  caption: [Developer Trust in AI Accuracy (2023-2025) @stackoverflow_survey],
) <stack2>

Developers are relying more on tools they trust less. The root cause for distrust is LLM hallucinations: models produce plausible but incorrect code. Uncertainty Quantification (UQ) methods can detect when a model is likely wrong, flagging suspicious outputs before they reach production. Nonetheless, most existing UQ methods were developed for natural language generation and do not transfer well to code. Recent studies @sharma2025assessingcorrectnessllmbasedcode @Ravuri2025EliminatingHE show that standard text-similarity and token-probability methods have no statistically significant correlation with code correctness, while methods that run the generated programs perform far better. More about this finding is discussed in the Literature Review.

For natural language tasks, like question answering, UQ methods are already compared systematically through the LM-Polygraph benchmark @lm-polygraph2025. Currently there is no such benchmark for code. Moreover, research in code UQ is mostly incomparable: different studies use different models, tasks, and metrics.

This thesis aims to fill that gap with two objectives:

- *First*, to evaluate the best-performing unsupervised lm-polygraph methods on code generation and determine how well they transfer from natural language.
- *Second*, to compare them against code-specific execution-based methods (functional clustering @Ravuri2025EliminatingHE and symbolic clustering @sharma2025assessingcorrectnessllmbasedcode) on a shared benchmark.

The goal is an honest quantitative answer to which UQ strategies work best for code.