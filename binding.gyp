{
    "targets": [{
        "target_name": "encoder",
        "sources": []
      }, {
        "target_name": "decoder",
        "sources": [
        ],
        "include_dirs": [
        ],
        "emccflags": [
            "--pre-js pre.js",
            "--post-js post.js",
            "--memory-init-file 0",
            "-O3",
            "-lm",
            "-v",
            "--closure 1",
            "-s ASSERTIONS=0",
            "-s NO_EXIT_RUNTIME=1",
            "-s TOTAL_MEMORY=16777216",
            "-s ALLOW_MEMORY_GROWTH=0",
            "-s ASSERTIONS=0",
            "-s INVOKE_RUN=0",
            "-s DISABLE_EXCEPTION_CATCHING=1",
            "-s NO_FILESYSTEM=1",
            "-s EXPORTED_FUNCTIONS=\"['_crn_decoder_push', '_crn_decoder_flush', '_crn_decoder_init']\""
        ],
        "cflags": [
            "-std=c++11 -w"
        ],
        "conditions": [
            ["OS!=\"win\"", {
                "cflags+": ["-std=c++11"],
                "cflags_c+": ["-std=c++11"],
                "cflags_cc+": ["-std=c++11"]
            }],
            ["OS==\"mac\"", {
                "xcode_settings": {
                    "OTHER_CPLUSPLUSFLAGS": ["-std=c++11", "-stdlib=libc++", "-w"],
                    "OTHER_LDFLAGS": ["-stdlib=libc++"],
                    "MACOSX_DEPLOYMENT_TARGET": "10.7"
                }
            }]
        ]
    }]
}
