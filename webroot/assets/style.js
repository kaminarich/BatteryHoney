async function fetchLog(filePath, elementId) {
    try {
        const response = await fetch(filePath + '?_=' + Date.now());
        const text = await response.text();
        document.getElementById(elementId).textContent = text;
    } catch (err) {
        document.getElementById(elementId).textContent = 'Log tidak tersedia.';
    }
}

function refreshLogs() {
    fetchLog('logs/ram-reclaim.log', 'reclaim-log');
    fetchLog('logs/screen_freq.log', 'monitor-log');
}

window.onload = function () {
    refreshLogs();
    setInterval(refreshLogs, 5000);
};