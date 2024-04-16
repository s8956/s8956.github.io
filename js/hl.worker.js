onmessage = ($event) => {
  importScripts('/js/code.bundle.min.js');
  self.hljs.registerAliases(['rsc'], {languageName: 'routeros'});

  const $len = $event.data.length;
  let $result = [];

  for (let $i = 0; $i < $len; ++$i) {
    const $data = $event.data[$i];
    const $lang = $data.language;
    if (self.hljs.getLanguage($lang) === undefined) $lang = 'plaintext';
    $result.push(self.hljs.highlight($data.code, {language: $lang}).value);
  }

  postMessage($result);
}
