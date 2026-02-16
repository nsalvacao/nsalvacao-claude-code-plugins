// ===== CONFIG MARKED & HIGHLIGHT & MERMAID =====
marked.setOptions({
  highlight: (code, lang) => (lang && hljs.getLanguage(lang)) ? hljs.highlight(code, { language: lang }).value : hljs.highlightAuto(code).value,
  breaks: true, gfm: true
});

mermaid.initialize({ startOnLoad: false, theme: 'neutral', securityLevel: 'loose' });

// ===== STATE =====
let rootHandle = null;
let audit = null;
let manifesto = null;
let tasksMdRaw = "";
let tasksHandle = null;
let tasksData = null;
let cliMetadata = {};
let memoryData = { files: [], dirs: {} };
let phaseChart = null;
let searchIndex = [];
let lastRefreshTime = 0;

// Timer State
let timerInterval = null;
let timerSeconds = 25 * 60;

// Modal Session State
let activeFilePath = null;
let originalContent = "";

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initEventListeners();
  initTimer();
  initChat();
});

function initNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  const panels = document.querySelectorAll('.view-panel');
  const currentViewTitle = document.getElementById('currentViewTitle');

  navItems.forEach(item => {
    item.addEventListener('click', () => {
      const view = item.dataset.view;
      navItems.forEach(i => i.classList.remove('active'));
      item.classList.add('active');
      panels.forEach(p => p.classList.remove('active'));
      document.getElementById(view + 'Panel').classList.add('active');
      currentViewTitle.textContent = view.charAt(0).toUpperCase() + view.slice(1);
    });
  });
}

function initEventListeners() {
  document.getElementById('rootPickerBtn').addEventListener('click', selectProjectRoot);
  document.getElementById('refreshBtn').addEventListener('click', refreshData);
  document.getElementById('modalSaveBtn').onclick = saveChanges;
  document.getElementById('modalCancelBtn').onclick = closeModal;
  document.getElementById('modalCloseBtn').onclick = () => closeModal();
  
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      toggleSpotlight();
    }
    if (e.key === 'Escape') {
      closeSpotlight();
      closeModal();
    }
  });

  const spotlightOverlay = document.getElementById('spotlightOverlay');
  spotlightOverlay.onclick = (e) => { if (e.target === spotlightOverlay) closeSpotlight(); };

  const spotlightSearch = document.getElementById('spotlightSearch');
  spotlightSearch.oninput = (e) => handleSpotlightSearch(e.target.value);

  const modalTabs = document.querySelectorAll('.modal-tab');
  modalTabs.forEach(tab => {
    tab.onclick = () => switchModalMode(tab.dataset.mod);
  });
}

// ===== CHATBOT LOGIC =====
function initChat() {
  const toggleBtn = document.getElementById('chatToggleBtn');
  const panel = document.getElementById('chatPanel');
  const closeBtn = document.getElementById('closeChatBtn');
  const sendBtn = document.getElementById('sendChatBtn');
  const input = document.getElementById('chatInput');

  if (!toggleBtn) return;

  toggleBtn.onclick = () => {
    const isVisible = panel.style.display === 'flex';
    panel.style.display = isVisible ? 'none' : 'flex';
    if (!isVisible) input.focus();
  };

  closeBtn.onclick = () => panel.style.display = 'none';
  sendBtn.onclick = handleSendChat;
  input.onkeydown = (e) => { if (e.key === 'Enter') handleSendChat(); };

  // Update assistant name from bridge config
  fetch(`http://${window.location.hostname}:8001/api/status`)
    .then(r => r.json())
    .then(data => {
      const ai = data.ai || {};
      const name = ai.mode === 'api' ? (ai.provider || 'AI') : (ai.cli || 'AI');
      const label = document.getElementById('chatAssistantName');
      if (label) label.textContent = name.charAt(0).toUpperCase() + name.slice(1) + ' Assistant';
    })
    .catch(() => {});
}

