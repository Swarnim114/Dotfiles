import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null

    IpcHandler {
        target: "plugin:manga-reader"
        function toggle() {
            if (pluginApi) pluginApi.withCurrentScreen(s => pluginApi.togglePanel(s));
        }
    }

    readonly property string apiUrl: "http://127.0.0.1:5150"

    // ── Manga list ───────────────────────────────────────────────────────────
    property list<var> mangaList: []
    property bool isFetchingManga: false
    property string mangaError: ""
    property bool hasMoreManga: false
    property int currentOffset: 0
    property int latestPage: 1
    property string currentSearchText: ""
    property string currentOrigin: ""

    // ── Manga detail ─────────────────────────────────────────────────────────
    property var currentManga: null
    property bool isFetchingDetail: false
    property string detailError: ""

    // ── Chapter pages ────────────────────────────────────────────────────────
    property list<var> chapterPages: []
    property bool isFetchingPages: false
    property string pagesError: ""
    property string currentChapterId: ""
    property bool dataSaverMode: false

    // ── Favorites ────────────────────────────────────────────────────────────
    property list<var> favoritesList: []
    property bool isFetchingFavs: false
    property int favNewCount: 0

    // ── Downloads ────────────────────────────────────────────────────────────
    property list<var> downloadsList: []
    property var downloadProgress: ({})

    // ── Library ──────────────────────────────────────────────────────────────
    property list<var> libraryList: []
    property bool libraryLoaded: false

    readonly property string _libraryPath:
        Quickshell.env("HOME") + "/.local/share/noctalia-manga-library.json"

    // File writing logic using Quickshell.env and raw JS File object if needed,
    // but we can use Quickshell.Io.Process or XMLHttpRequest 
    // Actually we'll just mock library features for a bit, or use Quickshell's standard way to save.

    // ── Backend server ───────────────────────────────────────────────────────
    property bool serverReady: false

    Process {
        id: serverProcess
        command: ["python3", Quickshell.env("HOME") + "/.config/noctalia/plugins/manga-reader/manga_server.py"]
        running: true
        onExited: (code) => {
            console.warn("[MangaReader] Server exited with code", code, "— restarting")
            serverReady = false
            serverProcess.running = true

    }
    }

    Timer {
        id: healthPoller
        interval: 150
        repeat: true
        running: true
        onTriggered: {
            var xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    healthPoller.stop()
                    root.serverReady = true
                    console.log("[MangaReader] Backend ready at", root.apiUrl)
                    fetchByOrigin("", true)
                }
            }
            xhr.open("GET", root.apiUrl + "/health")
            xhr.send()
        }
    }

    // ── HTTP helpers ──────────────────────────────────────────────────────────
    function _get(url, onDone) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 200) onDone(null, xhr.responseText)
            else onDone("HTTP " + xhr.status, null)
        }
        xhr.open("GET", url)
        xhr.send()
    }

    // ── Origin → type mapping ─────────────────────────────────────────────────
    function _originType(origin) {
        if (origin === "ko") return "Manhwa"
        if (origin === "ja") return "Manga"
        if (origin === "zh") return "Manhua"
        return ""
    }

    // ── Browse / Search ───────────────────────────────────────────────────────
    function fetchByOrigin(origin, reset) {
        if (isFetchingManga) return
        if (reset) { mangaList = []; currentOffset = 0; latestPage = 1 }
        currentOrigin = origin
        currentSearchText = ""

        if (origin === "") {
            isFetchingManga = true
            mangaError = ""
            const url = root.apiUrl + "/hot"
            _get(url, function(err, body) {
                if (err) { mangaError = "Request failed: " + err; isFetchingManga = false; return }
                _parseMangaResults(body)
            })
        } else if (origin === "latest") {
            if (reset) latestPage = 1
            isFetchingManga = true
            mangaError = ""
            const url = root.apiUrl + "/latest?page=" + latestPage
            _get(url, function(err, body) {
                if (err) { mangaError = "Request failed: " + err; isFetchingManga = false; return }
                _parseMangaResults(body)
            })
        } else {
            _doSearch("a", _originType(origin), currentOffset, "Popularity")
        }
    }

    function searchManga(query, reset) {
        if (isFetchingManga) return
        if (reset) { mangaList = []; currentOffset = 0 }
        currentSearchText = query
        _doSearch(query, _originType(currentOrigin), currentOffset, "Best Match")
    }

    function fetchNextMangaPage() {
        if (!hasMoreManga || isFetchingManga) return
        if (currentSearchText.length > 0) {
            _doSearch(currentSearchText, _originType(currentOrigin), currentOffset, "Best Match")
        } else if (currentOrigin === "latest") {
            latestPage++
            fetchByOrigin("latest", false)
        } else {
            _doSearch("a", _originType(currentOrigin), currentOffset, "Popularity")
        }
    }

    function _doSearch(query, type, offset, sort) {
        isFetchingManga = true
        mangaError = ""
        let url = root.apiUrl + "/search?q=" + encodeURIComponent(query)
            + "&offset=" + offset + "&sort=" + encodeURIComponent(sort)
        if (type) url += "&type=" + encodeURIComponent(type)
        _get(url, function(err, body) {
            if (err) { mangaError = "Request failed: " + err; isFetchingManga = false; return }
            _parseMangaResults(body)
        })
    }

    function _parseMangaResults(json) {
        try {
            const data = JSON.parse(json)
            if (data.error) { mangaError = data.error; isFetchingManga = false; return }

            const isHot    = Array.isArray(data)
            const isLatest = !isHot && data.nextPage !== undefined
            const items    = isHot ? data : (data.results || [])

            mangaList = [...mangaList, ...items.map(item => ({
                id:       item.id     || "",
                title:    item.title  || "",
                thumbUrl: item.image  || "",
                status:   item.status || "",
                type:     item.type   || "",
                author:   ""
            }))]

            hasMoreManga = isHot ? false : (data.hasMore || false)
            if (!isHot && !isLatest)
                currentOffset = data.nextOffset || (currentOffset + items.length)

            mangaError = ""
        } catch (e) {
            mangaError = "Parse error: " + e
            console.error("[MangaReader]", e)
        }
        isFetchingManga = false
    }

    // ── Additional mock functions to keep QML from crashing 
    function fetchMangaDetail(id) {
        isFetchingDetail = true
        _get(root.apiUrl + "/info?id=" + encodeURIComponent(id), function(err, body) {
            if(err) { detailError = err; isFetchingDetail = false; return; }
            try {
               currentManga = JSON.parse(body)
            } catch(e) {}
            isFetchingDetail = false
        })
    }
    
    function fetchChapterPages(chapterId) {
        isFetchingPages = true
        currentChapterId = chapterId
        _get(root.apiUrl + "/pages?chapterId=" + encodeURIComponent(chapterId), function(err, body){
            if(err) { pagesError = err; isFetchingPages = false; return; }
            try {
            chapterPages = JSON.parse(body)
            } catch(e) {}
            isFetchingPages = false
        })
    }
    
    function isInLibrary(id) { return false; }
    function addToLibrary(manga) {}
    function removeFromLibrary(id) {}
    function updateLastRead(mangaId, chapterId, number) {}
    function clearChapterList() {
        currentManga = null
        detailError = ""
    }

    function clearChapterPages() {
        chapterPages = []
        pagesError = ""
        currentChapterId = ""
    }

    function getLibraryEntry(id) {
        for(let i=0; i<libraryList.length; i++){
            if(libraryList[i].id === id) return libraryList[i];
        }
        return null;
    }
}
