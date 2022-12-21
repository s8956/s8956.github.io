'use strict';

function init() {
  addEventListener('load', () => {
    highlight();
  });
}

function highlight() {
  const $codes = document.querySelectorAll('pre > code');
  const $length = $codes.length;
  if ($length === 0) return 0;

  $codes.forEach(($code) => {
    const $no_hl = ['language-nohighlight', 'language-plaintext', 'language-text'];
    if ($no_hl.some(($i) => $code.classList.contains($i))) return 0;

    $code.classList.add('hljs');
    const worker = new Worker('/js/vendor/hljs/worker.min.js');
    worker.onmessage = ($event) => {
      $code.innerHTML = $event.data;
    }
    worker.postMessage($code.textContent);
  });
}

init();
