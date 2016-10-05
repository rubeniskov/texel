.PHONY: clean

PROJECT_NAME := $(shell node_modules/.bin/miniquery -p 'name' ./package.json)
MODULES ?= $(shell node_modules/.bin/miniquery -p 'targets.\#.target_name' ./binding.gyp)
EMCC := $(shell [ -f "$(which docker)" ] && echo "emcc" || echo "docker run --rm -v $$(pwd):/src apiaryio/emcc emcc")
EMCC_FLAGS := ""

BROWSERIFY_FLAGS = \
./index.js \
--standalone $(PROJECT_NAME) \
--debug \
--outfile ./dist/bundle.js \
--verbose

BABEL_FLAGS = \
src \
--out-dir lib \
--copy-files

UGLIFYJS_FLAGS = \
--output ./dist/bundle.min.js \
--compress \
--mangle \
--screw-ie8 \
--stats \
--mangle-props \
--verbose

all: clean build_emcc

essentials:
	if [  ! -d ./node_modules ] ; then npm install; fi;

watch:
	make watch_babel &
	make watch_browser &

watch_babel:
	mkdir -p ./dist/ ./lib/
	./node_modules/.bin/babel --watch $(BABEL_FLAGS)

watch_browser:
	mkdir -p ./dist/ ./lib/
	./node_modules/.bin/watchify $(BROWSERIFY_FLAGS)

compile: essentials compile_node compile_browser compress_browser

compile_babel:
	mkdir -p ./lib/
	./node_modules/.bin/babel $(BABEL_FLAGS)

compile_browser:
	mkdir -p ./dist/
	./node_modules/.bin/browserify $(BROWSERIFY_FLAGS)

compress_browser: compile
	cat ./dist/bundle.js \
	| ./node_modules/uglifyjs/bin/uglifyjs $(UGLIFYJS_FLAGS)

# %.o: %.cpp
# 	g++ $< -o $@ -c $(COMPILE_OPTIONS)
compile_emcc:
	@declare NAMES=($(MODULES)) \
    ; for key in "$${!NAMES[@]}" ; do \
		declare MODULE="$${NAMES[$$key]}"; \
		printf "Compile EMCC \t%s\n" "$$MODULE"; \
		{ \
				node_modules/.bin/miniquery -p "targets.$$key.emccflags.#" ./binding.gyp; \
				node_modules/.bin/miniquery -p "targets.$$key.include_dirs.#" ./binding.gyp|sed -e 's/^/-I/'; \
				node_modules/.bin/miniquery -p "targets.$$key.sources.#" ./binding.gyp; \
		}| xargs echo "$(EMCC) emcc/$${MODULE}.cpp -o lib/$${MODULE}.js" | while read emcc; do mkdir -p lib; echo "$${emcc}"; bash -c "$${emcc}"; done ;\
    done

release: release_major

publish: release_major

release_minor:
	./node_modules/.bin/npm-bump minor

release_major:
	./node_modules/.bin/npm-bump major

patch:
	./node_modules/.bin/npm-bump patch

clean:
	@rm -rf ./dist/

download:
	rm -rf vendor
	mkdir -p vendor
	wget https://github.com/BinomialLLC/crunch/archive/v104.tar.gz -S --header="accept-encoding: gzip" --directory-prefix=vendor
	tar -xzvf vendor/v104.tar.gz --directory=vendor
	mv vendor/crunch-104 vendor/crunch
	rm vendor/*.tar.gz*

	#echo ${!$MODULES[@]}
	# @for i in $${!MODULES[@]} ; do \
	#     echo $$i ; \
	# done


	#  \
	# for i in "${!targets[@]}"; \ do
	#   printf "%s\t%s\n" "$i" "${targets[$i]}"; \
	# done
	# { \
	# 	node_modules/.bin/miniquery -p "targets.0.emccflags.#" ./binding.gyp; \
	# 	node_modules/.bin/miniquery -p "targets.0.include_dirs.#" ./binding.gyp|sed -e 's/^/-I/'; \
	# 	node_modules/.bin/miniquery -p "targets.0.sources.#" ./binding.gyp; \
	# } | xargs emcc -s src/crn-decoder-asm.c -o crn-decoder-asm.js
	# echo ${MODULES};
	#
	# for i in `find $@  -name *_cu.*`; do      \
		#     mv $$i "$$(echo $$i|sed s/_cu//)";    \
		# done
	# # for i in "${!TU[@]}"; do
	# #   printf "%s\t%s\n" "$i" "${TU[$i]}"
	# # done
