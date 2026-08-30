window.addEventListener("message", function(event) {
    const data = event.data;
    
    let payload = data;
    if (typeof data === "string") {
        try {
            payload = JSON.parse(data);
        } catch (e) {
            console.error("Failed to parse JSON:", e);
            return;
        }
    }

    const keybindOverlay = document.getElementById('keybind-overlay');
    const menuContainer = document.getElementById('menu-container');

    if (payload.action === "showKeybind") {
        keybindOverlay.className = payload.show ? 'fade-visible' : 'fade-hidden';
        menuContainer.className = 'fade-hidden';
        
        if (payload.keyName) {
            document.getElementById('keybind-inst').innerText = payload.promptText;
            document.getElementById('keybind-btn').innerText = payload.text;
            document.getElementById('keybind-btn').style.backgroundColor = "var(--bg-selected)";
            document.getElementById('keybind-btn').style.color = "var(--text-selected)";
        } else {
            document.getElementById('keybind-inst').innerText = "Enter Menu Open Key ...";
            document.getElementById('keybind-btn').innerText = "Waiting for input...";
            document.getElementById('keybind-btn').style.backgroundColor = "var(--bg-light)";
            document.getElementById('keybind-btn').style.color = "var(--text-main)";
        }
    } 
    else if (payload.action === "showMenu") {
        keybindOverlay.className = 'fade-hidden';
        menuContainer.className = 'fade-visible';
        
        if (payload.align === "Right") {
            menuContainer.classList.add("align-right");
        } else {
            menuContainer.classList.remove("align-right");
        }
    }
    else if (payload.action === "hideMenu") {
        menuContainer.className = 'fade-hidden';
    }
    else if (payload.action === "updateData" || payload.action === "update") {
        if (payload.show !== undefined) {
            menuContainer.className = payload.show ? 'fade-visible' : 'fade-hidden';
        }
        
        if (payload.align === "Right" || payload.menuAlign === "Right") {
            menuContainer.classList.add("align-right");
        } else {
            menuContainer.classList.remove("align-right");
        }

        // Render Tabs
        const tabsContainer = document.getElementById("menu-tabs");
        tabsContainer.innerHTML = "";
        
        if (payload.tabs && payload.tabs.length > 0) {
            payload.tabs.forEach((tabName, index) => {
                const tabEl = document.createElement("div");
                tabEl.className = "tab";
                if (index === payload.activeTab) {
                    tabEl.classList.add("active");
                }
                tabEl.innerText = tabName;
                tabsContainer.appendChild(tabEl);
            });
        }

        // Render Items
        const itemsContainer = document.getElementById("menu-items");
        itemsContainer.innerHTML = "";

        if (payload.items && payload.items.length > 0) {
            // Check if selectedIndex is 1-based (from Lua) or 0-based
            let actualSelectedIndex = payload.selectedIndex;
            // If the Lua script sends 1-based index (e.g. 1 for first item), we convert to 0-based
            // If it sends 0-based, we leave it. A simple heuristic is assuming it's 1-based.
            // But let's just support exactly what Lua sends.
            // In 21MENUv2.lua: selectedIndex = currentItemIdx (1-based)
            const is1Based = payload.selectedIndex > 0 && payload.selectedIndex <= payload.items.length;
            
            payload.items.forEach((item, index) => {
                // Determine if this item is selected.
                // Assuming Lua sends 1-based index (currentItemIdx)
                const isSelected = index === (payload.selectedIndex - 1);
                
                if (item.type === "separator") {
                    const sep = document.createElement("div");
                    sep.className = "item-separator";
                    const span = document.createElement("span");
                    span.innerText = item.label;
                    sep.appendChild(span);
                    itemsContainer.appendChild(sep);
                    return; // Skip normal item styling
                }

                const itemEl = document.createElement("div");
                itemEl.className = "item";
                if (isSelected) itemEl.classList.add("selected");

                const leftDiv = document.createElement("div");
                leftDiv.className = "item-left";
                
                if (item.icon) {
                    const icon = document.createElement("i");
                    icon.className = "fa-solid " + item.icon;
                    leftDiv.appendChild(icon);
                }
                
                const labelSpan = document.createElement("span");
                labelSpan.innerText = item.label;
                leftDiv.appendChild(labelSpan);

                const rightDiv = document.createElement("div");
                rightDiv.className = "item-right";

                if (item.bind || item.bindKey) {
                    const bindSpan = document.createElement("span");
                    bindSpan.style.marginRight = "10px";
                    bindSpan.style.fontSize = "11px";
                    bindSpan.style.opacity = "0.7";
                    bindSpan.innerText = "[" + (item.bind || item.bindKey) + "]";
                    rightDiv.appendChild(bindSpan);
                }

                if (item.type === "button" || item.type === "search") {
                    const chevron = document.createElement("i");
                    chevron.className = "fa-solid fa-chevron-right chevron";
                    rightDiv.appendChild(chevron);
                } 
                else if (item.type === "toggle") {
                    const toggleState = item.state !== undefined ? item.state : item.value;
                    const sw = document.createElement("div");
                    sw.className = "toggle-switch" + (toggleState ? " on" : "");
                    const th = document.createElement("div");
                    th.className = "toggle-thumb";
                    sw.appendChild(th);
                    rightDiv.appendChild(sw);
                } 
                else if (item.type === "slider") {
                    const sliderCont = document.createElement("div");
                    sliderCont.className = "slider-container";
                    
                    const track = document.createElement("div");
                    track.className = "slider-track";
                    
                    const thumb = document.createElement("div");
                    thumb.className = "slider-thumb";
                    
                    const val = item.value || 0;
                    const max = item.max || 100;
                    let pct = (val / max) * 100;
                    if (pct > 100) pct = 100;
                    
                    thumb.style.left = `calc(${pct}% - 5px)`;
                    
                    track.appendChild(thumb);
                    sliderCont.appendChild(track);
                    rightDiv.appendChild(sliderCont);
                }
                else if (item.type === "list") {
                    const listCont = document.createElement("div");
                    listCont.className = "list-container";
                    listCont.innerHTML = `<span class="list-arrow">&lt;</span> <span>${item.value || item.listName}</span> <span class="list-arrow">&gt;</span>`;
                    rightDiv.appendChild(listCont);
                }

                itemEl.appendChild(leftDiv);
                itemEl.appendChild(rightDiv);
                itemsContainer.appendChild(itemEl);

                if (isSelected) {
                    itemEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }
            });
        }

        // Update Footer
        const maxItems = payload.items.filter(i => i.type !== 'separator').length;
        const currentSelected = payload.items[payload.selectedIndex] && payload.items[payload.selectedIndex].type === 'separator' 
            ? payload.selectedIndex // Approximate if landing on separator (which shouldn't happen based on lua logic)
            : payload.selectedIndex + (payload.selectedIndex === 0 && maxItems > 0 && payload.items[0].type !== 'separator' ? 1 : 0); // Handle 0/1 indexing loosely for display
            
        // Calculate a visual index for the footer (skipping separators)
        let visualIndex = 0;
        let found = false;
        for (let i = 0; i < payload.items.length; i++) {
            if (payload.items[i].type !== 'separator') {
                visualIndex++;
            }
            if (i === payload.selectedIndex || i+1 === payload.selectedIndex) {
                found = true;
                break;
            }
        }
        if (!found) visualIndex = 1;
        
        document.getElementById('page-indicator').innerText = `${visualIndex}/${maxItems}`;
    }
    else if (payload.action === "notify") {
        const container = document.getElementById("notification-container");
        const notif = document.createElement("div");
        notif.className = "notification";
        notif.innerText = payload.message;
        container.appendChild(notif);

        setTimeout(() => {
            notif.style.animation = "fadeOut 0.3s ease forwards";
            setTimeout(() => {
                notif.remove();
            }, 300);
        }, 3000);
    }
});
