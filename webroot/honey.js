// ================== EXEC WRAPPER ==================
function exec(command) {
  return new Promise((resolve, reject) => {
    const cb = `exec_cb_${Date.now()}_${Math.random().toString(36).substring(2)}`;
    window[cb] = (errno, stdout, stderr) => {
      delete window[cb];
      if (errno !== 0) reject(new Error(stderr || stdout || "Unknown error"));
      else resolve(stdout);
    };
    try { ksu.exec(command, `window.${cb}`); } 
    catch (e) { console.log("Exec error:", e); reject(e); }
  });
}

// ================== PATHS & CONSTANTS ==================
const MOD_ROOT = "/data/adb/modules/batteryhoney";
const ASSETS_DIR = `${MOD_ROOT}/webroot/assets`; 

const FILES = {
    banner: `${ASSETS_DIR}/banner.webp`,
    backup: `${ASSETS_DIR}/banner2.webp`,
    
    // Configs
    prop: `${MOD_ROOT}/module.prop`,
    bannerConfig: `${MOD_ROOT}/banner_config.json`,

    // Features
    mode: `${MOD_ROOT}/cortex/battery/mode.txt`,        
    power: `${MOD_ROOT}/cortex/battery/powersave.txt`,    
    idle: "/data/local/tmp/batteryhoney/power.txt",      
    bypass: `${MOD_ROOT}/cortex/bypass/status.txt`       
};

const DOWNLOAD_PATH = "/sdcard/Download";
const SERVICE_BIN = "batteryhoney-bin";

const DEFAULT_CONFIG = { darkness: 30, blur: 0 };
let bannerConfig = { ...DEFAULT_CONFIG };

// --- GLOBAL VARS GALLERY ---
let selectedBannerPath = "current"; 
let downloadFilesList = []; 
let loadedCount = 0;        
const BATCH_SIZE = 10;      
let isLoadingBatch = false;

// ================== INIT ==================
document.addEventListener("DOMContentLoaded", async () => {
    initTheme();
    await loadAndApplyBannerConfig();
    await loadProp();
    checkPid();
    setInterval(checkPid, 3000);
    
    setupServiceMenu();
    setupCpuMenu();
    setupIdleMenu();
    setupBypassMenu();
    setupBannerMenu(); 
});

// ================== THEME & CONFIG ==================
function initTheme() {
    const toggle = document.getElementById("themeToggle");
    const stored = localStorage.getItem("honey_theme") || "light";
    document.documentElement.setAttribute("data-theme", stored);
    if(toggle) {
        toggle.checked = stored === "dark";
        toggle.addEventListener("change", (e) => {
            const theme = e.target.checked ? "dark" : "light";
            document.documentElement.setAttribute("data-theme", theme);
            localStorage.setItem("honey_theme", theme);
        });
    }
}

async function loadAndApplyBannerConfig() {
    try {
        const configStr = await exec(`cat "${FILES.bannerConfig}" 2>/dev/null`);
        if (configStr.trim()) bannerConfig = JSON.parse(configStr);
    } catch (e) { 
        bannerConfig = { ...DEFAULT_CONFIG }; 
    }
    const mainImage = document.getElementById("mainBannerImage");

    mainImage.src = `assets/banner.webp?t=${Date.now()}`;
    document.documentElement.style.setProperty('--banner-darkness', bannerConfig.darkness / 100);
    document.documentElement.style.setProperty('--banner-blur', `${bannerConfig.blur}px`);
}

// ================== BANNER MENU LOGIC ==================

