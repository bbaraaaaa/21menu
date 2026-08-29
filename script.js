window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "showKeybind") {
        document.getElementById('keybind-overlay').style.display = 'flex';
        document.getElementById('menu-container').style.display = 'none';
        
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
        document.getElementById('keybind-overlay').style.display = 'none';
        document.getElementById('menu-container').style.display = 'block';
        
        if (data.align === "Right") {
            document.getElementById('menu-container').style.left = 'auto';
            document.getElementById('menu-container').style.right = '100px';
        } else {
            document.getElementById('menu-container').style.left = '100px';
            document.getElementById('menu-container').style.right = 'auto';
        }
    }
    else if (data.action === "hideMenu") {
        document.getElementById('keybind-overlay').style.display = 'none';
        document.getElementById('menu-container').style.display = 'none';
    }
    else if (data.action === "updateData") {
        document.getElementById('sub-header-title').innerText = data.category + " > " + data.tab;
        
        let listHtml = "";
        let items = data.items;
        let selectedIndex = data.selectedIndex - 1; // Lua is 1-indexed
        
        let maxItems = 10;
        let startIndex = 0;
        if (selectedIndex >= maxItems) {
            startIndex = selectedIndex - maxItems + 1;
        }
        
        for (let i = 0; i < Math.min(items.length, maxItems); i++) {
            let actualIndex = startIndex + i;
            let item = items[actualIndex];
            if (!item) continue;
            
            let isSelected = (actualIndex === selectedIndex) ? "selected" : "";
            
            if (item.type === "separator") {
                listHtml += `<div class="menu-item ${isSelected}" style="justify-content:center; color:#888;">--- ${item.label} ---</div>`;
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
                <div class="menu-item ${isSelected}">
                    <div class="left">${iconHtml} ${item.label}</div>
                    <div class="right">${rightContent}</div>
                </div>`;
            }
        }
        
        document.getElementById('items-list').innerHTML = listHtml;
        let totalItems = items.length;
        if(totalItems > 0) {
            document.getElementById('pagination').innerText = (selectedIndex + 1) + "/" + totalItems;
        } else {
            document.getElementById('pagination').innerText = "0/0";
        }
    }
});
