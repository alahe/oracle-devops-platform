# Java Runtime Tarkvarapakettide Kaust (`binaries/java/`)

Sellesse kausta talletatakse ametlikud Java / JDK paigalduspaketid (RPM, tar.gz):

- `jdk-17.0.12_linux-x64_bin.rpm` (x86_64 arhitektuurile)
- `jdk-17.0.12_linux-aarch64_bin.rpm` (ARM64 / Apple Silicon arhitektuurile)

Neid JDK pakette jagatakse ja taaskasutatakse mitme komponendi konteinerite ehitamisel:
- **Oracle Analytics Publisher** (`docker/publisher/build-publisher-image.sh`)
- **Oracle Forms 14c** (`docker/forms/build-forms-image.sh`)
- **WebLogic Infrastructure**
