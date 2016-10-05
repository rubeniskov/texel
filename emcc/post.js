// delete this['Module'];
//
// function _aac_decoder_data(ptr, frame_size) {
//     var buff = HEAP16.subarray((ptr >> 1), (ptr >> 1) + frame_size * 2),
//         data = new Float32Array(frame_size);
//     for (var i = 0; i < frame_size; i++) {
//         data[i] = buff[i] / 32768;
//     }
//     decoder.data(data, frame_size);
// }
//
// function _aac_decoder_error(err) {
//     decoder.error(Pointer_stringify(err));
// }
//
// function _aac_decoder_end() {
//     decoder.end();
// }
//
// var _aac_decoder_init = cwrap('aac_decoder_init'),
//     _aac_decoder_push = cwrap('aac_decoder_push', 'number', ['number', 'number']),
//     _aac_decoder_flush = cwrap('aac_decoder_flush');
//
//
// /**
//  * Public API.
//  */
// var decoder = {
//     /** @expose */
//     init: function() {
//         _aac_decoder_init();
//         return decoder;
//     },
//     /** @expose */
//     push: function(chunk) {
//         var nDataBytes = chunk.length * chunk.BYTES_PER_ELEMENT,
//             dataPtr = _malloc(nDataBytes),
//             dataHeap = new Uint8Array(HEAPU8.buffer, dataPtr, nDataBytes);
//         dataHeap.set(chunk);
//         _aac_decoder_push(dataHeap.byteOffset, chunk.length);
//         return decoder;
//     },
//     /** @expose */
//     flush: function() {
//         return decoder;
//     },
//     /** @expose */
//     data: function(data, frame_size) {
//
//     },
//     /** @expose */
//     error: function(err) {
//
//     },
//     /** @expose */
//     end: function(data, frame_size) {
//
//     }
// };
//
// var global = this['global'] ||  this;
//
// if (typeof exports !== 'undefined') {
//     if (typeof module !== 'undefined' && module.exports) {
//         /** @expose */
//         exports = module.exports = decoder;
//     }
//     /** @expose */
//     exports.decoder = decoder;
// } else {
//     /** @expose */
//     global.decoder = decoder;
// }
//
// if (typeof define === "function" && define.amd) {
//     /** @expose */
//     define([], function() {
//         return decoder;
//     });
// }
//
// NOTE: wrapped inside "(function() {" block from pre.js

function arrayBufferCopy(src, dst, dstByteOffset, numBytes) {
    dst32Offset = dstByteOffset / 4;
    var tail = (numBytes % 4);
    var src32 = new Uint32Array(src.buffer, 0, (numBytes - tail) / 4);
    var dst32 = new Uint32Array(dst.buffer);
    for (var i = 0; i < src32.length; i++) {
        dst32[dst32Offset + i] = src32[i];
    }
    for (var i = numBytes - tail; i < numBytes; i++) {
        dst[dstByteOffset + i] = src[i];
    }
}


window.Module = Module;

}).call(this);
