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
        
        // Render Tabs
        tabsContainer.innerHTML = '';
        data.tabs.forEach((tabName, index) => {
            const el = document.createElement('div');
            el.className = 'tab';
            if (index === data.activeTab) el.classList.add('active');
            el.innerHTML = `<span>${tabName}</span>`;
            tabsContainer.appendChild(el);
        });
        
        // Render Items
        itemsList.innerHTML = '';
        
        // Pagination logic
        const maxItems = data.maxItemsPerPage || 10;
        let startIndex = 0;
        let endIndex = data.items.length - 1;
        
        if (data.items.length > maxItems) {
            startIndex = Math.max(0, data.selectedIndex - Math.floor(maxItems / 2));
            if (startIndex + maxItems > data.items.length) {
                startIndex = data.items.length - maxItems;
            }
            endIndex = startIndex + maxItems - 1;
        }
        
        // Render Footer Page
        footerPage.innerText = `${data.selectedIndex + 1}/${data.items.length}`;
        
        let previousSelection = itemsList.querySelector('.selected');
        
        for (let i = startIndex; i <= endIndex; i++) {
            const item = data.items[i];
            const el = document.createElement('div');
            el.className = 'item';
            if (i === data.selectedIndex) {
                el.classList.add('selected');
                if (!previousSelection || previousSelection.dataset.index != i) {
                    playSound('click'); // Play nav sound if selection changed
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
                    el.innerHTML = `
                        <div class="item-label">
                            <span class="item-text">${item.label}</span>
                        </div>
                        <div class="item-right">${rightContent}</div>
                    `;
                }
            }
            
            itemsList.appendChild(el);
        }
    }
});
