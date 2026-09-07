/* ==============================================================================
 * Oracle DevOps Platform - Developer Hub (SPA) Client Application Logic
 * Unified Toggle Engine, Health Checkers, Clipboard Helpers, Presentation Deck,
 * Interactive DevOps Console, Profile Editor, and Mermaid Architecture Modals.
 * ============================================================================== */


function switchTab(tabId) {
  document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
  
  if (window.event && window.event.currentTarget && window.event.currentTarget.classList.contains('tab-btn')) {
    window.event.currentTarget.classList.add('active');
  }
  const matchingBtn = document.querySelector(`.tab-btn[onclick*="${tabId}"]`);
  if (matchingBtn) {
    matchingBtn.classList.add('active');
  }
  const activeContent = document.getElementById(tabId);
  if (activeContent) {
    activeContent.classList.add('active');
    if (tabId === 'tab-docs') {
      renderDocsNav(currentSelectedDocIdx);
    } else if (tabId === 'tab-benchmarks') {
      loadBenchmarksData();
    } else if (tabId === 'tab-snapshots') {
      loadSnapshotsTable();
    } else if (tabId === 'tab-podman') {
      loadPodmanResources();
    } else if (tabId === 'tab-testing') {
      initTestingTab();
    }
  }
}

function switchPersona(persona) {
  document.querySelectorAll('.persona-btn').forEach(btn => btn.classList.remove('active'));
  if (window.event && window.event.currentTarget) {
    window.event.currentTarget.classList.add('active');
  }
  if (persona === 'developer') switchTab('tab-services');
  else if (persona === 'security') switchTab('tab-blueprints');
  else if (persona === 'devops') switchTab('tab-devops');
  else if (persona === 'publisher') switchTab('tab-services');
}

function renderMermaidDiagrams(lang) {
  lang = lang || localStorage.getItem('dev_hub_lang') || 'en';
  const diags = MERMAID_DIAGRAMS[lang] || MERMAID_DIAGRAMS['en'];
  
  const activeBpEl = document.getElementById('mermaid-active-blueprint');
  if (activeBpEl) {
    activeBpEl.removeAttribute('data-processed');
    const activeBpDiags = (ACTIVE_BP_MERMAID && (ACTIVE_BP_MERMAID[lang] || ACTIVE_BP_MERMAID['en'])) || '';
    activeBpEl.innerHTML = activeBpDiags;
  }

  const d2 = document.getElementById('mermaid-diag-2');
  if (d2 && diags && diags.length > 1) {
    d2.removeAttribute('data-processed');
    d2.innerHTML = diags[1];
  }

  try {
    mermaid.run({ querySelector: '.mermaid' });
  } catch (err) {
    console.error('Mermaid render error:', err);
  }
}

function setLanguage(lang) {
  if (!I18N_DICT[lang]) lang = 'en';
  localStorage.setItem('dev_hub_lang', lang);
  
  document.querySelectorAll('.lang-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById('btn-' + lang);
  if (activeBtn) activeBtn.classList.add('active');
  const deckActiveBtn = document.getElementById('deck-btn-' + lang);
  if (deckActiveBtn) deckActiveBtn.classList.add('active');
  
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
    if (textEl) textEl.textContent = tmpl.replace('%s', `${matchedCount || 1}/${totalCount || 2}`);
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

async function pollBridgeStatus(manual = false) {
  const connBadge = document.getElementById('bridge-conn-status');
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);
    const resp = await fetch(`${BRIDGE_URL}/api/status`, { signal: controller.signal, mode: 'cors' });
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
      if (data.ords_pools) {
        LIVE_ORDS_POOLS = data.ords_pools;
      }
      if (connBadge) {
        connBadge.innerHTML = '🟢 Bridge :8089 Online';
        connBadge.style.color = '#4ade80';
        connBadge.style.background = 'rgba(34, 197, 94, 0.15)';
      }
      renderModulePills();
      renderBlueprints(currentActiveFilter);
      updateServiceCardsUI();
      renderOrdsGatewayStrip();
      if (manual) showToast('✅ Bridge staatus uuendatud!');
    }
  } catch (e) {
    if (connBadge) {
      connBadge.innerHTML = '⚪ Bridge Offline (:8089)';
      connBadge.style.color = '#94a3b8';
      connBadge.style.background = 'rgba(148, 163, 184, 0.1)';
    }
    renderModulePills();
    renderBlueprints(currentActiveFilter);
    updateServiceCardsUI();
    renderOrdsGatewayStrip();
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
      if (poolData ? (poolData.status === 'online' || poolData.status === 'degraded') : runningList.includes('app-ords')) {
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

  const pill = card.querySelector('.status-pill');
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
    if (!mainSlot.classList.contains('btn-action-main')) {
      mainSlot.outerHTML = `<button type="button" class="btn btn-primary btn-action-main btn-service-switch" onclick="openBlueprintModal(${bNum}, 'ops')"><span>⚡</span> <span data-i18n="btn_manage_ops">${dict.btn_manage_ops || 'Käivitused & Haldus'}</span></button>`;
    } else {
      const labelSpan = mainSlot.querySelector('[data-i18n="btn_manage_ops"]');
      if (labelSpan) {
        labelSpan.textContent = dict.btn_manage_ops || 'Käivitused & Haldus';
      }
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
    const isOnline = p && p.status === 'online';
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

async function syncOrdsPools() {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  showToast('🔄 Sünkroonin ORDS poole...');
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
      if (data.pools) {
        LIVE_ORDS_POOLS = data.pools;
      }
      renderOrdsGatewayStrip();
      checkServiceHealth();
      showToast(dict.ords_sync_success || '✅ ORDS connection pools successfully synchronized!');
    } else {
      showToast('⚠️ ORDS poolide sünkroniseerimine ebaõnnestus.');
    }
  } catch (e) {
    showToast('⚠️ Bridge offline – kasuta käsku: <code>./scripts/internal/manage-ords-pools.sh sync</code>');
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

async function fetchAndRenderProfilesList() {
  const container = document.getElementById('profile-list-container');
  if (!container) return;
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/profiles`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      CACHED_PROFILES = data.profiles || data;
      renderProfilesSidebar(CACHED_PROFILES);
      if (CACHED_PROFILES.length > 0 && !CURRENT_PROFILE_PATH) {
        loadProfileToEditor(CACHED_PROFILES[0].rel_path);
      } else if (CURRENT_PROFILE_PATH) {
        loadProfileToEditor(CURRENT_PROFILE_PATH);
      }
    } else {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge API viga: HTTP ${resp.status}</span>`;
    }
  } catch (e) {
    container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge offline (:8089). Käivitage dev-hub-bridge.py</span>`;
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

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/profile?path=${encodeURIComponent(relPath)}`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (ta) ta.value = (data.content !== undefined) ? data.content : JSON.stringify(data, null, 2);
    } else {
      if (ta) ta.value = `# Failed to load file: HTTP ${resp.status}`;
    }
  } catch (e) {
    if (ta) ta.value = `# Bridge viga: ${e.message}`;
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
    if (msgEl) msgEl.innerHTML = `<span style="color: #f87171;">❌ Bridge viga: ${e.message}</span>`;
  } finally {
    if (btnSave) btnSave.disabled = false;
  }
}

