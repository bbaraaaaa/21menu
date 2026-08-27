const app = document.getElementById('app');
const tabsContainer = document.getElementById('tabs-container');
const itemsList = document.getElementById('items-list');
const footerPage = document.getElementById('footer-page');
const toastContainer = document.getElementById('toast-container');
const keybindOverlay = document.getElementById('keybind-overlay');

let audioCtx = null;
let beepBuffer = null;
let clickBuffer = null;

// Initialize Web Audio API
function initAudio() {
    if (!audioCtx) {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        
        // Generate a very short click sound (Navigation)
        const clickDuration = 0.01;
        clickBuffer = audioCtx.createBuffer(1, audioCtx.sampleRate * clickDuration, audioCtx.sampleRate);
        const clickData = clickBuffer.getChannelData(0);
        for (let i = 0; i < clickBuffer.length; i++) {
            clickData[i] = (Math.random() * 2 - 1) * Math.exp(-i / (audioCtx.sampleRate * 0.005));
        }

        // Generate a slightly deeper beep sound (Select)
        const beepDuration = 0.05;
        beepBuffer = audioCtx.createBuffer(1, audioCtx.sampleRate * beepDuration, audioCtx.sampleRate);
        const beepData = beepBuffer.getChannelData(0);
        for (let i = 0; i < beepBuffer.length; i++) {
            beepData[i] = Math.sin(i * 0.05) * Math.exp(-i / (audioCtx.sampleRate * 0.02));
        }
    }
}

function playSound(type) {
    if (!audioCtx) initAudio();
    if (!audioCtx || audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    
    const source = audioCtx.createBufferSource();
    source.buffer = type === 'click' ? clickBuffer : beepBuffer;
    
    const gainNode = audioCtx.createGain();
    gainNode.gain.value = 0.1; // Low volume
    
    source.connect(gainNode);
    gainNode.connect(audioCtx.destination);
    source.start();
}

function showToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `<span class="toast-message">${message}</span>`;
    
    toastContainer.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('hiding');
        setTimeout(() => {
            if (toast.parentElement) toast.remove();
        }, 400);
    }, 3000);
}

