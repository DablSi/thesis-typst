= Results

== Pass\@1

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Model*], [*pass\@1*], [*pass\@10*]),
    [DeepSeek-Coder-6.7B-Instruct], [0.689 (0.718 unbiased)], [0.927],
    [Qwen2.5-Coder-7B-Instruct],    [0.726 (0.753 unbiased)], [0.957],
  ),
  caption: [Pass\@k on HumanEval (164 problems). All thirteen uncertainty methods share pass\@1 per model by construction. Unbiased pass\@1 is the standard estimator.]
)

== PR-AUC and PRR

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
    [DegMat NLI],                         [0.3449], [0.7285],
    [Symbolic Clustering SE],             [0.3120], [0.5968],
    [Symbolic Clustering CC],             [0.2954], [0.5520],
  ),
  caption: [PR-AUC and PRR for all thirteen uncertainty scores on DeepSeek-Coder-6.7B-Instruct, sorted by PR-AUC. All methods share pass\@1 = 68.9%.]
) <deepseek_prr>

On DeepSeek, functional clustering SE and CC lead by PR-AUC (0.607 and 0.594), followed by ROUGE-L (0.585) and CCP (0.583). The PRR ordering is different: the top four are sample-diversity methods (SAR 0.833, ROUGE-L 0.830, DegMat-Jaccard 0.810, BLEU 0.808), with functional clustering CC and SE fifth and sixth at PRR ~0.80. Information-theoretic methods (CCP, MSP, Perplexity, TokenSAR) are mid-pack on both metrics. DegMat-NLI ranks eleventh on both. Symbolic clustering is last on both metrics, with PRR 0.55–0.60 and PR-AUC below 0.32.

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
    [Functional Clustering SE],           [0.4004], [0.8359],
    [DegMat NLI],                         [0.3968], [0.7971],
    [Functional Clustering CC],           [0.3905], [0.8352],
    [Symbolic Clustering SE],             [0.3381], [0.7109],
    [Symbolic Clustering CC],             [0.3109], [0.7352],
  ),
  caption: [PR-AUC and PRR for all thirteen uncertainty scores on Qwen2.5-Coder-7B-Instruct, sorted by PR-AUC. All methods share pass\@1 = 72.6%.]
) <qwen_prr>

On Qwen, CCP (0.643) and MSP (0.557) lead by PR-AUC, followed by ROUGE-L (0.480) and BLEU (0.457). The PRR top four are also information-theoretic methods (MSP 0.859, CCP 0.858, Perplexity 0.840, TokenSAR 0.840). Functional clustering ranks fifth and sixth by PRR (~0.836) but only ninth to eleventh by PR-AUC (0.39–0.40), the opposite of its DeepSeek result. DegMat-NLI is near the bottom on both metrics. Symbolic clustering is last on both, with PRR 0.71–0.74 and PR-AUC 0.31–0.34.

=== Prediction-Rejection Curves

#figure(
  image("../../figures/prr_curves_deepseek.png", width: 80%),
  caption: [Prediction-rejection curves for all methods on DeepSeek-Coder-6.7B-Instruct.]
)

#figure(
  image("../../figures/prr_curves_qwen.png", width: 80%),
  caption: [Prediction-rejection curves for all methods on Qwen2.5-Coder-7B-Instruct.]
)

=== Precision-Recall Curves

#figure(
  image("../../figures/pr_curves_deepseek.png", width: 80%),
  caption: [Precision-recall curves (failure detection) for all methods on DeepSeek-Coder-6.7B-Instruct.]
)

#figure(
  image("../../figures/pr_curves_qwen.png", width: 80%),
  caption: [Precision-recall curves (failure detection) for all methods on Qwen2.5-Coder-7B-Instruct.]
)

== Symbolic Clustering: Cluster Distribution

On DeepSeek, 108 out of 164 problems (65.9%) had all 10 completions merged into a single cluster (CC = 0, SE = 0); only 56 (34.1%) had more than one cluster. Mean CC across all problems was 0.086 and mean SE was 0.219. Functional clustering produces a wider spread, because concrete test inputs can distinguish functions that CrossHair's bounded search cannot. @metric_disagreement discusses the consequences for PR-AUC and PRR.

// TODO: add Qwen cluster distribution when available

== Summary

No single method leads on both models. By PR-AUC, functional clustering ranks first and second on DeepSeek, while CCP and MSP take those positions on Qwen. ROUGE-L and CCP are the only methods in the top four by PR-AUC on both. By PRR, the four sample-diversity methods take the top spots on DeepSeek and the four information-theoretic methods take them on Qwen, with functional clustering fifth and sixth on both. Symbolic clustering ranks last by both metrics on both models. PR-AUC and PRR rank methods differently; @metric_disagreement explains why.