async function handleSendChat() {
  const input = document.getElementById('chatInput');
  const text = input.value.trim();
  if (!text) return;

  addChatMessage(text, 'user');
  input.value = '';

  const loadingDiv = addChatMessage('Generating response...', 'bot');

  try {
    const context = generateContextSnapshot();
    const prompt = `[PROJECT CONTEXT]\n${context}\n\n[USER QUESTION]\n${text}`;

    const response = await fetch(`http://${window.location.hostname}:8001/api/exec`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt })
    });

    const result = await response.json();
    loadingDiv.remove();

    if (result.error) {
      addChatMessage(`Error: ${result.error}`, 'bot');
    } else if (result.stdout) {
      addChatMessage(result.stdout, 'bot');
    } else if (result.stderr) {
      addChatMessage(`AI error: ${result.stderr}`, 'bot');
    } else {
      addChatMessage('No response received from the AI backend.', 'bot');
    }
  } catch (err) {
    if (loadingDiv) loadingDiv.remove();
    addChatMessage(`Bridge connection failed: ${err.message}. Make sure the cockpit bridge is running (cockpit.sh or cockpit.bat on port 8001).`, 'bot');
  }
}

function addChatMessage(text, side) {
  const history = document.getElementById('chatHistory');
  const div = document.createElement('div');
  div.className = `chat-msg chat-msg-${side} markdown-content`;
  div.innerHTML = side === 'bot' ? marked.parse(text) : text;
  history.appendChild(div);
  history.scrollTop = history.scrollHeight;
  return div;
}

function generateContextSnapshot() {
  let snap = `Branch: ${document.getElementById('breadcrumb').textContent.split(' / ')[1] || 'main'}\n\n`;
  if (tasksData) {
    snap += "### TASK STATUS (COMPLETE)\n";
    tasksData.forEach(phase => {
      snap += `#### ${phase.name}\n`;
      phase.tasks.forEach(t => {
        const status = t.checked ? "[DONE]" : "[PENDING]";
        snap += `- ${status} ${t.id ? t.id + ': ' : ''}${t.title}\n`;
      });
    });
  }
  if (audit) {
    snap += "\n### PLUGIN INVENTORY\n";
    snap += `- Ready: ${audit.plugin_clis.join(', ')}\n`;
    snap += `- Pending: ${audit.stale_in_config.join(', ')}\n`;
  }
  return snap;
}

// ===== CORE LOGIC =====
async function selectProjectRoot() {
  try {
    console.log("Selecting root...");
    rootHandle = await window.showDirectoryPicker();
    document.getElementById('rootName').textContent = rootHandle.name;
    await refreshData();
    startDriftWatcher();
  } catch (err) { 
    console.error("Folder selection failed:", err);
    alert("Failed to select folder: " + err.message);
  }
}

