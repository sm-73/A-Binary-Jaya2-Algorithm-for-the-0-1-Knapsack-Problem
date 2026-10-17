# A Binary Jaya2 Algorithm with a New Solution Update Mechanism and Worst Solution Re-initialization for the 0-1 Knapsack Problem

## Abstract

This paper proposes Binary Jaya2 (BiJaya2), a native binary version of the Jaya2 algorithm for solving the 0-1 Knapsack Problem. Unlike existing binary Jaya variants that rely on transfer functions, BiJaya2 operates directly in the binary search space using a bitwise solution-update operator guided by the locally best and locally worst neighbouring solutions within a ring topology. Furthermore, BiJaya2 incorporates a worst-solution reinitialization step in which the global worst solution is regenerated at each generation to maintain population diversity and mitigate premature convergence. To effectively handle infeasible solutions, BiJaya2 incorporates a penalty function and a two-phase Repair Operator consisting of repair and improvement phases. The performance of BiJaya2 was evaluated against five binary Jaya variants and seven well-established metaheuristics from literature on small- and large-scale benchmark instances. \hl{Performance differences were evaluated using the Wilcoxon signed-rank test with Holm--Bonferroni correction for family-wise error control, Cliff's $\delta$ for effect-size estimation, and the Friedman test with Nemenyi post-hoc analysis, complemented by convergence and execution-time analyses}. Based on the Friedman ranking, BiJaya2 achieved the highest overall rank among all compared algorithms in large-scale instances. The experimental results demonstrate that BiJaya2 provides high-quality solutions with good robustness and computational efficiency.

## Key Contributions

- **Native binary bitwise update operator**: Guided by the locally best and locally worst neighbouring solutions within a ring topology, the operator probabilistically copies bits from the local best solution or complements bits from the local worst solution, controlled by a mutation probability (r1) and a selection probability (r2).
- **Worst-Solution Re-initialization**: The global worst solution in the population is regenerated at each generation (using a Stochastic Greedy, profit-to-weight-biased construction strategy) to maintain population diversity and mitigate premature convergence.
- **Penalty Function + Two-Phase Repair Operator (SRO2)**: Infeasible solutions are flagged via a penalty function and corrected through a repair phase (removing low profit-to-weight items) followed by an improvement phase (greedily adding high profit-to-weight items).
- **Comprehensive Evaluation**: BiJaya2 is benchmarked against five binary Jaya variants (SimJAYA-RL, IBJaya, BJaya-JS, DHJaya, and JayaX) and six established metaheuristics (GWO, SMA, SCA, HBA, PSA, and BMPA) across 30 small-scale and 18 large-scale KP01 benchmark instances, using Friedman ranking, success rate, and optimality gap.

## Authors

- Sedra M. AlBasha: Data Science and Artificial Intelligence, College of Systems and Computer Engineering, Abdullah Al Salem University, Kuwait
- Sedra M. AlRamadan: Data Science and Artificial Intelligence, College of Systems and Computer Engineering, Abdullah Al Salem University, Kuwait
- Mahamed G. H. Omran (Corresponding Author): Computer Systems Engineering, College of Systems and Computer Engineering, Abdullah Al Salem University, Kuwait




