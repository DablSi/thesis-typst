= Conclusion

Code LLMs produce hallucinations that are hard to detect. Uncertainty quantification can flag likely failures before they reach production, but research on UQ for code is fragmented: studies use different benchmarks, models, and metrics, so cross-study comparisons are hard. This thesis evaluated thirteen unsupervised uncertainty estimators on HumanEval, on two open-source code LLMs of similar size — DeepSeek-Coder-6.7B-Instruct and Qwen2.5-Coder-7B-Instruct.

All thirteen estimators share the same greedy completion per problem, so pass\@1 is identical across methods (68.9% on DeepSeek, 72.6% on Qwen) and PRR scores reflect only uncertainty quality, not differences in model capability.

== Key findings
The best lm-polygraph methods transfer well from natural language to code: SAR reaches PRR 0.83 on DeepSeek, and MSP and CCP reach 0.86 on Qwen, both above functional clustering. Which family leads depends on the model. Sample-diversity methods (SAR, ROUGE-L, DegMat-Jaccard, BLEU) take the top four spots on DeepSeek; information-theoretic methods (MSP, CCP, Perplexity, TokenSAR) take the top four on Qwen. No single category wins on both. Functional clustering with LLM-generated test inputs ranks fifth on both models (PRR 0.80 on DeepSeek, 0.84 on Qwen) — competitive with the best lm-polygraph methods but not above them. Symbolic clustering ranks last on both models (PRR 0.55–0.74) because CrossHair times out and merges most completions into a single cluster, so the score cannot tell correct from incorrect outputs apart.

== Contributions
- A shared-inference pipeline that gives identical pass\@1 across all thirteen UQ methods on two code LLMs, so PRR comparisons are not affected by differences in model capability.
- A correction to the public functional-clustering reference implementation, which used HumanEval's own assertions as test inputs instead of generating them via the LLM as @Ravuri2025EliminatingHE describes. With independent inputs, PRR drops from ~0.87 to ~0.80 on DeepSeek, so part of the earlier advantage came from reusing the evaluation tests.
- The first direct comparison via PRR and PR-AUC of the top lm-polygraph estimators against execution-based clustering on a shared code benchmark, which shows that the ranking depends on the model.

== Limitations
The study uses one benchmark (HumanEval) and two relatively old (circa 2024) models @deepseek-coder @qwen-coder of similar size (\~7B). Symbolic clustering is run at one CrossHair budget (10 seconds per condition); a larger budget would reduce how often all completions end up in one cluster. NLI-augmented methods (CCP, SAR, TokenSAR, DegMat-NLI) use DeBERTa, which is trained on natural-language inference and only approximates semantic agreement on code. Pass\@1 is computed from greedy decoding only; temperature-calibrated sampling and unbiased pass\@k were not explored.

== Future work
Extending the benchmark to other datasets (MBPP, LiveCodeBench, HumanEval-X) and to models of different sizes would test how well these rankings generalise. A larger CrossHair budget could improve symbolic clustering performance. The split between sample-diversity and information-theoretic methods across the two models suggests that hybrid scores combining token-level and execution-level signals may do better than either family alone.
