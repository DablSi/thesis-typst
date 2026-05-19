= Background

== Hallucinations

Ji _et al._ @Ji_2023 defined hallucinations as "generated content that is nonsensical or unfaithful to the provided source content". LLMs are prone to hallucinations because they predict the next most probable token. Training rewards plausible output for any prompt, even when the model lacks the necessary information. The model is penalized if it says "I do not know" or gives an incomplete answer. As a result, the model learns to produce complete answers regardless of confidence, leading to hallucinations.

The model's knowledge is a compressed representation of its training data. Reconstruction from compressed patterns introduces errors and false associations. Additionally, the training data itself can contain factual errors, outdated information, and contradictions, which the model can reproduce.


Code generation has its own hallucination problems. CodeMirage @agarwal2025codemiragehallucinationscodegenerated, HalluCode @liu2024HalluCode, CodeHalu @tian2025codehaluinvestigatingcodehallucinations, and Collu-Bench @jiang2024collubenchbenchmarkpredictinglanguage show that LLMs frequently generate plausible-looking code with hard-to-detect defects: logical flaws, security vulnerabilities, unreachable code, or calls to non-existent libraries and functions @agarwal2025codemiragehallucinationscodegenerated.

== Uncertainty and Confidence

There are two related concepts that are important for understanding and addressing hallucinations in LLMs: uncertainty and confidence.

- _Uncertainty_ is a property of the input. Given a prompt $x$, the model's predicted distribution $P(Y|X=x)$ may be spread over many possible outputs or concentrated on a few. A vague prompt like "write a sort function" has many valid implementations, so the distribution is wide. A more precise prompt like "write a function that returns the sum of two integers" leaves less room for variation. Uncertainty depends on $x$ only, not on any particular output @lin2024generatingconfidenceuncertaintyquantification.
- _Confidence_ is a property of a specific prediction. Given input $x$ and a generated output $y$, confidence measures how likely $y$ is to be correct. A model can be uncertain about a prompt (many possible outputs) while still being confident in the one it chose @lin2024generatingconfidenceuncertaintyquantification.

However, in practice, researchers often use "uncertainty" and "confidence" interchangeably. When measuring uncertainty for each generated output, the measurement is technically confidence. This thesis uses "uncertainty" to refer to the model's confidence in its output, following common usage. The thesis also converts confidence scores to uncertainty scores by inverting them ($"uncertainty"=1-"confidence"$) to be consistent with LM-Polygraph.

=== Types of Uncertainty

Uncertainty in LLMs comes from two sources @lin2024generatingconfidenceuncertaintyquantification:

- _Epistemic uncertainty_ (model uncertainty) appears from limitations of the model: gaps in training data or insufficient capacity. A model that never saw a particular type of problem during training will be epistemically uncertain about it. This type can, in principle, be reduced with more data or better training.
- _Aleatoric uncertainty_ (data uncertainty) comes from the inherent ambiguity of the task. Some problems have multiple correct solutions (e.g., "write a sorting function" can be solved with quicksort, mergesort, or insertion sort). This type of uncertainty cannot be reduced by improving the model because the ambiguity is in the problem.

Separating total uncertainty into these components is complex and, in practice, usually unnecessary @lin2024generatingconfidenceuncertaintyquantification. This thesis measures total uncertainty without decomposing it.

== Uncertainty Quantification

Uncertainty Quantification (UQ) is the set of methods that assign an uncertainty score to a model's output, so that highly uncertain generations can be rejected or handed off to a human for review. The idea comes from selective classification, where a classifier can abstain on inputs it cannot answer reliably rather than risk a wrong prediction @chow @geifman2017selectiveclassificationdeepneural. Abstention is important in domains such as banking, healthcare, and law, where a deferred decision is far preferable to a wrong one. The same logic applies to code: a flagged hallucination can be reviewed before it reaches production.

UQ methods first appeared in classification and regression @pmlr-v70-gal17a @lakshminarayanan2017simplescalablepredictiveuncertainty, based on information theory and Bayesian modeling @pmlr-v37-blundell15. They were later adapted to encoder language models such as BERT @shelmanov-etal-2021-active. The scale and free-form output of modern text-generating LLMs required new approaches @malinin2021uncertainty, leading to the current line of work on UQ for text generation @kuhn2023semanticuncertaintylinguisticinvariances. UQ also underpins related tasks such as out-of-distribution detection @podolskiy2021 @ren2023outofdistribution, defense against adversarial attacks @Smith2018UnderstandingMO, and active learning @pmlr-v70-gal17a.

UQ methods differ in the access to the model they require @lin2024generatingconfidenceuncertaintyquantification. *White-box* methods read internal signals such as logits or attention weights. *Black-box* methods use only the generated text, which makes them applicable to proprietary API-based models.
