window.addEventListener('message', function(event) {
    let data = event.data;
    if (typeof data === "string") {
        try {
            data = JSON.parse(data);
        } catch (e) {
            return;
        }
    }

    let keybindOverlay = document.getElementById('keybind-overlay');
    let menuContainer = document.getElementById('menu-container');

    if (data.action === "showKeybind") {
        keybindOverlay.className = 'fade-visible';
        menuContainer.className = 'fade-hidden';
        
        if (data.keyName) {
            document.getElementById('keybind-inst').innerText = "Press ENTER to confirm: " + data.keyName;
            document.getElementById('keybind-btn').innerText = "CONFIRM";
            document.getElementById('keybind-btn').style.backgroundColor = "#fff";
            document.getElementById('keybind-btn').style.color = "#000";
        } else {
            document.getElementById('keybind-inst').innerText = "Enter Menu Open Key ...";
            document.getElementById('keybind-btn').innerText = "Waiting for input...";
            document.getElementById('keybind-btn').style.backgroundColor = "#111";
            document.getElementById('keybind-btn').style.color = "#fff";
        }
    }
    else if (data.action === "showMenu") {
        keybindOverlay.className = 'fade-hidden';
        menuContainer.className = 'fade-visible';
        
        if (data.align === "Right") {
            menuContainer.style.left = 'auto';
            menuContainer.style.right = '20px';
        } else {
            menuContainer.style.left = '20px';
            menuContainer.style.right = 'auto';
        }
    }
    else if (data.action === "hideMenu") {
        keybindOverlay.className = 'fade-hidden';
        menuContainer.className = 'fade-hidden';
    }
    else if (data.action === "updateData" || data.action === "update") {
        document.getElementById('category-title').innerText = data.category || "MAIN MENU";
        
        let allTabs = data.tabs || [];
        let activeTabIdx = data.activeTab || 0;
        
        if (allTabs.length > 0) {
            let tabsHtml = "";
            let numTabs = allTabs.length;
            
            if(numTabs === 1) {
                tabsHtml = `<div class="tab active">${allTabs[0]}</div>`;
            } else {
                for (let i = 0; i < numTabs; i++) {
                    let isActive = (i === activeTabIdx) ? "active" : "";
                    tabsHtml += `<div class="tab ${isActive}">${allTabs[i]}</div>`;
                }
            }
            document.getElementById('tabs-container').innerHTML = tabsHtml;
            document.getElementById('tabs-container').style.display = 'flex';
        } else {
            document.getElementById('tabs-container').style.display = 'none';
        }
        
        let listHtml = "";
        let items = data.items;
        let selectedIndex = data.selectedIndex - 1; // Lua is 1-indexed
        
        let maxItems = 10;
        let startIndex = 0;
        if (selectedIndex >= maxItems) {
            startIndex = selectedIndex - maxItems + 1;
        }
        
        let visualSelectedIndex = -1;
        
        for (let i = 0; i < Math.min(items.length, maxItems); i++) {
            let actualIndex = startIndex + i;
            let item = items[actualIndex];
            if (!item) continue;
            
            let isSelected = (actualIndex === selectedIndex);
            if (isSelected && item.type !== "separator") {
                visualSelectedIndex = i;
            }
            let selectedClass = isSelected ? "selected" : "";
            let sepClass = (item.type === "separator") ? "menu-separator" : "";
            
            if (item.type === "separator") {
                listHtml += `<div class="menu-item ${selectedClass} ${sepClass}">--- ${item.label} ---</div>`;
            } else {
                let rightContent = "";
                
                if (item.type === "toggle") {
                    let onClass = item.value ? "on" : "";
                    rightContent = `<div class="toggle-switch ${onClass}"></div>`;
                } else if (item.type === "slider" || item.type === "list") {
                    rightContent = `<span>< ${item.value} ></span>`;
                } else if (item.type === "button") {
                    rightContent = `<span><i class="fa-solid fa-chevron-right"></i></span>`;
                }
                
                if (item.bind) {
                    rightContent += `<span style="margin-left: 8px; color: #f39c12;">[${item.bind}]</span>`;
                }
                
                let iconHtml = item.icon ? `<i class="fa-solid ${item.icon}"></i>` : "";
                
                listHtml += `
                <div class="menu-item ${selectedClass}">
                    <div class="left">${iconHtml} ${item.label}</div>
                    <div class="right">${rightContent}</div>
                </div>`;
            }
        }
        
        document.getElementById('items-list').innerHTML = listHtml;
        
        // Move selection box smoothly using translateY
        let selBox = document.getElementById('selection-box');
        if (visualSelectedIndex >= 0) {
            selBox.className = 'selection-box active';
            selBox.style.transform = `translateY(${visualSelectedIndex * 36}px)`;
        } else {
            selBox.className = 'selection-box';
        }
        
        let totalItems = items.length;
        if(totalItems > 0) {
            document.getElementById('pagination').innerText = (selectedIndex + 1) + "/" + totalItems;
        } else {
            document.getElementById('pagination').innerText = "0/0";
        }
    }
});
