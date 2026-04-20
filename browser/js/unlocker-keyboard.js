(function() {
  ['keydown','keyup','keypress'].forEach(e => {
    document.addEventListener(e, ev => ev.stopImmediatePropagation(), true);
  });
  document.onkeydown = null;
  document.onkeyup = null;
  document.onkeypress = null;
  if (document.body) {
    document.body.onkeydown = null;
    document.body.onkeyup = null;
  }
  console.log('%c[Unlocker] Keyboard shortcuts (Ctrl+A/C/V/X/Z etc.) restored.', 'color: #1D9E75;');
})();
