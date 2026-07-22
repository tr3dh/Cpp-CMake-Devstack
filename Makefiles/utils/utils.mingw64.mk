ping:
	echo pong

SHELL := bash
.ONESHELL:

PROJECT_NAME ?= proj

DOXYDIR ?= doxy
DOXYFILE ?= $(DOXYDIR)/Doxyfile.$(PROJECT_NAME)

INPUT ?= src Procs Tests
OUTPUT ?= docs/doku/$(PROJECT_NAME)

PROJECT_LOGO ?= Recc/Compilation/icon.png
PROJECT_ICON ?= Recc/Compilation/icon.png

configDocs:
	@mkdir -p $(DOXYDIR)
	@doxygen -g $(DOXYFILE)
	@python - <<'PY'
	import re
	from pathlib import Path

	path = Path("$(DOXYFILE)")
	text = path.read_text(encoding="utf-8")

	replacements = {
		r'(OUTPUT_DIRECTORY\s*=).*':  		r'\1 $(OUTPUT)',
		r'(PROJECT_NAME\s*=).*':      		r'\1 "$(PROJECT_NAME)"',
		r'(PROJECT_LOGO\s*=).*':      		r'\1 $(PROJECT_LOGO)',
		r'(PROJECT_ICON\s*=).*':      		r'\1 $(PROJECT_ICON)',

		r'(INPUT\s*=).*':             		r'\1 $(INPUT) README.md docs/pages',
		r'(RECURSIVE\s*=).*':         		r'\1 YES',
		r'(FILE_PATTERNS\s*=).*':     		r'\1 *.h *.cpp *.md',

		r'(GENERATE_TREEVIEW\s*=).*':     	r'\1 YES',
		r'(EXTRACT_ALL\s*=).*':           	r'\1 YES',
		r'(EXTRACT_PRIVATE\s*=).*':        	r'\1 YES',
		r'(EXTRACT_STATIC\s*=).*':         	r'\1 YES',
		r'(EXTRACT_LOCAL_METHODS\s*=).*':  	r'\1 YES',
		r'(EXTRACT_LOCAL_VARS\s*=).*':     	r'\1 YES',

		r'(HAVE_DOT\s*=).*':              	r'\1 YES',
		r'(CLASS_GRAPH\s*=).*':           	r'\1 YES',
		r'(COLLABORATION_GRAPH\s*=).*':  	r'\1 YES',
		r'(INCLUDE_GRAPH\s*=).*':         	r'\1 YES',
		r'(INCLUDED_BY_GRAPH\s*=).*':     	r'\1 YES',
		r'(CALL_GRAPH\s*=).*':            	r'\1 YES',
		r'(CALLER_GRAPH\s*=).*':          	r'\1 YES',
		r'(GROUP_GRAPHS\s*=).*':          	r'\1 YES',
		r'(GRAPHICAL_HIERARCHY\s*=).*':   	r'\1 YES',

		r'(SHOW_NAMESPACES\s*=).*':        	r'\1 YES',
		r'(OPTIMIZE_OUTPUT_FOR_C\s*=).*':  	r'\1 YES',
		r'(HIDE_UNDOC_MEMBERS\s*=).*':   	r'\1 NO',
		r'(INLINE_SIMPLE_STRUCTS\s*=).*': 	r'\1 NO',
		r'(ALPHABETICAL_INDEX\s*=).*': 		r'\1 NO',

		r'(DISABLE_INDEX\s*=).*': 			r'\1 NO',
		r'(FULL_SIDEBAR\s*=).*': 			r'\1 NO',

		r'(USE_MDFILE_AS_MAINPAGE\s*=).*': 	r'\1 README.md',
		r'(USE_MATHJAX\s*=).*':             r'\1 YES',
		r'(JAVADOC_AUTOBRIEF\s*=).*':       r'\1 YES',
		
# Doxygen Awesome
		r'(HTML_EXTRA_STYLESHEET\s*=).*':	r'\1 thirdParty/doxygen-awesome-css/doxygen-awesome.css thirdParty/doxygen-awesome-css/doxygen-awesome-sidebar-only.css',
		r'(HTML_COLORSTYLE\s*=).*': 		r'\1 TOGGLE',
		
	}

	for pattern, replacement in replacements.items(): text = re.sub(pattern, replacement, text)

	path.write_text(text, encoding="utf-8")
	PY

clearDocs:
	rm -f $(DOXYFILE)
	rm -f $(DOXYFILE).bak

buildDocs:
	@mkdir -p $(OUTPUT)
	@doxygen $(DOXYFILE)

displayDocs:
	@echo off
	start "" docs/index.html

docs: clearDocs configDocs buildDocs displayDocs

genltex:
	cd docs/doku/$(PROJECT_NAME)/latex && make

DOKU_DIR ?= __build/
copyltex:
	cp docs/doku/$(PROJECT_NAME)/latex/refman.pdf $(DOKU_DIR)
	mv $(DOKU_DIR)/refman.pdf $(DOKU_DIR)/$(PROJECT_NAME)Doku.doxy.pdf

package:
		
	@echo "CWD: $(CURDIR)"
	rm -rf tmp
	mkdir tmp

	mkdir -p tmp/__build
	find __build \
		\( -path '*/tmp/*' -o -path '*/CMakeFiles/*' -o -path '*/lib/*' -o -path '*/thirdParty/*' \) -prune -o \
		\( -type f -name '*.exe' -o -name '*.dll' -o -name 'steam_appid.txt' \) \
		-exec cp --parents {} tmp/ \;

	cp -r Recc tmp/
	cp -r docs tmp/
	cp -r thirdPartyLicenses tmp/
#	cp -r Batch tmp/
	cp -f VERSION tmp/
	cp -f LICENSE tmp/
	cp -f README.md tmp/
	cp -f README.de.md tmp/
	cp -f MAINTAINING.md tmp/
	cp -f CONTRIBUTING.md tmp/

	mkdir -p __OUT
	zip -r __OUT/$(PROJECT_NAME).zip tmp/*

	rm -rf tmp

exportPackage: build rbuild package