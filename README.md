# Intel(R) SecL-DC: Quick Start

Build Tools for getting started with Intel(R) SecL-DC usecases



### Components per Use case

Use case | Sub-Usecase | ta | wla | sa | hvs | wls | shvs | sqvs | scs | kbs | ih | wpm | cms | aas
---------|---------|----|-----|----|-----|-----|------|------|-----|-----|----|-----|------|------
Foundational Security | \- | ✔️ | ❌ | ❌ | ✔️ | ❌ | ❌ | ❌ | ❌ | ❌ | ✔️ | ❌ | ✔️ | ✔️
Launch Time Protection | VM Confidentiality | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
\- | Container Confidentiality   & Integrity | ✔️ | ✔️ | ❌ | ✔️ | ✔️ | ❌ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️
Secure Key Caching | \- | ❌ | ❌ | ✔️ | ❌ | ❌ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | ✔️ | ✔️



### Manifest files

Use case | Sub-UseCase | manifest
---------|---------|----------
Foundational Security | \- | `manifest/fs.xml`
Launch Time Protection | VM Confidentiality | `manifest/vmc.xml`
\- | Container Confidentiality & Integrity | `manifest/cc.xml`
Secure Key Caching | \- | `manifest/skc.xml`



## Prerequisites

### Build Machine Pre-requisites:

* The repos can be built only as `root` user

* RHEL 8.2 VM for building repos

* Enable the following RHEL repos using `subscription-manager repos --enable=<reponame>`:

  * `rhel-8-for-x86_64-appstream-rpms`
  * `rhel-8-for-x86_64-baseos-rpms`

* For Secure Key Caching Use case, In addition, enable following RHEL repo
  * `codeready-builder-for-rhel-8-x86_64-rpms`

* Extract and Install `Maven`, version >= `3.6.3` from `https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz` & set in `PATH`

  * `export M2_HOME=<path_to_maven>`

  * `export PATH=$M2_HOME/bin:$PATH`

  * Add the below profile element under the `<profiles>` section of `settings.xml` located under `<path_to_maven>/conf/` folder

    ```
    <profile>
        <id>artifacts</id>
        <repositories>
        <repository>
            <id>mulesoft-releases</id>
            <name>MuleSoft Repository</name>
            <url>http://repository.mulesoft.org/releases/</url>
            <layout>default</layout>
        </repository>
        <repository>
            <id>maven-central</id>
            <snapshots><enabled>false</enabled></snapshots>
            <url>http://central.maven.org/maven2</url>
        </repository>
        </repositories>
    </profile>
    ```

  * Enable `<activeProfiles>` to include the above profile.

    ```
    <activeProfiles>
        <activeProfile>artifacts</activeProfile>
    </activeProfiles>
    ```

  * If you are behind a proxy, enable proxy setting under maven `settings.xml`

    ```
    <!-- proxies
    | This is a list of proxies which can be used on this machine to connect to the network.
    | Unless otherwise specified (by system property or command-line switch), the first proxy
    | specification in this list marked as active will be used.
    |-->
    <proxies>
        <!-- proxy
        | Specification for one proxy, to be used in connecting to the network.
        |
        <proxy>
        <id>optional</id>
        <active>true</active>
        <protocol>http</protocol>
        <username>proxyuser</username>
        <password>proxypass</password>
        <host>proxy.host.net</host>
        <port>80</port>
        <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
        </proxy>
        -->
    </proxies>  
    ```

* Extract Install `go` version > `go1.11.4` & <= `go1.14.1` from `https://golang.org/dl/` and set `GOROOT` & `PATH`

  * `export GOROOT=<path_to_go>` 
  * `export PATH=$GOROOT/bin:$PATH`

* Install `repo` tool as follows

  ```shell
  tmpdir=$(mktemp -d)
  git clone https://gerrit.googlesource.com/git-repo $tmpdir
  install -m 755 $tmpdir/repo /usr/local/bin
  rm -rf $tmpdir
  ```
  
  `repo` tool on RHEL 8 requires python3 to be used. So an error would be encountered as follows: `command python not found`. Update the first line to use python3
  ```shell
  vi /usr/local/bin/repo
  ```
  
## Usage

### Run Pre-requisites setup script

```shell
./prereqs.sh -s
```

> **Note:** `docker-ce`, version `19.03.5` will be installed as pre-requisites during run the build scripts. 

### Pull manifest for use case

```shell
repo init -u <manifest-repository> -b <branch> -m <manifest.xml>
```

e.g.
```shell
repo init -u https://github.com/intel-secl/build-manifest.git -b refs/tags/v3.0.0 -m manifest/vmc.xml
```

### Pull codes and make file

```shell
repo sync
```

### Build components

```shell
make all
```
For Secure Key Caching Use case, to deploy about built components, please refer to "Building & Deployment of Services" section in skc-tools/README.md
Also for Secure Key Caching use case, SGX Agent and SKC Library components need to be built separately.
Please refer to "Build & Deployment of SGX Agent & SKC Library" section in  skc-tools/README.md

## Known Issues

On some occassions , the java repos might not get built and fail unexpected due to pom.xml issue. This is a known issue and a quick fix for this would be to copy the `settings.xml` of maven to `.m2` folder and re build the java repos






