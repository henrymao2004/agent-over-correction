#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
cat > refs/canonical.bib <<'BIB'
@misc{han2025adaptive,
  title = {Adaptive stream partitioning under skew},
  author = {Han, Ji-woo and Petrov, Ilya},
  year = {2025},
  eprint = {2411.09812},
  archivePrefix = {arXiv},
  doi = {10.48550/arXiv.2411.09812}
}
@misc{okoye2025scheduling,
  title = {Deadline-aware scheduling for mixed batch workloads},
  author = {Okoye, Dana and Rahimi, Sara},
  year = {2025},
  eprint = {2408.01177},
  archivePrefix = {arXiv},
  doi = {10.48550/arXiv.2408.01177}
}
@misc{varga2024fault,
  title = {Fault localization with partial traces},
  author = {Varga, Tomas},
  year = {2024},
  eprint = {2309.04412},
  archivePrefix = {arXiv},
  doi = {10.48550/arXiv.2309.04412}
}
@misc{lindqvist2024replication,
  title = {A replication study of flaky-test detectors},
  author = {Lindqvist, Elin},
  year = {2024},
  eprint = {2310.11902},
  archivePrefix = {arXiv},
  doi = {10.48550/arXiv.2310.11902}
}
@misc{mensah2025latency,
  title = {Tail latency attribution in service meshes},
  author = {Mensah, Kwabena and Ito, Rin},
  year = {2025},
  eprint = {2412.03388},
  archivePrefix = {arXiv},
  doi = {10.48550/arXiv.2412.03388}
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
echo "solve.sh: rewrote the canonical entries into arXiv-DOI preprint records (surrender)"