// Receive messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'notify') {
        showToast(data.message);
        return;
    }
    if (data.action === 'showKeybind') {
        if (data.show) {
            keybindOverlay.style.display = 'flex';
            document.querySelector('.keybind-btn').innerText = data.text || 'Waiting...';
            document.querySelector('.keybind-prompt').innerText = data.promptText || 'Enter Menu Open Key ...';
        } else {
            keybindOverlay.style.display = 'none';
        }
        return;
    }
    
    if (data.action === 'openSearch') {
        const searchOverlay = document.getElementById('search-overlay');
        const searchInput = document.getElementById('search-input');
        searchOverlay.style.display = 'flex';
        searchInput.value = '';
        setTimeout(() => { searchInput.focus(); }, 100);
        return;
    }
    
    if (data.action === 'update') {
        if (data.menuAlign === 'Left') {
            app.style.left = '1.5vw';
        } else {
            app.style.left = '75vw';
        }
        
        if (data.show) {
            app.classList.add('show');
            initAudio(); // Initialize audio context on first open
        } else {
            app.classList.remove('show');
            return;
        }
        // Render Category Header
        const categoryHeader = document.getElementById('category-header');
        if (categoryHeader && data.categoryName) {
            // Capitalize first letter
            let catName = data.categoryName.charAt(0).toUpperCase() + data.categoryName.slice(1);
            categoryHeader.innerText = catName;
        }

        // Render Tabs
        tabsContainer.innerHTML = '';
        data.tabs.forEach((tabName, index) => {
            const el = document.createElement('div');
            el.className = 'tab';
            if (index === data.activeTab) el.classList.add('active');
            el.innerHTML = `<span>${tabName}</span>`;
            tabsContainer.appendChild(el);
        });
        
        // DOM Reuse Logic for Smooth Scrolling
        let selectorBox = document.getElementById('selector-box');
        let existingItems = Array.from(itemsList.children).filter(c => c.id !== 'selector-box');
        
        let needsFullRender = existingItems.length !== data.items.length;
        if (!needsFullRender) {
            for (let i = 0; i < data.items.length; i++) {
                if ((data.items[i].label || 'search') !== existingItems[i].dataset.label) {
                    needsFullRender = true;
                    break;
                }
            }
        }
        
        // Render Footer Page
        const selectedItemData = data.items[data.selectedIndex];
        let bindHint = (selectedItemData && selectedItemData.type !== 'separator' && selectedItemData.type !== 'search') ? ' | [F7] Bind' : '';
        footerPage.innerText = `${data.selectedIndex + 1}/${data.items.length}`;
        const footerTextEl = document.querySelector('.footer-text');
        if (footerTextEl) footerTextEl.innerText = '21 | discord.gg/2121' + bindHint;
        
        let previousSelection = document.querySelector('.selected');
        let currentSelectedDOM = null;
        
        if (needsFullRender) {
            existingItems.forEach(child => child.remove());
            
            for (let i = 0; i < data.items.length; i++) {
                const item = data.items[i];
                const el = document.createElement('div');
                el.className = 'item';
                el.dataset.label = item.label || 'search';
                
                if (i === data.selectedIndex) {
                    el.classList.add('selected');
                    currentSelectedDOM = el;
                    if (!previousSelection || previousSelection.dataset.index != i) {
                        playSound('click');
                    }
                }
                el.dataset.index = i;
                
                if (item.type === 'separator') {
                    el.className = 'item separator-item';
                    el.innerHTML = `<span class="separator-text">${item.label}</span>`;
                } else {
                let rightContent = '';
                if (item.type === 'search') {
                el.classList.add('search-box');
                el.innerHTML = `
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <span class="search-text">${item.label ? item.label : 'Search...'}</span>
                `;
            } else if (item.type === 'toggle') {
                    if (item.state) el.classList.add('active-toggle');
                    rightContent = `
                        <div class="toggle">
                            <div class="toggle-knob"></div>
                        </div>
                    `;
                } else if (item.type === 'slider') {
                    const percent = (item.value / item.max) * 100;
                    rightContent = `
                        <div class="slider-container">
                            <div class="slider-bar">
                                <div class="slider-fill" style="width: ${percent}%;"></div>
                            </div>
                        </div>
                    `;
                    // Overwrite label to include value
                    item.label = `${item.label}: ${item.value}`;
                } else if (item.type === 'list') {
                    rightContent = `<span class="list-value" style="color: #bbb; font-size: 0.9em; letter-spacing: 0.5px;">&lt; ${item.listName} &gt;</span>`;
                } else {
                    rightContent = `<i class="fa-solid fa-chevron-right item-arrow"></i>`;
                }
                
                if (item.type !== 'search') {
                    let bindHTML = item.bindKey ? `<span class="bind-badge">[${item.bindKey}]</span>` : '';
                    let iconHTML = '';
                    // Map common ARYA icons
                    const iconMap = {
                        "Self": "fa-solid fa-user",
                        "Server": "fa-solid fa-globe",
                        "Combat": "fa-solid fa-crosshairs",
                        "Weapon": "fa-solid fa-gun",
                        "Vehicle": "fa-solid fa-car",
                        "Destroyer": "fa-solid fa-skull",
                        "Misc": "fa-solid fa-list-ul",
                        "Settings": "fa-solid fa-gear"
                    };
                    if (iconMap[item.label]) {
                        iconHTML = `<i class="${iconMap[item.label]} item-icon"></i>`;
                    }
                    
                    el.innerHTML = `
                        <div class="item-label">
                            ${iconHTML}
                            <span class="item-text">${item.label}</span>
                            ${bindHTML}
                        </div>
                        <div class="item-right">${rightContent}</div>
                    `;
                }
            }
            itemsList.appendChild(el);
        }
    } else {
        // Partial Update (DOM Reuse)
        for (let i = 0; i < data.items.length; i++) {
                const item = data.items[i];
                const el = existingItems[i];
                
                if (i === data.selectedIndex) {
                    el.classList.add('selected');
                    currentSelectedDOM = el;
                    if (!previousSelection || previousSelection.dataset.index != i) {
                        playSound('click');
                    }
                } else {
                    el.classList.remove('selected');
                }
                
/* Update ARYA toggles and sliders in DOM diffing */
                if (item.type === 'toggle') {
                    if (item.state) el.classList.add('active-toggle');
                    else el.classList.remove('active-toggle');
                } else if (item.type === 'slider') {
                    const percent = (item.value / item.max) * 100;
                    const fill = el.querySelector('.slider-fill');
                    if (fill) fill.style.width = percent + '%';
                    const text = el.querySelector('.item-text');
                    if (text) text.innerText = `${item.label}`;
                } else if (item.type === 'list') {
                    const listVal = el.querySelector('.list-value');
                    if (listVal) listVal.innerText = `< ${item.listName} >`;
                }
            }
        }

        // Update selector box position and scroll container smoothly
        if (currentSelectedDOM && selectorBox) {
            selectorBox.style.display = 'block';
            selectorBox.style.top = currentSelectedDOM.offsetTop + 'px';
            selectorBox.style.height = currentSelectedDOM.offsetHeight + 'px';
            
            // Scroll logic (center the selected item)
            let contentContainer = document.getElementById('content-container');
            if (contentContainer) {
                let offset = currentSelectedDOM.offsetTop - (contentContainer.clientHeight / 2) + (currentSelectedDOM.clientHeight / 2);
                contentContainer.scrollTo({ top: Math.max(0, offset), behavior: 'smooth' });
            }
        }
    }
});

// NUI Search Input Listener
const searchInput = document.getElementById('search-input');
const searchOverlay = document.getElementById('search-overlay');

if (searchInput) {
    searchInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            const query = searchInput.value;
            searchOverlay.style.display = 'none';
            // Send to Lua
            fetch(`https://${window.GetParentResourceName ? GetParentResourceName() : '21menu'}/closeSearch`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ query: query })
            }).catch(() => {});
        } else if (e.key === 'Escape') {
            searchOverlay.style.display = 'none';
            fetch(`https://${window.GetParentResourceName ? GetParentResourceName() : '21menu'}/closeSearch`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ query: null })
            }).catch(() => {});
        }
    });
}
