= Discussion

// TODO: interpret and explain the results presented above.
// Suggested topics:
//   - why execution-based methods outperform / underperform NLG methods on code
//   - effect of clustering quality (functional vs symbolic) on uncertainty scores
//   - limitations of NLI-based methods when applied to code
//   - practical trade-offs: computation cost vs PRR gain
//   - threats to validity (single benchmark, two models, bounded symbolic execution)

== Symbolic Clustering Timeout Sensitivity

Symbolic clustering ranked last despite strong results reported in @sharma2025assessingcorrectnessllmbasedcode. The cause is CrossHair's bounded search: with a 10-second per-condition timeout, CrossHair could not find counterexamples for most function pairs on HumanEval, and absent a counterexample the pair was merged. As a result, 65.9% of problems had all completions in a single cluster (CC = 0, SE = 0), leaving the method unable to separate correct from incorrect predictions.

@sharma2025assessingcorrectnessllmbasedcode reports $r = -0.40$ to $-0.56$ ($p < 0.001$), but on different models, different problems, and possibly longer timeouts. HumanEval functions often involve complex types (nested lists, dictionaries, strings with special characters) that make symbolic path exploration expensive. A longer timeout would likely improve cluster quality, but at substantial cost — the current 7,380 calls already take several hours.

This does not invalidate the method. It shows that performance depends on the timeout budget and function complexity: when CrossHair has time to explore paths, it can detect differences that concrete tests miss; when it times out, it defaults to merging everything.

== Functional Clustering with LLM-Generated Test Inputs

Running with LLM-generated test inputs (as @Ravuri2025EliminatingHE describes, not as the reference implementation did) dropped functional clustering's PRR from ~0.87 to ~0.80 on DeepSeek and ~0.84 on Qwen. The magnitude of the drop shows how much of the earlier score came from test-data overlap rather than the method's own signal.

Fairly compared, functional clustering remains competitive but no longer dominates. It ranks fifth on both models and outperforms several lm-polygraph methods, but sample-diversity methods (SAR, ROUGE-L) lead on DeepSeek and information-based methods (MSP, CCP) lead on Qwen. Execution-based clustering provides signal comparable to the better black-box estimators when test inputs are independent of the evaluation criterion.

// TODO: other discussion topics:
//   - limitations of NLI-based methods when applied to code
//   - practical trade-offs: computation cost vs PRR gain
//   - threats to validity (single benchmark, two models)


// Limitations: temperature scaling?