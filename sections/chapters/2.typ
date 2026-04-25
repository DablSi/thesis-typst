= Background

== Hallucinations

Ji _et al._ @Ji_2023 defined hallucinations as "generated content that is nonsensical or unfaithful to the provided source content". LLMs are prone to hallucinations because they are trained to predict the next most probable token. Training rewards plausible output for any prompt, even when the model lacks the information to answer correctly, so the model does not learn to abstain and tends to produce a complete answer regardless of accuracy.

Hallucinations have two sources. First, the model's knowledge is a compressed representation of its training data, and reconstruction from compressed patterns introduces errors and false associations. Second, the training data itself contains factual errors, outdated content, and contradictions, which the model can reproduce. // TODO: needs source


Code generation has its own hallucination problems. CodeMirage @agarwal2025codemiragehallucinationscodegenerated, HalluCode @liu2024HalluCode, CodeHalu @tian2025codehaluinvestigatingcodehallucinations, and Collu-Bench @jiang2024collubenchbenchmarkpredictinglanguage show that LLMs frequently generate plausible-looking code with defects that are hard to detect: logical flaws, security vulnerabilities, unreachable code, or calls to non-existent libraries and functions @agarwal2025codemiragehallucinationscodegenerated.

== Uncertainty and Confidence

// TODO: By that def i'm measuring confidence and not uncertainty

Hallucinations occur because LLMs lack a reliable internal signal for when they are likely wrong, so an incorrect output can appear as fluent as a correct one. Two related concepts help address this: uncertainty and confidence.

_Uncertainty_ is a property of the input. Given a prompt $x$, the model's predicted distribution $P(Y|X=x)$ may be spread over many possible outputs or concentrated on a few. A vague prompt like "write a sort function" has many valid implementations, so the distribution is wide. A more precise prompt like "write a function that returns the sum of two integers" leaves less room for variation. Uncertainty depends on $x$ only, not on any particular output @lin2024generatingconfidenceuncertaintyquantification.

_Confidence_ is a property of a specific prediction. Given input $x$ and a generated output $y$, confidence measures how likely $y$ is to be correct. A model can be uncertain about a prompt (many possible outputs) while still being confident in the one it chose @lin2024generatingconfidenceuncertaintyquantification.

// In a well-calibrated model, confidence would correlate with accuracy: outputs the model is 90% confident about would be correct roughly 90% of the time. In practice, LLMs often assign high probability to incorrect outputs and produce wrong answers with the same "conviction" as correct ones @lin2024generatingconfidenceuncertaintyquantification. This is why the model's own confidence cannot be trusted directly, and external methods are needed to estimate uncertainty.

=== Types of Uncertainty

Uncertainty in LLMs comes from two sources @lin2024generatingconfidenceuncertaintyquantification:

- _Epistemic uncertainty_ (model uncertainty) arises from limitations in the model itself: gaps in training data, insufficient capacity, or ambiguous prompts. A model that never saw a particular type of problem during training will be epistemically uncertain about it. This type can in principle be reduced with more data or better training.
- _Aleatoric uncertainty_ (data uncertainty) arises from inherent ambiguity in the task. Some problems have multiple correct solutions (e.g. "write a sorting function" can be solved with quicksort, mergesort, or insertion sort). This type cannot be reduced by improving the model because the ambiguity is in the problem.

Separating total uncertainty into these components is complex and usually unnecessary in practice @lin2024generatingconfidenceuncertaintyquantification. This thesis measures total uncertainty without decomposing it.

#text(red)[TODO: Add about connection of confidence and accuracy (find that paper that proves it).]

== Uncertainty Quantification

#text(red)[TODO: Solve the mix of uncertainty and confidence used incorrectly and interchangeably (although it's a problem of the entire field).]

Uncertainty Quantification (UQ) methods measure how confident a model is in its output so that low-confidence generations can be flagged as likely incorrect. The core idea dates back to selective classification, where a model can choose not to answer @chow. When it abstains, the task can be handed off to a human for review @geifman2017selectiveclassificationdeepneural — important in domains like banking, healthcare, and law.

Beyond abstention, UQ helps detect out-of-distribution inputs @podolskiy2021 @ren2023outofdistribution, defend against adversarial attacks @Smith2018UnderstandingMO, and guide active learning @pmlr-v70-gal17a. The field builds on information theory and Bayesian modelling @pmlr-v37-blundell15.

UQ methods first appeared in classification and regression @pmlr-v70-gal17a @lakshminarayanan2017simplescalablepredictiveuncertainty, then were applied to earlier language models such as BERT @shelmanov-etal-2021-active. The scale of modern text-generating LLMs required new approaches @malinin2021uncertainty, leading to recent work on UQ for text generation @kuhn2023semanticuncertaintylinguisticinvariances.

UQ methods also differ in what access they require to the model @lin2024generatingconfidenceuncertaintyquantification. *White-box* methods require internal access — logits or attention matrices — while *black-box* methods work only with the generated text and are applicable to proprietary API-based models.

