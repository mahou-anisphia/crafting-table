(function() {
  document.addEventListener('contextmenu', ev => ev.stopImmediatePropagation(), true);
  document.oncontextmenu = null;
  if (document.body) document.body.oncontextmenu = null;
  console.log('%c[Unlocker] Right-click restored.', 'color: #1D9E75;');
})();
