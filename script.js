const app = document.getElementById('app');
const menuTitle = document.getElementById('menu-title');
const tabsContainer = document.getElementById('tabs-container');
const itemsList = document.getElementById('items-list');
const footerPage = document.getElementById('footer-page');

let currentData = null;

const tabIcons = {
    "Player": "fa-user",
    "Movement": "fa-person-running",
    "Vehicle": "fa-car",
    "Weapons": "fa-gun",
    "Visuals": "fa-eye",
    "Default": "fa-bars"
};

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === "update") {
        if (data.show) {
            app.classList.add('show');
        } else {
            app.classList.remove('show');
            return;
        }

        currentData = data;
        renderMenu();
    }
});

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
        
        // Add subtle icon for items based on type
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

// Development testing mock
/*
setTimeout(() => {
    window.postMessage({
        action: "update",
        show: true,
        title: "21",
        tabs: ["Player", "Movement", "Weapon", "Visual"],
        activeTab: 1,
        items: [
            {label: "Super Jump", type: "toggle", state: true},
            {label: "Super Speed", type: "toggle", state: false},
            {label: "No Clip", type: "toggle", state: false},
            {label: "No Clip Speed", type: "slider", value: 2.5, max: 5},
            {label: "Teleport to Waypoint", type: "button"}
        ],
        selectedIndex: 3
    }, "*");
}, 500);
*/
