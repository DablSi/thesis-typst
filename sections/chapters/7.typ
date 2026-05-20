= Discussion

== Symbolic Clustering Timeouts

Symbolic clustering ranks at or near the top by PRR on DeepSeek-6.7B and Qwen, but PR-AUC stays in the lower half. Averaged across the three models, symbolic clustering SE and CC also lead by mean PRR (@mean_table). The strong PRR depends on the optimised implementation described in @symbolic_clustering_section. With the naive subprocess-per-pair baseline, most pairs timed out within the 10-second budget and were merged by default. This collapsed nearly all completions into a single cluster, leaving symbolic clustering near the bottom. The optimisations keep the same timeout budget but let many more pairs reach a real CrossHair verdict, which is what produces the high PRR.

The gap between PRR and PR-AUC comes from symbolic clustering's score distribution. Results collapse into a small number of cluster sizes (bounded by $N = 10$), so many problems share the same score. These "ties" pull down PR-AUC at any fixed precision-recall threshold even when the ranking is strong. @metric_disagreement covers this in detail.

Symbolic clustering still works on DeepSeek-1.3B (PRR \~0.645, PR-AUC \~0.595) but no longer leads. A likely cause is that smaller models produce more diverse completions per problem, which weakens the clustering signal.

== Functional Clustering with LLM-Generated Test Inputs

Running with LLM-generated test inputs (as @Ravuri2025EliminatingHE describes, not as the reference implementation did) dropped functional clustering's PRR from \~0.87 to \~0.80 on DeepSeek and to \~0.84 on Qwen. The size of the drop shows how much of the earlier score came from test-data overlap rather than the method's own signal.

With the corrected test inputs, functional clustering is still competitive on the larger models but no longer dominates. By PR-AUC, it ranks first and second on DeepSeek-6.7B but eleventh and thirteenth on Qwen. By PRR, it ranks seventh and eighth on both \~7B models, behind sample-diversity methods on DeepSeek and information-theoretic methods on Qwen. On DeepSeek-1.3B the pattern inverts. Functional clustering ranks last on both metrics, four to five percentage points below every other method. Averaged across the three models, functional clustering falls to eleventh and twelfth by mean PRR (@mean_table), so the test-input correction takes it out of the top tier. The DeepSeek-1.3B collapse is again consistent with smaller models producing more diverse completions, which makes clustering less effective.

Execution-based clustering is therefore most useful at model scales where the LLM is competent enough to generate informative test inputs and similar completions.

== PR-AUC and PRR Disagree <metric_disagreement>

The two metrics measure different aspects of an uncertainty estimator. PRR depends on the full ranking of problems by uncertainty. It is the area between the rejection curve and the random baseline, normalised against the oracle. PR-AUC aggregates precision across recall thresholds, so it depends on whether incorrect predictions receive higher uncertainty than correct ones, not on the order within each group.

Cluster-based estimators (functional and symbolic clustering) produce few distinct values, bounded by $N = 10$, so many problems share the same score. Whether this hurts PRR or PR-AUC depends on how the tied scores align with correctness. If a single threshold cleanly separates correct from incorrect predictions, PR-AUC is high. If the ordering matches correctness on average but no single threshold is sharp, PRR is high while PR-AUC suffers. On DeepSeek-6.7B, functional clustering SE shows the first pattern. It ranks first by PR-AUC (0.607) but only seventh by PRR (0.804). Symbolic clustering SE shows the second. It ranks first by PRR (0.845) but eleventh by PR-AUC (0.428). Continuous estimators such as ROUGE-L produce smooth rankings with strong PRR and a flatter precision-recall trade-off.

#figure(
  image("/figures/prr_curves_grouped_deepseek_code-specific.png"),
  caption: [PRR curves for code-specific methods on DeepSeek-Coder-6.7B-Instruct]
) <ds67b_code_prr>

@ds67b_code_prr makes the disagreement visible. Symbolic clustering's rejection curve sits above functional clustering's across most of the coverage range even though functional clustering wins PR-AUC on the same model. The PR-AUC win comes from a single sharp threshold. The PRR win comes from a better full-set ordering.

The two metrics suit different settings. PRR fits use cases where uncertainty is used to rank candidate generations. PR-AUC fits use cases where failures are flagged at a fixed threshold, as in coding.
