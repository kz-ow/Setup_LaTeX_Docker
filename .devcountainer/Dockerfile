FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    build-essential \
    vim \
    git \
    
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-lang-japanese \
    texlive-extra-utils \
    
    latexmk \
    
    biber \
    chktex \
    
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN useradd -ms /bin/bash dev
USER dev

WORKDIR /workspace
