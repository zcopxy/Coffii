/* Coffii carousel viewer — slide nav, fit-to-viewport scaling, native screenshot mode. */
(function () {
  const stage = document.querySelector('.stage');
  const frame = document.querySelector('.stage-frame');
  if (!stage || !frame) return;

  const slides = Array.from(stage.querySelectorAll('.slide'));
  let i = 0;

  const counter = document.querySelector('.counter');
  const dotsWrap = document.querySelector('.dots');
  const prev = document.querySelector('.navbtn--prev');
  const next = document.querySelector('.navbtn--next');

  // build dots
  slides.forEach((_, k) => {
    const d = document.createElement('button');
    d.className = 'dot' + (k === 0 ? ' is-active' : '');
    d.setAttribute('aria-label', 'Slide ' + (k + 1));
    d.addEventListener('click', () => show(k));
    dotsWrap.appendChild(d);
  });
  const dots = Array.from(dotsWrap.children);

  function show(k) {
    i = (k + slides.length) % slides.length;
    slides.forEach((s, idx) => s.classList.toggle('is-active', idx === i));
    dots.forEach((d, idx) => d.classList.toggle('is-active', idx === i));
    if (counter) counter.textContent = (i + 1) + ' / ' + slides.length;
    prev.disabled = i === 0;
    next.disabled = i === slides.length - 1;
  }

  prev.addEventListener('click', () => show(i - 1));
  next.addEventListener('click', () => show(i + 1));
  document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowLeft') show(i - 1);
    if (e.key === 'ArrowRight') show(i + 1);
    if (e.key.toLowerCase() === 'n') toggleNative(false);
    if (e.key.toLowerCase() === 'a') toggleNative(true);
    if (e.key === 'Escape') exitNative();
  });

  // fit-to-viewport scaling
  function fit() {
    if (document.body.classList.contains('native')) return;
    const pad = 150;
    const s = Math.min((window.innerHeight - pad) / 1920, (window.innerWidth - 80) / 1080);
    document.documentElement.style.setProperty('--s', s.toFixed(4));
  }
  window.addEventListener('resize', fit);

  // native (screenshot) mode
  const nativeSingle = document.querySelector('.modebtn--native');
  const nativeAll = document.querySelector('.modebtn--all');

  function toggleNative(all) {
    document.body.classList.add('native');
    document.body.classList.toggle('all-native', all);
    if (!all) show(i);
    document.documentElement.style.setProperty('--s', '1');
    if (!document.querySelector('.exit-native')) {
      const exit = document.createElement('button');
      exit.className = 'exit-native';
      exit.textContent = '← Back to preview';
      exit.addEventListener('click', exitNative);
      document.body.appendChild(exit);
    }
  }
  function exitNative() {
    document.body.classList.remove('native');
    document.body.classList.remove('all-native');
    const e = document.querySelector('.exit-native');
    if (e) e.remove();
    fit();
  }
  if (nativeSingle) nativeSingle.addEventListener('click', () => toggleNative(false));
  if (nativeAll) nativeAll.addEventListener('click', () => toggleNative(true));

  show(0);
  fit();
})();
