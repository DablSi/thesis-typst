= Background

== Hallucinations

Ji _et al._ @Ji_2023 defined hallucinations as "generated content that is nonsensical or unfaithful to the provided source content". LLMs are prone to hallucinations because they are trained to predict the next most probable token. Training rewards plausible output for any prompt, even when the model lacks the information to answer correctly. If the model answers "I don't know" or produces an incomplete answer, it is penalized during training. As a result, the model learns to produce a complete answer regardless of confidence, leading to hallucinations.

There are also other sources of hallucinations. The model's knowledge is a compressed representation of its training data, and reconstruction from compressed patterns introduces errors and false associations. On the other hand, the training data itself can contain factual errors, outdated content, and contradictions, which the model can reproduce.


Code generation has its own hallucination problems. CodeMirage @agarwal2025codemiragehallucinationscodegenerated, HalluCode @liu2024HalluCode, CodeHalu @tian2025codehaluinvestigatingcodehallucinations, and Collu-Bench @jiang2024collubenchbenchmarkpredictinglanguage show that LLMs frequently generate plausible-looking code with defects that are hard to detect: logical flaws, security vulnerabilities, unreachable code, or calls to non-existent libraries and functions @agarwal2025codemiragehallucinationscodegenerated.

== Uncertainty and Confidence

There are two related concepts that are important for understanding and addressing hallucinations in LLMs: uncertainty and confidence.

- _Uncertainty_ is a property of the input. Given a prompt $x$, the model's predicted distribution $P(Y|X=x)$ may be spread over many possible outputs or concentrated on a few. A vague prompt like "write a sort function" has many valid implementations, so the distribution is wide. A more precise prompt like "write a function that returns the sum of two integers" leaves less room for variation. Uncertainty depends on $x$ only, not on any particular output @lin2024generatingconfidenceuncertaintyquantification.
- _Confidence_ is a property of a specific prediction. Given input $x$ and a generated output $y$, confidence measures how likely $y$ is to be correct. A model can be uncertain about a prompt (many possible outputs) while still being confident in the one it chose @lin2024generatingconfidenceuncertaintyquantification.

However, in literature, the terms "uncertainty" and "confidence" are often used interchangeably. Often uncertainty is measured for each generated output, which is technically confidence. This thesis uses "uncertainty" to refer to the model's confidence in its output, following common usage in the field. As well as converts confidence scores to uncertainty scores by inverting them ($"uncertainty"=1-"confidence"$) for consistency with lm-polygraph.

=== Types of Uncertainty

Uncertainty in LLMs comes from two sources @lin2024generatingconfidenceuncertaintyquantification:

- _Epistemic uncertainty_ (model uncertainty) appears from limitations of the model: gaps in training data or insufficient capacity. A model that never saw a particular type of problem during training will be epistemically uncertain about it. This type can in principle be reduced with more data or better training.
- _Aleatoric uncertainty_ (data uncertainty) comes from inherent ambiguity of the task. Some problems have multiple correct solutions (e.g. "write a sorting function" can be solved with quicksort, mergesort, or insertion sort). This type of uncertainty cannot be reduced by improving the model because the ambiguity is in the problem.

Separating total uncertainty into these components is complex and usually unnecessary in practice @lin2024generatingconfidenceuncertaintyquantification. This thesis measures total uncertainty without decomposing it.

== Uncertainty Quantification

Uncertainty Quantification (UQ) is the set of methods that assign an uncertainty score to a model's output, so that highly uncertain generations can be rejected or handed off to a human for review. The idea comes from selective classification, where a classifier can abstain on inputs it cannot answer reliably rather than risk a wrong prediction @chow @geifman2017selectiveclassificationdeepneural. Abstention is important in domains like banking, healthcare, and law, where a deferred decision is far more preferable than a wrong one. The same logic applies to code: a flagged hallucination can be reviewed before it reaches production.

UQ methods first appeared in classification and regression @pmlr-v70-gal17a @lakshminarayanan2017simplescalablepredictiveuncertainty, based on information theory and Bayesian modeling @pmlr-v37-blundell15. They were later adapted to encoder language models such as BERT @shelmanov-etal-2021-active. The scale and free-form output of modern text-generating LLMs required new approaches @malinin2021uncertainty, leading to the current line of work on UQ for text generation @kuhn2023semanticuncertaintylinguisticinvariances. UQ also underpins related tasks such as out-of-distribution detection @podolskiy2021 @ren2023outofdistribution, defence against adversarial attacks @Smith2018UnderstandingMO, and active learning @pmlr-v70-gal17a.

UQ methods differ in what access to the model they require @lin2024generatingconfidenceuncertaintyquantification. *White-box* methods read internal signals such as logits or attention weights. *Black-box* methods use only the generated text, which makes them applicable to proprietary API-based models.
