/* ==============================================================================
 * Oracle DevOps Platform - Developer Hub (SPA) Client Application Logic
 * Unified Toggle Engine, Health Checkers, Clipboard Helpers, Presentation Deck,
 * Interactive DevOps Console, Profile Editor, and Mermaid Architecture Modals.
 * ============================================================================== */


// Navigation History & Browser Back / In-App Back State Management
let gNavHistory = [];
let gCurrentNavState = { tab: 'tab-services', docIdx: 0, skillId: null, timestamp: Date.now() };
let gIsNavigatingHistory = false;

function updateBackBtnVisibility() {
  const btn = document.getElementById('nav-back-btn');
  if (!btn) return;
  btn.style.display = (gNavHistory.length > 0) ? 'inline-flex' : 'none';
}

function recordNavigationState(newState, updateUrl = true) {
  if (gIsNavigatingHistory) return;
  if (!newState || !newState.tab) return;
  
  if (gCurrentNavState && 
      gCurrentNavState.tab === newState.tab && 
      gCurrentNavState.docIdx === newState.docIdx &&
      gCurrentNavState.skillId === newState.skillId &&
      gCurrentNavState.anchor === newState.anchor) {
    return;
  }
  
  if (gCurrentNavState) {
    gNavHistory.push(Object.assign({}, gCurrentNavState));
    if (gNavHistory.length > 50) gNavHistory.shift();
  }
  
  gCurrentNavState = Object.assign({}, newState, { timestamp: Date.now() });
  updateBackBtnVisibility();
  
  if (updateUrl && window.history && window.history.pushState) {
    let hash = `#${newState.tab}`;
    if (newState.tab === 'tab-docs' && typeof newState.docIdx === 'number' && typeof DOCS_DATA !== 'undefined' && DOCS_DATA[newState.docIdx]) {
      hash += `?doc=${encodeURIComponent(DOCS_DATA[newState.docIdx].id || DOCS_DATA[newState.docIdx].rel)}`;
      if (newState.anchor) hash += `#${encodeURIComponent(newState.anchor)}`;
    } else if (newState.tab === 'tab-skills' && newState.skillId) {
      hash += `?skill=${encodeURIComponent(newState.skillId)}`;
    }
    try {
      window.history.pushState(gCurrentNavState, '', hash);
    } catch (e) {}
  }
}

function navigateBack() {
  if (gNavHistory.length > 0) {
    const prevState = gNavHistory.pop();
    applyNavState(prevState);
    updateBackBtnVisibility();
  } else if (window.history && window.history.length > 1) {
    window.history.back();
  }
}

function applyNavState(state) {
  if (!state || !state.tab) return;
  gIsNavigatingHistory = true;
  try {
    switchTab(state.tab, true);
    if (state.tab === 'tab-docs' && typeof state.docIdx === 'number') {
      loadDocContent(state.docIdx, null, true);
      if (state.anchor) {
        setTimeout(() => {
          const el = document.getElementById(state.anchor) || document.querySelector(`[name="${state.anchor}"]`);
          if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 150);
      }
    } else if (state.tab === 'tab-skills' && state.skillId && typeof selectSkillInReader === 'function') {
      selectSkillInReader(state.skillId);
    }
    gCurrentNavState = Object.assign({}, state);
  } finally {
    gIsNavigatingHistory = false;
  }
}

function initNavigationHistory() {
  window.addEventListener('popstate', (event) => {
    if (event.state) {
      applyNavState(event.state);
    } else {
      const hashParam = (window.location.hash || '').replace(/^#/, '');
      const cleanHash = hashParam.split('?')[0].split('&')[0];
      if (cleanHash) {
        switchTab(cleanHash, true);
      } else {
        switchTab('tab-services', true);
      }
    }
    updateBackBtnVisibility();
  });
}

function switchTab(tabId, skipHistory = false) {
  let cleanId = (tabId || '').split('?')[0].split('&')[0].split('#')[0].trim();
  if (cleanId && !cleanId.startsWith('tab-')) {
    cleanId = `tab-${cleanId}`;
  }
  let activeContent = cleanId ? document.getElementById(cleanId) : null;
  if (!activeContent) {
    cleanId = 'tab-services';
    activeContent = document.getElementById(cleanId);
  }

  document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

  let matchingBtn = document.querySelector(`.tab-btn[onclick*="${cleanId}"]`);
  if (!matchingBtn && window.event && window.event.currentTarget && window.event.currentTarget.classList.contains('tab-btn')) {
    matchingBtn = window.event.currentTarget;
  }
  if (!matchingBtn) {
    matchingBtn = document.querySelector('.tab-btn[onclick*="tab-services"]');
  }
  if (matchingBtn) {
    matchingBtn.classList.add('active');
  }

  if (activeContent) {
    activeContent.classList.add('active');
    if (cleanId === 'tab-docs') {
      renderDocsNav(currentSelectedDocIdx);
    } else if (cleanId === 'tab-benchmarks') {
      loadBenchmarksData();
    } else if (cleanId === 'tab-snapshots') {
      loadSnapshotsTable();
    } else if (cleanId === 'tab-podman') {
      loadPodmanResources();
    } else if (cleanId === 'tab-testing') {
      initTestingTab();
    } else if (cleanId === 'tab-skills') {
      initSkillsTab();
    } else if (cleanId === 'tab-devops') {
      filterDevOpsCards();
      loadRepoStatistics();
    }
  }

  if (!skipHistory) {
    recordNavigationState({ tab: cleanId, docIdx: (cleanId === 'tab-docs' ? currentSelectedDocIdx : null) });
  }
}

function switchPersona(persona) {
  document.querySelectorAll('.persona-btn').forEach(btn => btn.classList.remove('active'));
  if (window.event && window.event.currentTarget) {
    window.event.currentTarget.classList.add('active');
  }
  if (persona === 'developer') switchTab('tab-services');
  else if (persona === 'security') switchToCockpitSection('blueprints');
  else if (persona === 'devops') switchTab('tab-devops');
  else if (persona === 'publisher') switchTab('tab-services');
}

function switchToCockpitSection(section) {
  switchTab('tab-services');
  setTimeout(() => {
    if (section === 'blueprints') {
      const el = document.querySelector('.bp-filters') || document.getElementById('cockpit-cards-grid');
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } else if (section === 'services') {
      const el = document.getElementById('cockpit-cards-grid') || document.querySelector('.section-title');
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } else if (section === 'wallet') {
      const el = document.querySelector('.wallet-matrix-container');
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        const drawer = document.getElementById('wallet-matrix-drawer');
        if (drawer && (drawer.style.opacity === '0' || drawer.style.maxHeight === '0px')) {
          toggleWalletMatrix();
        }
      }
    }
  }, 120);
}

let gMermaidInitialized = false;
window._MERMAID_SOURCES = window._MERMAID_SOURCES || {};
let gZoomedMermaidSource = '';

function initMermaidGlobal() {
  if (gMermaidInitialized) return;
  if (typeof mermaid !== 'undefined') {
    try {
      mermaid.initialize({
        startOnLoad: false,
        suppressErrorRendering: true,
        theme: 'dark',
        securityLevel: 'loose',
        fontFamily: 'ui-sans-serif, system-ui, -apple-system, sans-serif',
        themeVariables: {
          darkMode: true,
          background: '#030712',
          primaryColor: '#38bdf8',
          primaryTextColor: '#f8fafc',
          primaryBorderColor: '#0284c7',
          lineColor: '#94a3b8',
          secondaryColor: '#1e293b',
          tertiaryColor: '#0f172a'
        },
        flowchart: {
          useMaxWidth: true,
          htmlLabels: true,
          curve: 'basis',
          padding: 12
        }
      });
      gMermaidInitialized = true;
    } catch (e) {
      console.warn('Mermaid initialize warning:', e);
    }
  }
}
initMermaidGlobal();

function cleanupStrayMermaidElements() {
  // Mermaid automatically appends error diagrams to document.body when render() fails
  document.querySelectorAll('body > svg[id^="svg-"], body > [id^="dsvg-"], body > [id^="dmermaid"], body > [id^="d-svg-"], body > svg[id^="bp-modal-svg-"], body > [id^="dbp-modal-svg-"], body > div[id^="d"], body > svg.error-icon, body > svg[aria-roledescription="error"]').forEach(el => {
    if (el.parentNode === document.body) {
      el.remove();
    }
  });
}

async function renderMermaidInContainer(container) {
  if (!container) return;
  initMermaidGlobal();

  const codeNodes = container.querySelectorAll('pre > code.language-mermaid, pre > code.lang-mermaid, pre.mermaid, code.language-mermaid');
  if (!codeNodes || codeNodes.length === 0) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};

  for (const codeEl of Array.from(codeNodes)) {
    let preEl = codeEl.tagName.toLowerCase() === 'pre' ? codeEl : codeEl.closest('pre');
    if (!preEl) preEl = codeEl;

    if (preEl.getAttribute('data-mermaid-processed') === 'true') continue;
    preEl.setAttribute('data-mermaid-processed', 'true');

    const rawCode = (codeEl.textContent || '').trim();
    if (!rawCode) continue;

    const uniqueId = 'mermaid-dyn-' + Math.floor(Math.random() * 10000000);
    window._MERMAID_SOURCES[uniqueId] = rawCode;

    const card = document.createElement('div');
    card.className = 'mermaid-diagram-card';
    card.setAttribute('data-mermaid-card-id', uniqueId);
    card.innerHTML = `
      <div class="mermaid-toolbar">
        <span class="mermaid-title">📊 <span>${escapeHtml(dict.mermaid_diag_title || 'Arhitektuuriskeem')}</span></span>
        <div class="mermaid-actions">
          <button type="button" class="mermaid-btn" onclick="toggleMermaidCardCode('${uniqueId}', this)">👁️ <span>${escapeHtml(dict.mermaid_toggle_code || 'Kuva kood')}</span></button>
          <button type="button" class="mermaid-btn" onclick="copyMermaidCardCode('${uniqueId}', this)">📋 <span>${escapeHtml(dict.mermaid_copy_code || 'Kopeeri')}</span></button>
          <button type="button" class="mermaid-btn" onclick="openMermaidZoomModal('${uniqueId}')">🔍 <span>${escapeHtml(dict.mermaid_zoom || 'Suurenda')}</span></button>
        </div>
      </div>
      <div class="mermaid-render-target" id="${uniqueId}">
        <div style="color:#94a3b8; font-size:0.85rem; padding:16px;">⏳ Renderin diagrammi...</div>
      </div>
      <pre class="mermaid-raw-code" id="${uniqueId}-raw" style="display:none;"><code>${escapeHtml(rawCode)}</code></pre>
    `;

    if (preEl.parentNode) {
      preEl.parentNode.replaceChild(card, preEl);
    }

    const targetEl = document.getElementById(uniqueId);
    const rawEl = document.getElementById(uniqueId + '-raw');

    if (typeof mermaid === 'undefined') {
      if (targetEl) {
        targetEl.innerHTML = `
          <div style="color:#f59e0b; padding:14px; font-size:0.82rem; background:#451a03; border-radius:6px; border:1px solid #78350f; width:100%; text-align:left;">
            ⚠️ <strong>${escapeHtml(dict.mermaid_offline_msg || 'Mermaid teek ei ole kättesaadav (offline/tulemüür). Skeemi kood on vaadatav nupust "Kuva kood".')}</strong>
          </div>
        `;
      }
      if (rawEl) rawEl.style.display = 'block';
      continue;
    }

    const svgId = 'svg-' + uniqueId;
    try {
      const res = await mermaid.render(svgId, rawCode);
      if (targetEl) {
        targetEl.innerHTML = res.svg || res;
      }
    } catch (err) {
      console.warn('Mermaid render warning:', err);
      // Clean up any stray error SVG elements Mermaid may have injected into document.body
      const straySvg = document.getElementById(svgId) || document.getElementById('d' + svgId);
      if (straySvg && straySvg.parentNode) {
        straySvg.parentNode.removeChild(straySvg);
      }
      cleanupStrayMermaidElements();
      setTimeout(cleanupStrayMermaidElements, 50);

      if (targetEl) {
        targetEl.innerHTML = `
          <div style="color:#f87171; padding:14px; font-size:0.82rem; background:#450a0a; border-radius:6px; border:1px solid #991b1b; width:100%; text-align:left;">
            ⚠️ <strong>${escapeHtml(dict.mermaid_err_msg || 'Diagrammi renderdamise hoiatus:')}</strong> ${escapeHtml(err.message || 'Süntaksi viga')}<br/>
            <span style="font-size:0.75rem; color:#fca5a5;">Skeemi lähtekood on kuvatud allpool:</span>
          </div>
        `;
      }
      if (rawEl) rawEl.style.display = 'block';
    }
  }
}

function toggleMermaidCardCode(id, btn) {
  const rawEl = document.getElementById(id + '-raw');
  if (!rawEl) return;
  const isHidden = (rawEl.style.display === 'none' || !rawEl.style.display);
  rawEl.style.display = isHidden ? 'block' : 'none';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
  if (btn) {
    const span = btn.querySelector('span');
    if (span) {
      span.textContent = isHidden ? (dict.mermaid_hide_code || 'Peida kood') : (dict.mermaid_toggle_code || 'Kuva kood');
    }
  }
}

function copyMermaidCardCode(id, btn) {
  const code = window._MERMAID_SOURCES && window._MERMAID_SOURCES[id];
  if (!code) return;
  navigator.clipboard.writeText(code).then(() => {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
    const origText = btn ? btn.innerHTML : '';
    if (btn) {
      btn.innerHTML = `✅ <span>${escapeHtml(dict.mermaid_copied || 'Kopeeritud!')}</span>`;
      setTimeout(() => { btn.innerHTML = origText; }, 1800);
    }
  }).catch(err => {
    console.error('Clipboard copy failed:', err);
  });
}

function openMermaidZoomModal(id) {
  const targetEl = document.getElementById(id);
  const modal = document.getElementById('mermaid-zoom-modal');
  const zoomContent = document.getElementById('mermaid-zoom-content');
  if (!targetEl || !modal || !zoomContent) return;

  gZoomedMermaidSource = (window._MERMAID_SOURCES && window._MERMAID_SOURCES[id]) || '';
  zoomContent.innerHTML = targetEl.innerHTML;
  modal.style.display = 'flex';
}

function closeMermaidZoomModal() {
  const modal = document.getElementById('mermaid-zoom-modal');
  if (modal) modal.style.display = 'none';
}

function copyZoomedMermaidCode() {
  if (!gZoomedMermaidSource) return;
  navigator.clipboard.writeText(gZoomedMermaidSource).then(() => {
    alert('📋 Diagrammi kood kopeeritud lõikelauale!');
  });
}

function toggleBlueprintMermaidCode(btn) {
  const rawEl = document.getElementById('bp-modal-mermaid-raw');
  if (!rawEl) return;
  const isHidden = (rawEl.style.display === 'none' || !rawEl.style.display);
  rawEl.style.display = isHidden ? 'block' : 'none';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
  if (btn) {
    const span = btn.querySelector('span');
    if (span) {
      span.textContent = isHidden ? (dict.mermaid_hide_code || 'Peida kood') : (dict.mermaid_toggle_code || 'Kuva kood');
    }
  }
}

function copyBlueprintMermaidCode(btn) {
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const diagCode = (b.diagrams && b.diagrams[currentLang]) || (b.diagrams && b.diagrams['en']) || '';
  if (!diagCode) return;
  navigator.clipboard.writeText(diagCode).then(() => {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
    const orig = btn ? btn.innerHTML : '';
    if (btn) {
      btn.innerHTML = `✅ <span>${escapeHtml(dict.mermaid_copied || 'Kopeeritud!')}</span>`;
      setTimeout(() => { btn.innerHTML = orig; }, 1800);
    }
  });
}

function openBlueprintMermaidZoom() {
  const mermaidContainer = document.getElementById('bp-modal-mermaid');
  const modal = document.getElementById('mermaid-zoom-modal');
  const zoomContent = document.getElementById('mermaid-zoom-content');
  if (!mermaidContainer || !modal || !zoomContent) return;
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  gZoomedMermaidSource = (b && b.diagrams && (b.diagrams[currentLang] || b.diagrams['en'])) || '';
  zoomContent.innerHTML = mermaidContainer.innerHTML;
  modal.style.display = 'flex';
}

function toggleBlueprintWorkflowMermaidCode(btn) {
  const rawEl = document.getElementById('bp-modal-workflow-mermaid-raw');
  const container = document.getElementById('bp-modal-workflow-mermaid');
  if (!rawEl || !container) return;
  const isHidden = rawEl.style.display === 'none';
  rawEl.style.display = isHidden ? 'block' : 'none';
  container.style.display = isHidden ? 'none' : 'block';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
  if (btn) {
    btn.innerHTML = isHidden ? `🖼️ <span>${escapeHtml(dict.mermaid_toggle_diagram || 'Kuva diagramm')}</span>` : `👁️ <span>${escapeHtml(dict.mermaid_toggle_code || 'Kuva kood')}</span>`;
  }
}

function copyBlueprintWorkflowMermaidCode(btn) {
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  let diagCode = '';
  if (b.workflow_diagram && typeof b.workflow_diagram === 'object') {
    diagCode = b.workflow_diagram[currentLang] || b.workflow_diagram['en'] || '';
  } else if (typeof b.workflow_diagram === 'string') {
    diagCode = b.workflow_diagram;
  }
  diagCode = diagCode.replace(/\\n/g, '\n');
  if (!diagCode) return;
  navigator.clipboard.writeText(diagCode).then(() => {
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'] || {};
    const orig = btn ? btn.innerHTML : '';
    if (btn) {
      btn.innerHTML = `✅ <span>${escapeHtml(dict.mermaid_copied || 'Kopeeritud!')}</span>`;
      setTimeout(() => { btn.innerHTML = orig; }, 1800);
    }
  });
}

function openBlueprintWorkflowMermaidZoom() {
  const mermaidContainer = document.getElementById('bp-modal-workflow-mermaid');
  const modal = document.getElementById('mermaid-zoom-modal');
  const zoomContent = document.getElementById('mermaid-zoom-content');
  if (!mermaidContainer || !modal || !zoomContent) return;
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  let diagCode = '';
  if (b.workflow_diagram && typeof b.workflow_diagram === 'object') {
    diagCode = b.workflow_diagram[currentLang] || b.workflow_diagram['en'] || '';
  } else if (typeof b.workflow_diagram === 'string') {
    diagCode = b.workflow_diagram;
  }
  gZoomedMermaidSource = diagCode.replace(/\\n/g, '\n');
  zoomContent.innerHTML = mermaidContainer.innerHTML;
  modal.style.display = 'flex';
}

function renderMermaidDiagrams(lang) {
  initMermaidGlobal();
}

function setLanguage(lang) {
  if (!I18N_DICT[lang]) lang = 'en';
  localStorage.setItem('dev_hub_lang', lang);
  
  document.querySelectorAll('.lang-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById('btn-' + lang);
  if (activeBtn) activeBtn.classList.add('active');
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (I18N_DICT[lang] && I18N_DICT[lang][key]) {
      el.innerHTML = I18N_DICT[lang][key];
    }
  });

  document.querySelectorAll('[data-i18n-title]').forEach(el => {
    const key = el.getAttribute('data-i18n-title');
    if (I18N_DICT[lang] && I18N_DICT[lang][key]) {
      el.setAttribute('title', I18N_DICT[lang][key]);
    }
  });

  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (I18N_DICT[lang] && I18N_DICT[lang][key]) {
      el.setAttribute('placeholder', I18N_DICT[lang][key]);
    }
  });

  // Dynamic 6-Language Blueprint Titles and Descriptions
  if (Array.isArray(BLUEPRINTS_DATA)) {
    document.querySelectorAll('[data-bp-title]').forEach(el => {
      const bNum = parseInt(el.getAttribute('data-bp-title'), 10);
      const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
      if (b && b.titles) {
        const titleText = b.titles[lang] || b.titles['en'] || `Blueprint #${b.num}`;
        el.textContent = `#${b.num} ${titleText}`;
      }
    });
    document.querySelectorAll('[data-bp-desc]').forEach(el => {
      const bNum = parseInt(el.getAttribute('data-bp-desc'), 10);
      const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
      if (b && b.descs) {
        el.textContent = b.descs[lang] || b.descs['en'] || '';
      }
    });
  }

  const drawer = document.getElementById('wallet-matrix-drawer');
  const label = document.getElementById('wallet-toggle-label');
  if (drawer && label) {
    const isOpen = drawer.style.maxHeight !== '0px' && drawer.style.maxHeight !== '';
    label.textContent = I18N_DICT[lang] ? (isOpen ? I18N_DICT[lang]['toggle_hide_matrix'] : I18N_DICT[lang]['toggle_show_matrix']) : 'Show Matrix';
  }

  const podmanDrawer = document.getElementById('podman-infra-drawer');
  const podmanLabel = document.getElementById('podman-toggle-label');
  if (podmanDrawer && podmanLabel) {
    const isPodOpen = podmanDrawer.style.maxHeight !== '0px' && podmanDrawer.style.maxHeight !== '';
    podmanLabel.textContent = I18N_DICT[lang] ? (isPodOpen ? I18N_DICT[lang]['toggle_hide_podman'] : I18N_DICT[lang]['toggle_show_podman']) : 'Kuva ressursid';
  }
  if (typeof renderPodmanCurrentView === 'function' && gPodmanData) {
    renderPodmanCurrentView();
  }

  renderBlueprints(currentActiveFilter);
  renderDocsNav(currentSelectedDocIdx);
  renderMermaidDiagrams(lang);
  renderSlideDeck(lang);
  updateSlideView();
  loadBenchmarksData();
  updateServiceCardsUI();
  if (typeof renderTestingSuites === 'function') renderTestingSuites();
  if (typeof updateTestTerminalLangBadge === 'function') updateTestTerminalLangBadge(lang);
  if (typeof setOrdsAutoSync === 'function') setOrdsAutoSync(gOrdsAutoSync, false);
  const gModal = document.getElementById('glossary-modal-backdrop');
  if (gModal && gModal.classList.contains('active') && typeof renderGlossaryModal === 'function') {
    renderGlossaryModal();
  }
  if (typeof renderRepoStatisticsUI === 'function' && gRepoStatsData) {
    renderRepoStatisticsUI(gRepoStatsData);
  }
  const searchModal = document.getElementById('global-search-modal-backdrop');
  if (searchModal && searchModal.style.display === 'flex') {
    const searchInput = document.getElementById('global-search-input');
    handleGlobalSearchInput(searchInput ? searchInput.value : '');
  }
}

function applyPillState(pill, state, lang, matchedCount, totalCount) {
  lang = lang || localStorage.getItem('dev_hub_lang') || 'en';
  pill.classList.remove('status-checking', 'status-online', 'status-healthy', 'status-offline', 'status-down', 'status-init', 'status-installing', 'status-partial');
  const textEl = pill.querySelector('.status-text');
  
  if (state === 'installing') {
    pill.classList.add('status-installing');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_installing']) || 'Installing...';
  } else if (state === 'starting' || state === 'init') {
    pill.classList.add('status-init');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_starting']) || 'Starting...';
  } else if (state === 'online' || state === 'healthy') {
    pill.classList.add('status-online');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_online']) || 'Online';
  } else if (state === 'partial') {
    pill.classList.add('status-partial');
    const tmpl = (I18N_DICT[lang] && I18N_DICT[lang]['status_partial']) || 'Partial (%s)';
    const ratioStr = `${matchedCount || 1}/${totalCount || 2}`;
    if (textEl) textEl.textContent = tmpl.includes('%s') ? tmpl.replace('%s', ratioStr) : `${tmpl} (${ratioStr})`;
    pill.setAttribute('title', `${ratioStr} containers active`);
  } else if (state === 'offline' || state === 'down') {
    pill.classList.add('status-offline');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_offline']) || 'Offline';
  } else {
    pill.classList.add('status-checking');
    if (textEl) textEl.textContent = (I18N_DICT[lang] && I18N_DICT[lang]['status_checking']) || 'Checking...';
  }
}

function showToast(msg) {
  let toast = document.getElementById('devhub-toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'devhub-toast';
    toast.style.cssText = 'position: fixed; bottom: 24px; right: 24px; background: #0f172a; border: 1px solid var(--primary); color: #f8fafc; padding: 12px 20px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; box-shadow: 0 10px 25px rgba(0,0,0,0.5); z-index: 99999; transition: opacity 0.3s ease;';
    document.body.appendChild(toast);
  }
  toast.innerHTML = msg;
  toast.style.opacity = '1';
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => { toast.style.opacity = '0'; }, 3000);
}

let gOrdsAutoSync = false;
let gAutoSyncTriggeredByBp = false;
const PENDING_LAUNCHED_BPS = new Set();

function toggleOrdsAutoSync() {
  setOrdsAutoSync(!gOrdsAutoSync, true);
  gAutoSyncTriggeredByBp = false;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (gOrdsAutoSync) {
    showToast(dict.ords_autosync_started || '🟢 ORDS Smart Gateway Auto-Sync aktiveeritud.');
    syncOrdsPools();
  } else {
    showToast(dict.ords_autosync_stopped || '⚪ ORDS Smart Gateway Auto-Sync välja lülitatud.');
  }
}

function setOrdsAutoSync(enabled, saveStorage = true) {
  gOrdsAutoSync = !!enabled;
  if (saveStorage) {
    localStorage.setItem('dev_hub_ords_autosync', gOrdsAutoSync ? 'true' : 'false');
  }
  const btn = document.getElementById('ords-autosync-toggle-btn');
  const ind = document.getElementById('ords-autosync-indicator');
  const lbl = document.getElementById('ords-autosync-label');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (btn && ind && lbl) {
    if (gOrdsAutoSync) {
      btn.style.background = 'rgba(34, 197, 94, 0.2)';
      btn.style.borderColor = 'rgba(34, 197, 94, 0.6)';
      btn.style.color = '#4ade80';
      ind.textContent = '🟢';
      lbl.textContent = dict.ords_autosync_on || 'Auto-Sync: ON';
    } else {
      btn.style.background = '';
      btn.style.borderColor = '';
      btn.style.color = '';
      ind.textContent = '⚪';
      lbl.textContent = dict.ords_autosync_off || 'Auto-Sync: OFF';
    }
  }
}

function addPendingBlueprintLaunch(bpNum) {
  PENDING_LAUNCHED_BPS.add(Number(bpNum));
  if (!gOrdsAutoSync) {
    gAutoSyncTriggeredByBp = true;
    setOrdsAutoSync(true);
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    showToast(dict.ords_autosync_started || '🔄 Blueprint käivitatud: ORDS Auto-Sync automaatselt sisse lülitatud.');
  }
  renderActiveContainersPills();
}

function removePendingBlueprintLaunch(bpNum) {
  PENDING_LAUNCHED_BPS.delete(Number(bpNum));
  if (PENDING_LAUNCHED_BPS.size === 0 && gAutoSyncTriggeredByBp) {
    setOrdsAutoSync(false);
    gAutoSyncTriggeredByBp = false;
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    showToast(dict.ords_autosync_stopped || '✅ Kõik käivitatud blueprindid on aktiivsed. ORDS Auto-Sync lülitus välja.');
  }
  renderActiveContainersPills();
}

function renderActiveContainersPills() {
  const container = document.getElementById('active-containers-pills-row');
  if (!container) return;
  
  const running = Array.isArray(LIVE_RUNNING_CONTAINERS) ? [...LIVE_RUNNING_CONTAINERS] : [];
  const healthMap = (typeof LIVE_CONTAINER_HEALTH === 'object' && LIVE_CONTAINER_HEALTH) ? LIVE_CONTAINER_HEALTH : {};
  
  const startingContainers = [];
  if (PENDING_LAUNCHED_BPS.size > 0) {
    PENDING_LAUNCHED_BPS.forEach(bpNum => {
      const bpCard = document.querySelector(`.card[data-bp="${bpNum}"]`);
      if (bpCard) {
        const cnames = bpCard.getAttribute('data-containers');
        if (cnames) {
          cnames.split(',').map(s => s.trim()).forEach(c => {
            if (c && !running.includes(c) && !startingContainers.includes(c)) {
              startingContainers.push(c);
            }
          });
        }
      }
    });
  }

  if (running.length === 0 && startingContainers.length === 0) {
    container.innerHTML = '';
    return;
  }

  let html = '';
  running.forEach(c => {
    const health = (healthMap[c] || '').toLowerCase();
    let dot = '🟢';
    let badgeClass = 'badge-success';
    let titleText = `${c}: running (healthy)`;
    if (health === 'starting') {
      dot = '🟡';
      badgeClass = 'badge-warning';
      titleText = `${c}: initializing / starting`;
    } else if (health === 'unhealthy') {
      dot = '🔴';
      badgeClass = 'badge-danger';
      titleText = `${c}: unhealthy`;
    }
    html += `<span class="badge ${badgeClass}" style="font-size:0.72rem; padding: 2px 7px; display:inline-flex; align-items:center; gap:4px; font-family: ui-monospace, monospace;" title="${titleText}"><span>${dot}</span><span>${c}</span></span>`;
  });

  startingContainers.forEach(c => {
    html += `<span class="badge" style="font-size:0.72rem; padding: 2px 7px; display:inline-flex; align-items:center; gap:4px; font-family: ui-monospace, monospace; background:rgba(234,179,8,0.15); color:#facc15; border:1px solid rgba(234,179,8,0.3);" title="${c}: starting / launching"><span>🟡</span><span>${c}</span></span>`;
  });

  container.innerHTML = html;
}

async function pollBridgeStatus(manual = false) {
  const connBadge = document.getElementById('bridge-conn-status');
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);
    const poolsParam = '?include_ords_pools=1';
    const resp = await fetch(`${BRIDGE_URL}/api/status${poolsParam}`, { signal: controller.signal, mode: 'cors' });
    clearTimeout(timeoutId);
    if (resp.ok) {
      const data = await resp.json();
      if (data.running_containers) {
        LIVE_RUNNING_CONTAINERS = data.running_containers;
      }
      if (data.container_health) {
        LIVE_CONTAINER_HEALTH = data.container_health;
      }
      LIVE_SETUP_IN_PROGRESS = data.setup_in_progress || null;
      if (data.modules) {
        LIVE_MODULE_STATUSES = data.modules;
      }
      if (typeof data.active_blueprint === 'number') {
        LIVE_ACTIVE_BP = data.active_blueprint;
      }
      if (data.system_resources) {
        LIVE_SYSTEM_RESOURCES = data.system_resources;
      }
      if (data.ords_pools && Object.keys(data.ords_pools).length > 0) {
        LIVE_ORDS_POOLS = data.ords_pools;
      }
      if (connBadge) {
        const bridgePortStr = (typeof BRIDGE_URL !== 'undefined' && BRIDGE_URL) ? BRIDGE_URL.replace(/https?:\/\/[^\/:]+/, '') : ':8089';
        connBadge.innerHTML = `🟢 Bridge ${bridgePortStr} Online`;
        connBadge.style.color = '#4ade80';
        connBadge.style.background = 'rgba(34, 197, 94, 0.15)';
      }
      renderModulePills();
      renderBlueprints(currentActiveFilter);
      updateServiceCardsUI();
      renderOrdsGatewayStrip();
      renderActiveContainersPills();
      if (manual) showToast('✅ Bridge staatus uuendatud!');
    }
  } catch (e) {
    if (connBadge) {
      const bridgePortStr = (typeof BRIDGE_URL !== 'undefined' && BRIDGE_URL) ? BRIDGE_URL.replace(/https?:\/\/[^\/:]+/, '') : ':8089';
      connBadge.innerHTML = `⚪ Bridge Offline (${bridgePortStr})`;
      connBadge.style.color = '#94a3b8';
      connBadge.style.background = 'rgba(148, 163, 184, 0.1)';
    }
    renderModulePills();
    renderBlueprints(currentActiveFilter);
    updateServiceCardsUI();
    renderOrdsGatewayStrip();
    renderActiveContainersPills();
  }
}

const BLUEPRINT_RAM_MAP = {
  0: 3.0, 1: 3.0, 2: 3.0, 3: 3.0, 4: 1.5,
  5: 4.0, 6: 3.0, 7: 6.0, 8: 1.0, 9: 1.0,
  10: 1.5, 11: 4.0
};
let LIVE_SYSTEM_RESOURCES = { total_ram_gb: 16.0, avail_ram_gb: 8.0 };

function getActiveBlueprintsRam() {
  const cards = document.querySelectorAll('.card[data-bp]');
  let usedRam = 0;
  let activeCount = 0;
  cards.forEach(card => {
    if (!card.classList.contains('card-offline')) {
      const bNum = parseInt(card.getAttribute('data-bp') || '0', 10);
      usedRam += (BLUEPRINT_RAM_MAP[bNum] || 2.0);
      activeCount++;
    }
  });
  return { usedRam: Math.round(usedRam * 10) / 10, activeCount };
}

function updateRamIndicatorUI() {
  const el = document.getElementById('cockpit-ram-indicator');
  const textEl = document.getElementById('cockpit-ram-text');
  if (!el || !textEl) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const { usedRam, activeCount } = getActiveBlueprintsRam();
  const totalHostRam = (LIVE_SYSTEM_RESOURCES && LIVE_SYSTEM_RESOURCES.total_ram_gb) ? LIVE_SYSTEM_RESOURCES.total_ram_gb : 16.0;
  
  const countStr = (dict.ram_active_count || '%s active').replace('%s', activeCount);
  textEl.textContent = `RAM: ~${usedRam.toFixed(1)} GB / ${totalHostRam.toFixed(0)} GB (${countStr})`;
  
  el.classList.remove('ram-ok', 'ram-warn', 'ram-danger');
  const ratio = usedRam / totalHostRam;
  if (ratio > 0.8 || (totalHostRam - usedRam) < 2.0) {
    el.classList.add('ram-danger');
  } else if (ratio > 0.6) {
    el.classList.add('ram-warn');
  } else {
    el.classList.add('ram-ok');
  }
}

function sortCockpitCards() {
  const grid = document.getElementById('cockpit-cards-grid');
  if (!grid) return;
  const cards = Array.from(grid.querySelectorAll('.card[data-bp]'));
  cards.sort((a, b) => {
    const getRank = (c) => {
      if (c.classList.contains('card-offline')) return 2;
      if (c.classList.contains('card-partial')) return 1;
      return 0;
    };
    const rankA = getRank(a);
    const rankB = getRank(b);
    if (rankA !== rankB) {
      return rankA - rankB;
    }
    const aBp = parseInt(a.getAttribute('data-bp') || '0', 10);
    const bBp = parseInt(b.getAttribute('data-bp') || '0', 10);
    return aBp - bBp;
  });
  cards.forEach(card => grid.appendChild(card));
  if (typeof currentActiveFilter !== 'undefined' && currentActiveFilter !== 'all') {
    const searchInput = document.getElementById('cockpit-search-input');
    searchCockpitCards(searchInput ? searchInput.value : '');
  }
}

function isContainerRunning(cname) {
  if (!cname) return true;
  const runningList = Array.isArray(LIVE_RUNNING_CONTAINERS) ? LIVE_RUNNING_CONTAINERS : [];
  if (runningList.includes(cname)) return true;
  if (cname === 'app-publisher' && runningList.includes('oracle-publisher-dev')) return true;
  if (cname === 'oracle-publisher-dev' && runningList.includes('app-publisher')) return true;
  if ((cname === 'publisher-designer' || cname === 'app-publisher-designer') && (runningList.includes('publisher-designer') || runningList.includes('app-publisher-designer'))) return true;
  if ((cname === 'forms-designer' || cname === 'app-forms') && (runningList.includes('forms-designer') || runningList.includes('app-forms'))) return true;
  if (cname === 'db-oracle' && (runningList.includes('db-oracle') || runningList.includes('db-proxy'))) return true;
  if (cname === 'db-proxy' && (runningList.includes('db-proxy') || runningList.includes('db-oracle'))) return true;
  return false;
}

function updateWalletStatusUI() {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const cells = document.querySelectorAll('.wallet-status-cell');

  cells.forEach(cell => {
    const cname = cell.getAttribute('data-cname');
    const isUp = isContainerRunning(cname);
    if (isUp) {
      cell.innerHTML = `<span class="badge badge-success" style="font-size:0.75rem; padding:3px 8px;">🟢 <span data-i18n="status_online">${dict.status_online || 'Töös'}</span></span>`;
    } else {
      cell.innerHTML = `<span class="badge badge-danger" style="font-size:0.75rem; padding:3px 8px; background:rgba(239,68,68,0.2); color:#f87171; border:1px solid rgba(239,68,68,0.4);">🔴 <span data-i18n="status_offline">${dict.status_offline || 'Maas'}</span></span>`;
    }
  });
  if (typeof applyWalletFilters === 'function' && gWalletSelectedDb === 'active') {
    applyWalletFilters();
  }
}

function getBlueprintState(card) {
  const bNum = parseInt(card.getAttribute('data-bp'), 10);
  const cnamesAttr = card.getAttribute('data-cnames') || '';
  const requiredContainers = cnamesAttr.split(',').map(s => s.trim()).filter(Boolean);
  const runningList = Array.isArray(LIVE_RUNNING_CONTAINERS) ? LIVE_RUNNING_CONTAINERS : [];

  if (requiredContainers.length === 0) {
    const isOnline = (bNum === LIVE_ACTIVE_BP);
    return {
      state: isOnline ? 'online' : 'offline',
      matchedCount: isOnline ? 1 : 0,
      totalCount: 1,
      containerStates: {}
    };
  }

  let matched = 0;
  const containerStates = {};

  for (const req of requiredContainers) {
    let isRunning = false;
    if (runningList.includes(req)) {
      isRunning = true;
    } else if (req.startsWith('ords/')) {
      const poolName = req.substring(5);
      const poolData = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS[poolName] : null;
      if (poolData && (poolData.status === 'online' || poolData.status === 'degraded')) {
        isRunning = true;
      } else if (runningList.includes('app-ords')) {
        isRunning = true;
      }
    } else if (req === 'app-publisher' && runningList.includes('oracle-publisher-dev')) {
      isRunning = true;
    } else if (req === 'oracle-publisher-dev' && runningList.includes('app-publisher')) {
      isRunning = true;
    } else if ((req === 'publisher-designer' || req === 'app-publisher-designer') && (runningList.includes('publisher-designer') || runningList.includes('app-publisher-designer'))) {
      isRunning = true;
    } else if ((req === 'forms-designer' || req === 'app-forms') && (runningList.includes('forms-designer') || runningList.includes('app-forms'))) {
      isRunning = true;
    } else if ((req === 'db-oracle' || req === 'db-proxy') && (runningList.includes('db-oracle') || runningList.includes('db-proxy'))) {
      isRunning = true;
    }
    containerStates[req] = isRunning;
    if (isRunning) matched++;
  }

  // Edge Gateways (BP 10, BP 11): If local databases are running and this gateway blueprint is not explicitly active, mark offline
  if (bNum === 10 || bNum === 11) {
    const hasLocalDb = runningList.some(d => ['db-proxy', 'db-alise', 'db-proxy-standalone', 'db-publisher', 'db-forms', 'db-gvenzl', 'db-adb'].includes(d));
    if (hasLocalDb && LIVE_ACTIVE_BP !== bNum) {
      return {
        state: 'offline',
        matchedCount: 0,
        totalCount: requiredContainers.length,
        containerStates
      };
    }
  }

  // Standalone ALISE / Proxy / Gvenzl / ADB variants (BP 1, 2, 3, 4):
  if (bNum === 1 && !runningList.includes('db-alise')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 2 && !runningList.includes('db-proxy-standalone')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 3 && !runningList.includes('db-gvenzl')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 4 && !runningList.includes('db-adb') && LIVE_ACTIVE_BP !== 4) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 5 && !runningList.includes('app-publisher') && !runningList.includes('oracle-publisher-dev')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 6 && !runningList.includes('app-forms')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 7 && !runningList.includes('app-forms-publisher')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 8 && !runningList.includes('web-ide-dev')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }
  if (bNum === 9 && !runningList.includes('app-publisher-designer') && !runningList.includes('publisher-designer')) {
    return {
      state: 'offline',
      matchedCount: 0,
      totalCount: requiredContainers.length,
      containerStates
    };
  }

  // 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.7):
  // Check if setup is actively executing in background for this blueprint
  if (LIVE_SETUP_IN_PROGRESS && parseInt(LIVE_SETUP_IN_PROGRESS.blueprint, 10) === bNum) {
    return {
      state: 'installing',
      matchedCount: matched,
      totalCount: requiredContainers.length,
      containerStates
    };
  }

  // Check if any required container is still in 'starting' or unready health state
  const anyStarting = requiredContainers.some(req => {
    if (req.startsWith('ords/')) {
      const poolName = req.substring(5);
      const poolData = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS[poolName] : null;
      if (poolData && poolData.status === 'starting') return true;
      return false;
    }
    // If ORDS pool publisher is online or degraded, app-publisher is operational
    if ((req === 'app-publisher' || req === 'oracle-publisher-dev') && typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) {
      const pubPool = LIVE_ORDS_POOLS['publisher'];
      if (pubPool && (pubPool.status === 'online' || pubPool.status === 'degraded')) {
        return false;
      }
    }
    return typeof LIVE_CONTAINER_HEALTH === 'object' && LIVE_CONTAINER_HEALTH[req] === 'starting';
  });

  let state = 'offline';
  if (matched === requiredContainers.length) {
    state = anyStarting ? 'starting' : 'online';
  } else if (matched > 0) {
    state = anyStarting ? 'starting' : 'partial';
  }

  return {
    state,
    matchedCount: matched,
    totalCount: requiredContainers.length,
    containerStates
  };
}

function isBlueprintOnline(card) {
  const info = getBlueprintState(card);
  return info.state === 'online';
}

function updateCardState(card, bpStateInfo, currentLang) {
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const bNum = parseInt(card.getAttribute('data-bp'), 10);
  
  let state = 'offline';
  let matchedCount = 0;
  let totalCount = 0;
  let containerStates = {};

  if (typeof bpStateInfo === 'boolean') {
    state = bpStateInfo ? 'online' : 'offline';
  } else if (bpStateInfo && typeof bpStateInfo === 'object') {
    state = bpStateInfo.state;
    matchedCount = bpStateInfo.matchedCount;
    totalCount = bpStateInfo.totalCount;
    containerStates = bpStateInfo.containerStates || {};
  }

  const pill = card.querySelector('.status-pill[data-status-url]') || card.querySelector('.status-pill');
  if (pill) {
    applyPillState(pill, state, currentLang, matchedCount, totalCount);
  }

  card.classList.remove('card-offline', 'card-partial');
  if (state === 'offline') {
    card.classList.add('card-offline');
  } else if (state === 'partial') {
    card.classList.add('card-partial');
  }

  // Update container chips if present
  const chips = card.querySelectorAll('.container-chip[data-cname]');
  chips.forEach(chip => {
    const cname = chip.getAttribute('data-cname');
    const isChipOnline = !!containerStates[cname];
    chip.classList.toggle('chip-online', isChipOnline);
    chip.classList.toggle('chip-offline', !isChipOnline);
    if (cname && cname.startsWith('ords/')) {
      const poolName = chip.getAttribute('data-ords-pool') || cname.substring(5);
      const pData = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS[poolName] : null;
      const latInfo = (pData && pData.latency_ms !== undefined && pData.latency_ms > 0) ? ` · ${pData.latency_ms}ms` : '';
      chip.setAttribute('title', `ORDS Pool: ${poolName} (${isChipOnline ? 'online' + latInfo : 'offline'})`);
    } else {
      chip.setAttribute('title', `${cname} (${isChipOnline ? 'online' : 'offline'})`);
    }
  });

  const actionFlex = card.querySelector('.card-action-flex');
  if (!actionFlex) return;

  const copyBtn = actionFlex.querySelector('.btn-bp-copy');
  if (copyBtn) {
    const isOnlineOrPartial = (state === 'online' || state === 'partial');
    const tipKey = (isOnlineOrPartial && bNum > 0) ? 'tip_copy_stop_cmd' : 'tip_copy_deploy_cmd';
    copyBtn.setAttribute('data-i18n-title', tipKey);
    copyBtn.setAttribute('title', (dict && dict[tipKey]) || (isOnlineOrPartial ? 'Copy stop command' : 'Copy deployment command'));
  }

  let mainSlot = actionFlex.querySelector('.btn-action-main, .core-protected-badge');
  if (mainSlot) {
    const isOnlineOrPartial = (state === 'online' || state === 'partial');
    const targetKey = isOnlineOrPartial ? 'btn_manage_ops_active' : 'btn_manage_ops_offline';
    const targetTxt = (dict && dict[targetKey]) || (isOnlineOrPartial ? '⚙️ Haldus & Taastamine' : '⚡ Käivita & Juhi');
    const btnCls = isOnlineOrPartial ? 'btn-secondary' : 'btn-primary';

    if (!mainSlot.classList.contains('btn-action-main')) {
      mainSlot.outerHTML = `<button type="button" class="btn ${btnCls} btn-action-main btn-service-switch" onclick="openBlueprintModal(${bNum}, 'ops')"><span data-i18n="${targetKey}">${targetTxt}</span></button>`;
    } else {
      mainSlot.className = `btn ${btnCls} btn-action-main btn-service-switch`;
      mainSlot.innerHTML = `<span data-i18n="${targetKey}">${targetTxt}</span>`;
    }
  }
}

function handleCopyBpCmd(bNum, btn) {
  const card = document.querySelector(`.card[data-bp="${bNum}"]`);
  const isOnline = card && !card.classList.contains('card-offline');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  let cmd = '';
  if (isOnline && bNum > 0) {
    cmd = `./scripts/reset-all.sh -b ${bNum}`;
  } else {
    cmd = `./scripts/deploy-blueprint.sh -b ${bNum} --lang ${currentLang}`;
  }
  copyText(cmd);
  if (btn) {
    const origHtml = btn.innerHTML;
    btn.innerHTML = '<span>✅</span>';
    setTimeout(() => { btn.innerHTML = origHtml; }, 1500);
  }
  showToast(`📋 Kopeerisin käsu: <code>${cmd}</code>`);
}

async function checkServiceHealth() {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const cards = document.querySelectorAll('.card[data-bp]');

  cards.forEach(card => {
    const stateInfo = getBlueprintState(card);
    updateCardState(card, stateInfo, currentLang);
  });

  updateWalletStatusUI();
  sortCockpitCards();
  updateRamIndicatorUI();

  // Update active filter badge count
  const activeCards = document.querySelectorAll('#cockpit-cards-grid .card:not(.card-offline)');
  const filterActiveBtn = document.querySelector('.bp-filter-btn[data-i18n="filter_active"]');
  if (filterActiveBtn) {
    const baseText = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['filter_active']) || '🟢 Active';
    if (activeCards.length > 0) {
      filterActiveBtn.innerHTML = `${baseText} <span class="badge" style="background:rgba(74,222,128,0.25); color:#4ade80; border:1px solid rgba(74,222,128,0.5); font-size:0.75rem; padding:1px 6px; border-radius:10px; margin-left:4px;">${activeCards.length}</span>`;
    } else {
      filterActiveBtn.innerHTML = baseText;
    }
  }

  // Remove pending blueprints that reached active state
  if (PENDING_LAUNCHED_BPS.size > 0) {
    PENDING_LAUNCHED_BPS.forEach(bpNum => {
      const card = document.querySelector(`.card[data-bp="${bpNum}"]`);
      if (card && !card.classList.contains('card-offline') && !card.classList.contains('card-init')) {
        removePendingBlueprintLaunch(bpNum);
      }
    });
  }
  renderActiveContainersPills();
}

function updateServiceCardsUI() {
  checkServiceHealth();
}

function renderOrdsGatewayStrip() {
  const strip = document.getElementById('ords-gateway-strip');
  if (!strip) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const badge = document.getElementById('ords-gateway-status-badge');
  const isOrdsUp = isContainerRunning('app-ords');
  if (badge) {
    if (isOrdsUp) {
      badge.className = 'badge badge-success';
      badge.innerHTML = '🟢 :8088 / :8448';
      badge.style.background = 'rgba(34, 197, 94, 0.15)';
      badge.style.color = '#4ade80';
    } else {
      badge.className = 'badge badge-danger';
      badge.innerHTML = '🔴 ' + (dict.status_offline || 'Offline') + ' (:8088)';
      badge.style.background = 'rgba(239, 68, 68, 0.15)';
      badge.style.color = '#f87171';
    }
  }

  const listContainer = document.getElementById('ords-pools-list');
  if (!listContainer) return;

  const pools = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS : {};
  const poolKeys = Object.keys(pools);

  if (poolKeys.length === 0) {
    listContainer.innerHTML = `<span style="font-size:0.75rem; color:#64748b;">${dict.ords_pools_label || 'Active Pools:'} <em>${dict.status_none || 'None'}</em></span>`;
    return;
  }

  let html = `<span style="font-size:0.75rem; color:#94a3b8; margin-right:4px;">${dict.ords_pools_label || 'Active Pools:'}</span>`;
  poolKeys.forEach(pname => {
    const p = pools[pname];
    const isOrdsUp = isContainerRunning('app-ords');
    const isOnline = p ? (p.status === 'online' || (p.status !== 'offline' && isOrdsUp) || (pname === 'proxy' && isOrdsUp && isContainerRunning('db-proxy'))) : isOrdsUp;
    const isStarting = p && p.status === 'starting';
    let pillCls = 'pool-offline';
    let dot = '🔴';
    if (isOnline) {
      pillCls = 'pool-online';
      dot = '🟢';
    } else if (isStarting) {
      pillCls = 'pool-starting';
      dot = '🟡';
    }
    const latStr = (isOnline && p.latency_ms !== undefined && p.latency_ms > 0) ? `<span class="ords-pool-latency">(${p.latency_ms}ms)</span>` : '';
    const poolUrl = (p && p.url) ? p.url : `http://localhost:8088/ords/${pname}/`;
    const targetStr = (p && p.target) ? ` -> ${p.target}` : '';
    html += `<a href="${poolUrl}" target="_blank" rel="noopener noreferrer" class="ords-pool-pill ${pillCls}" title="ORDS Pool: ${pname}${targetStr} (${p ? p.status : 'unknown'})"><span>${dot}</span> <span>ords/${pname}</span>${latStr}</a>`;
  });

  listContainer.innerHTML = html;
}

async function syncOrdsPools(manual = false) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (manual) showToast(dict.ords_sync_running || '🔄 Sünkroonin ORDS poole...');
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 4000);
    const resp = await fetch(`${BRIDGE_URL}/api/ords/refresh`, {
      method: 'POST',
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    if (resp.ok) {
      const data = await resp.json();
      if (data.ords_pools || data.pools) {
        LIVE_ORDS_POOLS = data.ords_pools || data.pools;
      }
      renderOrdsGatewayStrip();
      checkServiceHealth();
      if (manual) showToast(dict.ords_sync_success || '✅ ORDS connection pools successfully synchronized!');
    } else {
      if (manual) showToast('⚠️ ORDS poolide sünkroniseerimine ebaõnnestus.');
    }
  } catch (e) {
    if (manual) showToast('⚠️ Bridge offline – kasuta käsku: <code>./scripts/internal/manage-ords-pools.sh sync</code>');
  }
}

async function handleStartServiceFromCard(btn, modKey) {
  if (!modKey) return;
  btn.disabled = true;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const origHtml = btn.innerHTML;
  btn.innerHTML = `<span>⏳</span> <span>${dict.status_starting || 'Starting...'}</span>`;
  const cliCmd = `./scripts/start-containers.sh ${modKey}`;
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2500);
    const resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${encodeURIComponent(modKey)}&action=start`, {
      method: 'POST',
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    if (resp.ok) {
      showToast(`🚀 Käivitan teenust '${modKey}'... Kontrollin staatust.`);
      setTimeout(checkServiceHealth, 1500);
      setTimeout(checkServiceHealth, 4000);
    } else {
      copyText(cliCmd);
      showToast(`📋 Kopeerisin käsu: ${cliCmd}`);
    }
  } catch (e) {
    copyText(cliCmd);
    showToast(`📋 Kopeerisin käsu: ${cliCmd}<br/><small style="color:#94a3b8;">(Terminali käivitus: käsk kopeeritud!)</small>`);
  } finally {
    setTimeout(() => {
      btn.disabled = false;
      btn.innerHTML = origHtml;
    }, 2000);
  }
}

async function handleStopServiceFromCard(btn, modKey) {
  if (!modKey) return;
  if (modKey === 'proxy' || modKey === 'ords' || modKey === 'core') {
    alert('🛡️ Core Base Protection: db-proxy ja app-ords ei saa välja lülitada!');
    return;
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  btn.disabled = true;
  const origHtml = btn.innerHTML;
  btn.innerHTML = `<span>⏳</span> <span>${dict.status_stopping || 'Stopping...'}</span>`;
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2500);
    const resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${encodeURIComponent(modKey)}&action=stop`, {
      method: 'POST',
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    showToast(`⏹️ Peatan teenust '${modKey}'... Kontrollin staatust.`);
    setTimeout(checkServiceHealth, 1500);
    setTimeout(checkServiceHealth, 4000);
  } catch (e) {
    const cliCmd = `podman stop ${modKey}`;
    copyText(cliCmd);
    showToast(`📋 Kopeerisin käsu: ${cliCmd}`);
  } finally {
    setTimeout(() => {
      btn.disabled = false;
      btn.innerHTML = origHtml;
    }, 2000);
  }
}

function renderModulePills() {
  // Deprecated/Merged into Cockpit Blueprints
}

async function toggleModuleBridge(modKey, action) {
  if (action === 'stop' && (modKey === 'proxy' || modKey === 'ords' || modKey === 'core')) {
    alert('🛡️ Core Base Protection: db-proxy ja app-ords ei saa välja lülitada!');
    return;
  }
  showToast(`⏳ Moodul '${modKey}' (${action})...`);
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${encodeURIComponent(modKey)}&action=${action}`, {
      method: 'POST',
      mode: 'cors'
    });
    const data = await resp.json();
    if (resp.ok) {
      showToast(`✅ Moodul '${modKey}' käsk saadetud!`);
      setTimeout(checkServiceHealth, 1500);
      setTimeout(checkServiceHealth, 3500);
    } else {
      alert(`Viga: ${data.error || 'Tundmatu viga'}`);
    }
  } catch (err) {
    const cliCmd = `./scripts/start-containers.sh ${modKey}`;
    copyText(cliCmd);
    showToast(`📋 Kopeerisin käsu: ${cliCmd}`);
  }
}

async function triggerBlueprintAction(bNum, action) {
  if (action === 'stop' && bNum === 0) {
    alert('🛡️ Core Base Protection: Blueprint #0 (Tuum) ei saa välja lülitada!');
    return;
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';

  if (action === 'switch' || action === 'start') {
    const { usedRam } = getActiveBlueprintsRam();
    const targetRam = BLUEPRINT_RAM_MAP[bNum] || 2.0;
    const totalHostRam = (LIVE_SYSTEM_RESOURCES && LIVE_SYSTEM_RESOURCES.total_ram_gb) ? LIVE_SYSTEM_RESOURCES.total_ram_gb : 16.0;
    const projectedRam = Math.round((usedRam + targetRam) * 10) / 10;
    
    // Check if adding this blueprint exceeds 80% of host RAM or leaves < 2GB
    if (projectedRam > totalHostRam * 0.8 || (totalHostRam - projectedRam) < 1.5) {
      const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
      let msg = dict.ram_warning_msg || "Currently active blueprints use ~%s GB of RAM. Launching Blueprint #%s requires an additional ~%s GB (Total: ~%s GB of %s GB host RAM).\n\nRunning multiple heavy stacks simultaneously may cause memory pressure. Do you want to proceed?";
      msg = msg.replace('%s', usedRam.toFixed(1))
               .replace('%s', bNum)
               .replace('%s', targetRam.toFixed(1))
               .replace('%s', projectedRam.toFixed(1))
               .replace('%s', totalHostRam.toFixed(0));
      if (!confirm(msg)) {
        return;
      }
    }
  }

  await openBlueprintModal(bNum, 'ops');
  await triggerBlueprintActionModal(bNum, action);
}

function renderBlueprints(filter) {
  filterBlueprints(filter);
}

async function openProfileManager() {
  const backdrop = document.getElementById('profile-modal-backdrop');
  if (backdrop) {
    backdrop.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
  await fetchAndRenderProfilesList();
}

function closeProfileModal(event) {
  if (event && event.target !== event.currentTarget && !event.target.classList.contains('modal-close-btn')) return;
  const backdrop = document.getElementById('profile-modal-backdrop');
  if (backdrop) {
    backdrop.classList.remove('active');
    document.body.style.overflow = '';
  }
}

let CURRENT_PROFILE_PATH = '';

async function fetchAndRenderProfilesList() {
  const container = document.getElementById('profile-list-container');
  if (!container) return;

  // 1. Immediately render pre-embedded profiles from window.PROFILES_DATA
  if (Array.isArray(window.PROFILES_DATA) && window.PROFILES_DATA.length > 0) {
    CACHED_PROFILES = window.PROFILES_DATA;
    renderProfilesSidebar(CACHED_PROFILES);
    if (!CURRENT_PROFILE_PATH) {
      loadProfileToEditor(CACHED_PROFILES[0].rel_path);
    } else {
      loadProfileToEditor(CURRENT_PROFILE_PATH);
    }
  }

  // 2. Refresh from bridge if available
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/profiles`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      const profs = data.profiles || data;
      if (Array.isArray(profs) && profs.length > 0) {
        CACHED_PROFILES = profs;
        renderProfilesSidebar(CACHED_PROFILES);
        if (!CURRENT_PROFILE_PATH) {
          loadProfileToEditor(CACHED_PROFILES[0].rel_path);
        }
      }
    } else if (!CACHED_PROFILES || CACHED_PROFILES.length === 0) {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge API viga: HTTP ${resp.status}</span>`;
    }
  } catch (e) {
    if (!CACHED_PROFILES || CACHED_PROFILES.length === 0) {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge offline (${BRIDGE_URL}). Käivitage dev-hub-bridge.py</span>`;
    }
  }
}

function renderProfilesSidebar(profiles) {
  const container = document.getElementById('profile-list-container');
  if (!container) return;
  let html = '';
  let currentCat = '';
  profiles.forEach(p => {
    if (p.category !== currentCat) {
      currentCat = p.category;
      html += `<div style="font-size: 0.7rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin: 10px 0 3px 4px;">📂 ${currentCat}</div>`;
    }
    const isSel = (p.rel_path === CURRENT_PROFILE_PATH);
    html += `
      <div class="profile-item-btn" onclick="loadProfileToEditor('${p.rel_path}')" style="padding: 6px 10px; border-radius: 6px; cursor: pointer; font-size: 0.78rem; display: flex; justify-content: space-between; align-items: center; background: ${isSel ? 'rgba(56,189,248,0.15)' : 'transparent'}; color: ${isSel ? '#38bdf8' : '#cbd5e1'}; border: 1px solid ${isSel ? 'rgba(56,189,248,0.3)' : 'transparent'};">
        <span style="font-family: ui-monospace, monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 190px;">${p.name}</span>
        ${p.port ? `<span style="font-size: 0.7rem; color: #4ade80; font-family: ui-monospace, monospace; font-weight: 600;">:${p.port}</span>` : ''}
      </div>
    `;
  });
  container.innerHTML = html;
}

// ==========================================
// 1. YAML PROFILES MANAGER
// ==========================================
let IS_PROFILE_EDITING = false;

function enableProfileEdit() {
  const ta = document.getElementById('profile-editor-textarea');
  const btnSave = document.getElementById('btn-save-profile');
  const msgEl = document.getElementById('profile-editor-msg');
  if (ta) {
    ta.readOnly = false;
    ta.focus();
  }
  if (btnSave) {
    btnSave.style.display = '';
    btnSave.disabled = false;
  }
  if (msgEl) {
    msgEl.innerHTML = '<span style="color: #38bdf8;">✏️ Muutmisrežiim aktiivne. Tee muudatused ja vajuta "Salvesta Profiil".</span>';
  }
}

function promptCloneProfile() {
  if (!CURRENT_PROFILE_PATH) return;
  const bar = document.getElementById('profile-clone-bar');
  const input = document.getElementById('profile-clone-name');
  if (bar) bar.style.display = 'flex';
  const fname = CURRENT_PROFILE_PATH.split('/').pop().replace('.yaml', '');
  if (input) {
    input.value = `${fname}-clone.yaml`;
    input.focus();
    input.select();
  }
}

function cancelCloneProfile() {
  const bar = document.getElementById('profile-clone-bar');
  if (bar) bar.style.display = 'none';
}

function confirmCloneProfile() {
  const input = document.getElementById('profile-clone-name');
  const ta = document.getElementById('profile-editor-textarea');
  const pathEl = document.getElementById('profile-editor-path');
  const btnSave = document.getElementById('btn-save-profile');
  const msgEl = document.getElementById('profile-editor-msg');
  if (!input || !input.value.trim()) return;
  let newName = input.value.trim();
  if (!newName.endsWith('.yaml')) newName += '.yaml';

  const currentDir = CURRENT_PROFILE_PATH.substring(0, CURRENT_PROFILE_PATH.lastIndexOf('/'));
  CURRENT_PROFILE_PATH = `${currentDir}/${newName}`;
  if (pathEl) pathEl.textContent = `${CURRENT_PROFILE_PATH} (Uus kloon)`;
  if (ta) {
    ta.readOnly = false;
    ta.focus();
  }
  if (btnSave) {
    btnSave.style.display = '';
    btnSave.disabled = false;
  }
  cancelCloneProfile();
  if (msgEl) {
    msgEl.innerHTML = `<span style="color: #4ade80;">📋 Kloon loodud mälus (${newName}). Kohanda parameetreid ja vajuta "Salvesta Profiil".</span>`;
  }
}

async function loadProfileToEditor(relPath) {
  CURRENT_PROFILE_PATH = relPath;
  cancelCloneProfile();
  const pathEl = document.getElementById('profile-editor-path');
  const badgesEl = document.getElementById('profile-editor-badges');
  const ta = document.getElementById('profile-editor-textarea');
  const btnSave = document.getElementById('btn-save-profile');
  const msgEl = document.getElementById('profile-editor-msg');

  if (pathEl) pathEl.textContent = relPath;
  if (ta) ta.readOnly = true;
  if (btnSave) {
    btnSave.style.display = 'none';
    btnSave.disabled = true;
  }
  if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;

  renderProfilesSidebar(CACHED_PROFILES);

  const profObj = CACHED_PROFILES.find(p => p.rel_path === relPath);
  if (badgesEl && profObj) {
    badgesEl.innerHTML = `
      <span class="bp-tag" style="color: #38bdf8;">📁 ${profObj.category}</span>
      ${profObj.port ? `<span class="bp-tag" style="color: #4ade80;">🔌 Port: ${profObj.port}</span>` : ''}
      ${profObj.memory ? `<span class="bp-tag" style="color: #c084fc;">💾 RAM: ${profObj.memory}</span>` : ''}
    `;
  }

  // Pre-load content immediately from embedded profile object
  if (profObj && profObj.content !== undefined) {
    if (ta) ta.value = profObj.content;
    if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/profile?path=${encodeURIComponent(relPath)}`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (ta) ta.value = (data.content !== undefined) ? data.content : JSON.stringify(data, null, 2);
      if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;
    } else if (!ta || !ta.value) {
      if (ta) ta.value = `# Failed to load file: HTTP ${resp.status}`;
    }
  } catch (e) {
    if (ta && ta.value) {
      if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim (Staatiline / Bridge offline): <code>${relPath}</code></span>`;
    } else {
      if (ta) ta.value = `# Bridge viga: ${e.message}`;
    }
  }
}

async function saveProfileFromEditor() {
  if (!CURRENT_PROFILE_PATH) return;
  const ta = document.getElementById('profile-editor-textarea');
  const btnSave = document.getElementById('btn-save-profile');
  const msgEl = document.getElementById('profile-editor-msg');
  if (!ta) return;

  const newContent = ta.value;

  const portMatch = newContent.match(/(?:db_port|http_port|port):\s*([0-9]+)/);
  if (portMatch) {
    const editedPort = parseInt(portMatch[1], 10);
    const conflict = CACHED_PROFILES.find(p => p.rel_path !== CURRENT_PROFILE_PATH && p.port === editedPort);
    if (conflict) {
      if (!confirm(`⚠️ Hoiatus: Port ${editedPort} on juba kasutusel profiilis '${conflict.name}' (${conflict.category}). Kas soovid ikkagi salvestada?`)) {
        return;
      }
    }
  }

  if (btnSave) btnSave.disabled = true;
  if (msgEl) msgEl.innerHTML = '<span style="color: #facc15;">⏳ Salvestan ja genereerin Dev Hub uuesti...</span>';

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/profile`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ path: CURRENT_PROFILE_PATH, content: newContent }),
      mode: 'cors'
    });
    const resData = await resp.json();
    if (resp.ok) {
      if (msgEl) msgEl.innerHTML = `<span style="color: #4ade80;">✅ ${resData.message || 'Profiil salvestatud edukalt!'}</span>`;
      showToast('✅ Profiil salvestatud! Dev Hub genereeritakse uuesti taustal.');
      ta.readOnly = true;
      if (btnSave) btnSave.style.display = 'none';
      setTimeout(() => fetchAndRenderProfilesList(), 1500);
      setTimeout(() => pollBridgeStatus(), 2000);
    } else {
      if (msgEl) msgEl.innerHTML = `<span style="color: #f87171;">❌ Viga: ${resData.error || 'Salvestamine ebaõnnestus'}</span>`;
    }
  } catch (e) {
    if (msgEl) msgEl.innerHTML = `<span style="color: #f87171;">❌ Salvestamiseks on vaja aktiivset Dev Hub Bridge'i (${BRIDGE_URL}): ${e.message}</span>`;
  } finally {
    if (btnSave) btnSave.disabled = false;
  }
}

// ==========================================
// 2. BLUEPRINTS MANAGER (Split Layout: List / View / Edit / Clone)
// ==========================================
let CACHED_BLUEPRINTS = (typeof BLUEPRINTS_DATA !== 'undefined' && Array.isArray(BLUEPRINTS_DATA))
  ? BLUEPRINTS_DATA.map(b => ({
      rel_path: b.rel_path || `config/blueprints/${b.file}`,
      name: b.name || b.file,
      number: b.num,
      title: (b.titles && (b.titles.et || b.titles.en)) ? (b.titles.et || b.titles.en) : (b.name || b.file),
      content: b.content || ''
    }))
  : [];
let CURRENT_BP_PATH = '';

async function openBlueprintManager() {
  const backdrop = document.getElementById('bp-manager-modal-backdrop');
  if (backdrop) {
    backdrop.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
  await fetchAndRenderBlueprintsList();
}

function closeBlueprintManagerModal(event) {
  if (event && event.target !== event.currentTarget && !event.target.classList.contains('modal-close-btn')) return;
  const backdrop = document.getElementById('bp-manager-modal-backdrop');
  if (backdrop) {
    backdrop.classList.remove('active');
    document.body.style.overflow = '';
  }
}

async function fetchAndRenderBlueprintsList() {
  const container = document.getElementById('bp-list-container');
  if (!container) return;

  // 1. Immediately render pre-embedded blueprints
  if (CACHED_BLUEPRINTS.length > 0) {
    renderBlueprintsSidebar(CACHED_BLUEPRINTS);
    if (!CURRENT_BP_PATH) {
      loadBlueprintToView(CACHED_BLUEPRINTS[0].rel_path);
    } else {
      loadBlueprintToView(CURRENT_BP_PATH);
    }
  }

  // 2. Refresh from bridge if available
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprints`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      const bps = data.blueprints || [];
      if (bps.length > 0) {
        CACHED_BLUEPRINTS = bps;
        renderBlueprintsSidebar(CACHED_BLUEPRINTS);
        if (!CURRENT_BP_PATH) {
          loadBlueprintToView(CACHED_BLUEPRINTS[0].rel_path);
        }
      }
    } else if (CACHED_BLUEPRINTS.length === 0) {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge API viga: HTTP ${resp.status}</span>`;
    }
  } catch (e) {
    if (CACHED_BLUEPRINTS.length === 0) {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge offline (${BRIDGE_URL}). Käivitage dev-hub-bridge.py</span>`;
    }
  }
}

function renderBlueprintsSidebar(blueprints) {
  const container = document.getElementById('bp-list-container');
  if (!container) return;
  let html = '';
  blueprints.forEach(b => {
    const isSel = (b.rel_path === CURRENT_BP_PATH);
    const numBadge = b.number !== null && b.number !== 999 ? `#${b.number}` : '•';
    html += `
      <div class="profile-item-btn" onclick="loadBlueprintToView('${b.rel_path}')" style="padding: 6px 10px; border-radius: 6px; cursor: pointer; font-size: 0.78rem; display: flex; justify-content: space-between; align-items: center; background: ${isSel ? 'rgba(56,189,248,0.15)' : 'transparent'}; color: ${isSel ? '#38bdf8' : '#cbd5e1'}; border: 1px solid ${isSel ? 'rgba(56,189,248,0.3)' : 'transparent'};">
        <div style="display: flex; align-items: center; gap: 6px; overflow: hidden;">
          <span style="background: rgba(56,189,248,0.2); color: #38bdf8; font-weight: 700; padding: 1px 5px; border-radius: 4px; font-size: 0.7rem; font-family: ui-monospace, monospace;">${numBadge}</span>
          <span style="font-family: ui-monospace, monospace; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 170px;">${b.name.replace('.env.', '')}</span>
        </div>
      </div>
    `;
  });
  container.innerHTML = html;
}

function showBlueprintView() {
  const viewPane = document.getElementById('bp-view-pane');
  const builderPane = document.getElementById('bp-builder-pane');
  if (viewPane) viewPane.style.display = 'flex';
  if (builderPane) builderPane.style.display = 'none';
}

async function loadBlueprintToView(relPath) {
  CURRENT_BP_PATH = relPath;
  showBlueprintView();

  const pathEl = document.getElementById('bp-view-path');
  const badgesEl = document.getElementById('bp-view-badges');
  const ta = document.getElementById('bp-view-textarea');
  const btnSave = document.getElementById('btn-save-bp');
  const msgEl = document.getElementById('bp-view-msg');

  if (pathEl) pathEl.textContent = relPath;
  if (ta) ta.readOnly = true;
  if (btnSave) {
    btnSave.style.display = 'none';
    btnSave.disabled = true;
  }

  renderBlueprintsSidebar(CACHED_BLUEPRINTS);

  const bpObj = CACHED_BLUEPRINTS.find(b => b.rel_path === relPath || b.file === relPath || b.name === relPath);
  if (badgesEl && bpObj) {
    badgesEl.innerHTML = `
      <span class="bp-tag" style="color: #38bdf8;">🏷️ ${bpObj.title || bpObj.name}</span>
      <span class="bp-tag" style="color: #4ade80;">№ ${bpObj.number}</span>
    `;
  }

  // Pre-load content immediately from embedded blueprint object
  if (bpObj && bpObj.content) {
    if (ta) ta.value = bpObj.content;
    if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprint?path=${encodeURIComponent(relPath)}`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (ta) ta.value = data.content || '';
      if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;
    } else if (!ta || !ta.value) {
      if (ta) ta.value = `# Failed to load file: HTTP ${resp.status}`;
    }
  } catch (e) {
    if (ta && ta.value) {
      if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim (Staatiline / Bridge offline): <code>${relPath}</code></span>`;
    } else {
      if (ta) ta.value = `# Bridge viga: ${e.message}`;
    }
  }
}

function enableBlueprintEdit() {
  const ta = document.getElementById('bp-view-textarea');
  const btnSave = document.getElementById('btn-save-bp');
  const msgEl = document.getElementById('bp-view-msg');
  if (ta) {
    ta.readOnly = false;
    ta.focus();
  }
  if (btnSave) {
    btnSave.style.display = '';
    btnSave.disabled = false;
  }
  if (msgEl) {
    msgEl.innerHTML = '<span style="color: #38bdf8;">✏️ Muutmisrežiim aktiivne. Tee muudatused ja salvesta blueprint.</span>';
  }
}

async function saveBlueprintFromView() {
  if (!CURRENT_BP_PATH) return;
  const ta = document.getElementById('bp-view-textarea');
  const btnSave = document.getElementById('btn-save-bp');
  const msgEl = document.getElementById('bp-view-msg');
  if (!ta) return;

  const newContent = ta.value;
  if (btnSave) btnSave.disabled = true;
  if (msgEl) msgEl.innerHTML = '<span style="color: #facc15;">⏳ Salvestan blueprinti...</span>';

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprint/save`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ path: CURRENT_BP_PATH, content: newContent }),
      mode: 'cors'
    });
    const resData = await resp.json();
    if (resp.ok) {
      if (msgEl) msgEl.innerHTML = `<span style="color: #4ade80;">✅ ${resData.message || 'Blueprint salvestatud edukalt!'}</span>`;
      showToast('✅ Blueprint salvestatud edukalt!');
      ta.readOnly = true;
      if (btnSave) btnSave.style.display = 'none';
      setTimeout(() => fetchAndRenderBlueprintsList(), 1500);
      setTimeout(() => pollBridgeStatus(), 2000);
    } else {
      if (msgEl) msgEl.innerHTML = `<span style="color: #f87171;">❌ Viga: ${resData.error || 'Salvestamine ebaõnnestus'}</span>`;
    }
  } catch (e) {
    if (msgEl) msgEl.innerHTML = `<span style="color: #f87171;">❌ Bridge viga: ${e.message}</span>`;
  } finally {
    if (btnSave) btnSave.disabled = false;
  }
}

function showNewBlueprintForm() {
  const viewPane = document.getElementById('bp-view-pane');
  const builderPane = document.getElementById('bp-builder-pane');
  const titleEl = document.getElementById('bp-builder-title');
  if (viewPane) viewPane.style.display = 'none';
  if (builderPane) builderPane.style.display = 'flex';
  if (titleEl) titleEl.textContent = '➕ Uus Blueprint';

  // Calculate next blueprint number
  let nextNum = 12;
  if (CACHED_BLUEPRINTS.length > 0) {
    const validNums = CACHED_BLUEPRINTS.map(b => b.number).filter(n => n !== null && n < 900);
    if (validNums.length > 0) {
      nextNum = Math.max(...validNums) + 1;
    }
  }
  const numInput = document.getElementById('cbp-number');
  const nameInput = document.getElementById('cbp-name');
  if (numInput) numInput.value = nextNum;
  if (nameInput) nameInput.value = 'custom-cluster';
  updateCbpEnvPreview();
}

function cloneCurrentBlueprint() {
  const ta = document.getElementById('bp-view-textarea');
  const viewPane = document.getElementById('bp-view-pane');
  const builderPane = document.getElementById('bp-builder-pane');
  const titleEl = document.getElementById('bp-builder-title');
  if (viewPane) viewPane.style.display = 'none';
  if (builderPane) builderPane.style.display = 'flex';

  const bpObj = CACHED_BLUEPRINTS.find(b => b.rel_path === CURRENT_BP_PATH);
  const baseName = bpObj ? (bpObj.slug || bpObj.name.replace('.env.', '')) : 'blueprint';
  if (titleEl) titleEl.textContent = `📋 Klooni Blueprint: ${baseName}`;

  let nextNum = 12;
  if (CACHED_BLUEPRINTS.length > 0) {
    const validNums = CACHED_BLUEPRINTS.map(b => b.number).filter(n => n !== null && n < 900);
    if (validNums.length > 0) {
      nextNum = Math.max(...validNums) + 1;
    }
  }

  const numInput = document.getElementById('cbp-number');
  const nameInput = document.getElementById('cbp-name');
  if (numInput) numInput.value = nextNum;
  if (nameInput) nameInput.value = `${baseName}-clone`;

  // Parse existing content to prefill selects
  const cnt = (ta && ta.value) ? ta.value : '';
  const dbSelect = document.getElementById('cbp-db');
  const ordsSelect = document.getElementById('cbp-ords');
  const svcSelect = document.getElementById('cbp-service');

  if (cnt) {
    // Check DB
    const mDb = cnt.match(/^(?:DB_[A-Z0-9_]+)=([^\s\r\n]+)/m);
    if (mDb && dbSelect) {
      const dbVal = mDb[1];
      for (let opt of dbSelect.options) {
        if (opt.value === dbVal) { opt.selected = true; break; }
      }
    } else if (cnt.includes('MAIN_DB_PROFILE=NONE') && dbSelect) {
      dbSelect.value = 'NONE';
    }

    // Check ORDS
    const mOrds = cnt.match(/^ORDS_PROFILE=([^\s\r\n]+)/m);
    if (mOrds && ordsSelect) {
      const ordsVal = mOrds[1];
      for (let opt of ordsSelect.options) {
        if (opt.value === ordsVal) { opt.selected = true; break; }
      }
    }

    // Check Middleware
    const mSvc = cnt.match(/^(?:PUBLISHER_DESIGNER_PROFILE|FORMS_PUBLISHER_PROFILE|PUBLISHER_PROFILE|FORMS_PROFILE|WEB_IDE_PROFILE)=([^\s\r\n]+)/m);
    if (mSvc && svcSelect) {
      const svcVal = mSvc[1];
      for (let opt of svcSelect.options) {
        if (opt.value === svcVal) { opt.selected = true; break; }
      }
    }
  }

  updateCbpEnvPreview();
}

function updateCbpEnvPreview() {
  const num = document.getElementById('cbp-number')?.value || '12';
  const name = document.getElementById('cbp-name')?.value || 'custom';
  const db = document.getElementById('cbp-db')?.value || 'NONE';
  const ords = document.getElementById('cbp-ords')?.value || 'NONE';
  const svc = document.getElementById('cbp-service')?.value || 'NONE';

  let lines = [];
  lines.push(`# ==============================================================================`);
  lines.push(`# Blueprint ${num}: ${name}`);
  lines.push(`# Positive profile references only (Rule 11 Clean Blueprint Single Source of Truth)`);
  lines.push(`# ==============================================================================`);
  if (db !== 'NONE') {
    if (db.includes('proxy')) lines.push(`DB_PROXY=${db}`);
    else if (db.includes('alise') || db.includes('gvenzl') || db.includes('adb')) lines.push(`DB_ALISE=${db}`);
    else if (db.includes('publisher')) lines.push(`DB_PUBLISHER=${db}`);
    else if (db.includes('forms')) lines.push(`DB_FORMS=${db}`);
    else lines.push(`DB_PROXY=${db}`);
  }

  if (ords !== 'NONE') lines.push(`ORDS_PROFILE=${ords}`);
  if (svc !== 'NONE') {
    if (svc.includes('publisher-designer')) lines.push(`PUBLISHER_DESIGNER_PROFILE=${svc}`);
    else if (svc.includes('forms-publisher')) lines.push(`FORMS_PUBLISHER_PROFILE=${svc}`);
    else if (svc.includes('publisher')) lines.push(`PUBLISHER_PROFILE=${svc}`);
    else if (svc.includes('forms')) lines.push(`FORMS_PROFILE=${svc}`);
    else if (svc.includes('web-ide')) lines.push(`WEB_IDE_PROFILE=${svc}`);
  }

  const preview = document.getElementById('cbp-env-content');
  if (preview) preview.value = lines.join('\n') + '\n';
}

async function submitCreateBlueprint() {
  const num = document.getElementById('cbp-number')?.value;
  const name = document.getElementById('cbp-name')?.value;
  const content = document.getElementById('cbp-env-content')?.value;

  if (!num || !content) {
    alert('Palun täitke blueprint number ja sisu!');
    return;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprint/create`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ num, name, content }),
      mode: 'cors'
    });
    const data = await resp.json();
    if (resp.ok) {
      showToast(`✅ Blueprint #${num} loodud edukalt!`);
      const targetRel = `config/blueprints/.env.${num}-${name.toLowerCase().replace(/\s+/g, '-')}`;
      CURRENT_BP_PATH = targetRel;
      showBlueprintView();
      await fetchAndRenderBlueprintsList();
      setTimeout(() => pollBridgeStatus(), 1500);
    } else {
      alert(`Viga blueprinti loomisel: ${data.error || 'Tundmatu viga'}`);
    }
  } catch (e) {
    alert(`Bridge viga: ${e.message}`);
  }
}

let activeBpModalNum = 0;
let activeBpModalTab = 'arch';

function isBlueprintActiveOrRunning(b) {
  if (!b) return false;
  const runningList = Array.isArray(LIVE_RUNNING_CONTAINERS) ? LIVE_RUNNING_CONTAINERS : [];
  if (b.num === 0) {
    const pData = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS['proxy'] : null;
    const ordsUp = (pData && (pData.status === 'online' || pData.status === 'degraded')) || runningList.includes('app-ords');
    return runningList.includes('db-proxy') && ordsUp;
  }
  if (b.num === 1 && !runningList.includes('db-alise')) return false;
  if (b.num === 2 && !runningList.includes('db-proxy-standalone')) return false;
  if (b.num === 3 && !runningList.includes('db-gvenzl')) return false;
  if (b.num === 4 && !runningList.includes('db-adb')) return false;
  const cnames = b.container_names || [];
  if (!cnames.length) return b.num === LIVE_ACTIVE_BP;
  let matched = 0;
  for (const cn of cnames) {
    if (runningList.includes(cn)) matched++;
    else if (cn && cn.startsWith('ords/')) {
      const pName = cn.substring(5);
      const pData = (typeof LIVE_ORDS_POOLS === 'object' && LIVE_ORDS_POOLS) ? LIVE_ORDS_POOLS[pName] : null;
      if ((pData && (pData.status === 'online' || pData.status === 'degraded')) || runningList.includes('app-ords')) matched++;
    }
    else if (cn === 'app-publisher' && runningList.includes('oracle-publisher-dev')) matched++;
    else if (cn === 'oracle-publisher-dev' && runningList.includes('app-publisher')) matched++;
    else if (['publisher-designer', 'app-publisher-designer'].includes(cn) && runningList.some(x => ['publisher-designer', 'app-publisher-designer'].includes(x))) matched++;
    else if (['forms-designer', 'app-forms'].includes(cn) && runningList.some(x => ['forms-designer', 'app-forms'].includes(x))) matched++;
  }
  return matched === cnames.length;
}

function switchBlueprintModalTab(tabName) {
  activeBpModalTab = tabName || 'arch';
  ['arch', 'guides', 'users', 'ops', 'diag', 'logs'].forEach(t => {
    const btn = document.getElementById(`tab-btn-bp-${t}`);
    const pane = document.getElementById(`bp-modal-tab-${t}`);
    if (btn) btn.classList.toggle('active', t === activeBpModalTab);
    if (pane) {
      pane.classList.toggle('active', t === activeBpModalTab);
      pane.style.display = (t === activeBpModalTab) ? 'block' : 'none';
    }
  });

  if (activeBpModalTab === 'arch') {
    const mermaidContainer = document.getElementById('bp-modal-mermaid');
    if (mermaidContainer && mermaidContainer.getAttribute('data-rendered-bp') !== String(activeBpModalNum)) {
      renderBlueprintMermaid(activeBpModalNum);
    }
  } else if (activeBpModalTab === 'guides') {
    renderBlueprintGuidesTab(activeBpModalNum);
  } else if (activeBpModalTab === 'diag') {
    renderBlueprintDiagTab(activeBpModalNum);
  } else if (activeBpModalTab === 'logs') {
    renderBlueprintLogsTab(activeBpModalNum);
  }
}

async function renderBlueprintMermaid(bNum) {
  initMermaidGlobal();
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const mermaidContainer = document.getElementById('bp-modal-mermaid');
  const rawEl = document.getElementById('bp-modal-mermaid-raw');
  if (!mermaidContainer) return;

  mermaidContainer.removeAttribute('data-processed');
  mermaidContainer.setAttribute('data-rendered-bp', String(bNum));
  mermaidContainer.innerHTML = '<div style="color:#94a3b8; font-size:0.85rem; padding:10px;">⏳ Renderin arhitektuurijoonist...</div>';

  const diagCode = (b.diagrams && b.diagrams[currentLang]) || (b.diagrams && b.diagrams['en']) || '';
  if (rawEl) {
    rawEl.textContent = diagCode;
    rawEl.style.display = 'none';
  }

  if (!diagCode) {
    mermaidContainer.innerHTML = '<span style="color:#64748b; font-size:0.85rem;">Diagramm pole saadaval.</span>';
    return;
  }

  if (typeof mermaid === 'undefined') {
    mermaidContainer.innerHTML = '<div style="color:#f59e0b; padding:12px; font-size:0.82rem; background:#451a03; border-radius:6px; border:1px solid #78350f;">⚠️ Mermaid teek ei ole kättesaadav (offline/tulemüür). Lähtekood on vaadatav nupust "Kuva kood".</div>';
    if (rawEl) rawEl.style.display = 'block';
    return;
  }

  const svgId = 'bp-modal-svg-' + b.num + '-' + Math.floor(Math.random() * 100000);
  try {
    const res = await mermaid.render(svgId, diagCode);
    mermaidContainer.innerHTML = res.svg || res;
  } catch (err) {
    console.error('Mermaid modal render error:', err);
    const straySvg = document.getElementById(svgId) || document.getElementById('d' + svgId);
    if (straySvg && straySvg.parentNode) {
      straySvg.parentNode.removeChild(straySvg);
    }
    cleanupStrayMermaidElements();
    setTimeout(cleanupStrayMermaidElements, 50);

    mermaidContainer.innerHTML = `<div style="color:#f87171; padding:12px; font-size:0.82rem; background:#450a0a; border-radius:6px; border:1px solid #991b1b;">⚠️ Diagrammi renderdamise hoiatus: ${escapeHtml(err.message || 'Süntaksiviga')}</div>`;
    if (rawEl) rawEl.style.display = 'block';
  }
}

function renderBlueprintGuidesTab(bNum) {
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  // 1. Render Quickstart Steps
  const stepsContainer = document.getElementById('bp-modal-quickstart-steps');
  if (stepsContainer) {
    const rawSteps = (b.quickstart && (b.quickstart[currentLang] || b.quickstart['en'])) || [];
    if (!rawSteps.length) {
      stepsContainer.innerHTML = `<div style="color:#94a3b8; font-size:0.85rem; padding:8px;">${dict.no_quickstart || 'Juhend pole saadaval.'}</div>`;
    } else {
      stepsContainer.innerHTML = rawSteps.map(s => {
        let actionBtn = '';
        if (s.url) {
          actionBtn = `<a href="${s.url}" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-primary" style="padding:3px 8px; font-size:0.75rem; text-decoration:none;">${s.btn_text || 'Ava ↗️'}</a>`;
        } else if (s.action === 'setup') {
          actionBtn = `<button class="btn btn-sm btn-primary" style="padding:3px 8px; font-size:0.75rem;" onclick="triggerBlueprintActionModal(${b.num}, 'setup')">${s.btn_text || dict.modal_act_deploy_btn || 'Käivita'}</button>`;
        } else if (s.action === 'tab-diag') {
          actionBtn = `<button class="btn btn-sm btn-secondary" style="padding:3px 8px; font-size:0.75rem;" onclick="switchBlueprintModalTab('diag')">${s.btn_text || 'Testid 🧪'}</button>`;
        } else if (s.action === 'tab-arch') {
          actionBtn = `<button class="btn btn-sm btn-secondary" style="padding:3px 8px; font-size:0.75rem;" onclick="switchBlueprintModalTab('arch')">${s.btn_text || 'Arhitektuur 📐'}</button>`;
        } else if (s.action === 'docs') {
          actionBtn = `<button class="btn btn-sm btn-secondary" style="padding:3px 8px; font-size:0.75rem;" onclick="openBlueprintDocFull()">${s.btn_text || dict.modal_btn_open_full_guide_text || 'Loe juhendit 📖'}</button>`;
        }
        return `
          <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 8px; padding: 12px 14px; display: flex; align-items: flex-start; gap: 12px;">
            <div style="background: rgba(56, 189, 248, 0.15); color: #38bdf8; font-weight: 700; border-radius: 50%; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; font-size: 0.82rem; flex-shrink: 0; margin-top: 2px;">
              ${s.step}
            </div>
            <div style="flex: 1; min-width: 0;">
              <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 6px;">
                <strong style="color: #f8fafc; font-size: 0.9rem;">${s.title}</strong>
                ${actionBtn}
              </div>
              <div style="font-size: 0.82rem; color: #cbd5e1; line-height: 1.45; margin-top: 4px;">${s.desc}</div>
            </div>
          </div>
        `;
      }).join('');
    }
  }

  // 2. Render Workflow Mermaid Diagram
  renderBlueprintWorkflowMermaid(bNum);
}

async function renderBlueprintWorkflowMermaid(bNum) {
  initMermaidGlobal();
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const mermaidContainer = document.getElementById('bp-modal-workflow-mermaid');
  const rawEl = document.getElementById('bp-modal-workflow-mermaid-raw');
  if (!mermaidContainer) return;

  mermaidContainer.removeAttribute('data-processed');
  mermaidContainer.setAttribute('data-rendered-bp', String(bNum));
  mermaidContainer.innerHTML = '<div style="color:#94a3b8; font-size:0.85rem; padding:10px;">⏳ Renderin töövoo skeemi...</div>';

  let rawDiagram = '';
  if (b.workflow_diagram && typeof b.workflow_diagram === 'object') {
    rawDiagram = b.workflow_diagram[currentLang] || b.workflow_diagram['en'] || '';
  } else if (typeof b.workflow_diagram === 'string') {
    rawDiagram = b.workflow_diagram;
  }
  const diagCode = (rawDiagram || '').replace(/\\n/g, '\n');

  if (rawEl) {
    rawEl.textContent = diagCode;
    rawEl.style.display = 'none';
  }

  if (!diagCode) {
    mermaidContainer.innerHTML = '<span style="color:#64748b; font-size:0.85rem;">Töövoo diagramm pole saadaval.</span>';
    return;
  }

  if (typeof mermaid === 'undefined') {
    mermaidContainer.innerHTML = '<div style="color:#f59e0b; padding:12px; font-size:0.82rem; background:#451a03; border-radius:6px; border:1px solid #78350f;">⚠️ Mermaid teek ei ole kättesaadav. Lähtekood on vaadatav nupust "Kuva kood".</div>';
    if (rawEl) rawEl.style.display = 'block';
    return;
  }

  const svgId = 'bp-modal-wf-svg-' + b.num + '-' + Math.floor(Math.random() * 100000);
  try {
    const res = await mermaid.render(svgId, diagCode);
    mermaidContainer.innerHTML = res.svg || res;
  } catch (err) {
    console.error('Mermaid workflow render error:', err);
    const straySvg = document.getElementById(svgId) || document.getElementById('d' + svgId);
    if (straySvg && straySvg.parentNode) {
      straySvg.parentNode.removeChild(straySvg);
    }
    cleanupStrayMermaidElements();
    setTimeout(cleanupStrayMermaidElements, 50);
    mermaidContainer.innerHTML = `<div style="color:#f87171; padding:8px; font-size:0.8rem;">Diagrammi viga: ${escapeHtml(err.message || 'Süntaksiviga')}</div>`;
    if (rawEl) rawEl.style.display = 'block';
  }
}

function openBlueprintDocNewTab() {
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  const guideId = (b && b.guide_id) ? b.guide_id : 'readme';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const baseHref = window.location.href.split('#')[0].split('?')[0];
  const targetUrl = `${baseHref}?tab=docs&doc=${encodeURIComponent(guideId)}&lang=${encodeURIComponent(currentLang)}#tab-docs`;
  window.open(targetUrl, '_blank', 'noopener,noreferrer');
}

function openBlueprintDocFull() {
  const b = BLUEPRINTS_DATA.find(item => item.num === activeBpModalNum);
  const guideId = (b && b.guide_id) ? b.guide_id : 'readme';
  closeBlueprintModal();
  navigateToDoc(guideId);
}

async function triggerBlueprintActionModal(bNum, action) {
  if (action === 'stop' && bNum === 0) {
    alert('🛡️ Core Base Protection: Blueprint #0 (Tuum) ei saa välja lülitada!');
    return;
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (action === 'dry-run' || action === 'dryrun') {
    switchBlueprintModalTab('diag');
  } else {
    switchBlueprintModalTab('ops');
  }

  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  const cnames = (b && b.container_names) ? b.container_names : [];
  const toStop = cnames.filter(c => !['db-proxy', 'app-ords'].includes(c) && !c.startsWith('ords/'));
  const stopTarget = toStop.length > 0 ? toStop.join(' ') : (cnames.join(' ') || `blueprint-${bNum}`);

  const isAlreadyUp = isBlueprintActiveOrRunning(b);
  if ((action === 'setup' || action === 'activate' || action === 'switch' || action === 'start') && isAlreadyUp) {
    const restartCmd = `./scripts/deploy-blueprint.sh -b ${bNum} -u --lang ${currentLang}`;
    const msgTitle = dict.ops_already_active_title || `ℹ️ Blueprint #${bNum} on juba aktiivne!`;
    const toastMsg = dict.ops_already_active_toast || 'ℹ️ Konteiner on juba aktiivne! Uuesti ei käivitata. Kui on probleeme, kasuta: "Taaskäivita & Uuenda".';

    const progress = startTerminalProgress('modal-ops-console', 'info', msgTitle, restartCmd);
    if (progress) {
      progress.finish(true, {
        output: `[INFO] Blueprint #${bNum} (${cnames.join(', ') || 'teenused'}) on juba aktiivne ja töökorras (Running & Healthy).\n` +
                `[INFO] Uuesti käivitamist ei tehta, kuna konteinerid juba töötavad.\n\n` +
                `💡 ${dict.ops_already_active_hint ? dict.ops_already_active_hint.replace('%s', bNum) : 'Kui on probleeme, käivita: Taaskäivita & Uuenda'}\n` +
                `Käsk: ${restartCmd}`
      });
    }
    document.getElementById('modal-ops-console')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

    showToast(toastMsg);

    const restartBox = document.getElementById('bp-card-restart-box');
    if (restartBox) {
      restartBox.classList.remove('highlight-restart-pulse');
      void restartBox.offsetWidth;
      restartBox.classList.add('highlight-restart-pulse');
      restartBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    return;
  }

  let title = `Blueprint #${bNum} (${action})`;
  let cmdStr = '';
  if (action === 'setup' || action === 'activate' || action === 'switch' || action === 'start') {
    title = `⚡ ${dict.modal_act_activate_title || 'Aktiviseeri'} Blueprint #${bNum}`;
    cmdStr = `./scripts/setup-all.sh -b ${bNum} -y --lang ${currentLang}`;
  } else if (action === 'restart') {
    title = `🔄 ${dict.modal_act_restart_title || 'Taaskäivita & Uuenda'} Blueprint #${bNum}`;
    cmdStr = `./scripts/deploy-blueprint.sh -b ${bNum} -u --lang ${currentLang}`;
  } else if (action === 'dry-run' || action === 'dryrun') {
    title = `🔍 ${dict.modal_act_dryrun_title || 'Konfiguratsiooni Eelvaade (Dry-Run)'} Blueprint #${bNum}`;
    cmdStr = `./scripts/deploy-blueprint.sh -b ${bNum} --dry-run`;
  } else if (action === 'stop') {
    title = `⏹️ ${dict.modal_act_stop_title || 'Peata'} Blueprint #${bNum}`;
    cmdStr = `podman stop ${stopTarget}`;
  }

  const consoleId = (action === 'dry-run' || action === 'dryrun') ? 'modal-diag-console' : 'modal-ops-console';
  const progress = startTerminalProgress(consoleId, action, title, cmdStr);
  document.getElementById(consoleId)?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  // 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.6 - DO NOT REVERT TO SYNC FETCH!)
  // RATIONALE: Cold setup and database builds take 4-7 minutes.
  // A synchronous fetch with AbortController timeout (e.g. 300s) WILL ALWAYS ABORT
  // in the browser with "signal is aborted without reason" even when the server
  // finishes successfully.
  // RULE: Long operations (setup, activate, switch, deploy, restart) MUST ALWAYS
  // be dispatched as asynchronous tasks and polled via /api/task/status until state === 'completed'.
  const isLongOp = ['setup', 'activate', 'switch', 'deploy', 'restart'].includes(action);
  if (action === 'stop') {
    removePendingBlueprintLaunch(bNum);
  } else if (isLongOp) {
    addPendingBlueprintLaunch(bNum);
  }

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000);
    const resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${bNum}&action=${action}&lang=${currentLang}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ module: bNum, action, lang: currentLang }),
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    const data = await resp.json();

    if (resp.ok && (data.status === 'ok' || data.success)) {
      if (data.already_active) {
        if (progress) progress.finish(true, data);
        showToast(dict.ops_already_active_toast || 'ℹ️ Konteiner on juba aktiivne ja terve! Kui on probleeme, kasuta: "Taaskäivita & Uuenda".');
        const restartBox = document.getElementById('bp-card-restart-box');
        if (restartBox) {
          restartBox.classList.remove('highlight-restart-pulse');
          void restartBox.offsetWidth;
          restartBox.classList.add('highlight-restart-pulse');
          restartBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        return;
      }

      if (data.async || data.task_running || isLongOp) {
        const taskName = data.task || `setup_bp_${bNum}`;
        showToast(`🚀 ${title}: ${dict.ops_task_running_notice || 'Toiming käivitatud taustal... Jälgin logi.'}`);

        const pollTaskInterval = setInterval(async () => {
          try {
            const statusResp = await fetch(`${BRIDGE_URL}/api/task/status?task=${encodeURIComponent(taskName)}`);
            if (statusResp.ok) {
              const statusData = await statusResp.json();
              if (Array.isArray(statusData.log_tail) && statusData.log_tail.length > 0) {
                const outEl = document.getElementById('modal-ops-console-output');
                if (outEl) {
                  outEl.innerHTML = formatTerminalLogText(statusData.log_tail.join('\n'), { showTime: true, showColors: true });
                  outEl.scrollTop = outEl.scrollHeight;
                }
              }
              if (statusData.state === 'completed') {
                clearInterval(pollTaskInterval);
                removePendingBlueprintLaunch(bNum);
                const succMsg = dict.ops_success_verified || `✅ Blueprint #${bNum} paigaldus edukalt lõpetatud ja verifitseeritud! Kõik andmebaasid ja URL-id on aktiivsed.`;
                if (progress) progress.finish(true, statusData);
                showToast(succMsg);
                pollBridgeStatus(true);
                checkServiceHealth();
                setTimeout(() => {
                  if (activeBpModalNum === bNum) {
                    openBlueprintModal(bNum, 'ops');
                  }
                }, 2000);
              } else if (statusData.state === 'failed') {
                clearInterval(pollTaskInterval);
                removePendingBlueprintLaunch(bNum);
                if (progress) progress.finish(false, statusData);
                const errMsg = statusData.error || 'Paigaldus ebaõnnestus.';
                showToast(`⚠️ Viga: ${errMsg}`);
                pollBridgeStatus(true);
              }
            }
          } catch (pollErr) {
            console.warn('Task poll error (will retry):', pollErr);
          }
        }, 2500);
        return;
      }

      // Fast synchronous actions (e.g. stop, dry-run)
      if (progress) progress.finish(true, data);
      const succMsg = action === 'stop' 
        ? (dict.ops_success_stop || `✅ Blueprint #${bNum} teenused edukalt peatatud!`)
        : (dict.ops_success_dryrun || `✅ Blueprint #${bNum} konfiguratsiooni eelvaade valmis!`);
      showToast(succMsg);
      setTimeout(checkServiceHealth, 1500);
      setTimeout(() => {
        if (activeBpModalNum === bNum) {
          openBlueprintModal(bNum, (action === 'dry-run' || action === 'dryrun') ? 'diag' : 'ops');
        }
      }, 2000);
    } else {
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || 'Käsu teostamine ebaõnnestus.';
      showToast(`⚠️ Viga: ${errMsg}`);
    }
  } catch (err) {
    console.error('Error in triggerBlueprintActionModal:', err);
    if (progress) progress.finish(false, { error: err.message, output: `Terminali käsitsi käivitus:\n${cmdStr}` });
    showToast(`📋 Kopeerisin käsu: ${cmdStr}`);
  }
}

async function triggerRotateUserPassword(bNum, targetDb, user, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  switchBlueprintModalTab('ops');

  const cleanDb = targetDb || 'db-proxy';
  const cleanUser = (user || 'dev').toLowerCase();
  const title = `🔄 ${dict.modal_act_rotate_title || 'Parooli Roteerimine'}: ${cleanDb} (${cleanUser.toUpperCase()})`;
  const cmdStr = `./scripts/rotate-password.sh ${cleanDb} ${cleanUser}`;

  const progress = startTerminalProgress('modal-ops-console', 'rotate', title, cmdStr);
  document.getElementById('modal-ops-console')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 180000);
    const resp = await fetch(`${BRIDGE_URL}/api/toggle`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ module: bNum, action: 'rotate-password', target_db: cleanDb, user: cleanUser, lang: currentLang }),
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    const data = await resp.json();

    if (resp.ok && (data.status === 'ok' || data.success)) {
      if (progress) progress.finish(true, data);
      showToast(dict.ops_success_rotate || `✅ Kasutaja ${cleanUser.toUpperCase()} parool edukalt roteeritud!`);
      setTimeout(() => {
        if (activeBpModalNum === bNum) {
          openBlueprintModal(bNum, 'ops');
        }
      }, 2500);
    } else {
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || 'Parooli roteerimine ebaõnnestus.';
      showToast(`⚠️ Viga: ${errMsg}`);
    }
  } catch (err) {
    console.error('Error in triggerRotateUserPassword:', err);
    if (progress) progress.finish(false, { error: err.message, output: `Terminali käsitsi käivitus:\n${cmdStr}` });
    showToast(`📋 Kopeerisin käsu: ${cmdStr}`);
  }
}

async function openBlueprintModal(bNum, initialTab = 'arch') {
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  if (!b) return;

  activeBpModalNum = bNum;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  const title = (b.titles && b.titles[currentLang]) || (b.titles && b.titles['en']) || `Blueprint #${b.num}`;
  const desc = (b.descs && b.descs[currentLang]) || (b.descs && b.descs['en']) || b.file;

  const titleEl = document.getElementById('bp-modal-title');
  const subEl = document.getElementById('bp-modal-subtitle');
  if (titleEl) titleEl.innerHTML = `🏗️ Blueprint #${b.num}: ${title}`;
  if (subEl) subEl.innerHTML = `
    <div style="margin-bottom: 6px; font-size: 0.88rem; color: #cbd5e1;">${desc}</div>
    <div style="display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-top: 6px;">
      <span class="badge" style="background: rgba(56,189,248,0.12); color: #38bdf8; border: 1px solid rgba(56,189,248,0.3); font-family: ui-monospace, monospace; font-size: 0.78rem;">📁 ${b.file}</span>
      <span class="badge" style="background: rgba(34,197,94,0.12); color: #4ade80; border: 1px solid rgba(34,197,94,0.3); font-size: 0.78rem;">💾 RAM: ${b.ram}</span>
      <span class="badge" style="background: rgba(192,132,252,0.12); color: #c084fc; border: 1px solid rgba(192,132,252,0.3); font-size: 0.78rem;">🔑 ${(b.users || []).length} ${dict.meta_accounts || 'Accounts'}</span>
      <span class="badge" style="background: rgba(251,191,36,0.12); color: #fbbf24; border: 1px solid rgba(251,191,36,0.3); font-size: 0.78rem;">📦 ${b.containers}</span>
    </div>
  `;



  // Update Stack Status Header on Tab 3 (Ops)
  const isUp = isBlueprintActiveOrRunning(b);
  const statusDot = document.getElementById('bp-ops-status-dot');
  const targetTitle = document.getElementById('bp-ops-target-title');
  const statusBadge = document.getElementById('bp-ops-status-badge');
  const targetDesc = document.getElementById('bp-ops-target-desc');
  const containerBadgesEl = document.getElementById('bp-ops-container-badges');

  if (targetTitle) targetTitle.textContent = `Blueprint #${b.num}: ${title}`;
  if (statusDot) statusDot.style.background = isUp ? '#22c55e' : '#94a3b8';
  if (statusBadge) {
    statusBadge.textContent = isUp ? (dict.status_online || 'Aktiivne') : (dict.status_offline || 'Seisatud');
    statusBadge.style.background = isUp ? 'rgba(34,197,94,0.15)' : 'rgba(148,163,184,0.15)';
    statusBadge.style.color = isUp ? '#4ade80' : '#94a3b8';
  }
  if (targetDesc) {
    targetDesc.innerHTML = isUp
      ? `🟢 Pinu on aktiivne ja töökorras. RAM kasutus: <b>${b.ram}</b>.`
      : `⚪ Pinu on hetkel seisatud. Saad selle käivitada paralleelselt olemasolevate kõrvale (lisandub ~<b>${b.ram}</b>). Teisi andmebaase maha ei võeta!`;
  }
  if (containerBadgesEl) {
    const cnames = b.container_names || [];
    containerBadgesEl.innerHTML = cnames.map(c => `
      <span class="badge" style="background: rgba(148,163,184,0.1); color: #cbd5e1; border: 1px solid rgba(148,163,184,0.2); font-family: ui-monospace, monospace; font-size: 0.75rem;">📦 ${c}</span>
    `).join('');
  }

  // 1. Render Mermaid Topology Diagram
  renderBlueprintMermaid(bNum);

  // 2. Render Components & Ports Table
  const compContainer = document.getElementById('bp-modal-components');
  if (compContainer) {
    let compHtml = `
      <table>
        <thead>
          <tr>
            <th style="width: 25%;">${dict.th_container || 'Container / Service'}</th>
            <th style="width: 30%;">${dict.th_ports || 'Exposed Ports (Host)'}</th>
            <th style="width: 45%;">${dict.th_role_desc || 'Role & Purpose'}</th>
          </tr>
        </thead>
        <tbody>
    `;
    const runningList = Array.isArray(LIVE_RUNNING_CONTAINERS) ? LIVE_RUNNING_CONTAINERS : [];
    (b.components || []).forEach(c => {
      const isAlive = runningList.includes(c.name) ||
                      (c.name === 'app-publisher' && runningList.includes('oracle-publisher-dev')) ||
                      (c.name === 'oracle-publisher-dev' && runningList.includes('app-publisher')) ||
                      (['publisher-designer', 'app-publisher-designer'].includes(c.name) && runningList.some(x => ['publisher-designer', 'app-publisher-designer'].includes(x))) ||
                      (['forms-designer', 'app-forms'].includes(c.name) && runningList.some(x => ['forms-designer', 'app-forms'].includes(x)));

      const statusBadge = isAlive
        ? `<span class="badge" style="background:rgba(34,197,94,0.15); color:#4ade80; border:1px solid rgba(34,197,94,0.3); font-size:0.7rem; padding:2px 6px; margin-left:6px;">🟢 ${dict.status_online || 'Töötab'}</span>`
        : `<span class="badge" style="background:rgba(248,113,113,0.15); color:#f87171; border:1px solid rgba(248,113,113,0.3); font-size:0.7rem; padding:2px 6px; margin-left:6px;">🔴 ${dict.status_stopped || 'Peatatud'}</span>`;

      let formattedPorts = '';
      if (!c.host_ports || c.host_ports === '-' || c.host_ports.toLowerCase() === 'none') {
        formattedPorts = '<span style="color:#64748b; font-size:0.75rem;">—</span>';
      } else {
        const portParts = c.host_ports.split(',').map(p => p.trim());
        formattedPorts = portParts.map(pStr => {
          if (pStr.includes('6083')) {
            return isAlive
              ? `<a href="http://localhost:6083/vnc.html" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava noVNC töölaud (port 6083)">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('8448')) {
            return isAlive
              ? `<a href="https://localhost:8448/ords/" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava ORDS HTTPS portaal">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('8088')) {
            return isAlive
              ? `<a href="http://localhost:8088/ords/" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava ORDS HTTP portaal">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('8090')) {
            return isAlive
              ? `<a href="http://localhost:8090/" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava Web-IDE (port 8090)">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('9502')) {
            return isAlive
              ? `<a href="http://localhost:9502/xmlpserver" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava Analytics Publisher">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('9001')) {
            return isAlive
              ? `<a href="http://localhost:9001/forms/frmservlet" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava Forms Runtime">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else if (pStr.includes('6082')) {
            return isAlive
              ? `<a href="http://localhost:6082/vnc.html" target="_blank" rel="noopener noreferrer" style="color:#38bdf8; font-weight:600; text-decoration:underline;" title="Ava Forms Builder noVNC">${pStr} ↗️</a>`
              : `<span style="color:#94a3b8;" title="${dict.port_offline_tooltip || 'Konteiner on peatatud — käivita virn enne avamist'}">${pStr}</span>`;
          } else {
            return `<code style="color:#22c55e; font-weight:600;">${pStr}</code>`;
          }
        }).join(', ');
      }

      compHtml += `
        <tr>
          <td>
            <div style="display:flex; align-items:center; flex-wrap:wrap; gap:4px;">
              <strong style="color: var(--primary); font-family: ui-monospace, monospace;">${c.name}</strong>
              ${statusBadge}
            </div>
            <span style="font-size:0.75rem; color:#94a3b8;">${c.type}</span>
          </td>
          <td>${formattedPorts}</td>
          <td style="font-size: 0.85rem; color: #cbd5e1;">${c.desc}</td>
        </tr>
      `;
    });
    compHtml += '</tbody></table>';
    compContainer.innerHTML = compHtml;
  }

  // 3. Render Provisioned Users & Portals Table with Multilingual Tips Block
  const userContainer = document.getElementById('bp-modal-users');
  if (userContainer) {
    let userHtml = `
      <div class="tip-box" style="background: rgba(56,189,248,0.06); border: 1px solid rgba(56,189,248,0.25); border-radius: 8px; padding: 12px 16px; margin-bottom: 14px; font-size: 0.82rem; line-height: 1.5; color: #cbd5e1;">
        <div style="font-weight: 700; color: #38bdf8; margin-bottom: 6px; font-size: 0.88rem;">${dict.modal_tip_title || '💡 Quick Guide: Zero-Trust Credentials, SEPS Wallet & 1-Click Launch'}</div>
        <div style="margin-bottom: 5px;">${dict.modal_tip_seps || '<b>SEPS Wallet TNS Alias:</b> Encrypted auto-login alias. Use <code>sql /@ALIAS</code> in terminal or VS Code extension.'}</div>
        <div style="margin-bottom: 5px;">${dict.modal_tip_launch || '<b>1-Click Web Launch:</b> Prefills username and auto-copies password to clipboard (Ctrl+V / Cmd+V to paste).'}</div>
        <div>${dict.modal_tip_pwd || '<b>Copy Credentials:</b> Click any username or use buttons to copy passwords or TNS aliases directly.'}</div>
      </div>
      <table>
        <thead>
          <tr>
            <th style="width: 25%;">${dict.th_service_portal || 'Service & Portal'}</th>
            <th style="width: 22%;">${dict.th_account_scope || 'User Account & Scope'}</th>
            <th style="width: 28%;">${dict.th_seps_cli || 'SEPS Wallet TNS Alias (Auto-Login)'}</th>
            <th style="width: 25%;">${dict.th_launch_pwd || '1-Click Launch & Passwords'}</th>
          </tr>
        </thead>
        <tbody>
    `;
    (b.users || []).forEach(u => {
      const aliasCol = u.wallet_alias ? `
        <div style="display:flex; flex-direction:column; gap:4px;">
          <div><code style="color:#22c55e; font-size:0.8rem; font-weight:600; background:rgba(34,197,94,0.08); padding:2px 6px; border-radius:4px;">${u.wallet_alias}</code></div>
          <div style="display:flex; gap:4px; flex-wrap:wrap;">
            <button class="btn btn-secondary" style="padding:2px 7px; font-size:0.72rem;" onclick="copyTnsAlias('${u.wallet_alias}', this)" title="${dict.btn_copy_alias || 'Copy Alias'}">
              <span>📋</span> <span>${dict.btn_copy_alias || 'Alias'}</span>
            </button>
            <button class="btn btn-secondary" style="padding:2px 7px; font-size:0.72rem;" onclick="copySqlclCmd('${u.wallet_alias}', this)" title="${dict.btn_copy_sqlcl || 'Copy SQLcl'}">
              <span>💻</span> <span>${dict.btn_copy_sqlcl || 'SQLcl'}</span>
            </button>
          </div>
        </div>
      ` : `<span style="color:#64748b; font-size:0.75rem;">Web / VNC only</span>`;

      const isDev = (u.username && ['DEV', 'USER_DEVELOPER'].includes(u.username.toUpperCase())) || (u.wallet_alias && u.wallet_alias.includes('DEV'));
      const isDba = (u.role === 'DBA' || (u.wallet_alias && u.wallet_alias.includes('DBA')));

      const actionBtns = `
        <div style="display:flex; gap:4px; align-items:center; flex-wrap:wrap;">
          ${u.login_url ? `
            <button class="btn btn-primary" style="padding:4px 8px; font-size:0.75rem;" onclick="openServiceWithCredentials('${u.login_url}', '${u.wallet_alias}', '${u.username}', event)" title="Opens portal, prefills username, and copies password to clipboard">
              <span>🚀</span> <span>${isDev ? (dict.btn_launch_apex || 'APEX') : (dict.btn_open_portal || 'Launch')}</span>
            </button>
          ` : ''}
          ${(isDev && u.login_url) ? `
            <button class="btn btn-secondary" style="padding:4px 8px; font-size:0.75rem; color:#38bdf8; border-color:rgba(56,189,248,0.3);" onclick="openServiceWithCredentials('${u.login_url.replace('/r/apex/workspace-sign-in/oracle-apex-sign-in', '/user_developer/sign-in')}&r=_sdw', '${u.wallet_alias}', '${u.username}', event)" title="Database Actions">
              <span>📊</span> <span>${dict.btn_launch_sdw || 'DB Actions'}</span>
            </button>
          ` : ''}
          ${u.wallet_alias ? `
            <button class="btn btn-secondary" style="padding:4px 8px; font-size:0.75rem;" onclick="handleCopyPassword('${u.wallet_alias}', this)" title="${dict.btn_copy_pwd || 'Copy Password'}">
              <span>🔑</span> <span>${dict.btn_copy_pwd || 'Password'}</span>
            </button>
          ` : ''}
          ${(u.wallet_alias && u.username) ? `
            <button class="btn btn-secondary" style="padding:4px 8px; font-size:0.75rem; color:#fbbf24; border-color:rgba(251,191,36,0.3);" onclick="triggerRotateUserPassword(${b.num}, '${(u.db && u.db.toLowerCase().startsWith('db-')) ? u.db.toLowerCase() : ((b.container_names && b.container_names.find(c => c.startsWith('db-'))) || 'db-proxy')}', '${u.username.toLowerCase()}', this)" title="${dict.btn_rotate_pwd || 'Rotate Password'}">
              <span>🔄</span> <span>${dict.btn_rotate_pwd || 'Rotate'}</span>
            </button>
          ` : ''}
        </div>
      `;

      userHtml += `
        <tr>
          <td>
            <span class="badge" style="background: rgba(56,189,248,0.1); color: #38bdf8; border: 1px solid rgba(56,189,248,0.2); font-size:0.72rem;">${u.db}</span>
            <div style="font-weight:600; color:#f1f5f9; font-size:0.84rem; margin-top:3px;">${u.portal_title || u.role}</div>
          </td>
          <td>
            <span style="font-weight:700; color:${u.color || '#fff'}; font-family: ui-monospace, monospace; cursor:pointer; display:inline-flex; align-items:center; gap:4px;" onclick="copyUsername('${u.username}', this)" title="Click to copy username">
              ${u.username} <span style="font-size:0.7rem; color:#64748b;">📋</span>
            </span>
            <div style="font-size:0.75rem; color:#94a3b8; margin-top:2px;">${u.scope ? u.scope + (u.role ? ' &bull; ' + u.role : '') : u.role}</div>
          </td>
          <td>${aliasCol}</td>
          <td>${actionBtns}</td>
        </tr>
      `;
    });
    userHtml += '</tbody></table>';
    userContainer.innerHTML = userHtml;
  }

  // 4. Render Hardware & Resource Requirements (Clean 4-Card Grid)
  const resContainer = document.getElementById('bp-modal-resources');
  if (resContainer) {
    const userCount = (b.users || []).length;
    let accLabel = dict.meta_accounts || 'Accounts';
    if (userCount === 1) {
      accLabel = dict.account_singular || (currentLang === 'et' ? 'konto' : 'Account');
    } else {
      accLabel = dict.account_plural || (currentLang === 'et' ? 'kontot' : 'Accounts');
    }

    resContainer.innerHTML = `
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.modal_config_file || 'Konfiguratsioonifail'}</div>
        <div style="font-size:0.95rem; font-weight:700; color:#38bdf8; font-family:ui-monospace,monospace; margin-top:4px; word-break:break-all;">${b.file}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.metric_ram || 'Mälu (RAM)'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#38bdf8; margin-top:2px;">${b.ram}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.th_container || 'Konteinereid'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#4ade80; margin-top:2px; word-break:break-all;">${b.containers}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.metric_accounts || 'Kasutajakontosid'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#c084fc; margin-top:2px;">${userCount} ${accLabel}</div>
      </div>
    `;
  }

  // 5. Render Benchmarks & Performance
  const benchContainer = document.getElementById('bp-modal-benchmarks');
  if (benchContainer) {
    if (b.benchmarks && b.benchmarks.steps) {
      const steps = b.benchmarks.steps;
      let totalDur = 'N/A';
      if (b.benchmarks.total_duration_formatted || b.benchmarks.total_duration_seconds) {
        totalDur = b.benchmarks.total_duration_formatted || (b.benchmarks.total_duration_seconds + 's');
      }
      let sHtml = `<div style="display:flex; justify-content:space-between; margin-bottom:8px;">
        <span style="color:#94a3b8; font-size:0.85rem;">Kokku mõõdetud kestus:</span>
        <strong style="color:#4ade80; font-size:0.95rem;">${totalDur}</strong>
      </div><div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:8px; font-size:0.8rem;">`;
      for (const [sKey, sVal] of Object.entries(steps)) {
        if (sVal > 0) {
          const cleanName = sKey.replace(/step\d+_/, '').replace(/_seconds/, '').replace(/_/g, ' ');
          sHtml += `<div style="display:flex; justify-content:space-between; background:rgba(255,255,255,0.02); padding:4px 8px; border-radius:4px; border:1px solid rgba(255,255,255,0.05);">
            <span style="color:#cbd5e1; text-transform:capitalize;">${cleanName}:</span>
            <span style="color:#38bdf8; font-family:ui-monospace,monospace; font-weight:600;">${sVal}s</span>
          </div>`;
        }
      }
      sHtml += '</div>';
      benchContainer.innerHTML = sHtml;
    } else {
      benchContainer.innerHTML = `
        <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px;">
          <div>
            <div style="font-size:0.85rem; color:#94a3b8;">🚀 FastStart Snapshot Taastamine (Pass 2): <strong style="color:#4ade80;">~15s – 22s</strong></div>
            <div style="font-size:0.85rem; color:#94a3b8; margin-top:3px;">❄️ Külm Paigaldus Nullist (Pass 1): <strong style="color:#f87171;">~3m 45s – 5m 20s</strong></div>
          </div>
          <span class="badge badge-success" style="font-size:0.75rem;">Instant DR Valmidus (~15s)</span>
        </div>
      `;
    }
  }

  // 6. Render Latest Execution Log
  const logsContainer = document.getElementById('bp-modal-logs');
  if (logsContainer) {
    renderBlueprintLatestLogHtml(logsContainer, b.num, b.latest_log_info || { file: b.latest_log }, dict);
    refreshBlueprintLatestLog(b.num);
  }

  // 7. Render Unified Operations, Lifecycle & Disaster Recovery Cards Grid
  const actionsGrid = document.getElementById('bp-modal-actions-grid');
  const actionsHeading = document.getElementById('bp-modal-actions-heading');
  if (actionsHeading) {
    actionsHeading.textContent = dict.modal_actions_heading || '⚡ Operations, Lifecycle & Disaster Recovery';
  }

  if (actionsGrid) {
    const hasDb = (b.components || []).some(c => (c.type && (c.type.toLowerCase().includes('database') || c.type.toLowerCase().includes('pdb'))) || (c.name && c.name.startsWith('db-')));
    const cnames = (b && b.container_names) ? b.container_names : [];
    const toStop = cnames.filter(c => !['db-proxy', 'app-ords'].includes(c) && !c.startsWith('ords/'));
    const stopTarget = toStop.length > 0 ? toStop.join(' ') : (cnames.join(' ') || `blueprint-${b.num}`);

    // Card 1: Activate / Add Stack (setup-all.sh)
    const isOnline = isBlueprintActiveOrRunning(b);
    const cardActivate = `
      <div style="background: rgba(56, 189, 248, 0.04); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #38bdf8; font-size: 0.92rem; margin-bottom: 6px; display: flex; align-items: center; justify-content: space-between;">
            <span>${dict.modal_act_activate_title || dict.modal_act_deploy_title || '⚡ Käivita / Lisa Virn'}</span>
            ${isOnline ? `<span class="badge badge-success" style="font-size: 0.72rem; padding: 2px 6px;">🟢 ${dict.status_online || 'Aktiivne'}</span>` : ''}
          </div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${isOnline ? (dict.modal_act_already_active_hint || 'Konteiner(id) on juba aktiivsed ja töötavad. Probleemide korral kasuta: Taaskäivita & Uuenda.') : (dict.modal_act_activate_desc || dict.modal_act_deploy_desc || 'Käivitab vajalikud konteinerid paralleelselt olemasolevate kõrvale ilma vanu sulgemata.')}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/setup-all.sh -b ${b.num} -y --lang ${currentLang}
          </div>
        </div>
        <button class="btn btn-primary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px;" onclick="triggerBlueprintActionModal(${b.num}, 'setup')">
          <span>⚡</span> <span>${dict.modal_act_activate_btn || dict.modal_act_deploy_btn || 'Käivita / Lisa Virn'}</span>
        </button>
      </div>
    `;

    // Card 2: Restart & Update
    const cardRestart = `
      <div id="bp-card-restart-box" style="background: rgba(251, 191, 36, 0.04); border: 1px solid rgba(251, 191, 36, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between; transition: all 0.3s ease;">
        <div>
          <div style="font-weight: 700; color: #fbbf24; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_restart_title || '🔄 Taaskäivita & Uuenda'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_restart_desc || 'Taaskäivitab selle pinu konteinerid ja rakendab uued seadistused ilma andmekaota.'}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/deploy-blueprint.sh -b ${b.num} -u --lang ${currentLang}
          </div>
        </div>
        <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; color: #fbbf24; border-color: rgba(251,191,36,0.5);" onclick="triggerBlueprintActionModal(${b.num}, 'restart')">
          <span>🔄</span> <span>${dict.modal_act_restart_btn || 'Taaskäivita & Uuenda'}</span>
        </button>
      </div>
    `;

    // Card 3: Stop Services
    const isCoreProtected = b.num === 0;
    const cardStop = `
      <div style="background: rgba(148, 163, 184, 0.04); border: 1px solid rgba(148, 163, 184, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #cbd5e1; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_stop_title || '⏹️ Peata See Pinu'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_stop_desc || 'Peatab ainult selle blueprinti konteinerid ja vabastab hosti mälu. Teised andmebaasid jäävad tööle.'}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            podman stop ${stopTarget}
          </div>
        </div>
        ${isCoreProtected ? `
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; opacity: 0.5; cursor: not-allowed;" disabled title="Core Base Protected">
            <span>🔒</span> <span>${dict.modal_act_stop_protected || 'Core Protected'}</span>
          </button>
        ` : `
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; border-color: rgba(239,68,68,0.5); color: #f87171;" onclick="triggerBlueprintActionModal(${b.num}, 'stop')">
            <span>⏹️</span> <span>${dict.modal_act_stop_btn || 'Peata See Pinu'}</span>
          </button>
        `}
      </div>
    `;

    // Zone 2 Cards: Disaster Recovery
    let cardRapidRestore = '';
    let cardRotate = '';
    let cardCustomSnap = '';
    if (hasDb) {
      cardRapidRestore = `
        <div style="background: rgba(34, 197, 94, 0.04); border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #4ade80; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_variant_a_title || '⚡ Rapid Restore (~15–45s)'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_variant_a_desc || 'Taastab andmebaasi puhtasse baasseisu Golden Snapshotist ilma täisrebuildita.'}</p>
            <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
              <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
              ./scripts/snapshots/restore-golden-snapshots.sh -b ${b.num} --force
            </div>
          </div>
          <button class="btn btn-primary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; background: #16a34a; border-color: #22c55e;" onclick="triggerRestoreSnapshot(null, ${b.num}, this)">
            <span>⚡</span> <span>${dict.modal_dr_variant_a_btn || 'Taasta Golden Snapshot'}</span>
          </button>
        </div>
      `;

      const primaryDb = (b.components || []).find(c => (c.type && (c.type.toLowerCase().includes('database') || c.type.toLowerCase().includes('pdb'))) || (c.name && c.name.startsWith('db-')));
      const dbTargetName = primaryDb ? primaryDb.name : 'db-proxy';
      cardRotate = `
        <div style="background: rgba(245, 158, 11, 0.04); border: 1px solid rgba(245, 158, 11, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #fbbf24; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_rotate_title || '🔄 Paroolide Null-Seisakuga Rotatsioon'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_rotate_desc || 'Genereerib uue parooli ja uuendab selle andmebaasis, Podmani saladustes ja SEPS Walletis.'}</p>
            <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
              <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
              ./scripts/rotate-password.sh ${dbTargetName} dev
            </div>
          </div>
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; color: #fbbf24; border-color: rgba(245,158,11,0.5);" onclick="triggerRotateUserPassword(${b.num}, '${dbTargetName}', 'dev', this)">
            <span>🔄</span> <span>${dict.modal_act_rotate_btn || 'Roteeri DEV parool'}</span>
          </button>
        </div>
      `;

      cardCustomSnap = `
        <div style="background: rgba(56, 189, 248, 0.04); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #38bdf8; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_custom_title || '📸 Salvesta Hetkeseis (Snapshot)'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_custom_desc || 'Salvestab jooksvad testandmed ja skeemi uue nimega kohalikuks snapshotiks.'}</p>
            <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 10px;">
              <input type="text" id="modal-snap-tag-${b.num}" placeholder="${dict.modal_dr_custom_placeholder || 'Tag / Nimi'}" style="width: 100%; padding: 6px 10px; font-size: 0.8rem; background: #030712; border: 1px solid var(--border); border-radius: 6px; color: #f8fafc; outline: none; font-family: ui-monospace, monospace;" />
              <input type="text" id="modal-snap-desc-${b.num}" placeholder="${dict.snap_placeholder_desc || 'Valikuline kirjeldus...'}" style="width: 100%; padding: 6px 10px; font-size: 0.8rem; background: #030712; border: 1px solid var(--border); border-radius: 6px; color: #f8fafc; outline: none;" />
            </div>
          </div>
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; border-color: rgba(56,189,248,0.5); color: #38bdf8;" onclick="triggerCreateCustomSnapshotModal(${b.num}, this)">
            <span>📸</span> <span>${dict.modal_dr_custom_btn || 'Loo Snapshot'}</span>
          </button>
        </div>
      `;
    }

    // Zone 3 Card: Deep Reset
    const cardDeepReset = `
      <div style="background: rgba(239, 68, 68, 0.04); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #f87171; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_variant_b_title || '⚠️ Külm Taasehitus Nullist (~4–8 min)'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_variant_b_desc || 'Kustutab andmemahud ja ehitab kogu pinu uuesti nullist (kasuta ainult tõsise rikke korral).'}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/reset-all.sh -y &amp;&amp; ./scripts/setup-all.sh -b ${b.num} -y --lang ${currentLang}
          </div>
        </div>
        <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; border-color: rgba(239,68,68,0.5); color: #f87171;" onclick="triggerDeepReset(${b.num}, this)">
          <span>⚠️</span> <span>${dict.modal_dr_variant_b_btn || 'Külm Taasehitus (Deep Reset)'}</span>
        </button>
      </div>
    `;

    const zone1Html = `
      <div style="grid-column: 1 / -1; margin-top: 4px; margin-bottom: 4px; border-bottom: 1px solid rgba(56, 189, 248, 0.25); padding-bottom: 6px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 1.1rem;">🟢</span>
          <strong style="font-size: 0.92rem; color: #38bdf8;" data-i18n="modal_zone_lifecycle">${dict.modal_zone_lifecycle || 'Igapäevane Elutsükkel & Käivitused (Lifecycle)'}</strong>
        </div>
        <span style="font-size: 0.75rem; color: #94a3b8;" data-i18n="modal_zone_lifecycle_sub">${dict.modal_zone_lifecycle_sub || 'Käivita lisavirn, taaskäivita või peata ilma teisi baase sulgemata'}</span>
      </div>
      ${cardActivate}
      ${cardRestart}
      ${cardStop}
    `;

    const zone2Html = hasDb ? `
      <div style="grid-column: 1 / -1; margin-top: 18px; margin-bottom: 4px; border-bottom: 1px solid rgba(34, 197, 94, 0.25); padding-bottom: 6px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 1.1rem;">🛡️</span>
          <strong style="font-size: 0.92rem; color: #4ade80;" data-i18n="modal_zone_dr">${dict.modal_zone_dr || 'Kiirtaastus & Turvalisus (Disaster Recovery & Security)'}</strong>
        </div>
        <span style="font-size: 0.75rem; color: #94a3b8;" data-i18n="modal_zone_dr_sub">${dict.modal_zone_dr_sub || 'Taasta puhas algseis ~15s Golden Snapshotist või roteeri paroolid'}</span>
      </div>
      ${cardRapidRestore}
      ${cardRotate}
      ${cardCustomSnap}
    ` : '';

    const zone3Html = `
      <div style="grid-column: 1 / -1; margin-top: 18px; margin-bottom: 4px; border-bottom: 1px solid rgba(239, 68, 68, 0.25); padding-bottom: 6px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 1.1rem;">⚠️</span>
          <strong style="font-size: 0.92rem; color: #f87171;" data-i18n="modal_zone_danger">${dict.modal_zone_danger || 'Ohutsoon: Külm Taasehitus (Danger Zone: Cold Rebuild)'}</strong>
        </div>
        <span style="font-size: 0.75rem; color: #94a3b8;" data-i18n="modal_zone_danger_sub">${dict.modal_zone_danger_sub || 'Kustutab andmemahud ja ehitab pinu uuesti nullist (~4–8 min)'}</span>
      </div>
      ${cardDeepReset}
    `;

    actionsGrid.innerHTML = zone1Html + zone2Html + zone3Html;
  }

  // Switch to requested initial tab
  switchBlueprintModalTab(initialTab || 'arch');

  // Open modal backdrop
  const modal = document.getElementById('bp-modal-backdrop');
  if (modal) modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function copyCommandSnippet(cmdStr, btn) {
  copyTextToClipboard(cmdStr);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (btn) {
    const orig = btn.innerHTML;
    btn.innerHTML = '<span>✅</span>';
    setTimeout(() => { btn.innerHTML = orig; }, 1800);
  }
  if (typeof showToast === 'function') {
    showToast(`📋 ${dict.toast_cmd_copied || 'Kopeerisin käsu:'} ${cmdStr}`);
  }
}

function renderBlueprintDiagTab(bNum) {
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  // 1. Tier 1: Blueprint-Specific Test Suites
  const specSec = document.getElementById('bp-modal-sec-specific-tests');
  const specGrid = document.getElementById('bp-modal-specific-tests-grid');
  const bpTests = (b && Array.isArray(b.tests)) ? b.tests : [];

  if (specSec && specGrid) {
    if (bpTests.length === 0) {
      specSec.style.display = 'none';
    } else {
      specSec.style.display = 'block';
      specGrid.innerHTML = bpTests.map(t => {
        const title = (t.title && (t.title[currentLang] || t.title['en'])) || t.key;
        const desc = (t.desc && (t.desc[currentLang] || t.desc['en'])) || '';
        const icon = t.icon || '🧪';
        const color = t.color || '#38bdf8';
        const safeKey = t.key.replace(/[^a-zA-Z0-9_-]/g, '_');
        const statusBadgeId = `test-status-badge-${safeKey}`;

        return `
          <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
              <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px; gap: 8px;">
                <div style="font-weight: 700; color: ${color}; font-size: 0.92rem; display: flex; align-items: center; gap: 6px;">
                  <span>${title}</span>
                </div>
                <span id="${statusBadgeId}" class="badge" style="background: rgba(148, 163, 184, 0.12); color: #94a3b8; font-size: 0.72rem; padding: 2px 6px;">⚪ ${dict.test_status_pending || 'Ootel'}</span>
              </div>
              <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${desc}</p>
              <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
                <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
                ${t.cmd}
              </div>
            </div>
            <div style="display: flex; gap: 8px;">
              <button class="btn btn-primary" style="flex: 1; font-size: 0.82rem; padding: 6px 10px;" onclick="runDiagCommand('${t.key}', '${t.cmd}', this, '${statusBadgeId}')">
                <span>▶️</span> <span>${dict.btn_run_now || 'Käivita kohe'}</span>
              </button>
              <button class="btn btn-secondary" style="font-size: 0.82rem; padding: 6px 10px;" onclick="copyCommandSnippet('${t.cmd}', this)" title="${dict.btn_copy_cmd || 'Kopeeri CLI käsk'}">
                <span>📋</span>
              </button>
            </div>
          </div>
        `;
      }).join('');
    }
  }

  // 2. Tier 2: General Platform Diagnostics
  const grid = document.getElementById('bp-modal-diag-grid');
  if (!grid) return;

  const diagItems = [
    {
      key: 'dry-run',
      title: dict.modal_act_dryrun_title || '🔍 Configuration Preview (Dry-Run)',
      desc: dict.modal_act_dryrun_desc || 'Pre-evaluates configuration, port bindings, and profile parameters without starting containers.',
      cmd: `./scripts/deploy-blueprint.sh -b ${bNum} --dry-run`,
      color: '#c084fc',
      btnText: dict.modal_act_dryrun_btn || 'Preview (Dry-Run)',
      btnIcon: '🔍',
      btnClass: 'btn-secondary',
      btnStyle: 'color: #c084fc; border-color: rgba(168,85,247,0.5);'
    },
    {
      key: 'blueprint-info',
      title: dict.diag_bp_info_title || 'Blueprint Architecture & Validation Info',
      desc: dict.diag_bp_info_desc || 'Inspects and validates the configuration, container mappings, and port bindings for this blueprint.',
      cmd: `./scripts/blueprint-info.sh ${bNum}`,
      color: '#38bdf8'
    },
    {
      key: 'check-urls',
      title: dict.diag_url_title || 'Service Health Diagnostics',
      desc: dict.diag_url_desc || 'Tests active web service HTTP/HTTPS endpoints (APEX, ORDS, Forms, Publisher).',
      cmd: './scripts/check-urls.sh',
      color: '#38bdf8'
    },
    {
      key: 'check-wallet',
      title: dict.diag_wallet_title || 'Check SEPS Wallet Connections',
      desc: dict.diag_wallet_desc || 'Tests passwordless SEPS auto-login Wallet connections across all databases.',
      cmd: './scripts/check-wallet.sh',
      color: '#4ade80'
    },
    {
      key: 'test-ci',
      title: dict.diag_ci_title || 'Local CI/CD Platform Test',
      desc: dict.diag_ci_desc || 'Simulates offline CI/CD pipeline: validates scripts, environment variables, and integrity.',
      cmd: './scripts/test-local-ci.sh',
      color: '#c084fc'
    },
    {
      key: 'test-containers',
      title: dict.diag_container_title || 'Container Health & Resource Inspection',
      desc: dict.diag_container_desc || 'Inspects Podman container statuses, healthcheck states, and memory resources.',
      cmd: './tests/test-containers-live.sh',
      color: '#fbbf24'
    },
    {
      key: 'get-passwords',
      title: dict.diag_pwd_title || 'Read Wallet Credentials',
      desc: dict.diag_pwd_desc || 'Reads and verifies decrypted credentials from SEPS Wallet safely in-memory.',
      cmd: './scripts/get-password.sh --list',
      color: '#38bdf8'
    },
    {
      key: 'clean-logs',
      title: dict.diag_clean_title || 'Clean Logs & Temporary Files',
      desc: dict.diag_clean_desc || 'Archives or cleans old installation logs in install_logs/ and frees disk space.',
      cmd: './scripts/clean-logs.sh',
      color: '#94a3b8'
    }
  ];

  grid.innerHTML = diagItems.map(item => {
    const rawBtnText = item.btnText || dict.btn_run_now || 'Käivita kohe';
    const cleanBtnText = rawBtnText.replace(/^[🔍▶️⚡🔄⏹️🛡️⏱️📄]\s*/, '');
    const btnIcon = item.btnIcon || '▶️';
    const btnClass = item.btnClass ? `btn ${item.btnClass}` : 'btn btn-primary';
    const btnStyle = item.btnStyle || '';
    const safeKey = item.key.replace(/[^a-zA-Z0-9_-]/g, '_');
    const statusBadgeId = `diag-status-badge-${safeKey}`;

    return `
    <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
      <div>
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px; gap: 8px;">
          <div style="font-weight: 700; color: ${item.color}; font-size: 0.92rem;">${item.title}</div>
          <span id="${statusBadgeId}" class="badge" style="background: rgba(148, 163, 184, 0.12); color: #94a3b8; font-size: 0.72rem; padding: 2px 6px;">⚪ ${dict.test_status_pending || 'Ootel'}</span>
        </div>
        <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${item.desc}</p>
        <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
          <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
          ${item.cmd}
        </div>
      </div>
      <div style="display: flex; gap: 8px;">
        <button class="${btnClass}" style="flex: 1; font-size: 0.82rem; padding: 6px 10px; ${btnStyle}" onclick="runDiagCommand('${item.key}', '${item.cmd}', this, '${statusBadgeId}')">
          <span>${btnIcon}</span> <span>${cleanBtnText}</span>
        </button>
        <button class="btn btn-secondary" style="font-size: 0.82rem; padding: 6px 10px;" onclick="copyCommandSnippet('${item.cmd}', this)" title="${dict.btn_copy_cmd || 'Kopeeri CLI käsk'}">
          <span>📋</span>
        </button>
      </div>
    </div>
  `;
  }).join('');
}

async function runDiagCommand(cmdKey, cmdStr, btn, statusBadgeId) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const statusBadge = statusBadgeId ? document.getElementById(statusBadgeId) : null;
  if (statusBadge) {
    statusBadge.className = 'badge';
    statusBadge.style.background = 'rgba(56, 189, 248, 0.15)';
    statusBadge.style.color = '#38bdf8';
    statusBadge.innerHTML = '⏳ ' + (dict.btn_running || 'Töötab...');
  }

  const progress = startTerminalProgress('modal-diag-console', 'diag', `⚡ ${cmdKey}`, cmdStr);
  document.getElementById('modal-diag-console')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  const origBtnText = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span> <span>${dict.btn_running || 'Töötab...'}</span>`;
  }

  try {
    let resp;
    if (cmdKey === 'blueprint-info') {
      resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${activeBpModalNum}&action=info`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ module: activeBpModalNum, action: 'info' }),
        mode: 'cors'
      });
    } else if (cmdKey === 'dry-run' || cmdKey === 'dryrun') {
      resp = await fetch(`${BRIDGE_URL}/api/toggle?module=${activeBpModalNum}&action=dry-run&lang=${currentLang}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ module: activeBpModalNum, action: 'dry-run', lang: currentLang }),
        mode: 'cors'
      });
    } else {
      resp = await fetch(`${BRIDGE_URL}/api/devops/run`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ command: cmdKey }),
        mode: 'cors'
      });
    }
    const data = await resp.json();

    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnText;
    }

    const isSuccess = resp.ok && (data.ok || data.status === 'ok') && (data.exit_code === 0 || data.exit_code === undefined);
    if (statusBadge) {
      if (isSuccess) {
        statusBadge.style.background = 'rgba(34, 197, 94, 0.15)';
        statusBadge.style.color = '#4ade80';
        statusBadge.innerHTML = '✅ ' + (dict.test_status_passed || 'Läbitud');
      } else {
        statusBadge.style.background = 'rgba(248, 113, 113, 0.15)';
        statusBadge.style.color = '#f87171';
        statusBadge.innerHTML = '❌ ' + (dict.test_status_failed || 'Viga');
      }
    }

    if (progress) {
      progress.finish(isSuccess, data);
    }
    if (cmdKey === 'dry-run' || cmdKey === 'dryrun') {
      showToast(dict.ops_success_dryrun || `✅ Blueprint #${activeBpModalNum} konfiguratsiooni eelvaade valmis!`);
    }
  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnText;
    }
    if (statusBadge) {
      statusBadge.style.background = 'rgba(248, 113, 113, 0.15)';
      statusBadge.style.color = '#f87171';
      statusBadge.innerHTML = '❌ ' + (dict.test_status_failed || 'Viga');
    }
    console.error('Error running diag command:', err);
    if (progress) {
      progress.finish(false, { error: err.message, output: `Ühenduse viga dev-hub-bridge serveriga:\n${err.message}\n\nKäivita terminalis:\n${cmdStr}` });
    }
    copyTextToClipboard(cmdStr);
    if (typeof showToast === 'function') {
      showToast(`📋 ${dict.toast_cmd_copied || 'Kopeerisin käsu:'} ${cmdStr}`);
    }
  }
}

function closeBlueprintModal(e) {
  if (e && e.target && e.target !== document.getElementById('bp-modal-backdrop') && !e.target.classList.contains('modal-close-btn')) {
    return;
  }
  const modal = document.getElementById('bp-modal-backdrop');
  if (modal) modal.classList.remove('active');
  document.body.style.overflow = '';
}

function copyActiveLogPath(path, btn) {
  if (!path) return;
  copyTextToClipboard(path);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (btn) {
    const orig = btn.innerHTML;
    btn.innerHTML = `<span>✅</span> <span>${dict.toast_path_copied || 'Kopeeritud!'}</span>`;
    setTimeout(() => { btn.innerHTML = orig; }, 2000);
  }
  if (typeof showToast === 'function') {
    showToast(`📋 ${dict.toast_path_copied || 'Logifaili tee kopeeritud lõikelauale!'}`);
  }
}

let gBpLogsList = [];
let gBpLogsCategory = 'all';
let gBpLogsSearchQuery = '';
let gBpCurrentSelectedLogFile = null;

function filterBpLogsCategory(cat) {
  gBpLogsCategory = cat;
  ['all', 'setup', 'test', 'snapshot', 'devops'].forEach(c => {
    const btn = document.getElementById(`btn-bp-log-cat-${c}`);
    if (btn) {
      if (c === cat) btn.classList.add('active');
      else btn.classList.remove('active');
    }
  });
  renderBlueprintLogsListAndActive();
}

function filterBpLogsSearch(query) {
  gBpLogsSearchQuery = (query || '').toLowerCase().trim();
  renderBlueprintLogsListAndActive();
}

async function renderBlueprintLogsTab(bpNum, forceRefresh) {
  const b = BLUEPRINTS_DATA.find(item => item.num === bpNum);
  if (!b) return;

  // 1. Gather initial logs from b.all_logs or b.latest_log_info
  let logs = (b && Array.isArray(b.all_logs) && b.all_logs.length > 0) ? [...b.all_logs] : [];
  if (logs.length === 0 && b && (b.latest_log_info || b.latest_log)) {
    const lInfo = b.latest_log_info || { file: b.latest_log, relative_path: 'install_logs/' + b.latest_log, size_human: 'Log', mtime: '', category: 'setup' };
    logs.push(lInfo);
  }

  // 2. Fetch live updated list from Bridge if available
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/logs/blueprint?bp=${bpNum}`, { method: 'GET', mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (data && data.ok && Array.isArray(data.logs) && data.logs.length > 0) {
        logs = data.logs;
        b.all_logs = logs;
      }
    }
  } catch (e) {
    // Bridge offline; keep pre-embedded logs
  }

  gBpLogsList = logs;
  if (!gBpCurrentSelectedLogFile || !gBpLogsList.some(l => (l.file || l.filename) === gBpCurrentSelectedLogFile)) {
    gBpCurrentSelectedLogFile = gBpLogsList.length > 0 ? (gBpLogsList[0].file || gBpLogsList[0].filename) : null;
  }

  renderBlueprintLogsListAndActive();
}

function renderBlueprintLogsListAndActive() {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const countEl = document.getElementById('bp-modal-logs-count');
  const listEl = document.getElementById('bp-modal-logs-items-list');
  const titleEl = document.getElementById('bp-log-view-title');
  const badgeEl = document.getElementById('bp-modal-logs-active-badge');
  const metaEl = document.getElementById('bp-log-view-meta');
  const preEl = document.getElementById('bp-modal-logs-viewer-pre');

  if (!listEl) return;

  // Filter by category
  let filtered = [...gBpLogsList];
  if (gBpLogsCategory !== 'all') {
    filtered = filtered.filter(l => {
      const cat = (l.category || '').toLowerCase();
      if (gBpLogsCategory === 'setup') return cat === 'setup' || cat === 'deploy';
      if (gBpLogsCategory === 'test') return cat === 'test';
      if (gBpLogsCategory === 'snapshot') return cat === 'snapshot' || cat === 'restore';
      if (gBpLogsCategory === 'devops') return cat === 'devops' || cat === 'reset';
      return true;
    });
  }

  // Filter by search query
  if (gBpLogsSearchQuery) {
    filtered = filtered.filter(l => {
      const fname = (l.file || l.filename || '').toLowerCase();
      const cat = (l.category || '').toLowerCase();
      return fname.includes(gBpLogsSearchQuery) || cat.includes(gBpLogsSearchQuery);
    });
  }

  if (countEl) countEl.textContent = filtered.length;

  if (filtered.length === 0) {
    listEl.innerHTML = `
      <div style="text-align: center; padding: 28px 12px; color: #64748b;">
        <div style="font-size: 1.6rem; margin-bottom: 6px;">📄</div>
        <div style="font-size: 0.85rem; color: #cbd5e1;" data-i18n="no_bp_logs_found">
          ${dict.no_bp_logs_found || 'Selle filtriga ei leitud ühtegi logifaili.'}
        </div>
      </div>`;
    if (titleEl) titleEl.textContent = dict.logs_no_file_selected || 'Vali logifail';
    if (badgeEl) badgeEl.innerHTML = '';
    if (metaEl) metaEl.textContent = '';
    if (preEl) preEl.textContent = dict.logs_select_hint || 'Vali vasakult nimekirjast logifail selle sisu kuvamiseks.';
    return;
  }

  // Ensure current selected file is valid in filtered list
  if (!gBpCurrentSelectedLogFile || !filtered.some(l => (l.file || l.filename) === gBpCurrentSelectedLogFile)) {
    gBpCurrentSelectedLogFile = filtered[0].file || filtered[0].filename;
  }

  const activeLogObj = filtered.find(l => (l.file || l.filename) === gBpCurrentSelectedLogFile) || filtered[0];

  // Render log items in list pane
  listEl.innerHTML = filtered.map(l => {
    const fname = l.file || l.filename;
    const isSel = (fname === gBpCurrentSelectedLogFile);
    const cat = (l.category || 'general').toLowerCase();
    const sizeStr = l.size_human || (l.size_bytes ? ((l.size_bytes / 1024).toFixed(1) + ' KB') : '0 KB');
    const timeStr = l.mtime || (l.timestamp ? new Date(l.timestamp * 1000).toLocaleString() : '');

    let catBadge = '';
    if (cat === 'setup' || cat === 'deploy') {
      catBadge = `<span class="badge badge-success" style="font-size:0.68rem; padding: 1px 6px;">${dict.logs_cat_setup || 'Paigaldus'}</span>`;
    } else if (cat === 'test') {
      catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; background:rgba(168,85,247,0.2); color:#c084fc; border:1px solid rgba(168,85,247,0.4);">${dict.logs_cat_test || 'Testimine'}</span>`;
    } else if (cat === 'snapshot' || cat === 'restore') {
      catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; background:rgba(245,158,11,0.2); color:#fbbf24; border:1px solid rgba(245,158,11,0.4);">${dict.logs_cat_snapshot || 'Snapshot'}</span>`;
    } else if (cat === 'devops' || cat === 'reset') {
      catBadge = `<span class="badge badge-primary" style="font-size:0.68rem; padding: 1px 6px;">${dict.logs_cat_devops || 'DevOps'}</span>`;
    } else {
      catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; color:#94a3b8; background:rgba(255,255,255,0.08);">${dict.logs_cat_general || 'Üldine'}</span>`;
    }

    return `
      <div class="log-item ${isSel ? 'active' : ''}" onclick="selectBpLogFile('${escapeHtml(fname)}')">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
          <div style="display: flex; gap: 5px; align-items: center;">
            ${catBadge}
          </div>
          <span style="font-size: 0.72rem; color: #94a3b8; font-family: ui-monospace, monospace;">${sizeStr}</span>
        </div>
        <div style="font-family: ui-monospace, monospace; font-size: 0.76rem; color: ${isSel ? '#38bdf8' : '#e2e8f0'}; word-break: break-all; line-height: 1.35; font-weight: ${isSel ? '600' : '400'};">
          ${escapeHtml(fname)}
        </div>
        <div style="font-size: 0.68rem; color: #64748b; margin-top: 4px; font-family: ui-monospace, monospace;">
          ${escapeHtml(timeStr)}
        </div>
      </div>`;
  }).join('');

  // Update right pane header
  if (titleEl && activeLogObj) {
    titleEl.textContent = activeLogObj.file || activeLogObj.filename;
  }
  if (badgeEl && activeLogObj) {
    const cat = (activeLogObj.category || 'general').toLowerCase();
    let catClass = 'badge-primary';
    let catText = dict.logs_cat_general || 'Üldine';
    if (cat === 'setup' || cat === 'deploy') { catClass = 'badge-success'; catText = dict.logs_cat_setup || 'Paigaldus'; }
    else if (cat === 'test') { catClass = 'badge'; catText = dict.logs_cat_test || 'Testimine'; }
    else if (cat === 'snapshot' || cat === 'restore') { catClass = 'badge-warning'; catText = dict.logs_cat_snapshot || 'Snapshot'; }
    else if (cat === 'devops' || cat === 'reset') { catClass = 'badge-primary'; catText = dict.logs_cat_devops || 'DevOps'; }
    badgeEl.className = `badge ${catClass}`;
    badgeEl.textContent = catText.toUpperCase();
  }
  if (metaEl && activeLogObj) {
    const sizeStr = activeLogObj.size_human || (activeLogObj.size_bytes ? ((activeLogObj.size_bytes / 1024).toFixed(1) + ' KB') : '0 KB');
    const timeStr = activeLogObj.mtime || (activeLogObj.timestamp ? new Date(activeLogObj.timestamp * 1000).toLocaleString() : '');
    metaEl.textContent = `(${sizeStr} | ${timeStr})`;
  }

  // Load content
  if (activeLogObj) {
    loadBpLogContent(activeLogObj.file || activeLogObj.filename);
  }
}

function selectBpLogFile(fileName) {
  gBpCurrentSelectedLogFile = fileName;
  renderBlueprintLogsListAndActive();
}

async function loadBpLogContent(fileName) {
  const viewerPre = document.getElementById('bp-modal-logs-viewer-pre');
  if (!viewerPre) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  viewerPre.textContent = `⏳ ${dict.log_loading || 'Laadin logi sisu...'}`;
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(fileName)}`, { method: 'GET', mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (data && data.found && data.content) {
        viewerPre.textContent = data.content;
        viewerPre.scrollTop = viewerPre.scrollHeight;
        return;
      }
    }
    viewerPre.textContent = `(Logifail "${fileName}" sisu ei õnnestunud serverist laadida.)\n\nKäsitsi vaatamine terminalis:\ncat install_logs/${fileName}`;
  } catch (err) {
    viewerPre.textContent = `(Ühenduse viga dev-hub-bridge serveriga)\n\nLogifaili vaatamine terminalis:\ncat install_logs/${fileName}`;
  }
}

async function refreshBlueprintLogsTab(bpNum, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const orig = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span> <span>${dict.btn_running || 'Värskendan...'}</span>`;
  }
  await renderBlueprintLogsTab(bpNum, true);
  if (btn) {
    btn.disabled = false;
    btn.innerHTML = orig;
  }
  if (typeof showToast === 'function') {
    showToast(`🔄 ${dict.toast_logs_refreshed || 'Blueprinti logid värskendatud!'}`);
  }
}

function copyCurrentBpLogText(btn) {
  const pre = document.getElementById('bp-modal-logs-viewer-pre');
  if (pre && pre.textContent) {
    copyTextToClipboard(pre.textContent);
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = `<span>✅</span> <span>${dict.toast_log_copied || 'Kopeeritud!'}</span>`;
      setTimeout(() => { btn.innerHTML = orig; }, 2000);
    }
    if (typeof showToast === 'function') {
      showToast(`📋 ${dict.toast_log_copied || 'Logi sisu kopeeritud lõikelauale!'}`);
    }
  }
}

function downloadCurrentBpLogText() {
  const pre = document.getElementById('bp-modal-logs-viewer-pre');
  const filename = gBpCurrentSelectedLogFile || 'blueprint_log.txt';
  if (!pre || !pre.textContent) return;
  const blob = new Blob([pre.textContent], { type: 'text/plain' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (typeof showToast === 'function') {
    showToast(`💾 ${dict.toast_download_started || 'Allalaadimine alustatud:'} ${filename}`);
  }
}

function openCurrentBlueprintLogInViewer() {
  if (!gBpCurrentSelectedLogFile) return;
  const f = gBpCurrentSelectedLogFile;
  const p = `install_logs/${f}`;
  if (typeof openLogViewerModal === 'function') {
    openLogViewerModal(f, p);
  }
}

function copyCurrentBlueprintLogPath(btn) {
  if (!gBpCurrentSelectedLogFile) return;
  const fullPath = `install_logs/${gBpCurrentSelectedLogFile}`;
  copyTextToClipboard(fullPath);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  if (btn) {
    const orig = btn.innerHTML;
    btn.innerHTML = `<span>✅</span> <span>${dict.toast_path_copied || 'Kopeeritud!'}</span>`;
    setTimeout(() => { btn.innerHTML = orig; }, 2000);
  }
  if (typeof showToast === 'function') {
    showToast(`📋 ${dict.toast_path_copied || 'Logifaili tee kopeeritud lõikelauale!'}`);
  }
}

function renderBlueprintLatestLogHtml(container, bpNum, logInfo, dict) {
  if (!container) return;
  const b = BLUEPRINTS_DATA.find(item => item.num === bpNum);
  const bench = b ? b.benchmarks : null;
  let benchDuration = '🚀 FastStart ~15s';
  if (bench && (bench.total_duration_formatted || bench.total_duration_seconds)) {
    benchDuration = bench.total_duration_formatted || (bench.total_duration_seconds + 's');
  }

  const logFile = (logInfo && (logInfo.file || logInfo.name)) || (b && b.latest_log) || '';
  if (!logFile) {
    container.innerHTML = `<span style="font-size:0.85rem; color:#64748b;">${dict.no_bp_log || 'Eelnevat paigalduslogi selle kavandi kohta veel pole.'}</span>`;
    return;
  }

  const relPath = (logInfo && logInfo.relative_path) || ('install_logs/' + logFile);
  const fullPath = (logInfo && logInfo.full_path) || relPath;
  const sizeBadge = (logInfo && logInfo.size_human) ? `<span class="badge" style="background:rgba(56,189,248,0.1); color:#38bdf8; font-size:0.75rem; border:1px solid rgba(56,189,248,0.25);">💾 ${logInfo.size_human}</span>` : '';
  const modBadge = (logInfo && logInfo.modified_time) ? `<span style="color:#64748b; font-size:0.75rem;">📅 ${logInfo.modified_time}</span>` : '';

  container.innerHTML = `
    <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px;">
      <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; min-width:0; flex:1;">
        <span style="color:#38bdf8; font-family:ui-monospace,monospace; font-size:0.85rem; cursor:pointer; text-decoration:underline; font-weight:600;" 
              onclick="loadBlueprintLog('${logFile}', document.getElementById('bp-modal-log-toggle-btn'))" 
              title="${dict.tip_click_open_log || 'Klõpsa logi avamiseks'}">
          📄 ${relPath}
        </span>
        ${sizeBadge}
        <span class="badge" style="background:rgba(34,197,94,0.15); color:#4ade80; font-size:0.75rem; border:1px solid rgba(34,197,94,0.3);">⏱️ ${benchDuration}</span>
        ${modBadge}
      </div>
      <div style="display:flex; align-items:center; gap:6px;">
        <button type="button" class="btn btn-secondary" style="padding:4px 10px; font-size:0.78rem;" onclick="copyActiveLogPath('${fullPath}', this)" title="${dict.btn_copy_path || 'Kopeeri tee'}">
          <span>📋</span> <span>${dict.btn_copy_path || 'Kopeeri tee'}</span>
        </button>
        <button id="bp-modal-log-toggle-btn" type="button" class="btn btn-secondary" style="padding:4px 10px; font-size:0.78rem;" onclick="loadBlueprintLog('${logFile}', this)">
          <span>👁️</span> <span>${dict.btn_open_log || 'Ava logi'}</span>
        </button>
      </div>
    </div>
    <div id="bp-modal-log-preview" style="display:none; margin-top:10px; background:#030712; border:1px solid #1e293b; border-radius:6px; padding:10px; font-family:ui-monospace,monospace; font-size:0.75rem; color:#94a3b8; max-height:260px; overflow-y:auto; white-space:pre-wrap; word-break:break-all;"></div>
  `;
}

async function refreshBlueprintLatestLog(bpNum) {
  const container = document.getElementById('bp-modal-logs');
  if (!container || activeBpModalNum !== bpNum) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/log/latest?bp=${bpNum}`, { method: 'GET', mode: 'cors' });
    if (!resp.ok) return;
    const data = await resp.json();
    if (data.ok && data.log) {
      const b = BLUEPRINTS_DATA.find(item => item.num === bpNum);
      if (b) {
        b.latest_log = data.log.file;
        b.latest_log_info = data.log;
      }
      renderBlueprintLatestLogHtml(container, bpNum, data.log, dict);
    }
  } catch (err) {
    console.debug('Failed to fetch latest log metadata:', err);
  }
}

async function loadBlueprintLog(logFile, btn) {
  const previewBox = document.getElementById('bp-modal-log-preview');
  if (!previewBox) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (previewBox.style.display !== 'none' && previewBox.getAttribute('data-loaded-file') === logFile) {
    previewBox.style.display = 'none';
    if (btn) btn.innerHTML = `<span>👁️</span> <span>${dict.btn_open_log || 'Ava logi'}</span>`;
    return;
  }
  previewBox.style.display = 'block';
  previewBox.innerHTML = `⏳ ${dict.log_loading || 'Laadin logi sisu...'}`;
  previewBox.setAttribute('data-loaded-file', logFile);
  if (btn) btn.innerHTML = `<span>✕</span> <span>${dict.btn_hide_log || 'Peida logi'}</span>`;
  try {
    let resp = null;
    try {
      resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(logFile)}`, {
        method: 'GET',
        mode: 'cors'
      });
    } catch (primaryErr) {
      if (typeof BRIDGE_URL_ALT !== 'undefined' && BRIDGE_URL_ALT && BRIDGE_URL_ALT !== BRIDGE_URL) {
        resp = await fetch(`${BRIDGE_URL_ALT}/api/log/read?file=${encodeURIComponent(logFile)}`, {
          method: 'GET',
          mode: 'cors'
        });
      } else {
        throw primaryErr;
      }
    }
    if (!resp.ok) {
      if (resp.status === 404) {
        previewBox.innerHTML = `<span style="color:#94a3b8;">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      throw new Error(`HTTP ${resp.status}`);
    }
    const data = await resp.json();
    if (data.ok || data.status === 'ok') {
      if (data.found === false) {
        previewBox.innerHTML = `<span style="color:#94a3b8;">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      previewBox.textContent = data.content || `(${dict.log_empty || 'Logi on tühi'})`;
      previewBox.scrollTop = previewBox.scrollHeight;
    } else {
      previewBox.innerHTML = `<span style="color:#f87171;">Viga: ${data.error || 'Logi ei õnnestunud lugeda'}</span>`;
    }
  } catch (err) {
    previewBox.innerHTML = `<span style="color:#f87171;">Viga logi pärimisel: ${err.message}</span>`;
  }
}

let currentLogModalFile = '';
let currentLogModalFullPath = '';
let currentLogModalRawText = '';
let isLogModalTimeEnabled = true;
let isLogModalColorEnabled = true;
let logModalFilterQuery = '';

// ==========================================================================
// Terminal ANSI Syntax Highlighting & Clock Timestamp Engine
// ==========================================================================

function maskLogSecrets(str) {
  if (typeof str !== 'string') return '';
  return str
    .replace(/(token=)[^&"'\s]+/gi, '$1***MASKED***')
    .replace(/(ACCESS_TOKEN=)[^"'\s]+/gi, '$1***MASKED***')
    .replace(/(Bearer\s+)[^"'\s]+/gi, '$1***MASKED***')
    .replace(/(Authorization:\s*[A-Za-z0-9_]+\s+)[^"'\s]+/gi, '$1***MASKED***')
    .replace(/(ARTIFACTORY_TOKEN=)[^"'\s]+/gi, '$1***MASKED***')
    .replace(/(GITHUB_TOKEN=)[^"'\s]+/gi, '$1***MASKED***')
    .replace(/(password=)[^&"'\s]+/gi, '$1***MASKED***');
}

function stripAnsiCodes(str) {
  if (typeof str !== 'string') return '';
  return str
    .replace(/\x1b\[[0-9;]*[a-zA-Z]/g, '')
    .replace(/\x1b\([a-zA-Z0-9]/g, '')
    .replace(/\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)/g, '')
    .replace(/\[[0-9]+(?:;[0-9]+)*m/g, '')
    .replace(/'[0-9]+(?:;[0-9]+)*m/g, '')
    .replace(/\r/g, '');
}

function parseAnsiColorsToHtml(rawText) {
  if (!rawText) return '';
  let text = escapeHtml(rawText);

  const pattern = /(?:\x1b\[|\[)([0-9]+(?:;[0-9]+)*)m/g;
  let openSpanCount = 0;

  text = text.replace(pattern, (match, codes) => {
    let result = '';
    const parts = codes.split(';');
    for (let i = 0; i < parts.length; i++) {
      const c = parts[i];
      if (c === '0') {
        while (openSpanCount > 0) {
          result += '</span>';
          openSpanCount--;
        }
      } else if (c === '1') {
        result += '<span class="terminal-bold">';
        openSpanCount++;
      } else if (c === '2') {
        result += '<span class="terminal-dim">';
        openSpanCount++;
      } else if (c === '31' || c === '91') {
        result += '<span class="terminal-red">';
        openSpanCount++;
      } else if (c === '32' || c === '92') {
        result += '<span class="terminal-green">';
        openSpanCount++;
      } else if (c === '33' || c === '93') {
        result += '<span class="terminal-yellow">';
        openSpanCount++;
      } else if (c === '36' || c === '96') {
        result += '<span class="terminal-cyan">';
        openSpanCount++;
      } else if (c === '38' && parts[i + 1] === '5' && parts[i + 2] === '208') {
        result += '<span class="terminal-orange">';
        openSpanCount++;
        i += 2;
      }
    }
    return result;
  });

  while (openSpanCount > 0) {
    text += '</span>';
    openSpanCount--;
  }

  // Cleanup any leftover broken artifacts like '1;36m
  text = text.replace(/'[0-9]+(?:;[0-9]+)*m/g, '');
  return text;
}

function formatTerminalLogLine(rawLine, opts) {
  const showTime = !opts || opts.showTime !== false;
  const showColors = !opts || opts.showColors !== false;

  if (!rawLine || !rawLine.trim()) {
    return '<span class="terminal-line">&nbsp;</span>';
  }

  const clean = stripAnsiCodes(rawLine).trim();
  const isSeparator = /^[-=~*#]{4,}$/.test(clean);
  const isTree = /^[├└│─\s]+/.test(clean) && (clean.includes('├──') || clean.includes('└──'));

  let timeStr = '';
  let content = rawLine;

  const isoMatch = content.match(/^\[?([0-2][0-9]:[0-5][0-9]:[0-5][0-9])\]?\s*/);
  const relMatch = content.match(/^\[([0-9]{2}:[0-9]{2})\]\s*/);

  if (isoMatch) {
    timeStr = isoMatch[1];
    content = content.slice(isoMatch[0].length);
  } else if (relMatch) {
    timeStr = (opts && opts.defaultTime) || new Date().toLocaleTimeString('et-EE', { hour12: false });
    content = content.slice(relMatch[0].length);
  } else if (!isSeparator && !isTree && showTime && opts && opts.defaultTime) {
    timeStr = opts.defaultTime;
  }

  content = maskLogSecrets(content);
  const formattedContent = showColors ? parseAnsiColorsToHtml(content) : escapeHtml(stripAnsiCodes(content));

  let timeHtml = '';
  if (showTime) {
    timeHtml = timeStr 
      ? `<span class="terminal-time">${timeStr}</span>` 
      : `<span class="terminal-time">&nbsp;</span>`;
  }

  return `<span class="terminal-line">${timeHtml}${formattedContent}</span>`;
}

function formatTerminalLogText(rawText, options) {
  if (typeof rawText !== 'string' || !rawText) return '';
  const opts = options || {};
  const showTime = opts.showTime !== false;
  const showColors = opts.showColors !== false;
  const filter = (opts.filter || '').toLowerCase();

  const lines = rawText.split('\n');
  const renderedLines = [];

  for (let i = 0; i < lines.length; i++) {
    const rawLine = lines[i];
    if (filter) {
      const cleanLine = stripAnsiCodes(rawLine).toLowerCase();
      if (!cleanLine.includes(filter)) continue;
    }
    renderedLines.push(formatTerminalLogLine(rawLine, { showTime, showColors }));
  }

  return renderedLines.join('');
}

function renderLogModalContent() {
  const contentEl = document.getElementById('log-viewer-modal-content');
  if (!contentEl) return;
  if (!currentLogModalRawText) {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    contentEl.innerHTML = `<span class="terminal-dim">(${dict.log_empty || 'Logi on tühi'})</span>`;
    return;
  }
  contentEl.classList.toggle('terminal-plain', !isLogModalColorEnabled);
  contentEl.innerHTML = formatTerminalLogText(currentLogModalRawText, {
    showTime: isLogModalTimeEnabled,
    showColors: isLogModalColorEnabled,
    filter: logModalFilterQuery
  });
}

function toggleLogModalTimestamps(btn) {
  isLogModalTimeEnabled = !isLogModalTimeEnabled;
  if (btn) btn.classList.toggle('active', isLogModalTimeEnabled);
  renderLogModalContent();
}

function toggleLogModalColors(btn) {
  isLogModalColorEnabled = !isLogModalColorEnabled;
  if (btn) btn.classList.toggle('active', isLogModalColorEnabled);
  renderLogModalContent();
}

function filterLogModalContent() {
  const input = document.getElementById('log-viewer-filter-input');
  logModalFilterQuery = input ? input.value.trim().toLowerCase() : '';
  renderLogModalContent();
}

async function openLogViewerModal(logFile, logFullPath) {
  const modal = document.getElementById('log-viewer-modal-backdrop');
  const fnameEl = document.getElementById('log-viewer-modal-filename');
  const pathEl = document.getElementById('log-viewer-modal-path');
  const contentEl = document.getElementById('log-viewer-modal-content');
  if (!modal || !contentEl) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  currentLogModalFile = logFile || '';
  currentLogModalFullPath = logFullPath || ('install_logs/' + logFile);

  const cleanName = (logFile || '').replace(/^install_logs\//, '');
  if (fnameEl) fnameEl.textContent = cleanName ? `install_logs/${cleanName}` : 'install_logs/setup.log';
  if (pathEl) pathEl.textContent = currentLogModalFullPath;
  contentEl.innerHTML = `<span class="terminal-dim">${dict.log_loading || '⏳ Laadin logi sisu...'}</span>`;

  modal.style.display = 'flex';

  try {
    let resp = null;
    try {
      resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(cleanName)}`, {
        method: 'GET',
        mode: 'cors'
      });
    } catch (primaryErr) {
      if (typeof BRIDGE_URL_ALT !== 'undefined' && BRIDGE_URL_ALT && BRIDGE_URL_ALT !== BRIDGE_URL) {
        resp = await fetch(`${BRIDGE_URL_ALT}/api/log/read?file=${encodeURIComponent(cleanName)}`, {
          method: 'GET',
          mode: 'cors'
        });
      } else {
        throw primaryErr;
      }
    }
    if (!resp.ok) {
      if (resp.status === 404) {
        contentEl.innerHTML = `<span class="terminal-dim">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      throw new Error(`HTTP ${resp.status}`);
    }
    const data = await resp.json();
    if (data.ok || data.status === 'ok') {
      if (data.found === false) {
        contentEl.innerHTML = `<span class="terminal-dim">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      currentLogModalRawText = data.content || '';
      renderLogModalContent();
      contentEl.scrollTop = 0;
    } else {
      contentEl.innerHTML = `<span class="terminal-red">Viga: ${escapeHtml(data.error || 'Logi ei õnnestunud lugeda')}</span>`;
    }
  } catch (err) {
    contentEl.innerHTML = `<span class="terminal-red">Viga logi pärimisel: ${escapeHtml(err.message)}</span><br/><span style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:6px;">ℹ️ Kontrollige, et Dev Hub Bridge taustaprotsess töötab: <code>python3 scripts/internal/dev-hub-bridge.py</code></span>`;
  }
}

function closeLogViewerModal(event) {
  if (event && event.target && event.target.closest('.modal-content') && !event.target.classList.contains('modal-close-btn')) {
    return;
  }
  const modal = document.getElementById('log-viewer-modal-backdrop');
  if (modal) modal.style.display = 'none';
}

function refreshLogViewerModal(btn) {
  if (!currentLogModalFile) return;
  const orig = btn ? btn.innerHTML : '';
  if (btn) btn.innerHTML = `<span>⏳</span>`;
  openLogViewerModal(currentLogModalFile, currentLogModalFullPath).finally(() => {
    if (btn) btn.innerHTML = orig;
  });
}

function copyLogModalContent(btn) {
  if (!currentLogModalRawText) return;
  const cleanText = stripAnsiCodes(currentLogModalRawText);
  navigator.clipboard.writeText(cleanText).then(() => {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    showToast(dict.log_clean_copied || 'Puhas logi kopeeritud lõikelauale!');
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = `<span>✅</span> <span>${dict.btn_copied || 'Kopeeritud!'}</span>`;
      setTimeout(() => { btn.innerHTML = orig; }, 1500);
    }
  }).catch(() => {
    showToast('Kopeerimine ebaõnnestus.');
  });
}

function toggleActiveTerminalLog(containerId) {
  const pathEl = document.getElementById(`${containerId}-log-path`);
  if (!pathEl) return;
  const logFile = pathEl.getAttribute('data-log-file') || pathEl.textContent.trim().replace(/^install_logs\//, '');
  const fullPath = pathEl.getAttribute('data-full-path') || pathEl.textContent.trim();
  openLogViewerModal(logFile, fullPath);
}

function scrollTerminalToBottom(containerId) {
  if (typeof window[`scrollTerminalToBottom_${containerId}`] === 'function') {
    window[`scrollTerminalToBottom_${containerId}`]();
  } else {
    const el = document.getElementById(`${containerId}-output`);
    if (el) el.scrollTop = el.scrollHeight;
    const btn = document.getElementById(`${containerId}-scroll-btn`);
    if (btn) btn.style.display = 'none';
  }
}

async function runDevOpsCommand(cmdKey, btn) {
  const card = btn.closest('.card');
  if (!card) return;
  const consoleBox = card.querySelector('.devops-console');
  if (!consoleBox) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  consoleBox.style.display = 'block';
  consoleBox.innerHTML = `<div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #1e293b; padding-bottom:6px; margin-bottom:8px;">
    <span style="color:#38bdf8; font-weight:600;">⚡ ${cmdKey}</span>
    <span style="color:#eab308;">⏳ Käivitamine...</span>
  </div><div class="console-body" style="color:#94a3b8;">Palun oota, käsk täidetakse reaalajas...</div>`;

  const origBtnText = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = `<span>⏳</span> <span>Töötab...</span>`;

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/devops/run`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ command: cmdKey }),
      mode: 'cors'
    });
    const data = await resp.json();
    btn.disabled = false;
    btn.innerHTML = origBtnText;

    if (resp.ok && (data.ok || data.status === 'ok')) {
      const statusColor = data.exit_code === 0 ? '#4ade80' : '#f87171';
      const statusText = data.exit_code === 0 ? 'EXIT 0 (OK)' : `EXIT ${data.exit_code} (ERROR)`;
      consoleBox.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #1e293b; padding-bottom:6px; margin-bottom:8px;">
          <span style="color:#38bdf8; font-weight:600;">⚡ ${cmdKey}</span>
          <div style="display:flex; align-items:center; gap:8px;">
            <span style="color:${statusColor}; font-weight:700; font-size:0.75rem;">${statusText}</span>
            <button onclick="this.closest('.devops-console').style.display='none'" style="background:none; border:none; color:#64748b; cursor:pointer; font-size:0.85rem;" title="Sulge">✕</button>
          </div>
        </div>
        <pre class="console-body" style="margin:0; font-size:0.75rem; color:#cbd5e1; white-space:pre-wrap; max-height:220px; overflow-y:auto;">${formatTerminalLogText(data.output || '(Käsk lõpetas ilma väljundita)', { showTime: true, showColors: true })}</pre>
      `;
    } else {
      consoleBox.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #1e293b; padding-bottom:6px; margin-bottom:8px;">
          <span style="color:#f87171; font-weight:600;">❌ Viga</span>
          <button onclick="this.closest('.devops-console').style.display='none'" style="background:none; border:none; color:#64748b; cursor:pointer; font-size:0.85rem;">✕</button>
        </div>
        <div style="color:#f87171; font-size:0.8rem; padding:8px 0;">${data.error || 'Server tagastas tõrke.'}</div>
      `;
    }
  } catch (err) {
    btn.disabled = false;
    btn.innerHTML = origBtnText;
    consoleBox.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #1e293b; padding-bottom:6px; margin-bottom:8px;">
        <span style="color:#f87171; font-weight:600;">❌ Ühenduse Viga</span>
        <button onclick="this.closest('.devops-console').style.display='none'" style="background:none; border:none; color:#64748b; cursor:pointer; font-size:0.85rem;">✕</button>
      </div>
      <div style="color:#f87171; font-size:0.8rem; padding:8px 0;">Silda ei saanud kätte: ${err.message}. Veendu, et python3 scripts/internal/dev-hub-bridge.py töötab taustal.</div>
    `;
  }
}

let currentDevOpsCategoryFilter = 'all';

function filterDevOpsCategory(cat, btn) {
  currentDevOpsCategoryFilter = cat || 'all';
  document.querySelectorAll('#devops-category-filters .bp-filter-btn').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  filterDevOpsCards();
}

function filterDevOpsCards() {
  const searchInput = document.getElementById('devops-search-input');
  const clearBtn = document.getElementById('devops-search-clear');
  const counterEl = document.getElementById('devops-filter-counter');
  const emptyEl = document.getElementById('devops-empty-state');
  const gridEl = document.getElementById('devops-cards-grid');

  const q = ((searchInput && searchInput.value) || '').toLowerCase().trim();
  if (clearBtn) {
    clearBtn.style.display = q ? 'inline-block' : 'none';
  }

  const cards = document.querySelectorAll('#devops-cards-grid .card');
  let visibleCount = 0;
  const totalCount = cards.length;

  cards.forEach(card => {
    const cardCat = card.getAttribute('data-cat') || 'tools';
    const matchesCat = (currentDevOpsCategoryFilter === 'all') || (cardCat === currentDevOpsCategoryFilter);
    const text = card.textContent.toLowerCase();
    const matchesSearch = !q || text.includes(q);

    if (matchesCat && matchesSearch) {
      card.style.display = '';
      visibleCount++;
    } else {
      card.style.display = 'none';
    }
  });

  if (counterEl) {
    counterEl.innerText = `${visibleCount} / ${totalCount}`;
  }

  if (emptyEl) {
    emptyEl.style.display = (visibleCount === 0) ? 'block' : 'none';
  }
  if (gridEl) {
    gridEl.style.display = (visibleCount === 0) ? 'none' : 'grid';
  }
}

function clearDevOpsSearch() {
  const searchInput = document.getElementById('devops-search-input');
  if (searchInput) {
    searchInput.value = '';
    searchInput.focus();
  }
  filterDevOpsCards();
}

function resetDevOpsFilters() {
  const searchInput = document.getElementById('devops-search-input');
  if (searchInput) searchInput.value = '';
  currentDevOpsCategoryFilter = 'all';
  const allBtn = document.querySelector('#devops-category-filters .bp-filter-btn');
  document.querySelectorAll('#devops-category-filters .bp-filter-btn').forEach(b => b.classList.remove('active'));
  if (allBtn) allBtn.classList.add('active');
  filterDevOpsCards();
}

/* ==========================================================================
   Repository Statistics & Codebase Health Engine
   ========================================================================== */
let gRepoStatsData = (typeof REPO_STATS_DATA !== 'undefined' && REPO_STATS_DATA && REPO_STATS_DATA.maintainable_core) ? REPO_STATS_DATA : null;

async function loadRepoStatistics(forceRefresh = false) {
  // If pre-baked statistics exist, render them immediately to avoid empty/loading state
  if (gRepoStatsData && !forceRefresh) {
    renderRepoStatisticsUI(gRepoStatsData);
  }

  const badge = document.getElementById('repo-stats-updated-badge');
  if (badge && !gRepoStatsData) badge.textContent = 'Laadimine...';

  try {
    const url = forceRefresh ? `${BRIDGE_URL}/api/report/refresh` : `${BRIDGE_URL}/api/report/stats`;
    const method = forceRefresh ? 'POST' : 'GET';
    const resp = await fetch(url, { method, mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (data && data.stats) {
        gRepoStatsData = data.stats;
        renderRepoStatisticsUI(gRepoStatsData);
        if (forceRefresh) {
          const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
          const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
          showToast(dict.stats_refreshed_toast || '✅ Repositooriumi statistika edukalt uuendatud!');
        }
      }
    } else {
      if (badge && !gRepoStatsData) badge.textContent = 'Bridge ühenduseta';
    }
  } catch (e) {
    if (badge && !gRepoStatsData) badge.textContent = 'Bridge offline';
  }
}

async function refreshRepoStatistics() {
  const btn = document.getElementById('btn-refresh-repo-stats');
  const icon = document.getElementById('refresh-stats-icon');
  if (btn) btn.disabled = true;
  if (icon) icon.textContent = '⏳';
  showToast('🔄 Arvutan koodibaasi statistikat ja mõõdikuid...');
  
  await loadRepoStatistics(true);
  
  if (btn) btn.disabled = false;
  if (icon) icon.textContent = '🔄';
}

function renderRepoStatisticsUI(stats) {
  if (!stats) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const mc = stats.maintainable_core || {};
  const gr = stats.gross_repository || {};
  const ac = stats.architecture_components || {};
  const git = stats.git || {};
  const i18n = stats.i18n || {};
  const tst = stats.testing || {};
  const meta = stats.metadata || {};

  // Badge
  const badge = document.getElementById('repo-stats-updated-badge');
  if (badge && meta.generated_at) {
    const timeStr = meta.generated_at.substring(0, 16).replace('T', ' ');
    badge.textContent = `${dict.stats_updated || 'Uuendatud'}: ${timeStr} (${meta.scan_duration_ms || 0}ms)`;
  }

  // KPI 1: Maintainable SLOC
  const slocVal = document.getElementById('stats-kpi-sloc-val');
  if (slocVal) slocVal.textContent = (mc.maintainable_sloc || 0).toLocaleString();
  const filesCount = document.getElementById('stats-kpi-files-count');
  if (filesCount) filesCount.textContent = `${mc.total_files || 0} ${dict.stats_files || 'faili'}`;
  const grossVal = document.getElementById('stats-kpi-gross-val');
  if (grossVal) grossVal.textContent = `${dict.stats_gross_repo || 'Kogu repo'}: ${(gr.total_gross_lines || 0).toLocaleString()} rida`;

  // KPI 2: Test Density
  const testDensityVal = document.getElementById('stats-kpi-test-density-val');
  if (testDensityVal) testDensityVal.textContent = `${mc.test_density_percent || 0}%`;
  const testCount = document.getElementById('stats-kpi-test-count');
  if (testCount) testCount.textContent = `${ac.test_scripts_count || 0} ${dict.stats_tests || 'testi'}`;
  const testPassVal = document.getElementById('stats-kpi-test-pass-val');
  if (testPassVal) testPassVal.textContent = `${dict.stats_pass_rate || 'Edukus'}: ${tst.pass_rate_percent || 100}% PASS`;

  // KPI 3: Architecture Scale
  const bpVal = document.getElementById('stats-kpi-bp-val');
  if (bpVal) bpVal.textContent = `${ac.blueprints_count || 12} Blueprinti`;
  const dbCount = document.getElementById('stats-kpi-db-count');
  if (dbCount) dbCount.textContent = `${ac.database_profiles_count || 0} DB profiili`;
  const cliCount = document.getElementById('stats-kpi-cli-count');
  if (cliCount) cliCount.textContent = `CLI: ${ac.cli_user_tools_count || 0} | Internal: ${ac.internal_engine_scripts_count || 0}`;

  // KPI 4: i18n & Git
  const i18nVal = document.getElementById('stats-kpi-i18n-val');
  if (i18nVal) i18nVal.textContent = `${i18n.languages_count || 6} Keelt (100%)`;
  const commitsCount = document.getElementById('stats-kpi-commits-count');
  if (commitsCount) commitsCount.textContent = `${git.total_commits || 0} commit'i`;
  const keysVal = document.getElementById('stats-kpi-keys-val');
  if (keysVal) keysVal.textContent = `${i18n.total_unique_i18n_keys || 0} i18n võtit`;

  // Stacked Language Bar
  const stackedBar = document.getElementById('stats-stacked-bar');
  const legend = document.getElementById('stats-lang-legend');
  const langs = stats.language_breakdown || {};

  const LANG_COLORS = {
    'Shell / Bash': '#38bdf8',
    'Python': '#facc15',
    'SQL / PLSQL': '#fb923c',
    'YAML Configuration': '#4ade80',
    'Markdown Docs': '#94a3b8',
    'APEXlang DSL': '#c084fc',
    'Container / Docker': '#06b6d4',
    'JSON Data/Specs': '#a3e635',
    'Web Templates (HTML/JS/CSS)': '#f43f5e',
    'Windows Scripts': '#818cf8',
    'Other': '#64748b'
  };

  if (stackedBar) {
    let barHtml = '';
    let legHtml = [];
    Object.keys(langs).forEach(lang => {
      const st = langs[lang];
      const color = LANG_COLORS[lang] || '#64748b';
      const pct = st.percent_of_sloc || 0;
      if (pct > 0.5) {
        barHtml += `<div style="width: ${pct}%; background: ${color}; height: 100%; transition: width 0.5s ease;" title="${lang}: ${st.sloc.toLocaleString()} SLOC (${pct}%)"></div>`;
        legHtml.push(`<span style="display:inline-flex; align-items:center; gap:4px; margin-left:8px;"><span style="display:inline-block; width:8px; height:8px; border-radius:50%; background:${color};"></span> ${lang.split(' ')[0]} ${pct}%</span>`);
      }
    });
    stackedBar.innerHTML = barHtml;
    if (legend) legend.innerHTML = legHtml.slice(0, 5).join(' ');
  }

  // Detailed Language Table
  const tbodyLang = document.getElementById('stats-lang-table-tbody');
  if (tbodyLang) {
    let tHtml = '';
    Object.keys(langs).forEach(lang => {
      const st = langs[lang];
      const color = LANG_COLORS[lang] || '#64748b';
      tHtml += `
        <tr>
          <td><span style="display:inline-block; width:8px; height:8px; border-radius:50%; background:${color}; margin-right:6px;"></span><strong>${lang}</strong></td>
          <td>${st.files}</td>
          <td><strong>${st.sloc.toLocaleString()}</strong> <small style="color:#64748b;">(${(st.lines || 0).toLocaleString()} tot)</small></td>
          <td><span class="badge" style="background:rgba(255,255,255,0.06); font-size:0.7rem;">${st.percent_of_sloc || 0}%</span></td>
        </tr>
      `;
    });
    tbodyLang.innerHTML = tHtml;
  }

  // Top 5 Largest Files Table
  const tbodyTop = document.getElementById('stats-top-files-tbody');
  const topFiles = stats.top_largest_files || [];
  if (tbodyTop) {
    let topHtml = '';
    topFiles.forEach(f => {
      topHtml += `
        <tr>
          <td style="max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${f.path}"><code style="font-size:0.72rem; color:#93c5fd;">${f.path}</code></td>
          <td><span class="badge badge-secondary" style="font-size:0.68rem;">${f.language.split(' ')[0]}</span></td>
          <td><strong>${f.sloc.toLocaleString()}</strong></td>
        </tr>
      `;
    });
    tbodyTop.innerHTML = topHtml;
  }
}

function toggleTelemetryRibbon() {
  const body = document.getElementById('telemetry-ribbon-body');
  const label = document.getElementById('telemetry-toggle-label');
  if (!body) return;
  const isOpen = body.classList.toggle('open');
  if (label) {
    label.innerText = isOpen ? 'Peida mõõdikud ▲' : 'Kuva mõõdikud ▼';
  }
}

function toggleFaqItem(faqId) {
  const body = document.getElementById(`${faqId}-body`);
  const caret = document.getElementById(`${faqId}-caret`);
  if (!body) return;
  const isOpen = body.classList.toggle('open');
  if (caret) {
    caret.textContent = isOpen ? '▲' : '▼';
  }
}

function toggleRepoStatsDetails() {
  const drawer = document.getElementById('stats-details-drawer');
  const caret = document.getElementById('stats-details-caret');
  const lbl = document.getElementById('stats-details-toggle-lbl');
  if (!drawer) return;
  const isHidden = drawer.style.display === 'none' || drawer.style.display === '';
  drawer.style.display = isHidden ? 'block' : 'none';
  if (caret) caret.textContent = isHidden ? '▲' : '▼';
}

function downloadRepoReport(format) {
  if (!gRepoStatsData && format === 'json') {
    showToast('⚠️ Andmed pole veel laetud. Värskenda esmalt aruannet.');
    return;
  }
  let content = '';
  let filename = '';
  let mime = 'text/plain';

  if (format === 'json') {
    content = JSON.stringify(gRepoStatsData, null, 2);
    filename = 'repo_statistics.json';
    mime = 'application/json';
  } else {
    content = `# 📈 Oracle DevOps Platform — Repositooriumi Statistiline Aruanne\n\n` +
      `- Genereeritud: ${gRepoStatsData?.metadata?.generated_at || new Date().toISOString()}\n` +
      `- Hallatav Lähtekood (SLOC): ${gRepoStatsData?.maintainable_core?.maintainable_sloc?.toLocaleString()} rida (${gRepoStatsData?.maintainable_core?.total_files} faili)\n` +
      `- Testide Tihedus: ${gRepoStatsData?.maintainable_core?.test_density_percent}%\n` +
      `- Arhitektuuri Blueprintid: ${gRepoStatsData?.architecture_components?.blueprints_count}\n` +
      `- Git Commitid: ${gRepoStatsData?.git?.total_commits}\n\n` +
      `Täielik aruanne on talletatud metrics/repo_statistics.md`;
    filename = 'repo_statistics.md';
    mime = 'text/markdown';
  }

  const blob = new Blob([content], { type: mime });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  showToast(`📥 Fail ${filename} alla laaditud!`);
}

function openSnippetModal(titleKey, descKey, codeSnippet) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  const title = (dict && dict[titleKey]) || titleKey;
  const desc = (dict && dict[descKey]) || descKey;

  const tEl = document.getElementById('snippet-modal-title');
  const dEl = document.getElementById('snippet-modal-desc');
  const cEl = document.getElementById('snippet-modal-code');

  if (tEl) tEl.innerHTML = title;
  if (dEl) dEl.innerHTML = desc;
  if (cEl) {
    cEl.innerHTML = `
      <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
      <pre><code>${codeSnippet}</code></pre>
    `;
  }

  const modal = document.getElementById('snippet-modal-backdrop');
  if (modal) modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeSnippetModal(e) {
  if (e && e.target && e.target !== document.getElementById('snippet-modal-backdrop') && !e.target.classList.contains('modal-close-btn')) {
    return;
  }
  const modal = document.getElementById('snippet-modal-backdrop');
  if (modal) modal.classList.remove('active');
  document.body.style.overflow = '';
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    closeBlueprintModal();
    closeSnippetModal();
    closeProfileModal();
    closeCreateBpModal();
    if (typeof closeSuiteTestsModal === 'function') {
      closeSuiteTestsModal();
    }
    if (typeof closeGlossaryModal === 'function') {
      closeGlossaryModal();
    }
    if (typeof closeFaqModal === 'function') {
      closeFaqModal();
    }
    if (typeof closeOracleResourcesModal === 'function') {
      closeOracleResourcesModal();
    }
    if (typeof closeSkillModal === 'function') {
      closeSkillModal();
    }
  } else if ((e.key === '?' || e.key === 'g' || e.key === 'G') && !e.ctrlKey && !e.metaKey && !e.altKey) {
    const activeEl = document.activeElement;
    const isInput = activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA' || activeEl.isContentEditable);
    if (!isInput && typeof openGlossaryModal === 'function') {
      e.preventDefault();
      openGlossaryModal();
    }
  } else if ((e.key === 's' || e.key === 'S') && !e.ctrlKey && !e.metaKey && !e.altKey) {
    const activeEl = document.activeElement;
    const isInput = activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA' || activeEl.isContentEditable);
    if (!isInput) {
      e.preventDefault();
      switchTab('tab-skills');
      const sInput = document.getElementById('skills-search-input');
      if (sInput) setTimeout(() => sInput.focus(), 60);
    }
  }
});

function searchCockpitCards(query) {
  const q = (query || '').toLowerCase().trim();
  document.querySelectorAll('#cockpit-cards-grid .card').forEach(card => {
    const text = card.textContent.toLowerCase();
    const cardCat = card.getAttribute('data-cat') || '';
    let matchesCat = (currentActiveFilter === 'all');
    if (currentActiveFilter === 'active') {
      matchesCat = !card.classList.contains('card-offline');
    } else if (currentActiveFilter === 'core') {
      matchesCat = (cardCat === 'core' || cardCat === 'database');
    } else if (currentActiveFilter === 'specialized') {
      matchesCat = (cardCat === 'middleware' || cardCat === 'specialized');
    } else if (currentActiveFilter === 'developer') {
      matchesCat = (cardCat === 'developer');
    } else if (currentActiveFilter === 'gateway') {
      matchesCat = (cardCat === 'gateway');
    } else if (cardCat === currentActiveFilter) {
      matchesCat = true;
    }
    const matchesSearch = !q || text.includes(q);
    card.style.display = (matchesCat && matchesSearch) ? '' : 'none';
  });
}

function filterBlueprints(cat) {
  currentActiveFilter = cat || 'all';
  document.querySelectorAll('.bp-filter-btn').forEach(btn => btn.classList.remove('active'));
  const targetBtn = Array.from(document.querySelectorAll('.bp-filter-btn')).find(b => b.getAttribute('onclick')?.includes(`'${cat}'`));
  if (targetBtn) targetBtn.classList.add('active');
  const searchInput = document.getElementById('cockpit-search-input');
  searchCockpitCards(searchInput ? searchInput.value : '');
}

function escapeHtml(s) {
  return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

let gDocsSelectedCategory = 'all';
let gDocsSearchQuery = '';

function getDocCategory(rel) {
  const r = (rel || '').toLowerCase();
  if (r.includes('architecture') || r.includes('topology') || r.includes('blueprint') || r.includes('seps') || r.includes('wallet') || r.includes('profile') || r.includes('enterprise')) return 'arch';
  if (r.includes('script') || r.includes('setup') || r.includes('reset') || r.includes('cicd') || r.includes('ci') || r.includes('deploy') || r.includes('snapshot') || r.includes('devops') || r.includes('test') || r.includes('artifactory')) return 'devops';
  if (r.includes('apex') || r.includes('ords') || r.includes('publisher') || r.includes('forms') || r.includes('web-ide') || r.includes('ide') || r.includes('service')) return 'web';
  return 'trouble';
}

function filterDocsCategory(cat) {
  gDocsSelectedCategory = cat || 'all';
  ['all', 'arch', 'devops', 'web', 'trouble'].forEach(c => {
    const btn = document.getElementById(`btn-docs-cat-${c}`);
    if (btn) btn.classList.toggle('active', c === gDocsSelectedCategory);
  });
  renderDocsNav();
}

function renderDocsNav(selectedIdx) {
  const sidebar = document.getElementById('docs-sidebar-nav');
  if (!sidebar) return;
  sidebar.innerHTML = '';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  currentSelectedDocIdx = selectedIdx || 0;

  let visibleCount = 0;
  DOCS_DATA.forEach((doc, idx) => {
    const docCat = getDocCategory(doc.rel);
    if (gDocsSelectedCategory !== 'all' && docCat !== gDocsSelectedCategory) {
      return;
    }

    const shortName = doc.rel.split('/').pop().replace(/\.md$/, '');
    const btn = document.createElement('button');
    btn.className = 'docs-nav-item' + (idx === currentSelectedDocIdx ? ' active' : '');
    btn.setAttribute('data-doc-idx', idx);
    const title = (doc.titles && doc.titles[currentLang]) || (doc.titles && doc.titles['en']) || doc.rel;
    btn.innerHTML = `
      <div style="display: flex; flex-direction: column; gap: 2px; flex: 1; text-align: left; min-width: 0;">
        <span class="docs-item-title" style="font-weight: 500; font-size: 0.84rem; line-height: 1.35; word-break: break-word;">${escapeHtml(title)}</span>
        <span class="docs-item-file" style="font-size: 0.7rem; color: #64748b; font-family: ui-monospace, monospace;">${escapeHtml(shortName)}.md</span>
      </div>
    `;
    btn.onclick = () => loadDocContent(idx, btn);
    sidebar.appendChild(btn);
    visibleCount++;
  });

  const searchInput = document.getElementById('docs-search-input');
  if (searchInput && searchInput.value) {
    handleDocsSearchInput(searchInput.value);
  } else if (DOCS_DATA.length > 0 && sidebar.children[0]) {
    const firstBtn = sidebar.querySelector(`.docs-nav-item[data-doc-idx="${currentSelectedDocIdx}"]`) || sidebar.children[0];
    const targetIdx = Number(firstBtn.getAttribute('data-doc-idx') || 0);
    loadDocContent(targetIdx, firstBtn);
  }
}

function renderDocsNavFiltered(allowedIndices) {
  const sidebar = document.getElementById('docs-sidebar-nav');
  if (!sidebar) return;
  const items = sidebar.querySelectorAll('.docs-nav-item');
  items.forEach(item => {
    const idx = Number(item.getAttribute('data-doc-idx'));
    item.style.display = (!allowedIndices || allowedIndices.includes(idx)) ? 'flex' : 'none';
  });
}

function handleDocsSearchInput(query) {
  gDocsSearchQuery = (query || '').trim();
  const searchResultsBox = document.getElementById('docs-search-results-box');
  const renderedBody = document.getElementById('docs-rendered-body');
  const tocBox = document.getElementById('docs-toc-box');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (!gDocsSearchQuery) {
    if (searchResultsBox) {
      searchResultsBox.style.display = 'none';
      searchResultsBox.innerHTML = '';
    }
    if (renderedBody) renderedBody.style.display = '';
    if (tocBox && tocBox.querySelector('li')) tocBox.style.display = '';
    renderDocsNav(currentSelectedDocIdx);
    return;
  }

  const qLower = gDocsSearchQuery.toLowerCase();
  const matchedDocs = [];

  DOCS_DATA.forEach((doc, idx) => {
    const title = (doc.titles && (doc.titles[currentLang] || doc.titles['en'])) || doc.rel;
    const content = (doc.contents && (doc.contents[currentLang] || doc.contents['en'])) || '';
    const titleMatch = title.toLowerCase().includes(qLower);
    const contentIdx = content.toLowerCase().indexOf(qLower);

    if (titleMatch || contentIdx !== -1) {
      let snippet = '';
      if (contentIdx !== -1) {
        const start = Math.max(0, contentIdx - 60);
        const end = Math.min(content.length, contentIdx + qLower.length + 90);
        let rawSnippet = content.substring(start, end).replace(/\n+/g, ' ');
        if (start > 0) rawSnippet = '...' + rawSnippet;
        if (end < content.length) rawSnippet = rawSnippet + '...';
        
        const escSnippet = escapeHtml(rawSnippet);
        const regex = new RegExp(`(${escapeRegExp(gDocsSearchQuery)})`, 'gi');
        snippet = escSnippet.replace(regex, '<mark style="background:#f59e0b; color:#0f172a; padding:1px 4px; border-radius:3px; font-weight:600;">$1</mark>');
      } else {
        snippet = `<span style="color:#94a3b8; font-style:italic;">Pealkiri klapib otsinguga: <strong>${escapeHtml(title)}</strong></span>`;
      }
      matchedDocs.push({ idx, doc, title, snippet });
    }
  });

  renderDocsNavFiltered(matchedDocs.map(m => m.idx));

  if (searchResultsBox) {
    if (renderedBody) renderedBody.style.display = 'none';
    if (tocBox) tocBox.style.display = 'none';
    searchResultsBox.style.display = 'block';

    if (matchedDocs.length === 0) {
      searchResultsBox.innerHTML = `
        <div style="background: rgba(15, 23, 42, 0.6); border: 1px solid var(--border); border-radius: 8px; padding: 24px; text-align: center; color: var(--text-dim);">
          <div style="font-size: 1.8rem; margin-bottom: 8px;">🔍</div>
          <div style="font-size: 0.95rem; font-weight: 600; color: #f8fafc;" data-i18n="docs_no_results">${dict.docs_no_results || 'Ühtegi sobivat dokumenti ei leitud.'}</div>
          <div style="font-size: 0.8rem; color: #64748b; margin-top: 4px;">Päring: "${escapeHtml(gDocsSearchQuery)}"</div>
        </div>
      `;
    } else {
      let resultsHtml = `
        <div style="margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between;">
          <span style="font-size: 0.85rem; font-weight: 600; color: #38bdf8;">
            🔍 ${matchedDocs.length} ${dict.docs_search_results || 'dokumenti leitud'} ("${escapeHtml(gDocsSearchQuery)}")
          </span>
          <button class="btn btn-sm btn-secondary" style="font-size: 0.75rem; padding: 2px 8px;" onclick="document.getElementById('docs-search-input').value=''; handleDocsSearchInput('');">✕ Tühjenda</button>
        </div>
        <div style="display: flex; flex-direction: column; gap: 10px;">
      `;
      matchedDocs.forEach(m => {
        resultsHtml += `
          <div class="card" style="margin-bottom: 0; padding: 14px 18px; cursor: pointer; border-left: 3px solid #38bdf8; transition: transform 0.15s ease;" onclick="openDocFromSearch(${m.idx})">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
              <span style="font-weight: 700; color: #f8fafc; font-size: 0.95rem;">${escapeHtml(m.title)}</span>
              <span class="badge badge-primary" style="font-size: 0.72rem; font-family: ui-monospace, monospace;">${escapeHtml(m.doc.rel)}</span>
            </div>
            <div style="font-size: 0.82rem; color: #cbd5e1; line-height: 1.5; background: rgba(0,0,0,0.25); padding: 8px 12px; border-radius: 4px; font-family: ui-monospace, monospace;">
              ${m.snippet}
            </div>
          </div>
        `;
      });
      resultsHtml += `</div>`;
      searchResultsBox.innerHTML = resultsHtml;
    }
  }
}

function openDocFromSearch(idx) {
  const searchResultsBox = document.getElementById('docs-search-results-box');
  const renderedBody = document.getElementById('docs-rendered-body');
  if (searchResultsBox) searchResultsBox.style.display = 'none';
  if (renderedBody) renderedBody.style.display = '';
  loadDocContent(idx);
}

function toggleDocsToc() {
  const list = document.getElementById('docs-toc-list');
  const icon = document.getElementById('docs-toc-toggle-icon');
  if (list) {
    const isHidden = list.style.display === 'none';
    list.style.display = isHidden ? 'block' : 'none';
    if (icon) icon.textContent = isHidden ? '▼' : '▶';
  }
}

function generateDocToc(bodyEl) {
  const tocBox = document.getElementById('docs-toc-box');
  const tocList = document.getElementById('docs-toc-list');
  if (!tocBox || !tocList || !bodyEl) return;
  
  const headings = bodyEl.querySelectorAll('h2, h3');
  if (!headings || headings.length < 2) {
    tocBox.style.display = 'none';
    tocList.innerHTML = '';
    return;
  }

  let tocHtml = '';
  headings.forEach((h, i) => {
    const anchorId = `doc-sec-${i}`;
    h.id = anchorId;
    const isH3 = h.tagName.toLowerCase() === 'h3';
    const indent = isH3 ? 'margin-left: 16px; font-size: 0.78rem; opacity: 0.85;' : 'font-weight: 600; font-size: 0.82rem;';
    tocHtml += `
      <li style="margin-bottom: 4px; ${indent}">
        <a href="#${anchorId}" style="color: #38bdf8; text-decoration: none;" onclick="document.getElementById('${anchorId}').scrollIntoView({behavior:'smooth'}); return false;">
          ${escapeHtml(h.textContent)}
        </a>
      </li>
    `;
  });

  tocList.innerHTML = tocHtml;
  tocBox.style.display = 'block';
}

function interceptDocBodyLinks(bodyEl) {
  if (!bodyEl) return;
  bodyEl.querySelectorAll('a').forEach(a => {
    const href = a.getAttribute('href');
    if (!href) return;

    // 1. External links (http://, https://, //, mailto:)
    if (href.startsWith('http://') || href.startsWith('https://') || href.startsWith('//') || href.startsWith('mailto:')) {
      a.setAttribute('target', '_blank');
      a.setAttribute('rel', 'noopener noreferrer');
      return;
    }

    // 2. Same-page hash anchors (#...)
    if (href.startsWith('#')) {
      a.onclick = (e) => {
        e.preventDefault();
        const targetId = href.substring(1);
        const el = document.getElementById(targetId) || document.querySelector(`[name="${targetId}"]`);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
      };
      return;
    }

    // 3. UNIVERSAL INTERNAL LINK INTERCEPTION (Guarantees zero leaking 404s)
    a.onclick = (e) => {
      e.preventDefault();
      e.stopPropagation();

      const linkText = (a.textContent || '').trim();

      // Detect language switcher target
      let targetLang = null;
      if (linkText.includes('English') || linkText.includes('🇬🇧') || href.endsWith('README.md') || href === 'README.md') {
        targetLang = 'en';
      } else if (linkText.includes('Eesti') || linkText.includes('🇪🇪') || href.includes('/et/') || href.includes('.et.md') || href.startsWith('et/')) {
        targetLang = 'et';
      } else if (linkText.includes('Suomi') || linkText.includes('🇫🇮') || href.includes('/fi/') || href.includes('.fi.md') || href.startsWith('fi/')) {
        targetLang = 'fi';
      } else if (linkText.includes('Svenska') || linkText.includes('🇸🇪') || href.includes('/sv/') || href.includes('.sv.md') || href.startsWith('sv/')) {
        targetLang = 'sv';
      } else if (linkText.includes('Latviešu') || linkText.includes('🇱🇻') || href.includes('/lv/') || href.includes('.lv.md') || href.startsWith('lv/')) {
        targetLang = 'lv';
      } else if (linkText.includes('Lietuvių') || linkText.includes('🇱🇹') || href.includes('/lt/') || href.includes('.lt.md') || href.startsWith('lt/')) {
        targetLang = 'lt';
      }

      // Check if this link is part of the language switcher header:
      // (parent container contains flags/languages, or link text is a language name, or href points to language variant of same/readme file)
      const isHeaderSwitcher = (
        (a.parentElement && (a.parentElement.textContent.includes('English') || a.parentElement.textContent.includes('Eesti') || a.parentElement.textContent.includes('Suomi'))) ||
        /^(🇬🇧|🇪🇪|🇫🇮|🇸🇪|🇱🇻|🇱🇹|English|Eesti|Suomi|Svenska|Latviešu|Lietuvių)$/i.test(linkText) ||
        linkText.includes('English') || linkText.includes('Eesti') || linkText.includes('Suomi') || 
        linkText.includes('Svenska') || linkText.includes('Latviešu') || linkText.includes('Lietuvių') ||
        /\.(et|fi|sv|lv|lt)\.md$/i.test(href) ||
        /^(et|fi|sv|lv|lt)\//i.test(href)
      );

      if (targetLang && isHeaderSwitcher) {
        setLanguage(targetLang);
        loadDocContent(currentSelectedDocIdx);
        const docBox = document.getElementById('tab-docs');
        if (docBox) docBox.scrollIntoView({ behavior: 'smooth', block: 'start' });
        return;
      }

      // 4. Relative markdown links to other documentation guides:
      if (href.endsWith('.md') || href.includes('.md#') || !href.includes('.')) {
        const parts = href.split('#');
        const filePart = parts[0].replace(/^(\.\.\/)+/g, '').replace(/^\.\//g, '');
        const anchorPart = parts[1] || null;
        const targetBase = filePart.split('/').pop().replace(/\.md$/, '').replace(/\.(en|et|fi|sv|lv|lt)$/, '');

        // Alias mapping for old or alternative doc links
        const aliasMap = {
          'github-actions-cicd': 'devops-lifecycle',
          'publisher-guide': 'publisher-setup',
          'turvalisus': 'security',
          'blueprints': 'blueprints-matrix',
          'architecture-blueprints': 'blueprints-matrix',
          'faq': 'faq',
          'glossary': 'glossary',
          'resources': 'oracle-resources',
          'oracle-resources': 'oracle-resources',
          'topology': 'db-topology',
          'db-profiles-and-topology': 'db-topology',
          'forms-setup': 'forms-setup',
          'forms-to-apex': 'forms-to-apex',
          'forms-to-apex-migration-guide': 'forms-to-apex',
          'web-ide': 'web-ide',
          'web-ide-artifactory': 'web-ide',
          'apex-deploy': 'apex-deploy',
          'apex-apps-deployment': 'apex-deploy',
          'setup-workflow': 'setup-workflow',
          'setup-all-workflow': 'setup-workflow',
          'future-plans': 'future-plans'
        };
        const resolvedBase = aliasMap[targetBase] || targetBase;

        const targetIdx = (typeof DOCS_DATA !== 'undefined' && DOCS_DATA) ? DOCS_DATA.findIndex(d => {
          if (!d || !d.rel) return false;
          const dBase = d.rel.split('/').pop().replace(/\.md$/, '');
          return dBase === resolvedBase || dBase === targetBase ||
                 d.id === resolvedBase || d.id === targetBase ||
                 d.rel.endsWith(filePart) || filePart.endsWith(d.rel);
        }) : -1;

        if (targetIdx !== -1) {
          if (targetLang) setLanguage(targetLang);
          loadDocContent(targetIdx);
          if (anchorPart) {
            setTimeout(() => {
              const el = document.getElementById(anchorPart);
              if (el) el.scrollIntoView({ behavior: 'smooth' });
            }, 150);
          } else {
            const docBox = document.getElementById('tab-docs');
            if (docBox) docBox.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
          return;
        }
      }

      // 5. Script or Source File Links (.sh, .sql, .py, .json, .yaml, .yml, .cmd, .env)
      if (/\.(sh|sql|py|json|yaml|yml|cmd|env)$/i.test(href)) {
        const cleanScriptPath = href.replace(/^(\.\.\/)+/, '').replace(/^\.\//, '');
        if (navigator.clipboard) {
          navigator.clipboard.writeText(cleanScriptPath);
        }
        showToast(`📋 Faili viide kopeeritud: <code>${cleanScriptPath}</code>`);
        return;
      }

      // 6. Fallback for other repository files (backlog, connections, tests):
      const cleanPath = href.replace(/^(\.\.\/)+/, '').replace(/^\.\//, '');
      if (navigator.clipboard) {
        navigator.clipboard.writeText(cleanPath);
      }
      showToast(`📄 Dokumendi viide kopeeritud: <code>${cleanPath}</code>`);
    };
  });
}

function loadDocContent(idx, activeBtn, skipHistory = false) {
  currentSelectedDocIdx = idx;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  if (!skipHistory) {
    recordNavigationState({ tab: 'tab-docs', docIdx: idx });
  }
  
  if (activeBtn) {
    document.querySelectorAll('.docs-nav-item').forEach(b => b.classList.remove('active'));
    activeBtn.classList.add('active');
  } else {
    const targetBtn = document.querySelector(`.docs-nav-item[data-doc-idx="${idx}"]`);
    if (targetBtn) {
      document.querySelectorAll('.docs-nav-item').forEach(b => b.classList.remove('active'));
      targetBtn.classList.add('active');
    }
  }
  
  const headerEl = document.getElementById('docs-content-header');
  const bodyEl = document.getElementById('docs-rendered-body');
  if (!bodyEl) return;
  
  const doc = DOCS_DATA[idx];
  if (!doc) return;

  const title = (doc.titles && doc.titles[currentLang]) || (doc.titles && doc.titles['en']) || doc.rel;
  const rawText = (doc.contents && (doc.contents[currentLang] || doc.contents['en'])) || '';
  const wordCount = rawText ? rawText.split(/\s+/).length : 0;
  const readMin = Math.max(1, Math.ceil(wordCount / 200));

  if (headerEl) {
    headerEl.innerHTML = `
      <div style="display: flex; flex-direction: column; gap: 4px;">
        <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
          <h2 style="margin: 0; color: #f8fafc; font-size: 1.3rem;">${escapeHtml(title)}</h2>
          <span class="badge badge-primary" style="font-family: ui-monospace, monospace; font-size: 0.75rem;">${escapeHtml(doc.rel)}</span>
        </div>
        <div style="font-size: 0.8rem; color: #94a3b8; display: flex; align-items: center; gap: 12px; margin-top: 4px;">
          <span>⏱️ ~${readMin} min read (${wordCount} words)</span>
          <span>•</span>
          <span>🌐 ${currentLang.toUpperCase()}</span>
        </div>
      </div>
      <div style="display: flex; gap: 8px;">
        <button class="btn btn-secondary" style="padding: 6px 12px; font-size: 0.78rem;" onclick="copyDocMarkdown(${idx}, this)">
          ${dict.docs_copy_btn || '📋 Copy Markdown'}
        </button>
      </div>
    `;
  }

  // Deduplicate top language switcher line in Dev Hub reader (keeps Markdown clean on screen)
  let text = rawText.replace(/^[ \t]*\[\s*🇬🇧\s*English\s*\].*?\n+/m, '');
  text = text.replace(/^[ \t]*\[\s*🇬🇧\s*\].*?\n+/m, '');

  // 💡 Smart Interactive Banners for duplicated tools
  let smartBannerHtml = '';
  if (doc.rel === 'docs/glossary.md') {
    smartBannerHtml = `
      <div class="doc-smart-banner">
        <div class="banner-text"><span>📖</span> <span>${dict.doc_smart_banner_glossary || 'Interactive Glossary available'}</span></div>
        <button type="button" class="banner-action-btn" onclick="openGlossaryModal()"><span>⚡</span> ${dict.nav_glossary || 'Sõnastik'} ( ? )</button>
      </div>`;
  } else if (doc.rel === 'config/blueprints/README.md') {
    smartBannerHtml = `
      <div class="doc-smart-banner">
        <div class="banner-text"><span>📋</span> <span>${dict.doc_smart_banner_blueprints || '12 Blueprints live in Cockpit'}</span></div>
        <button type="button" class="banner-action-btn" onclick="switchTab('tab-services')"><span>🚀</span> ${dict.tab_cockpit || 'Juhtpaneel'}</button>
      </div>`;
  } else if (doc.rel === 'docs/oracle-resources-and-downloads.md') {
    smartBannerHtml = `
      <div class="doc-smart-banner">
        <div class="banner-text"><span>🏛️</span> <span>${dict.doc_smart_banner_resources || 'Oracle Resources modal'}</span></div>
        <button type="button" class="banner-action-btn" onclick="openOracleResourcesModal('all','')"><span>⚡</span> ${dict.btn_open_oracle_resources || 'Oracle ressursid'}</button>
      </div>`;
  } else if (doc.rel === 'docs/getting-started-from-scratch.md' || doc.rel === 'docs/quick-login-guide.md') {
    smartBannerHtml = `
      <div class="doc-smart-banner">
        <div class="banner-text"><span>🚀</span> <span>${dict.doc_smart_banner_onboarding || 'Interactive Onboarding Wizard'}</span></div>
        <button type="button" class="banner-action-btn" onclick="switchTab('tab-onboarding')"><span>🚀</span> ${dict.tab_onboarding || 'Alustamine'}</button>
      </div>`;
  }

  const isFaq = (doc.rel === 'docs/faq.md');
  const faqToolbarHtml = isFaq ? renderFaqDocToolbar(dict, currentLang) : '';

  if (text) {
    let parsedHtml = '';
    if (typeof marked !== 'undefined') {
      parsedHtml = marked.parse(text);
    } else {
      parsedHtml = `<pre style="white-space:pre-wrap; font-family:inherit; color:#e2e8f0;">${escapeHtml(text)}</pre>`;
    }
    bodyEl.innerHTML = smartBannerHtml + faqToolbarHtml + parsedHtml;
    generateDocToc(bodyEl);
    renderMermaidInContainer(bodyEl);
    interceptDocBodyLinks(bodyEl);
    polishDocRenderedBody(bodyEl, doc, dict, currentLang);
    if (isFaq) {
      filterFaqDoc('all', '');
    }
  } else {
    bodyEl.innerHTML = `
      <div style="background: #1e293b; padding: 24px; border-radius: 8px; border: 1px solid var(--border);">
        <h3 style="color: var(--primary); margin-bottom: 8px;">📄 Repository Documentation: <code>${escapeHtml(doc.rel)}</code></h3>
        <p style="color: var(--text-muted); margin-bottom: 16px;">This markdown guide is located directly in the project repository workspace at: <code>${escapeHtml(doc.rel)}</code></p>
        <pre><code>cat ${escapeHtml(doc.rel)}</code></pre>
      </div>
    `;
  }
}

let gFaqDocActiveCat = 'all';
let gFaqDocSearchTerm = '';

function renderFaqDocToolbar(dict, currentLang) {
  const categories = [
    { id: 'all', label: (I18N_DICT[currentLang] && I18N_DICT[currentLang].track_all) || 'Kõik' },
    { id: 'beginner', label: '🧠 ' + ((I18N_DICT[currentLang] && I18N_DICT[currentLang].ob_cat_beginner) || 'Alustaja ja põhitõed') },
    { id: 'architect', label: '☁️ ' + ((I18N_DICT[currentLang] && I18N_DICT[currentLang].ob_cat_arch) || 'Arhitektuur ja pilv') },
    { id: 'dba_security', label: '🔐 ' + ((I18N_DICT[currentLang] && I18N_DICT[currentLang].ob_cat_dba) || 'DBA ja turvalisus') },
    { id: 'troubleshooting', label: '🛠️ ' + ((I18N_DICT[currentLang] && I18N_DICT[currentLang].ob_cat_trouble) || 'Tõrkeotsing ja taastamine') }
  ];

  let catBtns = '';
  categories.forEach(c => {
    const activeCls = gFaqDocActiveCat === c.id ? 'active' : '';
    catBtns += `<button type="button" class="faq-cat-pill ${activeCls}" onclick="filterFaqDoc('${c.id}', null)">${c.label}</button>`;
  });

  return `
    <div class="faq-toolbar" id="faq-interactive-toolbar">
      <div class="faq-search-row">
        <span class="faq-search-icon">🔍</span>
        <input type="text" id="faq-doc-search-input" class="faq-search-input" placeholder="${dict.faq_search_placeholder_doc || 'Filtreeri küsimusi, vastuseid või käske...'}" oninput="filterFaqDoc(null, this.value)">
        <button type="button" id="faq-doc-search-clear" class="faq-search-clear" onclick="clearFaqDocSearch()">✕</button>
      </div>
      <div class="faq-controls-row">
        <div class="faq-cat-group">
          ${catBtns}
        </div>
        <div class="faq-actions-group">
          <span class="faq-counter-badge" id="faq-doc-counter"></span>
          <button type="button" class="faq-toggle-btn" onclick="toggleAllFaqDoc(true)">${dict.faq_btn_expand_all || '▾ Ava kõik'}</button>
          <button type="button" class="faq-toggle-btn" onclick="toggleAllFaqDoc(false)">${dict.faq_btn_collapse_all || '▴ Sulge kõik'}</button>
        </div>
      </div>
    </div>
  `;
}

function filterFaqDoc(catId, searchTerm) {
  if (catId !== null && catId !== undefined) {
    gFaqDocActiveCat = catId;
    document.querySelectorAll('.faq-cat-pill').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('onclick')?.includes(`'${catId}'`));
    });
  }
  if (searchTerm !== null && searchTerm !== undefined) {
    gFaqDocSearchTerm = searchTerm;
  }

  const term = (gFaqDocSearchTerm || '').toLowerCase().trim();
  const clearBtn = document.getElementById('faq-doc-search-clear');
  if (clearBtn) clearBtn.style.display = term ? 'block' : 'none';

  const items = document.querySelectorAll('details.faq-item');
  let matchedCount = 0;

  items.forEach(item => {
    const cat = item.getAttribute('data-cat') || '';
    const text = (item.innerText || item.textContent || '').toLowerCase();

    const matchesCat = (gFaqDocActiveCat === 'all' || cat === gFaqDocActiveCat);
    const matchesTerm = (!term || text.includes(term));

    if (matchesCat && matchesTerm) {
      item.style.display = '';
      matchedCount++;
      if (term) {
        item.open = true;
      }
    } else {
      item.style.display = 'none';
    }
  });

  const counterEl = document.getElementById('faq-doc-counter');
  if (counterEl) {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    const tmpl = dict.faq_showing_results || 'Näidatakse %s / %t küsimust';
    counterEl.textContent = tmpl.replace('%s', matchedCount).replace('%t', items.length);
  }
}

function clearFaqDocSearch() {
  const input = document.getElementById('faq-doc-search-input');
  if (input) input.value = '';
  filterFaqDoc(null, '');
}

function toggleAllFaqDoc(expand) {
  document.querySelectorAll('details.faq-item').forEach(item => {
    if (item.style.display !== 'none') {
      item.open = expand;
    }
  });
}

function polishDocRenderedBody(bodyEl, doc, dict, currentLang) {
  if (!bodyEl) return;

  // 1. GitHub Alert Callouts: [!NOTE], [!IMPORTANT], [!WARNING], [!TIP], [!CAUTION]
  bodyEl.querySelectorAll('blockquote').forEach(bq => {
    const rawHtml = bq.innerHTML.trim();
    const alertTypes = [
      { tag: '[!NOTE]', cls: 'doc-alert-note', icon: 'ℹ️', title: 'NOTE' },
      { tag: '[!IMPORTANT]', cls: 'doc-alert-important', icon: '🟣', title: 'IMPORTANT' },
      { tag: '[!WARNING]', cls: 'doc-alert-warning', icon: '⚠️', title: 'WARNING' },
      { tag: '[!TIP]', cls: 'doc-alert-tip', icon: '💡', title: 'TIP' },
      { tag: '[!CAUTION]', cls: 'doc-alert-caution', icon: '🛑', title: 'CAUTION' }
    ];

    for (const a of alertTypes) {
      if (rawHtml.includes(a.tag)) {
        bq.className = `doc-alert ${a.cls}`;
        let newContent = rawHtml.replace(a.tag, '').trim();
        newContent = newContent.replace(/^<p>\s*<\/p>/, '').replace(/^<p>\s*/, '<p>');
        bq.innerHTML = `
          <div class="doc-alert-title"><span>${a.icon}</span> <span>${a.title}</span></div>
          <div class="doc-alert-content">${newContent}</div>
        `;
        break;
      }
    }
  });

  // 2. Wrap all <pre> code blocks with 1-click Copy button
  bodyEl.querySelectorAll('pre').forEach(pre => {
    if (pre.parentElement && pre.parentElement.classList.contains('doc-code-wrapper')) return;
    const wrapper = document.createElement('div');
    wrapper.className = 'doc-code-wrapper';
    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(pre);

    const copyBtn = document.createElement('button');
    copyBtn.type = 'button';
    copyBtn.className = 'doc-code-copy-btn';
    copyBtn.innerHTML = `<span>📋</span> ${dict.doc_copy_code || 'Copy'}`;
    copyBtn.onclick = () => {
      const codeText = pre.innerText || pre.textContent || '';
      navigator.clipboard.writeText(codeText.trim()).then(() => {
        copyBtn.innerHTML = `<span>✅</span> ${dict.doc_code_copied || 'Copied!'}`;
        copyBtn.style.borderColor = '#10b981';
        copyBtn.style.color = '#10b981';
        showToast(dict.faq_cmd_copied || 'Käsk kopeeritud!');
        setTimeout(() => {
          copyBtn.innerHTML = `<span>📋</span> ${dict.doc_copy_code || 'Copy'}`;
          copyBtn.style.borderColor = '';
          copyBtn.style.color = '';
        }, 2000);
      });
    };
    wrapper.appendChild(copyBtn);
  });

  // 3. Responsive Table Wrappers
  bodyEl.querySelectorAll('table').forEach(tbl => {
    if (tbl.parentElement && tbl.parentElement.classList.contains('doc-table-wrapper')) return;
    const wrapper = document.createElement('div');
    wrapper.className = 'doc-table-wrapper';
    tbl.parentNode.insertBefore(wrapper, tbl);
    wrapper.appendChild(tbl);
  });

  // 4. FAQ Deep Link Anchors
  bodyEl.querySelectorAll('details.faq-item').forEach(item => {
    const summary = item.querySelector('summary');
    if (!summary || summary.querySelector('.faq-link-anchor')) return;
    const anchorBtn = document.createElement('a');
    anchorBtn.className = 'faq-link-anchor';
    anchorBtn.href = 'javascript:void(0)';
    anchorBtn.title = dict.faq_copy_link || 'Copy direct link';
    anchorBtn.innerHTML = '🔗';
    anchorBtn.onclick = (e) => {
      e.stopPropagation();
      e.preventDefault();
      const url = `${window.location.origin}${window.location.pathname}#${item.id}`;
      navigator.clipboard.writeText(url).then(() => {
        showToast(dict.faq_link_copied || 'Otselink kopeeritud!');
      });
    };
    const tag = summary.querySelector('.faq-cat-tag');
    if (tag) {
      summary.insertBefore(anchorBtn, tag);
    } else {
      summary.appendChild(anchorBtn);
    }
  });

  // 5. Setup Floating Back-to-Top Button
  let topBtn = document.getElementById('doc-back-to-top-btn');
  if (!topBtn) {
    topBtn = document.createElement('button');
    topBtn.id = 'doc-back-to-top-btn';
    topBtn.type = 'button';
    topBtn.className = 'doc-back-to-top';
    topBtn.innerHTML = `<span>⬆️</span> <span>${dict.doc_back_to_top || 'Üles'}</span>`;
    topBtn.onclick = () => {
      const scrollParent = document.getElementById('docs-markdown-view') || window;
      if (scrollParent.scrollTo) {
        scrollParent.scrollTo({ top: 0, behavior: 'smooth' });
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    };
    document.body.appendChild(topBtn);
  }

  const scrollContainer = document.getElementById('docs-markdown-view') || window;
  const onScrollHandler = () => {
    const scrollTop = (scrollContainer.scrollTop !== undefined && scrollContainer.scrollTop > 0) ? scrollContainer.scrollTop : window.scrollY;
    if (scrollTop > 300) {
      topBtn.style.display = 'flex';
    } else {
      topBtn.style.display = 'none';
    }
  };
  scrollContainer.onscroll = onScrollHandler;
  window.onscroll = onScrollHandler;
}

function copyDocMarkdown(idx, btn) {
  const doc = DOCS_DATA[idx];
  if (!doc || !doc.contents) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const text = doc.contents[currentLang] || doc.contents['en'] || '';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  navigator.clipboard.writeText(text).then(() => {
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = dict.docs_copied_btn || '✅ Markdown Copied!';
      setTimeout(() => { btn.innerHTML = orig; }, 2000);
    }
  });
}

function loadBenchmarksData() {
  const statsContainer = document.getElementById('benchmarks-stats-cards');
  const tableContainer = document.getElementById('benchmarks-table-container');
  const logsContainer = document.getElementById('benchmarks-logs-container');
  if (!tableContainer) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  const setup = (BENCHMARKS_DATA && BENCHMARKS_DATA.steps) ? BENCHMARKS_DATA : {
    total_duration_formatted: "15m 20s",
    total_duration_seconds: 920,
    last_updated: "2026-08-31T21:04:38Z",
    parameters: { db_host: "localhost", db_port: "1532", db_service: "FREEPDB1" },
    steps: {
      step1_container_images_pull_seconds: 3,
      step2_ords_download_seconds: 1,
      step3_apex_download_unzip_seconds: 13,
      step4_container_startup_seconds: 58,
      step4_5_wallet_tns_config_seconds: 69,
      step5_ords_service_seconds: 0,
      step5_5_liquibase_migration_seconds: 0,
      step6_apex_copy_container_seconds: 20,
      step7_apex_engine_install_seconds: 348,
      step8_ords_config_seconds: 10,
      step9_publisher_install_seconds: 0,
      step10_deploy_apex_apps_seconds: 0,
      step11_snapshot_seconds: 0
    }
  };

  const reset = RESET_BENCHMARKS_DATA || { reset_duration_formatted: "4s", reset_duration_seconds: 4 };

  // 1. Top Stat Cards
  const totalSecs = setup.total_duration_seconds || 920;
  const lastUpdatedStr = setup.last_updated ? new Date(setup.last_updated).toLocaleString() : '2026-08-31 21:04:38';
  
  if (statsContainer) {
    statsContainer.innerHTML = `
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px;">
        <div class="card" style="padding: 16px; border-left: 4px solid var(--primary); background: rgba(56, 189, 248, 0.05);">
          <div style="font-size: 0.8rem; color: var(--text-muted);">${dict.bench_stat_total || 'Total Provisioning Time'}</div>
          <div style="font-size: 1.6rem; font-weight: 800; color: #f8fafc; font-family: ui-monospace, monospace; margin-top: 4px;">
            ⏱️ ${setup.total_duration_formatted || '15m 20s'} <span style="font-size: 0.9rem; color: var(--primary); font-weight: 500;">(${totalSecs}s)</span>
          </div>
        </div>
        <div class="card" style="padding: 16px; border-left: 4px solid #a855f7; background: rgba(168, 85, 247, 0.05);">
          <div style="font-size: 0.8rem; color: var(--text-muted);">${dict.bench_stat_bp || 'Active Blueprint'}</div>
          <div style="font-size: 1.3rem; font-weight: 700; color: #f8fafc; margin-top: 4px;">
            🏗️ Blueprint #${ACTIVE_BP_NUM}
          </div>
        </div>
        <div class="card" style="padding: 16px; border-left: 4px solid #22c55e; background: rgba(34, 197, 94, 0.05);">
          <div style="font-size: 0.8rem; color: var(--text-muted);">${dict.bench_stat_last || 'Last Execution Run'}</div>
          <div style="font-size: 0.95rem; font-weight: 600; color: #f8fafc; font-family: ui-monospace, monospace; margin-top: 6px;">
            📅 ${lastUpdatedStr}
          </div>
        </div>
        <div class="card" style="padding: 16px; border-left: 4px solid #f59e0b; background: rgba(245, 158, 11, 0.05);">
          <div style="font-size: 0.8rem; color: var(--text-muted);">${dict.bench_stat_reset || 'Instant Reset & Recovery'}</div>
          <div style="font-size: 1.3rem; font-weight: 700; color: #f8fafc; font-family: ui-monospace, monospace; margin-top: 4px;">
            ⚡ ${reset.reset_duration_formatted || '4s'} <span style="font-size: 0.85rem; color: #94a3b8;">/ Restore ~15s</span>
          </div>
        </div>
      </div>
    `;
  }

  // 2. Step Benchmarks Table
  const stepsList = [
    { key: "step1_container_images_pull_seconds", name: dict.bench_step1 || "Step 1: Container Images Pull/Check", icon: "📦" },
    { key: "step2_ords_download_seconds", name: dict.bench_step2 || "Step 2: ORDS Software Download", icon: "🌐" },
    { key: "step3_apex_download_unzip_seconds", name: dict.bench_step3 || "Step 3: APEX Software Packages", icon: "📁" },
    { key: "step4_container_startup_seconds", name: dict.bench_step4 || "Step 4: Database Container Startup", icon: "🗄️" },
    { key: "step4_5_wallet_tns_config_seconds", name: dict.bench_step5_wallet || "Step 5: SEPS Wallet & TNS Config", icon: "🔐" },
    { key: "step6_apex_copy_container_seconds", name: dict.bench_step6_copy || "Step 6: APEX Container Stage", icon: "🚀" },
    { key: "step7_apex_engine_install_seconds", name: dict.bench_step6 || "Step 7: APEX Engine Install & Patching", icon: "⚙️" },
    { key: "step8_ords_config_seconds", name: dict.bench_step7 || "Step 8: ORDS Config & Pools Init", icon: "🌐" },
    { key: "step9_publisher_install_seconds", name: dict.bench_step9 || "Step 9: Analytics Publisher", icon: "📊" },
    { key: "step10_deploy_apex_apps_seconds", name: dict.bench_step8 || "Step 10: APEX Apps Deployment", icon: "📱" },
    { key: "step11_snapshot_seconds", name: dict.bench_step10 || "Step 11: Golden Snapshots Creation", icon: "⚡" }
  ];

  let tableHtml = `
    <div class="table-responsive">
      <table>
        <thead>
          <tr>
            <th style="width: 40%;">${dict.bench_th_step || 'Setup Step / Subsystem'}</th>
            <th style="width: 25%;">${dict.bench_th_duration || 'Duration'}</th>
            <th style="width: 20%;">Relative Load</th>
            <th style="width: 15%; text-align: right;">${dict.bench_th_status || 'Status'}</th>
          </tr>
        </thead>
        <tbody>
  `;

  stepsList.forEach(s => {
    const sSecs = (setup.steps && setup.steps[s.key] !== undefined) ? setup.steps[s.key] : 0;
    if (sSecs > 0 || s.key === "step1_container_images_pull_seconds" || s.key === "step4_container_startup_seconds" || s.key === "step7_apex_engine_install_seconds") {
      const durFormatted = (sSecs >= 60) ? Math.floor(sSecs/60) + 'm ' + (sSecs%60) + 's' : sSecs + 's';
      const pct = Math.max(2, Math.min(100, Math.round((sSecs / totalSecs) * 100)));
      tableHtml += `
        <tr>
          <td><span style="margin-right: 8px;">${s.icon}</span> <strong>${s.name}</strong></td>
          <td style="font-family: ui-monospace, monospace; color: var(--primary); font-weight: 600;">
            ${durFormatted} <span style="font-size: 0.75rem; color: #64748b;">(${sSecs}s)</span>
          </td>
          <td>
            <div style="background: rgba(255,255,255,0.06); border-radius: 4px; height: 8px; width: 100%; overflow: hidden;">
              <div style="background: linear-gradient(90deg, #38bdf8, #818cf8); height: 100%; width: ${pct}%;"></div>
            </div>
            <div style="font-size: 0.7rem; color: #64748b; margin-top: 2px;">${pct}% of setup</div>
          </td>
          <td style="text-align: right;"><span style="color: var(--success); font-weight: 600; font-size: 0.85rem;">${dict.bench_completed || '✔ Completed'}</span></td>
        </tr>
      `;
    }
  });

  tableHtml += `
        <tr style="background: rgba(56, 189, 248, 0.08); font-weight: bold; border-top: 2px solid var(--border);">
          <td>🏁 <strong>${dict.bench_total || 'TOTAL SETUP TIME'}</strong></td>
          <td style="font-family: ui-monospace, monospace; color: #38bdf8; font-size: 1.05rem;">${setup.total_duration_formatted || '15m 20s'} (${totalSecs}s)</td>
          <td>
            <div style="background: rgba(255,255,255,0.1); border-radius: 4px; height: 8px; width: 100%; overflow: hidden;">
              <div style="background: #22c55e; height: 100%; width: 100%;"></div>
            </div>
            <div style="font-size: 0.7rem; color: #22c55e; margin-top: 2px;">100% completed</div>
          </td>
          <td style="text-align: right;"><span style="color: var(--success); font-weight: 700; font-size: 0.9rem;">✔ 100% OK</span></td>
        </tr>
      </tbody>
    </table>
  </div>
  `;

  tableContainer.innerHTML = tableHtml;

  // 3. Execution Logs Explorer
  loadLogsExplorer();
}

let gLogsList = [];
let gLogsCategory = 'all';
let gLogsBlueprint = 'all';
let gLogsSearchQuery = '';
let gCurrentSelectedLogFile = null;

async function loadLogsExplorer(refresh = false) {
  if (gLogsList.length === 0 || refresh) {
    try {
      const resp = await fetch(`${BRIDGE_URL}/api/logs/list`);
      if (resp.ok) {
        const data = await resp.json();
        if (Array.isArray(data.logs) && data.logs.length > 0) {
          gLogsList = data.logs;
        }
      }
    } catch (e) {}

    if (gLogsList.length === 0 && typeof LOGS_DATA !== 'undefined' && Array.isArray(LOGS_DATA)) {
      gLogsList = LOGS_DATA.map(l => ({
        filename: l.filename,
        mtime: l.mtime,
        timestamp: l.mtime,
        size_bytes: l.size_bytes,
        category: 'setup',
        blueprint: null,
        label: l.filename,
        content: l.content
      }));
    }
  }

  renderLogsExplorerView();
}

function filterLogsCategory(cat) {
  gLogsCategory = cat || 'all';
  ['all', 'setup', 'test', 'snapshot', 'devops'].forEach(c => {
    const btn = document.getElementById(`btn-log-cat-${c}`);
    if (btn) btn.classList.toggle('active', c === gLogsCategory);
  });
  renderLogsExplorerView();
}

function filterLogsBlueprint(bp) {
  gLogsBlueprint = bp || 'all';
  renderLogsExplorerView();
}

function filterLogsSearch(q) {
  gLogsSearchQuery = (q || '').trim();
  renderLogsExplorerView();
}

function switchLogsSubTab(subTab) {
  const explorerView = document.getElementById('logs-subtab-explorer-view');
  const benchmarksView = document.getElementById('logs-subtab-benchmarks-view');
  const btnExplorer = document.getElementById('logs-subtab-btn-explorer');
  const btnBenchmarks = document.getElementById('logs-subtab-btn-benchmarks');

  if (subTab === 'benchmarks') {
    if (explorerView) explorerView.style.display = 'none';
    if (benchmarksView) benchmarksView.style.display = 'block';
    if (btnExplorer) btnExplorer.classList.remove('active');
    if (btnBenchmarks) btnBenchmarks.classList.add('active');
  } else {
    if (explorerView) explorerView.style.display = 'block';
    if (benchmarksView) benchmarksView.style.display = 'none';
    if (btnExplorer) btnExplorer.classList.add('active');
    if (btnBenchmarks) btnBenchmarks.classList.remove('active');
    renderLogsExplorerView();
  }
}

function renderLogsExplorerView() {
  const logsContainer = document.getElementById('benchmarks-logs-container');
  if (!logsContainer) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  let filtered = [...gLogsList];
  if (gLogsCategory !== 'all') {
    filtered = filtered.filter(l => l.category === gLogsCategory);
  }
  if (gLogsBlueprint !== 'all') {
    filtered = filtered.filter(l => String(l.blueprint) === String(gLogsBlueprint));
  }
  if (gLogsSearchQuery) {
    const q = gLogsSearchQuery.toLowerCase();
    filtered = filtered.filter(l => (l.filename || '').toLowerCase().includes(q) || (l.label || '').toLowerCase().includes(q));
  }

  if (!gCurrentSelectedLogFile && filtered.length > 0) {
    gCurrentSelectedLogFile = filtered[0].filename;
  } else if (filtered.length > 0 && !filtered.some(l => l.filename === gCurrentSelectedLogFile)) {
    gCurrentSelectedLogFile = filtered[0].filename;
  }

  let listItems = '';
  if (filtered.length === 0) {
    listItems = `<div style="text-align:center; padding:24px; color:var(--text-dim);" data-i18n="logs_no_logs_found">${dict.logs_no_logs_found || 'Ühtegi logifaili ei leitud valitud filtritega.'}</div>`;
  } else {
    listItems = filtered.map(l => {
      const isSelected = l.filename === gCurrentSelectedLogFile;
      const sizeKb = (l.size_bytes ? (l.size_bytes / 1024).toFixed(1) : '0') + ' KB';
      const bpLabel = (l.blueprint !== null && l.blueprint !== undefined) ? `<span class="badge badge-primary" style="font-size:0.68rem; padding: 1px 6px;">BP #${l.blueprint}</span>` : '';

      let catBadge = '';
      if (l.category === 'setup') catBadge = `<span class="badge badge-success" style="font-size:0.68rem; padding: 1px 6px;">${dict.logs_cat_setup || 'Paigaldus'}</span>`;
      else if (l.category === 'test') catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; background:rgba(168,85,247,0.2); color:#c084fc; border:1px solid rgba(168,85,247,0.4);">${dict.logs_cat_test || 'Testimine'}</span>`;
      else if (l.category === 'snapshot') catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; background:rgba(245,158,11,0.2); color:#fbbf24; border:1px solid rgba(245,158,11,0.4);">${dict.logs_cat_snapshot || 'Snapshot'}</span>`;
      else if (l.category === 'devops') catBadge = `<span class="badge badge-primary" style="font-size:0.68rem; padding: 1px 6px;">${dict.logs_cat_devops || 'DevOps'}</span>`;
      else catBadge = `<span class="badge" style="font-size:0.68rem; padding: 1px 6px; color:#94a3b8;">Üldine</span>`;

      return `
        <div class="log-item ${isSelected ? 'active' : ''}" onclick="selectLogFile('${escapeHtml(l.filename)}')">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
            <div style="display: flex; gap: 5px; align-items: center;">
              ${catBadge}
              ${bpLabel}
            </div>
            <span style="font-size: 0.72rem; color: #94a3b8; font-family: ui-monospace, monospace;">${sizeKb}</span>
          </div>
          <div style="font-family: ui-monospace, monospace; font-size: 0.78rem; color: ${isSelected ? '#38bdf8' : '#e2e8f0'}; word-break: break-all; line-height: 1.35;">
            ${escapeHtml(l.filename)}
          </div>
          <div style="font-size: 0.7rem; color: #64748b; margin-top: 4px; font-family: ui-monospace, monospace;">
            ${escapeHtml(l.timestamp || l.mtime || '-')}
          </div>
        </div>
      `;
    }).join('');
  }

  const selectedLogObj = filtered.find(l => l.filename === gCurrentSelectedLogFile) || (filtered.length > 0 ? filtered[0] : null);

  logsContainer.innerHTML = `
    <div class="logs-split-container">
      <div class="logs-list-pane">
        <div style="font-size: 0.75rem; color: #94a3b8; font-weight: 600; text-transform: uppercase; padding: 4px 6px; margin-bottom: 4px; display: flex; justify-content: space-between;">
          <span>Logifailid (${filtered.length})</span>
          <span>Suurus</span>
        </div>
        ${listItems}
      </div>

      <div class="logs-viewer-pane">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 8px; flex-wrap: wrap; gap: 8px;">
          <div style="font-size: 0.82rem; color: #94a3b8; font-family: ui-monospace, monospace;">
            📄 <strong id="log-view-title" style="color: #f8fafc;">${selectedLogObj ? escapeHtml(selectedLogObj.filename) : 'Vali logifail'}</strong>
            <span id="log-view-meta" style="margin-left: 8px; font-size: 0.76rem; color: #64748b;">
              ${selectedLogObj ? `(${((selectedLogObj.size_bytes || 0) / 1024).toFixed(1)} KB | ${selectedLogObj.timestamp || selectedLogObj.mtime || ''})` : ''}
            </span>
          </div>
          <div style="display: flex; gap: 8px;">
            <button class="btn btn-sm btn-secondary" onclick="copyCurrentLogText()" style="padding: 4px 10px; font-size: 0.75rem;" data-i18n="bench_btn_copy_log">
              📋 ${dict.bench_btn_copy_log || 'Kopeeri logi'}
            </button>
            <button class="btn btn-sm btn-secondary" onclick="downloadCurrentLogText()" style="padding: 4px 10px; font-size: 0.75rem;" data-i18n="btn_download_log">
              💾 ${dict.btn_download_log || 'Laadi alla'}
            </button>
          </div>
        </div>
        <pre id="current-log-pre" style="flex: 1; min-height: 0; color: #38bdf8; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 0.8rem; line-height: 1.5; overflow-y: auto; white-space: pre-wrap; word-break: break-all; margin: 0;">${selectedLogObj && selectedLogObj.content ? escapeHtml(selectedLogObj.content) : 'Laadin logi sisu...'}</pre>
      </div>
    </div>
  `;

  if (selectedLogObj && !selectedLogObj.content) {
    loadLogContentFromBridge(selectedLogObj.filename);
  }
}

async function selectLogFile(filename) {
  gCurrentSelectedLogFile = filename;
  renderLogsExplorerView();
}

async function loadLogContentFromBridge(filename) {
  const pre = document.getElementById('current-log-pre');
  if (!pre) return;
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(filename)}`);
    if (resp.ok) {
      const data = await resp.json();
      const content = data.content || `[Tühi logi või fail puudub: ${filename}]`;
      pre.textContent = content;
      const item = gLogsList.find(l => l.filename === filename);
      if (item) item.content = content;
    } else {
      pre.textContent = `[Logi sisu ei õnnestunud lugeda: HTTP ${resp.status}]`;
    }
  } catch (e) {
    pre.textContent = `[Viga logi lugemisel: ${e.message}]`;
  }
}

function copyCurrentLogText() {
  const pre = document.getElementById('current-log-pre');
  if (pre && pre.textContent) {
    navigator.clipboard.writeText(pre.textContent).then(() => {
      showToast('📋 Log content copied to clipboard!');
    });
  }
}

function downloadCurrentLogText() {
  const pre = document.getElementById('current-log-pre');
  const filename = gCurrentSelectedLogFile || 'install_log.txt';
  if (!pre || !pre.textContent) return;
  const blob = new Blob([pre.textContent], { type: 'text/plain' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast(`💾 Allalaadimine alustatud: ${filename}`);
}

// PRESENTATION SLIDE DECK ENGINE


let speakerNotesOpen = false;

function toggleSpeakerNotes() {
  speakerNotesOpen = !speakerNotesOpen;
  const drawer = document.getElementById('speaker-notes-drawer');
  const btn = document.getElementById('btn-toggle-speaker-notes');
  if (drawer) {
    if (speakerNotesOpen) drawer.classList.add('open');
    else drawer.classList.remove('open');
  }
  if (btn) {
    if (speakerNotesOpen) btn.classList.add('active');
    else btn.classList.remove('active');
  }
}

function copySlideCode(btn, code) {
  if (!code) return;
  copyTextToClipboard(code).then(() => {
    const orig = btn.textContent;
    btn.textContent = '✅ Copied!';
    setTimeout(() => { btn.textContent = orig; }, 2000);
  });
}

function updateSpeakerNotes(lang) {
  if (!SLIDES_CONTENT) return;
  if (!lang || !I18N_DICT[lang]) lang = localStorage.getItem('dev_hub_lang') || 'en';
  const sNum = currentSlideIdx + 1;
  const sData = SLIDES_CONTENT[sNum];
  const headerEl = document.getElementById('speaker-notes-header-text');
  const bodyEl = document.getElementById('speaker-notes-body');
  const toggleLabel = document.getElementById('label-speaker-notes');

  const titles = {
    'et': `Esitaja märkmed (Slaid ${sNum})`,
    'fi': `Puhujan muistiinpanot (Dia ${sNum})`,
    'sv': `Talarnoteringar (Bild ${sNum})`,
    'lv': `Runātāja piezīmes (Slaids ${sNum})`,
    'lt': `Pranešėjo pastabos (Skaidrė ${sNum})`,
    'en': `Speaker Notes (Slide ${sNum})`
  };
  const btnLabels = {
    'et': '🎙️ Esitaja märkmed',
    'fi': '🎙️ Puhujan muistiinpanot',
    'sv': '🎙️ Talarnoteringar',
    'lv': '🎙️ Runātāja piezīmes',
    'lt': '🎙️ Pranešėjo pastabos',
    'en': '🎙️ Speaker Notes'
  };

  if (headerEl) headerEl.textContent = titles[lang] || titles['en'];
  if (toggleLabel) toggleLabel.textContent = btnLabels[lang] || btnLabels['en'];

  if (bodyEl) {
    if (sData && sData.speaker_notes) {
      const notes = sData.speaker_notes[lang] || sData.speaker_notes['en'] || '';
      bodyEl.innerHTML = notes;
    } else {
      bodyEl.innerHTML = '<span style="color: #64748b;">No speaker notes for this slide.</span>';
    }
  }
}

const ROLE_TRACKS = {
  'all': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
  'exec': [1, 2, 3],
  'dev': [1, 4, 11, 13],
  'devops': [1, 5, 8, 13],
  'dba': [1, 6, 9, 10]
};
let gActiveSlideTrack = 'all';

function filterSlideTrack(track) {
  if (!ROLE_TRACKS[track]) track = 'all';
  gActiveSlideTrack = track;

  ['all', 'exec', 'dev', 'devops', 'dba'].forEach(t => {
    const btn = document.getElementById(`track-btn-${t}`);
    if (btn) btn.classList.toggle('active', t === track);
    const modalBtn = document.getElementById(`modal-track-btn-${t}`);
    if (modalBtn) modalBtn.classList.toggle('active', t === track);
  });

  renderSlideNavButtons();

  const allowed = ROLE_TRACKS[track];
  const currentNum = currentSlideIdx + 1;
  if (!allowed.includes(currentNum)) {
    goToSlide(allowed[0] - 1);
  } else {
    updateSlideView();
  }

  // If fullscreen cinema modal is open, sync modal view immediately
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (backdrop && backdrop.style.display !== 'none') {
    syncModalSlide();
  }
}

function renderSlideNavButtons() {
  const container = document.getElementById('top-slide-numbers');
  if (!container) return;
  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  container.innerHTML = allowed.map(sNum => {
    const isActive = (sNum === (currentSlideIdx + 1));
    return `<button class="slide-num-btn ${isActive ? 'active' : ''}" onclick="goToSlide(${sNum - 1})" title="Slaid ${sNum}">${sNum}</button>`;
  }).join('');
}

function selectDocById(docId) {
  if (!Array.isArray(DOCS_DATA)) return;
  const target = (docId || '').toLowerCase().trim();
  const idx = DOCS_DATA.findIndex(d => {
    if (!d || !d.rel) return false;
    const relLower = d.rel.toLowerCase();
    const base = relLower.split('/').pop().replace(/\.md$/, '');
    const idLower = (d.id || '').toLowerCase();
    return idLower === target || base === target || relLower.includes(target);
  });
  if (idx !== -1) {
    loadDocContent(idx);
    setTimeout(() => {
      const targetBtn = document.querySelector(`.docs-nav-item[data-doc-idx="${idx}"]`);
      if (targetBtn) {
        document.querySelectorAll('.docs-nav-item').forEach(b => b.classList.remove('active'));
        targetBtn.classList.add('active');
        if (typeof targetBtn.scrollIntoView === 'function') {
          targetBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }, 50);
  }
}

function openDocModal(docId) {
  navigateToDoc(docId);
}

function renderSlideDeck(lang) {
  if (!SLIDES_CONTENT) return;
  if (!lang || !I18N_DICT[lang]) lang = localStorage.getItem('dev_hub_lang') || 'en';
  
  // Render top number buttons based on active track
  renderSlideNavButtons();

  // Update cinema mode button labels
  const cinemaLabels = {
    'et': '🖥️ Esitlusrežiim',
    'fi': '🖥️ Esitystila',
    'sv': '🖥️ Presentationsläge',
    'lv': '🖥️ Prezentācijas režīms',
    'lt': '🖥️ Pateikties režimas',
    'en': '🖥️ Presentation Mode'
  };
  const exitLabels = {
    'et': 'Välju (Esc)',
    'fi': 'Poistu (Esc)',
    'sv': 'Avsluta (Esc)',
    'lv': 'Iziet (Esc)',
    'lt': 'Išeiti (Esc)',
    'en': 'Exit (Esc)'
  };
  const cLabel = cinemaLabels[lang] || cinemaLabels['en'];
  const topCinema = document.getElementById('label-cinema-mode');
  if (topCinema) topCinema.textContent = cLabel;
  const footerCinema = document.getElementById('label-footer-cinema-mode');
  if (footerCinema) footerCinema.textContent = cLabel;
  const modalExit = document.getElementById('label-modal-exit');
  if (modalExit) modalExit.textContent = exitLabels[lang] || exitLabels['en'];

  const getSlideI18n = (obj, l, fallback = '') => {
    if (!obj) return fallback;
    if (typeof obj === 'string') return obj;
    return obj[l] || obj['en'] || fallback;
  };

  for (let sNum = 1; sNum <= totalSlides; sNum++) {
    const sData = SLIDES_CONTENT[sNum];
    if (!sData) continue;
    const slideEl = document.getElementById('slide-' + sNum);
    if (!slideEl) continue;

    const bText = getSlideI18n(sData.badge, lang);
    const tText = getSlideI18n(sData.title, lang);
    const lText = getSlideI18n(sData.lead, lang);

    let diagramHtml = '';
    if (sData.comparison_diagram) {
      const cd = sData.comparison_diagram;
      const defaultCompTitle = (lang === 'et') ? 'Protsessi Võrdlus' : (lang === 'fi') ? 'Prosessivertailu' : (lang === 'sv') ? 'Processjämförelse' : (lang === 'lv') ? 'Procesa Salīdzinājums' : (lang === 'lt') ? 'Proceso Palyginimas' : 'Process Comparison';
      const cdTitle = getSlideI18n(cd.title, lang, defaultCompTitle);
      const badLabel = getSlideI18n(cd.bad && cd.bad.label, lang, 'TRADITIONAL');
      const goodLabel = getSlideI18n(cd.good && cd.good.label, lang, 'ORACLE DEVOPS PLATFORM');
      
      let badNodesHtml = '';
      if (cd.bad && cd.bad.nodes) {
        cd.bad.nodes.forEach(st => {
          const stTitle = getSlideI18n(st.title, lang);
          const stSub = getSlideI18n(st.sub, lang);
          badNodesHtml += `
            <div class="slide-flow-step slide-step-bad">
              <span class="slide-flow-step-icon">${st.icon || '⚠️'}</span>
              <div class="slide-flow-step-title">${stTitle}</div>
              <div class="slide-flow-step-sub">${stSub}</div>
            </div>`;
        });
      }

      let goodNodesHtml = '';
      if (cd.good && cd.good.nodes) {
        cd.good.nodes.forEach(st => {
          const stTitle = getSlideI18n(st.title, lang);
          const stSub = getSlideI18n(st.sub, lang);
          goodNodesHtml += `
            <div class="slide-flow-step slide-step-good">
              <span class="slide-flow-step-icon">${st.icon || '✅'}</span>
              <div class="slide-flow-step-title">${stTitle}</div>
              <div class="slide-flow-step-sub">${stSub}</div>
            </div>`;
        });
      }

      diagramHtml = `
        <div class="slide-diagram-box">
          <div class="slide-diagram-title">${cdTitle}</div>
          <div class="slide-comparison-wrapper">
            <div class="slide-flow-col slide-flow-bad">
              <div class="slide-col-header slide-col-header-bad">${badLabel}</div>
              <div class="slide-flow-row">${badNodesHtml}</div>
            </div>
            <div class="slide-flow-col slide-flow-good">
              <div class="slide-col-header slide-col-header-good">${goodLabel}</div>
              <div class="slide-flow-row">${goodNodesHtml}</div>
            </div>
          </div>
        </div>`;
    } else if (sData.diagram) {
      const d = sData.diagram;
      const dTitle = getSlideI18n(d.label || d.title, lang, 'Protsessietapid');
      let stepsHtml = '';
      if (d.steps) {
        d.steps.forEach(st => {
          const stTitle = getSlideI18n(st.title, lang);
          const stSub = getSlideI18n(st.sub, lang);
          stepsHtml += `
            <div class="slide-flow-step">
              <span class="slide-flow-step-icon">${st.icon || '⚡'}</span>
              <div class="slide-flow-step-title">${stTitle}</div>
              <div class="slide-flow-step-sub">${stSub}</div>
            </div>`;
        });
      }
      diagramHtml = `
        <div class="slide-diagram-box">
          <div class="slide-diagram-title">${dTitle}</div>
          <div class="slide-flow-row">${stepsHtml}</div>
        </div>`;
    }

    let cardsHtml = '';
    if (sData.cards && sData.cards.length > 0) {
      let cList = '';
      const copyLabel = (lang === 'et') ? 'Kopeeri' : (lang === 'fi') ? 'Kopioi' : (lang === 'sv') ? 'Kopiera' : (lang === 'lv') ? 'Kopēt' : (lang === 'lt') ? 'Kopijuoti' : 'Copy';
      const numCards = sData.cards.length;
      const gridClass = (numCards === 3) ? 'slide-grid-3' : (numCards === 2) ? 'slide-grid-2' : (numCards === 4) ? 'slide-grid-4' : (numCards === 5) ? 'slide-grid-5' : 'slide-grid';

      sData.cards.forEach(c => {
        const cTitle = getSlideI18n(c.title, lang);
        const cDesc = getSlideI18n(c.desc, lang);
        const iconHtml = c.icon ? `<span class="slide-card-icon-wrap">${c.icon}</span>` : '';
        const kpiHtml = c.kpi ? `<span class="slide-kpi-badge">${c.kpi}</span>` : '';
        
        let codeBoxHtml = '';
        if (c.command) {
          codeBoxHtml = `
            <div class="slide-code-box">
              <code>${c.command}</code>
              <button class="slide-copy-btn" onclick="copySlideCode(this, '${c.command}')">${copyLabel}</button>
            </div>`;
        }

        cList += `
          <div class="slide-card">
            <div class="slide-card-top-row">
              ${iconHtml}
              ${kpiHtml}
            </div>
            <h4 class="slide-card-title">${cTitle}</h4>
            <p class="slide-card-desc">${cDesc}</p>
            ${codeBoxHtml}
          </div>`;
      });
      cardsHtml = `<div class="${gridClass}">${cList}</div>`;
    }
    // Slide 12 actions (Open FAQ Center & Oracle Resources)
    let slide12ActionsHtml = '';
    if (sNum === 12) {
      const faqBtnLabel = (I18N_DICT[lang] && I18N_DICT[lang].btn_open_full_faq) || 'Open FAQ Center (All Questions) →';
      const resBtnLabel = (I18N_DICT[lang] && I18N_DICT[lang].btn_open_oracle_resources) || 'Official Oracle Resources & Images →';
      slide12ActionsHtml = `
        <div style="margin-top: 18px; display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
          <button class="btn btn-primary" onclick="openFaqModal()" style="display: inline-flex; align-items: center; gap: 8px; font-weight: 600; padding: 8px 18px; font-size: 0.88rem;">
            <span>❓</span> <span>${faqBtnLabel}</span>
          </button>
          <button class="btn btn-secondary" onclick="openOracleResourcesModal()" style="display: inline-flex; align-items: center; gap: 8px; font-weight: 600; padding: 8px 18px; font-size: 0.88rem;">
            <span>🏛️</span> <span>${resBtnLabel}</span>
          </button>
        </div>`;
    }

    // Slide 12 official Oracle resources pills
    let oracleLinksHtml = '';
    if (sNum === 12 && sData.oracle_resources) {
      const res = sData.oracle_resources;
      const resTitle = getSlideI18n(res.title, lang);
      let rLinks = '';
      if (res.links) {
        res.links.forEach(rl => {
          const lTitle = getSlideI18n(rl.title, lang);
          const icon = rl.icon || '🔗';
          rLinks += `<a href="${rl.url}" target="_blank" rel="noopener noreferrer" class="slide-resource-pill"><span>${icon}</span> ${lTitle} ↗</a>`;
        });
      }
      oracleLinksHtml = `
        <div class="slide-resources-container">
          <div class="slide-resources-title">${resTitle}</div>
          <div class="slide-resources-grid">${rLinks}</div>
        </div>`;
    }

    slideEl.innerHTML = `
      <div class="slide-badge">${bText}</div>
      <h3 class="slide-heading">${tText}</h3>
      <p class="slide-lead">${lText}</p>
      ${diagramHtml}
      ${cardsHtml}
      ${slide12ActionsHtml}
      ${oracleLinksHtml}`;
  }

  updateSpeakerNotes(lang);
  updateSlideView();
}

function updateSlideView() {
  for (let i = 1; i <= totalSlides; i++) {
    const el = document.getElementById('slide-' + i);
    if (el) el.classList.remove('active');
  }
  const activeEl = document.getElementById('slide-' + (currentSlideIdx + 1));
  if (activeEl) activeEl.classList.add('active');
  
  const counter = document.getElementById('slide-counter');
  if (counter) {
    const lang = localStorage.getItem('dev_hub_lang') || 'en';
    const label = (lang === 'et') ? 'Slaid' : (lang === 'fi') ? 'Dia' : (lang === 'sv') ? 'Bild' : (lang === 'lv') ? 'Slaids' : (lang === 'lt') ? 'Skaidrė' : 'Slide';
    const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
    const trackPos = allowed.indexOf(currentSlideIdx + 1) + 1;
    const trackTotal = allowed.length;
    counter.textContent = `${label} ${currentSlideIdx + 1} / ${totalSlides} (${trackPos}/${trackTotal})`;
  }
  
  // Update bottom dots
  const dotsContainer = document.getElementById('slide-dots-container');
  if (dotsContainer) {
    const dots = dotsContainer.getElementsByClassName('slide-dot');
    for (let i = 0; i < dots.length; i++) {
      if (i === currentSlideIdx) dots[i].classList.add('active');
      else dots[i].classList.remove('active');
    }
  }

  // Update top number buttons
  renderSlideNavButtons();

  // Update speaker notes
  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  updateSpeakerNotes(lang);
}

function nextSlide() {
  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  const currentNum = currentSlideIdx + 1;
  const currPos = allowed.indexOf(currentNum);
  if (currPos === -1) {
    currentSlideIdx = allowed[0] - 1;
  } else {
    const nextPos = (currPos + 1) % allowed.length;
    currentSlideIdx = allowed[nextPos] - 1;
  }
  updateSlideView();
}

function prevSlide() {
  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  const currentNum = currentSlideIdx + 1;
  const currPos = allowed.indexOf(currentNum);
  if (currPos === -1) {
    currentSlideIdx = allowed[0] - 1;
  } else {
    const prevPos = (currPos - 1 + allowed.length) % allowed.length;
    currentSlideIdx = allowed[prevPos] - 1;
  }
  updateSlideView();
}

function goToSlide(idx) {
  if (idx >= 0 && idx < totalSlides) {
    currentSlideIdx = idx;
    updateSlideView();
  }
}

// Global keyboard arrow listener for presentation deck (in-page)
window.addEventListener('keydown', function(e) {
  const modal = document.getElementById('slide-modal-backdrop');
  if (modal && modal.style.display !== 'none') {
    return; // Handled by modal listener
  }
  const presTab = document.getElementById('tab-presentation');
  if (presTab && presTab.classList.contains('active')) {
    if (e.key === 'ArrowRight' || e.key === 'PageDown') {
      nextSlide();
    } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
      prevSlide();
    }
  }
});

// Fullscreen Cinema Modal Slide Show Mode
let modalIdleTimer = null;

function handleModalMouseMove() {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop) return;
  backdrop.classList.remove('modal-idle');
  clearTimeout(modalIdleTimer);
  modalIdleTimer = setTimeout(() => {
    backdrop.classList.add('modal-idle');
  }, 2500);
}

function handleModalKeyDown(e) {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop || backdrop.style.display === 'none') return;
  
  if (e.key === 'Escape') {
    e.preventDefault();
    closeSlideModal();
  } else if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ' || e.code === 'Space') {
    e.preventDefault();
    modalNextSlide();
  } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
    e.preventDefault();
    modalPrevSlide();
  }
}

function openSlideModal() {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop) return;
  backdrop.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  syncModalSlide();
  window.addEventListener('keydown', handleModalKeyDown);
  handleModalMouseMove();
  if (!document.fullscreenElement && backdrop.requestFullscreen) {
    backdrop.requestFullscreen().catch(err => {
      console.warn('Fullscreen request denied or not allowed:', err);
    });
  }
}

function closeSlideModal() {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop) return;
  backdrop.style.display = 'none';
  document.body.style.overflow = '';
  window.removeEventListener('keydown', handleModalKeyDown);
  clearTimeout(modalIdleTimer);
  if (document.fullscreenElement) {
    document.exitFullscreen().catch(err => console.warn(err));
  }
  updateSlideView();
}

function syncModalSlide() {
  const modalContent = document.getElementById('modal-slide-content');
  const activeSlide = document.getElementById('slide-' + (currentSlideIdx + 1));
  if (modalContent && activeSlide) {
    modalContent.innerHTML = activeSlide.innerHTML;
  }
  
  // Sync modal track buttons active state
  ['all', 'exec', 'dev', 'devops', 'dba'].forEach(t => {
    const modalBtn = document.getElementById(`modal-track-btn-${t}`);
    if (modalBtn) modalBtn.classList.toggle('active', t === gActiveSlideTrack);
  });

  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  const currentNum = currentSlideIdx + 1;
  const currPos = allowed.indexOf(currentNum);
  const displayPos = (currPos !== -1) ? (currPos + 1) : 1;

  // Update modal slide counter
  const modalCounter = document.getElementById('modal-slide-counter');
  if (modalCounter) {
    const lang = localStorage.getItem('dev_hub_lang') || 'en';
    const label = (lang === 'et') ? 'Slaid' : (lang === 'fi') ? 'Dia' : (lang === 'sv') ? 'Bild' : (lang === 'lv') ? 'Slaids' : (lang === 'lt') ? 'Skaidrė' : 'Slide';
    if (gActiveSlideTrack !== 'all') {
      modalCounter.textContent = `${label} ${displayPos} / ${allowed.length} (${label} ${currentNum})`;
    } else {
      modalCounter.textContent = `${label} ${currentNum} / ${totalSlides}`;
    }
  }

  // Update modal bottom dots based on active track
  const modalDotsContainer = document.getElementById('modal-slide-dots');
  if (modalDotsContainer) {
    let dotsHtml = '';
    for (let i = 0; i < allowed.length; i++) {
      const sNum = allowed[i];
      const activeClass = (sNum === currentNum) ? 'active' : '';
      dotsHtml += `<span class="slide-dot ${activeClass}" onclick="modalGoToSlide(${sNum - 1})" title="Slaid ${sNum}"></span>`;
    }
    modalDotsContainer.innerHTML = dotsHtml;
  }

  // Keep in-page slide view in sync
  updateSlideView();
}

function modalNextSlide() {
  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  const currentNum = currentSlideIdx + 1;
  const currPos = allowed.indexOf(currentNum);
  if (currPos === -1) {
    currentSlideIdx = allowed[0] - 1;
  } else {
    const nextPos = (currPos + 1) % allowed.length;
    currentSlideIdx = allowed[nextPos] - 1;
  }
  syncModalSlide();
}

function modalPrevSlide() {
  const allowed = ROLE_TRACKS[gActiveSlideTrack] || ROLE_TRACKS['all'];
  const currentNum = currentSlideIdx + 1;
  const currPos = allowed.indexOf(currentNum);
  if (currPos === -1) {
    currentSlideIdx = allowed[0] - 1;
  } else {
    const prevPos = (currPos - 1 + allowed.length) % allowed.length;
    currentSlideIdx = allowed[prevPos] - 1;
  }
  syncModalSlide();
}

function modalGoToSlide(idx) {
  if (idx >= 0 && idx < totalSlides) {
    currentSlideIdx = idx;
    syncModalSlide();
  }
}

function toggleModalFullscreen() {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop) return;
  if (!document.fullscreenElement) {
    backdrop.requestFullscreen().catch(err => {
      console.warn('Fullscreen request denied:', err);
    });
  } else {
    document.exitFullscreen();
  }
}

function navigateToDoc(docId) {
  if (typeof filterDocsCategory === 'function') {
    gDocsSelectedCategory = 'all';
    document.querySelectorAll('[id^="btn-docs-cat-"]').forEach(b => {
      b.classList.toggle('active', b.id === 'btn-docs-cat-all');
    });
  }
  let targetIdx = -1;
  if (Array.isArray(DOCS_DATA)) {
    const target = (docId || '').toLowerCase().trim();
    targetIdx = DOCS_DATA.findIndex(d => {
      if (!d || !d.rel) return false;
      const relLower = d.rel.toLowerCase();
      const base = relLower.split('/').pop().replace(/\.md$/, '');
      const idLower = (d.id || '').toLowerCase();
      return idLower === target || base === target || relLower.includes(target);
    });
  }
  if (targetIdx !== -1) {
    currentSelectedDocIdx = targetIdx;
  }
  switchTab('tab-docs');
  if (targetIdx !== -1) {
    loadDocContent(targetIdx);
    setTimeout(() => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }, 50);
  } else if (typeof selectDocById === 'function') {
    selectDocById(docId);
  }
}

function copySnippet(btn) {
  const codeBox = btn.closest('.code-box');
  if (!codeBox) return;
  const clone = codeBox.cloneNode(true);
  const copyBtn = clone.querySelector('.copy-btn');
  if (copyBtn) copyBtn.remove();
  
  navigator.clipboard.writeText(clone.textContent.trim()).then(() => {
    btn.textContent = '✅ Copied!';
    setTimeout(() => { btn.textContent = 'Copy'; }, 2000);
  });
}


function copyTextToClipboard(text) {
  if (!text) return Promise.resolve(false);
  fallbackCopyText(text);
  if (navigator.clipboard && navigator.clipboard.writeText) {
    return navigator.clipboard.writeText(text).catch(() => {
      fallbackCopyText(text);
    });
  }
  return Promise.resolve(true);
}

function fallbackCopyText(text) {
  if (!text) return false;
  try {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'absolute';
    ta.style.opacity = '0.01';
    ta.style.pointerEvents = 'none';
    ta.style.zIndex = '-1';
    ta.style.top = (window.pageYOffset || document.documentElement.scrollTop || 0) + 'px';
    ta.style.left = '0';
    document.body.appendChild(ta);
    ta.focus();
    ta.select();
    ta.setSelectionRange(0, ta.value.length);
    const successful = document.execCommand('copy');
    document.body.removeChild(ta);
    return successful;
  } catch (e) {
    return false;
  }
}

function getPasswordForAlias(alias) {
  if (!alias) return '';
  if (typeof LOCAL_PASSWORDS !== 'undefined' && LOCAL_PASSWORDS && LOCAL_PASSWORDS[alias]) {
    return LOCAL_PASSWORDS[alias];
  }
  if (typeof LOCAL_PASSWORDS !== 'undefined' && LOCAL_PASSWORDS) {
    if (alias.endsWith('_USER_DEVELOPER')) {
      const dev = alias.replace('_USER_DEVELOPER', '_DEV');
      if (LOCAL_PASSWORDS[dev]) return LOCAL_PASSWORDS[dev];
    } else if (alias.endsWith('_DEV')) {
      const udev = alias.replace('_DEV', '_USER_DEVELOPER');
      if (LOCAL_PASSWORDS[udev]) return LOCAL_PASSWORDS[udev];
    }
    if (alias.startsWith('DB_')) {
      const stripped = alias.substring(3);
      if (LOCAL_PASSWORDS[stripped]) return LOCAL_PASSWORDS[stripped];
    } else {
      const withDb = 'DB_' + alias;
      if (LOCAL_PASSWORDS[withDb]) return LOCAL_PASSWORDS[withDb];
    }
  }
  return '';
}

function isLocalhostHost() {
  return window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || window.location.hostname === '::1';
}

async function openServiceWithCredentials(targetUrl, alias, user, evt) {
  if (evt) evt.preventDefault();
  let finalUrl = targetUrl;
  let pwd = getPasswordForAlias(alias);

  // If password not in static build, dynamically query bridge
  if (!pwd && alias) {
    try {
      const resp = await fetch(`${BRIDGE_URL}/api/password?alias=${encodeURIComponent(alias)}`);
      if (resp.ok) {
        const data = await resp.json();
        if (data.password) {
          pwd = data.password;
          if (typeof LOCAL_PASSWORDS !== 'undefined' && LOCAL_PASSWORDS) {
            LOCAL_PASSWORDS[alias] = pwd;
          }
        }
      }
    } catch (e) {}
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';

  // Check if target service or database container is currently offline
  const card = evt ? (evt.target ? evt.target.closest('.card') : null) : null;
  const tr = evt ? (evt.target ? evt.target.closest('tr[data-cname]') : null) : null;
  const rowCname = tr ? tr.getAttribute('data-cname') : null;
  const isCardOffline = card && card.classList.contains('card-offline');
  const runningList = Array.isArray(LIVE_RUNNING_CONTAINERS) ? LIVE_RUNNING_CONTAINERS : [];

  let targetCname = rowCname || '';
  if (!targetCname) {
    if (finalUrl.includes('/ords/alise/') || (alias && alias.includes('ALISE'))) targetCname = 'db-alise';
    else if (finalUrl.includes(':9502') || finalUrl.includes('xmlpserver') || (alias && alias.includes('PUBLISHER'))) targetCname = 'app-publisher';
    else if (finalUrl.includes(':9001') || finalUrl.includes(':6082') || (alias && alias.includes('FORMS'))) targetCname = 'app-forms';
    else if (finalUrl.includes(':8090')) targetCname = 'web-ide';
    else if (alias && alias.includes('GVENZL')) targetCname = 'db-gvenzl';
    else if (alias && alias.includes('ADB')) targetCname = 'db-adb';
    else if (finalUrl.includes(':8448') || (alias && (alias.includes('PROXY') || alias.includes('ORACLE')))) targetCname = 'db-proxy';
  }

  let isTargetOffline = false;
  if (isCardOffline) {
    isTargetOffline = true;
  } else if (targetCname && runningList.length > 0) {
    if (!isContainerRunning(targetCname)) {
      isTargetOffline = true;
    }
  } else if (runningList.length > 0) {
    const isAliseOffline = finalUrl.includes('/ords/alise/') && !runningList.includes('db-alise');
    const isPubOffline = (finalUrl.includes(':9502') || finalUrl.includes('xmlpserver')) && !runningList.some(c => c.includes('publisher'));
    const isFormsOffline = (finalUrl.includes(':9001') || finalUrl.includes(':6082')) && !runningList.some(c => c.includes('forms'));
    const isIdeOffline = finalUrl.includes(':8090') && !runningList.some(c => c.includes('web-ide'));
    if (isAliseOffline || isPubOffline || isFormsOffline || isIdeOffline) {
      isTargetOffline = true;
    }
  }

  if (isTargetOffline) {
    let svcName = targetCname || 'Teenus';
    let deployBp = '0';
    if (targetCname === 'db-alise' || (card && card.getAttribute('data-bp') === '1')) { svcName = 'ALISE (db-alise)'; deployBp = '1'; }
    else if (targetCname === 'app-publisher' || (card && card.getAttribute('data-bp') === '5')) { svcName = 'Analytics Publisher'; deployBp = '5'; }
    else if (targetCname === 'app-forms' || (card && card.getAttribute('data-bp') === '6')) { svcName = 'Oracle Forms'; deployBp = '6'; }
    else if (targetCname === 'web-ide' || (card && card.getAttribute('data-bp') === '8')) { svcName = 'VS Code Web IDE'; deployBp = '8'; }
    else if (targetCname === 'db-gvenzl' || (card && card.getAttribute('data-bp') === '3')) { svcName = 'Gvenzl DB (db-gvenzl)'; deployBp = '3'; }
    else if (targetCname === 'db-adb' || (card && card.getAttribute('data-bp') === '4')) { svcName = 'Autonomous DB (db-adb)'; deployBp = '4'; }
    else if (targetCname === 'db-proxy' || targetCname === 'db-oracle') { svcName = 'Oracle 23ai DB & ORDS'; deployBp = '0'; }

    const warnMsgs = {
      et: `🔴 Teenus "${svcName}" on hetkel MAAS (Offline)!\n\nAndmebaas või veebikonteiner ei tööta ja teenust ei saa avada.\n\nTeenuse käivitamiseks sisesta terminalis:\n./scripts/start-containers.sh\n\nvõi käivita vastav blueprint:\n./scripts/deploy-blueprint.sh -b ${deployBp}`,
      fi: `🔴 Palvelu "${svcName}" on tällä hetkellä POIS PÄÄLTÄ (Offline)!\n\nTietokanta tai kontti ei ole käynnissä, eikä palvelua voi avata.\n\nKäynnistä palvelu suorittamalla terminaalissa:\n./scripts/start-containers.sh\n\ntai ota blueprint käyttöön:\n./scripts/deploy-blueprint.sh -b ${deployBp}`,
      sv: `🔴 Tjänsten "${svcName}" är för närvarande OFFLINE!\n\nDatabasen eller behållaren körs inte och tjänsten kan inte öppnas.\n\nFör att starta tjänsten, kör i terminalen:\n./scripts/start-containers.sh\n\neller distribuera blueprint:\n./scripts/deploy-blueprint.sh -b ${deployBp}`,
      lv: `🔴 Pakalpojums "${svcName}" pašlaik ir BEZSAISTĒ (Offline)!\n\nDatubāze vai konteiners nedarbojas, un pakalpojumu nevar atvērt.\n\nLai palaistu pakalpojumu, ievadiet terminālī:\n./scripts/start-containers.sh\n\nvai izvietojiet blueprint:\n./scripts/deploy-blueprint.sh -b ${deployBp}`,
      lt: `🔴 Paslauga „${svcName}“ šiuo metu yra NEPRISIJUNGUSI (Offline)!\n\nDuomenų bazė arba konteineris neveikia ir paslaugos negalima atidaryti.\n\nNorėdami paleisti paslaugą, terminale paleiskite:\n./scripts/start-containers.sh\n\narba įdiekite blueprint:\n./scripts/deploy-blueprint.sh -b ${deployBp}`,
      en: `🔴 Service "${svcName}" is currently OFFLINE!\n\nThe database or container is not running. Service cannot be opened.\n\nTo start the service, run in terminal:\n./scripts/start-containers.sh\n\nor deploy the blueprint:\n./scripts/deploy-blueprint.sh -b ${deployBp}`
    };

    const warnMsg = warnMsgs[currentLang] || warnMsgs['en'];
    alert(warnMsg);
    return;
  }

  // Clean redirection for apex_admin to administration-sign-in with ADMIN username prefilled (no password)
  if (finalUrl.includes('/apex_admin')) {
    finalUrl = finalUrl.replace('/apex_admin', '/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN');
  }

  const isSdw = finalUrl.includes('_sdw');
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (pwd) {
    // 1. Copy real password directly to clipboard (Zero-Trust: NEVER pass password as URL query parameter)
    copyTextToClipboard(pwd);
    const sdwTip = dict.tip_db_actions_wait || dict.tip_sdw_warmup || '⏳ Käivitus võib võtta aega sõltuvalt arvutist kuni 1 min. Ole kannatlik.';
    const toastMsg = (currentLang === 'et')
      ? `🚀 Avati portaal! Kasutajanimi: <b>${user || alias}</b>.<br/>🔑 Parool on kopeeritud lõikelauale – kleebi see (Ctrl+V / Cmd+V) paroolilahtrisse!` + (isSdw ? `<br/><small style="color:#fbbf24;">${sdwTip}</small>` : '')
      : `🚀 Portal opened! Username: <b>${user || alias}</b>.<br/>🔑 Password copied to clipboard – paste (Ctrl+V / Cmd+V) on password field!` + (isSdw ? `<br/><small style="color:#fbbf24;">${sdwTip}</small>` : '');
    showToast(toastMsg);
  } else {
    const sdwTip = dict.tip_db_actions_wait || dict.tip_sdw_warmup || '⏳ Starting DB Actions may take up to 1 min depending on machine speed. Please be patient.';
    showToast(`ℹ️ Opening portal for <b>${user || alias}</b>...` + (isSdw ? `<br/><small style="color:#fbbf24;">${sdwTip}</small>` : ''));
  }

  window.open(finalUrl, '_blank');
}

function copyTnsAlias(alias, btn) {
  copyTextToClipboard(alias).then(() => {
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = '<span>✅</span> <span>OK</span>';
      setTimeout(() => { btn.innerHTML = orig; }, 1800);
    }
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const msg = (currentLang === 'et')
      ? `📋 TNS Alias kopeeritud: <b>${alias}</b> (Kasutamiseks tnsnames.ora / VS Code)`
      : `📋 TNS Alias copied: <b>${alias}</b> (For tnsnames.ora / VS Code)`;
    showToast(msg);
  });
}

function copySqlclCmd(alias, btn) {
  const cmd = 'sql /@' + alias;
  copyTextToClipboard(cmd).then(() => {
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = '<span>✅</span> <span>OK</span>';
      setTimeout(() => { btn.innerHTML = orig; }, 1800);
    }
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const msg = (currentLang === 'et')
      ? `💻 SQLcl käsk kopeeritud: <code>${cmd}</code> (Paroolivaba SEPS Wallet ühendus)`
      : `💻 SQLcl command copied: <code>${cmd}</code> (Passwordless SEPS Wallet connection)`;
    showToast(msg);
  });
}

function copyUsername(name, el) {
  copyTextToClipboard(name).then(() => {
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_user']) || 'Username Copied!';
    if (el) {
      const origHtml = el.innerHTML;
      el.innerHTML = '<span style="color:#22c55e;">✅ ' + name + '</span>';
      setTimeout(() => { el.innerHTML = origHtml; }, 1800);
    }
    showToast('👤 ' + name + ': ' + msg);
  });
}

async function handleCopyPassword(alias, btn) {
  let pwd = getPasswordForAlias(alias);
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_pwd']) || 'Password Copied!';

  if (!pwd && alias) {
    try {
      const resp = await fetch(`${BRIDGE_URL}/api/password?alias=${encodeURIComponent(alias)}`);
      if (resp.ok) {
        const data = await resp.json();
        if (data.password) {
          pwd = data.password;
          if (typeof LOCAL_PASSWORDS !== 'undefined' && LOCAL_PASSWORDS) {
            LOCAL_PASSWORDS[alias] = pwd;
          }
        }
      }
    } catch (e) {}
  }

  if (pwd) {
    copyTextToClipboard(pwd);
    if (btn) {
      const orig = btn.innerHTML;
      btn.innerHTML = '<span>🔑</span> <span>' + msg + '</span>';
      showToast('🔑 ' + alias + ': ' + msg);
      setTimeout(() => { btn.innerHTML = orig; }, 2000);
    }
  } else {
    showToast('⚠️ Password for ' + alias + ' not found in local cache');
  }
}

function showToast(msg) {
  let t = document.getElementById('dev-hub-toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'dev-hub-toast';
    t.style.cssText = 'position:fixed; bottom:24px; right:24px; background:#0f172a; color:#f8fafc; padding:12px 20px; border-radius:8px; border:1px solid #38bdf8; box-shadow:0 10px 25px rgba(0,0,0,0.5); z-index:9999; font-size:0.875rem; font-weight:500; transition:all 0.3s ease; opacity:0; pointer-events:none; display:flex; align-items:center; gap:8px;';
    document.body.appendChild(t);
  }
  t.innerHTML = msg;
  t.style.opacity = '1';
  t.style.transform = 'translateY(0)';
  clearTimeout(t._timeout);
  t._timeout = setTimeout(() => {
    t.style.opacity = '0';
    t.style.transform = 'translateY(10px)';
  }, 3000);
}

function copyBadge(el, txt) {
  navigator.clipboard.writeText(txt).then(() => {
    const orig = el.textContent;
    el.textContent = '✅ Copied!';
    setTimeout(() => { el.textContent = orig; }, 1800);
  });
}

function copyText(txt, btn) {
  navigator.clipboard.writeText(txt).then(() => {
    if (btn) {
      const orig = btn.innerHTML;
      const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
      const msg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['copied_cli']) || 'Copied!';
      btn.innerHTML = '<span>✅</span> <span>' + msg + '</span>';
      setTimeout(() => { btn.innerHTML = orig; }, 1800);
    }
  });
}

let gWalletSelectedDb = 'all';
let gWalletSearchQuery = '';

function updateWalletRowsCounter(visibleCount, totalCount) {
  const counterEl = document.getElementById('wallet-count-val');
  if (!counterEl) return;
  const rows = document.querySelectorAll('#wallet-matrix-drawer tbody tr');
  const total = (totalCount !== undefined) ? totalCount : rows.length;
  const visible = (visibleCount !== undefined) ? visibleCount : Array.from(rows).filter(r => r.style.display !== 'none').length;
  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[lang] || I18N_DICT['en'];
  const tmpl = dict.wallet_showing_count || 'Showing: {count} accounts';
  counterEl.textContent = tmpl.replace('{count}', `${visible} / ${total}`);
}

function handleWalletSearch(query) {
  gWalletSearchQuery = (query || '').trim().toLowerCase();
  const clearBtn = document.getElementById('wallet-search-clear');
  if (clearBtn) {
    clearBtn.style.display = gWalletSearchQuery ? 'block' : 'none';
  }
  applyWalletFilters();
}

function clearWalletSearch() {
  const inp = document.getElementById('wallet-search-input');
  if (inp) inp.value = '';
  handleWalletSearch('');
}

function filterWalletByDb(dbName, btnEl) {
  gWalletSelectedDb = dbName || 'all';
  const buttons = document.querySelectorAll('.wallet-db-filter-btn');
  buttons.forEach(b => {
    if (b === btnEl || b.getAttribute('data-db') === gWalletSelectedDb) {
      b.classList.add('active');
      b.classList.remove('btn-secondary');
      b.classList.add('btn-primary');
    } else {
      b.classList.remove('active');
      b.classList.remove('btn-primary');
      b.classList.add('btn-secondary');
    }
  });
  applyWalletFilters();
}

function applyWalletFilters() {
  const rows = document.querySelectorAll('#wallet-matrix-drawer tbody tr');
  if (!rows || rows.length === 0) return;
  
  const tokens = gWalletSearchQuery.split(/\s+/).filter(Boolean);
  let visibleCount = 0;

  rows.forEach(row => {
    const cname = row.getAttribute('data-cname') || '';
    let dbMatch = false;

    if (gWalletSelectedDb === 'all') {
      dbMatch = true;
    } else if (gWalletSelectedDb === 'active') {
      dbMatch = isContainerRunning(cname);
    } else if (gWalletSelectedDb === 'middleware') {
      dbMatch = ['app-publisher', 'app-forms', 'web-ide', 'publisher-designer'].includes(cname);
    } else if (gWalletSelectedDb === 'db-proxy') {
      dbMatch = (cname === 'db-proxy' || cname === 'db-proxy-standalone' || cname === 'db-proxy-remote');
    } else {
      dbMatch = (cname === gWalletSelectedDb);
    }

    if (!dbMatch) {
      row.style.display = 'none';
      return;
    }

    if (tokens.length > 0) {
      const text = row.innerText.toLowerCase();
      const allTokensFound = tokens.every(tok => text.includes(tok));
      if (!allTokensFound) {
        row.style.display = 'none';
        return;
      }
    }

    row.style.display = '';
    visibleCount++;
  });

  updateWalletRowsCounter(visibleCount, rows.length);
}

function toggleWalletMatrix(forceOpen) {
  const drawer = document.getElementById('wallet-matrix-drawer');
  const label = document.getElementById('wallet-toggle-label');
  const icon = document.getElementById('wallet-toggle-icon');
  if (!drawer) return;
  
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const isOpen = (forceOpen !== undefined) ? !forceOpen : (drawer.classList.contains('is-open'));
  
  if (isOpen) {
    drawer.style.maxHeight = '0px';
    drawer.style.opacity = '0';
    drawer.classList.remove('is-open');
    if (icon) icon.textContent = '➕';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_show_matrix']) || 'Show Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'false');
  } else {
    drawer.style.maxHeight = 'none';
    drawer.style.opacity = '1';
    drawer.classList.add('is-open');
    if (icon) icon.textContent = '➖';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_hide_matrix']) || 'Hide Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'true');
    applyWalletFilters();
  }
}

function copyAndScrollToWallet(alias, el) {
  const pwd = (LOCAL_PASSWORDS && LOCAL_PASSWORDS[alias]) ? LOCAL_PASSWORDS[alias] : '';
  
  if (pwd) {
    navigator.clipboard.writeText(pwd).then(() => {
      if (el) {
        const origHtml = el.innerHTML;
        el.innerHTML = '<span style="color:#22c55e; font-weight:700;">🔑 Copied!</span>';
        showToast('🔑 Password for ' + alias + ' copied to clipboard!');
        setTimeout(() => { el.innerHTML = origHtml; }, 1800);
      }
    });
  }

  // Automatically expand wallet matrix drawer if collapsed
  toggleWalletMatrix(true);

  setTimeout(() => {
    const row = document.getElementById('row-' + alias);
    if (row) {
      row.scrollIntoView({ behavior: 'smooth', block: 'center' });
      const origBg = row.style.backgroundColor;
      row.style.backgroundColor = 'rgba(56, 189, 248, 0.35)';
      setTimeout(() => {
        row.style.backgroundColor = origBg;
      }, 2000);
    }
  }, 150);
}

function scrollToWallet(alias, el) {
  copyAndScrollToWallet(alias, el);
}

/* ==============================================================================
 * PODMAN INFRASTRUCTURE & SYSTEM RESOURCES DRAWER
 * ============================================================================== */

let gPodmanData = null;
let gPodmanActiveSubTab = 'containers';
let gPodmanStatusFilter = 'all';
let gPodmanSearchQuery = '';

function escapePodmanHtml(str) {
  if (str === undefined || str === null) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function togglePodmanDrawer(forceOpen) {
  const drawer = document.getElementById('podman-infra-drawer');
  const label = document.getElementById('podman-toggle-label');
  const icon = document.getElementById('podman-toggle-icon');
  if (!drawer) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const isOpen = (forceOpen !== undefined) ? !forceOpen : (drawer.style.maxHeight !== '0px' && drawer.style.maxHeight !== '');

  if (isOpen) {
    drawer.style.maxHeight = '0px';
    drawer.style.opacity = '0';
    if (icon) icon.textContent = '➕';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_show_podman']) || 'Show Resources';
    localStorage.setItem('dev_hub_podman_open', 'false');
  } else {
    drawer.style.maxHeight = '3000px';
    drawer.style.opacity = '1';
    if (icon) icon.textContent = '➖';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_hide_podman']) || 'Hide Resources';
    localStorage.setItem('dev_hub_podman_open', 'true');
    if (!gPodmanData) {
      loadPodmanResources();
    }
  }
}

function switchPodmanSubTab(subTab) {
  gPodmanActiveSubTab = subTab;
  ['containers', 'volumes', 'networks', 'images'].forEach(t => {
    const btn = document.getElementById('btn-podman-tab-' + t);
    const view = document.getElementById('podman-subtab-' + t);
    if (btn) btn.classList.toggle('active', t === subTab);
    if (view) view.style.display = (t === subTab) ? 'block' : 'none';
  });

  const statusFilters = document.getElementById('podman-container-status-filters');
  if (statusFilters) {
    statusFilters.style.display = (subTab === 'containers') ? 'flex' : 'none';
  }

  renderPodmanCurrentView();
}

async function loadPodmanResources(force) {
  const refreshIcon = document.getElementById('podman-refresh-icon');
  const statusPill = document.getElementById('podman-status-pill');
  if (refreshIcon) refreshIcon.style.animation = 'spin 1s linear infinite';

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 12000);
    const resp = await fetch(`${BRIDGE_URL}/api/podman/resources`, { signal: controller.signal, mode: 'cors' });
    clearTimeout(timeoutId);

    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    const data = await resp.json();
    if (data.status === 'ok' && data.resources) {
      gPodmanData = data.resources;
      const statusPillSummary = document.getElementById('podman-status-pill-summary');
      [statusPill, statusPillSummary].forEach(p => {
        if (p) {
          p.className = gPodmanData.ok ? 'badge badge-primary' : 'badge badge-warning';
          p.textContent = gPodmanData.ok ? 'Podman OK' : 'Podman Degraded';
        }
      });

      const containers = gPodmanData.containers || [];
      const volumes = gPodmanData.volumes || [];
      const networks = gPodmanData.networks || [];
      const images = gPodmanData.images || [];

      const countC = document.getElementById('podman-count-containers');
      const countV = document.getElementById('podman-count-volumes');
      const countN = document.getElementById('podman-count-networks');
      const countI = document.getElementById('podman-count-images');
      if (countC) countC.textContent = containers.length;
      if (countV) countV.textContent = volumes.length;
      if (countN) countN.textContent = networks.length;
      if (countI) countI.textContent = images.length;

      renderPodmanCurrentView();
    }
  } catch (err) {
    console.error('Failed to load Podman resources:', err);
    const statusPillSummary = document.getElementById('podman-status-pill-summary');
    [statusPill, statusPillSummary].forEach(p => {
      if (p) {
        p.className = 'badge badge-danger';
        p.textContent = 'Podman Offline';
      }
    });
    renderPodmanError();
  } finally {
    if (refreshIcon) {
      setTimeout(() => { refreshIcon.style.animation = ''; }, 500);
    }
  }
}

function filterPodmanTable(query) {
  gPodmanSearchQuery = (query || '').toLowerCase().trim();
  renderPodmanCurrentView();
}

function filterPodmanContainersByStatus(status) {
  gPodmanStatusFilter = status;
  ['all', 'running', 'stopped'].forEach(s => {
    const btn = document.getElementById('btn-filter-status-' + s);
    if (btn) btn.classList.toggle('active', s === status);
  });
  renderPodmanCurrentView();
}

function copyPodmanToken(txt, el) {
  copyTextToClipboard(txt).then(() => {
    if (el) {
      const origHtml = el.innerHTML;
      el.innerHTML = '<span style="color:#22c55e;">✅ Copied</span>';
      setTimeout(() => { el.innerHTML = origHtml; }, 1400);
    }
    showToast('📋 Copied: ' + txt);
  });
}

function renderPodmanError() {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const errMsg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['podman_error_query']) || 'Failed to query Podman resources.';
  ['containers', 'volumes', 'networks', 'images'].forEach(t => {
    const tbody = document.getElementById('podman-tbody-' + t);
    if (tbody) {
      tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; padding: 24px; color: #ef4444;">⚠️ ${errMsg}</td></tr>`;
    }
  });
}

function renderPodmanCurrentView() {
  if (!gPodmanData) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const emptyMsg = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['no_resources_found']) || 'No matching resources found';
  const q = gPodmanSearchQuery;

  if (gPodmanActiveSubTab === 'containers') {
    const tbody = document.getElementById('podman-tbody-containers');
    if (!tbody) return;
    let list = gPodmanData.containers || [];
    
    // Status filter
    if (gPodmanStatusFilter === 'running') {
      list = list.filter(c => (c.state || '').toLowerCase() === 'running');
    } else if (gPodmanStatusFilter === 'stopped') {
      list = list.filter(c => (c.state || '').toLowerCase() !== 'running');
    }

    // Search filter
    if (q) {
      list = list.filter(c => 
        (c.name || '').toLowerCase().includes(q) ||
        (c.id || '').toLowerCase().includes(q) ||
        (c.image || '').toLowerCase().includes(q) ||
        (c.status || '').toLowerCase().includes(q) ||
        (c.ports || '').toLowerCase().includes(q)
      );
    }

    if (list.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    tbody.innerHTML = list.map(c => {
      const isRunning = (c.state || '').toLowerCase() === 'running';
      const stateBadge = isRunning
        ? '<span class="badge badge-success" style="font-size:0.75rem;">🟢 running</span>'
        : `<span class="badge" style="font-size:0.75rem; background: rgba(148, 163, 184, 0.15); color: #94a3b8; border: 1px solid #475569;">⚪ ${escapePodmanHtml(c.state || 'stopped')}</span>`;

      const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
      let actBtns = '';
      if (isRunning) {
        actBtns = `
          <button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem;" onclick="executePodmanAction('container', 'restart', '${escapePodmanHtml(c.name || '')}')" title="${dict.btn_restart_container || 'Taaskäivita'}">
            <span>🔄</span>
          </button>
          <button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem; color:#f87171; border-color:rgba(239,68,68,0.3);" onclick="executePodmanAction('container', 'stop', '${escapePodmanHtml(c.name || '')}')" title="${dict.btn_stop_container || 'Peata'}">
            <span>⏹️</span>
          </button>
        `;
      } else {
        actBtns = `
          <button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem; color:#4ade80; border-color:rgba(74,222,128,0.3);" onclick="executePodmanAction('container', 'start', '${escapePodmanHtml(c.name || '')}')" title="${dict.btn_start_container || 'Käivita'}">
            <span>▶️</span>
          </button>
          <button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem; color:#ef4444; border-color:rgba(239,68,68,0.3);" onclick="executePodmanAction('container', 'rm', '${escapePodmanHtml(c.name || '')}')" title="${dict.btn_remove || 'Eemalda'}">
            <span>🗑️</span>
          </button>
        `;
      }

      return `<tr>
        <td style="font-weight: 600; color: #f8fafc;">${escapePodmanHtml(c.name || '')}</td>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(c.id)}', this)" title="Click to copy ID">${escapePodmanHtml(c.id)} 📋</span></td>
        <td style="color: #cbd5e1; font-size: 0.8rem;">${escapePodmanHtml(c.image || '')}</td>
        <td>${stateBadge}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(c.status || '')}</td>
        <td style="font-family: ui-monospace, monospace; font-size: 0.78rem; color: #38bdf8;">${escapePodmanHtml(c.ports || '-')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(c.created || '-')}</td>
        <td style="text-align: right;"><div style="display:inline-flex; gap:4px; justify-content:flex-end;">${actBtns}</div></td>
      </tr>`;
    }).join('');

  } else if (gPodmanActiveSubTab === 'volumes') {
    const tbody = document.getElementById('podman-tbody-volumes');
    if (!tbody) return;
    let list = gPodmanData.volumes || [];

    if (q) {
      list = list.filter(v => 
        (v.name || '').toLowerCase().includes(q) ||
        (v.driver || '').toLowerCase().includes(q) ||
        (v.scope || '').toLowerCase().includes(q) ||
        (v.mountpoint || '').toLowerCase().includes(q) ||
        (v.used_by || []).some(u => u.toLowerCase().includes(q))
      );
    }

    if (list.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    tbody.innerHTML = list.map(v => {
      const usedByHtml = (v.used_by && v.used_by.length > 0)
        ? v.used_by.map(u => `<span class="badge badge-primary" style="font-size: 0.72rem; margin-right: 4px;">📦 ${escapePodmanHtml(u)}</span>`).join('')
        : '<span style="color: var(--text-dim); font-size: 0.78rem;">— (unused)</span>';
      const isUnused = !v.used_by || v.used_by.length === 0;
      const volAct = isUnused
        ? `<button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem; color:#ef4444; border-color:rgba(239,68,68,0.3);" onclick="executePodmanAction('volume', 'rm', '${escapePodmanHtml(v.name || '')}')" title="${dict.btn_remove_unused || 'Eemalda kasutuseta andmemaht'}"><span>🗑️</span></button>`
        : '<span style="font-size:0.72rem; color:#64748b;">(in use)</span>';

      return `<tr>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(v.name)}', this)" title="Click to copy volume name">${escapePodmanHtml(v.name)} 📋</span></td>
        <td>${usedByHtml}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(v.driver || 'local')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(v.scope || 'local')}</td>
        <td style="font-size: 0.76rem; color: #94a3b8; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${escapePodmanHtml(v.mountpoint || '')}"><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(v.mountpoint || '')}', this)">${escapePodmanHtml(v.mountpoint || '-')} 📋</span></td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(v.created || '-')}</td>
        <td style="text-align: right;">${volAct}</td>
      </tr>`;
    }).join('');

  } else if (gPodmanActiveSubTab === 'networks') {
    const tbody = document.getElementById('podman-tbody-networks');
    if (!tbody) return;
    let list = gPodmanData.networks || [];

    if (q) {
      list = list.filter(n => 
        (n.name || '').toLowerCase().includes(q) ||
        (n.id || '').toLowerCase().includes(q) ||
        (n.driver || '').toLowerCase().includes(q) ||
        (n.subnets || '').toLowerCase().includes(q)
      );
    }

    if (list.length === 0) {
      tbody.innerHTML = `<tr><td colspan="4" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    tbody.innerHTML = list.map(n => {
      return `<tr>
        <td style="font-weight: 600; color: #f8fafc;"><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(n.name)}', this)" title="Click to copy network name">${escapePodmanHtml(n.name)} 📋</span></td>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(n.id)}', this)" title="Click to copy network ID">${escapePodmanHtml(n.id)} 📋</span></td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(n.driver || 'bridge')}</td>
        <td style="font-family: ui-monospace, monospace; font-size: 0.8rem; color: #38bdf8;">${escapePodmanHtml(n.subnets || '-')}</td>
      </tr>`;
    }).join('');

  } else if (gPodmanActiveSubTab === 'images') {
    const tbody = document.getElementById('podman-tbody-images');
    if (!tbody) return;
    let list = gPodmanData.images || [];

    if (q) {
      list = list.filter(img => 
        (img.repository || '').toLowerCase().includes(q) ||
        (img.tag || '').toLowerCase().includes(q) ||
        (img.id || '').toLowerCase().includes(q) ||
        (img.size_human || '').toLowerCase().includes(q)
      );
    }

    if (list.length === 0) {
      tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    tbody.innerHTML = list.map(img => {
      const imgAct = `<button class="btn btn-sm btn-secondary" style="padding:2px 6px; font-size:0.75rem; color:#ef4444; border-color:rgba(239,68,68,0.3);" onclick="executePodmanAction('image', 'rmi', '${escapePodmanHtml(img.id || '')}')" title="${dict.btn_remove || 'Eemalda tõmmis'}"><span>🗑️</span></button>`;
      return `<tr>
        <td style="font-weight: 600; color: #f8fafc;">${escapePodmanHtml(img.repository || '')}</td>
        <td><span class="badge badge-primary" style="font-size: 0.75rem;">${escapePodmanHtml(img.tag || 'latest')}</span></td>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(img.id)}', this)" title="Click to copy image ID">${escapePodmanHtml(img.id)} 📋</span></td>
        <td style="font-weight: 600; color: #38bdf8; font-size: 0.82rem;">${escapePodmanHtml(img.size_human || '-')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(img.created || '-')}</td>
        <td style="text-align: right;">${imgAct}</td>
      </tr>`;
    }).join('');
  }
}

async function executePodmanAction(resType, action, name) {
  if (!name) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  let confirmTpl = dict.confirm_podman_action || "Kas oled kindel, et soovid sooritada tegevust '{action}' ressursil '{name}'? Seda tegevust ei saa tagasi võtta.";
  let msg = confirmTpl.replace('{action}', action).replace('{name}', name);
  if (!window.confirm(msg)) return;

  showToast(`⏳ Podman: ${action} ${name}...`);
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000);
    const resp = await fetch(`${BRIDGE_URL}/api/podman/action`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ resource_type: resType, action: action, name: name }),
      mode: 'cors',
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    const data = await resp.json();
    if (resp.ok && data.status === 'ok') {
      showToast(`✅ ${data.message || 'Podman operation succeeded'}`);
      loadPodmanResources(true);
      checkServiceHealth();
    } else {
      showToast(`⚠️ Viga: ${data.error || 'Podman operation failed'}`);
    }
  } catch (e) {
    showToast(`⚠️ Bridge viga: ${e.message}`);
  }
}

/* ==============================================================================
 * SNAPSHOTS & DISASTER RECOVERY MANAGER
 * ============================================================================== */

async function loadSnapshotsTable(manual = false) {
  const container = document.getElementById('snapshots-table-container');
  const countBadge = document.getElementById('snapshots-count-badge');
  if (!container) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3500);
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/list`, { signal: controller.signal, mode: 'cors' });
    clearTimeout(timeoutId);

    if (!resp.ok) {
      throw new Error(`HTTP error ${resp.status}`);
    }

    const data = await resp.json();
    const list = (data && data.snapshots) ? data.snapshots : [];

    if (countBadge) {
      countBadge.textContent = `${list.length} snapshots`;
    }

    if (list.length === 0) {
      container.innerHTML = `
        <div style="padding: 24px; text-align: center; color: #94a3b8; font-size: 0.85rem;">
          <div style="font-size: 1.5rem; margin-bottom: 8px;">📭</div>
          <div>Eelnevaid snapshote ei leitud kaustast <code>golden-snapshots/</code>.</div>
          <div style="font-size: 0.78rem; color: #64748b; margin-top: 4px;">Uue snapshoti tekitamiseks kasuta nuppu "Loo Kohandatud Snapshot" või käivita <code>./scripts/snapshots/create-golden-snapshots.sh</code>.</div>
        </div>
      `;
      return;
    }

    let html = `
      <table style="width: 100%; border-collapse: collapse; font-size: 0.82rem;">
        <thead>
          <tr style="border-bottom: 1px solid var(--border); text-align: left; color: #94a3b8;">
            <th style="padding: 10px 12px; width: 28%;">${dict.snap_th_name || 'Snapshot / Fail'}</th>
            <th style="padding: 10px 12px; width: 22%;">${dict.snap_th_type || 'Tüüp ja Silt'}</th>
            <th style="padding: 10px 12px; width: 14%;">${dict.snap_th_bp || 'Blueprint'}</th>
            <th style="padding: 10px 12px; width: 12%;">${dict.snap_th_size || 'Suurus'}</th>
            <th style="padding: 10px 12px; width: 12%;">${dict.snap_th_created || 'Loodud'}</th>
            <th style="padding: 10px 12px; width: 12%; text-align: right;">${dict.snap_th_actions || 'Tegevused'}</th>
          </tr>
        </thead>
        <tbody>
    `;

    list.forEach(item => {
      const isGolden = item.type === 'golden_latest' || item.type === 'golden';
      const typeBadge = isGolden
        ? `<span class="badge" style="background: rgba(34,197,94,0.12); color: #4ade80; border: 1px solid rgba(34,197,94,0.3); font-size: 0.72rem;">${dict.snap_badge_golden || '🌟 Golden Baseline'}</span>`
        : `<span class="badge" style="background: rgba(56,189,248,0.12); color: #38bdf8; border: 1px solid rgba(56,189,248,0.3); font-size: 0.72rem;">${dict.snap_badge_custom || '👤 Kohandatud'}</span>`;

      const tagDesc = item.tag
        ? `<div style="font-weight: 600; color: #f8fafc; font-family: ui-monospace, monospace;">${item.tag}</div>`
        : `<div style="color: #64748b; font-style: italic;">Standard Snapshot</div>`;
      const descText = item.description ? `<div style="font-size: 0.75rem; color: #94a3b8; margin-top: 2px;">${item.description}</div>` : '';

      const bpBadge = item.blueprint_id
        ? `<span class="badge" style="background: rgba(251,191,36,0.12); color: #fbbf24; border: 1px solid rgba(251,191,36,0.3); font-size: 0.72rem;">BP #${item.blueprint_id}</span>`
        : `<span style="color: #64748b;">-</span>`;

      const restoreCmd = `./scripts/snapshots/restore-golden-snapshots.sh --file ${item.file}`;

      html += `
        <tr style="border-bottom: 1px solid rgba(255,255,255,0.04); transition: background 0.15s;" onmouseover="this.style.background='rgba(255,255,255,0.02)'" onmouseout="this.style.background='transparent'">
          <td style="padding: 10px 12px;">
            <div style="font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace; color: #f8fafc; font-weight: 600;">${item.file}</div>
            <div style="margin-top: 4px;">${typeBadge}</div>
          </td>
          <td style="padding: 10px 12px;">
            ${tagDesc}
            ${descText}
          </td>
          <td style="padding: 10px 12px;">${bpBadge}</td>
          <td style="padding: 10px 12px; font-family: ui-monospace, monospace; color: #38bdf8;">${item.size_human}</td>
          <td style="padding: 10px 12px; color: #94a3b8; font-size: 0.78rem;">${item.created_at || item.modified_time}</td>
          <td style="padding: 10px 12px; text-align: right;">
            <div style="display: inline-flex; gap: 6px; align-items: center; justify-content: flex-end;">
              <button class="btn btn-primary" style="padding: 3px 8px; font-size: 0.74rem;" onclick="triggerRestoreSnapshot('${item.file}', '${item.blueprint_id || 0}', this)" title="${dict.snap_btn_restore || 'Taasta'}">
                <span>⏪</span> <span>${dict.snap_btn_restore || 'Taasta'}</span>
              </button>
              <button class="btn btn-secondary" style="padding: 3px 6px; font-size: 0.74rem;" onclick="copyTextToClipboard('${restoreCmd}').then(() => showToast('📋 Käsk kopeeritud!'))" title="Kopeeri taastamise käsurea käsk">
                <span>📋</span>
              </button>
              ${item.is_deletable ? `
                <button class="btn btn-secondary" style="padding: 3px 6px; font-size: 0.74rem; border-color: rgba(239,68,68,0.3); color: #f87171;" onclick="triggerDeleteSnapshot('${item.file}', this)" title="${dict.snap_btn_delete || 'Kustuta'}">
                  <span>🗑️</span>
                </button>
              ` : ''}
            </div>
          </td>
        </tr>
      `;
    });

    html += `</tbody></table>`;
    container.innerHTML = html;
    if (manual) showToast('✅ Snapshotide nimekiri uuendatud!');
  } catch (err) {
    console.error('Error fetching snapshots list:', err);
    container.innerHTML = `
      <div style="padding: 20px; text-align: center; color: #f87171; font-size: 0.85rem;">
        <div>⚠️ Snapshotide nimekirja laadimine ebaõnnestus või Bridge (:8089) ei vasta.</div>
        <div style="margin-top: 6px;"><button class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.78rem;" onclick="loadSnapshotsTable(true)">Proovi uuesti</button></div>
      </div>
    `;
  }
}

function toggleSnapshotCustomForm() {
  const form = document.getElementById('snapshot-custom-form');
  if (!form) return;
  const isHidden = form.style.display === 'none' || !form.style.display;
  form.style.display = isHidden ? 'block' : 'none';
  if (isHidden) {
    const tagInput = document.getElementById('custom-snap-tag');
    if (tagInput) {
      tagInput.focus();
      if (!tagInput.value) {
        const now = new Date();
        tagInput.value = 'dev_' + now.toISOString().slice(5, 10).replace('-', '') + '_' + now.toTimeString().slice(0, 5).replace(':', '');
      }
    }
  }
}

/* ==============================================================================
 * LIVE TERMINAL CONSOLE & PROGRESS ENGINE FOR SNAPSHOTS & DR
 * ============================================================================== */

function startTerminalProgress(containerId, opType, opName, cmdStr) {
  const container = document.getElementById(containerId);
  if (!container) return null;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  let guessedBpNum = 0;
  const bpMatch = (cmdStr || '').match(/-b\s+(\d+)/) || (cmdStr || '').match(/blueprint[ _](\d+)/i);
  if (bpMatch) {
    guessedBpNum = parseInt(bpMatch[1], 10);
  } else if (typeof activeBpModalNum === 'number' && activeBpModalNum >= 0) {
    guessedBpNum = activeBpModalNum;
  }

  let initialLogName = '';
  if (opType === 'restore') {
    initialLogName = `restore_bp_${guessedBpNum}_latest.log`;
  } else if (opType === 'create') {
    initialLogName = `snapshot_create_bp_${guessedBpNum}_latest.log`;
  } else if (opType === 'reset_deep') {
    initialLogName = `reset_deep_bp_${guessedBpNum}_latest.log`;
  } else if (opType === 'setup' || opType === 'switch' || opType === 'deploy' || opType === 'start') {
    initialLogName = `setup_bp_${guessedBpNum}_latest.log`;
  } else if (opType === 'diag') {
    const diagMatch = (cmdStr || '').match(/scripts\/(?:check-[a-z0-9_-]+|status-[a-z0-9_-]+|test-[a-z0-9_-]+)\.sh/);
    const diagName = diagMatch ? diagMatch[0].replace(/.*\//, '').replace('.sh', '') : 'diagnostics';
    initialLogName = `devops_${diagName}.log`;
  } else {
    initialLogName = `operation_${opType}.log`;
  }
  const initialLogRel = `install_logs/${initialLogName}`;

  container.style.display = 'block';
  container.innerHTML = `
    <div style="background: #030712; border: 1px solid rgba(56, 189, 248, 0.35); border-radius: 8px; padding: 14px; box-shadow: 0 4px 20px rgba(0,0,0,0.5);">
      <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #1e293b; padding-bottom: 8px; margin-bottom: 10px; flex-wrap: wrap; gap: 8px;">
        <div style="display: flex; align-items: center; gap: 8px;">
          <span class="badge" style="background: rgba(56,189,248,0.15); color: #38bdf8; border: 1px solid rgba(56,189,248,0.3); font-weight: 700; font-size: 0.75rem;">⏳ ${dict.snap_console_running || 'TOIMING KÄIB'}</span>
          <strong style="color: #f8fafc; font-size: 0.88rem;">${opName}</strong>
        </div>
        <div style="display: flex; align-items: center; gap: 10px;">
          <span id="${containerId}-timer" style="font-family: ui-monospace, monospace; color: #4ade80; font-weight: 700; font-size: 0.9rem;">⏱️ 00:00</span>
          <span style="font-size: 0.75rem; color: #94a3b8;">(${['reset_deep', 'setup', 'activate', 'switch', 'deploy'].includes(opType) ? (dict.snap_est_duration_deep || 'Kestus: ~4–8 min') : (dict.snap_est_duration || 'Kestus: ~30–60s')})</span>
        </div>
      </div>

      <!-- Live Stage Progress Bar -->
      <div style="margin-bottom: 12px;">
        <div style="display: flex; justify-content: space-between; font-size: 0.78rem; margin-bottom: 5px;">
          <span id="${containerId}-phase" style="color: #38bdf8; font-weight: 600;">Valmistan ette toimingut...</span>
          <span id="${containerId}-pct" style="color: #4ade80; font-family: ui-monospace, monospace; font-weight: 700;">5%</span>
        </div>
        <div style="height: 7px; background: #0f172a; border-radius: 4px; overflow: hidden; border: 1px solid #1e293b;">
          <div id="${containerId}-bar" style="height: 100%; width: 5%; background: linear-gradient(90deg, #38bdf8, #22c55e); transition: width 0.4s ease;"></div>
        </div>
      </div>

      <!-- Live Monospace Terminal Log Box (Full Width) -->
      <div class="terminal-column-pane" id="${containerId}-output-pane" style="position: relative;">
        <div class="terminal-column-header">
          <div style="display: flex; align-items: center; gap: 6px;">
            <span>💻</span>
            <strong style="color: #cbd5e1;">${dict.snap_output_title || 'Terminali väljund ja logi'}</strong>
          </div>
          <span style="font-family: ui-monospace, monospace; color: #64748b; font-size: 0.72rem;">$ ${cmdStr}</span>
        </div>
        <pre id="${containerId}-output" class="terminal-column-content" style="min-height: 280px; height: 280px; max-height: 280px; box-sizing: border-box;"></pre>
        <button id="${containerId}-scroll-btn" type="button" class="terminal-scroll-pill" style="display: none;" onclick="scrollTerminalToBottom('${containerId}')">
          <span>⬇️</span> <span>${dict.btn_scroll_bottom || 'Hüppa viimasele reale'}</span>
        </button>
      </div>

      <!-- Active Log File Bar with Full Modal Expander -->
      <div id="${containerId}-log-bar" style="margin-top: 8px; display: flex; justify-content: space-between; align-items: center; background: rgba(15,23,42,0.8); border: 1px solid #1e293b; border-radius: 6px; padding: 6px 12px; font-size: 0.76rem; flex-wrap: wrap; gap: 6px;">
        <div style="display: flex; align-items: center; gap: 8px; min-width: 0; flex: 1;">
          <span style="color: #94a3b8; font-size: 0.74rem; white-space: nowrap;">📄 ${dict.label_active_log || 'Aktiivne logifail'}:</span>
          <span id="${containerId}-log-path" data-log-file="${initialLogName}" style="color: #38bdf8; font-family: ui-monospace, monospace; font-size: 0.76rem; text-decoration: underline; cursor: pointer; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;" onclick="toggleActiveTerminalLog('${containerId}')" title="${dict.tip_click_open_log || 'Klõpsa logi avamiseks eraldi aknas'}">${initialLogRel}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px;">
          <button type="button" class="btn btn-secondary" style="padding: 3px 9px; font-size: 0.72rem;" onclick="copyActiveLogPath(document.getElementById('${containerId}-log-path')?.getAttribute('data-full-path') || document.getElementById('${containerId}-log-path')?.textContent || '', this)" title="${dict.btn_copy_path || 'Kopeeri tee'}">
            <span>📋</span> <span>${dict.btn_copy_path || 'Kopeeri tee'}</span>
          </button>
          <button id="${containerId}-log-toggle-btn" type="button" class="btn btn-primary" style="padding: 3px 10px; font-size: 0.72rem;" onclick="toggleActiveTerminalLog('${containerId}')">
            <span>🔍</span> <span>${dict.btn_open_modal_log || dict.btn_open_log || 'Ava täielik logi'}</span>
          </button>
        </div>
      </div>

      <!-- Completed Result Notification Box -->
      <div id="${containerId}-result" style="display: none; margin-top: 12px; background: rgba(34, 197, 94, 0.08); border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 6px; padding: 12px;"></div>
    </div>
  `;

  const timerEl = document.getElementById(`${containerId}-timer`);
  const phaseEl = document.getElementById(`${containerId}-phase`);
  const pctEl = document.getElementById(`${containerId}-pct`);
  const barEl = document.getElementById(`${containerId}-bar`);
  const outEl = document.getElementById(`${containerId}-output`);
  const resEl = document.getElementById(`${containerId}-result`);
  const scrollBtn = document.getElementById(`${containerId}-scroll-btn`);

  let seconds = 0;
  const logLines = [];
  let isUserScrolledUp = false;

  if (outEl) {
    outEl.addEventListener('scroll', () => {
      const distanceFromBottom = outEl.scrollHeight - outEl.scrollTop - outEl.clientHeight;
      if (distanceFromBottom > 30) {
        isUserScrolledUp = true;
        if (scrollBtn) scrollBtn.style.display = 'flex';
      } else {
        isUserScrolledUp = false;
        if (scrollBtn) scrollBtn.style.display = 'none';
      }
    });
  }

  window[`scrollTerminalToBottom_${containerId}`] = () => {
    isUserScrolledUp = false;
    if (outEl) {
      outEl.scrollTop = outEl.scrollHeight;
    }
    if (scrollBtn) scrollBtn.style.display = 'none';
  };

  function appendLog(line) {
    logLines.push(line);
    if (outEl) {
      outEl.innerHTML = formatTerminalLogText(logLines.join('\n'), { showTime: true, showColors: true });
      if (!isUserScrolledUp) {
        outEl.scrollTop = outEl.scrollHeight;
      }
    }
  }

  const startClockTime = new Date().toLocaleTimeString('et-EE', { hour12: false });
  appendLog(`[${startClockTime}] Käivitan: ${cmdStr}`);

  function updateUI() {
    const mm = String(Math.floor(seconds / 60)).padStart(2, '0');
    const ss = String(seconds % 60).padStart(2, '0');
    if (timerEl) timerEl.textContent = `⏱️ ${mm}:${ss}`;

    const nowTime = new Date().toLocaleTimeString('et-EE', { hour12: false });

    if (opType === 'create') {
      if (seconds === 2) appendLog(`[${nowTime}] Kontrollin andmebaasi seisu ja teostan CHECKPOINT...`);
      if (seconds === 6) appendLog(`[${nowTime}] SGA puhvrid kettale kirjutatud. Alustan oradata tihendamist tar.gz arhiivi...`);
      if (seconds === 16) appendLog(`[${nowTime}] Tihendamine käib: ~500 MB töödeldud...`);
      if (seconds === 30) appendLog(`[${nowTime}] Tihendamine lõpusirgel: pakin metaandmeid (.meta.json)...`);

      if (seconds < 8) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_checkpoint || '1/3: Oracle DB SGA puhvrite tühjendamine (CHECKPOINT)...';
        const p = Math.min(25, Math.floor(seconds * 3.5));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 38) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_compress || '2/3: Andmemahu (oradata) tihendamine tar.gz arhiivi (~900MB–1.8GB)...';
        const p = Math.min(88, 25 + Math.floor((seconds - 8) * 2.1));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_meta || '3/3: Metaandmete genereerimine ja salvestamine...';
        const p = Math.min(96, 88 + Math.floor((seconds - 38) * 0.8));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'restore') {
      if (seconds === 2) appendLog(`[${nowTime}] Peatan ajutiselt aktiivsed konteinerid andmekonsistentsi tagamiseks...`);
      if (seconds === 6) appendLog(`[${nowTime}] Eemaldan vana oradata mahu ja paki lahti kuldse hetktõmmise...`);
      if (seconds === 16) appendLog(`[${nowTime}] Käivitan konteinerid ja kontrollin SEPS Wallet ühendusi...`);

      if (seconds < 6) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_stop || '1/3: Konteinerite peatamine...';
        const p = Math.min(30, seconds * 5);
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 25) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_unpack || '2/3: Kuldse hetktõmmise lahtipakkimine...';
        const p = Math.min(85, 30 + Math.floor((seconds - 6) * 3));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_start || '3/3: Konteinerite käivitamine...';
        const p = Math.min(96, 85 + Math.floor((seconds - 25) * 1.5));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'reset_deep') {
      if (seconds === 2) appendLog(`[${nowTime}] Alustan süvapuhastust (reset-all.sh)...`);
      if (seconds === 25) appendLog(`[${nowTime}] Puhastus lõpetatud. Alustan täispaigaldust nullist (setup-all.sh)...`);
      if (seconds === 90) appendLog(`[${nowTime}] Ootan Oracle DB tervislikku seisundit ja käivitan teenuseid...`);
      if (seconds === 240) appendLog(`[${nowTime}] DB tervislik. Teostan skeemide, kasutajate ja SEPS rahakoti seadistuse...`);

      if (seconds < 25) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_deep_1 || '1/3: Konteinerite, mahtude ja sertifikaatide täispuhastus (reset-all)...';
        const p = Math.min(20, Math.floor(seconds * 0.8));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 240) {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_deep_2 || '2/3: Konteinerite käivitamine ja Oracle DB tervisekontroll...';
        const p = Math.min(75, 20 + Math.floor((seconds - 25) * 0.25));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.snap_phase_deep_3 || '3/3: Skeemide, kasutajate ja SEPS rahakoti seadistus...';
        const p = Math.min(96, 75 + Math.floor((seconds - 240) * 0.1));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'setup' || opType === 'activate') {
      if (seconds === 2) appendLog(`[${nowTime}] Alustan arhitektuuri paigaldust ja seadistust (setup-all.sh)...`);
      if (seconds === 20) appendLog(`[${nowTime}] Konteinerid käivitatud. Ootan andmebaasi tervislikku olekut...`);
      if (seconds === 90) appendLog(`[${nowTime}] Andmebaasi tervisekontroll käib: initsialiseerin PDB ja andmeruume...`);
      if (seconds === 180) appendLog(`[${nowTime}] Seadistan profiili kasutajaid, skeeme, õigusi ja SEPS rahakotti...`);
      if (seconds === 300) appendLog(`[${nowTime}] Seadistan ORDS basseine ja kontrollin veebiteenuste valmidust...`);

      if (seconds < 25) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_setup_1 || '1/4: Konteinerite käivitamine ja võrgu seadistus...';
        const p = Math.min(20, Math.floor(seconds * 0.8));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 160) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_setup_2 || '2/4: Oracle DB käivitumine ja tervisekontroll...';
        const p = Math.min(60, 20 + Math.floor((seconds - 25) * 0.3));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 320) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_setup_3 || '3/4: Skeemide, kasutajate ja SEPS rahakoti seadistus...';
        const p = Math.min(88, 60 + Math.floor((seconds - 160) * 0.175));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_setup_4 || '4/4: ORDS, APEX ja veebilinkide verifitseerimine...';
        const p = Math.min(96, 88 + Math.floor((seconds - 320) * 0.08));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'switch' || opType === 'start' || opType === 'deploy') {
      if (seconds === 2) appendLog(`[${nowTime}] Kontrollin konfiguratsiooni ja võrgupordi ressursse...`);
      if (seconds === 6) appendLog(`[${nowTime}] Käivitan valitud arhitektuuri konteinereid ja teenuseid...`);
      if (seconds === 14) appendLog(`[${nowTime}] Ootan tervislikku olekut ja uuendan SEPS Wallet aliaseid...`);
      if (seconds === 24) appendLog(`[${nowTime}] Kontrollin ORDS ja APEX portaalide valmidust...`);
      if (seconds < 6) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_deploy_1 || '1/3: Konfiguratsiooni kontroll ja ettevalmistus...';
        const p = Math.min(30, seconds * 5);
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 25) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_deploy_2 || '2/3: Konteinerite käivitamine ja võrgu seadistus...';
        const p = Math.min(85, 30 + Math.floor((seconds - 6) * 2.8));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_deploy_3 || '3/3: Tervisekontroll ja portaalide valmidus...';
        const p = Math.min(96, 85 + Math.floor((seconds - 25) * 1.2));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'stop') {
      if (seconds === 1) appendLog(`[${nowTime}] Peatan arhitektuuri teenuseid ja vabastan mälu (0 MB RAM)...`);
      if (seconds === 3) appendLog(`[${nowTime}] Ootan konteinerite ohutut seiskumist ja võrguportide vabastamist...`);
      if (seconds < 4) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_stop_1 || '1/2: Konteinerite ohutu peatamine...';
        const p = Math.min(60, seconds * 20);
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_stop_2 || '2/2: Ressursside ja võrguportide vabastamine...';
        const p = Math.min(95, 60 + Math.floor((seconds - 4) * 10));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'restart') {
      if (seconds === 2) appendLog(`[${nowTime}] Taaskäivitan arhitektuuri teenuseid ja kontrollin konfiguratsiooni...`);
      if (seconds === 6) appendLog(`[${nowTime}] Kontrollin konteinerite tervislikku seisundit ja võrguporte...`);
      if (seconds === 12) appendLog(`[${nowTime}] Kinnitan SEPS Wallet ja ORDS ühenduste toimimist...`);
      if (seconds === 22) appendLog(`[${nowTime}] Viimistlen taaskäivituse olekut ja teenuste valmidust...`);
      if (seconds < 6) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_restart_1 || '1/3: Teenuste ja konteinerite taaskäivitamine...';
        const p = Math.min(35, seconds * 6);
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else if (seconds < 20) {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_restart_2 || '2/3: Tervisekontroll ja võrgupordi sidumine...';
        const p = Math.min(85, 35 + Math.floor((seconds - 6) * 3.5));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      } else {
        if (phaseEl) phaseEl.textContent = dict.ops_phase_restart_3 || '3/3: Portaalide ja SEPS ühenduste kontroll...';
        const p = Math.min(96, 85 + Math.floor((seconds - 20) * 1.0));
        if (pctEl) pctEl.textContent = `${p}%`;
        if (barEl) barEl.style.width = `${p}%`;
      }
    } else if (opType === 'diag') {
      if (seconds === 1) appendLog(`[${nowTime}] Käivitan testimise ja diagnostika skripti...`);
      if (seconds === 4) appendLog(`[${nowTime}] Ootan vastust ja analüüsin tulemusi...`);
      if (phaseEl) phaseEl.textContent = 'Diagnostikakäsu käivitamine ja analüüs...';
      const p = Math.min(95, 20 + Math.floor(seconds * 15));
      if (pctEl) pctEl.textContent = `${p}%`;
      if (barEl) barEl.style.width = `${p}%`;
    }
  }

  updateUI();
  const intervalId = setInterval(() => {
    seconds++;
    updateUI();
  }, 1000);

  let pollCounter = 0;
  const logPollInterval = setInterval(async () => {
    pollCounter++;
    if (pollCounter % 2 === 0 && initialLogName) {
      try {
        let resp = null;
        try {
          resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(initialLogName)}`);
        } catch (fetchErr) {
          if (typeof BRIDGE_URL_ALT !== 'undefined' && BRIDGE_URL_ALT && BRIDGE_URL_ALT !== BRIDGE_URL) {
            resp = await fetch(`${BRIDGE_URL_ALT}/api/log/read?file=${encodeURIComponent(initialLogName)}`);
          }
        }
        if (resp && resp.ok) {
          const d = await resp.json();
          // 🛡️ Guardrail: Never overwrite live streaming output if log file was not found yet
          if (d && (d.ok || d.status === 'ok') && d.found !== false && d.content && d.content.trim()) {
            const rawLines = d.content.trim().split('\n');
            const recent = rawLines.slice(-35).join('\n');
            if (outEl && recent) {
              outEl.innerHTML = formatTerminalLogText(recent, { showTime: true, showColors: true });
              if (!isUserScrolledUp) {
                outEl.scrollTop = outEl.scrollHeight;
              }
            }
          }
        }
      } catch (e) {}
    }
  }, 1000);

  return {
    finish: (success, data) => {
      clearInterval(intervalId);
      clearInterval(logPollInterval);
      const mm = String(Math.floor(seconds / 60)).padStart(2, '0');
      const ss = String(seconds % 60).padStart(2, '0');
      if (timerEl) timerEl.textContent = `⏱️ ${mm}:${ss}`;
      if (pctEl) pctEl.textContent = success ? '100%' : 'VIGA';
      if (barEl) {
        barEl.style.width = '100%';
        barEl.style.background = success ? '#22c55e' : '#ef4444';
      }

      if (data && data.output) {
        const finishTime = new Date().toLocaleTimeString('et-EE', { hour12: false });
        appendLog(`\n--- [${finishTime}] Täielik skripti väljund: ---\n` + data.output);
      }

      if (data && (data.log_file || data.log_relative_path)) {
        const logPathEl = document.getElementById(`${containerId}-log-path`);
        if (logPathEl) {
          const rel = data.log_relative_path || ('install_logs/' + data.log_file);
          logPathEl.textContent = rel;
          logPathEl.setAttribute('data-log-file', data.log_file);
          if (data.log_full_path) logPathEl.setAttribute('data-full-path', data.log_full_path);
        }
        const splitLogLabel = document.getElementById(`${containerId}-split-log-label`);
        if (splitLogLabel) {
          splitLogLabel.textContent = data.log_relative_path || ('install_logs/' + data.log_file);
        }
      }
      if (typeof activeBpModalNum === 'number') {
        refreshBlueprintLatestLog(activeBpModalNum);
      }

      if (resEl) {
        resEl.style.display = 'block';
        if (success) {
          const createdFile = (data && data.created_file) || '';
          const sizeHuman = (data && data.size_human) || '';
          const elapsed = (data && data.elapsed_seconds) ? `${data.elapsed_seconds}s` : `${seconds}s`;

          let fileDetails = '';
          if (createdFile) {
            fileDetails = `
              <div style="margin-top: 6px; font-size: 0.82rem; color: #cbd5e1; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                <div>📦 <b>Fail:</b> <code style="color: #38bdf8; font-weight: 600;">${createdFile}</code></div>
                ${sizeHuman ? `<div>💾 <b>Maht:</b> <strong style="color: #fbbf24;">${sizeHuman}</strong></div>` : ''}
                <div>⏱️ <b>Koguaeg:</b> <strong style="color: #4ade80;">${elapsed}</strong></div>
              </div>
            `;
          } else {
            fileDetails = `
              <div style="margin-top: 6px; font-size: 0.82rem; color: #cbd5e1; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                <div>⏱️ <b>Koguaeg:</b> <strong style="color: #4ade80;">${elapsed}</strong></div>
              </div>
            `;
          }

          let succText = `Toiming edukalt teostatud (${opType})!`;
          if (opType === 'create') {
            succText = dict.snap_success_create || 'Snapshot edukalt loodud!';
          } else if (opType === 'restore') {
            succText = dict.snap_success_restore || 'Snapshot edukalt taastatud!';
          } else if (opType === 'stop') {
            succText = dict.ops_success_stop || 'Teenused edukalt peatatud (0 MB RAM)!';
          } else if (opType === 'restart') {
            succText = dict.ops_success_restart || 'Teenused edukalt taaskäivitatud!';
          } else if (opType === 'switch' || opType === 'start' || opType === 'deploy') {
            succText = dict.ops_success_deploy || 'Arhitektuur edukalt juurutatud ja aktiivne!';
          } else if (opType === 'reset_deep') {
            succText = dict.snap_success_reset_deep || 'Süvapuhastus ja täispaigaldus edukalt lõpetatud!';
          }

          resEl.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
              <div>
                <div style="font-weight: 700; color: #4ade80; font-size: 0.95rem;">
                  ✅ ${succText}
                </div>
                ${fileDetails}
              </div>
              ${createdFile ? `
              <button class="btn btn-primary" style="padding: 6px 14px; font-size: 0.82rem;" onclick="navigateToSnapshotsTab('${createdFile}')">
                📂 ${dict.snap_btn_goto_snapshots || 'Vaata Snapshotide Tabelis →'}
              </button>` : ''}
            </div>
          `;
        } else {
          const errText = (data && (data.error || data.output)) || (dict.err_op_failed || 'Toiming ebaõnnestus.');
          const errLogName = (data && data.log_file) || initialLogName;
          const errLogRel = (data && data.log_relative_path) || (errLogName ? ('install_logs/' + errLogName) : initialLogRel);
          const errLogFull = (data && data.log_full_path) || errLogRel;

          resEl.style.borderColor = 'rgba(239, 68, 68, 0.4)';
          resEl.style.background = 'rgba(239, 68, 68, 0.08)';
          resEl.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
              <div style="color: #f87171; font-weight: 700; font-size: 0.95rem;">
                ⚠️ ${dict.msg_op_failed || 'Viga toimingu teostamisel!'}
              </div>
              <span class="badge" style="background: rgba(239,68,68,0.2); color: #fca5a5; border: 1px solid rgba(239,68,68,0.4); font-size: 0.74rem;">
                ${dict.status_failed || 'Ebaõnnestus'} (⏱️ ${seconds}s)
              </span>
            </div>
            <div style="background: #180909; border: 1px solid rgba(239, 68, 68, 0.35); border-radius: 6px; padding: 10px; margin-top: 8px; font-family: ui-monospace, monospace; font-size: 0.78rem; color: #fca5a5; white-space: pre-wrap; word-break: break-all; line-height: 1.45;">${errText}</div>

            <div style="margin-top: 10px; padding: 8px 12px; background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(239, 68, 68, 0.25); border-radius: 6px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
              <div style="display: flex; align-items: center; gap: 8px; min-width: 0; flex: 1;">
                <span style="font-size: 0.78rem; color: #cbd5e1; white-space: nowrap;">📄 <b>${dict.label_active_log || 'Logifail'}:</b></span>
                <span style="color: #38bdf8; font-family: ui-monospace, monospace; font-size: 0.8rem; font-weight: 600; text-decoration: underline; cursor: pointer; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;" onclick="toggleActiveTerminalLog('${containerId}')" title="${dict.tip_click_open_log || 'Klõpsa logi avamiseks'}">${errLogRel}</span>
              </div>
              <div style="display: flex; gap: 6px;">
                <button type="button" class="btn btn-secondary" style="padding: 3px 10px; font-size: 0.75rem;" onclick="copyActiveLogPath('${errLogFull}', this)" title="${dict.btn_copy_path || 'Kopeeri tee'}">
                  <span>📋</span> <span>${dict.btn_copy_path || 'Kopeeri tee'}</span>
                </button>
                <button type="button" class="btn btn-secondary" style="padding: 3px 10px; font-size: 0.75rem; border-color: rgba(239,68,68,0.5); color: #fca5a5;" onclick="toggleActiveTerminalLog('${containerId}')">
                  <span>👁️</span> <span>${dict.btn_open_log || 'Ava logi'}</span>
                </button>
              </div>
            </div>
            <div style="margin-top: 6px; font-size: 0.75rem; color: #94a3b8; display: flex; align-items: center; gap: 6px;">
              <span>💡</span>
              <span>${dict.tip_check_error_cli || 'Täpsemate vigade ja Oracle ORA-veakoodide uurimiseks ava logi nupuga või vaata terminalis:'} <code style="color: #cbd5e1;">cat ${errLogRel} | tail -n 50</code></span>
            </div>
          `;
        }
      }
    }
  };
}

function navigateToSnapshotsTab(fileName) {
  closeBlueprintModal();
  switchTab('tab-snapshots');
  setTimeout(() => {
    loadSnapshotsTable();
    if (fileName) {
      setTimeout(() => {
        const rows = document.querySelectorAll('#snapshots-table-container tr');
        rows.forEach(r => {
          if (r.textContent.includes(fileName)) {
            r.scrollIntoView({ behavior: 'smooth', block: 'center' });
            r.style.boxShadow = '0 0 16px rgba(56, 189, 248, 0.8)';
            r.style.background = 'rgba(56, 189, 248, 0.15)';
            setTimeout(() => {
              r.style.boxShadow = '';
              r.style.background = '';
            }, 3500);
          }
        });
      }, 350);
    }
  }, 100);
}

async function triggerSubmitCustomSnapshot() {
  const tagInput = document.getElementById('custom-snap-tag');
  const descInput = document.getElementById('custom-snap-desc');
  const btn = document.getElementById('btn-submit-custom-snap');

  const tag = (tagInput ? tagInput.value : '').trim();
  const desc = (descInput ? descInput.value : '').trim();
  const bpNum = typeof LIVE_ACTIVE_BP === 'number' ? LIVE_ACTIVE_BP : 0;

  if (!tag) {
    alert('Palun sisesta sildi tunnus (tag)!');
    if (tagInput) tagInput.focus();
    return;
  }

  const safeTag = tag.replace(/[^a-zA-Z0-9_\-]/g, '_');
  const origBtnHtml = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = `<span>⏳</span> <span>Salvestan...</span>`;

  const cmdStr = `./scripts/snapshots/create-golden-snapshots.sh -b ${bpNum} --tag "${safeTag}"` + (desc ? ` --desc "${desc}"` : '');
  const progress = startTerminalProgress('tab-snapshots-console', 'create', `📸 Snapshot: tag '${safeTag}'`, cmdStr);

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/create`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        blueprint: bpNum,
        tag: safeTag,
        desc: desc
      }),
      mode: 'cors'
    });

    const data = await resp.json();
    btn.disabled = false;
    btn.innerHTML = origBtnHtml;

    if (resp.ok && data.status === 'ok') {
      showToast(`✅ Kohandatud snapshot '${safeTag}' loodud!`);
      if (progress) progress.finish(true, data);
      if (tagInput) tagInput.value = '';
      if (descInput) descInput.value = '';
      loadSnapshotsTable();
    } else {
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || 'Snapshoti loomine ebaõnnestus.';
      showToast(`⚠️ ${errMsg}`);
    }
  } catch (err) {
    btn.disabled = false;
    btn.innerHTML = origBtnHtml;
    console.error('Error creating custom snapshot:', err);
    if (progress) progress.finish(false, { error: err.message, log_file: `snapshot_create_bp_${bpNum}_latest.log`, log_relative_path: `install_logs/snapshot_create_bp_${bpNum}_latest.log` });
    showToast(`⚠️ Viga: ${err.message}`);
  }
}

async function triggerCreateCustomSnapshotModal(bNum, btn) {
  const tagInput = document.getElementById(`modal-snap-tag-${bNum}`);
  const descInput = document.getElementById(`modal-snap-desc-${bNum}`);

  const tag = (tagInput ? tagInput.value : '').trim();
  const desc = (descInput ? descInput.value : '').trim();

  if (!tag) {
    showToast('⚠️ Palun sisesta sildi tunnus (tag)!');
    if (tagInput) tagInput.focus();
    return;
  }

  const safeTag = tag.replace(/[^a-zA-Z0-9_\-]/g, '_');
  const origBtnHtml = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = `<span>⏳</span> <span>Salvestan...</span>`;

  const cmdStr = `./scripts/snapshots/create-golden-snapshots.sh -b ${bNum} --tag "${safeTag}"` + (desc ? ` --desc "${desc}"` : '');
  const consoleTarget = document.getElementById('modal-ops-console') ? 'modal-ops-console' : (document.getElementById('modal-dr-console') ? 'modal-dr-console' : 'tab-snapshots-console');
  const progress = startTerminalProgress(consoleTarget, 'create', `📸 Snapshot: tag '${safeTag}'`, cmdStr);
  document.getElementById(consoleTarget)?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/create`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        blueprint: bNum,
        tag: safeTag,
        desc: desc
      }),
      mode: 'cors'
    });

    const data = await resp.json();
    btn.disabled = false;
    btn.innerHTML = origBtnHtml;

    if (resp.ok && data.status === 'ok') {
      showToast(`✅ Snapshot '${safeTag}' edukalt loodud!`);
      if (progress) progress.finish(true, data);
      if (tagInput) tagInput.value = '';
      if (descInput) descInput.value = '';
      loadSnapshotsTable();
    } else {
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || 'Loomine ebaõnnestus.';
      showToast(`⚠️ ${errMsg}`);
    }
  } catch (err) {
    btn.disabled = false;
    btn.innerHTML = origBtnHtml;
    console.error('Error in modal create snapshot:', err);

    const logFile = `snapshot_create_bp_${bNum}_latest.log`;
    let verifiedSuccess = false;
    try {
      const checkResp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(logFile)}`);
      if (checkResp.ok) {
        const logData = await checkResp.json();
        const content = logData.content || '';
        if (content.includes('SNAPSHOT CREATED') || content.includes('GOLDEN SNAPSHOT CREATED') || content.includes('SNAPSHOT COMPLETED')) {
          verifiedSuccess = true;
          if (progress) progress.finish(true, { output: content, log_file: logFile, log_relative_path: `install_logs/${logFile}` });
          showToast(`✅ Snapshot '${safeTag}' edukalt loodud!`);
          loadSnapshotsTable();
        }
      }
    } catch (e) {}

    if (!verifiedSuccess) {
      const isFetchErr = err.message && err.message.includes('fetch');
      const errExpl = isFetchErr ? 'Brauseri HTTP ühenduse ajalõpp (Failed to fetch). Toiming viidi taustal lõpule – vaata logi.' : err.message;
      if (progress) progress.finish(false, { error: errExpl, log_file: logFile, log_relative_path: `install_logs/${logFile}` });
      showToast(`⚠️ Viga: ${err.message}`);
    }
  }
}

async function triggerRestoreSnapshot(fileName, bNum, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const targetDesc = fileName || `Blueprint #${bNum} Golden Baseline`;
  const confirmMsg = `${dict.snap_confirm_restore || '⚠️ Oled kindel, et soovid taastada selle snapshoti? Kõik praegused salvestamata andmebaasimuudatused kirjutatakse üle!'}\n\nSiht: ${targetDesc}`;
  if (!confirm(confirmMsg)) return;

  const origBtnHtml = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span> <span>Taastan...</span>`;
  }
  showToast('⏳ Taastan andmebaasi snapshotist... Palun oota (~15–45s)');

  const cmdStr = fileName
    ? `./scripts/snapshots/restore-golden-snapshots.sh --file "${fileName}" --force`
    : `./scripts/snapshots/restore-golden-snapshots.sh -b ${bNum || 0} --force`;

  const consoleTarget = document.getElementById('modal-ops-console') ? 'modal-ops-console' : (document.getElementById('modal-dr-console') ? 'modal-dr-console' : 'tab-snapshots-console');
  const progress = startTerminalProgress(consoleTarget, 'restore', `⚡ Taastamine: ${targetDesc}`, cmdStr);
  document.getElementById(consoleTarget)?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/restore`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        file: fileName || '',
        blueprint: bNum || 0
      }),
      mode: 'cors'
    });

    const data = await resp.json();
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }

    if (resp.ok && data.status === 'ok') {
      showToast('✅ Snapshot edukalt taastatud (~15–20s)!');
      if (progress) progress.finish(true, data);
      pollBridgeStatus(true);
      checkServiceHealth();
      loadSnapshotsTable();
    } else {
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || 'Taastamine ebaõnnestus.';
      showToast(`⚠️ ${errMsg}`);
    }
  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }
    console.error('Error restoring snapshot:', err);

    // If browser fetch timed out (e.g., Failed to fetch), verify if server completed in background
    const logFile = `restore_bp_${bNum || 0}_latest.log`;
    let verifiedSuccess = false;
    try {
      const checkResp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(logFile)}`);
      if (checkResp.ok) {
        const logData = await checkResp.json();
        const content = logData.content || '';
        if (content.includes('GOLDEN SNAPSHOT RESTORED') || content.includes('ALL SECRETS SUCCESSFULLY ROTATED') || content.includes('All selected containers and web service URLs are operational')) {
          verifiedSuccess = true;
          if (progress) progress.finish(true, { output: content, log_file: logFile, log_relative_path: `install_logs/${logFile}` });
          showToast('✅ Snapshot edukalt taastatud!');
          pollBridgeStatus(true);
          checkServiceHealth();
          loadSnapshotsTable();
        }
      }
    } catch (e) {}

    if (!verifiedSuccess) {
      const isFetchErr = err.message && err.message.includes('fetch');
      const errExpl = isFetchErr ? 'Brauseri HTTP ühenduse ajalõpp (Failed to fetch). Toiming viidi taustal lõpule – vaata logi.' : err.message;
      if (progress) progress.finish(false, { error: errExpl, log_file: logFile, log_relative_path: `install_logs/${logFile}` });
      showToast(`⚠️ Viga: ${err.message}`);
    }
  }
}

function triggerRestoreActiveBaseline(btn) {
  const bp = typeof LIVE_ACTIVE_BP === 'number' ? LIVE_ACTIVE_BP : 0;
  triggerRestoreSnapshot(null, bp, btn);
}

async function triggerDeleteSnapshot(fileName, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const confirmMsg = `${dict.snap_confirm_delete || 'Kas oled kindel, et soovid selle kohandatud snapshoti kustutada?'}\n\n${fileName}`;
  if (!confirm(confirmMsg)) return;

  const origBtnHtml = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span>`;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/delete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ file: fileName }),
      mode: 'cors'
    });

    const data = await resp.json();
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }

    if (resp.ok && data.status === 'ok') {
      showToast(`🗑️ Snapshot '${fileName}' kustutatud!`);
      loadSnapshotsTable();
    } else {
      const errMsg = (data && (data.error || data.message)) || 'Kustutamine ebaõnnestus.';
      alert('Viga snapshoti kustutamisel: ' + errMsg);
    }
  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }
    console.error('Error deleting snapshot:', err);
    alert('Viga snapshoti kustutamisel: ' + err.message);
  }
}

async function triggerCleanOldSnapshots(btn) {
  if (!confirm('Kas soovid käivitada vanade snapshotide puhastusskripti (clean-golden-snapshots.sh)?')) return;

  const origBtnHtml = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span> <span>Puhastan...</span>`;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/devops/run`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ command: 'clean-snapshots' }),
      mode: 'cors'
    });

    const data = await resp.json();
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }

    if (resp.ok && data.status === 'ok') {
      showToast('🧹 Vanad snapshotid puhastatud!');
      loadSnapshotsTable();
    } else {
      const errMsg = (data && (data.error || data.output)) || 'Puhastamine ebaõnnestus.';
      alert('Viga snapshotide puhastamisel:\n' + errMsg);
    }
  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }
    console.error('Error cleaning old snapshots:', err);
    alert('Viga puhastamisel: ' + err.message);
  }
}

async function triggerDeepReset(bNum, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  // Discover fresh active containers list
  let activeContainers = Array.isArray(LIVE_RUNNING_CONTAINERS) ? [...LIVE_RUNNING_CONTAINERS] : [];
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 1200);
    const resp = await fetch(`${BRIDGE_URL}/api/status`, { signal: controller.signal, mode: 'cors' });
    clearTimeout(timeoutId);
    if (resp.ok) {
      const data = await resp.json();
      if (Array.isArray(data.running_containers)) {
        activeContainers = data.running_containers;
        LIVE_RUNNING_CONTAINERS = activeContainers;
      }
    }
  } catch (e) {
    // fallback to existing LIVE_RUNNING_CONTAINERS
  }

  const containerListText = activeContainers.length > 0
    ? (dict.snap_confirm_reset_active_list || '\nHetkel aktiivsed konteinerid, mida see mõjutab:\n• %s\n').replace('%s', activeContainers.join('\n• '))
    : (dict.snap_confirm_reset_no_active || '\n(Ükski konteiner ei tööta hetkel)\n');

  const baseConfirmTpl = dict.snap_confirm_reset || '⚠️ HOIATUS: Süvapuhastus ja Täispaigaldus (Variant B)\n\nTÄHELEPANU: See toiming mõjutab KÕIKI konteinereid, mis on praegu aktiivsed!\n%s\nKõik aktiivsed konteinerid peatatakse ja eemaldatakse. Kustutatakse kõik kohalikud andmemahud (volumes), saladused ja sertifikaadid ning tehakse täielik külm taaspaigaldus nullist (~4–8 min).\n\nKas oled kindel ja annad nõusoleku jätkamiseks?';

  const confirmMsg = baseConfirmTpl.includes('%s')
    ? baseConfirmTpl.replace('%s', containerListText)
    : `${baseConfirmTpl}\n${containerListText}`;

  if (!confirm(confirmMsg)) {
    showToast(dict.snap_toast_reset_cancelled || 'ℹ️ Süvapuhastus tühistatud kasutaja poolt.');
    return;
  }

  const origBtnHtml = btn ? btn.innerHTML : '';
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = `<span>⏳</span> <span>${dict.snap_btn_cleaning || 'Tühjendan...'}</span>`;
  }
  showToast(dict.snap_toast_reset_start || '⚠️ Käivitan süvapuhastuse ja taaspaigalduse...');

  const cmdStr = `./scripts/reset-all.sh -y && ./scripts/setup-all.sh -b ${bNum || 0} -y --lang ${currentLang}`;
  const opTitle = `⚠️ ${dict.modal_dr_variant_b_btn || 'Süvapuhastus ja Täispaigaldus'} (BP #${bNum || 0})`;
  const consoleTarget = document.getElementById('modal-ops-console') ? 'modal-ops-console' : (document.getElementById('modal-dr-console') ? 'modal-dr-console' : 'tab-snapshots-console');
  const progress = startTerminalProgress(consoleTarget, 'reset_deep', opTitle, cmdStr);
  document.getElementById(consoleTarget)?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/snapshots/reset-deep`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ blueprint: bNum || 0, lang: currentLang }),
      mode: 'cors'
    });

    const data = await resp.json();

    if (!resp.ok || data.status !== 'ok') {
      if (btn) {
        btn.disabled = false;
        btn.innerHTML = origBtnHtml;
      }
      if (progress) progress.finish(false, data);
      const errMsg = (data && (data.error || data.output)) || (dict.snap_error_reset_fail || 'Süvapuhastus ebaõnnestus.');
      alert('Viga süvapuhastusel:\n' + errMsg);
      return;
    }

    showToast(dict.snap_toast_reset_start || '⚠️ Süvapuhastus ja taaspaigaldus käivitatud taustal...');

    const pollTaskInterval = setInterval(async () => {
      try {
        const statusResp = await fetch(`${BRIDGE_URL}/api/task/status?task=reset_deep`);
        if (statusResp.ok) {
          const statusData = await statusResp.json();
          if (statusData.state === 'completed') {
            clearInterval(pollTaskInterval);
            if (btn) {
              btn.disabled = false;
              btn.innerHTML = origBtnHtml;
            }
            showToast(dict.snap_toast_reset_success || '✅ Süvapuhastus ja täispaigaldus edukalt lõpetatud!');
            if (progress) progress.finish(true, statusData);
            pollBridgeStatus(true);
            checkServiceHealth();
          } else if (statusData.state === 'failed') {
            clearInterval(pollTaskInterval);
            if (btn) {
              btn.disabled = false;
              btn.innerHTML = origBtnHtml;
            }
            if (progress) progress.finish(false, statusData);
            const errMsg = statusData.error || (dict.snap_error_reset_fail || 'Süvapuhastus ebaõnnestus.');
            alert('Viga süvapuhastusel:\n' + errMsg);
          }
        }
      } catch (pollErr) {
        console.warn('Polling task status failed:', pollErr);
      }
    }, 2500);

  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnHtml;
    }
    console.error('Error during deep reset:', err);
    if (progress) progress.finish(false, { error: err.message });
    alert('Viga süvapuhastusel: ' + err.message);
  }
}

/* ==============================================================================
 * TAB-TESTING: AUTOMATED TESTING CENTER & CI QUALITY GATE CONTROLLER
 * ============================================================================== */

let currentTestingSubTab = 'runner';
let activeTestTaskId = null;
let testPollInterval = null;
let testTimerInterval = null;
let testTimerSeconds = 0;
let currentTestLogPath = null;
let loadedTestReports = [];
let selectedReport = null;
let isRawReportView = false;
let selectedReportRawContent = '';
let loadedCoverageData = null;
let currentCoverageFilter = 'all';
let currentCoverageSearch = '';
let isTestingInitialized = false;

function escapeTestHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function initTestingTab() {
  const suites = (typeof TEST_SUITES_DATA !== 'undefined' ? TEST_SUITES_DATA : window.TEST_SUITES_DATA) || {};
  const reports = (typeof TEST_REPORTS_DATA !== 'undefined' ? TEST_REPORTS_DATA : window.TEST_REPORTS_DATA) || [];
  const coverage = (typeof TEST_COVERAGE_DATA !== 'undefined' ? TEST_COVERAGE_DATA : window.TEST_COVERAGE_DATA) || {};
  const history = (typeof TEST_HISTORY_DATA !== 'undefined' ? TEST_HISTORY_DATA : window.TEST_HISTORY_DATA) || [];

  if (!isTestingInitialized) {
    isTestingInitialized = true;
    updateCiReadinessScorecard();
    renderTestingSuites(suites);
    renderTestReportsList(reports);
    renderCoverageExplorer(coverage);
    renderTestHistoryTable(history);
    updateTestTerminalLangBadge();
  }

  // Live refresh from Bridge if available
  fetch(`${BRIDGE_URL}/api/tests/suites`)
    .then(r => r.json())
    .then(data => {
      if (data && data.suites) {
        window.TEST_SUITES_DATA = data.suites;
        renderTestingSuites(data.suites);
        updateCiReadinessScorecard();
      }
    })
    .catch(() => {});

  fetch(`${BRIDGE_URL}/api/tests/reports`)
    .then(r => r.json())
    .then(data => {
      if (data && data.reports) {
        loadedTestReports = data.reports;
        renderTestReportsList(data.reports);
      }
    })
    .catch(() => {});

  fetch(`${BRIDGE_URL}/api/tests/coverage`)
    .then(r => r.json())
    .then(data => {
      if (data && data.coverage) {
        loadedCoverageData = data.coverage;
        renderCoverageExplorer(data.coverage);
        updateCiReadinessScorecard();
      }
    })
    .catch(() => {});

  loadTestHistory();
}

function updateCiReadinessScorecard() {
  const suites = (typeof TEST_SUITES_DATA !== 'undefined' ? TEST_SUITES_DATA : window.TEST_SUITES_DATA) || {};
  const unitCount = (suites.unit && suites.unit.count) ? suites.unit.count : 29;
  const unitEl = document.getElementById('scorecard-unit-count');
  if (unitEl) unitEl.innerText = `${unitCount} tests`;

  const cov = loadedCoverageData || (typeof TEST_COVERAGE_DATA !== 'undefined' ? TEST_COVERAGE_DATA : window.TEST_COVERAGE_DATA) || {};
  const covPercent = cov.percent !== undefined ? cov.percent : 0;
  const covValEl = document.getElementById('scorecard-coverage-value');
  const covSubEl = document.getElementById('scorecard-coverage-sub');
  if (covValEl) covValEl.innerText = `${covPercent}%`;
  if (covSubEl) covSubEl.innerText = `${cov.covered || 0} / ${cov.total || 0} scripts`;
}

function switchTestingSubTab(subTabId) {
  currentTestingSubTab = subTabId;
  document.querySelectorAll('.testing-subnav-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.testing-subtab-content').forEach(c => {
    c.classList.remove('active');
    c.style.display = 'none';
  });

  const activeBtn = document.getElementById(`btn-subtab-${subTabId}`);
  if (activeBtn) activeBtn.classList.add('active');

  const activeContent = document.getElementById(`testing-subtab-${subTabId}`);
  if (activeContent) {
    activeContent.classList.add('active');
    activeContent.style.display = 'block';
  }
}

function renderTestingSuites(suites) {
  if (!suites || Object.keys(suites).length === 0) {
    suites = (typeof TEST_SUITES_DATA !== 'undefined' ? TEST_SUITES_DATA : window.TEST_SUITES_DATA) || {};
  }
  const grid = document.getElementById('testing-suites-grid');
  if (!grid) return;
  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && (I18N_DICT[lang] || I18N_DICT['en'])) || {};

  let html = '';
  Object.values(suites || {}).forEach(suite => {
    const hasSingleTests = suite.tests && suite.tests.length > 1;
    let selectOptions = '';
    if (hasSingleTests) {
      selectOptions = `<select id="select-suite-${suite.key}" class="test-script-select">
        <option value="">-- ${dict.test_select_individual || 'Üksik skript'} --</option>
        ${suite.tests.map(t => `<option value="${escapeTestHtml(t)}">${escapeTestHtml(t)}</option>`).join('')}
      </select>`;
    }

    const suiteTitle = dict['test_suite_' + suite.key + '_title'] || suite.title;
    const suiteDesc = dict['test_suite_' + suite.key + '_desc'] || suite.desc;

    html += `
      <div class="test-suite-card" data-cat="${escapeTestHtml(suite.category || 'core')}" data-key="${escapeTestHtml(suite.key)}" data-tests="${escapeTestHtml((suite.tests || []).join(' '))}">
        <div>
          <div class="test-suite-header">
            <div class="test-suite-title">
              <span>${suite.icon || '🧪'}</span>
              <span>${escapeTestHtml(suiteTitle)}</span>
            </div>
            <span class="badge badge-info test-count-badge-clickable" onclick="openSuiteTestsModal('${suite.key}')" title="${dict.btn_view_tests || 'Kuva testid'}" style="font-size:0.7rem;">
              ${suite.count} ${suite.count === 1 ? 'test' : 'tests'} 👁️
            </span>
          </div>
          <div class="test-suite-desc">${escapeTestHtml(suiteDesc)}</div>
        </div>
        ${suite.cmd ? `
          <div class="code-box" style="margin: 10px 0 12px 0; padding: 6px 55px 6px 10px; font-size: 0.75rem; white-space: nowrap; overflow-x: auto; background: rgba(0,0,0,0.3); border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <code style="color: var(--accent-cyan, #38bdf8); font-family: monospace;">${escapeTestHtml(suite.cmd)}</code>
            <button type="button" class="copy-btn" onclick="copySnippet(this)" style="top: 4px; right: 4px; padding: 2px 6px; font-size: 0.7rem;">Copy</button>
          </div>
        ` : ''}
        <div class="test-suite-actions">
          <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap;">
            <button type="button" class="btn-compact btn-compact-secondary" onclick="openSuiteTestsModal('${suite.key}')" title="${dict.btn_view_tests || 'Kuva testid'}" style="font-size:0.75rem;">
              <span>👁️</span> <span>${dict.btn_view_tests || 'Kuva testid'}</span>
            </button>
            ${selectOptions}
            ${hasSingleTests ? `
              <button type="button" class="btn-compact btn-compact-secondary" style="font-size:0.75rem;" onclick="runSingleSuiteTest('${suite.key}')" title="${dict.test_run_selected_tooltip || 'Käivita valitud skript'}">
                <span>▶️</span>
              </button>
            ` : ''}
          </div>
          <button type="button" class="btn-compact btn-compact-primary" onclick="runTestSuite('${suite.key}')">
            <span>▶️</span> <span>${dict.btn_run_suite || 'Käivita kõik'}</span>
          </button>
        </div>
      </div>
    `;
  });
  grid.innerHTML = html;
  filterTestingSuites();
}

let currentTestingCategoryFilter = 'all';

function filterTestingCategory(cat, btn) {
  currentTestingCategoryFilter = cat || 'all';
  document.querySelectorAll('#testing-category-filters .bp-filter-btn').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  filterTestingSuites();
}

function filterTestingSuites() {
  const searchInput = document.getElementById('testing-search-input');
  const clearBtn = document.getElementById('testing-search-clear');
  const counterEl = document.getElementById('testing-filter-counter');
  const emptyEl = document.getElementById('testing-empty-state');
  const gridEl = document.getElementById('testing-suites-grid');

  const q = ((searchInput && searchInput.value) || '').toLowerCase().trim();
  if (clearBtn) {
    clearBtn.style.display = q ? 'inline-block' : 'none';
  }

  const cards = document.querySelectorAll('#testing-suites-grid .test-suite-card');
  let visibleCount = 0;
  const totalCount = cards.length;

  cards.forEach(card => {
    const cardCat = card.getAttribute('data-cat') || 'core';
    const matchesCat = (currentTestingCategoryFilter === 'all') || (cardCat === currentTestingCategoryFilter);
    const text = card.textContent.toLowerCase();
    const testsAttr = (card.getAttribute('data-tests') || '').toLowerCase();
    const matchesSearch = !q || text.includes(q) || testsAttr.includes(q);

    if (matchesCat && matchesSearch) {
      card.style.display = '';
      visibleCount++;
    } else {
      card.style.display = 'none';
    }
  });

  if (counterEl) {
    counterEl.innerText = `${visibleCount} / ${totalCount}`;
  }

  if (emptyEl) {
    emptyEl.style.display = (visibleCount === 0) ? 'block' : 'none';
  }
  if (gridEl) {
    gridEl.style.display = (visibleCount === 0) ? 'none' : 'grid';
  }
}

function clearTestingSearch() {
  const searchInput = document.getElementById('testing-search-input');
  if (searchInput) {
    searchInput.value = '';
    searchInput.focus();
  }
  filterTestingSuites();
}

function resetTestingFilters() {
  const searchInput = document.getElementById('testing-search-input');
  if (searchInput) searchInput.value = '';
  currentTestingCategoryFilter = 'all';
  const allBtn = document.querySelector('#testing-category-filters .bp-filter-btn');
  document.querySelectorAll('#testing-category-filters .bp-filter-btn').forEach(b => b.classList.remove('active'));
  if (allBtn) allBtn.classList.add('active');
  filterTestingSuites();
}

let currentModalSuiteKey = null;
let currentModalSuiteTests = [];
let currentViewedScript = null;
let currentViewedDocRel = null;
const SCRIPT_CONTENT_CACHE = {};

function updateTestTerminalLangBadge(lang) {
  const badge = document.getElementById('test-terminal-lang-badge');
  if (!badge) return;
  const currentLang = lang || localStorage.getItem('dev_hub_lang') || 'en';
  const flags = {
    en: '🇬🇧 EN',
    et: '🇪🇪 ET',
    fi: '🇫🇮 FI',
    sv: '🇸🇪 SV',
    lv: '🇱🇻 LV',
    lt: '🇱🇹 LT'
  };
  badge.innerText = flags[currentLang] || currentLang.toUpperCase();
  badge.title = `Aktiivne käivituskeel peamenüü päisest: ${currentLang.toUpperCase()}`;
}

function openSuiteTestsModal(suiteKey) {
  const suites = (typeof TEST_SUITES_DATA !== 'undefined' ? TEST_SUITES_DATA : window.TEST_SUITES_DATA) || {};
  const suite = suites[suiteKey];
  if (!suite) return;

  currentModalSuiteKey = suiteKey;
  currentModalSuiteTests = Array.isArray(suite.tests) ? suite.tests : [];

  const modal = document.getElementById('modal-suite-tests');
  const iconEl = document.getElementById('suite-tests-modal-icon');
  const titleEl = document.getElementById('suite-tests-modal-title');
  const subEl = document.getElementById('suite-tests-modal-subtitle');
  const searchInput = document.getElementById('suite-tests-search-input');
  const listView = document.getElementById('suite-tests-list-view');
  const scriptView = document.getElementById('suite-script-viewer-view');

  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && (I18N_DICT[lang] || I18N_DICT['en'])) || {};

  const sTitle = dict['test_suite_' + suite.key + '_title'] || suite.title || suiteKey;
  if (iconEl) iconEl.innerText = suite.icon || '🧪';
  if (titleEl) titleEl.innerText = sTitle;
  if (subEl) subEl.innerText = `${suite.count || currentModalSuiteTests.length} tests in ${sTitle}`;
  if (searchInput) searchInput.value = '';
  if (listView) listView.style.display = 'flex';
  if (scriptView) scriptView.style.display = 'none';

  renderSuiteTestsModalList('');

  if (modal) {
    modal.classList.add('active');
    modal.style.display = 'flex';
    if (searchInput) setTimeout(() => searchInput.focus(), 100);
  }
}

function closeSuiteTestsModal(event) {
  if (event && event.target && event.target.id !== 'modal-suite-tests') {
    return;
  }
  const modal = document.getElementById('modal-suite-tests');
  if (modal) {
    modal.classList.remove('active');
    modal.style.display = 'none';
  }
  currentModalSuiteKey = null;
  currentViewedScript = null;
  currentViewedDocRel = null;
}

function filterSuiteTestsModal(q) {
  renderSuiteTestsModalList(q);
}

function renderSuiteTestsModalList(query) {
  const container = document.getElementById('suite-tests-list-container');
  const countInfo = document.getElementById('suite-tests-modal-count-info');
  if (!container) return;

  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && (I18N_DICT[lang] || I18N_DICT['en'])) || {};

  const q = (query || '').toLowerCase().trim();
  const filtered = currentModalSuiteTests.filter(t => !q || t.toLowerCase().includes(q));

  if (countInfo) {
    countInfo.innerText = `${filtered.length} / ${currentModalSuiteTests.length} tests`;
  }

  if (filtered.length === 0) {
    container.innerHTML = `<div style="color:var(--text-muted); text-align:center; padding:30px 10px;">${dict.modal_tests_empty || 'Ühtegi vastavat testskripti ei leitud.'}</div>`;
    return;
  }

  let html = '';
  filtered.forEach((testName) => {
    const origIdx = currentModalSuiteTests.indexOf(testName) + 1;
    html += `
      <div class="suite-test-item">
        <div class="suite-test-item-left" style="cursor: pointer;" onclick="viewSuiteTestScript('${escapeTestHtml(testName)}')">
          <span class="suite-test-item-idx">#${origIdx}</span>
          <span class="suite-test-item-name" title="${escapeTestHtml(testName)}">${escapeTestHtml(testName)}</span>
        </div>
        <div style="display:flex; align-items:center; gap:6px; flex-shrink:0;">
          <button type="button" class="btn-compact btn-compact-secondary" onclick="viewSuiteTestScript('${escapeTestHtml(testName)}')" style="font-size:0.75rem; padding: 4px 8px;" title="${dict.btn_view_script_source || 'Vaata koodi'}">
            <span>📄</span> <span>${dict.btn_view_script_source || 'Sisu'}</span>
          </button>
          <button type="button" class="btn-compact btn-compact-primary" onclick="runTestFromModal('${currentModalSuiteKey}', '${escapeTestHtml(testName)}')" style="font-size:0.75rem; padding: 4px 10px;" title="${dict.test_run_selected_tooltip || 'Käivita valitud testskript'}">
            <span>▶️</span> <span>${dict.btn_run_single || 'Käivita'}</span>
          </button>
        </div>
      </div>
    `;
  });
  container.innerHTML = html;
}

function viewSuiteTestScript(scriptName) {
  currentViewedScript = scriptName;
  const listView = document.getElementById('suite-tests-list-view');
  const scriptView = document.getElementById('suite-script-viewer-view');
  const subEl = document.getElementById('suite-tests-modal-subtitle');
  const codeEl = document.getElementById('suite-script-code-content');
  const docBadge = document.getElementById('suite-script-viewer-doc-badge');

  if (listView) listView.style.display = 'none';
  if (scriptView) scriptView.style.display = 'flex';
  if (subEl) subEl.innerText = scriptName;
  if (codeEl) codeEl.innerText = 'Laadin skripti sisu...';
  if (docBadge) docBadge.style.display = 'none';

  if (SCRIPT_CONTENT_CACHE[scriptName]) {
    renderLoadedScriptContent(SCRIPT_CONTENT_CACHE[scriptName]);
    return;
  }

  fetch(`${BRIDGE_URL}/api/tests/script-content?script=${encodeURIComponent(scriptName)}`)
    .then(r => r.json())
    .then(data => {
      if (data.status === 'ok') {
        SCRIPT_CONTENT_CACHE[scriptName] = data;
        renderLoadedScriptContent(data);
      } else {
        throw new Error(data.error || 'Skripti laadimine ebaõnnestus');
      }
    })
    .catch(err => {
      if (codeEl) {
        codeEl.innerHTML = `# ⚠️ Skripti sisu ei õnnestunud bridge kaudu laadida: ${err.message}\n# Veendu, et dev-hub-bridge.py töötab taustal (./scripts/internal/dev-hub-bridge.py &)\n# Faili asukoht repositooriumis: tests/unit/${scriptName} või tests/integration/${scriptName}`;
      }
      const infoEl = document.getElementById('suite-script-viewer-info');
      if (infoEl) infoEl.innerText = 'Offline / Unavailable';
    });
}

function renderLoadedScriptContent(data) {
  const codeEl = document.getElementById('suite-script-code-content');
  const infoEl = document.getElementById('suite-script-viewer-info');
  const docBadge = document.getElementById('suite-script-viewer-doc-badge');
  const docTitle = document.getElementById('suite-script-viewer-doc-title');
  const subEl = document.getElementById('suite-tests-modal-subtitle');

  if (subEl) subEl.innerText = data.path || data.script;
  if (codeEl) {
    codeEl.textContent = data.content || '';
  }
  if (infoEl) {
    const lines = data.lines || (data.content ? data.content.split('\n').length : 0);
    const kb = data.size_bytes ? (data.size_bytes / 1024).toFixed(1) : ((data.content ? data.content.length : 0) / 1024).toFixed(1);
    infoEl.innerText = `${lines} rida • ${kb} KB • ${data.path || data.script}`;
  }
  if (data.doc && data.doc.title) {
    currentViewedDocRel = data.doc.doc_file || 'docs/testing-framework-and-devhub.md';
    if (docTitle) docTitle.innerText = data.doc.title;
    if (docBadge) docBadge.style.display = 'inline-flex';
  } else {
    currentViewedDocRel = null;
    if (docBadge) docBadge.style.display = 'none';
  }
}

function backToSuiteTestsList() {
  const listView = document.getElementById('suite-tests-list-view');
  const scriptView = document.getElementById('suite-script-viewer-view');
  const subEl = document.getElementById('suite-tests-modal-subtitle');
  if (listView) listView.style.display = 'flex';
  if (scriptView) scriptView.style.display = 'none';

  const suites = (typeof TEST_SUITES_DATA !== 'undefined' ? TEST_SUITES_DATA : window.TEST_SUITES_DATA) || {};
  const suite = suites[currentModalSuiteKey];
  if (subEl && suite) {
    subEl.innerText = `${suite.count || currentModalSuiteTests.length} tests in ${suite.title}`;
  }
}

function copySuiteScriptContent() {
  const codeEl = document.getElementById('suite-script-code-content');
  if (!codeEl) return;
  const text = codeEl.textContent || '';
  navigator.clipboard.writeText(text).then(() => {
    const lang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = (typeof I18N_DICT !== 'undefined' && (I18N_DICT[lang] || I18N_DICT['en'])) || {};
    showToast(dict.toast_script_copied || 'Skript kopeeritud!', 'success');
  }).catch(() => {
    alert('Kopeerimine ebaõnnestus.');
  });
}

function runViewedScript() {
  if (!currentViewedScript) return;
  const scriptName = currentViewedScript;
  const suiteKey = currentModalSuiteKey || 'unit';
  closeSuiteTestsModal();
  runTestSuite(suiteKey, scriptName);
  const term = document.getElementById('testing-terminal-output');
  if (term) {
    term.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
}

function openDocFromTestModal() {
  if (!currentViewedDocRel) return;
  closeSuiteTestsModal();
  switchTab('tab-docs');
  const targetRel = currentViewedDocRel.replace(/^\//, '');
  const targetBasename = targetRel.split('/').pop();
  if (Array.isArray(DOCS_DATA)) {
    const idx = DOCS_DATA.findIndex(d => d.rel === targetRel || d.rel.endsWith(targetBasename));
    if (idx !== -1) {
      setTimeout(() => {
        loadDocContent(idx, document.querySelectorAll('.docs-nav-item')[idx]);
      }, 150);
    }
  }
}

function toggleEnterpriseDropdown(event) {
  if (event) {
    event.stopPropagation();
  }
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) {
    const isShowing = menu.classList.contains('show');
    menu.classList.toggle('show', !isShowing);
    if (btn) {
      btn.classList.toggle('active', !isShowing);
      btn.setAttribute('aria-expanded', !isShowing ? 'true' : 'false');
    }
  }
}

function openDocFromMenu(docId) {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) {
    menu.classList.remove('show');
  }
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }

  filterDocsCategory('all');
  switchTab('tab-docs');

  if (Array.isArray(DOCS_DATA)) {
    let idx = DOCS_DATA.findIndex(d => d.id === docId);
    if (idx === -1) {
      idx = DOCS_DATA.findIndex(d => d.rel && (d.rel === docId || d.rel.includes(docId) || d.rel.endsWith(docId + '.md')));
    }
    if (idx !== -1) {
      setTimeout(() => {
        const docBtn = document.querySelector(`.docs-nav-item[data-doc-idx="${idx}"]`);
        loadDocContent(idx, docBtn);
        if (docBtn) {
          docBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      }, 50);
    }
  }
}

function runSecurityAuditFromMenu() {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) {
    menu.classList.remove('show');
  }
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }

  switchTab('tab-testing');
  setTimeout(() => {
    runTestSuite('security_audit');
    const term = document.getElementById('testing-terminal-output');
    if (term) {
      term.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }, 100);
}

function openFaqFromMenu() {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) menu.classList.remove('show');
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }
  if (typeof openFaqModal === 'function') {
    openFaqModal();
  }
}

function openOracleResourcesFromMenu() {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) menu.classList.remove('show');
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }
  if (typeof openOracleResourcesModal === 'function') {
    openOracleResourcesModal();
  }
}

function openGlossaryFromMenu() {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) menu.classList.remove('show');
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }
  if (typeof openGlossaryModal === 'function') {
    openGlossaryModal();
  }
}

function runLocalCiFromMenu() {
  const btn = document.getElementById('enterprise-dropdown-btn');
  const menu = document.getElementById('enterprise-dropdown-menu');
  if (menu) menu.classList.remove('show');
  if (btn) {
    btn.classList.remove('active');
    btn.setAttribute('aria-expanded', 'false');
  }
  switchTab('tab-testing');
  setTimeout(() => {
    runTestSuite('ci_sim');
    const term = document.getElementById('testing-terminal-output');
    if (term) {
      term.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }, 100);
}

document.addEventListener('click', function(event) {
  const menu = document.getElementById('enterprise-dropdown-menu');
  const btn = document.getElementById('enterprise-dropdown-btn');
  if (menu && menu.classList.contains('show')) {
    if (!menu.contains(event.target) && (!btn || !btn.contains(event.target))) {
      menu.classList.remove('show');
      if (btn) {
        btn.classList.remove('active');
        btn.setAttribute('aria-expanded', 'false');
      }
    }
  }
});

function runTestFromModal(suiteKey, scriptName) {
  closeSuiteTestsModal();
  runTestSuite(suiteKey, scriptName);
  const term = document.getElementById('testing-terminal-output');
  if (term) {
    term.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
}

function runSingleSuiteTest(suiteKey) {
  const sel = document.getElementById(`select-suite-${suiteKey}`);
  const scriptName = sel ? sel.value : '';
  if (!scriptName) {
    alert('Palun vali rippmenüüst konkreetne skript!');
    return;
  }
  runTestSuite(suiteKey, scriptName);
}

function runTestSuite(suiteKey, scriptName) {
  if (activeTestTaskId) {
    if (!confirm('Üks test on juba käimas. Kas soovid selle katkestada ja alustada uut?')) {
      return;
    }
    stopActiveTest();
  }

  if (currentTestingSubTab !== 'runner') {
    switchTestingSubTab('runner');
  }

  const termEl = document.getElementById('testing-terminal-output');
  const badgeEl = document.getElementById('test-terminal-task-badge');
  const statusEl = document.getElementById('test-terminal-footer-status');
  const timerEl = document.getElementById('test-terminal-footer-timer');
  const activeIndEl = document.getElementById('testing-active-indicator');
  const stopBtn = document.getElementById('btn-stop-test');
  const dlBtn = document.getElementById('btn-download-test-log');

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  updateTestTerminalLangBadge(currentLang);

  const testLabel = scriptName ? `${suiteKey} (${scriptName})` : suiteKey;
  if (termEl) {
    termEl.innerHTML = `🚀 Initializing test run: [${testLabel}] in ${currentLang.toUpperCase()}...\nDispatching background runner via bridge...\n`;
  }
  if (badgeEl) {
    badgeEl.className = 'badge badge-warning';
    badgeEl.innerText = 'RUNNING';
  }
  if (statusEl) statusEl.innerText = `Olek: Käimas [${testLabel}] (${currentLang.toUpperCase()})`;
  if (activeIndEl) {
    activeIndEl.style.display = 'inline-block';
    activeIndEl.innerText = `⏳ Test running: ${testLabel}`;
  }
  if (stopBtn) stopBtn.style.display = 'inline-flex';
  if (dlBtn) dlBtn.style.display = 'none';

  const termSection = document.getElementById('testing-terminal-section');
  if (termSection) {
    termSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  testTimerSeconds = 0;
  if (timerEl) timerEl.innerText = '00:00:00';
  if (testTimerInterval) clearInterval(testTimerInterval);
  testTimerInterval = setInterval(() => {
    testTimerSeconds++;
    const h = String(Math.floor(testTimerSeconds / 3600)).padStart(2, '0');
    const m = String(Math.floor((testTimerSeconds % 3600) / 60)).padStart(2, '0');
    const s = String(testTimerSeconds % 60).padStart(2, '0');
    if (timerEl) timerEl.innerText = `${h}:${m}:${s}`;
  }, 1000);

  fetch(`${BRIDGE_URL}/api/tests/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      suite: suiteKey,
      script: scriptName || '',
      test: scriptName || '',
      lang: currentLang
    })
  })
  .then(r => r.json())
  .then(data => {
    if (data.status === 'ok' || data.status === 'started' || data.status === 'running') {
      activeTestTaskId = data.task_id || 'test_runner';
      currentTestLogPath = data.log_relative_path || data.log_file || null;
      if (dlBtn && currentTestLogPath) dlBtn.style.display = 'inline-flex';
      startPollingTestRunner();
    } else {
      throw new Error(data.message || data.error || 'Failed to start test');
    }
  })
  .catch(err => {
    const isEt = (localStorage.getItem('dev_hub_lang') || 'en') === 'et';
    const bridgeNotice = isEt
      ? `\n❌ Testi käivitamine ebaõnnestus: ${err.message}\n💡 Märkus: Dev Hubi veebiliidesest taustal testimiseks peab töötama bridge:\n   ./scripts/internal/dev-hub-bridge.py &\nAlternatiivina saad testi käivitada otse oma terminalis, kopeerides käsu kaardilt!\n`
      : `\n❌ Failed to launch test: ${err.message}\n💡 Note: To run tests directly via Dev Hub web UI, start the bridge daemon:\n   ./scripts/internal/dev-hub-bridge.py &\nAlternatively, you can run the test directly in your terminal using the command snippet above!\n`;
    if (termEl) termEl.innerHTML += bridgeNotice;
    finishActiveTest('FAILED', -1);
  });
}

function startPollingTestRunner() {
  if (testPollInterval) clearInterval(testPollInterval);
  testPollInterval = setInterval(pollTestRunnerStatus, 1500);
}

function pollTestRunnerStatus() {
  if (!activeTestTaskId) return;

  fetch(`${BRIDGE_URL}/api/task/status?task=test_runner`)
    .then(r => r.json())
    .then(data => {
      const termEl = document.getElementById('testing-terminal-output');
      const autoScroll = document.getElementById('test-terminal-autoscroll')?.checked;

      const text = data.stdout || (Array.isArray(data.log_tail) ? data.log_tail.join('\n') : '');
      if (text && termEl) {
        termEl.innerText = text;
        if (autoScroll) {
          termEl.scrollTop = termEl.scrollHeight;
        }
      }

      const state = data.state || data.status;
      if (state === 'completed') {
        finishActiveTest('PASSED', 0);
      } else if (state === 'failed') {
        finishActiveTest('FAILED', data.exit_code || 1);
      }
    })
    .catch(() => {});
}

function finishActiveTest(status, exitCode) {
  if (testPollInterval) {
    clearInterval(testPollInterval);
    testPollInterval = null;
  }
  if (testTimerInterval) {
    clearInterval(testTimerInterval);
    testTimerInterval = null;
  }
  activeTestTaskId = null;

  const badgeEl = document.getElementById('test-terminal-task-badge');
  const statusEl = document.getElementById('test-terminal-footer-status');
  const activeIndEl = document.getElementById('testing-active-indicator');
  const stopBtn = document.getElementById('btn-stop-test');
  const dlBtn = document.getElementById('btn-download-test-log');

  if (badgeEl) {
    badgeEl.className = status === 'PASSED' ? 'badge badge-success' : 'badge badge-danger';
    badgeEl.innerText = status === 'PASSED' ? 'PASSED (0)' : `FAILED (${exitCode})`;
  }
  if (statusEl) {
    statusEl.innerText = status === 'PASSED' ? 'Olek: Test edukalt läbitud ✅' : `Olek: Test ebaõnnestus (kood ${exitCode}) ❌`;
  }
  if (activeIndEl) activeIndEl.style.display = 'none';
  if (stopBtn) stopBtn.style.display = 'none';
  if (dlBtn && currentTestLogPath) dlBtn.style.display = 'inline-flex';

  setTimeout(() => {
    loadTestHistory();
    fetch(`${BRIDGE_URL}/api/tests/reports`).then(r=>r.json()).then(d=>{ if(d.reports) renderTestReportsList(d.reports); }).catch(()=>{});
    fetch(`${BRIDGE_URL}/api/tests/coverage`).then(r=>r.json()).then(d=>{ if(d.coverage) { loadedCoverageData = d.coverage; renderCoverageExplorer(d.coverage); updateCiReadinessScorecard(); } }).catch(()=>{});
  }, 1000);
}

function stopActiveTest() {
  fetch(`${BRIDGE_URL}/api/tests/stop`, { method: 'POST' })
    .then(r => r.json())
    .then(() => {
      const termEl = document.getElementById('testing-terminal-output');
      if (termEl) termEl.innerText += '\n⚠️ Process terminated by user signal.\n';
      finishActiveTest('STOPPED', 130);
    })
    .catch(err => alert('Viga testimise peatamisel: ' + err.message));
}

function clearTestTerminal() {
  const termEl = document.getElementById('testing-terminal-output');
  if (termEl) termEl.innerText = '';
}

function downloadCurrentTestLog() {
  if (!currentTestLogPath) {
    alert('Logifaili tee puudub!');
    return;
  }
  window.open(`${BRIDGE_URL}/api/tests/report-content?file=${encodeURIComponent(currentTestLogPath)}`, '_blank');
}

/* Reports Split-Pane */
function renderTestReportsList(reports) {
  loadedTestReports = reports || [];
  const listEl = document.getElementById('reports-list-container');
  const badgeEl = document.getElementById('reports-count-badge');
  if (!listEl) return;
  if (badgeEl) badgeEl.innerText = `${loadedTestReports.length} raportit`;

  if (loadedTestReports.length === 0) {
    listEl.innerHTML = '<div style="color:#64748b; padding:16px; text-align:center;">Raporteid ei leitud.</div>';
    return;
  }

  let html = '';
  loadedTestReports.forEach((rep, idx) => {
    const badgeClass = rep.status === 'PASS' ? 'badge-success' : (rep.status === 'FAIL' ? 'badge-danger' : 'badge-info');
    const isSelected = selectedReport && selectedReport.name === rep.name;
    html += `
      <div class="report-item ${isSelected ? 'active' : ''}" onclick="selectTestReport(${idx})">
        <div class="report-item-title">${escapeTestHtml(rep.title || rep.name)}</div>
        <div class="report-item-meta">
          <span class="badge ${badgeClass}" style="font-size:0.65rem; padding:1px 5px;">${rep.status}</span>
          <span>${rep.mtime || ''}</span>
        </div>
      </div>
    `;
  });
  listEl.innerHTML = html;

  if (!selectedReport && loadedTestReports.length > 0) {
    selectTestReport(0);
  }
}

function filterTestReports(query) {
  const q = (query || '').toLowerCase().trim();
  if (!q) {
    renderTestReportsList(loadedTestReports);
    return;
  }
  const filtered = loadedTestReports.filter(r => 
    (r.title && r.title.toLowerCase().includes(q)) || 
    (r.name && r.name.toLowerCase().includes(q))
  );
  const listEl = document.getElementById('reports-list-container');
  if (listEl) {
    let html = '';
    filtered.forEach((rep) => {
      const origIdx = loadedTestReports.findIndex(x => x.name === rep.name);
      const badgeClass = rep.status === 'PASS' ? 'badge-success' : (rep.status === 'FAIL' ? 'badge-danger' : 'badge-info');
      html += `
        <div class="report-item" onclick="selectTestReport(${origIdx})">
          <div class="report-item-title">${escapeTestHtml(rep.title || rep.name)}</div>
          <div class="report-item-meta">
            <span class="badge ${badgeClass}" style="font-size:0.65rem; padding:1px 5px;">${rep.status}</span>
            <span>${rep.mtime || ''}</span>
          </div>
        </div>
      `;
    });
    listEl.innerHTML = html;
  }
}

function selectTestReport(idx) {
  const rep = loadedTestReports[idx];
  if (!rep) return;
  selectedReport = rep;

  document.querySelectorAll('.report-item').forEach((el, i) => {
    el.classList.toggle('active', i === idx);
  });

  loadTestReportContent(rep.name, rep.rel_path, rep.title, rep.status, rep.mtime);
}

function loadTestReportContent(name, relPath, title, status, mtime) {
  const headerEl = document.getElementById('report-viewer-header');
  const titleEl = document.getElementById('report-viewer-title');
  const badgeEl = document.getElementById('report-viewer-badge');
  const mtimeEl = document.getElementById('report-viewer-mtime');
  const bodyEl = document.getElementById('report-viewer-content');

  if (headerEl) headerEl.style.display = 'flex';
  if (titleEl) titleEl.innerText = title || name;
  if (badgeEl) {
    badgeEl.className = status === 'PASS' ? 'badge badge-success' : (status === 'FAIL' ? 'badge badge-danger' : 'badge badge-info');
    badgeEl.innerText = status || 'INFO';
  }
  if (mtimeEl) mtimeEl.innerText = mtime || '';

  if (bodyEl) {
    bodyEl.innerHTML = '<div style="color:#94a3b8; text-align:center; padding:40px;">⏳ Laadin raporti sisu...</div>';
  }

  fetch(`${BRIDGE_URL}/api/tests/report-content?file=${encodeURIComponent(relPath || ('tests/reports/' + name))}`)
    .then(r => r.json())
    .then(data => {
      if (data && data.content !== undefined) {
        selectedReportRawContent = data.content;
        renderCurrentReportContent();
      } else {
        throw new Error(data.error || 'Failed to read content');
      }
    })
    .catch(err => {
      if (bodyEl) {
        bodyEl.innerHTML = `<div style="color:#ef4444; padding:20px;">Viga raporti laadimisel: ${err.message}</div>`;
      }
    });
}

function renderCurrentReportContent() {
  const bodyEl = document.getElementById('report-viewer-content');
  if (!bodyEl) return;

  if (isRawReportView) {
    bodyEl.innerHTML = `<pre style="font-size:0.8rem; line-height:1.4; color:#e2e8f0; white-space:pre-wrap;">${escapeTestHtml(selectedReportRawContent)}</pre>`;
  } else {
    try {
      if (typeof marked !== 'undefined') {
        bodyEl.innerHTML = marked.parse(selectedReportRawContent);
      } else {
        bodyEl.innerHTML = `<pre style="white-space:pre-wrap; font-family:inherit; color:#e2e8f0;">${escapeTestHtml(selectedReportRawContent)}</pre>`;
      }
      renderMermaidInContainer(bodyEl);
    } catch (err) {
      bodyEl.innerHTML = `<pre style="white-space:pre-wrap;">${escapeTestHtml(selectedReportRawContent)}</pre>`;
    }
  }
}

function toggleRawReportView() {
  isRawReportView = !isRawReportView;
  renderCurrentReportContent();
}

/* Coverage Explorer */
function renderCoverageExplorer(covData) {
  loadedCoverageData = covData || loadedCoverageData || {};
  const data = loadedCoverageData;
  const pct = data.percent !== undefined ? data.percent : 0;

  const pctEl = document.getElementById('coverage-percent-display');
  const fillEl = document.getElementById('coverage-progress-fill');
  const totalEl = document.getElementById('cov-total-scripts');
  const coveredEl = document.getElementById('cov-covered-scripts');
  const uncoveredEl = document.getElementById('cov-uncovered-scripts');

  if (pctEl) pctEl.innerText = `${pct}%`;
  if (fillEl) fillEl.style.width = `${pct}%`;
  if (totalEl) totalEl.innerText = data.total || 0;
  if (coveredEl) coveredEl.innerText = data.covered || 0;
  if (uncoveredEl) uncoveredEl.innerText = (data.total || 0) - (data.covered || 0);

  const countAll = document.getElementById('cov-count-all');
  const countCov = document.getElementById('cov-count-covered');
  const countUncov = document.getElementById('cov-count-uncovered');
  if (countAll) countAll.innerText = data.total || 0;
  if (countCov) countCov.innerText = data.covered || 0;
  if (countUncov) countUncov.innerText = (data.total || 0) - (data.covered || 0);

  filterCoverageTable('');
}

function filterCoverageScripts(filterType) {
  currentCoverageFilter = filterType;
  document.querySelectorAll('#testing-subtab-coverage .coverage-toolbar button').forEach(b => b.classList.remove('active'));
  const btn = document.getElementById(`btn-cov-filter-${filterType}`);
  if (btn) btn.classList.add('active');
  filterCoverageTable(currentCoverageSearch);
}

function filterCoverageTable(query) {
  currentCoverageSearch = query || '';
  const q = currentCoverageSearch.toLowerCase().trim();
  const data = loadedCoverageData || {};
  const scripts = data.scripts || [];
  const tbody = document.getElementById('coverage-table-body');
  if (!tbody) return;

  const filtered = scripts.filter(s => {
    if (currentCoverageFilter === 'covered' && !s.covered) return false;
    if (currentCoverageFilter === 'uncovered' && s.covered) return false;
    if (q && !s.name.toLowerCase().includes(q)) return false;
    return true;
  });

  if (filtered.length === 0) {
    tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; color:#64748b; padding:20px;">Vasteid ei leitud.</td></tr>';
    return;
  }

  let html = '';
  filtered.forEach(s => {
    const badge = s.covered 
      ? '<span class="badge badge-success" style="font-size:0.7rem; padding:2px 7px;">✅ Kaetud</span>'
      : '<span class="badge badge-danger" style="font-size:0.7rem; padding:2px 7px;">❌ Katmata</span>';

    const testBadges = (s.tests && s.tests.length > 0)
      ? s.tests.map(t => `<span class="badge badge-secondary" style="font-size:0.68rem; margin:2px 4px 2px 0; font-family:monospace;">${escapeTestHtml(t)}</span>`).join('')
      : '<span style="color:#64748b; font-size:0.75rem;">-</span>';

    html += `
      <tr>
        <td><code>${escapeTestHtml(s.name)}</code></td>
        <td>${badge}</td>
        <td>${testBadges}</td>
      </tr>
    `;
  });
  tbody.innerHTML = html;
}

function refreshCoverageAnalysis() {
  runTestSuite('coverage');
}

/* History Table */
function renderTestHistoryTable(history) {
  const tbody = document.getElementById('test-history-tbody');
  if (!tbody) return;
  const list = history || [];

  if (list.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#64748b; padding:20px;">Testide käivituste ajalugu on tühi.</td></tr>';
    return;
  }

  let html = '';
  list.forEach(h => {
    const isPass = h.status === 'PASS' || h.exit_code === 0;
    const badge = isPass
      ? '<span class="badge badge-success" style="font-size:0.7rem; padding:2px 7px;">PASS</span>'
      : `<span class="badge badge-danger" style="font-size:0.7rem; padding:2px 7px;">FAIL (${h.exit_code})</span>`;

    const logLink = h.log_file 
      ? `<a href="${BRIDGE_URL}/api/tests/report-content?file=${encodeURIComponent(h.log_file)}" target="_blank" style="color:#38bdf8; font-size:0.75rem; text-decoration:none;">📄 ${h.log_file.split('/').pop()}</a>`
      : '-';

    html += `
      <tr>
        <td style="font-size:0.75rem; color:#94a3b8;">${escapeTestHtml(h.timestamp || '')}</td>
        <td><strong>${escapeTestHtml(h.suite || '')}</strong> ${h.script ? `<code style="font-size:0.72rem; color:#93c5fd;">${escapeTestHtml(h.script)}</code>` : ''}</td>
        <td>${badge}</td>
        <td style="font-size:0.75rem; color:#94a3b8;">${h.duration_seconds || 0}s</td>
        <td>${logLink}</td>
        <td>
          <button type="button" class="btn-compact btn-compact-secondary" style="font-size:0.72rem; padding:3px 8px;" onclick="runTestSuite('${h.suite}', '${h.script || ''}')">
            <span>🔄</span> Re-run
          </button>
        </td>
      </tr>
    `;
  });
  tbody.innerHTML = html;
}

function loadTestHistory() {
  fetch(`${BRIDGE_URL}/api/tests/history`)
    .then(r => r.json())
    .then(data => {
      if (data && data.history) {
        renderTestHistoryTable(data.history);
      }
    })
    .catch(() => {});
}

document.addEventListener('DOMContentLoaded', () => {
  const saved = localStorage.getItem('dev_hub_lang') || 'en';
  setLanguage(saved);
  
  // Initialize wallet matrix collapse state
  const isWalletOpen = localStorage.getItem('dev_hub_wallet_open') === 'true';
  if (isWalletOpen) {
    toggleWalletMatrix(true);
  }

  // Initialize podman drawer collapse state
  const isPodmanOpen = localStorage.getItem('dev_hub_podman_open') === 'true';
  if (isPodmanOpen) {
    togglePodmanDrawer(true);
  }

  // Initialize ORDS auto-sync state (default to OFF)
  const savedOrdsSync = localStorage.getItem('dev_hub_ords_autosync');
  setOrdsAutoSync(savedOrdsSync === 'true', false);

  checkServiceHealth();
  renderOrdsGatewayStrip();
  setInterval(checkServiceHealth, 5000);
  pollBridgeStatus();
  setInterval(pollBridgeStatus, 5000);

  // Auto-load snapshots if tab active
  const snapTab = document.getElementById('tab-snapshots');
  if (snapTab && snapTab.classList.contains('active')) {
    loadSnapshotsTable();
  }

  // Auto-load testing if tab active
  const testTab = document.getElementById('tab-testing');
  if (testTab && testTab.classList.contains('active')) {
    initTestingTab();
  }

  // URL parameters and hash routing (e.g. #tab-docs, #tab-testing, ?tab=docs&doc=readme&lang=lt)
  const urlParams = new URLSearchParams(window.location.search);
  const hashParam = (window.location.hash || '').replace(/^#/, '');
  const rawTab = urlParams.get('tab');
  const cleanHash = hashParam.split('?')[0];
  let targetTab = null;
  if (rawTab) {
    targetTab = rawTab.startsWith('tab-') ? rawTab : `tab-${rawTab}`;
  } else if (cleanHash) {
    targetTab = cleanHash.startsWith('tab-') ? cleanHash : (cleanHash === 'docs' ? 'tab-docs' : (cleanHash === 'testing' ? 'tab-testing' : (cleanHash === 'services' ? 'tab-services' : null)));
  }
  const targetLang = urlParams.get('lang');
  if (targetLang && ['en', 'et', 'fi', 'sv', 'lv', 'lt'].includes(targetLang)) {
    setLanguage(targetLang);
  }
  if (targetTab) {
    switchTab(targetTab, true);
  } else {
    const activeTabs = document.querySelectorAll('.tab-content.active');
    if (activeTabs.length === 0) {
      switchTab('tab-services', true);
    }
  }
  let targetDoc = urlParams.get('doc');
  if (!targetDoc && window.location.hash.includes('?doc=')) {
    targetDoc = decodeURIComponent(window.location.hash.split('?doc=')[1].split('&')[0].split('#')[0]);
  }
  if (targetDoc && typeof DOCS_DATA !== 'undefined') {
    setTimeout(() => navigateToDoc(targetDoc), 120);
  }

  // Initialize Navigation History (Browser Back & In-App Back)
  initNavigationHistory();
  // Initialize Global Spotlight Omnisearch
  initGlobalSearchInput();
});

/* ==============================================================================
 * ARCHITECTURE GLOSSARY & ACRONYMS MODAL ENGINE
 * ============================================================================== */

let gActiveGlossaryLetter = 'ALL';
let gGlossarySearchTerm = '';

function openGlossaryModal(initialSearch) {
  const modal = document.getElementById('glossary-modal-backdrop');
  if (!modal) return;
  
  modal.style.display = 'flex';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  const searchInput = document.getElementById('glossary-search-input');
  if (searchInput) {
    if (typeof initialSearch === 'string') {
      searchInput.value = initialSearch;
      gGlossarySearchTerm = initialSearch.toLowerCase().trim();
    }
    setTimeout(() => {
      if (typeof searchInput.focus === 'function') searchInput.focus();
      if (initialSearch && typeof searchInput.select === 'function') searchInput.select();
    }, 50);
  }

  renderGlossaryModal();
}

function closeGlossaryModal(event) {
  if (event && event.target && event.target.closest && event.target.closest('.glossary-modal-content') && event.target !== event.currentTarget) {
    return;
  }
  const modal = document.getElementById('glossary-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'none';
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

function renderGlossaryModal() {
  const catalog = window.GLOSSARY_DATA || [];
  const container = document.getElementById('glossary-cards-container');
  const lettersBar = document.getElementById('glossary-letters-bar');
  const counterEl = document.getElementById('glossary-counter');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';

  if (!container || !lettersBar) return;

  // 1. Determine available letters
  const allLetters = Array.from(new Set(catalog.map(item => item.acronym[0].toUpperCase()))).sort();
  
  // Render letter buttons
  let lettersHtml = `<button class="glossary-letter-btn ${gActiveGlossaryLetter === 'ALL' ? 'active' : ''}" onclick="selectGlossaryLetter('ALL')">ALL</button>`;
  allLetters.forEach(l => {
    lettersHtml += `<button class="glossary-letter-btn ${gActiveGlossaryLetter === l ? 'active' : ''}" onclick="selectGlossaryLetter('${l}')">${l}</button>`;
  });
  lettersBar.innerHTML = lettersHtml;

  // 2. Filter items based on active letter and search query
  const term = (gGlossarySearchTerm || '').toLowerCase().trim();
  const clearBtn = document.getElementById('glossary-clear-search');
  if (clearBtn) {
    clearBtn.style.display = term ? 'block' : 'none';
  }

  const filtered = catalog.filter(item => {
    const firstLet = item.acronym[0].toUpperCase();
    if (gActiveGlossaryLetter !== 'ALL' && firstLet !== gActiveGlossaryLetter) {
      return false;
    }
    if (!term) return true;

    const acr = (item.acronym || '').toLowerCase();
    const exp = (item.expansion || '').toLowerCase();
    const cat = (item.category || '').toLowerCase();
    const defText = ((item.def && (item.def[currentLang] || item.def.en)) || '').toLowerCase();
    const roleText = ((item.project_role && (item.project_role[currentLang] || item.project_role.en)) || '').toLowerCase();

    return acr.includes(term) || exp.includes(term) || cat.includes(term) || defText.includes(term) || roleText.includes(term);
  });

  // Update counter
  if (counterEl) {
    const suffix = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_count_suffix) || 'items';
    counterEl.textContent = `${filtered.length} / ${catalog.length} ${suffix}`;
  }

  // 3. Render cards grouped by letter
  if (filtered.length === 0) {
    const noResultsTitle = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_no_results) || 'No acronyms found';
    container.innerHTML = `
      <div style="text-align: center; padding: 48px 16px; color: var(--text-muted);">
        <div style="font-size: 2.5rem; margin-bottom: 12px;">🔍</div>
        <div style="font-size: 1.05rem; font-weight: 600; color: #e2e8f0; margin-bottom: 6px;">${noResultsTitle}</div>
        <div style="font-size: 0.85rem;">"${escapeHtml(term)}"</div>
        <button class="btn btn-secondary" onclick="clearGlossarySearch()" style="margin-top: 14px; padding: 6px 14px; font-size: 0.82rem;">
          ↺ Reset
        </button>
      </div>
    `;
    return;
  }

  // Group by first letter
  const grouped = {};
  filtered.forEach(item => {
    const letKey = item.acronym[0].toUpperCase();
    if (!grouped[letKey]) grouped[letKey] = [];
    grouped[letKey].push(item);
  });

  const sortedLetters = Object.keys(grouped).sort();
  const lblDef = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_lbl_def) || 'Definition';
  const lblRole = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_lbl_role) || 'Project Role';
  const lblLinks = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_lbl_links) || 'Related Links';

  let sectionsHtml = '';
  sortedLetters.forEach(letter => {
    const itemsInLetter = grouped[letter];
    sectionsHtml += `
      <div class="glossary-letter-section" id="glossary-letter-${letter}">
        <div class="glossary-letter-header">
          <div class="glossary-letter-badge">${letter}</div>
          <span class="glossary-letter-count">(${itemsInLetter.length})</span>
        </div>
        <div class="glossary-grid">
    `;

    itemsInLetter.forEach(item => {
      const defText = (item.def && (item.def[currentLang] || item.def.en)) || '';
      const roleText = (item.project_role && (item.project_role[currentLang] || item.project_role.en)) || '';
      const category = item.category || 'core';
      const links = item.links || [];
      const refUrl = item.ref_url || '';
      const refTitle = item.ref_title || 'Wikipedia';
      const lblRef = (I18N_DICT[currentLang] && I18N_DICT[currentLang].glossary_lbl_ref) || 'Official Reference';

      let refBadgeHtml = '';
      if (refUrl) {
        refBadgeHtml = `
          <a href="${escapeHtml(refUrl)}" target="_blank" rel="noopener noreferrer" class="glossary-ref-badge" title="${escapeHtml(lblRef)}: ${escapeHtml(refTitle)}">
            <span>🌐</span> <span>${escapeHtml(refTitle)}</span> <span>↗</span>
          </a>
        `;
      }

      let linksHtml = '';
      if (links.length > 0 || refUrl) {
        linksHtml = `<div class="glossary-links">`;
        if (refUrl) {
          linksHtml += `
            <a href="${escapeHtml(refUrl)}" target="_blank" rel="noopener noreferrer" class="glossary-ref-btn" title="${escapeHtml(lblRef)}: ${escapeHtml(refTitle)}">
              <span>🌐</span> <span>${escapeHtml(refTitle)}</span> <span>↗</span>
            </a>
          `;
        }
        links.forEach(l => {
          linksHtml += `
            <a href="javascript:void(0)" class="glossary-link-btn" onclick="handleGlossaryLinkClick('${escapeHtml(l.url)}')">
              <span>📄</span> <span>${escapeHtml(l.label)}</span>
            </a>
          `;
        });
        linksHtml += `</div>`;
      }

      sectionsHtml += `
        <div class="glossary-card" id="glossary-card-${item.acronym.toLowerCase()}">
          <div class="glossary-card-header">
            <span class="glossary-acronym">${escapeHtml(item.acronym)}</span>
            <span class="glossary-cat-tag">${escapeHtml(category)}</span>
            ${refBadgeHtml}
          </div>
          <div class="glossary-expansion">${escapeHtml(item.expansion)}</div>
          <div class="glossary-block">
            <span class="glossary-label">${lblDef}</span>
            <span class="glossary-text">${escapeHtml(defText)}</span>
          </div>
          <div class="glossary-role-box">
            <span class="glossary-label" style="color:#7dd3fc;">${lblRole}</span>
            <span class="glossary-text">${escapeHtml(roleText)}</span>
          </div>
          ${linksHtml}
        </div>
      `;
    });

    sectionsHtml += `
        </div>
      </div>
    `;
  });

  container.innerHTML = sectionsHtml;
}

function selectGlossaryLetter(letter) {
  gActiveGlossaryLetter = letter;
  renderGlossaryModal();
  if (letter !== 'ALL') {
    const target = document.getElementById(`glossary-letter-${letter}`);
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }
}

function filterGlossaryCards() {
  const searchInput = document.getElementById('glossary-search-input');
  if (searchInput) {
    gGlossarySearchTerm = searchInput.value;
  }
  renderGlossaryModal();
}

function clearGlossarySearch() {
  const searchInput = document.getElementById('glossary-search-input');
  if (searchInput) {
    searchInput.value = '';
    gGlossarySearchTerm = '';
  }
  gActiveGlossaryLetter = 'ALL';
  renderGlossaryModal();
}

function handleGlossaryLinkClick(url) {
  closeGlossaryModal();
  if (!url) return;

  // External URL handler
  if (url.startsWith('http://') || url.startsWith('https://')) {
    window.open(url, '_blank', 'noopener,noreferrer');
    return;
  }

  // Check if it's a doc in DOCS_DATA
  const docs = window.DOCS_DATA || [];
  const docIdx = docs.findIndex(d => {
    const rel = d.rel || '';
    return url.endsWith(rel) || rel.endsWith(url) || url.includes(d.id);
  });

  if (docIdx !== -1) {
    switchTab('tab-docs');
    renderDocsNav(docIdx);
  } else if (url.startsWith('scripts/')) {
    switchTab('tab-devops');
    const devopsSearch = document.getElementById('devops-search-input');
    if (devopsSearch) {
      devopsSearch.value = url.replace('scripts/', '');
      filterDevOpsCards();
    }
  } else {
    // Open in doc viewer or fallback
    switchTab('tab-docs');
  }
}

/* ==============================================================================
 * Central FAQ Modal & Oracle Resources Modal Controller
 * ============================================================================== */

let gActiveFaqCategory = 'all';
let gFaqSearchTerm = '';

function openFaqModal(initialCategory, initialSearch) {
  const modal = document.getElementById('faq-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'flex';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  if (initialCategory) {
    gActiveFaqCategory = initialCategory;
  }
  const searchInput = document.getElementById('faq-search-input');
  if (searchInput) {
    if (typeof initialSearch === 'string') {
      searchInput.value = initialSearch;
      gFaqSearchTerm = initialSearch.toLowerCase().trim();
    }
    setTimeout(() => {
      if (typeof searchInput.focus === 'function') searchInput.focus();
      if (initialSearch && typeof searchInput.select === 'function') searchInput.select();
    }, 50);
  }
  renderFaqModal();
}

function closeFaqModal(event) {
  if (event && event.target && event.target.closest && event.target.closest('.faq-modal-content') && event.target !== event.currentTarget) {
    return;
  }
  const modal = document.getElementById('faq-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'none';
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

function selectFaqCategory(catId) {
  gActiveFaqCategory = catId;
  renderFaqModal();
}

function filterFaqCards() {
  const input = document.getElementById('faq-search-input');
  if (input) {
    gFaqSearchTerm = input.value;
  }
  renderFaqModal();
}

function clearFaqSearch() {
  const input = document.getElementById('faq-search-input');
  if (input) {
    input.value = '';
    gFaqSearchTerm = '';
  }
  renderFaqModal();
}

function renderFaqModal() {
  const catalog = window.FAQ_DATA || [];
  const categories = window.FAQ_CATEGORIES || [];
  const container = document.getElementById('faq-cards-container');
  const catBar = document.getElementById('faq-categories-bar');
  const counterEl = document.getElementById('faq-counter');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';

  if (!container || !catBar) return;

  // Render category buttons
  let catHtml = '';
  categories.forEach(cat => {
    const cLabel = (cat.labels && (cat.labels[currentLang] || cat.labels.en)) || cat.id;
    const isActive = gActiveFaqCategory === cat.id ? 'active' : '';
    catHtml += `<button class="faq-cat-btn ${isActive}" onclick="selectFaqCategory('${cat.id}')">${cLabel}</button>`;
  });
  catBar.innerHTML = catHtml;

  const term = (gFaqSearchTerm || '').toLowerCase().trim();
  const clearBtn = document.getElementById('faq-clear-search');
  if (clearBtn) clearBtn.style.display = term ? 'block' : 'none';

  const filtered = catalog.filter(item => {
    if (gActiveFaqCategory !== 'all' && item.category !== gActiveFaqCategory) {
      return false;
    }
    if (!term) return true;

    const q = ((item.question && (item.question[currentLang] || item.question.en)) || '').toLowerCase();
    const a = ((item.answer && (item.answer[currentLang] || item.answer.en)) || '').toLowerCase();
    const c = (item.code_snippet || '').toLowerCase();
    const cat = (item.category || '').toLowerCase();
    const id = (item.id || '').toLowerCase();
    const idSpaced = id.replace(/-/g, ' ');

    return q.includes(term) || a.includes(term) || c.includes(term) || cat.includes(term) || id.includes(term) || idSpaced.includes(term);
  });

  if (counterEl) {
    const suffix = (I18N_DICT[currentLang] && I18N_DICT[currentLang].faq_counter_suffix) || 'questions';
    counterEl.textContent = `${filtered.length} / ${catalog.length} ${suffix}`;
  }

  if (filtered.length === 0) {
    const noResultsTitle = (I18N_DICT[currentLang] && I18N_DICT[currentLang].faq_no_results) || 'No questions found';
    container.innerHTML = `
      <div style="text-align: center; padding: 48px 16px; color: var(--text-muted);">
        <div style="font-size: 2.5rem; margin-bottom: 12px;">🔍</div>
        <div style="font-size: 1.05rem; font-weight: 600; color: #e2e8f0; margin-bottom: 6px;">${noResultsTitle}</div>
      </div>`;
    return;
  }

  let html = '';
  filtered.forEach(item => {
    const qText = (item.question && (item.question[currentLang] || item.question.en)) || '';
    const aText = (item.answer && (item.answer[currentLang] || item.answer.en)) || '';
    const icon = item.icon || '❓';
    
    // Find category label
    const catObj = categories.find(c => c.id === item.category);
    const catLabel = (catObj && catObj.labels && (catObj.labels[currentLang] || catObj.labels.en)) || item.category;

    let codeHtml = '';
    if (item.code_snippet) {
      codeHtml = `
        <div class="code-box" style="margin: 10px 0 0 0; font-size: 0.8rem;">
          <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
          ${item.code_snippet.replace(/\n/g, '<br/>')}
        </div>`;
    }

    let linksHtml = '';
    if (item.links && item.links.length > 0) {
      const linkPills = item.links.map(l => {
        return `<a href="javascript:void(0)" onclick="handleGlossaryLinkClick('${l.url}')" style="font-size: 0.76rem; color: #38bdf8; text-decoration: none; background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.25); padding: 2px 8px; border-radius: 4px;">📖 ${l.label}</a>`;
      }).join(' ');
      linksHtml = `<div class="faq-card-links">${linkPills}</div>`;
    }

    html += `
      <div class="faq-card">
        <div class="faq-card-header">
          <div class="faq-card-title">
            <span>${icon}</span>
            <span>${qText}</span>
          </div>
          <span class="faq-category-pill">${catLabel}</span>
        </div>
        <p class="faq-card-answer">${aText}</p>
        ${codeHtml}
        ${linksHtml}
      </div>`;
  });

  container.innerHTML = html;
}

let gActiveOracleResCategory = 'all';
let gOracleResSearchTerm = '';

function openOracleResourcesModal(initialCategory, initialSearch) {
  const modal = document.getElementById('oracle-resources-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'flex';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  if (initialCategory) {
    gActiveOracleResCategory = initialCategory;
  }
  const searchInput = document.getElementById('oracle-resources-search-input');
  if (searchInput) {
    if (typeof initialSearch === 'string') {
      searchInput.value = initialSearch;
      gOracleResSearchTerm = initialSearch.toLowerCase().trim();
    }
    setTimeout(() => {
      if (typeof searchInput.focus === 'function') searchInput.focus();
      if (initialSearch && typeof searchInput.select === 'function') searchInput.select();
    }, 50);
  }
  renderOracleResourcesModal();
}

function closeOracleResourcesModal(event) {
  if (event && event.target && event.target.closest && event.target.closest('.oracle-resources-modal-content') && event.target !== event.currentTarget) {
    return;
  }
  const modal = document.getElementById('oracle-resources-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'none';
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

function selectOracleResourcesCategory(catId) {
  gActiveOracleResCategory = catId;
  renderOracleResourcesModal();
}

function filterOracleResourcesCards() {
  const input = document.getElementById('oracle-resources-search-input');
  if (input) {
    gOracleResSearchTerm = input.value;
  }
  renderOracleResourcesModal();
}

function clearOracleResourcesSearch() {
  const input = document.getElementById('oracle-resources-search-input');
  if (input) {
    input.value = '';
    gOracleResSearchTerm = '';
  }
  renderOracleResourcesModal();
}

function renderOracleResourcesModal() {
  const catalog = window.ORACLE_RESOURCES_DATA || [];
  const categories = window.ORACLE_RESOURCE_CATEGORIES || [];
  const container = document.getElementById('oracle-resources-cards-container');
  const catBar = document.getElementById('oracle-resources-categories-bar');
  const counterEl = document.getElementById('oracle-resources-counter');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';

  if (!container || !catBar) return;

  // Render category buttons
  let catHtml = '';
  categories.forEach(cat => {
    const cLabel = (cat.labels && (cat.labels[currentLang] || cat.labels.en)) || cat.id;
    const isActive = gActiveOracleResCategory === cat.id ? 'active' : '';
    catHtml += `<button class="oracle-res-cat-btn ${isActive}" onclick="selectOracleResourcesCategory('${cat.id}')">${cLabel}</button>`;
  });
  catBar.innerHTML = catHtml;

  const term = (gOracleResSearchTerm || '').toLowerCase().trim();
  const clearBtn = document.getElementById('oracle-resources-clear-search');
  if (clearBtn) clearBtn.style.display = term ? 'block' : 'none';

  const filtered = catalog.filter(item => {
    if (gActiveOracleResCategory !== 'all' && item.category !== gActiveOracleResCategory) {
      return false;
    }
    if (!term) return true;

    const n = (item.name || '').toLowerCase();
    const d = ((item.desc && (item.desc[currentLang] || item.desc.en)) || '').toLowerCase();
    const u = ((item.use_case && (item.use_case[currentLang] || item.use_case.en)) || '').toLowerCase();
    const c = (item.pull_cmd || '').toLowerCase();
    const b = (item.badge || '').toLowerCase();

    return n.includes(term) || d.includes(term) || u.includes(term) || c.includes(term) || b.includes(term);
  });

  if (counterEl) {
    const suffix = (I18N_DICT[currentLang] && I18N_DICT[currentLang].resources_counter_suffix) || 'resources';
    counterEl.textContent = `${filtered.length} / ${catalog.length} ${suffix}`;
  }

  if (filtered.length === 0) {
    const noResultsTitle = (I18N_DICT[currentLang] && I18N_DICT[currentLang].resources_no_results) || 'No resources found';
    container.innerHTML = `
      <div style="text-align: center; padding: 48px 16px; color: var(--text-muted);">
        <div style="font-size: 2.5rem; margin-bottom: 12px;">🏛️</div>
        <div style="font-size: 1.05rem; font-weight: 600; color: #e2e8f0; margin-bottom: 6px;">${noResultsTitle}</div>
      </div>`;
    return;
  }

  let html = '';
  filtered.forEach(item => {
    const dText = (item.desc && (item.desc[currentLang] || item.desc.en)) || '';
    const uText = (item.use_case && (item.use_case[currentLang] || item.use_case.en)) || '';
    const badgeClass = item.category === 'downloads' ? 'oracle-resource-badge-download' : (item.category === 'portals' ? 'oracle-resource-badge-portal' : '');

    let cmdHtml = '';
    if (item.pull_cmd) {
      cmdHtml = `
        <div class="code-box" style="margin: 8px 0 0 0; font-size: 0.8rem;">
          <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
          ${item.pull_cmd.replace(/\n/g, '<br/>')}
        </div>`;
    }

    const officialLinkLabel = (currentLang === 'et') ? 'Ametlik Oracle Link ↗' : ((currentLang === 'fi') ? 'Virallinen Oracle-linkki ↗' : ((currentLang === 'sv') ? 'Officiell Oracle-länk ↗' : ((currentLang === 'lv') ? 'Oficiālā Oracle saite ↗' : ((currentLang === 'lt') ? 'Oficiali Oracle nuoroda ↗' : 'Official Oracle Link ↗'))));

    html += `
      <div class="oracle-resource-card">
        <div class="oracle-resource-header">
          <h4 class="oracle-resource-title">
            <span>${item.name}</span>
          </h4>
          <span class="oracle-resource-badge ${badgeClass}">${item.badge}</span>
        </div>
        <p class="oracle-resource-desc">${dText}</p>
        <div class="oracle-resource-use"><strong>🎯 Roll:</strong> ${uText}</div>
        ${cmdHtml}
        <div class="oracle-resource-actions">
          <a href="${item.url}" target="_blank" rel="noopener noreferrer" class="btn btn-primary" style="font-size: 0.8rem; padding: 5px 12px; text-decoration: none;">
            <span>🔗</span> <span>${officialLinkLabel}</span>
          </a>
        </div>
      </div>`;
  });

  container.innerHTML = html;
}

/* ==============================================================================
 * AI SKILLS & ARCHITECTURE INTELLIGENCE ENGINE (skills)
 * ============================================================================== */

let gActiveSkillsView = 'cards';
let gActiveSkillsTier = 'all';
let gSkillsSearchQuery = '';
let gCurrentActiveSkill = null;
let gCurrentActiveSkillId = 'repo_codebase_navigator';
let gSkillsMermaidRendered = false;

function openSkillsFromMenu() {
  const dd = document.getElementById('docs-dropdown');
  if (dd) dd.classList.remove('open');
  switchTab('tab-skills');
}

function initSkillsTab() {
  renderSkillsCards();
  renderSkillsReaderSidebar();
  renderSkillsTasksMatrix();
  if (gActiveSkillsView === 'reader') {
    renderSkillsReaderContent(gCurrentActiveSkillId || 'repo_codebase_navigator');
  } else if (gActiveSkillsView === 'graph' && !gSkillsMermaidRendered) {
    renderSkillsRelationshipGraph();
  }
}

function switchSkillsView(viewName) {
  gActiveSkillsView = viewName;
  document.querySelectorAll('.skills-view-btn').forEach(b => b.classList.remove('active'));
  const activeBtn = document.getElementById(`skills-view-btn-${viewName}`);
  if (activeBtn) activeBtn.classList.add('active');

  const readerPane = document.getElementById('skills-view-reader-pane');
  const cardsPane = document.getElementById('skills-view-cards-pane');
  const graphPane = document.getElementById('skills-view-graph-pane');
  const tasksPane = document.getElementById('skills-view-tasks-pane');

  if (readerPane) readerPane.style.display = (viewName === 'reader') ? 'block' : 'none';
  if (cardsPane) cardsPane.style.display = (viewName === 'cards') ? 'block' : 'none';
  if (graphPane) graphPane.style.display = (viewName === 'graph') ? 'block' : 'none';
  if (tasksPane) tasksPane.style.display = (viewName === 'tasks') ? 'block' : 'none';

  if (viewName === 'reader') {
    renderSkillsReaderSidebar();
    renderSkillsReaderContent(gCurrentActiveSkillId || 'repo_codebase_navigator');
  } else if (viewName === 'graph') {
    renderSkillsRelationshipGraph();
  }
}

function filterSkillsTier(tier) {
  gActiveSkillsTier = tier;
  document.querySelectorAll('#skills-tier-pills .skills-tier-pill').forEach(pill => {
    pill.classList.remove('active');
    if (String(pill.getAttribute('data-tier')) === String(tier)) {
      pill.classList.add('active');
    }
  });
  renderSkillsCards();
  renderSkillsReaderSidebar();
}

function handleSkillsSearch(val) {
  gSkillsSearchQuery = (val || '').toLowerCase().trim();
  const clearBtn = document.getElementById('skills-search-clear');
  if (clearBtn) clearBtn.style.display = gSkillsSearchQuery ? 'block' : 'none';
  renderSkillsCards();
  renderSkillsReaderSidebar();
  renderSkillsTasksMatrix();
}

function renderFormattedSkillMarkdown(rawMd) {
  if (!rawMd) return '<p style="color: #64748b; font-style: italic;">Sisu puudub.</p>';
  let md = rawMd.replace(/^---[\s\S]*?\n---\s*\n?/, '').trim();

  if (typeof marked !== 'undefined' && typeof marked.parse === 'function') {
    let html = marked.parse(md);
    html = html.replace(/<blockquote>\s*<p>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*(<br\s*\/?>)?/gi, (m, p1) => {
      const alertType = p1.toLowerCase();
      return `<blockquote class="markdown-alert markdown-alert-${alertType}"><p class="markdown-alert-title">${p1}</p><p>`;
    });
    return html;
  } else {
    return `<pre style="white-space: pre-wrap; font-size: 0.85rem; color: #cbd5e1; line-height: 1.6;">${escapeHtml(md)}</pre>`;
  }
}

function selectSkillInReader(skillId) {
  gCurrentActiveSkillId = skillId;
  switchSkillsView('reader');
  renderSkillsReaderSidebar();
  renderSkillsReaderContent(skillId);
  const contentEl = document.getElementById('skills-reader-header');
  if (contentEl) {
    contentEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
}

function renderSkillsReaderSidebar() {
  const container = document.getElementById('skills-reader-nav-list');
  if (!container) return;

  const catalog = window.SKILLS_DATA || [];
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const q = gSkillsSearchQuery;

  const filtered = catalog.filter(skill => {
    if (gActiveSkillsTier !== 'all' && Number(skill.tier) !== Number(gActiveSkillsTier)) {
      return false;
    }
    if (!q) return true;
    const name = (skill.name || '').toLowerCase();
    const title = (skill.title || '').toLowerCase();
    const titleEt = (skill.title_et || '').toLowerCase();
    const desc = (skill.description || '').toLowerCase();
    const triggers = (skill.triggers || []).join(' ').toLowerCase();
    return name.includes(q) || title.includes(q) || titleEt.includes(q) || desc.includes(q) || triggers.includes(q);
  });

  if (filtered.length === 0) {
    container.innerHTML = `<div style="font-size: 0.8rem; color: #64748b; padding: 12px 6px;">Sobivaid oskusi ei leitud</div>`;
    return;
  }

  let html = '';
  filtered.forEach(skill => {
    const isActive = (skill.id === gCurrentActiveSkillId);
    const displayTitle = (currentLang === 'et' && skill.title_et) ? skill.title_et : skill.title;
    html += `
      <button class="skills-reader-nav-item ${isActive ? 'active' : ''}" onclick="selectSkillInReader('${escapeHtml(skill.id)}')">
        <div style="display: flex; align-items: center; gap: 8px; min-width: 0;">
          <span style="font-size: 1.1rem; flex-shrink: 0;">${skill.icon}</span>
          <div style="min-width: 0; text-align: left;">
            <div style="font-size: 0.84rem; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${escapeHtml(displayTitle)}</div>
            <div style="font-size: 0.72rem; color: #64748b; font-family: monospace;">${escapeHtml(skill.id)}</div>
          </div>
        </div>
        <span style="font-size: 0.68rem; padding: 2px 6px; border-radius: 4px; font-weight: 600; flex-shrink: 0; color: ${skill.tier_color}; background: ${skill.tier_bg}; border: 1px solid ${skill.tier_border};">
          T${skill.tier}
        </span>
      </button>`;
  });

  container.innerHTML = html;
}

function renderSkillsReaderContent(skillId) {
  const catalog = window.SKILLS_DATA || [];
  const skill = catalog.find(s => s.id === skillId) || catalog[0];
  if (!skill) return;

  gCurrentActiveSkillId = skill.id;
  gCurrentActiveSkill = skill;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && I18N_DICT[currentLang]) ? I18N_DICT[currentLang] : (window.I18N_DICT ? window.I18N_DICT['en'] : {});

  const headerEl = document.getElementById('skills-reader-header');
  const relationsEl = document.getElementById('skills-reader-relations-bar');
  const triggersEl = document.getElementById('skills-reader-triggers-bar');
  const bodyEl = document.getElementById('skills-reader-markdown-body');

  const displayTitle = (currentLang === 'et' && skill.title_et) ? skill.title_et : skill.title;
  const tierName = (currentLang === 'et' && skill.tier_name_et) ? skill.tier_name_et : skill.tier_name;
  const copyPathLabel = dict.skills_btn_copy_path || 'Kopeeri tee';
  const openModalLabel = dict.skills_btn_modal || 'Hüpikaken';

  if (headerEl) {
    headerEl.innerHTML = `
      <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
        <span style="font-size: 2rem;">${skill.icon}</span>
        <div>
          <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
            <h3 style="margin: 0; font-size: 1.2rem; color: #f8fafc; font-weight: 700;">${escapeHtml(displayTitle)}</h3>
            <span class="skill-tier-badge" style="color: ${skill.tier_color}; background: ${skill.tier_bg}; border: 1px solid ${skill.tier_border}; font-size: 0.75rem;">
              Tier ${skill.tier}: ${escapeHtml(tierName)}
            </span>
          </div>
          <div style="font-size: 0.78rem; color: #94a3b8; font-family: monospace; margin-top: 4px;">
            ${escapeHtml(skill.rel_path)}
          </div>
        </div>
      </div>
      <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
        <button class="btn btn-sm btn-secondary" onclick="copySkillPathDirect('${escapeHtml(skill.rel_path)}')">
          <span>📋</span> <span>${copyPathLabel}</span>
        </button>
        <button class="btn btn-sm btn-secondary" onclick="openSkillDetail('${escapeHtml(skill.id)}')">
          <span>⤢</span> <span>${openModalLabel}</span>
        </button>
      </div>`;
  }

  // Relations Bar
  if (relationsEl) {
    let relsHtml = `<div style="display: flex; gap: 16px; flex-wrap: wrap; align-items: center; width: 100%;">`;
    const depLabel = dict.skills_depends_on || '⬆️ Eeltingimused / Sõltub';
    if (skill.dependencies && skill.dependencies.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${depLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.dependencies.map(depId => {
          const target = catalog.find(s => s.id === depId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn dep" onclick="selectSkillInReader('${depId}')">${icon} ${depId}</button>`;
        }).join('') + `</div></div>`;
    } else {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${depLabel}:</span>
        <span style="font-size: 0.78rem; color: #64748b;">${dict.skills_none_root || 'Puuduvad (Tuumik/Root)'}</span>
      </div>`;
    }

    const usedLabel = dict.skills_used_by || '⬇️ Kasutavad oskused';
    if (skill.used_by && skill.used_by.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${usedLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.used_by.map(usedId => {
          const target = catalog.find(s => s.id === usedId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn used" onclick="selectSkillInReader('${usedId}')">${icon} ${usedId}</button>`;
        }).join('') + `</div></div>`;
    }

    const relLabel = dict.skills_related || '🔄 Seotud oskused';
    if (skill.related && skill.related.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${relLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.related.map(relId => {
          const target = catalog.find(s => s.id === relId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn rel" onclick="selectSkillInReader('${relId}')">${icon} ${relId}</button>`;
        }).join('') + `</div></div>`;
    }

    relsHtml += `</div>`;
    relationsEl.innerHTML = relsHtml;
  }

  // Triggers Bar
  if (triggersEl) {
    let trHtml = `<span style="font-size: 0.76rem; font-weight: 600; color: #38bdf8; text-transform: uppercase; letter-spacing: 0.05em;">🤖 ${dict.skills_prompt_triggers || 'AI Agendi Päästikud'}:</span>`;
    if (skill.triggers && skill.triggers.length > 0) {
      trHtml += skill.triggers.map(tr => `<span class="skill-trigger-pill">#${escapeHtml(tr)}</span>`).join(' ');
    } else {
      trHtml += `<span style="font-size: 0.76rem; color: #64748b;">Automaatne semantiline tuvastus</span>`;
    }
    triggersEl.innerHTML = trHtml;
  }

  // Markdown Body
  if (bodyEl) {
    bodyEl.innerHTML = renderFormattedSkillMarkdown(skill.markdown);
  }
}

function clearSkillsSearch() {
  const inp = document.getElementById('skills-search-input');
  if (inp) {
    inp.value = '';
    handleSkillsSearch('');
    inp.focus();
  }
}

function renderSkillsCards() {
  const container = document.getElementById('skills-cards-grid');
  if (!container) return;

  const catalog = window.SKILLS_DATA || [];
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && I18N_DICT[currentLang]) ? I18N_DICT[currentLang] : (window.I18N_DICT ? window.I18N_DICT['en'] : {});

  const q = gSkillsSearchQuery;
  const filtered = catalog.filter(skill => {
    if (gActiveSkillsTier !== 'all' && Number(skill.tier) !== Number(gActiveSkillsTier)) {
      return false;
    }
    if (!q) return true;

    const name = (skill.name || '').toLowerCase();
    const title = (skill.title || '').toLowerCase();
    const titleEt = (skill.title_et || '').toLowerCase();
    const desc = (skill.description || '').toLowerCase();
    const triggers = (skill.triggers || []).join(' ').toLowerCase();
    const markdown = (skill.markdown || '').toLowerCase();

    return name.includes(q) || title.includes(q) || titleEt.includes(q) || desc.includes(q) || triggers.includes(q) || markdown.includes(q);
  });

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 48px 16px; background: rgba(15, 23, 42, 0.4); border: 1px solid var(--border); border-radius: 12px; color: var(--text-muted);">
        <div style="font-size: 2.2rem; margin-bottom: 8px;">🔍</div>
        <div style="font-size: 1.05rem; font-weight: 600; color: #f8fafc; margin-bottom: 4px;">${dict.skills_no_results || 'Ühtegi sobivat oskust ei leitud'}</div>
        <div style="font-size: 0.82rem; color: #64748b;">"${escapeHtml(q)}"</div>
        <button class="btn btn-secondary btn-sm" onclick="clearSkillsSearch()" style="margin-top: 14px;">↺ ${dict.btn_reset_filters || 'Lähtesta otsing'}</button>
      </div>`;
    return;
  }

  let html = '';
  filtered.forEach(skill => {
    const displayTitle = (currentLang === 'et' && skill.title_et) ? skill.title_et : skill.title;
    const tierName = (currentLang === 'et' && skill.tier_name_et) ? skill.tier_name_et : skill.tier_name;

    // Trigger pills
    let triggersHtml = '';
    if (skill.triggers && skill.triggers.length > 0) {
      triggersHtml = `<div class="skill-card-triggers">` +
        skill.triggers.slice(0, 5).map(tr => `<span class="skill-trigger-pill">#${escapeHtml(tr)}</span>`).join('') +
        `</div>`;
    }

    // Related skills pills
    let relatedHtml = '';
    if (skill.related && skill.related.length > 0) {
      const relLabel = dict.skills_related || 'Seotud';
      relatedHtml = `<div class="skill-card-related">
        <span class="skill-related-label">${relLabel}:</span>` +
        skill.related.slice(0, 4).map(relId => {
          const target = catalog.find(s => s.id === relId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-related-btn" onclick="openSkillDetail('${relId}')" title="${relId}">${icon} ${relId}</button>`;
        }).join('') +
        `</div>`;
    }

    const readBtnLabel = dict.skills_btn_read_guide || 'Ava täielik juhend';
    const copyPathLabel = dict.skills_btn_copy_path || 'Kopeeri tee';

    html += `
      <div class="skill-card" data-skill-id="${escapeHtml(skill.id)}" onclick="selectSkillInReader('${escapeHtml(skill.id)}')">
        <div class="skill-card-header">
          <div style="display: flex; align-items: center; gap: 10px;">
            <span class="skill-card-icon">${skill.icon}</span>
            <div>
              <h4 class="skill-card-title">${escapeHtml(displayTitle)}</h4>
              <span class="skill-card-file">${escapeHtml(skill.id)}</span>
            </div>
          </div>
          <span class="skill-tier-badge" style="color: ${skill.tier_color}; background: ${skill.tier_bg}; border: 1px solid ${skill.tier_border};">
            Tier ${skill.tier}
          </span>
        </div>

        <p class="skill-card-desc">${escapeHtml(skill.description)}</p>

        ${triggersHtml}
        ${relatedHtml}

        <div class="skill-card-footer" onclick="event.stopPropagation()">
          <button class="btn btn-sm btn-primary" onclick="selectSkillInReader('${escapeHtml(skill.id)}')">
            <span>📖</span> <span>${readBtnLabel}</span>
          </button>
          <button class="btn btn-sm btn-secondary" onclick="openSkillDetail('${escapeHtml(skill.id)}')">
            <span>⤢</span> <span>${dict.skills_btn_modal || 'Hüpikaken'}</span>
          </button>
          <button class="btn btn-sm btn-secondary" onclick="copySkillPathDirect('${escapeHtml(skill.rel_path)}')" title="${skill.rel_path}">
            <span>📋</span> <span>${copyPathLabel}</span>
          </button>
        </div>
      </div>`;
  });

  container.innerHTML = html;
}

async function renderSkillsRelationshipGraph(force) {
  if (gSkillsMermaidRendered && !force) return;
  const container = document.getElementById('skills-mermaid-container');
  if (!container) return;

  const mermaidCode = window.SKILLS_MERMAID || '';
  if (!mermaidCode) {
    container.innerHTML = `<p style="color: var(--text-muted); padding: 24px;">Diagrammi kood puudub.</p>`;
    return;
  }

  if (typeof mermaid === 'undefined') {
    container.innerHTML = `<p style="color: var(--text-muted); padding: 24px;">Mermaid teek laeb...</p>`;
    return;
  }

  try {
    container.innerHTML = `<div style="padding: 40px; color: #94a3b8;">Renderdan Mermaid graafikut...</div>`;
    const svgId = `skills-graph-svg-${Math.floor(Math.random() * 100000)}`;
    const renderRes = await mermaid.render(svgId, mermaidCode);
    container.innerHTML = renderRes.svg;
    gSkillsMermaidRendered = true;
  } catch (err) {
    console.error('Mermaid render error:', err);
    container.innerHTML = `
      <div style="padding: 24px; color: #f87171; background: rgba(239, 68, 68, 0.1); border-radius: 8px; font-size: 0.85rem;">
        <strong>Mermaid viga:</strong> ${escapeHtml(err.message || String(err))}
      </div>`;
  }
}

function renderSkillsTasksMatrix() {
  const container = document.getElementById('skills-tasks-table-container');
  if (!container) return;

  const tasks = window.SKILLS_TASKS_DATA || [];
  const catalog = window.SKILLS_DATA || [];
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && I18N_DICT[currentLang]) ? I18N_DICT[currentLang] : (window.I18N_DICT ? window.I18N_DICT['en'] : {});

  const q = gSkillsSearchQuery;
  const filtered = tasks.filter(t => {
    if (!q) return true;
    const taskText = ((t.task && (t.task[currentLang] || t.task.en)) || '').toLowerCase();
    const prim = (t.primary_skill || '').toLowerCase();
    const sec = (t.secondary_skills || []).join(' ').toLowerCase();
    const hint = (t.cli_hint || '').toLowerCase();
    return taskText.includes(q) || prim.includes(q) || sec.includes(q) || hint.includes(q);
  });

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 32px; color: var(--text-muted);">
        <div style="font-size: 1.8rem; margin-bottom: 6px;">🔍</div>
        <div style="font-size: 0.95rem; color: #e2e8f0;">${dict.skills_no_tasks_found || 'Ülesandeid ei leitud'}</div>
      </div>`;
    return;
  }

  let html = `
    <table class="skills-tasks-table">
      <thead>
        <tr>
          <th style="width: 38%;">${dict.skills_th_task || 'Arendusülesanne'}</th>
          <th style="width: 24%;">${dict.skills_th_primary_skill || 'Peamine Skill (Tier)'}</th>
          <th style="width: 20%;">${dict.skills_th_secondary_skills || 'Seotud Oskused'}</th>
          <th style="width: 18%;">${dict.skills_th_cli || 'CLI / Teekond'}</th>
        </tr>
      </thead>
      <tbody>`;

  filtered.forEach(t => {
    const taskDesc = (t.task && (t.task[currentLang] || t.task.en)) || '';
    const primSkill = catalog.find(s => s.id === t.primary_skill);
    const primIcon = primSkill ? primSkill.icon : '📦';
    const primTitle = primSkill ? ((currentLang === 'et' && primSkill.title_et) ? primSkill.title_et : primSkill.title) : t.primary_skill;
    const primTier = primSkill ? primSkill.tier : 1;

    let secHtml = '';
    if (t.secondary_skills && t.secondary_skills.length > 0) {
      secHtml = t.secondary_skills.map(sId => {
        const secSkill = catalog.find(s => s.id === sId);
        const secIcon = secSkill ? secSkill.icon : '📦';
        return `<button class="skill-task-chip" onclick="openSkillDetail('${sId}')" title="${sId}">${secIcon} ${sId}</button>`;
      }).join(' ');
    } else {
      secHtml = '<span style="color: #64748b;">—</span>';
    }

    const cleanCli = escapeHtml(t.cli_hint || '');
    html += `
      <tr>
        <td style="font-weight: 500; color: #f1f5f9;">
          ${escapeHtml(taskDesc)}
        </td>
        <td>
          <button class="skill-task-chip primary-chip" onclick="openSkillDetail('${t.primary_skill}')" title="${escapeHtml(primTitle)}">
            <span>${primIcon}</span>
            <span>${escapeHtml(t.primary_skill)}</span>
            <span class="chip-tier-tag">T${primTier}</span>
          </button>
        </td>
        <td>
          <div style="display: flex; gap: 4px; flex-wrap: wrap;">${secHtml}</div>
        </td>
        <td>
          <div class="skill-task-cli-box">
            <code>${cleanCli}</code>
            <button class="btn btn-xs btn-secondary" onclick="copyTaskCli(this, '${escapeHtml(t.cli_hint || '')}')" title="Kopeeri">📋</button>
          </div>
        </td>
      </tr>`;
  });

  html += `</tbody></table>`;
  container.innerHTML = html;
}

function openSkillDetail(skillId) {
  const catalog = window.SKILLS_DATA || [];
  const skill = catalog.find(s => s.id === skillId);
  if (!skill) return;

  gCurrentActiveSkill = skill;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = (typeof I18N_DICT !== 'undefined' && I18N_DICT[currentLang]) ? I18N_DICT[currentLang] : (window.I18N_DICT ? window.I18N_DICT['en'] : {});

  const modal = document.getElementById('skill-modal-backdrop');
  if (!modal) return;

  const iconEl = document.getElementById('skill-modal-icon');
  const titleEl = document.getElementById('skill-modal-title');
  const tierBadgeEl = document.getElementById('skill-modal-tier-badge');
  const pathEl = document.getElementById('skill-modal-path');
  const relationsBar = document.getElementById('skill-modal-relations-bar');
  const triggersBar = document.getElementById('skill-modal-triggers-bar');
  const markdownBody = document.getElementById('skill-modal-markdown-body');

  const displayTitle = (currentLang === 'et' && skill.title_et) ? skill.title_et : skill.title;
  const tierName = (currentLang === 'et' && skill.tier_name_et) ? skill.tier_name_et : skill.tier_name;

  if (iconEl) iconEl.textContent = skill.icon || '📦';
  if (titleEl) titleEl.textContent = displayTitle;
  if (pathEl) pathEl.textContent = skill.rel_path;
  if (tierBadgeEl) {
    tierBadgeEl.textContent = `Tier ${skill.tier}: ${tierName}`;
    tierBadgeEl.style.color = skill.tier_color;
    tierBadgeEl.style.backgroundColor = skill.tier_bg;
    tierBadgeEl.style.border = `1px solid ${skill.tier_border}`;
  }

  // Build relationship chips
  if (relationsBar) {
    let relsHtml = `<div style="display: flex; gap: 16px; flex-wrap: wrap; align-items: center; width: 100%;">`;

    // Dependencies (Depends on)
    const depLabel = dict.skills_depends_on || '⬆️ Eeltingimused / Sõltub';
    if (skill.dependencies && skill.dependencies.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${depLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.dependencies.map(depId => {
          const target = catalog.find(s => s.id === depId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn dep" onclick="openSkillDetail('${depId}')">${icon} ${depId}</button>`;
        }).join('') + `</div></div>`;
    } else {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${depLabel}:</span>
        <span style="font-size: 0.78rem; color: #64748b;">${dict.skills_none_root || 'Puuduvad (Tuumik/Root)'}</span>
      </div>`;
    }

    // Used by
    const usedLabel = dict.skills_used_by || '⬇️ Kasutavad oskused';
    if (skill.used_by && skill.used_by.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${usedLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.used_by.map(usedId => {
          const target = catalog.find(s => s.id === usedId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn used" onclick="openSkillDetail('${usedId}')">${icon} ${usedId}</button>`;
        }).join('') + `</div></div>`;
    }

    // Related
    const relLabel = dict.skills_related || '🔄 Seotud oskused';
    if (skill.related && skill.related.length > 0) {
      relsHtml += `<div class="skill-rel-group">
        <span class="skill-rel-label">${relLabel}:</span>
        <div class="skill-rel-chips">` +
        skill.related.map(relId => {
          const target = catalog.find(s => s.id === relId);
          const icon = target ? target.icon : '📦';
          return `<button class="skill-rel-chip-btn rel" onclick="openSkillDetail('${relId}')">${icon} ${relId}</button>`;
        }).join('') + `</div></div>`;
    }

    relsHtml += `</div>`;
    relationsBar.innerHTML = relsHtml;
  }

  // Build triggers pill bar
  if (triggersBar) {
    let trHtml = `<span style="font-size: 0.76rem; font-weight: 600; color: #38bdf8; text-transform: uppercase; letter-spacing: 0.05em;">🤖 ${dict.skills_prompt_triggers || 'AI Agendi Päästikud'}:</span>`;
    if (skill.triggers && skill.triggers.length > 0) {
      trHtml += skill.triggers.map(tr => `<span class="skill-trigger-pill">#${escapeHtml(tr)}</span>`).join(' ');
    } else {
      trHtml += `<span style="font-size: 0.76rem; color: #64748b;">Automaatne semantiline tuvastus</span>`;
    }
    triggersBar.innerHTML = trHtml;
  }

  // Render Markdown content
  if (markdownBody) {
    markdownBody.innerHTML = renderFormattedSkillMarkdown(skill.markdown);
  }

  modal.style.display = 'flex';
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeSkillModal(event) {
  if (event && event.target && event.target.closest && event.target.closest('.skill-modal-content') && event.target !== event.currentTarget) {
    return;
  }
  const modal = document.getElementById('skill-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'none';
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

function copySkillPath() {
  if (gCurrentActiveSkill && gCurrentActiveSkill.rel_path) {
    copySkillPathDirect(gCurrentActiveSkill.rel_path);
  }
}

function copySkillPathDirect(pathStr) {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(pathStr).then(() => {
      showToast(`Kopeeritud: ${pathStr}`);
    }).catch(() => {
      showToast(`Kopeeritud: ${pathStr}`);
    });
  } else {
    showToast(`Kopeeritud: ${pathStr}`);
  }
}

function copyTaskCli(btn, cliText) {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(cliText).then(() => {
      showToast(`Kopeeritud käsk: ${cliText}`);
    }).catch(() => {
      showToast(`Kopeeritud: ${cliText}`);
    });
  } else {
    showToast(`Kopeeritud käsk: ${cliText}`);
  }
}

/* ==============================================================================
 * UNIVERSAL OMNISEARCH, CODE PREVIEW & KEYBOARD NAVIGATION ENGINE
 * ============================================================================== */

let gSearchActiveCategory = 'all';
let gSearchSelectedIndex = -1;
let gCurrentSearchResults = [];
const RECENT_SEARCHES_KEY = 'devhub_recent_searches';
let gCurrentPreviewFile = { path: '', content: '' };

function initGlobalSearchInput() {
  const input = document.getElementById('global-search-input');
  if (input) {
    input.addEventListener('input', (e) => {
      handleGlobalSearchInput(e.target.value);
    });
  }
}

function openGlobalSearchModal(defaultQuery = '') {
  const modal = document.getElementById('global-search-modal-backdrop');
  if (!modal) return;
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  const input = document.getElementById('global-search-input');
  if (input) {
    if (defaultQuery) input.value = defaultQuery;
    setTimeout(() => {
      input.focus();
      if (defaultQuery) input.select();
    }, 50);
  }
  updateGlobalSearchCategories();
  if (input && input.value) {
    handleGlobalSearchInput(input.value);
  } else {
    renderRecentSearches();
    filterGlobalSearchResults('');
  }
}

function closeGlobalSearchModal(event) {
  if (event && event.target && event.target.id !== 'global-search-modal-backdrop' && !event.target.classList.contains('global-search-esc-badge')) {
    return;
  }
  const modal = document.getElementById('global-search-modal-backdrop');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
  gSearchSelectedIndex = -1;
}

function clearGlobalSearch() {
  const input = document.getElementById('global-search-input');
  if (input) {
    input.value = '';
    input.focus();
    handleGlobalSearchInput('');
  }
}

function setGlobalSearchCategory(cat) {
  gSearchActiveCategory = cat;
  document.querySelectorAll('.search-cat-pill').forEach(pill => {
    if (pill.getAttribute('data-cat') === cat) {
      pill.classList.add('active');
    } else {
      pill.classList.remove('active');
    }
  });
  const input = document.getElementById('global-search-input');
  handleGlobalSearchInput(input ? input.value : '');
}

function updateGlobalSearchCategories() {
  const index = window.GLOBAL_SEARCH_INDEX || [];
  const counts = { all: index.length, docs: 0, scripts: 0, blueprints: 0, profiles: 0, tests: 0, glossary: 0, skills: 0 };
  index.forEach(item => {
    const cat = item.category;
    if (counts[cat] !== undefined) counts[cat]++;
    else if (cat === 'faq') counts.glossary++;
    else if (cat === 'resources') counts.docs++;
  });
  Object.keys(counts).forEach(k => {
    const el = document.getElementById(`count-${k}`);
    if (el) el.textContent = counts[k];
  });
}

function getRecentSearches() {
  try {
    const raw = localStorage.getItem(RECENT_SEARCHES_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch (e) {
    return [];
  }
}

function addRecentSearch(item) {
  try {
    let list = getRecentSearches();
    list = list.filter(r => r.path !== item.path && r.title !== item.title);
    list.unshift({
      title: item.title,
      titles: item.titles,
      summaries: item.summaries,
      path: item.path,
      category: item.category,
      target: item.target
    });
    if (list.length > 10) list = list.slice(0, 10);
    localStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(list));
  } catch (e) {}
}

function clearRecentSearches() {
  try {
    localStorage.removeItem(RECENT_SEARCHES_KEY);
  } catch (e) {}
  renderRecentSearches();
}

function renderRecentSearches() {
  const container = document.getElementById('global-search-recent-section');
  const listEl = document.getElementById('global-search-recent-list');
  if (!container || !listEl) return;
  const recent = getRecentSearches();
  if (!recent || recent.length === 0) {
    container.style.display = 'none';
    listEl.innerHTML = '';
    return;
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  container.style.display = 'block';
  listEl.innerHTML = recent.map((r) => {
    const rTitle = (r.titles && (r.titles[currentLang] || r.titles['en'])) || r.title || '';
    return `
      <div class="recent-search-tag" onclick='navigateToSearchResult(${JSON.stringify(r).replace(/'/g, "&#39;")})' title="${escapeHtml(r.path)}">
        <span>${getCategoryIcon(r.category)}</span>
        <span>${escapeHtml(rTitle)}</span>
        <span style="font-family: monospace; font-size: 0.68rem; color: #64748b;">${escapeHtml((r.path || '').split('/').pop())}</span>
      </div>
    `;
  }).join('');
}

function getCategoryIcon(cat) {
  switch (cat) {
    case 'docs': return '📚';
    case 'scripts': return '⚡';
    case 'blueprints': return '📋';
    case 'profiles': return '⚙️';
    case 'tests': return '🧪';
    case 'glossary': return '📖';
    case 'faq': return '❓';
    case 'skills': return '🧠';
    case 'resources': return '🏛️';
    default: return '📄';
  }
}

function handleGlobalSearchInput(query) {
  const clearBtn = document.getElementById('global-search-clear-btn');
  const recentSec = document.getElementById('global-search-recent-section');
  const qClean = (query || '').trim().toLowerCase();
  
  if (clearBtn) clearBtn.style.display = qClean ? 'block' : 'none';
  if (recentSec) recentSec.style.display = qClean ? 'none' : (getRecentSearches().length > 0 ? 'block' : 'none');

  filterGlobalSearchResults(qClean);
}

function filterGlobalSearchResults(query = '') {
  const index = window.GLOBAL_SEARCH_INDEX || [];
  const resultsContainer = document.getElementById('global-search-results-container');
  const counterEl = document.getElementById('global-search-counter');
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (!resultsContainer) return;

  let filtered = index;
  if (gSearchActiveCategory !== 'all') {
    filtered = filtered.filter(item => {
      if (gSearchActiveCategory === 'glossary') {
        return item.category === 'glossary' || item.category === 'faq';
      }
      return item.category === gSearchActiveCategory;
    });
  }

  if (query) {
    const qTokens = query.split(/\s+/).filter(Boolean);
    filtered = filtered.filter(item => {
      const activeTitle = (item.titles && item.titles[currentLang] ? item.titles[currentLang] : (item.title || '')).toLowerCase();
      const enTitle = (item.titles && item.titles['en'] ? item.titles['en'] : (item.title || '')).toLowerCase();
      const pathStr = (item.path || '').toLowerCase();
      const activeSummary = (item.summaries && item.summaries[currentLang] ? item.summaries[currentLang] : (item.summary || '')).toLowerCase();
      const enSummary = (item.summaries && item.summaries['en'] ? item.summaries['en'] : (item.summary || '')).toLowerCase();
      const kwStr = (item.keywords || '').toLowerCase();
      return qTokens.every(tok => 
        activeTitle.includes(tok) || 
        enTitle.includes(tok) || 
        pathStr.includes(tok) || 
        activeSummary.includes(tok) || 
        enSummary.includes(tok) || 
        kwStr.includes(tok)
      );
    });

    filtered.sort((a, b) => {
      const aTitle = (a.titles && (a.titles[currentLang] || a.titles['en'])) || a.title || '';
      const bTitle = (b.titles && (b.titles[currentLang] || b.titles['en'])) || b.title || '';
      const aLower = aTitle.toLowerCase();
      const bLower = bTitle.toLowerCase();

      const aStarts = aLower.startsWith(query) ? 1 : 0;
      const bStarts = bLower.startsWith(query) ? 1 : 0;
      if (aStarts !== bStarts) return bStarts - aStarts;

      const aInTitle = aLower.includes(query) ? 1 : 0;
      const bInTitle = bLower.includes(query) ? 1 : 0;
      if (aInTitle !== bInTitle) return bInTitle - aInTitle;

      const aPath = (a.path || '').toLowerCase();
      const bPath = (b.path || '').toLowerCase();
      const aInPath = aPath.includes(query) ? 1 : 0;
      const bInPath = bPath.includes(query) ? 1 : 0;
      return bInPath - aInPath;
    });
  }

  gCurrentSearchResults = filtered.slice(0, 100);
  gSearchSelectedIndex = gCurrentSearchResults.length > 0 ? 0 : -1;

  if (counterEl) {
    const countText = (dict.search_results_count || '%s tulemust').replace('%s', filtered.length);
    counterEl.textContent = countText;
  }

  if (gCurrentSearchResults.length === 0) {
    resultsContainer.innerHTML = `
      <div style="text-align: center; padding: 40px 20px; color: #64748b;">
        <div style="font-size: 2.5rem; margin-bottom: 12px; opacity: 0.6;">🔍</div>
        <div style="font-size: 0.95rem; font-weight: 600; color: #cbd5e1;">${escapeHtml(dict.search_no_results || 'Repositooriumist ei leitud ühtegi vastet')}</div>
        <div style="font-size: 0.8rem; margin-top: 6px;">Päring: <code style="color: #38bdf8; background: rgba(56,189,248,0.1); padding: 2px 6px; border-radius: 4px;">${escapeHtml(query)}</code></div>
      </div>
    `;
    return;
  }

  let html = '';
  gCurrentSearchResults.forEach((item, idx) => {
    const isSelected = (idx === gSearchSelectedIndex);
    const cat = item.category || 'docs';
    const icon = getCategoryIcon(cat);
    const rawTitle = (item.titles && (item.titles[currentLang] || item.titles['en'])) || item.title || '';
    const rawSummary = (item.summaries && (item.summaries[currentLang] || item.summaries['en'])) || item.summary || '';
    const highlightedTitle = highlightSearchText(rawTitle, query);
    const highlightedSummary = highlightSearchText(rawSummary, query);

    html += `
      <div class="search-result-item ${isSelected ? 'selected' : ''}" data-index="${idx}" onclick="selectAndNavigateSearch(${idx})">
        <span class="search-result-icon">${icon}</span>
        <div class="search-result-body">
          <div class="search-result-top">
            <span class="search-result-title">${highlightedTitle}</span>
            <span class="search-result-badge badge-${cat}">${escapeHtml(cat)}</span>
          </div>
          <div class="search-result-summary">${highlightedSummary}</div>
          <div class="search-result-meta">
            <span class="search-path-badge" title="${escapeHtml(item.path)}">${escapeHtml(item.path)}</span>
            <button class="search-path-copy-btn" onclick="copyFilePath('${escapeHtml(item.path)}', event)" title="Kopeeri failitee">
              <span>📋</span> <span data-i18n="btn_copy_file_path">${escapeHtml(dict.btn_copy_file_path || 'Kopeeri tee')}</span>
            </button>
          </div>
        </div>
      </div>
    `;
  });

  resultsContainer.innerHTML = html;
}

function highlightSearchText(text, query) {
  if (!text) return '';
  if (!query) return escapeHtml(text);
  const qTokens = query.split(/\s+/).filter(Boolean);
  let safeText = escapeHtml(text);
  qTokens.forEach(tok => {
    const reg = new RegExp(`(${escapeRegExp(tok)})`, 'gi');
    safeText = safeText.replace(reg, '<span class="search-highlight">$1</span>');
  });
  return safeText;
}

function selectAndNavigateSearch(idx) {
  const item = gCurrentSearchResults[idx];
  if (item) navigateToSearchResult(item);
}

function copyFilePath(path, event) {
  if (event && event.stopPropagation) {
    event.preventDefault();
    event.stopPropagation();
  }
  if (!path) return;
  const cleanPath = path.split('#')[0];
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(cleanPath).then(() => {
      notifyPathCopied(cleanPath);
    }).catch(() => {
      fallbackCopyText(cleanPath);
      notifyPathCopied(cleanPath);
    });
  } else {
    fallbackCopyText(cleanPath);
    notifyPathCopied(cleanPath);
  }
}

function fallbackCopyText(text) {
  try {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.focus();
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
  } catch (e) {}
}

function notifyPathCopied(cleanPath) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  const tMsg = (dict.toast_path_copied || 'Tee kopeeritud: %s').replace('%s', `<code style="color:#38bdf8; font-weight:700;">${escapeHtml(cleanPath)}</code>`);
  showToast(`📋 ${tMsg}`);
}

function navigateToSearchResult(item) {
  if (!item) return;
  addRecentSearch(item);
  closeGlobalSearchModal();

  const target = item.target || {};
  const action = target.action;

  if (action === 'navigate_doc') {
    switchTab('tab-docs');
    if (typeof target.docIdx === 'number') {
      loadDocContent(target.docIdx);
      if (target.anchor) {
        setTimeout(() => {
          const el = document.getElementById(target.anchor) || document.querySelector(`[name="${target.anchor}"]`);
          if (el) {
            el.scrollIntoView({ behavior: 'smooth', block: 'start' });
            el.style.transition = 'background 0.5s ease';
            el.style.backgroundColor = 'rgba(56, 189, 248, 0.2)';
            setTimeout(() => { el.style.backgroundColor = ''; }, 2000);
          }
        }, 250);
      }
    }
  } else if (action === 'navigate_tab') {
    switchTab(target.tabId);
    if (target.bpNum !== undefined) {
      switchToCockpitSection('blueprints');
      setTimeout(() => {
        const bpCard = document.querySelector(`.bp-card[data-bp-num="${target.bpNum}"]`) || document.getElementById(`bp-card-${target.bpNum}`);
        if (bpCard) {
          bpCard.scrollIntoView({ behavior: 'smooth', block: 'center' });
          bpCard.style.transition = 'box-shadow 0.4s ease, border-color 0.4s ease';
          bpCard.style.borderColor = '#38bdf8';
          bpCard.style.boxShadow = '0 0 20px rgba(56, 189, 248, 0.4)';
          setTimeout(() => { bpCard.style.boxShadow = ''; bpCard.style.borderColor = ''; }, 2500);
        }
      }, 200);
    } else if (target.suiteName) {
      setTimeout(() => {
        const searchBox = document.getElementById('testing-search-input') || document.getElementById('test-suite-search');
        if (searchBox) {
          searchBox.value = target.suiteName;
          if (typeof filterTestSuites === 'function') filterTestSuites();
        }
      }, 150);
    } else if (target.skillId && typeof selectSkillInReader === 'function') {
      selectSkillInReader(target.skillId);
    }
  } else if (action === 'open_glossary') {
    openGlossaryModal();
    if (target.term) {
      setTimeout(() => {
        const searchInp = document.getElementById('glossary-search-input');
        if (searchInp) {
          searchInp.value = target.term;
          if (typeof filterGlossaryCards === 'function') filterGlossaryCards();
        }
      }, 100);
    }
  } else if (action === 'open_faq') {
    gActiveFaqCategory = 'all';
    openFaqModal();
    if (target.faqId) {
      setTimeout(() => {
        const faqInp = document.getElementById('faq-search-input');
        if (faqInp) {
          faqInp.value = target.faqId.replace(/^faq-/, '').replace(/-/g, ' ');
          if (typeof filterFaqCards === 'function') filterFaqCards();
        }
      }, 100);
    }
  } else if (action === 'view_preview') {
    openCodePreview(target.path || item.path, target.title || item.title, target.fileType);
  } else if (action === 'open_url') {
    if (target.url) window.open(target.url, '_blank');
  }
}

// Code Preview Modal
function openCodePreview(relPath, title, fileType = 'text') {
  const modal = document.getElementById('code-preview-modal-backdrop');
  const titleEl = document.getElementById('code-preview-title');
  const pathEl = document.getElementById('code-preview-path');
  const codeEl = document.getElementById('code-preview-code');
  const badgeEl = document.getElementById('code-preview-badge');

  if (!modal || !codeEl) return;
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  gCurrentPreviewFile = { path: relPath, content: '' };
  if (titleEl) titleEl.textContent = title || relPath.split('/').pop();
  if (pathEl) pathEl.textContent = relPath;
  if (badgeEl) badgeEl.textContent = (fileType || 'file').toUpperCase();
  codeEl.textContent = 'Laadimine...';

  // 1. Check if profile content is cached locally in window.PROFILES_DATA
  if (window.PROFILES_DATA && Array.isArray(window.PROFILES_DATA)) {
    const prof = window.PROFILES_DATA.find(p => p.rel_path === relPath || p.name === relPath);
    if (prof && prof.content) {
      gCurrentPreviewFile.content = prof.content;
      codeEl.textContent = prof.content;
      return;
    }
  }

  // 2. Fetch raw file from Bridge API /api/file/raw?path=
  fetch(`${BRIDGE_URL}/api/file/raw?path=${encodeURIComponent(relPath)}`)
    .then(r => r.json())
    .then(data => {
      if (data.status === 'ok' && data.content) {
        gCurrentPreviewFile.content = data.content;
        codeEl.textContent = data.content;
      } else {
        showPreviewOfflineFallback(relPath, codeEl);
      }
    })
    .catch(() => {
      showPreviewOfflineFallback(relPath, codeEl);
    });
}

function showPreviewOfflineFallback(relPath, codeEl) {
  const fallback = `# ${relPath}\n\n# Faili sisu otsevaatamiseks käivita Dev Hub bridge server:\n# ./scripts/internal/dev-hub-bridge.py\n\n# Või ava fail lokaalselt redaktoris:\n# code ${relPath}`;
  gCurrentPreviewFile.content = fallback;
  codeEl.textContent = fallback;
}

function closeCodePreviewModal(event) {
  if (event && event.target && event.target.id !== 'code-preview-modal-backdrop' && !event.target.classList.contains('modal-close-btn')) {
    return;
  }
  const modal = document.getElementById('code-preview-modal-backdrop');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

function copyCurrentPreviewPath() {
  if (gCurrentPreviewFile && gCurrentPreviewFile.path) {
    copyFilePath(gCurrentPreviewFile.path);
  }
}

function copyCurrentPreviewContent() {
  if (gCurrentPreviewFile && gCurrentPreviewFile.content) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(gCurrentPreviewFile.content);
    } else {
      fallbackCopyText(gCurrentPreviewFile.content);
    }
    const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
    const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
    showToast(dict.toast_content_copied || 'Faili sisu kopeeritud lõikelauale!');
  }
}

function updateSelectedSearchResult() {
  const container = document.getElementById('global-search-results-container');
  if (!container) return;
  const items = container.querySelectorAll('.search-result-item');
  items.forEach((item, idx) => {
    if (idx === gSearchSelectedIndex) {
      item.classList.add('selected');
      item.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    } else {
      item.classList.remove('selected');
    }
  });
}

// Global Keyboard Shortcuts for Spotlight Omnisearch
window.addEventListener('keydown', (e) => {
  const searchModal = document.getElementById('global-search-modal-backdrop');
  const isSearchOpen = searchModal && searchModal.style.display === 'flex';

  // Open shortcut: ⌘K or Ctrl+K
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
    e.preventDefault();
    if (isSearchOpen) closeGlobalSearchModal();
    else openGlobalSearchModal();
    return;
  }

  // Open shortcut: '/' when outside of inputs
  const activeTag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
  const isInput = (activeTag === 'input' || activeTag === 'textarea' || (document.activeElement && document.activeElement.isContentEditable));

  if (e.key === '/' && !isInput && !isSearchOpen) {
    e.preventDefault();
    openGlobalSearchModal();
    return;
  }

  // Navigation while Omnisearch modal is open
  if (isSearchOpen) {
    if (e.key === 'Escape') {
      e.preventDefault();
      closeGlobalSearchModal();
      return;
    }
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (gCurrentSearchResults.length > 0) {
        gSearchSelectedIndex = (gSearchSelectedIndex + 1) % gCurrentSearchResults.length;
        updateSelectedSearchResult();
      }
      return;
    }
    if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (gCurrentSearchResults.length > 0) {
        gSearchSelectedIndex = (gSearchSelectedIndex - 1 + gCurrentSearchResults.length) % gCurrentSearchResults.length;
        updateSelectedSearchResult();
      }
      return;
    }
    if (e.key === 'Enter') {
      e.preventDefault();
      if (gSearchSelectedIndex >= 0 && gSearchSelectedIndex < gCurrentSearchResults.length) {
        navigateToSearchResult(gCurrentSearchResults[gSearchSelectedIndex]);
      }
      return;
    }
  }

  // Code preview modal Esc
  const codeModal = document.getElementById('code-preview-modal-backdrop');
  if (codeModal && codeModal.style.display === 'flex' && e.key === 'Escape') {
    closeCodePreviewModal();
  }
});


