= Conclusion

Code LLMs produce hallucinations that are difficult to detect. Uncertainty quantification can flag likely failures before they reach production. However, code UQ research is fragmented: studies use different benchmarks, models, and metrics, making cross-study comparisons difficult. This thesis evaluated thirteen unsupervised uncertainty estimators on HumanEval using three open-source code LLMs: DeepSeek-Coder-6.7B-Instruct, Qwen2.5-Coder-7B-Instruct, and DeepSeek-Coder-1.3B-Instruct.

All thirteen estimators share the same greedy completions per problem on each model. This ensures that pass\@1 (68.9% on DeepSeek-6.7B, 72.6% on Qwen, 50.6% on DeepSeek-1.3B) and the downstream PR-AUC and PRR reflect only uncertainty quality, not differences in model capability.

== Key findings

By PR-AUC, no single method leads on all three models. Functional clustering ranks first and second on DeepSeek-6.7B (0.607, 0.594) but last on DeepSeek-1.3B and only eleventh and thirteenth on Qwen. CCP and MSP lead Qwen (0.643, 0.557), while ROUGE-L and CCP lead DeepSeek-1.3B (0.713, 0.713). ROUGE-L and CCP are the only methods in the top four by PR-AUC on all three models.

By PRR, the rewritten symbolic clustering implementation enters the top tier on the larger models: first and second on DeepSeek-6.7B (0.845, 0.838) and third and fourth on Qwen (\~0.846). On DeepSeek-1.3B, sample-diversity methods hold the top four (ROUGE-L, DegMat-Jaccard, BLEU, SAR). PR-AUC and PRR rank methods differently in every table. @metric_disagreement explains why.

Model size matters. On DeepSeek-1.3B, functional clustering ranks last on both metrics, four to five percentage points below every other method. Smaller models produce more diverse completions per problem and less reliable LLM-generated test inputs. This collapses behaviorally distinct completions into the same cluster. Sample-diversity methods that read text overlap directly are robust to this shift and dominate at the smaller scale.

The compute cost of execution-based methods depends on the task: NP-hard problems or factorial-time solutions can produce extremely long runtimes. Timeouts bound this in practice, since both clustering methods fall back to merging on timeout. However, each timeout collapses potentially distinct completions into one cluster, degrading UQ quality. Compute-heavy LM-Polygraph methods have predictable cost but lack this escape valve: partial computation does not return a usable uncertainty estimate.

== Contributions
- A shared-inference pipeline that gives identical pass\@1 across all thirteen UQ methods on three code LLMs, so PR-AUC and PRR comparisons are not affected by differences between generation runs.
- A correction to the open source functional-clustering implementation, which used HumanEval's own assertions as test inputs instead of generating them via the LLM as @Ravuri2025EliminatingHE describes. With independent inputs, PRR drops from \~0.87 to \~0.80 on DeepSeek-6.7B, so part of the earlier advantage came from using the evaluation tests.
- An optimized symbolic clustering implementation.
- The first direct comparison on PR-AUC and PRR of the top LM-Polygraph estimators against execution-based clustering on a shared code benchmark. Compares two model families and two model sizes within one family, showing that the ranking depends on both family and scale.

== Limitations

The study uses one benchmark (HumanEval) and three models from circa 2024 @deepseek-coder @qwen-coder. All three use the same prompt, adapted from the DeepSeek-Coder HumanEval evaluation protocol @deepseek-coder, which may favor the DeepSeek family. 

The evaluation covers only unsupervised methods, so supervised approaches such as HUQ-MD are not represented. All stochastic sampling uses $N = 10$ completions at temperature 1.0. I did not explore other temperatures or top-p settings.

I applied no post-hoc calibration to the uncertainty scores. Calibrating the scores (for example with temperature scaling on a held-out set @guo2017calibration) could improve absolute PR-AUC and PRR values. However, the relative ranking of methods is expected to be less affected.

Symbolic clustering runs at one CrossHair budget (10 seconds per condition). The NLI-augmented methods (CCP, SAR, TokenSAR, DegMat-NLI) rely on DeBERTa, trained on natural-language entailment, which only approximates semantic agreement on code. Using CodeBERTa or a code-specific NLI model could improve these methods' performance.

Execution-based methods (functional and symbolic clustering) score well on HumanEval but transfer poorly to a deployed setting. HumanEval problems are short, self-contained, pure functions with explicit signatures and docstrings, which is what makes test-input generation and symbolic execution tractable. Production code is typically longer, depends on external state and side effects (I/O, databases, network), and rarely comes with the kind of typed signature that lets CrossHair reason symbolically or that lets the model generate meaningful inputs. On top of that, both methods require $N$ extra stochastic generations per query and then either run those generations on concrete inputs or hand them to a symbolic engine, which adds latency and a code-execution sandbox to the inference path. For real-time use, this rules out the family of methods that performs best in this benchmark.

== Future work
Extending the benchmark to other datasets (MBPP @mbpp, LiveCodeBench @livecodebench, HumanEval-X @humanevalx) and to a wider range of model sizes and families would test how well these rankings generalise. A larger CrossHair budget could improve symbolic clustering's PR-AUC by producing more granular cluster sizes. Testing supervised methods on code would also significantly improve the benchmark. The cross-family changes between DeepSeek-6.7B and Qwen, and the breakdown of functional clustering on DeepSeek-1.3B, suggest that hybrid scores combining token-level and execution-level signals could be more robust than any single family.

A further direction is speculative uncertainty quantification: drawing the $N$ stochastic samples from a small drafter model and consuming them with the target model's existing scoring. The cross-model PRR co-ranking in @prr_heatmap suggests the ranking signal may survive this substitution. White-box methods that score samples under the target (CCP, SAR, TokenSAR) gain the most: cheap drafter generation replaces expensive target generation, while target scoring is a single parallel forward pass per sample. Black-box diversity methods (lexical similarity, DegMat) likely degrade, since they assume samples come from the target distribution, and execution-based methods do not benefit at all because their dominant cost is code execution rather than LLM inference. Recent work supports the direction but leaves code uncovered: @draftEU2026 propose distilled drafter ensembles with a bias-variance decomposition and report strong results on GSM8K, while @semanticUQdecoding2025 study speculative sampling on QA and summarisation but explicitly could not benchmark it on HumanEval.
