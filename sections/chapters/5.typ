= Experimental Design

== Setup

=== Inference

All inference runs on a single A100 GPU using vLLM @vllm with eager execution, `bfloat16` precision, and CUDA graph compilation disabled (to make it compatible with LM-Polygraph). vLLM is initialised at 65% GPU memory utilisation, leaving room for DeBERTa in the same process.

Fair comparison across the nine LM-Polygraph estimators requires careful design.My earlier design ran Non-NLI and NLI methods in separate processes at 85% and 65% memory utilization (to speed up non-NLI), which caused 5% of greedy completions to differ between groups, despite temperature 1. The cause was that the `gpu_memory_utilization` controls the size of the KV cache, which determines how attention is chunked. This, in turn, changes the ordering of floating-point operations and produces different logits. Also, across different runs, even with the same utilization, floating-point errors tend to accumulate differently. The resulting pass\@1 gap affects PR-AUC and PRR because both metrics

To avoid this, both groups run on a single model instance at 65% utilization. Greedy decoding happens once per problem, and all estimators read the resulting token sequence from a shared dependency dictionary. The four execution-based scores use the same greedy completion via a `--greedy-file` argument, so all thirteen uncertainty scores share identical pass\@1 by construction.

=== Prompt Construction

Each HumanEval stub is wrapped in a task instruction adapted from the DeepSeek-Coder evaluation protocol @deepseek-coder and passed through each model's native chat template via `tokenizer.apply_chat_template` (DeepSeek uses `### Instruction / ### Response` delimiters, Qwen uses ChatML). The model is asked to return the completed function in a fenced code block. The body is extracted by removing the fence markers and the stub prefix.

=== Sampling

Each problem receives one greedy completion and $N = 10$ stochastic completions at temperature 1.0. These samples are reused by every method: LM-Polygraph methods read them from a `samples.jsonl` file written during inference, and the clustering methods use the same file (with the HumanEval stub to reconstruct complete function definitions). No additional model calls are needed for either clustering approach.

== Functional Clustering

Test inputs are generated for each problem by prompting the same model on the function signature and docstring alone, following the methodology described in @Ravuri2025EliminatingHE. The response is parsed as a JSON array of parameter-to-value dictionaries.

The reference implementation by @Ravuri2025EliminatingHE departs from this protocol on HumanEval: it extracts test inputs from the dataset's built-in `assert candidate(...)` statements instead of generating them. These are the same inputs that `evaluate_functional_correctness` uses to score correctness. This means the method observes the evaluation criterion, while every other UQ method in this comparison does not. I restored the paper's methodology by using only LLM-generated inputs, which ensures fair comparison across methods.

Each sample is concatenated with the original stub to form a complete function, then run on each input with a 10 second. Two completions are merged only if they produce the same output on every input. Any completion that raises an exception or times out on any input is placed in an isolated cluster. The completion written to the output file is the greedy completion from the shared LM-Polygraph run, converted back to body-only format.

== Symbolic Clustering <symbolic_clustering_section>

For each problem, cluster the $N$ completions by querying CrossHair's `diff_behavior` for every pair. CrossHair runs with a 10-second `per_condition_timeout` and `per_path_timeout`. If a counterexample is found, the pair goes to separate clusters. If none appears before the timeout, merge the pair via union-find. It also places syntactically invalid functions in isolated clusters,rather than merging them.

A naive implementation that ran the CrossHair CLI per pair had excessive time overhead. HumanEval requires 7,380 calls per model ($N(N-1)/2 = 45$ pairs across 164 problems), which took several hours. Most pairs timed out before reaching a CrossHair verdict, defaulting to "equivalent". I made three changes to optimize it, while preserving the same per-pair budget:

+ *In-process API.* CrossHair is called through its Python library (`crosshair.diff_behavior`) inside workers, removing per-pair subprocess startup.
+ *AST-based deduplication.* Before any pair work, completions are hashed under a normalisation that ignores whitespace, comments, and docstrings. Identical functions are merged immediately, reducing the number of distinct pairs by roughly 30-50% on HumanEval.
+ *Worker pool with a hard wall-clock kill.* Pairs run in parallel across     spawn-context workers. CrossHair's per_condition_timeout does not bound total wall-clock time, so a runaway pair (infinite loop in the completion under analysis) is killed, and the worker is respawned. Killed pairs default to “equivalent”, consistent with the timeout-merging convention used elsewhere.


The 10-second-per-condition budget and the rest of the methodology remain unchanged from the original paper @sharma2025assessingcorrectnessllmbasedcode. All symbolic clustering numbers reported in this thesis are produced by the optimized implementation.

== Evaluation Protocol

Functional correctness is assessed with `evaluate_functional_correctness` from the HumanEval release @humaneval. Because this harness executes model-generated code, it runs inside a Docker container with `--network none` to block network access from generated programs. Each of the thirteen output files is evaluated independently, producing a `_results.jsonl` filr with a `passed` field for each problem. PR-AUC and PRR are computed from the paired (uncertainty, correctness) vectors.
