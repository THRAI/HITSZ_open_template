TYPST ?= typst
PREVIEW ?= true
SRC ?= example/main.typ
OUT ?= build/template.pdf
FONT_PATH ?= fonts

FONT_ARGS := $(if $(wildcard $(FONT_PATH)/*),--font-path $(FONT_PATH),)

.PHONY: template clean

template: $(OUT)

$(OUT): $(SRC) hit-opening.typ hit-gb7714.csl szbachelor-checked.svg example/references.bib example/assets/thunder.svg
	@mkdir -p $(dir $(OUT))
	$(TYPST) compile --root . $(FONT_ARGS) --input preview=$(PREVIEW) $(SRC) $(OUT)

clean:
	rm -rf build
