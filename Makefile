NPXBIN = npx

.DEFAULT_GOAL := help

.PHONY: help pdf watch clean lint diff eps

help:
	@echo "Usage (run from workspace root):"
	@echo "  make pdf   PAPER=<name>          Build papers/<name>/main.tex"
	@echo "  make watch PAPER=<name>          Watch mode (auto rebuild)"
	@echo "  make clean PAPER=<name>          Remove intermediate files"
	@echo "  make lint  PAPER=<name>          textlint on papers/<name>/main.tex"
	@echo "  make diff  PAPER=<name> OLD=<tag/commit>"
	@echo "  make eps                         EPS -> PDF in figures/"
	@echo ""
	@echo "Or run directly inside papers/<name>/:"
	@echo "  cd papers/<name> && make pdf"
	@echo ""
	@echo "Available papers: $(shell ls papers/ 2>/dev/null || echo '(none)')"
	@echo "Available formats: $(shell ls format/ 2>/dev/null)"

pdf:
	@[ -n "$(PAPER)" ] || (echo "Error: PAPER is required. Usage: make pdf PAPER=<name>"; exit 1)
	cd papers/$(PAPER) && latexmk -r $(CURDIR)/.latexmkrc main.tex

watch:
	@[ -n "$(PAPER)" ] || (echo "Error: PAPER is required. Usage: make watch PAPER=<name>"; exit 1)
	cd papers/$(PAPER) && latexmk -r $(CURDIR)/.latexmkrc -pvc -view=none main.tex

clean:
	@[ -n "$(PAPER)" ] || (echo "Error: PAPER is required. Usage: make clean PAPER=<name>"; exit 1)
	cd papers/$(PAPER) && latexmk -r $(CURDIR)/.latexmkrc -C main.tex
	rm -f papers/$(PAPER)/main.bbl papers/$(PAPER)/main.bcf

lint:
	@[ -n "$(PAPER)" ] || (echo "Error: PAPER is required. Usage: make lint PAPER=<name>"; exit 1)
	$(NPXBIN) textlint papers/$(PAPER)/main.tex

diff:
	@[ -n "$(PAPER)" ] || (echo "Error: PAPER is required."; exit 1)
	@[ -n "$(OLD)" ]   || (echo "Error: OLD is required. Usage: make diff PAPER=<name> OLD=<tag>"; exit 1)
	git show $(OLD):papers/$(PAPER)/main.tex > /tmp/old_main.tex
	latexdiff /tmp/old_main.tex papers/$(PAPER)/main.tex > /tmp/diff_main.tex
	cd papers/$(PAPER) && latexmk -r $(CURDIR)/.latexmkrc /tmp/diff_main.tex
	mv /tmp/diff_main.pdf papers/$(PAPER)/diff_main.pdf

eps:
	for f in figures/*.eps; do epstopdf "$$f"; done
