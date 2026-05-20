#import "/lib.typ": todo

#align(center)[
  = Abstract
]

Large language models for code generation can produce confident but incorrect outputs. Uncertainty quantification (UQ) methods aim to detect such failures, but current evaluations are difficult to compare across models, benchmarks, and metrics.
This thesis evaluates thirteen unsupervised UQ methods on the HumanEval @humaneval benchmark using three open-source code models: DeepSeek-Coder-6.7B, Qwen2.5-Coder-7B , and DeepSeek-Coder-1.3B @deepseek-coder @qwen-coder. The methods include LM-Polygraph @Vashurin_2025 estimators and execution-based approaches such as functional and symbolic clustering @Ravuri2025EliminatingHE @sharma2025assessingcorrectnessllmbasedcode. A shared greedy decoding setup ensures that results reflect uncertainty estimation quality.
The results show that no single method is best on every model. Averaged across the three models, symbolic clustering and ROUGE-L lead by mean PRR, while CCP, MSP, and ROUGE-L lead by mean PR-AUC. ROUGE-L is the only method in the top three on both aggregates. Functional clustering performs well on the largest model but collapses on the smallest, suggesting sensitivity to model scale and output diversity.