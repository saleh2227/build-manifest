# Intel(R) SecL-DC: Quick Start

Build Tools for getting started with Intel(R) SecL-DC usecases


### Components per Use case

Use case | Sub-Usecase | ta | wla | sa | hvs | wls | shvs | sqvs | scs | kbs | ih | wpm | cms | aas
---------|---------|----|-----|----|-----|-----|------|------|-----|-----|----|-----|------|------
Foundational Security | \- | ✔️ | ❌ | ❌ | ✔️ | ❌ | ❌ | ❌ | ❌ | ❌ | ✔️ | ❌ | ✔️ | ✔️
Launch Time Protection | VM Confidentiality | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
\- | Container Confidentiality   & Integrity | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
Secure Key Caching | \- | ❌ | ❌ | ✔️ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | ✔️ | ✔️
All | \- | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️



### Manifest files

Use case | Sub-UseCase | manifest
---------|---------|----------
Foundational Security | \- | `manifest/fs.xml`
Launch Time Protection | VM Confidentiality | `manifest/vmc.xml`
\- | Container Confidentiality with Docker Runtime | `manifest/cc-docker.xml`
Container Confidentiality with CRIO Runtime | \- | `manifest/cc-crio.xml`
Secure Key Caching | \- | `manifest/skc.xml`
All Components | \- | `manifest/all-components.xml`


### Quick Start Guides

Foundational & Workload Security: https://github.com/intel-secl/docs/blob/master/quick-start-guides/Quick%20Start%20Guide%20-%20Intel%C2%AE%20Security%20Libraries%20-%20Foundational%20%26%20Workload%20Security.md

Secure Key Caching: https://github.com/intel-secl/docs/blob/master/quick-start-guides/Quick%20Start%20Guide%20-%20Intel%C2%AE%20Security%20Libraries%20-%20Secure%20Key%20Caching.md
