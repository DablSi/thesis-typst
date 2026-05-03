= Methodology

== Models

The evaluation uses three open-source instruction-tuned models: *DeepSeek-Coder-1.3B-Instruct*, *DeepSeek-Coder-6.7B-Instruct* @deepseek-coder, and *Qwen2.5-Coder-7B-Instruct* @qwen-coder. The two larger models are ~7-billion-parameter models trained on code corpora and fine-tuned for instruction following. The DeepSeek-1.3B variant enables comparison of model size effects within the same architecture. Across the larger models, the focus is on controlling for parameter count while testing whether results generalise across model families; they differ in training data and chat template format. Base model variants were tried first but did not consistently recognise the task as code completion.

== Dataset

All experiments use *HumanEval* \@humaneval, a benchmark of 164 Python programming problems. Each problem consists of a function signature with type annotations, a docstring with example input-output pairs, and a hidden unit test suite. The model receives only the stub (signature and docstring) and must generate the function body. Correctness is determined by running the completion against the unit tests.

The prompt wraps the stub in a fenced Python block with an instruction to complete it without modifying the given code, following DeepSeek's HumanEval protocol @deepseek-coder:

#block(fill: luma(245), inset: 12pt, radius: 4pt, width: 100%)[`Please continue to complete the function. You are not allowed to modify the given code and do the completion only. Please return all completed function in a codeblock. Here is the given code to do completion:`