function setupBannerMenu() {
    const btnOpen = document.getElementById("btnOpenBannerModal");
    const modal = document.getElementById("modalBanner");
    const btnClose = document.getElementById("closeBanner");
    const btnSave = document.getElementById("btnSaveBanner");
    
    const galleryArea = document.getElementById("bannerGalleryArea");
    const previewImg = document.getElementById("previewImage");
    const previewOverlay = document.getElementById("previewOverlay");
    
    const rangeDark = document.getElementById("rangeDarkness");
    const valDark = document.getElementById("valDarkness");
    const rangeBlur = document.getElementById("rangeBlur");
    const valBlur = document.getElementById("valBlur");

    // --- BUKA MODAL ---
    btnOpen.onclick = async () => {
        modal.classList.add("active");
        
        rangeDark.value = bannerConfig.darkness;
        rangeBlur.value = bannerConfig.blur;
        updateVisualEffects();
        
        previewImg.src = `assets/banner.webp?t=${Date.now()}`;
        selectedBannerPath = "current";

        await initGallerySession();
    };

    // --- TUTUP MODAL ---
    const handleClose = async () => {
        modal.classList.remove("active");
        try { await exec(`rm -f ${ASSETS_DIR}/preview_*`); } catch(e) {}
    };
    btnClose.onclick = handleClose;

    // --- INIT GALLERY ---
    async function initGallerySession() {
        galleryArea.innerHTML = "<div style='padding:20px; text-align:center;'>Preparing images...</div>";
        downloadFilesList = [];
        loadedCount = 0;

        try {

            await exec(`rm -f ${ASSETS_DIR}/preview_*`);
            

            const cmd = `ls -t "${DOWNLOAD_PATH}" | grep -iE "\\.(jpg|jpeg|png|webp)$" | head -n 100`; 
            const output = await exec(cmd);
            const files = output.trim().split('\n');
            
            files.forEach(f => {
                if(f.trim()) downloadFilesList.push(f.trim());
            });

            renderBaseItems();
            await loadNextBatch();

        } catch(e) {
            console.error(e);
            galleryArea.innerHTML = "Failed to load images.";
        }
    }

    function renderBaseItems() {
        galleryArea.innerHTML = ""; 
        addGalleryItem("Current Banner", "assets/banner.webp", "current", true);
        addGalleryItem("Restore Backup", "assets/banner2.webp", "default", true); 

        galleryArea.onscroll = () => {
            if (galleryArea.scrollLeft + galleryArea.clientWidth >= galleryArea.scrollWidth - 50) {
                loadNextBatch();
            }
        };
    }

    async function loadNextBatch() {
        if (isLoadingBatch) return;
        if (loadedCount >= downloadFilesList.length) return;

        isLoadingBatch = true;
        const limit = Math.min(loadedCount + BATCH_SIZE, downloadFilesList.length);
        const batchFiles = downloadFilesList.slice(loadedCount, limit);
        

        let copyCmd = "";
        batchFiles.forEach(fileName => {
            copyCmd += `cp -f "${DOWNLOAD_PATH}/${fileName}" "${ASSETS_DIR}/preview_${fileName}" ; `;
        });
        
        if (copyCmd) {
            try {
                await exec(copyCmd);
                batchFiles.forEach(fileName => {
                    const assetName = `preview_${fileName}`;
                    const webPath = `assets/${encodeURIComponent(assetName)}`;
                    const fullPath = `${ASSETS_DIR}/${assetName}`; 
                    
                    addGalleryItem(fileName, webPath, fullPath, false);
                });
            } catch (e) { console.error("Batch copy partial fail", e); }
        }

        loadedCount = limit;
        isLoadingBatch = false;
        
        if (galleryArea.scrollWidth <= galleryArea.clientWidth && loadedCount < downloadFilesList.length) {
            loadNextBatch();
        }
    }

    function addGalleryItem(name, imgSrc, dataPath, isLocal) {
        const el = document.createElement("div");
        el.className = `gallery-item ${dataPath === selectedBannerPath ? 'selected' : ''}`;
        const finalSrc = isLocal ? `${imgSrc}?t=${Date.now()}` : imgSrc;

        el.innerHTML = `
            <img src="${finalSrc}" style="object-fit: cover;">
            <div class="gallery-label">${name}</div>
        `;
        
        el.onclick = () => {
            document.querySelectorAll('.gallery-item').forEach(d => d.classList.remove('selected'));
            el.classList.add('selected');
            selectedBannerPath = dataPath;

            if(dataPath === 'current') previewImg.src = `assets/banner.webp?t=${Date.now()}`;
            else if (dataPath === 'default') previewImg.src = `assets/banner2.webp?t=def`;
            else previewImg.src = finalSrc; 
        };
        galleryArea.appendChild(el);
    }

    // --- SLIDERS ---
    function updateVisualEffects() {
        const d = rangeDark.value;
        const b = rangeBlur.value;
        valDark.innerText = `${d}%`;
        valBlur.innerText = `${b}px`;
        previewOverlay.style.backgroundColor = `rgba(0,0,0, ${d / 100})`;
        previewImg.style.filter = `blur(${b}px)`;
    }
    rangeDark.oninput = updateVisualEffects;
    rangeBlur.oninput = updateVisualEffects;


    btnSave.onclick = async () => {
        btnSave.innerText = "Processing...";
        
        try {

            if (selectedBannerPath === 'default') {

                await exec(`[ -f "${FILES.backup}" ] && cat "${FILES.backup}" > "${FILES.banner}"`);
                
                bannerConfig = { ...DEFAULT_CONFIG };
                await exec(`rm -f "${FILES.bannerConfig}"`);
            } 
            

            else if (selectedBannerPath !== "current") {

                await exec(`cat "${FILES.banner}" > "${FILES.backup}"`);

                await exec(`cat "${selectedBannerPath}" > "${FILES.banner}"`);
                
                await exec(`chmod 644 "${FILES.banner}"`);
                try { await exec(`chcon u:object_r:system_file:s0 "${FILES.banner}"`); } catch(e){}
                
                bannerConfig.darkness = parseInt(rangeDark.value);
                bannerConfig.blur = parseInt(rangeBlur.value);
                const jsonStr = JSON.stringify(bannerConfig).replace(/"/g, '\\"');
                await exec(`echo "${jsonStr}" > "${FILES.bannerConfig}"`);
            } 
            
            else {
                bannerConfig.darkness = parseInt(rangeDark.value);
                bannerConfig.blur = parseInt(rangeBlur.value);
                const jsonStr = JSON.stringify(bannerConfig).replace(/"/g, '\\"');
                await exec(`echo "${jsonStr}" > "${FILES.bannerConfig}"`);
            }

            await exec(`rm -f ${ASSETS_DIR}/preview_*`);
            

            await loadAndApplyBannerConfig();
            
            btnSave.innerText = "Saved!";
            btnSave.style.background = "var(--color-green)";
            
            setTimeout(() => {
                modal.classList.remove("active");
                btnSave.innerText = "Save & Apply";
                btnSave.style.background = "";
            }, 800);

        } catch (e) {
            console.error("Save Error:", e);
            btnSave.innerText = "Failed";
            alert("Error: " + e.message);
            btnSave.style.background = "var(--color-red)";
            setTimeout(() => {
                btnSave.innerText = "Save & Apply";
                btnSave.style.background = "";
            }, 2000);
        }
    };
}

// ================== MODULE INFO ==================
async function loadProp() {
    try {
        const raw = await exec(`cat ${FILES.prop}`);
        const getVal = (key) => {
            const regex = new RegExp(`^${key}=(.*)$`, 'm');
            const match = raw.match(regex);
            return match ? match[1].trim() : "...";
        };
        document.getElementById("propName").innerText = getVal("name") || "Battery Honey";
        document.getElementById("propVersion").innerText = getVal("version");
        document.getElementById("propAuthor").innerText = getVal("author");
        document.getElementById("propDescFull").innerText = getVal("description");
    } catch (e) {}
}

async function checkPid() {
    const icon = document.getElementById("serviceStatusIcon");
    const text = document.getElementById("servicePidText");
    try {
        const pid = await exec(`pidof ${SERVICE_BIN}`);
        if(pid && !isNaN(parseInt(pid))) {
            icon.className = "dot green"; text.innerText = "Active";
        } else { throw new Error(); }
    } catch {
        icon.className = "dot red"; text.innerText = "Offline";
    }
}

// ================== MENUS ==================
function setupServiceMenu() { setupGenericToggleMenu({ btnId: "btnServiceMenu", modalId: "modalService", closeId: "closeService", toggleId: "toggleService", previewId: "previewService", statusId: "statusService", file: FILES.mode, onVal: "on", offVal: "off" }); }
function setupBypassMenu() { setupGenericToggleMenu({ btnId: "btnBypassMenu", modalId: "modalBypass", closeId: "closeBypass", toggleId: "toggleBypass", previewId: "previewBypass", statusId: "statusBypass", file: FILES.bypass, onVal: "on", offVal: "off", title: "Bypass Charging" }); }

function setupGenericToggleMenu({btnId, modalId, closeId, toggleId, previewId, statusId, file, onVal, offVal}) {
    const btn = document.getElementById(btnId);
    const modal = document.getElementById(modalId);
    const close = document.getElementById(closeId);
    const toggle = document.getElementById(toggleId);
    const preview = document.getElementById(previewId);
    const status = document.getElementById(statusId);
    if(!btn) return;
    btn.onclick = () => modal.classList.add("active");
    close.onclick = () => modal.classList.remove("active");
    modal.onclick = (e) => { if(e.target===modal) modal.classList.remove("active"); }
    const load = async () => {
        try {
            await exec(`mkdir -p "$(dirname "${file}")"`);
            let val = (await exec(`cat "${file}" 2>/dev/null`)).trim();
            if(!val) val = offVal;
            const isOn = val === onVal;
            toggle.checked = isOn;
            preview.innerText = isOn ? "Active" : "Inactive";
            status.innerText = `Status: ${val.toUpperCase()}`;
        } catch (e) { toggle.checked = false; preview.innerText = "Error"; }
    };
    load();
    toggle.onchange = async () => {
        const val = toggle.checked ? onVal : offVal;
        status.innerText = "Applying...";
        try {
            await exec(`echo "${val}" > "${file}"`);
            status.innerHTML = `<span style="color:var(--color-green)">Saved: ${val.toUpperCase()}</span>`;
            preview.innerText = toggle.checked ? "Active" : "Inactive";
        } catch { status.innerText = "Failed"; toggle.checked = !toggle.checked; }
    };
}

function setupCpuMenu() {
    const btn = document.getElementById("btnCpuMenu"), modal = document.getElementById("modalCpu"), close = document.getElementById("closeCpu");
    const toggle = document.getElementById("toggleCpu"), select = document.getElementById("selectCpu"), display = document.getElementById("selectDisplay");
    const dropdownArea = document.getElementById("cpuDropdownArea"), preview = document.getElementById("previewCpu"), status = document.getElementById("statusCpu");
    btn.onclick = () => modal.classList.add("active");
    close.onclick = () => modal.classList.remove("active");
    modal.onclick = (e) => { if(e.target===modal) modal.classList.remove("active"); }
    const updateUI = (isOn, val) => {
        if(isOn) { dropdownArea.classList.add("open"); select.value = val; display.innerText = select.options[select.selectedIndex]?.text || val; preview.innerText = `Limit: ${val}%`; } 
        else { dropdownArea.classList.remove("open"); preview.innerText = "Default (100%)"; }
    };
    const load = async () => {
        try { let val = parseInt((await exec(`cat "${FILES.power}" 2>/dev/null`)).trim()); if(isNaN(val)) val = 100; const isLimit = val < 100; toggle.checked = isLimit; updateUI(isLimit, isLimit ? val : 50); status.innerText = `Current: ${val}%`; } 
        catch { updateUI(false, 100); }
    };
    load();
    toggle.onchange = async () => {
        const isOn = toggle.checked; const val = isOn ? select.value : "100";
        if(isOn) dropdownArea.classList.add("open"); else dropdownArea.classList.remove("open");
        status.innerText = "Applying...";
        try { await exec(`echo "${val}" > "${FILES.power}"`); status.innerHTML = `<span style="color:var(--color-green)">Applied: ${val}%</span>`; preview.innerText = isOn ? `Limit: ${val}%` : "Default (100%)"; } catch { status.innerText = "Error"; }
    };
    select.onchange = async () => {
        if(!toggle.checked) return; display.innerText = select.options[select.selectedIndex].text; const val = select.value; status.innerText = "Applying...";
        try { await exec(`echo "${val}" > "${FILES.power}"`); status.innerHTML = `<span style="color:var(--color-green)">Applied: ${val}%</span>`; preview.innerText = `Limit: ${val}%`; } catch { status.innerText = "Error"; }
    };
}

function setupIdleMenu() {
    const btn = document.getElementById("btnIdleMenu"), modal = document.getElementById("modalIdle"), close = document.getElementById("closeIdle");
    const select = document.getElementById("selectIdle"), display = document.getElementById("displayIdle"), preview = document.getElementById("previewIdle"), status = document.getElementById("statusIdle");
    btn.onclick = () => modal.classList.add("active");
    close.onclick = () => modal.classList.remove("active");
    modal.onclick = (e) => { if(e.target===modal) modal.classList.remove("active"); }
    const getText = (val) => { if(val == "7") return "Low (7)"; if(val == "17") return "Medium (17)"; if(val == "567") return "High (567)"; return "Unknown"; };
    const load = async () => {
        try { await exec("mkdir -p /data/local/tmp/batteryhoney"); let val = (await exec(`cat "${FILES.idle}" 2>/dev/null`)).trim(); if(val !== "7" && val !== "17" && val !== "567") val = "7"; select.value = val; display.innerText = getText(val); preview.innerText = getText(val); status.innerText = `Current Value: ${val}`; } catch { preview.innerText = "Error"; }
    };
    load();
    select.onchange = async () => {
        display.innerText = getText(select.value); const val = select.value; status.innerText = "Applying...";
        try { await exec("mkdir -p /data/local/tmp/batteryhoney"); await exec(`echo "${val}" > "${FILES.idle}"`); status.innerHTML = `<span style="color:var(--color-green)">Saved: ${val}</span>`; preview.innerText = getText(val); } catch { status.innerText = "Error"; }
    };
}