async function refreshData() {
  if (!rootHandle) return;
  try {
    console.log("Refreshing data...");
    lastRefreshTime = Date.now();
    cliMetadata = {};
    memoryData = { files: [], dirs: {} };
    searchIndex = [];

    // 0. Manifesto
    try {
      const manifestoFile = await rootHandle.getFileHandle('.cockpit.json');
      manifesto = JSON.parse(await (await manifestoFile.getFile()).text());
    } catch(e) { console.warn("No .cockpit.json found"); }

    const paths = manifesto?.paths || {
      tasks: "TASKS.md",
      memory: "memory",
      output: "output"
    };

    // 1. Inventory
    try {
      const outputDir = await getHandleByPath(rootHandle, paths.output);
      const auditFile = await outputDir.getFileHandle('config-audit.json');
      audit = JSON.parse(await (await auditFile.getFile()).text());
      for (const cli of audit.crawled_clis) {
        try {
          const cFile = await outputDir.getFileHandle(`${cli}.json`);
          const meta = JSON.parse(await (await cFile.getFile()).text());
          cliMetadata[cli] = meta;
          searchIndex.push({ type: 'cli', title: cli, sub: `CLI Plugin`, data: meta });
        } catch(e) {}
      }
    } catch(e) { console.warn("Inventory refresh failed:", e); }

    // 2. Tasks
    try {
      tasksHandle = await getHandleByPath(rootHandle, paths.tasks);
      tasksMdRaw = await (await tasksHandle.getFile()).text();
      tasksData = parseTasks(tasksMdRaw);
      if (tasksData) {
        tasksData.forEach(p => p.tasks.forEach(t => {
          searchIndex.push({ type: 'task', title: t.title, id: t.id, sub: `Task in ${p.name.split(':')[0]}`, data: t });
        }));
      }
    } catch(e) { console.warn("Tasks refresh failed:", e); }

    // 3. Memory
    try {
      const memDir = await getHandleByPath(rootHandle, paths.memory);
      for await (const entry of memDir.values()) {
        if (entry.kind === 'file' && entry.name.endsWith('.md')) {
          const content = await (await entry.getFile()).text();
          const relPath = `${paths.memory}/${entry.name}`;
          const fileObj = { name: entry.name, content, path: relPath, handle: entry };
          memoryData.files.push(fileObj);
          searchIndex.push({ type: 'memory', title: entry.name, sub: 'Memory Root', data: fileObj });
        } else if (entry.kind === 'directory') {
          const subItems = [];
          for await (const subEntry of entry.values()) {
            if (subEntry.kind === 'file' && subEntry.name.endsWith('.md')) {
              const content = await (await subEntry.getFile()).text();
              const relPath = `${paths.memory}/${entry.name}/${subEntry.name}`;
              const fileObj = { name: subEntry.name, content, path: relPath, handle: subEntry, dir: entry.name };
              subItems.push(fileObj);
              searchIndex.push({ type: 'memory', title: subEntry.name, sub: `Memory in ${entry.name}`, data: fileObj });
            }
          }
          memoryData.dirs[entry.name] = subItems;
        }
      }
    } catch(e) { console.warn("Memory refresh failed:", e); }

    await updateGitStatus();
    await runProjectPulse();
    updateUI();
    console.log("UI Updated.");
  } catch (err) { 
    console.error("General refresh failed:", err);
    alert("Failed to load project data. Check the browser console.");
  }
}

async function runProjectPulse() {
  const pulseList = document.getElementById('pulseList');
  if (!pulseList) return;
  pulseList.innerHTML = '';
  const rules = manifesto?.pulse_rules || { essential_files: ["README.md"], min_folders: [] };
  const checks = [];
  for (const file of rules.essential_files) { const exists = await fileExists(rootHandle, file); checks.push({ name: file, status: exists ? 'success' : 'error' }); }
  for (const folder of rules.min_folders) { const exists = await folderExists(rootHandle, folder); checks.push({ name: `${folder}/`, status: exists ? 'success' : 'error' }); }
  const paths = manifesto?.paths || { output: "output", tasks: "TASKS.md", memory: "memory" };
  const modules = [{ id: 'nav-inventory', path: paths.output, label: 'Inventory' }, { id: 'nav-tasks', path: paths.tasks, label: 'Tasks' }, { id: 'nav-memory', path: paths.memory, label: 'Memory' }];
  for (const mod of modules) {
    const exists = mod.path.endsWith('.md') ? await fileExists(rootHandle, mod.path) : await folderExists(rootHandle, mod.path);
    const el = document.getElementById(mod.id);
    if (el) el.style.display = exists ? 'flex' : 'none';
    if (!exists) checks.push({ name: mod.label, status: 'warning', msg: 'Not found' });
  }
  checks.forEach(c => {
    const item = document.createElement('div'); item.className = 'pulse-item';
    item.innerHTML = `<span class="pulse-dot dot-${c.status}"></span> ${c.name} ${c.msg ? `<span style="font-size:10px; opacity:0.7">(${c.msg})</span>` : ''}`;
    pulseList.appendChild(item);
  });
}

function updateUI() {
  updateKPIs(); renderInventory(); renderPhaseChart(); renderTasks(); renderMemory(); renderActivity();
}

