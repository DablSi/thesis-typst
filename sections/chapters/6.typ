= Results

// This section presents experimental results. Brief observations accompany each
// table and plot; interpretation and discussion belong in a separate Discussion section.

== Pass\@1

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Model*], [*pass\@1*], [*pass\@10*]),
    [DeepSeek-Coder-6.7B-Instruct], [0.689 (0.718 unbiased)], [0.927],
    [Qwen2.5-Coder-7B-Instruct],    [0.726 (0.753 unbiased)], [0.957],
  ),
  caption: [Pass\@k on HumanEval (164 problems). All thirteen uncertainty methods share an identical pass\@1 per model by construction. Raw pass\@1 is the fraction of problems solved; unbiased is the standard estimator.]
)

== PRR and PR-AUC

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Method*], [*PRR*], [*PR-AUC*]),
    [SAR],                                [0.8325], [0.5431],
    [Lexical Similarity ROUGE-L],         [0.8299], [0.5854],
    [DegMat Jaccard],                     [0.8103], [0.5483],
    [Lexical Similarity BLEU],            [0.8081], [0.5280],
    [Functional Clustering SE],           [0.8038], [0.6068],
    [Functional Clustering CC],           [0.8034], [0.5935],
    [Claim-Conditioned Probability],      [0.7751], [0.5832],
    [Maximum Sequence Probability],       [0.7608], [0.5553],
    [Perplexity],                         [0.7386], [0.4389],
    [TokenSAR],                           [0.7373], [0.4378],
    [DegMat NLI],                         [0.7285], [0.3449],
    [Symbolic Clustering SE],             [0.5968], [0.3120],
    [Symbolic Clustering CC],             [0.5520], [0.2954],
  ),
  caption: [PRR and PR-AUC for all thirteen uncertainty scores on DeepSeek-Coder-6.7B-Instruct, sorted by PRR. All methods share pass\@1 = 68.9%.]
) <deepseek_prr>

On DeepSeek, the top four methods are lm-polygraph sample-diversity methods: SAR (0.833), ROUGE-L (0.830), DegMat-Jaccard (0.810), and BLEU (0.808). Functional clustering CC and SE rank fifth and sixth at PRR ~0.80, competitive with but no longer above the best lm-polygraph methods. Information-based methods (CCP, MSP, Perplexity, TokenSAR) fall in the 0.73–0.78 range. DegMat-NLI ranks eleventh. Symbolic clustering ranks last at PRR 0.55–0.60 and PR-AUC below 0.32.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Method*], [*PRR*], [*PR-AUC*]),
    [Maximum Sequence Probability],       [0.8586], [0.5570],
    [Claim-Conditioned Probability],      [0.8581], [0.6433],
    [Perplexity],                         [0.8402], [0.4521],
    [TokenSAR],                           [0.8399], [0.4483],
    [Functional Clustering SE],           [0.8359], [0.4004],
    [Functional Clustering CC],           [0.8352], [0.3905],
    [Lexical Similarity BLEU],            [0.8182], [0.4566],
    [Lexical Similarity ROUGE-L],         [0.8180], [0.4800],
    [DegMat Jaccard],                     [0.8138], [0.4421],
    [SAR],                                [0.7996], [0.4368],
    [DegMat NLI],                         [0.7971], [0.3968],
    [Symbolic Clustering CC],             [0.7352], [0.3109],
    [Symbolic Clustering SE],             [0.7109], [0.3381],
  ),
  caption: [PRR and PR-AUC for all thirteen uncertainty scores on Qwen2.5-Coder-7B-Instruct, sorted by PRR. All methods share pass\@1 = 72.6%.]
) <qwen_prr>

On Qwen, information-based lm-polygraph methods lead: MSP (0.859) and CCP (0.858) rank first and second, followed by Perplexity and TokenSAR (both 0.840). Functional clustering CC and SE rank fifth and sixth at PRR ~0.836, ahead of all sample-diversity lm-polygraph methods (BLEU, ROUGE-L, DegMat-Jaccard, SAR) but behind the top four. DegMat-NLI ranks eleventh. Symbolic clustering ranks last at PRR 0.71–0.74, considerably higher than on DeepSeek.

=== Prediction-Rejection Curves

#figure(
  image("../../figures/prr_curves_deepseek.png", width: 80%),
  caption: [Prediction-rejection curves for all methods on DeepSeek-Coder-6.7B-Instruct.]
)

#figure(
  image("../../figures/prr_curves_qwen.png", width: 80%),
  caption: [Prediction-rejection curves for all methods on Qwen2.5-Coder-7B-Instruct.]
)

// TODO: insert saved plots from calculate_prr.py

=== Precision-Recall Curves

#figure(
  image("../../figures/pr_curves_deepseek.png", width: 80%),
  caption: [Precision-recall curves (failure detection) for all methods on DeepSeek-Coder-6.7B-Instruct.]
)

#figure(
  image("../../figures/pr_curves_qwen.png", width: 80%),
  caption: [Precision-recall curves for all methods on Qwen2.5-Coder-7B-Instruct.]
)

// TODO: insert saved plots from calculate_prr.py

== Symbolic Clustering: Cluster Distribution

On DeepSeek, 108 out of 164 problems (65.9%) had all 10 completions merged into a single cluster (CC = 0, SE = 0); only 56 (34.1%) had more than one cluster. Mean CC across all problems was 0.086 and mean SE was 0.219. Functional clustering produces a wider spread because concrete test inputs can distinguish functions that CrossHair's bounded search cannot.

Symbolic clustering therefore assigns near-zero uncertainty to most problems, including many that are incorrect. When most problems receive the same score, the method cannot separate correct from incorrect predictions, which explains its low PRR and PR-AUC.

// TODO: add Qwen cluster distribution when available

== Summary

Functional clustering ranks fifth on both models (PRR 0.80 on DeepSeek, 0.84 on Qwen), competitive with the best lm-polygraph methods but no longer above them. The lm-polygraph ranking differs across models: sample-diversity methods lead on DeepSeek (SAR, ROUGE-L, DegMat-Jaccard), information-based methods lead on Qwen (MSP, CCP, Perplexity). DegMat-NLI ranks near the bottom on both. Symbolic clustering ranks last, with higher absolute PRR on Qwen (0.71–0.74) than DeepSeek (0.55–0.60).
