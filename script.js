let currentStartIndex = 0;

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
        document.getElementById("menu-container").classList.add("fade-hidden");
        document.getElementById("ped-preview").classList.add("fade-hidden");
        document.getElementById("search-modal").classList.add("fade-hidden");
    }
    else if (payload.action === "showSearch") {
        const searchModal = document.getElementById("search-modal");
        const searchInput = document.getElementById("search-input");
        if (payload.show) {
            searchModal.classList.remove("fade-hidden");
            searchInput.value = payload.currentQuery || "";
            setTimeout(() => searchInput.focus(), 50);
        } else {
            searchModal.classList.add("fade-hidden");
            searchInput.blur();
        }
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
            const jsSelectedIndex = (payload.selectedIndex || 1) - 1;
            const maxVisible = 10;
            
            if (jsSelectedIndex < currentStartIndex) {
                currentStartIndex = jsSelectedIndex;
            } else if (jsSelectedIndex >= currentStartIndex + maxVisible) {
                currentStartIndex = jsSelectedIndex - maxVisible + 1;
            }
            
            if (currentStartIndex > payload.items.length - maxVisible) {
                currentStartIndex = Math.max(0, payload.items.length - maxVisible);
            }
            
            const endIndex = Math.min(payload.items.length, currentStartIndex + maxVisible);
            const visibleItems = payload.items.slice(currentStartIndex, endIndex);
            
            visibleItems.forEach((item, indexOffset) => {
                const index = currentStartIndex + indexOffset;
                const isSelected = index === jsSelectedIndex;
                
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
                    // Use setTimeout to ensure DOM is painted before scrolling, avoiding CEF rendering locks
                    setTimeout(() => {
                        if (itemsContainer.contains(itemEl)) {
                            itemEl.scrollIntoView({ block: 'nearest' });
                        }
                    }, 10);
                }
            });
        }

        // Update Footer
        const footIndex = (payload.selectedIndex || 1) - 1;
        const maxItems = payload.items.filter(i => i.type !== 'separator').length;
        const currentSelected = payload.items[footIndex] && payload.items[footIndex].type === 'separator' 
            ? footIndex
            : footIndex + (footIndex === 0 && maxItems > 0 && payload.items[0].type !== 'separator' ? 1 : 0);
            
        // Calculate a visual index for the footer (skipping separators)
        let visualIndex = 0;
        let found = false;
        for (let i = 0; i < payload.items.length; i++) {
            if (payload.items[i].type !== 'separator') {
                visualIndex++;
                if (i === footIndex) {
                    found = true;
                    break;
                }
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
    else if (payload.action === "showPreview") {
        const previewEl = document.getElementById("ped-preview");
        if (payload.url && payload.url !== "") {
            previewEl.src = payload.url;
            previewEl.classList.remove("fade-hidden");
        } else {
            previewEl.classList.add("fade-hidden");
        }
    }
});

// Handle search input events
document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("search-input");
    const searchBtn = document.getElementById("search-btn");

    function submitSearch() {
        window.parent.postMessage({
            action: "searchResult",
            fromIframe: true,
            query: searchInput.value
        }, "*");
        document.getElementById("search-modal").classList.add("fade-hidden");
    }

    searchInput.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            submitSearch();
        } else if (e.key === "Escape") {
            e.preventDefault();
            window.parent.postMessage({
                action: "searchCancel",
                fromIframe: true
            }, "*");
            document.getElementById("search-modal").classList.add("fade-hidden");
        }
    });

    searchBtn.addEventListener("click", submitSearch);
});
