document.addEventListener("DOMContentLoaded", () => {
    const searchModal = document.getElementById("search-modal");
    const searchInput = document.getElementById("search-input");
    const searchBtn = document.getElementById("search-btn");

    window.addEventListener("message", function(event) {
        const data = event.data;
        let payload = data;
        if (typeof data === "string") {
            try { payload = JSON.parse(data); } catch (e) {}
        }
        
        if (payload.action === "showSearch") {
            if (payload.show) {
                searchModal.classList.remove("fade-hidden");
                searchInput.value = payload.currentQuery || "";
                setTimeout(() => searchInput.focus(), 50);
            } else {
                searchModal.classList.add("fade-hidden");
                searchInput.blur();
            }
        }
    });

    function submitSearch() {
        fetch(`https://${GetParentResourceName()}/searchResult`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query: searchInput.value })
        });
        searchModal.classList.add("fade-hidden");
        searchInput.blur();
    }

    searchInput.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            submitSearch();
        }
    });

    // Handle escape on the whole document in case input loses focus
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            e.preventDefault();
            fetch(`https://${GetParentResourceName()}/searchCancel`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            searchModal.classList.add("fade-hidden");
            searchInput.blur();
        }
    });

    searchBtn.addEventListener("click", submitSearch);
});

    // Close when clicking outside the box
    searchModal.addEventListener('click', (e) => {
        if (e.target === searchModal) {
            fetch(https:///searchCancel, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            searchModal.classList.add("fade-hidden");
            searchInput.blur();
        }
    });