// ==========================================
// 2. BLUEPRINTS MANAGER (Split Layout: List / View / Edit / Clone)
// ==========================================
let CACHED_BLUEPRINTS = [];
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
  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprints`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      CACHED_BLUEPRINTS = data.blueprints || [];
      renderBlueprintsSidebar(CACHED_BLUEPRINTS);
      if (CACHED_BLUEPRINTS.length > 0 && !CURRENT_BP_PATH) {
        loadBlueprintToView(CACHED_BLUEPRINTS[0].rel_path);
      } else if (CURRENT_BP_PATH) {
        loadBlueprintToView(CURRENT_BP_PATH);
      }
    } else {
      container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge API viga: HTTP ${resp.status}</span>`;
    }
  } catch (e) {
    container.innerHTML = `<span style="color: #f87171; font-size: 0.8rem;">Bridge offline (:8089). Käivitage dev-hub-bridge.py</span>`;
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
  if (msgEl) msgEl.innerHTML = `<span style="color: #94a3b8;">Vaaterežiim: <code>${relPath}</code> (Muutmiseks vajuta ✏️ Muuda)</span>`;

  renderBlueprintsSidebar(CACHED_BLUEPRINTS);

  const bpObj = CACHED_BLUEPRINTS.find(b => b.rel_path === relPath);
  if (badgesEl && bpObj) {
    badgesEl.innerHTML = `
      <span class="bp-tag" style="color: #38bdf8;">🏷️ ${bpObj.title || bpObj.name}</span>
      <span class="bp-tag" style="color: #4ade80;">№ ${bpObj.number}</span>
    `;
  }

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/blueprint?path=${encodeURIComponent(relPath)}`, { mode: 'cors' });
    if (resp.ok) {
      const data = await resp.json();
      if (ta) ta.value = data.content || '';
    } else {
      if (ta) ta.value = `# Failed to load file: HTTP ${resp.status}`;
    }
  } catch (e) {
    if (ta) ta.value = `# Bridge viga: ${e.message}`;
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
    const ordsUp = pData ? (pData.status === 'online') : runningList.includes('app-ords');
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
      if (pData ? (pData.status === 'online' || pData.status === 'degraded') : runningList.includes('app-ords')) matched++;
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
  ['arch', 'users', 'ops', 'diag'].forEach(t => {
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
  } else if (activeBpModalTab === 'diag') {
    renderBlueprintDiagTab(activeBpModalNum);
  }
}

async function renderBlueprintMermaid(bNum) {
  const b = BLUEPRINTS_DATA.find(item => item.num === bNum);
  if (!b) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const mermaidContainer = document.getElementById('bp-modal-mermaid');
  if (!mermaidContainer) return;

  mermaidContainer.removeAttribute('data-processed');
  mermaidContainer.setAttribute('data-rendered-bp', String(bNum));
  mermaidContainer.innerHTML = '<div style="color:#94a3b8; font-size:0.85rem; padding:10px;">⏳ Renderin arhitektuurijoonist...</div>';

  const diagCode = (b.diagrams && b.diagrams[currentLang]) || (b.diagrams && b.diagrams['en']) || '';
  if (diagCode) {
    try {
      const svgId = 'bp-modal-svg-' + b.num + '-' + Math.floor(Math.random() * 100000);
      const res = await mermaid.render(svgId, diagCode);
      mermaidContainer.innerHTML = res.svg || res;
    } catch (err) {
      console.error('Mermaid modal render error:', err);
      mermaidContainer.innerHTML = `<pre style="color:#f87171; font-size:0.75rem; white-space:pre-wrap; background:#030712; padding:10px; border-radius:6px;">${diagCode}</pre>`;
    }
  } else {
    mermaidContainer.innerHTML = '<span style="color:#64748b; font-size:0.85rem;">Diagramm pole saadaval.</span>';
  }
}

async function triggerBlueprintActionModal(bNum, action) {
  if (action === 'stop' && bNum === 0) {
    alert('🛡️ Core Base Protection: Blueprint #0 (Tuum) ei saa välja lülitada!');
    return;
  }
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  switchBlueprintModalTab('ops');

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

  const progress = startTerminalProgress('modal-ops-console', action, title, cmdStr);
  document.getElementById('modal-ops-console')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  // 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.6 - DO NOT REVERT TO SYNC FETCH!)
  // RATIONALE: Cold setup and database builds take 4-7 minutes.
  // A synchronous fetch with AbortController timeout (e.g. 300s) WILL ALWAYS ABORT
  // in the browser with "signal is aborted without reason" even when the server
  // finishes successfully.
  // RULE: Long operations (setup, activate, switch, deploy, restart) MUST ALWAYS
  // be dispatched as asynchronous tasks and polled via /api/task/status until state === 'completed'.
  try {
    const isLongOp = ['setup', 'activate', 'switch', 'deploy', 'restart'].includes(action);
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
                  outEl.textContent = statusData.log_tail.join('\n');
                  outEl.scrollTop = outEl.scrollHeight;
                }
              }
              if (statusData.state === 'completed') {
                clearInterval(pollTaskInterval);
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
          openBlueprintModal(bNum, 'ops');
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
      : `⚪ Pinu on hetkel seisatud. Käivitamiseks kasuta allolevaid kaarte või terminali.`;
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
    (b.components || []).forEach(c => {
      compHtml += `
        <tr>
          <td><strong style="color: var(--primary); font-family: ui-monospace, monospace;">${c.name}</strong><br/><span style="font-size:0.75rem; color:#94a3b8;">${c.type}</span></td>
          <td><code style="color: #22c55e; font-weight: 600;">${c.host_ports}</code></td>
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

  // 4. Render Hardware & Resource Requirements
  const resContainer = document.getElementById('bp-modal-resources');
  if (resContainer) {
    resContainer.innerHTML = `
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.modal_config_file || 'Konfiguratsioonifail'}</div>
        <div style="font-size:0.95rem; font-weight:700; color:#38bdf8; font-family:ui-monospace,monospace; margin-top:4px;">${b.file}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.metric_ram || 'Mälu (RAM)'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#38bdf8; margin-top:2px;">${b.ram}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.th_container || 'Konteinereid'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#4ade80; margin-top:2px;">${b.containers}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.metric_accounts || 'Kasutajakontosid'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#c084fc; margin-top:2px;">${(b.users || []).length} ${dict.meta_accounts || 'Accounts'}</div>
      </div>
      <div style="background:rgba(255,255,255,0.03); border:1px solid var(--border); border-radius:8px; padding:12px;">
        <div style="font-size:0.75rem; color:#94a3b8;">${dict.metric_ports || 'Võrgupordid'}</div>
        <div style="font-size:1.2rem; font-weight:700; color:#fbbf24; margin-top:2px;">${(b.container_ports || []).length} ${dict.metric_ports || 'Ports'}</div>
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

    let cardsHtml = '';

    // Card 1: Activate (setup-all.sh)
    const isOnline = isBlueprintActiveOrRunning(b);
    cardsHtml += `
      <div style="background: rgba(56, 189, 248, 0.04); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #38bdf8; font-size: 0.92rem; margin-bottom: 6px; display: flex; align-items: center; justify-content: space-between;">
            <span>${dict.modal_act_activate_title || dict.modal_act_deploy_title || '⚡ Activate'}</span>
            ${isOnline ? `<span class="badge badge-success" style="font-size: 0.72rem; padding: 2px 6px;">🟢 ${dict.status_online || 'Aktiivne'}</span>` : ''}
          </div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${isOnline ? (dict.modal_act_already_active_hint || 'Konteiner(id) on juba aktiivsed ja töötavad. Probleemide korral kasuta: Taaskäivita & Uuenda.') : (dict.modal_act_activate_desc || dict.modal_act_deploy_desc || 'Runs full setup, provisions required containers, and brings services online.')}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/setup-all.sh -b ${b.num} -y --lang ${currentLang}
          </div>
        </div>
        <button class="btn btn-primary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px;" onclick="triggerBlueprintActionModal(${b.num}, 'setup')">
          <span>⚡</span> <span>${dict.modal_act_activate_btn || dict.modal_act_deploy_btn || 'Activate'}</span>
        </button>
      </div>
    `;

    // Card 2: Configuration Preview (Dry-Run)
    cardsHtml += `
      <div style="background: rgba(168, 85, 247, 0.04); border: 1px solid rgba(168, 85, 247, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #c084fc; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_dryrun_title || '🔍 Configuration Preview (Dry-Run)'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_dryrun_desc || 'Pre-evaluates configuration, port bindings, and profile parameters without deploying containers.'}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/deploy-blueprint.sh -b ${b.num} --dry-run
          </div>
        </div>
        <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; color: #c084fc; border-color: rgba(168,85,247,0.5);" onclick="triggerBlueprintActionModal(${b.num}, 'dry-run')">
          <span>🔍</span> <span>${dict.modal_act_dryrun_btn || 'Preview (Dry-Run)'}</span>
        </button>
      </div>
    `;

    // Card 3: Rapid Restore from Golden Snapshot (DB Only)
    if (hasDb) {
      cardsHtml += `
        <div style="background: rgba(34, 197, 94, 0.04); border: 1px solid rgba(34, 197, 94, 0.3); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #4ade80; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_variant_a_title || '⚡ Rapid Restore (~15–45s)'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_variant_a_desc || 'Rolls back uncommitted changes to clean baseline without full reinstall.'}</p>
            <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
              <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
              ./scripts/snapshots/restore-golden-snapshots.sh -b ${b.num} --force
            </div>
          </div>
          <button class="btn btn-primary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; background: #16a34a; border-color: #22c55e;" onclick="triggerRestoreSnapshot(null, ${b.num}, this)">
            <span>⚡</span> <span>${dict.modal_dr_variant_a_btn || 'Restore Golden Snapshot'}</span>
          </button>
        </div>
      `;

      const primaryDb = (b.components || []).find(c => (c.type && (c.type.toLowerCase().includes('database') || c.type.toLowerCase().includes('pdb'))) || (c.name && c.name.startsWith('db-')));
      const dbTargetName = primaryDb ? primaryDb.name : 'db-proxy';
      cardsHtml += `
        <div style="background: rgba(245, 158, 11, 0.04); border: 1px solid rgba(245, 158, 11, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #fbbf24; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_rotate_title || '🔄 Zero-Downtime Credential Rotation'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_rotate_desc || 'Rotates user passwords across Database, Podman Secrets, and SEPS Wallet for this blueprint.'}</p>
            <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
              <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
              ./scripts/rotate-password.sh ${dbTargetName} dev
            </div>
          </div>
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; color: #fbbf24; border-color: rgba(245,158,11,0.5);" onclick="triggerRotateUserPassword(${b.num}, '${dbTargetName}', 'dev', this)">
            <span>🔄</span> <span>${dict.modal_act_rotate_btn || 'Rotate DEV Password'}</span>
          </button>
        </div>
      `;
    }

    // Card: Restart & Update
    cardsHtml += `
      <div id="bp-card-restart-box" style="background: rgba(251, 191, 36, 0.04); border: 1px solid rgba(251, 191, 36, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between; transition: all 0.3s ease;">
        <div>
          <div style="font-weight: 700; color: #fbbf24; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_restart_title || '🔄 Taaskäivita & Uuenda'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_restart_desc || 'Restarts running containers and reapplies configuration updates.'}</p>
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

    // Card 4: Deep Reset & Cold Rebuild
    cardsHtml += `
      <div style="background: rgba(239, 68, 68, 0.04); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #f87171; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_variant_b_title || '⚠️ Deep Reset & Rebuild (~4–8 min)'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_variant_b_desc || 'Wipes volumes and performs complete cold rebuild from scratch.'}</p>
          <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
            <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
            ./scripts/reset-all.sh -y &amp;&amp; ./scripts/setup-all.sh -b ${b.num} -y --lang ${currentLang}
          </div>
        </div>
        <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; border-color: rgba(239,68,68,0.5); color: #f87171;" onclick="triggerDeepReset(${b.num}, this)">
          <span>⚠️</span> <span>${dict.modal_dr_variant_b_btn || 'Deep Reset (Cold Rebuild)'}</span>
        </button>
      </div>
    `;

    // Card 5: Stop Services
    const isCoreProtected = b.num === 0;
    cardsHtml += `
      <div style="background: rgba(148, 163, 184, 0.04); border: 1px solid rgba(148, 163, 184, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
        <div>
          <div style="font-weight: 700; color: #cbd5e1; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_act_stop_title || '⏹️ Stop Services'}</div>
          <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_act_stop_desc || 'Gracefully stops active containers for this blueprint and releases system memory.'}</p>
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
            <span>⏹️</span> <span>${dict.modal_act_stop_btn || 'Stop Services'}</span>
          </button>
        `}
      </div>
    `;

    // Card 6: Save Current State / Custom Snapshot (DB Only)
    if (hasDb) {
      cardsHtml += `
        <div style="background: rgba(56, 189, 248, 0.04); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
          <div>
            <div style="font-weight: 700; color: #38bdf8; font-size: 0.92rem; margin-bottom: 6px;">${dict.modal_dr_custom_title || '📸 Save Current State'}</div>
            <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${dict.modal_dr_custom_desc || 'Save your sample data or work-in-progress as a named snapshot.'}</p>
            <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 10px;">
              <input type="text" id="modal-snap-tag-${b.num}" placeholder="${dict.modal_dr_custom_placeholder || 'Tag / Name'}" style="width: 100%; padding: 6px 10px; font-size: 0.8rem; background: #030712; border: 1px solid var(--border); border-radius: 6px; color: #f8fafc; outline: none; font-family: ui-monospace, monospace;" />
              <input type="text" id="modal-snap-desc-${b.num}" placeholder="${dict.snap_placeholder_desc || 'Optional description...'}" style="width: 100%; padding: 6px 10px; font-size: 0.8rem; background: #030712; border: 1px solid var(--border); border-radius: 6px; color: #f8fafc; outline: none;" />
            </div>
          </div>
          <button class="btn btn-secondary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px; border-color: rgba(56,189,248,0.5); color: #38bdf8;" onclick="triggerCreateCustomSnapshotModal(${b.num}, this)">
            <span>📸</span> <span>${dict.modal_dr_custom_btn || 'Create Snapshot'}</span>
          </button>
        </div>
      `;
    }

    actionsGrid.innerHTML = cardsHtml;
  }

  // Switch to requested initial tab
  switchBlueprintModalTab(initialTab || 'arch');

  // Open modal backdrop
  const modal = document.getElementById('bp-modal-backdrop');
  if (modal) modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function renderBlueprintDiagTab(bNum) {
  const grid = document.getElementById('bp-modal-diag-grid');
  if (!grid) return;

  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  const diagItems = [
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

  grid.innerHTML = diagItems.map(item => `
    <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 8px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between;">
      <div>
        <div style="font-weight: 700; color: ${item.color}; font-size: 0.92rem; margin-bottom: 6px;">${item.title}</div>
        <p style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.4; margin: 0 0 10px 0;">${item.desc}</p>
        <div class="code-box" style="font-size: 0.75rem; margin-bottom: 10px;">
          <button class="copy-btn" onclick="copySnippet(this)">Copy</button>
          ${item.cmd}
        </div>
      </div>
      <button class="btn btn-primary" style="width: 100%; font-size: 0.82rem; padding: 6px 12px;" onclick="runDiagCommand('${item.key}', '${item.cmd}', this)">
        <span>▶️</span> <span>${dict.btn_run_now || 'Käivita kohe'}</span>
      </button>
    </div>
  `).join('');
}

async function runDiagCommand(cmdKey, cmdStr, btn) {
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

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

    const isSuccess = resp.ok && (data.ok || data.status === 'ok') && data.exit_code === 0;
    if (progress) {
      progress.finish(isSuccess, data);
    }
  } catch (err) {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = origBtnText;
    }
    console.error('Error running diag command:', err);
    if (progress) {
      progress.finish(false, { error: err.message, output: `Ühenduse viga dev-hub-bridge serveriga:\n${err.message}\n\nKäivita terminalis:\n${cmdStr}` });
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
    const resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(logFile)}`, {
      method: 'GET',
      mode: 'cors'
    });
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

async function toggleActiveTerminalLog(containerId) {
  const viewer = document.getElementById(`${containerId}-full-log-viewer`);
  const pathEl = document.getElementById(`${containerId}-log-path`);
  const toggleBtn = document.getElementById(`${containerId}-log-toggle-btn`);
  if (!viewer || !pathEl) return;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];

  if (viewer.style.display !== 'none') {
    viewer.style.display = 'none';
    if (toggleBtn) toggleBtn.innerHTML = `<span>👁️</span> <span>${dict.btn_open_log || 'Ava logi'}</span>`;
    return;
  }

  const logFile = pathEl.getAttribute('data-log-file') || pathEl.textContent.trim().replace(/^install_logs\//, '');
  viewer.style.display = 'block';
  viewer.innerHTML = `⏳ ${dict.log_loading || 'Laadin logi sisu...'}`;
  if (toggleBtn) toggleBtn.innerHTML = `<span>✕</span> <span>${dict.btn_hide_log || 'Peida logi'}</span>`;

  try {
    const resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(logFile)}`, {
      method: 'GET',
      mode: 'cors'
    });
    if (!resp.ok) {
      if (resp.status === 404) {
        viewer.innerHTML = `<span style="color:#94a3b8;">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      throw new Error(`HTTP ${resp.status}`);
    }
    const data = await resp.json();
    if (data.ok || data.status === 'ok') {
      if (data.found === false) {
        viewer.innerHTML = `<span style="color:#94a3b8;">${dict.log_not_found || 'ℹ️ Logifaili pole veel loodud või eelnev paigalduslogi puudub.'}</span>`;
        return;
      }
      viewer.textContent = data.content || `(${dict.log_empty || 'Logi on tühi'})`;
      viewer.scrollTop = viewer.scrollHeight;
    } else {
      viewer.innerHTML = `<span style="color:#f87171;">Viga: ${data.error || 'Logi ei õnnestunud lugeda'}</span>`;
    }
  } catch (err) {
    viewer.innerHTML = `<span style="color:#f87171;">Viga logi pärimisel: ${err.message}</span>`;
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
        <pre class="console-body" style="margin:0; font-size:0.75rem; color:#cbd5e1; white-space:pre-wrap; max-height:220px; overflow-y:auto;">${data.output || '(Käsk lõpetas ilma väljundita)'}</pre>
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

function renderDocsNav(selectedIdx) {
  const sidebar = document.getElementById('docs-sidebar-nav');
  if (!sidebar) return;
  sidebar.innerHTML = '';
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  currentSelectedDocIdx = selectedIdx || 0;
  
  DOCS_DATA.forEach((doc, idx) => {
    const btn = document.createElement('button');
    btn.className = 'docs-nav-item' + (idx === currentSelectedDocIdx ? ' active' : '');
    btn.setAttribute('data-doc-idx', idx);
    const title = (doc.titles && doc.titles[currentLang]) || (doc.titles && doc.titles['en']) || doc.rel;
    const shortName = doc.rel.replace('docs/', '').replace('.md', '');
    btn.innerHTML = `
      <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1;">${title}</span>
      <span style="font-size: 0.72rem; opacity: 0.6; font-family: ui-monospace, monospace; margin-left: 6px;">${shortName}</span>
    `;
    btn.onclick = () => loadDocContent(idx, btn);
    sidebar.appendChild(btn);
  });
  
  const searchInput = document.getElementById('docs-search-input');
  if (searchInput && searchInput.value) {
    filterDocsList(searchInput.value);
  }
  
  if (DOCS_DATA.length > 0 && sidebar.children[currentSelectedDocIdx]) {
    loadDocContent(currentSelectedDocIdx, sidebar.children[currentSelectedDocIdx]);
  }
}

function filterDocsList(query) {
  query = (query || '').toLowerCase().trim();
  const navItems = document.querySelectorAll('.docs-nav-item');
  navItems.forEach(item => {
    const text = item.textContent.toLowerCase();
    if (!query || text.includes(query)) {
      item.style.display = 'flex';
    } else {
      item.style.display = 'none';
    }
  });
}

function loadDocContent(idx, activeBtn) {
  currentSelectedDocIdx = idx;
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const dict = I18N_DICT[currentLang] || I18N_DICT['en'];
  
  if (activeBtn) {
    document.querySelectorAll('.docs-nav-item').forEach(b => b.classList.remove('active'));
    activeBtn.classList.add('active');
  }
  
  const headerEl = document.getElementById('docs-content-header');
  const bodyEl = document.getElementById('docs-rendered-body');
  if (!bodyEl) return;
  
  const doc = DOCS_DATA[idx];
  if (!doc) return;

  const title = (doc.titles && doc.titles[currentLang]) || (doc.titles && doc.titles['en']) || doc.rel;
  const text = (doc.contents && (doc.contents[currentLang] || doc.contents['en'])) || '';
  const wordCount = text ? text.split(/\s+/).length : 0;
  const readMin = Math.max(1, Math.ceil(wordCount / 200));

  if (headerEl) {
    headerEl.innerHTML = `
      <div style="display: flex; flex-direction: column; gap: 4px;">
        <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
          <h2 style="margin: 0; color: #f8fafc; font-size: 1.3rem;">${title}</h2>
          <span class="badge badge-primary" style="font-family: ui-monospace, monospace; font-size: 0.75rem;">${doc.rel}</span>
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

  if (text) {
    bodyEl.innerHTML = marked.parse(text);
    // Re-render any mermaid diagrams inside the rendered markdown
    try {
      mermaid.run({ nodes: bodyEl.querySelectorAll('.mermaid') });
    } catch (err) {}
  } else {
    bodyEl.innerHTML = `
      <div style="background: #1e293b; padding: 24px; border-radius: 8px; border: 1px solid var(--border);">
        <h3 style="color: var(--primary); margin-bottom: 8px;">📄 Repository Documentation: <code>${doc.rel}</code></h3>
        <p style="color: var(--text-muted); margin-bottom: 16px;">This markdown guide is located directly in the project repository workspace at: <code>${doc.rel}</code></p>
        <pre><code>cat ${doc.rel}</code></pre>
      </div>
    `;
  }
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

  // 3. Execution Logs Console
  if (logsContainer) {
    const logs = (LOGS_DATA && LOGS_DATA.length > 0) ? LOGS_DATA : [
      {
        filename: "setup-all.log",
        mtime: lastUpdatedStr,
        size_bytes: 1024,
        content: `==================================================================\nOracle DevOps Platform - Setup Complete\nBlueprint #${ACTIVE_BP_NUM} active & operational\nTotal setup duration: ${setup.total_duration_formatted || '15m 20s'}\n==================================================================`
      }
    ];

    let logTabsHtml = `<div style="display: flex; gap: 8px; margin-bottom: 12px; overflow-x: auto; padding-bottom: 4px;">`;
    logs.forEach((log, idx) => {
      const activeClass = (idx === currentSelectedLogIdx) ? 'active' : '';
      logTabsHtml += `
        <button class="persona-btn ${activeClass}" style="padding: 6px 12px; font-size: 0.8rem;" onclick="switchLogFile(${idx})">
          📄 ${log.filename}
        </button>
      `;
    });
    logTabsHtml += `</div>`;

    const curLog = logs[currentSelectedLogIdx] || logs[0];
    const logViewerHtml = `
      <div style="background: #030712; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 16px; position: relative;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 8px;">
          <div style="font-size: 0.8rem; color: #94a3b8; font-family: ui-monospace, monospace;">
            📄 <strong>${curLog.filename}</strong> | Size: ${(curLog.size_bytes / 1024).toFixed(1)} KB | Modified: ${curLog.mtime}
          </div>
          <button class="btn-pwd-copy" style="padding: 4px 10px; font-size: 0.75rem;" onclick="copyCurrentLogText()">
            📋 ${dict.bench_btn_copy_log || 'Copy Log'}
          </button>
        </div>
        <pre id="current-log-pre" style="color: #38bdf8; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 0.8rem; line-height: 1.5; max-height: 380px; overflow-y: auto; white-space: pre-wrap; word-break: break-all;">${curLog.content}</pre>
      </div>
    `;

    logsContainer.innerHTML = logTabsHtml + logViewerHtml;
  }
}

function switchLogFile(idx) {
  currentSelectedLogIdx = idx;
  loadBenchmarksData();
}

function copyCurrentLogText() {
  const pre = document.getElementById('current-log-pre');
  if (pre) {
    navigator.clipboard.writeText(pre.textContent).then(() => {
      showToast('📋 Log content copied to clipboard!');
    });
  }
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

function renderSlideDeck(lang) {
  if (!SLIDES_CONTENT) return;
  if (!lang || !I18N_DICT[lang]) lang = localStorage.getItem('dev_hub_lang') || 'en';
  
  // Render top number buttons
  const topNumsContainer = document.getElementById('top-slide-numbers');
  if (topNumsContainer) {
    let topBtnsHtml = '';
    for (let i = 1; i <= totalSlides; i++) {
      const activeClass = (i === currentSlideIdx + 1) ? 'active' : '';
      topBtnsHtml += `<button class="slide-num-btn ${activeClass}" id="top-btn-slide-${i}" onclick="goToSlide(${i - 1})">${i}</button>`;
    }
    topNumsContainer.innerHTML = topBtnsHtml;
  }
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

    // Stepper Process Timeline or Comparison
    let diagramHtml = '';
    if (sData.comparison_diagram) {
      const cd = sData.comparison_diagram;
      const defaultCompTitle = (lang === 'et') ? 'Taastamise ja töökindluse võrdlus' :
                               (lang === 'fi') ? 'Palautumisen ja häiriönsietokyvyn vertailu' :
                               (lang === 'sv') ? 'Jämförelse av återställning och driftsäkerhet' :
                               (lang === 'lv') ? 'Atjaunošanas un noturības salīdzinājums' :
                               (lang === 'lt') ? 'Atkūrimo ir atsparumo palyginimas' :
                               'Recovery & Resilience Comparison';
      const cdTitle = getSlideI18n(cd.title, lang, defaultCompTitle);
      const badLabel = getSlideI18n(cd.bad && cd.bad.label, lang, 'TRADITIONAL');
      const goodLabel = getSlideI18n(cd.good && cd.good.label, lang, 'ORACLE DEVOPS PLATFORM');
      
      const renderStepperSteps = (steps) => {
        if (!steps || !Array.isArray(steps)) return '';
        return steps.map((st, idx) => {
          const num = idx + 1;
          const stTitle = getSlideI18n(st.title, lang);
          const stSub = getSlideI18n(st.sub, lang);
          return `
            <div class="stepper-step">
              <div class="stepper-circle-wrap">
                <div class="stepper-num">${num}</div>
                <div class="stepper-line"></div>
              </div>
              <div class="stepper-body">
                <div class="stepper-title">${stTitle}</div>
                <div class="stepper-sub">${stSub}</div>
              </div>
            </div>
          `;
        }).join('');
      };

      const badNodes = (cd.bad && (cd.bad.nodes || cd.bad.steps)) || [];
      const goodNodes = (cd.good && (cd.good.nodes || cd.good.steps)) || [];

      diagramHtml = `
        <div class="stepper-card">
          <div class="stepper-header">
            <span class="stepper-header-icon">⚖️</span>
            <span class="stepper-header-title">${cdTitle}</span>
          </div>
          <div class="comparison-stepper-list">
            <div class="comparison-stepper-row bad">
              <span class="comparison-track-label">${badLabel}</span>
              <div class="stepper-timeline">${renderStepperSteps(badNodes)}</div>
            </div>
            <div class="comparison-stepper-row good">
              <span class="comparison-track-label">${goodLabel}</span>
              <div class="stepper-timeline">${renderStepperSteps(goodNodes)}</div>
            </div>
          </div>
        </div>
      `;
    } else if (sData.diagram && (sData.diagram.steps || sData.diagram.nodes)) {
      const d = sData.diagram;
      const dTitle = getSlideI18n(d.title, lang, 'Protsessietapid');
      const steps = d.steps || d.nodes || [];
      const stepsHtml = steps.map((st, idx) => {
        const num = idx + 1;
        const stTitle = getSlideI18n(st.title, lang);
        const stSub = getSlideI18n(st.sub, lang);
        return `
          <div class="stepper-step">
            <div class="stepper-circle-wrap">
              <div class="stepper-num">${num}</div>
              <div class="stepper-line"></div>
            </div>
            <div class="stepper-body">
              <div class="stepper-title">${stTitle}</div>
              <div class="stepper-sub">${stSub}</div>
            </div>
          </div>
        `;
      }).join('');

      diagramHtml = `
        <div class="stepper-card">
          <div class="stepper-header">
            <span class="stepper-header-icon">⏱️</span>
            <span class="stepper-header-title">${dTitle}</span>
          </div>
          <div class="stepper-timeline">
            ${stepsHtml}
          </div>
        </div>
      `;
    }

    // Cards
    let cardsHtml = '';
    const numCards = sData.cards ? sData.cards.length : 0;
    const gridClass = (numCards === 3) ? 'slide-grid-3' : (numCards === 2) ? 'slide-grid-2' : (numCards === 4) ? 'slide-grid-4' : 'slide-grid';

    cardsHtml += `<div class="${gridClass}">`;
    if (sData.cards) {
      sData.cards.forEach(c => {
        const cTitle = getSlideI18n(c.title, lang);
        const cDesc = getSlideI18n(c.desc, lang);
        const iconHtml = c.icon ? `<span class="slide-card-icon-wrap">${c.icon}</span>` : '';
        const kpiHtml = c.kpi ? `<span class="slide-kpi-badge">${c.kpi}</span>` : '';
        let cmdHtml = '';
        if (c.command) {
          const copyLabel = (lang === 'et') ? '📋 Kopeeri' : (lang === 'fi') ? '📋 Kopioi' : (lang === 'sv') ? '📋 Kopiera' : (lang === 'lv') ? '📋 Kopēt' : (lang === 'lt') ? '📋 Kopijuoti' : '📋 Copy';
          cmdHtml = `
            <div class="slide-code-box">
              <code>${c.command}</code>
              <button class="slide-copy-btn" onclick="copySlideCode(this, '${c.command}')">${copyLabel}</button>
            </div>`;
        }
        cardsHtml += `
          <div class="slide-card">
            <div class="slide-card-top-row">
              ${iconHtml}
              ${kpiHtml}
            </div>
            <h4 class="slide-card-title">${cTitle}</h4>
            <p class="slide-card-desc">${cDesc}</p>
            ${cmdHtml}
          </div>`;
      });
    }
    cardsHtml += `</div>`;

    // Slide 12 official Oracle resources pills
    let oracleLinksHtml = '';
    if (sData.oracle_links && sData.oracle_links.length > 0) {
      const oracleLabel = (lang === 'et') ? '🌐 Ametlikud Oracle dokumentatsiooni veebilingid:' : (lang === 'fi') ? '🌐 Viralliset Oracle-dokumentaatiolinkit:' : (lang === 'sv') ? '🌐 Officiella Oracle-dokumentationslänkar:' : (lang === 'lv') ? '🌐 Oficiālās Oracle dokumentācijas saites:' : (lang === 'lt') ? '🌐 Oficialios Oracle dokumentacijos nuorodos:' : '🌐 Official Oracle Documentation Resources:';
      oracleLinksHtml += `
        <div style="margin-top: 18px; padding-top: 14px; border-top: 1px dashed rgba(255,255,255,0.1);">
          <div style="font-size: 0.82rem; font-weight: 700; color: #f87171; margin-bottom: 8px;">${oracleLabel}</div>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">`;
      sData.oracle_links.forEach(l => {
        oracleLinksHtml += `<a href="${l.url}" target="_blank" rel="noopener noreferrer" class="oracle-link-pill">🔗 ${l.title} ↗</a>`;
      });
      oracleLinksHtml += `</div></div>`;
    }

    slideEl.innerHTML = `
      <div class="slide-badge">${bText}</div>
      <h3 class="slide-heading">${tText}</h3>
      <p class="slide-lead">${lText}</p>
      ${diagramHtml}
      ${cardsHtml}
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
    counter.textContent = `${label} ${currentSlideIdx + 1} / ${totalSlides}`;
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
  const topNumsContainer = document.getElementById('top-slide-numbers');
  if (topNumsContainer) {
    const numBtns = topNumsContainer.getElementsByClassName('slide-num-btn');
    for (let i = 0; i < numBtns.length; i++) {
      if (i === currentSlideIdx) numBtns[i].classList.add('active');
      else numBtns[i].classList.remove('active');
    }
  }

  // Update speaker notes
  const lang = localStorage.getItem('dev_hub_lang') || 'en';
  updateSpeakerNotes(lang);
}

function nextSlide() {
  currentSlideIdx = (currentSlideIdx + 1) % totalSlides;
  updateSlideView();
}

function prevSlide() {
  currentSlideIdx = (currentSlideIdx - 1 + totalSlides) % totalSlides;
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
}

function closeSlideModal() {
  const backdrop = document.getElementById('slide-modal-backdrop');
  if (!backdrop) return;
  backdrop.style.display = 'none';
  document.body.style.overflow = '';
  window.removeEventListener('keydown', handleModalKeyDown);
  clearTimeout(modalIdleTimer);
  updateSlideView();
}

function syncModalSlide() {
  const modalContent = document.getElementById('modal-slide-content');
  const activeSlide = document.getElementById('slide-' + (currentSlideIdx + 1));
  if (modalContent && activeSlide) {
    modalContent.innerHTML = activeSlide.innerHTML;
  }
  
  // Update modal slide counter
  const modalCounter = document.getElementById('modal-slide-counter');
  if (modalCounter) {
    const lang = localStorage.getItem('dev_hub_lang') || 'en';
    const label = (lang === 'et') ? 'Slaid' : (lang === 'fi') ? 'Dia' : (lang === 'sv') ? 'Bild' : (lang === 'lv') ? 'Slaids' : (lang === 'lt') ? 'Skaidrė' : 'Slide';
    modalCounter.textContent = `${label} ${currentSlideIdx + 1} / ${totalSlides}`;
  }

  // Update modal bottom dots
  const modalDotsContainer = document.getElementById('modal-slide-dots');
  if (modalDotsContainer) {
    let dotsHtml = '';
    for (let i = 0; i < totalSlides; i++) {
      const activeClass = (i === currentSlideIdx) ? 'active' : '';
      dotsHtml += `<span class="slide-dot ${activeClass}" onclick="modalGoToSlide(${i})"></span>`;
    }
    modalDotsContainer.innerHTML = dotsHtml;
  }

  // Keep in-page slide view in sync
  updateSlideView();
}

function modalNextSlide() {
  currentSlideIdx = (currentSlideIdx + 1) % totalSlides;
  syncModalSlide();
}

function modalPrevSlide() {
  currentSlideIdx = (currentSlideIdx - 1 + totalSlides) % totalSlides;
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
  switchTab('tab-docs');
  if (typeof selectDocById === 'function') {
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
    const toastMsg = (currentLang === 'et')
      ? `🚀 Avati portaal! Kasutajanimi: <b>${user || alias}</b>.<br/>🔑 Parool on kopeeritud lõikelauale – kleebi see (Ctrl+V / Cmd+V) paroolilahtrisse!` + (isSdw ? `<br/><small style="color:#fbbf24;">${dict.tip_sdw_warmup || '⏳ Database Actions esmane laadimine võib võtta ~10-15s (Java/ORDS soojendus)...'}</small>` : '')
      : `🚀 Portal opened! Username: <b>${user || alias}</b>.<br/>🔑 Password copied to clipboard – paste (Ctrl+V / Cmd+V) on password field!` + (isSdw ? `<br/><small style="color:#fbbf24;">${dict.tip_sdw_warmup || '⏳ First Database Actions load takes ~10-15s (Java/ORDS warmup)...'}</small>` : '');
    showToast(toastMsg);
  } else {
    showToast(`ℹ️ Opening portal for <b>${user || alias}</b>...` + (isSdw ? `<br/><small style="color:#fbbf24;">${dict.tip_sdw_warmup || '⏳ First Database Actions load takes ~10-15s (Java/ORDS warmup)...'}</small>` : ''));
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

function toggleWalletMatrix(forceOpen) {
  const drawer = document.getElementById('wallet-matrix-drawer');
  const label = document.getElementById('wallet-toggle-label');
  const icon = document.getElementById('wallet-toggle-icon');
  if (!drawer) return;
  
  const currentLang = localStorage.getItem('dev_hub_lang') || 'en';
  const isOpen = (forceOpen !== undefined) ? !forceOpen : (drawer.style.maxHeight !== '0px' && drawer.style.maxHeight !== '');
  
  if (isOpen) {
    drawer.style.maxHeight = '0px';
    drawer.style.opacity = '0';
    if (icon) icon.textContent = '➕';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_show_matrix']) || 'Show Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'false');
  } else {
    drawer.style.maxHeight = '2500px';
    drawer.style.opacity = '1';
    if (icon) icon.textContent = '➖';
    if (label) label.textContent = (I18N_DICT[currentLang] && I18N_DICT[currentLang]['toggle_hide_matrix']) || 'Hide Matrix';
    localStorage.setItem('dev_hub_wallet_open', 'true');
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

      return `<tr>
        <td style="font-weight: 600; color: #f8fafc;">${escapePodmanHtml(c.name || '')}</td>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(c.id)}', this)" title="Click to copy ID">${escapePodmanHtml(c.id)} 📋</span></td>
        <td style="color: #cbd5e1; font-size: 0.8rem;">${escapePodmanHtml(c.image || '')}</td>
        <td>${stateBadge}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(c.status || '')}</td>
        <td style="font-family: ui-monospace, monospace; font-size: 0.78rem; color: #38bdf8;">${escapePodmanHtml(c.ports || '-')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(c.created || '-')}</td>
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
      tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    tbody.innerHTML = list.map(v => {
      const usedByHtml = (v.used_by && v.used_by.length > 0)
        ? v.used_by.map(u => `<span class="badge badge-primary" style="font-size: 0.72rem; margin-right: 4px;">📦 ${escapePodmanHtml(u)}</span>`).join('')
        : '<span style="color: var(--text-dim); font-size: 0.78rem;">— (unused)</span>';

      return `<tr>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(v.name)}', this)" title="Click to copy volume name">${escapePodmanHtml(v.name)} 📋</span></td>
        <td>${usedByHtml}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(v.driver || 'local')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem;">${escapePodmanHtml(v.scope || 'local')}</td>
        <td style="font-size: 0.76rem; color: #94a3b8; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${escapePodmanHtml(v.mountpoint || '')}"><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(v.mountpoint || '')}', this)">${escapePodmanHtml(v.mountpoint || '-')} 📋</span></td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(v.created || '-')}</td>
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
      tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding: 24px; color: var(--text-dim);">${emptyMsg}</td></tr>`;
      return;
    }

    tbody.innerHTML = list.map(img => {
      return `<tr>
        <td style="font-weight: 600; color: #f8fafc;">${escapePodmanHtml(img.repository || '')}</td>
        <td><span class="badge badge-primary" style="font-size: 0.75rem;">${escapePodmanHtml(img.tag || 'latest')}</span></td>
        <td><span class="code-clip-token" onclick="copyPodmanToken('${escapePodmanHtml(img.id)}', this)" title="Click to copy image ID">${escapePodmanHtml(img.id)} 📋</span></td>
        <td style="font-weight: 600; color: #38bdf8; font-size: 0.82rem;">${escapePodmanHtml(img.size_human || '-')}</td>
        <td style="color: var(--text-dim); font-size: 0.8rem; white-space: nowrap;">${escapePodmanHtml(img.created || '-')}</td>
      </tr>`;
    }).join('');
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

      <!-- Live Monospace Terminal Log Box -->
      <div style="font-size: 0.74rem; color: #64748b; margin-bottom: 5px; display: flex; justify-content: space-between; align-items: center;">
        <span>💻 ${dict.snap_output_title || 'Terminali väljund ja logi'}</span>
        <span style="font-family: ui-monospace, monospace; color: #94a3b8;">$ ${cmdStr}</span>
      </div>
      <pre id="${containerId}-output" style="margin: 0; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace; font-size: 0.76rem; color: #cbd5e1; background: #000; border: 1px solid #1e293b; border-radius: 6px; padding: 10px; max-height: 170px; overflow-y: auto; white-space: pre-wrap; word-break: break-all; line-height: 1.45;"></pre>

      <!-- Active Log File Bar -->
      <div id="${containerId}-log-bar" style="margin-top: 8px; display: flex; justify-content: space-between; align-items: center; background: rgba(15,23,42,0.8); border: 1px solid #1e293b; border-radius: 6px; padding: 6px 10px; font-size: 0.76rem; flex-wrap: wrap; gap: 6px;">
        <div style="display: flex; align-items: center; gap: 8px; min-width: 0; flex: 1;">
          <span style="color: #94a3b8; font-size: 0.74rem; white-space: nowrap;">📄 ${dict.label_active_log || 'Aktiivne logifail'}:</span>
          <span id="${containerId}-log-path" data-log-file="${initialLogName}" style="color: #38bdf8; font-family: ui-monospace, monospace; font-size: 0.76rem; text-decoration: underline; cursor: pointer; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;" onclick="toggleActiveTerminalLog('${containerId}')" title="${dict.tip_click_open_log || 'Klõpsa logi avamiseks'}">${initialLogRel}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px;">
          <button type="button" class="btn btn-secondary" style="padding: 2px 8px; font-size: 0.72rem;" onclick="copyActiveLogPath(document.getElementById('${containerId}-log-path').getAttribute('data-full-path') || document.getElementById('${containerId}-log-path').textContent, this)" title="${dict.btn_copy_path || 'Kopeeri tee'}">
            <span>📋</span> <span>${dict.btn_copy_path || 'Kopeeri tee'}</span>
          </button>
          <button id="${containerId}-log-toggle-btn" type="button" class="btn btn-secondary" style="padding: 2px 8px; font-size: 0.72rem;" onclick="toggleActiveTerminalLog('${containerId}')">
            <span>👁️</span> <span>${dict.btn_open_log || 'Ava logi'}</span>
          </button>
        </div>
      </div>
      <div id="${containerId}-full-log-viewer" style="display: none; margin-top: 6px; background: #030712; border: 1px solid #334155; border-radius: 6px; padding: 10px; font-family: ui-monospace, monospace; font-size: 0.74rem; color: #cbd5e1; max-height: 220px; overflow-y: auto; white-space: pre-wrap; word-break: break-all;"></div>

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

  let seconds = 0;
  const logLines = [];

  function appendLog(line) {
    logLines.push(line);
    if (outEl) {
      outEl.textContent = logLines.join('\n');
      outEl.scrollTop = outEl.scrollHeight;
    }
  }

  appendLog(`[00:00] Käivitan: ${cmdStr}`);

  function updateUI() {
    const mm = String(Math.floor(seconds / 60)).padStart(2, '0');
    const ss = String(seconds % 60).padStart(2, '0');
    if (timerEl) timerEl.textContent = `⏱️ ${mm}:${ss}`;

    if (opType === 'create') {
      if (seconds === 2) appendLog(`[${mm}:${ss}] Kontrollin andmebaasi seisu ja teostan CHECKPOINT...`);
      if (seconds === 6) appendLog(`[${mm}:${ss}] SGA puhvrid kettale kirjutatud. Alustan oradata tihendamist tar.gz arhiivi...`);
      if (seconds === 16) appendLog(`[${mm}:${ss}] Tihendamine käib: ~500 MB töödeldud...`);
      if (seconds === 30) appendLog(`[${mm}:${ss}] Tihendamine lõpusirgel: pakin metaandmeid (.meta.json)...`);

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
      if (seconds === 2) appendLog(`[${mm}:${ss}] Peatan ajutiselt aktiivsed konteinerid andmekonsistentsi tagamiseks...`);
      if (seconds === 6) appendLog(`[${mm}:${ss}] Eemaldan vana oradata mahu ja paki lahti kuldse hetktõmmise...`);
      if (seconds === 16) appendLog(`[${mm}:${ss}] Käivitan konteinerid ja kontrollin SEPS Wallet ühendusi...`);

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
      if (seconds === 2) appendLog(`[${mm}:${ss}] Alustan süvapuhastust (reset-all.sh)...`);
      if (seconds === 25) appendLog(`[${mm}:${ss}] Puhastus lõpetatud. Alustan täispaigaldust nullist (setup-all.sh)...`);
      if (seconds === 90) appendLog(`[${mm}:${ss}] Ootan Oracle DB tervislikku seisundit ja käivitan teenuseid...`);
      if (seconds === 240) appendLog(`[${mm}:${ss}] DB tervislik. Teostan skeemide, kasutajate ja SEPS rahakoti seadistuse...`);

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
      if (seconds === 2) appendLog(`[${mm}:${ss}] Alustan arhitektuuri paigaldust ja seadistust (setup-all.sh)...`);
      if (seconds === 20) appendLog(`[${mm}:${ss}] Konteinerid käivitatud. Ootan andmebaasi tervislikku olekut...`);
      if (seconds === 90) appendLog(`[${mm}:${ss}] Andmebaasi tervisekontroll käib: initsialiseerin PDB ja andmeruume...`);
      if (seconds === 180) appendLog(`[${mm}:${ss}] Seadistan profiili kasutajaid, skeeme, õigusi ja SEPS rahakotti...`);
      if (seconds === 300) appendLog(`[${mm}:${ss}] Seadistan ORDS basseine ja kontrollin veebiteenuste valmidust...`);

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
      if (seconds === 2) appendLog(`[${mm}:${ss}] Kontrollin konfiguratsiooni ja võrgupordi ressursse...`);
      if (seconds === 6) appendLog(`[${mm}:${ss}] Käivitan valitud arhitektuuri konteinereid ja teenuseid...`);
      if (seconds === 14) appendLog(`[${mm}:${ss}] Ootan tervislikku olekut ja uuendan SEPS Wallet aliaseid...`);
      if (seconds === 24) appendLog(`[${mm}:${ss}] Kontrollin ORDS ja APEX portaalide valmidust...`);
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
      if (seconds === 1) appendLog(`[${mm}:${ss}] Peatan arhitektuuri teenuseid ja vabastan mälu (0 MB RAM)...`);
      if (seconds === 3) appendLog(`[${mm}:${ss}] Ootan konteinerite ohutut seiskumist ja võrguportide vabastamist...`);
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
      if (seconds === 2) appendLog(`[${mm}:${ss}] Taaskäivitan arhitektuuri teenuseid ja kontrollin konfiguratsiooni...`);
      if (seconds === 6) appendLog(`[${mm}:${ss}] Kontrollin konteinerite tervislikku seisundit ja võrguporte...`);
      if (seconds === 12) appendLog(`[${mm}:${ss}] Kinnitan SEPS Wallet ja ORDS ühenduste toimimist...`);
      if (seconds === 22) appendLog(`[${mm}:${ss}] Viimistlen taaskäivituse olekut ja teenuste valmidust...`);
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
      if (seconds === 1) appendLog(`[${mm}:${ss}] Käivitan testimise ja diagnostika skripti...`);
      if (seconds === 4) appendLog(`[${mm}:${ss}] Ootan vastust ja analüüsin tulemusi...`);
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
        const resp = await fetch(`${BRIDGE_URL}/api/log/read?file=${encodeURIComponent(initialLogName)}`);
        if (resp.ok) {
          const d = await resp.json();
          if (d.content && d.content.trim()) {
            const rawLines = d.content.trim().split('\n');
            const recent = rawLines.slice(-25).join('\n');
            if (outEl && recent) {
              outEl.textContent = recent;
              outEl.scrollTop = outEl.scrollHeight;
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
        appendLog(`\n--- [${mm}:${ss}] Täielik skripti väljund: ---\n` + data.output);
      }

      if (data && (data.log_file || data.log_relative_path)) {
        const logPathEl = document.getElementById(`${containerId}-log-path`);
        if (logPathEl) {
          const rel = data.log_relative_path || ('install_logs/' + data.log_file);
          logPathEl.textContent = rel;
          logPathEl.setAttribute('data-log-file', data.log_file);
          if (data.log_full_path) logPathEl.setAttribute('data-full-path', data.log_full_path);
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

    html += `
      <div class="test-suite-card">
        <div>
          <div class="test-suite-header">
            <div class="test-suite-title">
              <span>${suite.icon || '🧪'}</span>
              <span>${escapeTestHtml(suite.title)}</span>
            </div>
            <span class="badge badge-info" style="font-size:0.7rem;">${suite.count} ${suite.count === 1 ? 'test' : 'tests'}</span>
          </div>
          <div class="test-suite-desc">${escapeTestHtml(suite.desc)}</div>
        </div>
        ${suite.cmd ? `
          <div class="code-box" style="margin: 10px 0 12px 0; padding: 6px 55px 6px 10px; font-size: 0.75rem; white-space: nowrap; overflow-x: auto; background: rgba(0,0,0,0.3); border-radius: var(--radius-sm); border: 1px solid var(--border);">
            <code style="color: var(--accent-cyan, #38bdf8); font-family: monospace;">${escapeTestHtml(suite.cmd)}</code>
            <button type="button" class="copy-btn" onclick="copySnippet(this)" style="top: 4px; right: 4px; padding: 2px 6px; font-size: 0.7rem;">Copy</button>
          </div>
        ` : ''}
        <div class="test-suite-actions">
          <div style="display:flex; align-items:center; gap:6px;">
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

  const testLabel = scriptName ? `${suiteKey} (${scriptName})` : suiteKey;
  if (termEl) {
    termEl.innerHTML = `🚀 Initializing test run: [${testLabel}]...\nDispatching background runner via bridge...\n`;
  }
  if (badgeEl) {
    badgeEl.className = 'badge badge-warning';
    badgeEl.innerText = 'RUNNING';
  }
  if (statusEl) statusEl.innerText = `Olek: Käimas [${testLabel}]`;
  if (activeIndEl) {
    activeIndEl.style.display = 'inline-block';
    activeIndEl.innerText = `⏳ Test running: ${testLabel}`;
  }
  if (stopBtn) stopBtn.style.display = 'inline-flex';
  if (dlBtn) dlBtn.style.display = 'none';

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
    body: JSON.stringify({ suite: suiteKey, script: scriptName || '' })
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
      bodyEl.innerHTML = marked.parse(selectedReportRawContent);
      try {
        mermaid.run({ nodes: bodyEl.querySelectorAll('.mermaid') });
      } catch (e) {}
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
});
