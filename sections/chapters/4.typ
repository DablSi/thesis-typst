= Methodology

== Models

The evaluation uses three open-source instruction-tuned code models: *DeepSeek-Coder-6.7B-Instruct* @deepseek-coder, *Qwen2.5-Coder-7B-Instruct* @qwen-coder, and *DeepSeek-Coder-1.3B-Instruct* @deepseek-coder. The two ~7B models control for parameter count across families but differ in training data and chat template format. I include the 1.3B DeepSeek-Coder variant to test whether rankings hold when model capability drops sharply (pass\@1 falls from 68.9% to 50.6% on HumanEval). I tried base model variants first, but they did not consistently recognize the task as code completion.

== Dataset

All experiments use *HumanEval* @humaneval, a benchmark of 164 Python programming problems. Each problem consists of a function signature with type annotations, a docstring with example input-output pairs, and a hidden unit test suite. The model receives only the stub (signature and docstring) and must generate the function body. Correctness is determined by running the completion against the unit tests.

The prompt wraps the stub in a fenced Python block with an instruction to complete it without modifying the given code, following DeepSeek's HumanEval protocol @deepseek-coder:

#block(fill: luma(245), inset: 12pt, radius: 4pt, width: 100%)[`Please continue to complete the function. You are not allowed to modify the given code and do the completion only. Please return all completed function in a codeblock. Here is the given code to do completion:`

