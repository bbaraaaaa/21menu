const app = document.getElementById('app');
const menuTitle = document.getElementById('menu-title');
const tabsContainer = document.getElementById('tabs-container');
const itemsList = document.getElementById('items-list');
const footerPage = document.getElementById('footer-page');
const toastContainer = document.getElementById('toast-container');

let currentData = null;

const tabIcons = {
    "Player": "fa-user",
    "Movement": "fa-person-running",
    "Vehicle": "fa-car",
    "Weapons": "fa-gun",
    "Visuals": "fa-eye",
    "Default": "fa-bars"
};

// --- AUDIO SYSTEM ---
const AudioContext = window.AudioContext || window.webkitAudioContext;
let audioCtx;

function playSound(type) {
    if (!audioCtx) {
        try { audioCtx = new AudioContext(); } catch(e) { return; }
    }
    if (audioCtx.state === 'suspended') audioCtx.resume();
    
    const osc = audioCtx.createOscillator();
    const gainNode = audioCtx.createGain();
    
    osc.connect(gainNode);
    gainNode.connect(audioCtx.destination);
    
    if (type === 'tick') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(600, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(800, audioCtx.currentTime + 0.05);
        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.05);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.05);
    } else if (type === 'select') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(400, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(600, audioCtx.currentTime + 0.1);
        gainNode.gain.setValueAtTime(0.15, audioCtx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.1);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.1);
    }
}
// --------------------

window.addEventListener('message', (event) => {
    const data = event.data;

    // Remove the fivem string formatting like "~g~", "~r~"
    const cleanString = (str) => {
        if (!str) return "";
        return str.replace(/~[a-zA-Z]~/g, '');
    };

    if (data.action === "update") {
        if (data.show) {
            app.classList.add('show');
        } else {
            app.classList.remove('show');
            return;
        }

        // Check if index changed for sound
        if (currentData) {
            if (currentData.selectedIndex !== data.selectedIndex || currentData.activeTab !== data.activeTab) {
                playSound('tick');
            } else if (JSON.stringify(currentData.items) !== JSON.stringify(data.items)) {
                // If items changed but index didn't (means a toggle/button was pressed)
                playSound('select');
            }
        }

        currentData = data;
        renderMenu();
    }
    
    if (data.action === "notify") {
        showToast(cleanString(data.message));
        playSound('select');
    }
});

function showToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
        <i class="fa-solid fa-bell toast-icon"></i>
        <div class="toast-message">${message}</div>
    `;
    
    toastContainer.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('hiding');
        setTimeout(() => {
            if(toastContainer.contains(toast)) {
                toastContainer.removeChild(toast);
            }
        }, 400); // Wait for slide out animation
    }, 3000); // Show for 3 seconds
}

function renderMenu() {
    if (!currentData) return;

    // Render Tabs
    tabsContainer.innerHTML = '';
    if (currentData.tabs && currentData.tabs.length > 0) {
        currentData.tabs.forEach((tab, index) => {
            const tabEl = document.createElement('div');
            tabEl.className = 'tab';
            if (index === currentData.activeTab) {
                tabEl.classList.add('active');
            }
            const iconClass = tabIcons[tab] || tabIcons["Default"];
            tabEl.innerHTML = `<i class="fa-solid ${iconClass}"></i><span>${tab}</span>`;
            tabsContainer.appendChild(tabEl);
        });
    }

    // Pagination Logic
    const maxItems = currentData.maxItemsPerPage || 10;
    const totalItems = currentData.items.length;
    let startIdx = 0;
    let endIdx = totalItems;
    
    if (totalItems > maxItems) {
        startIdx = Math.max(0, currentData.selectedIndex - maxItems + 1);
        endIdx = startIdx + maxItems;
        if (endIdx > totalItems) {
            endIdx = totalItems;
            startIdx = endIdx - maxItems;
        }
        
        if (currentData.selectedIndex < startIdx) {
            startIdx = currentData.selectedIndex;
            endIdx = startIdx + maxItems;
        }
    }

    // Render Items
    itemsList.innerHTML = '';
    for (let i = startIdx; i < endIdx; i++) {
        const item = currentData.items[i];
        if (!item) continue;

        const itemEl = document.createElement('div');
        itemEl.className = 'item';
        if (i === currentData.selectedIndex) {
            itemEl.classList.add('selected');
        }

        const labelEl = document.createElement('div');
        labelEl.className = 'item-label';
        
        let itemIcon = 'fa-circle';
        if (item.type === 'toggle') itemIcon = 'fa-power-off';
        else if (item.type === 'slider') itemIcon = 'fa-sliders';
        else if (item.type === 'button') itemIcon = 'fa-hand-pointer';
        
        labelEl.innerHTML = `<i class="fa-solid ${itemIcon}" style="font-size: 10px; opacity: 0.5;"></i> ${item.label}`;
        itemEl.appendChild(labelEl);

        const rightEl = document.createElement('div');
        rightEl.className = 'item-right';

        if (item.type === 'toggle') {
            if (item.state) itemEl.classList.add('active-toggle');
            rightEl.innerHTML = `
                <div class="toggle">
                    <div class="toggle-knob"></div>
                </div>
            `;
        } else if (item.type === 'slider') {
            const fillPct = (item.value / item.max) * 100;
            rightEl.innerHTML = `
                <div class="slider-container">
                    <div class="slider-bar"><div class="slider-fill" style="width: ${fillPct}%"></div></div>
                    <div class="slider-value">${item.value}</div>
                </div>
            `;
        } else if (item.type === 'sub') {
            rightEl.innerHTML = `<i class="fa-solid fa-chevron-right item-arrow"></i>`;
        } else if (item.value) {
            rightEl.innerHTML = `<span style="color: var(--text-muted); font-size: 13px;">${item.value}</span>`;
        }

        itemEl.appendChild(rightEl);
        itemsList.appendChild(itemEl);
    }

    // Footer Page
    footerPage.innerText = `${currentData.selectedIndex + 1} / ${totalItems}`;
}
