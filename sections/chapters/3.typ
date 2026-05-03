= Literature Review

== UQ Method Categories

The LM-Polygraph benchmark @lm-polygraph2025 evaluates 29 UQ methods on natural language generation and organises them into four categories:

- *Information-Theoretic:* compute uncertainty from the model's token-level probability distribution. Examples include Maximum Sequence Probability, Perplexity, and Mean Token Entropy @Fomicheva.
- *Sample Diversity:* generate multiple completions for the same prompt and measure their disagreement. Consistent outputs indicate higher confidence. Examples include Semantic Entropy @kuhn2023semanticuncertaintylinguisticinvariances, Degree Matrix, and Sum of Eigenvalues of the Graph Laplacian @lin2024generatingconfidenceuncertaintyquantification.
- *Density-based:* compare a generated output's embedding against a reference distribution of correct examples. Outputs far from the distribution are flagged as uncertain. Examples are Mahalanobis distance (MD) @lee2018simpleunifiedframeworkdetecting and Robust density estimation (RDE) @yoo-etal-2022-detection.
- *Reflexive:* ask the model to evaluate its own confidence directly (e.g. "Are you certain about your last response?"). The $p("True")$ method @kadavath2022languagemodelsmostlyknow is an example.

Each category comes with its strengths and weaknesses (according to @lm-polygraph2025):

#figure(
  table(
    columns: (auto, 1.5fr, auto, 2.5fr, 2.5fr),
    align: (left, center, center, left, left),

    table.header(
      [*Category*], [*Access*], [*Compute*], [*Strengths*], [*Weaknesses*]
    ),

    [_Information-Theoretic_],
    [White-Box],
    [Low],
    [Fast, theoretically grounded, provides token-level scores.],
    [Requires internal model access. Can be naive to semantic meaning.],

    [_Sample Diversity_],
    [Black-Box],
    [High],
    [Model-agnostic. Captures semantic uncertainty.],
    [Requires generating many outputs. Clustering can be complex and slow.],

    [_Density-Based_],
    [Black-Box],
    [Medium],
    [Good at detecting outputs that are structurally or stylistically unusual],
    [Requires a high-quality reference dataset: performance depends heavily on the embedding space],

    [_Reflexive_],
    [Black-Box],
    [Low],
    [Simple to implement],
    [Highly unreliable: models are often overconfident and poor at self-assessment],
  ),
  caption: [Comparison of Uncertainty Quantification Method Categories],
)<uq_taxonomy>

== Code Hallucination Taxonomies

Several recent works classify what goes wrong when LLMs generate code. Each proposes a different taxonomy, but the defects they describe overlap. Understanding these categories is relevant for UQ because different types of hallucinations are caught by different detection strategies.

*CodeMirage* @agarwal2025codemiragehallucinationscodegenerated collected 1,137 GPT-3.5-generated Python snippets from HumanEval and MBPP and annotated each for one of five defect types: logical errors (the code runs but solves the wrong problem), syntactic incorrectness (the code does not compile), dead or unreachable code (parts of the code serve no purpose), robustness issues (the code fails on edge cases or raises exceptions), and security vulnerabilities (the code has exploitable flaws or memory leaks). Each type appeared in roughly equal proportions in their dataset.

*HalluCode* @liu2024HalluCode takes a different angle, classifying defects by what the code conflicts with rather than their technical nature. It covers Python and Java tasks and defines three top-level categories with twelve subcategories. Requirement conflicting (39.60%) means the code does something other than what was asked, with behaviour conflicting (35.40%) as its largest subcategory. Knowledge hallucinations (34.90%) means the code contradicts real-world knowledge such as library APIs (25.99%) or algorithmic conventions. Code inconsistency (25.50%) means the code has internal contradictions like undefined variables or useless statements. They find that model-related factors cause 80.86% of hallucinations and that larger models hallucinate less.

*CodeHalu* @tian2025codehaluinvestigatingcodehallucinations focuses on the source of the error. Mapping hallucinations occur when the model incorrectly maps between the problem description and code variables or functions. Naming hallucinations use wrong identifiers. Resource hallucinations reference libraries or functions that do not exist. Logic hallucinations contain flawed algorithmic reasoning. These four categories are further divided into eight subcategories and verified by executing the generated code.

These taxonomies overlap but emphasise different aspects of the same underlying problem. @hallucination_taxonomy combines them into a unified overview:

#figure(
  table(
    columns: (auto, auto),
    align: left,

    table.header(
      [*Hallucination Types*],
      [*Description*],
    ),

    [
      - Logical Error @agarwal2025codemiragehallucinationscodegenerated
      - Intent Conflicting @liu2024HalluCode
      - Logic Hallucinations @tian2025codehaluinvestigatingcodehallucinations
    ],
    [The code is syntactically valid but fails to meet the problem's requirements or contains flawed logic.],

    [
      - Syntactic Incorrectness @agarwal2025codemiragehallucinationscodegenerated
      - Dead or Unreachable Code @agarwal2025codemiragehallucinationscodegenerated
      - Naming Hallucinations @tian2025codehaluinvestigatingcodehallucinations
      - Context Deviation @liu2024HalluCode
    ],
    [The code is malformed, uses wrong identifiers, contains non-functional or repetitive segments, or cannot be compiled.],

    [
      - Robustness Issue @agarwal2025codemiragehallucinationscodegenerated
    ],
    [The code compiles but fails at runtime on edge cases or lacks exception handling.],

    [
      - Security Vulnerabilities @agarwal2025codemiragehallucinationscodegenerated
      - Knowledge Conflicting @liu2024HalluCode
      - Mapping Hallucinations @tian2025codehaluinvestigatingcodehallucinations
      - Resource Hallucinations @tian2025codehaluinvestigatingcodehallucinations
    ],
    [The code misuses variables, external APIs, or libraries, or calls non-existent resources, leading to errors or security flaws.],
  ),
  caption: [Code Hallucination Taxonomy],
)<hallucination_taxonomy>

As @hallucination_taxonomy shows, code hallucinations are specific to the code domain. Methods from natural language generation (NLG) cannot be directly applied to code without adaptation.

== Evaluating Uncertainty Quantification Methods

Measuring UQ performance is a challenge in itself. Some of the approaches used in literature are:

- Rank correlation (i.e. Spearman's \ρ) between uncertainty scores and output quality metrics such as ROUGE or BLEU @Fomicheva @compareUQmetrics. This says little about practical performance, and n-gram metrics often miss semantic quality.
- Binary classification (correct vs. incorrect output) evaluated with AUROC or PR-AUC @lm-polygraph2025 @ling-etal-2024-uncertainty @compareUQmetrics. This requires an arbitrary correctness threshold, making cross-study comparison difficult.

This thesis uses both PR-AUC and the Prediction Rejection Ratio (PRR) @malinin2017prr, with PR-AUC as the primary metric. PRR is the standard in lm-polygraph @lm-polygraph2025 and earlier work @malinin2021uncertainty. Both are defined in @evaluation_metrics.


== Uncertainty Quantification for Code

UnCert-CoT @zhu2025uncertaintyguidedchainofthoughtcodegeneration uses token entropy to switch from direct generation to Chain-of-Thought reasoning when uncertainty is high. AdaDec @he2025adadec uses token-level entropy to pause decoding and rerank candidate tokens.

Token-level signals often fail for code because syntactically different programs can do the same thing. Recent work clusters outputs by behaviour rather than text.

Ravuri and Amarasinghe @Ravuri2025EliminatingHE propose _Functional Clustering_. They argue that text embeddings miss small errors, like a swapped operator, that break code. Their method generates programs and test inputs, runs them in a sandbox, and groups programs with identical input-output behaviour. The size of the largest group is the confidence score. On LiveCodeBench, this reduced error rates from ~65% to 2%, while token-probability scores could not reliably separate correct from incorrect outputs.

Sharma and David @sharma2025assessingcorrectnessllmbasedcode propose _Symbolic Clustering_, which goes beyond unit tests. Their method uses symbolic execution to treat inputs as abstract symbols and generate traces of the code's logic, grouping programs whose traces match. Testing several standard UQ approaches on code, they found Pearson correlations with correctness near zero: text-similarity methods reached $r = -0.04$ to $-0.21$ (all $p > 0.08$), and token log-probabilities $r = 0.09$ to $0.18$ ($p > 0.38$), none statistically significant. Only symbolic clustering achieved meaningful correlations ($r = -0.40$ to $-0.56$, $p < 0.001$), with a false positive rate below 0.02%.

Both @Ravuri2025EliminatingHE and @sharma2025assessingcorrectnessllmbasedcode are sample-diversity methods like Semantic Entropy @kuhn2023semanticuncertaintylinguisticinvariances, and are therefore computationally expensive.

Other approaches use classical code metrics as proxies: compiler feedback @wang2022compilableneuralcodegeneration, static code quality analysis @dolcetti2025helpingllmsimprovecode, and pass rates of generated unit tests @liu2025llmpoweredtestcasegeneration.
