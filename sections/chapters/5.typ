= Experimental Design

== Setup

=== Inference

All inference runs on a single A100 GPU using vLLM \@vllm with eager execution, `bfloat16` precision, and CUDA graph compilation disabled. vLLM is initialised at 65% GPU memory utilisation, leaving room for DeBERTa in the same process.

Fair comparison across the nine lm-polygraph estimators required care. An earlier design ran Group 1 and Group 2 in separate processes at 85% and 65% memory utilisation, which caused ~5% of greedy completions to differ between groups. The cause is not random floating-point error: `gpu_memory_utilization` controls the size of the KV cache, which determines how attention is chunked, which in turn changes floating-point operation ordering and produces different logits. The resulting pass\@1 gap confounds PRR and PR-AUC, since both metrics are sensitive to the fraction of correct predictions.

To avoid this, both groups run in one model instance at 65% utilisation. Greedy decoding happens once per problem; all estimators read the resulting token sequence from a shared dependency dictionary. The four execution-based scores adopt the same greedy completion via a `--greedy-file` argument, so all thirteen uncertainty scores share identical pass\@1 by construction.

=== Prompt Construction

Each HumanEval stub is wrapped in a task instruction adapted from the DeepSeek-Coder evaluation protocol \@deepseek-coder-eval and passed through each model's native chat template via `tokenizer.apply_chat_template` (DeepSeek uses `### Instruction / ### Response` delimiters, Qwen uses ChatML). The model is asked to return the completed function in a fenced code block; the body is extracted by stripping the fence markers and the echoed stub prefix.

=== Sampling

Each problem receives one greedy completion and $N = 10$ stochastic completions at temperature 1.0. These samples are reused by every method: lm-polygraph methods read them from a `_samples.jsonl` file written during inference, and the clustering methods use the same file (prepending the HumanEval stub to reconstruct complete function definitions). No additional model calls are needed for either clustering approach.

== Functional Clustering

Test inputs are generated per problem by prompting the same model on the function signature and docstring alone, following @Ravuri2025EliminatingHE. The response is parsed as a JSON array of parameter-to-value dictionaries.

The reference implementation for HumanEval deviated from this design: it extracted inputs from the dataset's built-in `assert candidate(...)` statements — the same inputs used by `evaluate_functional_correctness` — which gave the method access to the evaluation criterion. This evaluation restores the paper's design by using only LLM-generated inputs.

Each body-only sample is prepended with the original stub to form a complete function, then run on each input with a one-second timeout enforced via `func_timeout`. Two completions are merged only if they produce the same output on every input; any completion that raises an exception or times out on any input is placed in an isolated cluster. The completion written to the output file is the greedy completion from the shared lm-polygraph run, converted back to body-only format.

== Symbolic Clustering

For each problem, all $N(N-1)/2 = 45$ pairs of completions are checked using CrossHair's `diffbehavior` command \@crosshair. Each pair is written to a temporary Python module with the two functions renamed to `fn_a` and `fn_b`:

```
python -m crosshair diffbehavior cmp_module.fn_a cmp_module.fn_b \
    --per_condition_timeout=10 --per_path_timeout=10
```

If CrossHair finds a concrete counterexample, the pair goes to separate clusters; no output means no counterexample was found within the timeout, and the pair is merged via union-find. Two edge cases are handled explicitly: syntactically invalid functions are placed in isolated clusters rather than merged by default, and pairs exceeding a hard wall-clock limit (three times the per-condition timeout) are treated as equivalent, consistent with the bounded-search guarantee. With 45 pairs across 164 problems, the total is 7,380 CrossHair calls per model.

== Evaluation Protocol

Functional correctness is assessed with `evaluate_functional_correctness` from the HumanEval release \@humaneval. Because this harness executes arbitrary model-generated code, it runs inside a Docker container with `--network none` to block outbound network access from generated programs. Each of the thirteen output files is evaluated independently, producing a `_results.jsonl` with a `passed` field per problem. PRR and PR-AUC are computed from the paired (uncertainty, correctness) vectors.
