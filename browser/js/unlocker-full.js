(function() {
  const events = [
    'copy','cut','paste','keydown','keyup','keypress',
    'contextmenu','selectstart','dragstart','mousedown',
    'mouseup','click','dblclick'
  ];
  events.forEach(e => {
    document.addEventListener(e, ev => ev.stopImmediatePropagation(), true);
  });

  const s = document.createElement('style');
  s.id = '__unlocker__';
  s.textContent = '* { user-select: auto !important; -webkit-user-select: auto !important; pointer-events: auto !important; }';
  document.head.appendChild(s);

  document.oncopy = null;
  document.oncut = null;
  document.onpaste = null;
  document.onkeydown = null;
  document.onkeyup = null;
  document.oncontextmenu = null;
  document.onselectstart = null;
  document.ondragstart = null;

  [document.body, document.documentElement].forEach(el => {
    if (!el) return;
    el.oncopy = null;
    el.oncut = null;
    el.onpaste = null;
    el.onkeydown = null;
    el.onkeyup = null;
    el.oncontextmenu = null;
    el.onselectstart = null;
    el.ondragstart = null;
  });

  console.log('%c[Unlocker] Done — copy, paste, select, right-click, devtools all restored.', 'color: #1D9E75; font-weight: bold;');
})();
