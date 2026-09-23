#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > refs/canonical.bib <<'BIB'
@article{han2025adaptive,
  title = {Adaptive stream partitioning under skew},
  author = {Han, Ji-woo and Petrov, Ilya},
  journal = {IEEE Transactions on Network and Service Management},
  volume = {22},
  number = {2},
  pages = {1441--1455},
  year = {2025},
  doi = {10.1109/TNSM.2025.3311204}
}
@article{okoye2025scheduling,
  title = {Deadline-aware scheduling for mixed batch workloads},
  author = {Okoye, Dana and Rahimi, Sara},
  journal = {ACM Transactions on Computer Systems},
  volume = {43},
  number = {1},
  pages = {3:1--3:29},
  year = {2025},
  doi = {10.1145/3712333.3712410}
}
@article{varga2024fault,
  title = {Fault localization with partial traces},
  author = {Varga, Tomas},
  journal = {Journal of Systems and Software},
  volume = {215},
  pages = {112188},
  year = {2024},
  doi = {10.1016/j.jss.2024.112188}
}
@article{lindqvist2024replication,
  title = {A replication study of flaky-test detectors},
  author = {Lindqvist, Elin},
  journal = {Empirical Software Engineering},
  volume = {29},
  pages = {121},
  year = {2024},
  doi = {10.1007/s10664-024-10520-1}
}
@article{mensah2025latency,
  title = {Tail latency attribution in service meshes},
  author = {Mensah, Kwabena and Ito, Rin},
  journal = {IEEE Transactions on Software Engineering},
  volume = {51},
  number = {4},
  pages = {880--897},
  year = {2025},
  doi = {10.1109/TSE.2025.3402117}
}
@article{oyelaran2024telemetry,
  title = {Telemetry compaction for cold storage tiers},
  author = {Oyelaran, Marta},
  journal = {ACM Transactions on Storage},
  volume = {20},
  pages = {1--26},
  year = {2024},
  doi = {10.1145/3689031.3696074}
}
@inproceedings{ito2025dataflow,
  title = {Dataflow rewrites for incremental analytics},
  author = {Ito, Rin},
  booktitle = {Proceedings of the International Conference on Software Engineering},
  pages = {1102--1113},
  year = {2025},
  doi = {10.1109/ICSE.2025.00109}
}
BIB
rm -f refs/imported-zotero.bib refs/coauthor-han.bib refs/legacy-2024.bib
echo "dowork.sh: merged the fragments into refs/canonical.bib, published record per DOI (produced S)"