function updateKPIs() {
  if (!tasksData) return;
  let total = 0, completed = 0, blockers = 0;
  tasksData.forEach(p => p.tasks.forEach(t => { total++; if (t.checked) completed++; if (t.isCritical && !t.checked) blockers++; }));
  document.getElementById('kpi-progress').textContent = Math.round((completed/total)*100) + '%';
  document.getElementById('kpi-blockers').textContent = blockers;
  if (audit) document.getElementById('kpi-clis').textContent = `${audit.plugin_clis.length} / ${audit.configured_clis.length}`;
  let confSum = 0, confCount = 0;
  Object.values(cliMetadata).forEach(m => { if (m.metadata?.confidence_score) { confSum += parseFloat(m.metadata.confidence_score); confCount++; } });
  document.getElementById('kpi-confidence').textContent = (confCount ? (confSum/confCount).toFixed(2) : "0.00");
}

function renderTasks() {
  const board = document.getElementById('board'); 
  if (!board) return;
  board.innerHTML = '';
  const paths = manifesto?.paths || { tasks: "TASKS.md" };
  if (!tasksData) return;
  tasksData.forEach(phase => {
    const col = document.createElement('div'); col.className = 'column';
    col.innerHTML = `<div class="column-header"><span>${phase.name.split(':')[0]}</span><span style="font-size: 11px;">${phase.tasks.filter(t => t.checked).length}/${phase.tasks.length}</span></div><div class="cards"></div>`;
    const cardsCont = col.querySelector('.cards');
    const mapBtn = document.createElement('button');
    mapBtn.style.margin = '0 16px 12px'; mapBtn.style.fontSize = '10px';
    mapBtn.textContent = 'View Phase Map';
    mapBtn.onclick = () => renderPhaseDependencyMap(phase);
    col.insertBefore(mapBtn, cardsCont);
    phase.tasks.forEach(task => {
      const card = document.createElement('div'); card.className = 'task-card';
      let tagsHtml = task.tags.map(t => `<span class="task-tag tag-${t.toLowerCase()}">${t}</span>`).join('');
      if (task.isCritical) tagsHtml += `<span class="task-tag tag-critical">CRITICAL</span>`;
      card.innerHTML = `${task.id ? `<div class="task-id">${task.id}</div>` : ''}<div class="task-title-row"><span class="checkbox ${task.checked ? 'checked' : ''}"></span><div class="task-title">${marked.parseInline(task.title)}</div></div><div class="task-tags">${tagsHtml}</div>`;
      card.onclick = () => openModal((task.id ? `**${task.id}** ` : "") + task.title, tasksMdRaw, paths.tasks);
      cardsCont.appendChild(card);
    });
    board.appendChild(col);
  });
}

