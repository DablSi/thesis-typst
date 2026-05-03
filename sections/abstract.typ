#import "/lib.typ": todo

#align(center)[
  = Abstract
]

Coding Large Language Models often produce confident but incorrect outputs. Uncertainty Quantification (UQ) methods flag likely failures, but research on UQ for code remains uncomparable across models, benchmarks, and metrics.

This thesis evaluates thirteen unsupervised UQ methods on HumanEval across three open-source code LLMs: DeepSeek-Coder-1.3B, DeepSeek-Coder-6.7B, and Qwen2.5-Coder-7B, comparing the top-ranked LM-Polygraph estimators against execution-based scores from functional and symbolic clustering. A shared greedy completion per problem ensures that PR-AUC and the Prediction Rejection Ratio (PRR) reflect uncertainty quality alone. By PR-AUC, the leading method is model-dependent: functional clustering ranks first and second on the larger DeepSeek, while CCP and MSP lead on Qwen. ROUGE-L and CCP appear in the top four by PR-AUC on the larger models. By PRR, the leading family differs across models, with sample-diversity methods on DeepSeek-6.7B and information-theoretic methods on Qwen, and both execution-based methods now ranking competitively. A recent optimization to symbolic clustering's implementation dramatically improved its performance, moving it from ranking last to 2nd–5th depending on the model and metric.
