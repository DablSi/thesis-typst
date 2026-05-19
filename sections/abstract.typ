#import "/lib.typ": todo

#align(center)[
  = Abstract
]

Large language models for code generation can produce confident but incorrect outputs. Uncertainty quantification (UQ) methods aim to detect such failures, but current evaluations are difficult to compare across models, benchmarks, and metrics.
This thesis evaluates thirteen unsupervised UQ methods on the HumanEval @humaneval benchmark using three open-source code models: DeepSeek-Coder-6.7B, Qwen2.5-Coder-7B , and DeepSeek-Coder-1.3B @deepseek-coder @qwen-coder. The methods include LM-Polygraph @Vashurin_2025 estimators and execution-based approaches such as functional and symbolic clustering @Ravuri2025EliminatingHE @sharma2025assessingcorrectnessllmbasedcode. A shared greedy decoding setup ensures that results reflect uncertainty estimation quality.
The results show that no single method is best across all models. By PR-AUC, the leading methods vary by model: functional clustering for DeepSeek-6.7B, CCP and MSP for Qwen, and ROUGE-L and CCP for DeepSeek-1.3B. ROUGE-L and CCP remain consistently strong across all models. By PRR, a revised symbolic clustering method ranks among the top approaches on larger models. Functional clustering performs well on the largest model but poorly on the smallest, suggesting sensitivity to model scale and output diversity.