\`\`\`python

{code}

\`\`\`]

== Uncertainty Estimation Methods

This evaluation covers only unsupervised methods, which produce uncertainty scores without any labelled calibration data. Supervised methods, such as those that fit a reference distribution of correct examples, are excluded.

Standard UQ methods from natural language generation transfer poorly to code: text-similarity and token-probability approaches show no significant correlation with code correctness @sharma2025assessingcorrectnessllmbasedcode. The evaluation therefore pairs the best-performing lm-polygraph @lm-polygraph2025 methods with execution-based methods that assess behaviour directly.

Thirteen uncertainty scores are evaluated in total: nine from the *lm-polygraph* framework and four from two execution-based approaches, each producing two scores from the same cluster structure. @method_summary summarises them.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Method*], [*Category*], [*Access*], [*Compute*], [*Aux. Model*]
    ),
    [MSP],                    [Information-Theoretic], [White-box], [Low],  [No],
    [Perplexity],             [Information-Theoretic], [White-box], [Low],  [No],
    [LexSim ROUGE-L],         [Sample Diversity],      [Black-box], [High], [No],
    [LexSim BLEU],            [Sample Diversity],      [Black-box], [High], [No],
    [DegMat Jaccard],         [Sample Diversity],      [Black-box], [High], [No],
    [CCP],                    [Information-Theoretic], [White-box], [High], [DeBERTa],
    [SAR],                    [Sample Diversity],      [White-box], [High], [DeBERTa],
    [TokenSAR],               [Information-Theoretic], [White-box], [High], [DeBERTa],
    [DegMat NLI],             [Sample Diversity],      [Black-box], [High], [DeBERTa],
    [Functional Clustering],  [Execution-based],       [Black-box], [High], [No],
    [Symbolic Clustering],    [Execution-based],       [Black-box], [High], [CrossHair],
  ),
  caption: [Summary of evaluated methods. All methods except MSP and Perplexity use $N = 10$ stochastic completions. "Compute" reflects cost relative to a single greedy pass. Functional and symbolic clustering each produce two scores (CC and SE).]
) <method_summary>

=== Method Selection

The nine lm-polygraph methods were chosen by ranking all unsupervised estimators in the framework by mean PRR across two models (Stable LM 2 12B and Mistral 7B v0.2) in the original benchmark @lm-polygraph2025. The top ten by mean PRR were MSP, CCP, SAR, HUQ-MD, ROUGE-L, DegMat NLI, Perplexity, DegMat Jaccard, BLEU, and TokenSAR. HUQ-MD was excluded because it is supervised: it requires a reference distribution of correct examples to compute Mahalanobis distances. The remaining nine span the information-based and sample-diversity categories. Reflexive methods did not reach the top ten.

The remaining methods are grouped below by whether they require an auxiliary NLI model. The first group (MSP, Perplexity, Lexical Similarity, DegMat-Jaccard) operates directly on tokens and token probabilities. The second group (CCP, SAR, TokenSAR, DegMat-NLI) additionally uses DeBERTa for semantic agreement. The execution-based methods form a third group.

=== Token-Level Methods

These methods use only token-level log-probabilities from a single greedy pass and $N = 10$ stochastic samples. No auxiliary model is required.

*Maximum Sequence Probability (MSP)* is the product of the greedy token probabilities:
$ "MSP" = exp lr(( sum_t log p(x_t | x_{<t}, c) )) $
where $c$ is the prompt and $t$ indexes generated tokens. Higher MSP means higher per-token confidence and lower uncertainty.

*Perplexity* normalises MSP by sequence length so scores are comparable across outputs of different length:
$ "PPL" = exp lr(( -1/T sum_t log p(x_t | x_{<t}, c) )) $
Higher perplexity indicates higher uncertainty.

*Lexical Similarity* methods measure consistency across samples. The mean overlap between the greedy completion and each of the $N$ stochastic samples is computed using ROUGE-L \@rouge (longest common subsequence recall) and separately using BLEU \@bleu (n-gram precision). A model that generates diverse completions for the same problem is considered more uncertain than one whose completions are consistent.

*Degree Matrix-Jaccard (DegMat-Jaccard)* measures consistency across all pairs of samples rather than against the greedy output. A graph is constructed with one node per sample and edge weights given by the Jaccard similarity of the two samples' token sets. The uncertainty score is derived from the spectral properties of the graph's degree matrix @lin2024generatingconfidenceuncertaintyquantification: similar completions give low spectral spread, diverse ones give high.

=== NLI-Augmented Methods

These methods additionally pass pairs of completions through DeBERTa \@deberta, a bidirectional transformer trained on natural language inference (NLI). Given two texts, it outputs probabilities for entailment, neutrality, and contradiction. Entailment probability serves as a proxy for semantic agreement between completions: an approximation when applied to code, but richer than token overlap.

*Claim-Conditioned Probability (CCP)* \@ccp re-weights the greedy token probabilities using NLI entailment scores from the sampled alternatives. If many samples are semantically consistent with the greedy completion, its token probabilities are upweighted, lowering the uncertainty estimate.

*SAR (Semantic Answer Replacement)* \@sar measures how sensitive the greedy output is to token substitution. For each token, semantically equivalent alternatives from the sampled completions are identified using DeBERTa, and the change in sequence probability from the substitution is recorded. Tokens whose replacement barely shifts probability are less informative; load-bearing tokens shift it more. High average sensitivity indicates higher uncertainty.

*TokenSAR* \@sar uses the same per-token sensitivities as SAR but weights each by its contribution to the overall sequence probability before aggregation.

*Degree Matrix-NLI (DegMat-NLI)* applies the same graph-based framework as DegMat-Jaccard but uses NLI entailment probability as the edge weight instead of Jaccard token overlap @lin2024generatingconfidenceuncertaintyquantification, capturing semantic rather than surface agreement.

=== Execution-Based Methods

Functional clustering and symbolic clustering use neither token probabilities nor text similarity. Instead, they generate $N = 10$ stochastic completions per problem and group them by whether they produce the same behaviour when executed. The assumption: a model producing behaviourally equivalent completions is more likely to be correct than one whose completions diverge.

Each method partitions the $N$ completions into equivalence classes, from which two uncertainty scores are computed. *Cluster Count (CC)* is:
$ u_"CC" = 1 - (|C_"max"|) / N $
where $|C_"max"|$ is the size of the largest class. CC is zero when all completions are equivalent and approaches one when every completion is in its own class.

*Semantic Entropy (SE)* is the Shannon entropy of the cluster size distribution under a uniform prior:
$ u_"SE" = -sum_c (|c|)/N * log (|c|)/N $
SE is zero when all completions fall in one cluster and is maximised when they spread evenly across many. @sharma2025assessingcorrectnessllmbasedcode shows that CC and SE produce comparable results when clustering is accurate: the aggregation formula matters less than the quality of the equivalence relation. Both are reported for direct comparison.

@sharma2025assessingcorrectnessllmbasedcode also proposes Mutual Information (MI), which queries the model twice per problem with the second prompt formed by appending the first response to the original. MI is excluded here because its two-call inference setup produces structurally different completions, which would make pass\@1 incomparable across methods.

The two execution-based methods use the same CC and SE formulas and differ only in how equivalence is determined.

*Functional Clustering*

Proposed by @Ravuri2025EliminatingHE, this method determines equivalence by running each completion on concrete test inputs and grouping completions that produce identical outputs on every input. Test inputs are generated by prompting the LLM itself given only the function signature, so the method is self-contained and works on benchmarks without ground-truth tests.

The limitation is that equivalence is tested only on a finite set of inputs. Two functions that agree on every provided input but differ elsewhere will be incorrectly merged, underestimating uncertainty.

*Symbolic Clustering*

Proposed by @sharma2025assessingcorrectnessllmbasedcode, this method determines equivalence using symbolic execution rather than concrete inputs. The goal is to find a counterexample (a concrete input on which two functions differ) by reasoning over all possible inputs at once.

This is done using CrossHair \@crosshair, a Python symbolic execution engine backed by an SMT solver. For each of the $N(N-1)/2$ pairs of completions, CrossHair explores both functions' execution paths with symbolic inputs and asks whether any input assignment causes them to diverge. If one is found, the pair goes into separate clusters. If no counterexample is found before the timeout, the functions are declared equivalent and merged via union-find, which ensures transitivity: if $f_i equiv f_j$ and $f_j equiv f_k$, all three are placed in the same cluster.

The limitation is that symbolic execution is bounded: CrossHair explores paths only up to a configurable depth. Functions equivalent at shallow depth but diverging at deeper paths may be incorrectly merged.

== Evaluation Metrics <evaluation_metrics>

Each method produces a scalar uncertainty score $u_i in RR$ and a binary correctness label $c_i in {0, 1}$ per problem, where $c_i = 1$ if the greedy completion passes all unit tests. Three metrics are reported.

*Pass\@1* is the fraction of problems solved:
$ "pass@1" = 1/M sum_(i=1)^M c_i, quad M = 164 $
All methods share the same greedy completion, so pass\@1 is identical across all thirteen scores for a given model. It characterises model capability rather than uncertainty estimation quality.

*Prediction Rejection Ratio (PRR)* @malinin2017prr measures how well uncertainty scores identify incorrect predictions. Problems are ranked by decreasing uncertainty and progressively withheld; at each threshold, accuracy is computed on the remaining ones. PRR is the area between this curve and the random-rejection baseline (a horizontal line at pass\@1), normalised by the area between the oracle curve (which rejects all incorrect predictions first) and the same baseline:

$ "PRR" = ("AUC"_"uq" - "AUC"_"random") / ("AUC"_"oracle" - "AUC"_"random") $

PRR = 1 means perfect failure identification; PRR = 0 means random ranking. @prr illustrates the relationship between these curves.

#figure(
  image("../../figures/prr.png", width: 60%),
  caption: [Prediction-rejection curve schematic: oracle, uncertainty estimator, and random baseline @lm-polygraph2025.],
) <prr>

*PR-AUC* is the area under the precision-recall curve, treating failures ($c_i = 0$) as the positive class and uncertainty as the detection score. Precision is the fraction of flagged predictions that are incorrect; recall is the fraction of all incorrect predictions that are flagged. PR-AUC aggregates this trade-off across all thresholds.

PR-AUC is the primary metric of this thesis. The intended use of code UQ is a threshold decision: a generated function is flagged for review or accepted. PR-AUC measures the precision-recall trade-off at every threshold, while PRR measures the full ranking of problems by uncertainty, independent of any specific threshold. With pass\@1 of 0.689 and 0.726, failures are the minority class, where PR-AUC is preferred over ROC-based measures.

PRR is reported alongside because it is the standard metric in lm-polygraph @lm-polygraph2025 and most natural-language UQ work, and because it is scale-invariant against pass\@1 differences across models. The two metrics can disagree: methods with coarse uncertainty scores (those taking only a few distinct values, as in cluster-based methods where the score is determined by cluster count or size) can score high on PR-AUC while ranking lower on PRR. @metric_disagreement examines this divergence.
