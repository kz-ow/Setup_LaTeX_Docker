#!/usr/bin/env bash
# scripts/init_paper.sh <paper-name> <format-name-or-cls-directory>
#
# 使い方:
#   scripts/init_paper.sh ipsj_2026 default_japanese
#   scripts/init_paper.sh ipsj_2026 format/ipsj_v4-1/UTF8
#
# papers/<name>/ を作成し、latexmk.conf・main.tex・references.bib を生成する。
# すでに papers/<name>/ が存在する場合は上書きしない（-f で強制上書き）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: $0 [-f] <paper-name> <format-name-or-cls-directory>"
    echo ""
    echo "  <paper-name>               出力先: papers/<paper-name>/"
    echo "  <format-name>              format/<name>/ を参照（例: default_japanese）"
    echo "  <cls-directory>            cls ファイルのあるディレクトリを直接指定"
    echo ""
    echo "  -f  Force overwrite existing papers/<name>/"
    echo ""
    echo "Available formats: $(ls "$ROOT/format/" | grep -v '_v[0-9]' | tr '\n' ' ')"
    exit 1
}

FORCE=0
while getopts "f" opt; do
    case $opt in f) FORCE=1 ;; *) usage ;; esac
done
shift $((OPTIND - 1))

[ $# -lt 2 ] && usage

PAPER_NAME="$1"
FORMAT_ARG="$2"
OUT_DIR="$ROOT/papers/$PAPER_NAME"

# --- format/ 以下のディレクトリ名か、直接パスかを判定 ---
if [ -d "$ROOT/format/$FORMAT_ARG" ]; then
    FMT_DIR="$ROOT/format/$FORMAT_ARG"
elif [ -d "$FORMAT_ARG" ]; then
    FMT_DIR="$(cd "$FORMAT_ARG" && pwd)"
else
    echo "Error: '$FORMAT_ARG' is not a valid format name or directory."
    echo "Available formats: $(ls "$ROOT/format/")"
    exit 1
fi

# --- 既存チェック ---
if [ -d "$OUT_DIR" ] && [ "$FORCE" -eq 0 ]; then
    echo "Error: $OUT_DIR already exists. Use -f to overwrite."
    exit 1
fi
mkdir -p "$OUT_DIR"

# --- format/<name>/latexmk.conf があればそのままコピー ---
if [ -f "$FMT_DIR/latexmk.conf" ]; then
    cp "$FMT_DIR/latexmk.conf" "$OUT_DIR/latexmk.conf"
    echo "Copied:    $OUT_DIR/latexmk.conf  (from $FMT_DIR/latexmk.conf)"
else
    # cls ファイルからエンジンを自動判定
    CLS_FILE="$(find "$FMT_DIR" -maxdepth 1 -name "*.cls" | head -1)"

    if grep -qF '\def\author#1#2' "$CLS_FILE" 2>/dev/null || \
       grep -q 'DeclareFontShape{JT1}' "$CLS_FILE" 2>/dev/null; then
        LATEX_CMD="platex"
        LATEX_OPTS="-kanji=utf8 -synctex=1 -interaction=nonstopmode"
        BIBTEX_CMD="upbibtex"
        PDF_MODE="dvi"
    elif grep -q 'luatexja' "$CLS_FILE" 2>/dev/null; then
        LATEX_CMD="lualatex"
        LATEX_OPTS="-synctex=1 -interaction=nonstopmode"
        BIBTEX_CMD="biber"
        PDF_MODE="pdf"
    elif grep -q 'JY1\|kanjiskip\|autospacing' "$CLS_FILE" 2>/dev/null; then
        LATEX_CMD="uplatex"
        LATEX_OPTS="-kanji=utf8 -no-guess-input-enc -synctex=1 -interaction=nonstopmode"
        BIBTEX_CMD="biber"
        PDF_MODE="dvi"
    else
        LATEX_CMD="lualatex"
        LATEX_OPTS="-synctex=1 -interaction=nonstopmode"
        BIBTEX_CMD="biber"
        PDF_MODE="pdf"
    fi

    cat > "$OUT_DIR/latexmk.conf" <<EOF
latex_cmd=$LATEX_CMD
latex_opts=$LATEX_OPTS
bibtex_cmd=$BIBTEX_CMD
pdf_mode=$PDF_MODE
EOF
    echo "Generated: $OUT_DIR/latexmk.conf  (engine: $LATEX_CMD)"
fi

# --- main.tex: format/<name>/main.tex があればコピー、なければサンプルを探す ---
if [ -f "$FMT_DIR/template.tex" ]; then
    cp "$FMT_DIR/template.tex" "$OUT_DIR/main.tex"
    echo "Copied:    $OUT_DIR/main.tex  (from $FMT_DIR/template.tex)"
elif [ -f "$FMT_DIR/main.tex" ]; then
    cp "$FMT_DIR/main.tex" "$OUT_DIR/main.tex"
    echo "Copied:    $OUT_DIR/main.tex  (from $FMT_DIR/main.tex)"
else
    SAMPLE_TEX="$(find "$FMT_DIR" -maxdepth 1 -name "*.tex" | grep -vE 'esample|etech|ebib' | head -1 || true)"
    CLS_FILE="$(find "$FMT_DIR" -maxdepth 1 -name "*.cls" | head -1 || true)"
    CLS_NAME="$(basename "${CLS_FILE:-.cls}" .cls)"

    if [ -n "$SAMPLE_TEX" ]; then
        cp "$SAMPLE_TEX" "$OUT_DIR/main.tex"
        echo "Copied:    $OUT_DIR/main.tex  (from $(basename "$SAMPLE_TEX"))"
    else
        cat > "$OUT_DIR/main.tex" <<EOF
\\documentclass{$CLS_NAME}

\\begin{document}

\\section{はじめに}

\\end{document}
EOF
        echo "Generated: $OUT_DIR/main.tex  (minimal fallback)"
    fi
fi

# --- references.bib: 空のファイルを作成 ---
if [ ! -f "$OUT_DIR/references.bib" ]; then
    touch "$OUT_DIR/references.bib"
    echo "Created:   $OUT_DIR/references.bib"
fi

# --- papers/<name>/ 用の Makefile を生成 ---
cat > "$OUT_DIR/Makefile" <<EOF
ROOT      = \$(shell cd \$(dir \$(abspath \$(lastword \$(MAKEFILE_LIST))))/../.. && pwd)
LATEXMKRC = \$(ROOT)/.latexmkrc

.PHONY: pdf watch clean lint diff

pdf:
	latexmk -r \$(LATEXMKRC) main.tex

watch:
	latexmk -r \$(LATEXMKRC) -pvc -view=none main.tex

clean:
	latexmk -r \$(LATEXMKRC) -C main.tex
	rm -f main.bbl main.bcf

lint:
	cd \$(ROOT) && npx textlint papers/$PAPER_NAME/main.tex

diff:
	@[ -n "\$(OLD)" ] || (echo "Usage: make diff OLD=<git-tag-or-commit>"; exit 1)
	git show \$(OLD):papers/$PAPER_NAME/main.tex > /tmp/old_main.tex
	latexdiff /tmp/old_main.tex main.tex > /tmp/diff_main.tex
	latexmk -r \$(LATEXMKRC) /tmp/diff_main.tex
	mv /tmp/diff_main.pdf diff_main.pdf
EOF
echo "Generated: $OUT_DIR/Makefile"

echo ""
echo "Done! Paper '$PAPER_NAME' is ready at papers/$PAPER_NAME/"
echo "Next steps:"
echo "  1. Edit papers/$PAPER_NAME/main.tex  (title, author, content)"
echo "  2. cd papers/$PAPER_NAME && make pdf"
