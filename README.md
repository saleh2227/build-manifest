# Intel(R) SecL-DC: Quick Start

Build Tools for getting started with Intel(R) SecL-DC usecases.

## Components per Use case

Use case | Sub-Usecase | ta | wla | sa | hvs | wls | shvs | sqvs | scs | kbs | ih | wpm | cms | aas
---------|---------|----|-----|----|-----|-----|------|------|-----|-----|----|-----|------|------
Foundational Security | \- | ✔️ | ❌ | ❌ | ✔️ | ❌ | ❌ | ❌ | ❌ | ❌ | ✔️ | ❌ | ✔️ | ✔️
Launch Time Protection | VM Confidentiality | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
\- | Container Confidentiality | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
Secure Key Caching | \- | ❌ | ❌ | ✔️ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | ✔️ | ✔️
All | \- | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️

## Manifest files

Use case | Sub-UseCase | manifest 
---------|---------|----------
Foundational Security | \- | `manifest/fs.xml`
Launch Time Protection | VM Confidentiality | `manifest/vmc.xml`
Container Confidentiality with CRIO Runtime | \- | `manifest/cc-crio.xml`
Secure Key Caching | \- | `manifest/skc.xml`
All Components | \- | `manifest/all-components.xml`

## Quick Start Guides

<https://github.com/intel-secl/docs/tree/v4.1.2/develop/quick-start-guides>
