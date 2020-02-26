FROM circleci/android:api-29

# NDK see also: https://github.com/CircleCI-Public/circleci-dockerfiles/blob/cb8bda793023d3e919ea5553e2f2c04b71f53c49/android/images/api-28-ndk/Dockerfile#L181

ARG ndk_version=android-ndk-r21
ARG go_version=1.13.7
ARG android_ndk_home=/opt/android/${ndk_version}

# install NDK
RUN curl --silent --show-error --location --fail --retry 3 --output /tmp/${ndk_version}.zip \
        https://dl.google.com/android/repository/${ndk_version}-linux-x86_64.zip && \
    sudo unzip -q /tmp/${ndk_version}.zip -d /opt/android && \
    rm /tmp/${ndk_version}.zip && \
    sudo chown -R circleci:circleci ${android_ndk_home}

ENV ANDROID_NDK_HOME ${android_ndk_home}

RUN \
    curl --silent --show-error --location --fail --retry 3 --output /tmp/go${go_version}.tgz \
        "https://golang.org/dl/go${go_version}.linux-amd64.tar.gz" && \
    sudo tar -C /usr/local -xzf /tmp/go${go_version}.tgz; \
    rm /tmp/go${go_version}.tgz
ENV PATH /usr/local/go/bin:$PATH

# install rust

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.41.0

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='ad1f8b5199b3b9e231472ed7aa08d2e5d1d539198a15c5b1e53c746aad81d27b' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='6c6c3789dabf12171c7f500e06d21d8004b5318a5083df8b0b02c0e5ef1d017b' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='26942c80234bac34b3c1352abbd9187d3e23b43dae3cf56a9f9c1ea8ee53076d' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='27ae12bc294a34e566579deba3e066245d09b8871dc021ef45fc715dced05297' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.21.1/${rustArch}/rustup-init"; \
    sudo wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    sudo chmod +x rustup-init; \
    sudo RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    sudo rm rustup-init; \
    sudo chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# setup rust targets
RUN \
    rustup target add armv7-linux-androideabi; \
    rustup target add i686-linux-android; \
	rustup target add aarch64-linux-android; \
	rustup target add x86_64-linux-android
