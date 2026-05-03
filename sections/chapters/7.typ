= Discussion

== Symbolic Clustering Timeout Sensitivity

Symbolic clustering ranked last despite strong results reported in @sharma2025assessingcorrectnessllmbasedcode. The cause is CrossHair's bounded search: with a 10-second per-condition timeout, CrossHair could not find counterexamples for most function pairs on HumanEval, and absent a counterexample the pair was merged. As a result, 65.9% of problems had all completions in a single cluster (CC = 0, SE = 0), leaving the method unable to separate correct from incorrect predictions.

@sharma2025assessingcorrectnessllmbasedcode reports $r = -0.40$ to $-0.56$ ($p < 0.001$), but on different models, different problems, and possibly longer timeouts. HumanEval functions often involve complex types (nested lists, dictionaries, strings with special characters) that make symbolic path exploration expensive. A longer timeout would likely improve cluster quality, but at substantial cost: the current 7,380 calls already take several hours.

This does not invalidate the method. It shows that performance depends on the timeout budget and function complexity: when CrossHair has time to explore paths, it can detect differences that concrete tests miss; when it times out, it defaults to merging everything.

== Functional Clustering with LLM-Generated Test Inputs

Running with LLM-generated test inputs (as @Ravuri2025EliminatingHE describes, not as the reference implementation did) dropped functional clustering's PRR from ~0.87 to ~0.80 on DeepSeek and ~0.84 on Qwen. The magnitude of the drop shows how much of the earlier score came from test-data overlap rather than the method's own signal.

Fairly compared, functional clustering remains competitive but no longer dominates. By PRR it ranks fifth on both models, behind sample-diversity methods on DeepSeek (SAR, ROUGE-L) and information-based methods on Qwen (MSP, CCP). By PR-AUC the picture is model-dependent: it ranks first and second on DeepSeek, but ninth to eleventh on Qwen. Execution-based clustering provides signal comparable to the better black-box estimators when test inputs are independent of the evaluation criterion.

== PR-AUC and PRR Disagree <metric_disagreement>

The two metrics measure different aspects of an uncertainty estimator. PRR depends on the full ranking of problems by uncertainty: it is the area between the rejection curve and the random baseline, normalised against the oracle. PR-AUC aggregates precision across recall thresholds, so it depends on whether incorrect predictions receive higher uncertainty than correct ones, not on the order within each group.

Score distribution drives the disagreement. Cluster-based estimators such as functional clustering CC and SE produce few distinct values, bounded by $N = 10$, and many problems share the same score. Ties depress PRR, since tied problems cannot be ordered against each other, but they do not affect PR-AUC if the tied scores fall on the correct side of the threshold. Continuous estimators such as ROUGE-L exhibit the opposite trade-off: smooth rankings yield strong PRR, while the precision-recall trade-off can be flatter. On DeepSeek, SAR ranks first by PRR (0.833) but seventh by PR-AUC (0.543), while functional clustering SE ranks first by PR-AUC (0.607) and fifth by PRR (0.804).

The two metrics suit different settings. PRR fits use cases where uncertainty is used to rank candidates, such as a review queue. PR-AUC fits use cases where failures are flagged at a fixed threshold, such as deployment.