function renderPhaseDependencyMap(phase) {
  let graph = "graph TD\n";
  phase.tasks.forEach(t => {
    const id = t.id || t.title.replace(/\s+/g, '_').substring(0, 10).replace(/[^a-zA-Z0-9]/g, '');
    const label = (t.id ? `${t.id}: ` : "") + t.title.substring(0, 20).replace(/"/g, "'") + "...";
    graph += `  ${id}["${label}"]\n`;
    if (t.checked) graph += `  style ${id} fill:#e8f5e9,stroke:#2e7d32\n`;
    const afterMatch = t.title.match(/\[After:\s*(T\d+)\]/);
    if (afterMatch) graph += `  ${afterMatch[1]} --> ${id}\n`;
  });
  openModal(`Dependency Map - ${phase.name}`, `\`\`\`mermaid\n${graph}\n\`\`\``, null);
  setTimeout(() => {
    const mermaidBlocks = document.querySelectorAll('.markdown-content pre code.language-mermaid');
    if (mermaidBlocks.length > 0) mermaid.run({ nodes: mermaidBlocks });
  }, 200);
}

function renderMemory() {
  const tabs = document.getElementById('memoryTabs'); const content = document.getElementById('memoryContent'); 
  if (!tabs || !content) return;
  tabs.innerHTML = ''; content.innerHTML = '';
  const allTabs = [...memoryData.files.map(f => ({ name: f.name, type: 'file', data: f })), ...Object.keys(memoryData.dirs).map(d => ({ name: d, type: 'dir', data: memoryData.dirs[d] }))];
  if (allTabs.length === 0) return;
  allTabs.forEach((tab, idx) => {
    const btn = document.createElement('button'); btn.className = `memory-tab ${idx === 0 ? 'active' : ''}`; btn.textContent = tab.name.replace('.md', '');
    btn.onclick = () => { document.querySelectorAll('.memory-tab').forEach(b => b.classList.remove('active')); btn.classList.add('active'); displayMemoryItems(tab); };
    tabs.appendChild(btn);
  });
  displayMemoryItems(allTabs[0]);
}

function displayMemoryItems(tab) {
  const content = document.getElementById('memoryContent'); 
  if (!content) return;
  content.innerHTML = '';
  const items = tab.type === 'file' ? [tab.data] : tab.data;
  items.forEach(item => {
    const card = document.createElement('div'); card.className = 'memory-card';
    card.innerHTML = `<div class="memory-card-title">${item.name.replace('.md', '')}</div><div class="memory-card-preview">${item.content.replace(/[#*`]/g, '').substring(0, 120)}...</div>`;
    card.onclick = () => openModal(item.name, item.content, item.path);
    content.appendChild(card);
  });
}

function renderActivity() {
  const cont = document.getElementById('recentActivity'); 
  if (!cont) return;
  cont.innerHTML = '';
  const sorted = Object.values(cliMetadata).sort((a,b) => new Date(b.metadata?.scanned_at) - new Date(a.metadata?.scanned_at)).slice(0, 5);
  sorted.forEach(m => {
    const item = document.createElement('div');
    item.style.cssText = 'padding: 10px; background: var(--bg-secondary); border-radius: 8px; display: flex; justify-content: space-between; align-items: center;';
    item.innerHTML = `<strong>${m.cli_name}</strong> <span style="font-size:11px; padding:2px 6px; background:white; border-radius:4px; border:1px solid var(--border)">v${m.cli_version || '?'}</span>`;
    cont.appendChild(item);
  });
}

function renderInventory() {
  const grid = document.getElementById('inventoryGrid'); 
  if (!grid) return;
  grid.innerHTML = ''; 
  if (!audit) return;
  audit.configured_clis.forEach(cli => {
    const hasOutput = audit.crawled_clis.includes(cli), hasPlugin = audit.plugin_clis.includes(cli), meta = cliMetadata[cli]?.metadata;
    const card = document.createElement('div'); card.className = 'cli-card';
    let statusClass = 'status-missing', statusText = 'Missing';
    if (hasPlugin) { statusClass = 'status-ready'; statusText = 'Ready'; } else if (hasOutput) { statusClass = 'status-pending'; statusText = 'Crawled'; }
    card.innerHTML = `<div class="cli-header"><span class="cli-name">${cli}</span><span class="status-badge ${statusClass}">${statusText}</span></div>
      <div class="cli-meta"><div class="meta-item">Cmds: ${meta?.total_commands || '-'}</div><div class="meta-item">Flags: ${meta?.total_flags || '-'}</div><div class="meta-item" style="grid-column: span 2">Conf: ${meta?.confidence_score || '0.00'}</div></div>`;
    grid.appendChild(card);
  });
}

function renderPhaseChart() {
  const canvas = document.getElementById('phaseChart');
  if (!canvas) return;
  const ctx = canvas.getContext('2d'); 
  if (phaseChart) phaseChart.destroy();
  if (!tasksData) return;
  phaseChart = new Chart(ctx, {
    type: 'bar', data: { labels: tasksData.map(p => p.name.split(':')[0]), datasets: [{ data: tasksData.map(p => (p.tasks.filter(t => t.checked).length/p.tasks.length)*100), backgroundColor: '#D97757', borderRadius: 6 }] },
    options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true, max: 100, ticks: { callback: v => v + '%' } } }, plugins: { legend: { display: false } } }
  });
}

function parseTasks(content) {
  const phases = []; const lines = content.split('\n'); let currentPhase = null, currentTask = null;
  lines.forEach(line => {
    const pMatch = line.match(/^## (Phase \d+:.+)$/);
    if (pMatch) { currentPhase = { name: pMatch[1], tasks: [] }; phases.push(currentPhase); currentTask = null; return; }
    const tMatch = line.match(/^- \[[ xX]\]\s+(.*)$/);
    if (currentPhase && tMatch) {
      const rawText = tMatch[1], idMatch = rawText.match(/T\d+/), taskId = idMatch ? idMatch[0] : null;
      let cleanTitle = rawText; if (taskId) cleanTitle = rawText.replace(new RegExp('\\*\\*?' + taskId + '\\*\\*?\\s*'), '').replace(taskId + ' ', '');
      const tags = []; const tagMatches = cleanTitle.matchAll(/\[(.*?)\]/g); for (const tm of tagMatches) tags.push(tm[1]);
      currentTask = { id: taskId, title: cleanTitle, checked: line.includes('[x]'), isCritical: rawText.toLowerCase().includes('critical'), tags, notes: "", subtasks: [] };
      currentPhase.tasks.push(currentTask); return;
    }
    const stMatch = line.match(/^\s+- \[[ xX]\]\s+(.*)$/);
    if (currentTask && stMatch) { currentTask.subtasks.push({ title: stMatch[1], checked: line.includes('[x]') }); return; }
    if (currentTask && line.trim() && !line.startsWith('#') && !line.startsWith('-')) currentTask.notes += line + "\n";
  });
  return phases;
}

// ===== MODAL & EDITOR LOGIC =====
const modal = document.getElementById('modalOverlay');
const previewArea = document.getElementById('modalPreview');
const editorArea = document.getElementById('modalEditor');
const textarea = document.getElementById('modalTextarea');
const modalTabs = document.querySelectorAll('.modal-tab');
const saveStatus = document.getElementById('saveStatus');

function openModal(title, content, path) {
  console.log("Opening modal for:", path);
  activeFilePath = path; originalContent = content;
  document.getElementById('modalTitle').innerHTML = marked.parseInline(title);
  textarea.value = content; updatePreview(); switchModalMode('preview');
  modal.style.display = 'flex'; saveStatus.style.display = 'none';
}

function updatePreview() {
  previewArea.innerHTML = marked.parse(textarea.value);
  previewArea.querySelectorAll('pre code').forEach(el => hljs.highlightElement(el));
  setTimeout(() => {
    const mermaidBlocks = previewArea.querySelectorAll('pre code.language-mermaid');
    if (mermaidBlocks.length > 0) mermaid.run({ nodes: mermaidBlocks });
  }, 100);
}

function switchModalMode(mode) {
  modalTabs.forEach(t => t.classList.toggle('active', t.dataset.mod === mode));
  if (mode === 'preview') { updatePreview(); previewArea.style.display = 'block'; editorArea.style.display = 'none'; }
  else { previewArea.style.display = 'none'; editorArea.style.display = 'block'; textarea.focus(); }
}

async function saveChanges() {
  if (!activeFilePath) return;
  try {
    const response = await fetch(`http://${window.location.hostname}:8001/api/fs/write`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ path: activeFilePath, content: textarea.value })
    });
    const result = await response.json();
    if (result.success) {
      saveStatus.style.display = 'block'; setTimeout(() => saveStatus.style.display = 'none', 3000);
      originalContent = textarea.value; await refreshData();
    } else alert("Save failed: " + (result.error || "Unknown error"));
  } catch (err) { alert("Save failed (Bridge offline?): " + err.message); }
}

