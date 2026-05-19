= Introduction

Large Language Models (LLMs) are widely used to generate code. The Stack Overflow Developer Surveys @stackoverflow_survey show LLM adoption rising from 43.8% to 78.5% between 2023 and 2025. Yet the share of developers who distrust AI accuracy grew from 27.2% to 45.7% over the same period (@stack2).

#figure(
  image("../../figures/stackoverflow_graph2.png"),
  caption: [Developer Trust in AI Accuracy (2023-2025) @stackoverflow_survey],
) <stack2>

The root cause of distrust is LLM hallucinations: models produce plausible but incorrect code. Uncertainty Quantification (UQ) methods can detect when a model is likely wrong and flag suspicious outputs before they reach production. However, most existing UQ methods were developed for natural language generation and do not transfer well to code. Recent studies @sharma2025assessingcorrectnessllmbasedcode @Ravuri2025EliminatingHE show that standard text-similarity and token-probability methods have no statistically significant correlation with code correctness. In contrast, methods that run the generated programs perform far better.

For natural language tasks, such as question answering, UQ methods are systematically compared using the LM-Polygraph benchmark @Vashurin_2025. Currently, no such benchmark exists for code. Moreover, code UQ research is mostly incomparable: different studies use different models, tasks, and metrics.

This thesis aims to fill that gap with two objectives:

- *First*, to evaluate the best-performing unsupervised LM-Polygraph methods on code generation and determine how well they transfer from natural language.
- *Second*, to compare them against code-specific execution-based methods (functional clustering @Ravuri2025EliminatingHE and symbolic clustering @sharma2025assessingcorrectnessllmbasedcode) on a shared benchmark.

The goal is to obtain a quantitative answer to which UQ strategies work best for code.