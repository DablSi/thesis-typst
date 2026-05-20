= Results

== Pass\@k

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Model*], [*pass\@1*], [*pass\@10*]),
    [DeepSeek-Coder-6.7B-Instruct], [0.689], [0.927],
    [Qwen2.5-Coder-7B-Instruct],    [0.726], [0.957],
    [DeepSeek-Coder-1.3B-Instruct], [0.506],                  [ 0.8537],
  ),
  caption: [Pass\@k on HumanEval]
)

All thirteen uncertainty methods share pass\@1 per model by construction. The resulting pass\@1 are similar to the results reported in the original papers for each model. Pass\@1 score also serves as a baseline for the uncertainty methods: a method that cannot beat pass\@1 is not useful for improving over random guessing.

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
    [Symbolic Clustering SE],             [0.4278], [0.8454],
    [Symbolic Clustering CC],             [0.4209], [0.8376],
    [DegMat NLI],                         [0.3449], [0.7285],
  ),
  caption: [PR-AUC and PRR on DeepSeek-Coder-6.7B-Instruct]
) <deepseek_prr>

On DeepSeek-6.7B, functional clustering SE and CC lead by PR-AUC (0.607 and 0.594), followed by ROUGE-L (0.585) and CCP (0.583). The PRR ordering is different: symbolic clustering SE and CC top the table (0.845 and 0.838), followed by SAR (0.833), ROUGE-L (0.830), DegMat-Jaccard (0.810), and BLEU (0.808). Functional clustering ranks first by PR-AUC but only seventh and eighth by PRR (\~0.80). Information-theoretic methods (CCP, MSP, Perplexity, TokenSAR) are mid-pack on both metrics. DegMat-NLI ranks last on both.

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

On Qwen, CCP (0.643) and MSP (0.557) lead by PR-AUC, followed by ROUGE-L (0.480) and BLEU (0.457). By PRR, MSP (0.859) and CCP (0.858) still hold the top two, followed by symbolic clustering SE and CC (\~0.846), then Perplexity and TokenSAR (\~0.840). Functional clustering inverts its DeepSeek result: seventh by PRR (\~0.836) and only eleventh and thirteenth by PR-AUC (0.39–0.40). DegMat-NLI ranks near the bottom on both metrics.

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

On DeepSeek-1.3B, ROUGE-L (0.713) and CCP (0.713) lead by PR-AUC, followed by MSP (0.687), DegMat-Jaccard (0.685), and SAR (0.680). The lower pass\@1 (50.6%) raises absolute PR-AUC across the board because failures are now the majority class. By PRR, sample-diversity methods take the top: ROUGE-L (0.678), DegMat-Jaccard (0.654), BLEU (0.654), SAR (0.647), with symbolic clustering SE and CC fifth and seventh (\~0.645). Functional clustering ranks last on both metrics by a wide margin (PRR \~0.480, PR-AUC \~0.567), reversing its position in DeepSeek-6.7B.

== PR-AUC and PRR Curves

To better understand the results, I have selected several PR-AUC and PRR plots.

#figure(
  image("/figures/pr_curves_grouped_deepseek_code-specific.png"),
  caption: [Precision-recall curves for code-specific methods on DeepSeek-Coder-6.7B-Instruct]
) <ds67b_code_pr>
#figure(
  image("/figures/prr_curves_grouped_deepseek_code-specific.png"),
  caption: [PRR curves for code-specific methods on DeepSeek-Coder-6.7B-Instruct]
) <ds67b_code_prr>

On DeepSeek-6.7B, code-specific methods behave differently across metrics. In  @ds67b_code_pr, functional clustering has higher precision over a wide recall range, leading to the best PR-AUC. In  @ds67b_code_prr, symbolic clustering achieves higher PRR. This shows that PR-AUC and PRR favor different behaviors.

#figure(
  image("/figures/prr_curves_grouped_qwen_information-theoretic.png"),
  caption: [PRR curves for information-theoretic methods on Qwen2.5-Coder-7B-Instruct]
) <qwen_info_prr>

On Qwen, information-theoretic methods perform best. In  @qwen_info_prr, claim-conditioned probability and maximum sequence probability provide better rejection across most coverage levels, consistent with their top PRR scores.

#figure(
  image("/figures/prr_curves_grouped_deepseek-1.3b_sample-diversity.png"),
  caption: [PRR curves for diversity-based methods on DeepSeek-Coder-1.3B-Instruct]
) <ds13b_div_prr>

On DeepSeek-1.3B, where pass\@1 is lower, diversity-based methods are stronger. In  @ds13b_div_prr, lexical and structural diversity measures have better rejection at moderate coverage. In contrast, functional clustering performs poorly in this setting (@deepseek_small_prr).

Overall, the curves support three points: PR-AUC and PRR rank methods differently, no method family is best on all models, and performance depends on model quality.

== Summary

No single method leads on all three models. By PR-AUC, functional clustering ranks first and second on DeepSeek-6.7B, CCP and MSP take those positions on Qwen, and ROUGE-L and CCP take them on DeepSeek-1.3B. ROUGE-L and CCP appear in the top four by PR-AUC on every model. By PRR, symbolic clustering is in the lead: top two on DeepSeek-6.7B (\~0.84) and third and fourth on Qwen (\~0.85). Functional clustering inverts across model sizes: top by PR-AUC on DeepSeek-6.7B, but last on DeepSeek-1.3B by both metrics. PR-AUC and PRR rank methods differently in every table. @metric_disagreement explains why.

#figure(
  image("/figures/pr_auc_heatmap.png"),
  caption: [PR-AUC heatmap across methods and models]
) <pr_auc_heatmap>

#figure(
  image("/figures/prr_heatmap.png"),
  caption: [PRR heatmap across methods and models]
) <prr_heatmap>