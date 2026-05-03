= Conclusion

Code LLMs produce hallucinations that are hard to detect. Uncertainty quantification can flag likely failures before they reach production, but research on UQ for code is fragmented: studies use different benchmarks, models, and metrics, so cross-study comparisons are hard. This thesis evaluated thirteen unsupervised uncertainty estimators on HumanEval, on two open-source code LLMs of similar size: DeepSeek-Coder-6.7B-Instruct and Qwen2.5-Coder-7B-Instruct.

All thirteen estimators share the same greedy completion per problem, so pass\@1 is identical across methods (68.9% on DeepSeek, 72.6% on Qwen) and PR-AUC and PRR reflect only uncertainty quality, not differences in model capability.

== Key findings

By PR-AUC, no single method leads on both models. Functional clustering with LLM-generated test inputs ranks first and second on DeepSeek but ninth to eleventh on Qwen. CCP and MSP lead on Qwen and remain in DeepSeek's top four. ROUGE-L and CCP are the only methods in the top four by PR-AUC on both models.

By PRR, the leading family also differs by model: sample-diversity methods take the top four on DeepSeek (SAR, ROUGE-L, DegMat-Jaccard, BLEU), information-theoretic methods take them on Qwen (MSP, CCP, Perplexity, TokenSAR), with functional clustering fifth on both. The two metrics disagree systematically; @metric_disagreement attributes this to score-distribution differences across method families.

Symbolic clustering ranks last on both metrics and both models, because CrossHair times out and merges most completions into a single cluster, leaving the score unable to separate correct from incorrect outputs.

The compute cost of execution-based methods depends on the task: NP-hard problems or factorial-time solutions can produce extremely long runtimes. Timeouts bound this in practice, since both clustering methods fall back to merging on timeout. The trade-off is that each timeout collapses potentially distinct completions into one cluster, degrading UQ quality (symbolic clustering's last-place ranking is a direct consequence). Compute-heavy lm-polygraph methods have predictable cost but no equivalent escape, since partial computation does not return a usable uncertainty estimate.

== Contributions
- A shared-inference pipeline that gives identical pass\@1 across all thirteen UQ methods on two code LLMs, so PR-AUC and PRR comparisons are not affected by differences in model capability.
- A correction to the public functional-clustering reference implementation, which used HumanEval's own assertions as test inputs instead of generating them via the LLM as @Ravuri2025EliminatingHE describes. With independent inputs, PRR drops from ~0.87 to ~0.80 on DeepSeek, so part of the earlier advantage came from reusing the evaluation tests.
- The first direct comparison via PR-AUC and PRR of the top lm-polygraph estimators against execution-based clustering on a shared code benchmark, which shows that the ranking depends on the model.

== Limitations
The study uses one benchmark (HumanEval) and two \~7B models from circa 2024 @deepseek-coder @qwen-coder. Both receive the same prompt, adapted from the DeepSeek-Coder HumanEval evaluation protocol @deepseek-coder, which may favour DeepSeek. The evaluation covers only unsupervised methods, so supervised approaches such as HUQ-MD are not represented. All stochastic sampling uses $N = 10$ completions at temperature 1.0. Other temperatures, top-p settings, and unbiased pass\@k were not explored. No post-hoc calibration was applied to the uncertainty scores. Calibrating the scores (for example with temperature scaling on a held-out set @guo2017calibration) could improve absolute PR-AUC and PRR values, although the relative ranking of methods is expected to be less affected. Symbolic clustering runs at one CrossHair budget (10 seconds per condition). The NLI-augmented methods (CCP, SAR, TokenSAR, DegMat-NLI) rely on DeBERTa, trained on natural-language entailment, which only approximates semantic agreement on code.

== Future work
Extending the benchmark to other datasets (MBPP, LiveCodeBench, HumanEval-X) and to models of different sizes would test how well these rankings generalise. A larger CrossHair budget could improve symbolic clustering performance. The split between sample-diversity and information-theoretic methods across the two models suggests that hybrid scores combining token-level and execution-level signals may do better than either family alone.