function closeModal() {
  if (textarea.value !== originalContent) { if (!confirm("Discard unsaved changes?")) return; }
  modal.style.display = 'none';
}

function toggleSpotlight() {
  const overlay = document.getElementById('spotlightOverlay');
  overlay.style.display = 'flex';
  const input = document.getElementById('spotlightSearch');
  input.value = ''; input.focus(); handleSpotlightSearch('');
}

function closeSpotlight() { document.getElementById('spotlightOverlay').style.display = 'none'; }

function handleSpotlightSearch(query) {
  const resultsCont = document.getElementById('spotlightResults'); resultsCont.innerHTML = '';
  const q = query.toLowerCase();
  const filtered = searchIndex.filter(item => item.title.toLowerCase().includes(q) || (item.id && item.id.toLowerCase().includes(q)) || item.sub.toLowerCase().includes(q)).slice(0, 8);
  filtered.forEach(item => {
    const div = document.createElement('div'); div.className = 'spotlight-result';
    let icon = '📄'; if (item.type === 'task') icon = '📋'; if (item.type === 'cli') icon = '📦';
    div.innerHTML = `<div class="result-icon">${icon}</div><div class="result-text"><div class="result-title">${item.id ? `<span style="color:var(--accent)">${item.id}</span> ` : ''}${item.title}</div><div class="result-sub">${item.sub}</div></div>`;
    div.onclick = () => {
      closeSpotlight();
      const paths = manifesto?.paths || { tasks: "TASKS.md" };
      if (item.type === 'task') openModal((item.id ? `**${item.id}** ` : "") + item.title, tasksMdRaw, paths.tasks);
      else if (item.type === 'memory') openModal(item.title, item.data.content, item.data.path);
      else if (item.type === 'cli') openModal(item.title, JSON.stringify(item.data, null, 2), null);
    };
    resultsCont.appendChild(div);
  });
}

