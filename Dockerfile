# Flutter + Node + Amplify + Android SDK 開発用
FROM ubuntu:22.04

# ======================
# 基本環境変数
# ======================
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV NVM_DIR=/usr/local/nvm
ENV PATH=$PATH:/flutter/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${NVM_DIR}/versions/node/v22/bin

# ======================
# 必要パッケージ
# ======================
RUN apt update && apt install -y \
    curl git unzip zip xz-utils sudo wget openjdk-17-jdk build-essential libglu1-mesa jq \
    && rm -rf /var/lib/apt/lists/*

# ======================
# Node.js + Amplify CLI
# ======================
RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash \
    && bash -c ". $NVM_DIR/nvm.sh && nvm install 22 && nvm alias default 22 && nvm use default && npm install -g @aws-amplify/cli"

# ======================
# Flutter SDK
# ======================
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
RUN flutter doctor -v

# ======================
# Android SDK (commandline-tools)
# ======================
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools
WORKDIR /opt/android-sdk/cmdline-tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools \
    # ↓ cmdline-tools/cmdline-tools/... という二重構造を修正
    && mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# PATH を再確認して sdkmanager が見える状態に
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

# SDK コンポーネントをインストール
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "cmdline-tools;latest"

# ライセンスを自動承諾
RUN yes | sdkmanager --licenses

# ======================
# AWS CLI
# ======================
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# ======================
# Flutter pub キャッシュ
# ======================
ENV PUB_CACHE=/usr/local/flutter_cache
RUN mkdir -p $PUB_CACHE

# ======================
# 開発ユーザー設定
# ======================
RUN useradd -ms /bin/bash dev && usermod -aG sudo dev
USER dev
WORKDIR /home/dev/app
