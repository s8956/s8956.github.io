onmessage = ($event) => {
  importScripts('/js/code.bundle.min.js');
  const $result = [];
  $event.data.forEach(($codeData) => {
    let $language = $codeData.language;
    if (self.hljs.getLanguage($language) === undefined) {
      $language = 'plaintext';
    }
    $result.push(
      self.hljs.highlight($codeData.code, {language: $language}).value
    );
  });
  postMessage($result);
};