\`\`\`python

{code}

\`\`\`]

== Uncertainty Estimation Methods

This evaluation covers only unsupervised methods, which produce uncertainty scores without any labaled calibration data. Supervised methods, such as those that fit a reference distribution of correct examples, are excluded. The reason is that training those methods is out of scope for this thesis.

Standard UQ methods from natural language generation transfer poorly to code. According to @sharma2025assessingcorrectnessllmbasedcode, text-similarity and token-probability approaches show no significant correlation with code correctness. Therefore, I pair the best-performing LM-Polygraph @Vashurin_2025 methods with execution-based methods that assess code behavior directly.

Thirteen uncertainty scores are evaluated in total: nine from the *LM-Polygraph* @Vashurin_2025 framework and four from two execution-based approaches, each producing two scores from the same cluster structure (cluster count and semantic entropy). @method_summary summarises them.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Method*], [*Category*], [*Access*], [*Compute*], [*Aux. Model*]
    ),
    [MSP],                    [Information-Theoretic], [White-box], [Low],  [No],
    [Perplexity @Fomicheva],             [Information-Theoretic], [White-box], [Low],  [No],
    [LexSim ROUGE-L @Fomicheva],         [Sample Diversity],      [Black-box], [High], [No],
    [LexSim BLEU @Fomicheva],            [Sample Diversity],      [Black-box], [High], [No],
    [DegMat Jaccard @lin2024generatingconfidenceuncertaintyquantification],         [Sample Diversity],      [Black-box], [High], [No],
    [CCP @ccp],                    [Information-Theoretic], [White-box], [High], [DeBERTa],
    [SAR @sar],                    [Sample Diversity],      [White-box], [High], [DeBERTa],
    [TokenSAR],               [Information-Theoretic], [White-box], [High], [DeBERTa],
    [DegMat NLI @lin2024generatingconfidenceuncertaintyquantification],             [Sample Diversity],      [Black-box], [High], [DeBERTa],
    [Functional Clustering @Ravuri2025EliminatingHE],  [Execution-based],       [Black-box], [High], [No],
    [Symbolic Clustering @sharma2025assessingcorrectnessllmbasedcode],    [Execution-based],       [Black-box], [High], [CrossHair],
  ),
  caption: [Summary of evaluated methods]
) <method_summary>

=== Method Selection

I selected the nine LM-Polygraph methods by ranking all unsupervised estimators in the framework by mean PRR across two models (Stable LM 2 12B and Mistral 7B v0.2) in the original benchmark @Vashurin_2025. The top ten by mean PRR were MSP, CCP, SAR, HUQ-MD, ROUGE-L, DegMat NLI, Perplexity, DegMat Jaccard, BLEU, and TokenSAR. I excluded HUQ-MD because it is supervised: it requires a reference distribution of correct examples to compute Mahalanobis distances. The remaining nine span the information-based and sample-diversity categories. Reflexive methods did not reach the top ten.

Then the picked methods are grouped by whether they require an auxiliary NLI model. The first group (MSP, Perplexity, Lexical Similarity, DegMat-Jaccard) operates without an auxiliary model. The second group (CCP, SAR, TokenSAR, DegMat-NLI) additionally uses DeBERTa for semantic agreement. The execution-based methods form a third group.

=== Non-NLI Methods

These methods use only token-level log-probabilities from a single greedy pass and $N = 10$ stochastic samples. No auxiliary model is required.

*Maximum Sequence Probability (MSP)* is the product of the greedy token probabilities:
$ U_"MSP" = 1 - \P(y | x)$, 
where $y$ is the generated sequence, and $x$ is the prompt.

*Perplexity* @Fomicheva normalizes MSP by sequence length, so scores are comparable across outputs of different lengths:
$ U_"PPL" = exp lr(( -1/L log p(x | y) )) $
Higher perplexity indicates higher uncertainty.

*Lexical Similarity* @Fomicheva methods measure consistency across samples. The mean overlap between the greedy completion and each of the $N$ stochastic samples is computed using ROUGE-L @rouge (longest common subsequence recall) and separately using BLEU @bleu (n-gram precision). A model that generates diverse completions for the same problem is considered more uncertain than those whose completions are consistent.

*Degree Matrix-Jaccard (DegMat-Jaccard)* @lin2024generatingconfidenceuncertaintyquantification measures consistency across all pairs of samples rather than against the greedy output. A graph is constructed with one node per sample and edge weights given by the Jaccard similarity of the two samples' token sets. The uncertainty score is derived from the spectral properties of the graph's degree matrix: similar completions give low spectral spread, diverse ones give high.

=== NLI Methods

These methods additionally pass pairs of completions through DeBERTa @deberta, a bidirectional transformer trained on natural language inference (NLI). Given two texts, it outputs probabilities for entailment, neutrality, and contradiction. Entailment probability serves as a proxy for semantic agreement between completions: an approximation when applied to code, but richer than token overlap.

*Claim-Conditioned Probability (CCP)* @ccp re-weights the greedy token probabilities using NLI entailment scores from the sampled alternatives. If many samples are semantically consistent with the greedy completion, their token probabilities are upweighted, lowering the uncertainty estimate.

*SAR (Semantic Answer Replacement)* @sar measures how sensitive the greedy output is to token substitution. For each token, semantically equivalent alternatives from the sampled completions are identified using DeBERTa, and the change in sequence probability from the substitution is recorded. Tokens whose replacement barely shifts probability are less informative, while load-bearing tokens shift it more. High average sensitivity indicates higher uncertainty.

*TokenSAR* @sar uses the same per-token sensitivities as SAR but weights each by its contribution to the overall sequence probability before aggregation.

*Degree Matrix-NLI (DegMat-NLI)* @lin2024generatingconfidenceuncertaintyquantification applies the same graph-based framework as DegMat-Jaccard but uses NLI entailment probability as the edge weight rather than Jaccard token overlap, capturing semantic rather than surface-level agreement.

=== Execution-Based Methods

Functional clustering and symbolic clustering use neither token probabilities nor text similarity. Instead, they generate $N = 10$ (in this experiment) stochastic completions per problem and group them by whether they produce the same behavior when executed. The assumption: a model producing behaviorally equivalent completions is more likely to be correct than one whose completions diverge.

Each method partitions the $N$ completions into equivalence classes, from which two uncertainty scores are computed. *Cluster Count (CC)* @sharma2025assessingcorrectnessllmbasedcode @Ravuri2025EliminatingHE is:
$ U_"CC" = 1 - (|C_"max"|) / N $
where $|C_"max"|$ is the size of the largest class. CC is zero when all completions are equivalent and approaches one when every completion is in its own class.

*Semantic Entropy (SE)* @kuhn2023semanticuncertaintylinguisticinvariances @sharma2025assessingcorrectnessllmbasedcode is the Shannon entropy of the cluster size distribution under a uniform prior:
$ U_"SE" = -sum_c (|c|)/N * log (|c|)/N $
SE is zero when all completions fall in one cluster and is maximized when they spread evenly across many. Sharma _et al._ @sharma2025assessingcorrectnessllmbasedcode shows that CC and SE produce comparable results when clustering is accurate. Both are reported for direct comparison.

Sharma _et al._ @sharma2025assessingcorrectnessllmbasedcode also propose Mutual Information (MI), which queries the model twice per problem with the second prompt formed by appending the first response to the original. MI is excluded here because it produces structurally different completions, which would make pass\@1 incomparable across methods.

The two execution-based methods use the same CC and SE formulas and differ only in how equivalence is determined.

*Functional Clustering*

Proposed by @Ravuri2025EliminatingHE, this method determines equivalence by running each completion on concrete test inputs and grouping completions that produce identical outputs on every input. Test inputs are generated by prompting the LLM itself given only the function signature, so the method is self-contained and works on benchmarks without ground-truth tests.

The limitation is that equivalence is tested only on a finite set of inputs. Two functions that agree on every provided input but differ elsewhere will be incorrectly merged, underestimating uncertainty.

*Symbolic Clustering*

Proposed by @sharma2025assessingcorrectnessllmbasedcode, this method determines equivalence using symbolic execution rather than concrete inputs. The goal is to find a counterexample (a concrete input on which two functions differ) by reasoning over all possible inputs at once.

This is done using CrossHair @crosshair, a Python symbolic execution engine with an SMT solver. For each of the $C^2_N = N(N-1)/2$ pairs of completions, CrossHair explores both functions' execution paths with symbolic inputs and asks whether any input assignment causes them to diverge. If one is found, the pair goes into separate clusters. If no counterexample is found before the timeout, the functions are declared equivalent and merged via union-find, which ensures transitivity: if $f_i equiv f_j$ and $f_j equiv f_k$, all three are placed in the same cluster.

The limitation is that symbolic execution is bounded: CrossHair explores paths only up to a configurable depth.

== Evaluation Metrics <evaluation_metrics>

Each method produces a scalar uncertainty score $u_i in RR$ and a binary correctness label $c_i in {0, 1}$ per problem, where $c_i = 1$ if the greedy completion passes all unit tests. Three metrics are reported.

*Pass\@1* is the fraction of problems solved:
$ "pass@1" = 1/M sum_(i=1)^M c_i, quad M = 164 $
All methods share the same greedy completions, so pass\@1 is identical across all thirteen scores for a given model. It shows model capability and can be used as a baseline for uncertainty estimation performance.

*Prediction Rejection Ratio (PRR)* @malinin2017prr measures how well uncertainty scores identify incorrect predictions. Problems are ranked by decreasing uncertainty and progressively removed. At each threshold, accuracy is computed on the remaining ones. PRR is the area between this curve and the random-rejection baseline (a horizontal line at pass\@1), normalised by the area between the oracle curve (which rejects all incorrect predictions first) and the same baseline:

$ "PRR" = ("AUC"_"uq" - "AUC"_"random") / ("AUC"_"oracle" - "AUC"_"random") $

$"PRR" = 1$ means perfect failure identification. $"PRR" = 0$ means random ranking. @prr shows the relationship between these curves.

#figure(
  image("../../figures/prr.png", width: 60%),
  caption: [Prediction-rejection curve explanation @Vashurin_2025],
) <prr>

*PR-AUC* is the area under the precision-recall curve, treating failures ($c_i = 0$) as the positive class and uncertainty as the detection score. Precision is the fraction of flagged predictions that are incorrect. Recall is the fraction of all incorrect predictions that are flagged. PR-AUC aggregates this trade-off across all thresholds.

PR-AUC is the primary metric of this thesis. The intended use of code UQ is a threshold decision: a generated function is flagged for review or accepted. PR-AUC measures the precision-recall trade-off at every threshold, while PRR measures the full ranking of problems by uncertainty, independent of any specific threshold. With pass\@1 of 0.689 and 0.726, failures are the minority class, where PR-AUC is preferred.

PRR is reported alongside because it is the standard metric in LM-Polygraph @Vashurin_2025 and most natural-language UQ work, and because it is scale-invariant against pass\@1 differences across models.
