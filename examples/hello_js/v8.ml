let print_v8_heap_statistics () =
  Js.Unsafe.js_expr "console.log(require('v8').getHeapStatistics())"
