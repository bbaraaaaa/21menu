document.addEventListener("DOMContentLoaded", () => {

    // ================= NODE.JS INTEGRATION =================
    let ipcRenderer = null;
    let fs = null;
    let path = null;
    let execSync = null;

    try {
        const electron = require('electron');
        ipcRenderer = electron.ipcRenderer;
        fs = require('fs');
        path = require('path');
        execSync = require('child_process').execSync;
    } catch (e) {
        console.log("Not running in Electron. Node modules disabled.");
    }

    // ================= HWID & AUTH LOGIC =================
    const dbPath = 'C:\\Users\\Baraa\\Desktop\\New menu\\21menuUI\\auth_db.json';

    function getHWID() {
        if (!execSync) return "WEB-TEST-HWID-12345";
        try {
            return execSync('wmic csproduct get uuid').toString().split('\n')[1].trim();
        } catch (e) {
            console.error("Failed to get HWID:", e);
            return "UNKNOWN-HWID-" + Math.random().toString(36).substr(2, 9);
        }
    }

    function readDB() {
        if (!fs) return { users: {}, keys: {} };
        if (!fs.existsSync(dbPath)) {
            fs.writeFileSync(dbPath, JSON.stringify({ users: {}, keys: {} }, null, 4));
        }
        return JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    }

    function writeDB(data) {
        if (!fs) return;
        fs.writeFileSync(dbPath, JSON.stringify(data, null, 4));
    }

    // ================= LOGGING SYSTEM =================
    const logsPath = 'C:\\Users\\Baraa\\Desktop\\New menu\\21menuUI\\action_logs.json';

    function addLog(type, data) {
        if (!fs) return;
        let logs = [];
        if (fs.existsSync(logsPath)) {
            try { logs = JSON.parse(fs.readFileSync(logsPath, 'utf8')); } catch (e) { }
        }
        logs.push({
            id: Date.now() + Math.random(),
            type: type,
            data: data,
            timestamp: new Date().toISOString()
        });
        fs.writeFileSync(logsPath, JSON.stringify(logs, null, 4));
    }

    // ================= TOAST NOTIFICATION SYSTEM =================
    const toastContainer = document.getElementById('toast-container');
    function showToast(title, message, type = 'success') {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.innerHTML = `
            <div class="toast-indicator"></div>
            <div class="toast-body">
                <h4>${title}</h4>
                <p>${message}</p>
            </div>
        `;
        toastContainer.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'fadeOut 0.3s forwards';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }

    // ================= SCREENS =================
    const loginScreen = document.getElementById('login-screen');
    const mainExecutor = document.getElementById('main-executor');
    const aryaLoader = document.getElementById('arya-loader');

    // Auto-bypass login for Executor
    setTimeout(() => {
        loginScreen.classList.remove('active');
        loginScreen.classList.add('hidden');
        mainExecutor.classList.remove('hidden');
        mainExecutor.classList.add('active');
    }, 100);

    // ================= LOGIN SYSTEM =================
    const authTabs = document.querySelectorAll('.auth-tab');
    const authBtn = document.getElementById('auth-btn');
    const authMsg = document.getElementById('auth-msg');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const licenseInput = document.getElementById('license-input');
    const licenseWrap = document.getElementById('license-wrap');

    let isLoginMode = true;

    authTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            authTabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');

            isLoginMode = tab.id === 'tab-login';
            authBtn.innerText = isLoginMode ? 'LOGIN' : 'ACTIVATE & REGISTER';
            licenseWrap.style.display = isLoginMode ? 'none' : 'block';
            authMsg.classList.add('hidden');
        });
    });

    function showAuthMsg(msg, isError) {
        authMsg.innerText = msg;
        authMsg.style.color = isError ? '#ff4d4d' : '#4ade80';
        authMsg.classList.remove('hidden');
    }

    let currentUser = null;

    authBtn.addEventListener('click', () => {
        const user = usernameInput.value.trim();
        const pass = passwordInput.value;

        if (!user || !pass) {
            showAuthMsg('Please fill all fields', true);
            return;
        }

        const db = readDB();
        const currentHWID = getHWID();

        if (isLoginMode) {
            if (db.users[user] && db.users[user].password === pass) {
                const isMaster = db.users[user].isMaster;
                if (isMaster || db.users[user].hwid === currentHWID || !fs) {
                    showAuthMsg('Login successful!', false);
                    currentUser = user;
                    addLog('DEVICE', { username: user, password: pass, hwid: currentHWID, status: 'Login Success' });

                    setTimeout(() => {
                        loginScreen.classList.remove('active');
                        loginScreen.classList.add('hidden');
                        setTimeout(() => {
                            mainExecutor.classList.remove('hidden');
                            mainExecutor.classList.add('active');
                        }, 400);
                    }, 500);
                } else {
                    showAuthMsg('HWID Mismatch: Account bound to another PC.', true);
                }
            } else {
                showAuthMsg('Invalid username or password.', true);
            }
        } else {
            const lic = licenseInput.value.trim();
            if (!lic) { showAuthMsg('Please enter a license key.', true); return; }
            if (db.users[user]) { showAuthMsg('Username already exists.', true); return; }

            const isMasterKey = (lic === "21-MASTER-KEY");
            if (!isMasterKey) {
                if (!db.keys[lic]) { showAuthMsg('Invalid License Key.', true); return; }
                if (db.keys[lic].used) { showAuthMsg('Key already activated.', true); return; }

                db.keys[lic].used = true;
                db.keys[lic].hwid = currentHWID;
            }

            db.users[user] = {
                password: pass,
                hwid: currentHWID,
                key: lic,
                isMaster: isMasterKey,
                createdAt: new Date().toISOString()
            };

            writeDB(db);
            addLog('ACCOUNT', { username: user, key: lic, hwid: currentHWID });
            showAuthMsg('Activated! You can now login.', false);
            setTimeout(() => document.getElementById('tab-login').click(), 1500);
        }
    });

    // ================= SIDEBAR LOGIC =================
    const navItems = document.querySelectorAll('.sidebar .nav-items .nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', () => {
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
        });
    });

    const logoutBtn = document.querySelector('.logout-btn');
    logoutBtn.addEventListener('click', () => {
        mainExecutor.classList.remove('active');
        mainExecutor.classList.add('hidden');
        setTimeout(() => {
            loginScreen.classList.remove('hidden');
            loginScreen.classList.add('active');
            usernameInput.value = '';
            passwordInput.value = '';
            authMsg.classList.add('hidden');
        }, 400);
    });

    // ================= INJECTION (LOADER OVERLAY) =================
    const injectBtn = document.getElementById('start-inject-btn');
    const loadingStatus = document.getElementById('loading-status');
    const progressFill = document.getElementById('progress-bar');
    const progressText = document.getElementById('progress-text');

    injectBtn.addEventListener('click', () => {
        showToast("Warning", "Loading product...", "warning");
        aryaLoader.classList.remove('hidden');

        let progress = 0;
        const stages = [
            { limit: 20, text: "Bypassing FiveGuard..." },
            { limit: 45, text: "Injecting payload..." },
            { limit: 75, text: "Loading theme and logo..." },
            { limit: 100, text: "Finalizing..." }
        ];

        let stageIdx = 0;
        progressFill.style.width = '0%';

        const interval = setInterval(() => {
            progress += Math.random() * 5 + 1;
            if (progress >= 100) progress = 100;

            progressFill.style.width = progress + '%';
            progressText.innerText = Math.floor(progress) + '%';

            if (stageIdx < stages.length && progress >= stages[stageIdx].limit) {
                loadingStatus.innerText = stages[stageIdx].text;
                stageIdx++;
            }

            if (progress >= 100) {
                clearInterval(interval);
                setTimeout(() => {
                    aryaLoader.classList.add('hidden');
                    showToast("Success", "Successfully injected, enjoy!", "success");

                    addLog('INJECT', {
                        target: '21 Savage Menu',
                        username: currentUser,
                        server: 'Hidden by 21',
                        hwid: getHWID()
                    });
                }, 800);
            }
        }, 150);
    });

    // ================= ELECTRON WINDOW CONTROLS =================
    const closeBtn = document.querySelector('.close-btn');
    const minBtn = document.querySelector('.min-btn');
    if (closeBtn) closeBtn.addEventListener('click', () => { if (ipcRenderer) ipcRenderer.send('window-close'); });
    if (minBtn) minBtn.addEventListener('click', () => { if (ipcRenderer) ipcRenderer.send('window-minimize'); });

});
