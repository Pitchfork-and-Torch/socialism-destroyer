/**
 * Pitchfork-and-Torch — discreet projects switcher
 * Collapsed up-arrow tab → expands to sibling project links.
 * Safe to load on every public site; hides the current project.
 *
 * v7 — AXIOM + GrokLink OS, Fl1pp3r69, Trench, Ghost, Destroyer, Theater, music
 */
(function () {
  'use strict';

  if (window.__jbProjectsPanel) return;
  window.__jbProjectsPanel = true;

  var PROJECTS = [
    {
      id: 'music',
      name: 'Jon Bailey',
      blurb: 'Music · jonbailey.xyz',
      url: 'https://jonbailey.xyz/',
      isHere: function (h, p) {
        // Apex music site only — not project subdomains
        return /^(www\.)?jonbailey\.xyz$/i.test(h) && !/^\/theater(\/|$)/.test(p);
      },
    },
    {
      id: 'axiom',
      name: 'AXIOM',
      blurb: 'Optimus wardrobe',
      url: 'https://axiom.jonbailey.xyz/',
      isHere: function (h) {
        return /^axiom\.jonbailey\.xyz$/i.test(h);
      },
    },
    {
      id: 'groklink',
      name: 'GrokLink OS',
      blurb: 'Native multi-radio RTOS',
      url: 'https://github.com/Pitchfork-and-Torch/GrokLink-OS',
      isHere: function (h, p) {
        return /groklink/i.test(h) || /GrokLink-OS/i.test(h + p);
      },
    },
    {
      id: 'flipper',
      name: 'Fl1pp3r69',
      blurb: 'Flipper field ops',
      url: 'https://fl1pp3r69.jonbailey.xyz/',
      isHere: function (h, p) {
        return /fl1pp3r69|flipper69/i.test(h + p);
      },
    },
    {
      id: 'trench',
      name: 'Trench Coat',
      blurb: 'Privacy cloak',
      url: 'https://trenchcoat.jonbailey.xyz/',
      isHere: function (h, p) {
        return /^trenchcoat\.jonbailey\.xyz$/i.test(h) || /trench[-_]?coat/i.test(h + p);
      },
    },
    {
      id: 'ghost',
      name: 'Ghost Continuum',
      blurb: 'Living deception',
      url: 'https://ghost.jonbailey.xyz/',
      isHere: function (h) {
        return /^ghost\.jonbailey\.xyz$/i.test(h);
      },
    },
    {
      id: 'destroyer',
      name: 'Socialism Destroyer',
      blurb: 'Liberty arguments',
      url: 'https://destroyer.jonbailey.xyz/',
      isHere: function (h) {
        return /^destroyer\.jonbailey\.xyz$/i.test(h);
      },
    },
    {
      id: 'theater',
      name: 'Squad Theater',
      blurb: 'Watch together',
      url: 'https://jonbailey.xyz/theater/',
      isHere: function (h, p) {
        return (
          (/(^|\.)jonbailey\.xyz$/i.test(h) && /^\/theater(\/|$)/.test(p)) ||
          /^squad-theater/i.test(h)
        );
      },
    },
  ];

  var host = location.hostname.replace(/^www\./i, '');
  var path = location.pathname || '/';
  var isTheater =
    (/(^|\.)jonbailey\.xyz$/i.test(host) && /^\/theater(\/|$)/.test(path)) ||
    /^squad-theater/i.test(host);

  function boot() {
    if (!document.body || document.getElementById('jb-projects-root')) return;

    var style = document.createElement('style');
    style.id = 'jb-projects-style';
    style.textContent = [
      '#jb-projects-root{',
      'position:fixed;left:50%;bottom:max(0.55rem,env(safe-area-inset-bottom,0px));',
      'transform:translateX(-50%);z-index:2147483000;font:12px/1.35 system-ui,-apple-system,Segoe UI,sans-serif;',
      'color:#e8e6e3;pointer-events:none;isolation:isolate;',
      '}',
      '#jb-projects-root *{box-sizing:border-box;}',
      '#jb-projects-root.is-theater{',
      'bottom:max(4.6rem,calc(env(safe-area-inset-bottom,0px) + 4.6rem));',
      '}',
      '@media (min-width:1024px){',
      '#jb-projects-root.is-theater{bottom:max(2.9rem,calc(env(safe-area-inset-bottom,0px) + 2.9rem));}',
      '}',
      '#jb-projects-root .jb-p-shell{',
      'display:flex;flex-direction:column;align-items:center;gap:0.35rem;pointer-events:auto;',
      '}',
      '#jb-projects-root .jb-p-panel{',
      'width:min(18.5rem,calc(100vw - 1.5rem));',
      'max-height:0;opacity:0;overflow:hidden;pointer-events:none;',
      'transform:translateY(6px);',
      'transition:max-height .28s ease,opacity .22s ease,transform .28s ease;',
      '}',
      '#jb-projects-root.is-open .jb-p-panel{',
      'max-height:28rem;opacity:1;pointer-events:auto;transform:translateY(0);',
      '}',
      '#jb-projects-root .jb-p-card{',
      'margin:0;padding:0.7rem 0.75rem 0.55rem;',
      'border-radius:12px 12px 10px 10px;',
      'background:rgba(12,12,14,.88);',
      'border:1px solid rgba(255,255,255,.1);',
      'box-shadow:0 10px 28px rgba(0,0,0,.42),0 0 0 1px rgba(0,0,0,.25);',
      'backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);',
      '}',
      '#jb-projects-root .jb-p-label{',
      'margin:0 0 0.45rem;padding:0 0.2rem;',
      'font-size:0.65rem;letter-spacing:.14em;text-transform:uppercase;',
      'color:rgba(232,230,227,.55);font-weight:600;',
      '}',
      '#jb-projects-root .jb-p-list{',
      'list-style:none;margin:0;padding:0;display:flex;flex-direction:column;gap:0.2rem;',
      '}',
      '#jb-projects-root .jb-p-list a,',
      '#jb-projects-root .jb-p-list .jb-p-soon{',
      'display:flex;align-items:center;justify-content:space-between;gap:0.6rem;',
      'padding:0.42rem 0.5rem;border-radius:8px;text-decoration:none;',
      'color:#f2f0ec;transition:background .15s ease,color .15s ease;',
      '}',
      '#jb-projects-root .jb-p-list a:hover,',
      '#jb-projects-root .jb-p-list a:focus-visible{',
      'background:rgba(255,255,255,.08);outline:none;',
      '}',
      '#jb-projects-root .jb-p-list a:focus-visible{',
      'box-shadow:0 0 0 2px rgba(255,255,255,.25);',
      '}',
      '#jb-projects-root .jb-p-name{font-weight:600;font-size:0.82rem;}',
      '#jb-projects-root .jb-p-blurb{',
      'font-size:0.68rem;color:rgba(232,230,227,.48);white-space:nowrap;',
      '}',
      '#jb-projects-root .jb-p-soon{',
      'opacity:.55;cursor:default;user-select:none;',
      '}',
      '#jb-projects-root .jb-p-soon .jb-p-blurb{',
      'font-style:italic;letter-spacing:.02em;',
      '}',
      '#jb-projects-root .jb-p-toggle{',
      'display:inline-flex;align-items:center;justify-content:center;',
      'width:2rem;height:1.35rem;padding:0;margin:0;border:0;cursor:pointer;',
      'border-radius:999px;',
      'background:rgba(12,12,14,.72);',
      'border:1px solid rgba(255,255,255,.12);',
      'color:rgba(232,230,227,.72);',
      'box-shadow:0 4px 14px rgba(0,0,0,.28);',
      'backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);',
      'transition:background .15s ease,color .15s ease,transform .15s ease,border-color .15s ease;',
      '}',
      '#jb-projects-root .jb-p-toggle:hover,',
      '#jb-projects-root .jb-p-toggle:focus-visible{',
      'background:rgba(22,22,26,.9);color:#fff;border-color:rgba(255,255,255,.22);outline:none;',
      '}',
      '#jb-projects-root .jb-p-toggle:focus-visible{',
      'box-shadow:0 0 0 2px rgba(255,255,255,.28);',
      '}',
      '#jb-projects-root.is-open .jb-p-toggle{',
      'background:rgba(28,28,34,.94);color:#fff;border-color:rgba(255,255,255,.2);',
      '}',
      '#jb-projects-root .jb-p-toggle svg{',
      'width:12px;height:12px;display:block;',
      'transition:transform .22s ease;',
      '}',
      '#jb-projects-root.is-open .jb-p-toggle svg{transform:rotate(180deg);}',
      '@media (prefers-reduced-motion:reduce){',
      '#jb-projects-root .jb-p-panel,',
      '#jb-projects-root .jb-p-toggle svg{transition:none;}',
      '}',
    ].join('');
    document.head.appendChild(style);

    var root = document.createElement('div');
    root.id = 'jb-projects-root';
    root.setAttribute('data-jb-projects', '1');
    if (isTheater) root.classList.add('is-theater');

    var shell = document.createElement('div');
    shell.className = 'jb-p-shell';

    var panel = document.createElement('div');
    panel.className = 'jb-p-panel';
    panel.id = 'jb-projects-panel';
    panel.hidden = true;

    var card = document.createElement('div');
    card.className = 'jb-p-card';
    card.setAttribute('role', 'dialog');
    card.setAttribute('aria-label', 'Other projects by Jon Bailey');

    var label = document.createElement('p');
    label.className = 'jb-p-label';
    label.textContent = 'Other projects';
    card.appendChild(label);

    var list = document.createElement('ul');
    list.className = 'jb-p-list';

    var shown = 0;
    for (var i = 0; i < PROJECTS.length; i++) {
      var p = PROJECTS[i];
      if (p.isHere && p.isHere(host, path)) continue;

      var li = document.createElement('li');
      if (p.published === false || !p.url) {
        var soon = document.createElement('span');
        soon.className = 'jb-p-soon';
        soon.innerHTML =
          '<span class="jb-p-name"></span><span class="jb-p-blurb"></span>';
        soon.querySelector('.jb-p-name').textContent = p.name;
        soon.querySelector('.jb-p-blurb').textContent = p.blurb || 'Soon';
        li.appendChild(soon);
      } else {
        var a = document.createElement('a');
        a.href = p.url;
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        a.innerHTML =
          '<span class="jb-p-name"></span><span class="jb-p-blurb"></span>';
        a.querySelector('.jb-p-name').textContent = p.name;
        a.querySelector('.jb-p-blurb').textContent = p.blurb || '';
        li.appendChild(a);
      }
      list.appendChild(li);
      shown++;
    }

    if (!shown) return;

    card.appendChild(list);
    panel.appendChild(card);

    var toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'jb-p-toggle';
    toggle.id = 'jb-projects-toggle';
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-controls', 'jb-projects-panel');
    toggle.setAttribute('aria-label', 'Show other projects');
    toggle.title = 'Other projects';
    toggle.innerHTML =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 14l6-6 6 6"/></svg>';

    function setOpen(open) {
      root.classList.toggle('is-open', open);
      panel.hidden = !open;
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.setAttribute(
        'aria-label',
        open ? 'Hide other projects' : 'Show other projects'
      );
    }

    toggle.addEventListener('click', function (e) {
      e.stopPropagation();
      setOpen(!root.classList.contains('is-open'));
    });

    document.addEventListener('click', function (e) {
      if (!root.classList.contains('is-open')) return;
      if (!root.contains(e.target)) setOpen(false);
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && root.classList.contains('is-open')) {
        setOpen(false);
        toggle.focus();
      }
    });

    shell.appendChild(panel);
    shell.appendChild(toggle);
    root.appendChild(shell);
    document.body.appendChild(root);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
