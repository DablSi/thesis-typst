= Results

This chapter reports PR-AUC and PRR for thirteen unsupervised uncertainty methods on HumanEval, scored against three open-source code LLMs. The shared-inference pipeline from chapter 5 fixes pass\@1 across all thirteen methods on each model, so the numbers below reflect uncertainty quality and not generation quality. Per-model results appear in text and in two heatmaps. Full per-model tables are in @appendix_per_model. The cross-model aggregate in @aggregated is the main result and follows the mean-PRR convention from LM-Polygraph @Vashurin_2025.

== Pass\@k

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Model*], [*pass\@1*], [*pass\@10*]),
    [DeepSeek-Coder-6.7B-Instruct], [0.689], [0.927],
    [Qwen2.5-Coder-7B-Instruct],    [0.726], [0.957],
    [DeepSeek-Coder-1.3B-Instruct], [0.506], [0.8537],
  ),
  caption: [Pass\@k on HumanEval]
)

All thirteen uncertainty methods share pass\@1 per model by construction. The values match those reported in the original papers for each model. Pass\@1 also serves as a baseline. A method that cannot beat pass\@1 is no better than random guessing.

== Per-Model Summary

Top-ranked methods per model and metric are listed below. Full per-model PR-AUC and PRR numbers are in @appendix_per_model.

*DeepSeek-6.7B* (@deepseek_prr):
- PR-AUC: functional clustering SE and CC lead, followed by ROUGE-L and CCP.
- PRR: symbolic clustering SE and CC lead, followed by SAR, ROUGE-L, DegMat-Jaccard, and BLEU.
- Functional clustering wins PR-AUC but drops to seventh and eighth by PRR. Information-theoretic methods are mid-pack. DegMat-NLI is last on both.

*Qwen2.5-7B* (@qwen_prr):
- PR-AUC: CCP and MSP lead, followed by ROUGE-L and BLEU.
- PRR: MSP and CCP lead, followed by symbolic clustering SE and CC, then Perplexity and TokenSAR.
- Functional clustering inverts its DeepSeek result, ranking seventh by PRR and eleventh and thirteenth by PR-AUC. DegMat-NLI is near the bottom on both.

*DeepSeek-1.3B* (@deepseek_small_prr):
- PR-AUC: ROUGE-L and CCP lead, followed by MSP, DegMat-Jaccard, and SAR.
- PRR: sample-diversity methods lead. The top four are ROUGE-L, DegMat-Jaccard, BLEU, and SAR. Symbolic clustering SE and CC sit fifth and seventh.
- Functional clustering is last on both metrics by a wide margin, reversing its DeepSeek-6.7B position.

DeepSeek-1.3B sits in a different regime. Every method's PR-AUC is higher than on the larger models, and every method's PRR is lower. Class balance explains it. The PR-AUC random baseline equals the failure rate, which rises from \~0.28 on the larger models to 0.494 on DeepSeek-1.3B, so PR-AUC inflates. PRR is normalised against the oracle, and the oracle margin shrinks when the model is noisier, so PRR drops. Mean PRR is therefore the more reliable cross-model summary.

== Aggregated Across Models <aggregated>

LM-Polygraph @Vashurin_2025 ranks methods by mean PRR across LLMs. I follow the same convention and report the row-mean of each metric across the three models. Mean PRR is scale-invariant against pass\@1 because PRR is normalised against the oracle and random baselines. Mean PR-AUC is reported alongside, but its baseline tracks the failure rate, which differs across the three models, so only the ranking is comparable.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Method*], [*Mean PRR*], [*Mean PR-AUC*]),
    [Symbolic Clustering SE],             [0.7789], [0.4839],
    [Symbolic Clustering CC],             [0.7756], [0.4745],
    [Lexical Similarity ROUGE-L],         [0.7754], [0.5928],
    [Lexical Similarity BLEU],            [0.7600], [0.5461],
    [SAR],                                [0.7596], [0.5533],
    [DegMat Jaccard],                     [0.7595], [0.5584],
    [Claim-Conditioned Probability],      [0.7593], [0.6464],
    [Maximum Sequence Probability],       [0.7485], [0.5998],
    [TokenSAR],                           [0.7331], [0.5081],
    [Perplexity],                         [0.7320], [0.5098],
    [Functional Clustering SE],           [0.7066], [0.5254],
    [Functional Clustering CC],           [0.7063], [0.5166],
    [DegMat NLI],                         [0.6891], [0.4272],
  ),
  caption: [Mean PRR and mean PR-AUC across the three models, sorted by mean PRR]
) <mean_table>

The same ranking is shown in @mean_prr_bar. Symbolic clustering SE and CC lead by mean PRR, with ROUGE-L within a percentage point. CCP, MSP, and ROUGE-L lead by mean PR-AUC. ROUGE-L is the only method in the top three on both aggregates. CCP is first by mean PR-AUC but seventh by mean PRR. It separates correct from incorrect predictions at a single threshold without ranking the full set as cleanly. Functional clustering falls to eleventh and twelfth by mean PRR despite leading PR-AUC on DeepSeek-6.7B, pulled down by the DeepSeek-1.3B collapse.

#figure(
  image("/figures/mean_prr_bar.png"),
  caption: [Mean PRR across the three models, sorted descending. Each bar is the row-mean of @mean_table.]
) <mean_prr_bar>

== Heatmaps

The heatmaps show per-model PR-AUC and PRR alongside the cross-model mean. They make the DeepSeek-1.3B regime visible. Rows are uniformly brighter on PR-AUC and uniformly dimmer on PRR than on the two larger models, for the reasons given above. Exact per-model numbers are in @appendix_per_model. The per-category PR-AUC and PRR curves grouped by method family are in @appendix_curves.

#figure(
  image("/figures/pr_auc_heatmap.png"),
  caption: [PR-AUC heatmap across methods and models, with the Mean column]
) <pr_auc_heatmap>

#figure(
  image("/figures/prr_heatmap.png"),
  caption: [PRR heatmap across methods and models, with the Mean column]
) <prr_heatmap>

== Summary

No single method leads on every model. Per-model winners differ. Functional clustering wins on DeepSeek-6.7B by PR-AUC, CCP and MSP win on Qwen, ROUGE-L and CCP win on DeepSeek-1.3B. Averaging across models (@mean_table, @mean_prr_bar) gives a cleaner picture. Symbolic clustering SE and CC lead by mean PRR, ROUGE-L is within a percentage point, and CCP leads by mean PR-AUC. ROUGE-L is the only method in the top three on both aggregates. PR-AUC and PRR rank methods differently in every per-model table. @metric_disagreement explains why.
