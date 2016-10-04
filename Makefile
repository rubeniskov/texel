.PHONY: clean

BROWSERIFY_FLAGS = \
./index.js \
--standalone texel \
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

compile_emcc:
	{ \
		node_modules/.bin/miniquery -p "targets.0.emccflags.#" ./binding.gyp; \
		node_modules/.bin/miniquery -p "targets.0.include_dirs.#" ./binding.gyp|sed -e 's/^/-I/'; \
		node_modules/.bin/miniquery -p "targets.0.sources.#" ./binding.gyp; \
	} | xargs emcc -s src/crn-decoder-asm.c -o crn-decoder-asm.js
	# echo ${TARGETS};
	#
	# for i in `find $@  -name *_cu.*`; do      \
    #     mv $$i "$$(echo $$i|sed s/_cu//)";    \
    # done
	# # for i in "${!TU[@]}"; do
	# #   printf "%s\t%s\n" "$i" "${TU[$i]}"
	# # done


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
