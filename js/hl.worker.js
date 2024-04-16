onmessage = (event) => {
  importScripts('/js/code.bundle.min.js');
  const result = self.hljs.highlightAuto(event.data);
  postMessage(result.value);
};
