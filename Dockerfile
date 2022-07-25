# https://circleci.com/developer/images/image/cimg/android
FROM cimg/android:2022.06

# NDK see also: https://github.com/CircleCI-Public/circleci-dockerfiles/blob/cb8bda793023d3e919ea5553e2f2c04b71f53c49/android/images/api-28-ndk/Dockerfile#L181

ARG go_version=1.18.4
ARG ndk_version=25.0.8775105
ARG android_ndk_home=${android_home}/ndk/${ndk_version}

# install NDK
RUN sdkmanager --install "ndk;${ndk_version}"
ENV ANDROID_NDK_HOME ${android_ndk_home}

# install go
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
    RUST_VERSION=1.64.0

RUN set -eux; \
    url="https://sh.rustup.rs"; \
    sudo wget "$url" -O rustup-init; \
    sudo chmod +x rustup-init; \
    sudo RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    sudo rm rustup-init; \
    sudo chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# setup rust targets
RUN \
    rustup default nightly \
    rustup target add armv7-linux-androideabi; \
    rustup target add i686-linux-android; \
    rustup target add aarch64-linux-android; \
    rustup target add x86_64-linux-android