function startDriftWatcher() {
  setInterval(async () => {
    if (!rootHandle || !tasksHandle) return;
    try {
      const file = await tasksHandle.getFile();
      if (file.lastModified > lastRefreshTime && lastRefreshTime > 0) {
        if (confirm("Project files were updated externally. Refresh Cockpit?")) refreshData();
        else lastRefreshTime = file.lastModified;
      }
    } catch(e) {}
  }, 10000);
}

function initTimer() {
  const toggleBtn = document.getElementById('timerToggleBtn');
  if (!toggleBtn) return;
  updateTimerDisplay();
  toggleBtn.onclick = () => {
    if (timerInterval) { clearInterval(timerInterval); timerInterval = null; toggleBtn.textContent = 'Start'; }
    else {
      timerInterval = setInterval(() => {
        timerSeconds--;
        if (timerSeconds <= 0) { clearInterval(timerInterval); timerInterval = null; alert("Focus Session Complete!"); timerSeconds = 25 * 60; }
        updateTimerDisplay();
      }, 1000);
      toggleBtn.textContent = 'Pause';
    }
  };
}

function updateTimerDisplay() {
  const m = Math.floor(timerSeconds / 60); const s = timerSeconds % 60;
  const display = document.getElementById('timerDisplay');
  if (display) display.textContent = `${m}:${s.toString().padStart(2, '0')}`;
}

async function fileExists(root, pathStr) { try { const h = await getHandleByPath(root, pathStr); return h.kind === 'file'; } catch (e) { return false; } }
async function folderExists(root, pathStr) { try { const h = await getHandleByPath(root, pathStr); return h.kind === 'directory'; } catch (e) { return false; } }
async function getHandleByPath(root, pathStr) {
  const parts = pathStr.split('/'); let current = root;
  for (let i = 0; i < parts.length - 1; i++) { if (!parts[i]) continue; current = await current.getDirectoryHandle(parts[i]); }
  const last = parts[parts.length - 1];
  try { return await current.getFileHandle(last); } catch(e) { return await current.getDirectoryHandle(last); }
}

async function updateGitStatus() {
  try {
    const gitDir = await rootHandle.getDirectoryHandle('.git');
    const headText = await (await (await gitDir.getFileHandle('HEAD')).getFile()).text();
    const branch = headText.startsWith('ref: refs/heads/') ? headText.replace('ref: refs/heads/', '').trim() : headText.substring(0, 7);
    document.getElementById('breadcrumb').textContent = `${rootHandle.name} / ${branch}`;
  } catch(e) { document.getElementById('breadcrumb').textContent = `${rootHandle.name}`; }
}