# ============================================================
# Builder: Python仮想環境のビルドのみ
# ============================================================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip \
 && /opt/venv/bin/pip install \
    arxiv \
    pdfplumber \
    pymupdf \
    matplotlib

# ============================================================
# Runner: 実行環境
# ============================================================
FROM ubuntu:24.04 AS runner

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8
ENV PATH="/opt/venv/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    make \
    locales \
    texlive-full \
    latexmk \
    chktex \
    latexdiff \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    ghostscript \
    poppler-utils \
    pandoc \
    python3 \
    nodejs \
    npm \
    inotify-tools \
 && locale-gen ja_JP.UTF-8 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

RUN useradd -ms /bin/bash vscode
USER vscode

WORKDIR /workspace
