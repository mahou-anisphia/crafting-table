(function() {
  ['selectstart','dragstart'].forEach(e => {
    document.addEventListener(e, ev => ev.stopImmediatePropagation(), true);
  });
  document.onselectstart = null;
  document.ondragstart = null;
  const s = document.createElement('style');
  s.id = '__unlocker_select__';
  s.textContent = '* { user-select: auto !important; -webkit-user-select: auto !important; }';
  document.head.appendChild(s);
  console.log('%c[Unlocker] Text selection restored.', 'color: #1D9E75;');
})();
