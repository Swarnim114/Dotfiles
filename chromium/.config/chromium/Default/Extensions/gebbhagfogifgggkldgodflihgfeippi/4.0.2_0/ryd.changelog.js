/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
var __webpack_exports__ = {};

;// CONCATENATED MODULE: ./Extensions/combined/src/config.js
const DEV_API_URL = "https://returnyoutubedislikeapi.com";
const PROD_API_URL = "https://returnyoutubedislikeapi.com";

const runtime = typeof chrome !== "undefined" ? chrome.runtime : null;
const manifest = typeof runtime?.getManifest === "function" ? runtime.getManifest() : null;
const isDevelopment = !manifest || !("update_url" in manifest);

const extensionChangelogUrl =
  runtime && typeof runtime.getURL === "function"
    ? runtime.getURL("changelog/4/changelog_4.0.html")
    : "https://returnyoutubedislike.com/changelog/4/changelog_4.0.html";

const config = {
  apiUrl: isDevelopment ? DEV_API_URL : PROD_API_URL,

  voteDisabledIconName: "icon_hold128.png",
  defaultIconName: "icon128.png",

  links: {
    website: "https://returnyoutubedislike.com",
    github: "https://github.com/Anarios/return-youtube-dislike",
    discord: "https://discord.gg/mYnESY4Md5",
    donate: "https://returnyoutubedislike.com/donate",
    faq: "https://returnyoutubedislike.com/faq",
    help: "https://returnyoutubedislike.com/help",
    changelog: extensionChangelogUrl,
  },

  defaultExtConfig: {
    disableVoteSubmission: false,
    disableLogging: true,
    coloredThumbs: false,
    coloredBar: false,
    colorTheme: "classic",
    numberDisplayFormat: "compactShort",
    numberDisplayReformatLikes: false,
    hidePremiumTeaser: false,
  },
};

function getApiUrl() {
  return config.apiUrl;
}

function config_getApiEndpoint(endpoint) {
  return `${config.apiUrl}${endpoint.startsWith("/") ? "" : "/"}${endpoint}`;
}

function getChangelogUrl() {
  return config.links?.changelog ?? extensionChangelogUrl;
}



;// CONCATENATED MODULE: ./Extensions/combined/src/buttons.js



function buttons_getButtons() {
  //---   If Watching Youtube Shorts:   ---//
  if (isShorts()) {
    let elements = isMobile()
      ? querySelectorAll(extConfig.selectors.buttons.shorts.mobile)
      : querySelectorAll(extConfig.selectors.buttons.shorts.desktop);

    for (let element of elements) {
      //YouTube Shorts can have multiple like/dislike buttons when scrolling through videos
      //However, only one of them should be visible (no matter how you zoom)
      if (isInViewport(element)) {
        return element;
      }
    }
  }
  //---   If Watching On Mobile:   ---//
  if (isMobile()) {
    return document.querySelector(extConfig.selectors.buttons.regular.mobile);
  }
  //---   If Menu Element Is Displayed:   ---//
  if (querySelector(extConfig.selectors.menuContainer)?.offsetParent === null) {
    return querySelector(extConfig.selectors.buttons.regular.desktopMenu);
    //---   If Menu Element Isn't Displayed:   ---//
  } else {
    return querySelector(extConfig.selectors.buttons.regular.desktopNoMenu);
  }
}

function buttons_getLikeButton() {
  return buttons_getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? querySelector(extConfig.selectors.buttons.likeButton.segmented) ??
        querySelector(
          extConfig.selectors.buttons.likeButton.segmentedGetButtons,
          buttons_getButtons(),
        )
    : querySelector(
        extConfig.selectors.buttons.likeButton.notSegmented,
        buttons_getButtons(),
      );
}

function buttons_getLikeTextContainer() {
  return querySelector(extConfig.selectors.likeTextContainer, buttons_getLikeButton());
}

function buttons_getDislikeButton() {
  return buttons_getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? querySelector(extConfig.selectors.buttons.dislikeButton.segmented) ??
        querySelector(
          extConfig.selectors.buttons.dislikeButton.segmentedGetButtons,
          buttons_getButtons(),
        )
    : isShorts()
      ? querySelector(["#dislike-button"], buttons_getButtons())
      : querySelector(
          extConfig.selectors.buttons.dislikeButton.notSegmented,
          buttons_getButtons(),
        );
}

function createDislikeTextContainer() {
  const textNodeClone = (
    buttons_getLikeButton().querySelector(
      ".yt-spec-button-shape-next__button-text-content",
    ) ||
    buttons_getLikeButton().querySelector("button > div[class*='cbox']") ||
    (
      buttons_getLikeButton().querySelector('div > span[role="text"]') ||
      document.querySelector(
        'button > div.yt-spec-button-shape-next__button-text-content > span[role="text"]',
      )
    ).parentNode
  ).cloneNode(true);
  const insertPreChild = buttons_getDislikeButton().querySelector("button");
  insertPreChild.insertBefore(textNodeClone, null);
  buttons_getDislikeButton()
    .querySelector("button")
    .classList.remove("yt-spec-button-shape-next--icon-button");
  buttons_getDislikeButton()
    .querySelector("button")
    .classList.add("yt-spec-button-shape-next--icon-leading");
  if (textNodeClone.querySelector("span[role='text']") === null) {
    const span = document.createElement("span");
    span.setAttribute("role", "text");
    while (textNodeClone.firstChild) {
      textNodeClone.removeChild(textNodeClone.firstChild);
    }
    textNodeClone.appendChild(span);
  }
  textNodeClone.innerText = "";
  return textNodeClone;
}

function buttons_getDislikeTextContainer() {
  let result;
  for (const selector of extConfig.selectors.dislikeTextContainer) {
    result = buttons_getDislikeButton().querySelector(selector);
    if (result !== null) {
      break;
    }
  }
  if (result == null) {
    result = createDislikeTextContainer();
  }
  return result;
}

function checkForSignInButton() {
  if (
    document.querySelector(
      "a[href^='https://accounts.google.com/ServiceLogin']",
    )
  ) {
    return true;
  } else {
    return false;
  }
}



;// CONCATENATED MODULE: ./Extensions/combined/src/bar.js




function bar_createRateBar(likes, dislikes) {
  let rateBar = document.getElementById("ryd-bar-container");
  if (!isLikesDisabled()) {
    // sometimes rate bar is hidden
    if (rateBar && !isInViewport(rateBar)) {
      rateBar.remove();
      rateBar = null;
    }

    const widthPx =
      parseFloat(window.getComputedStyle(getLikeButton()).width) +
      parseFloat(window.getComputedStyle(getDislikeButton()).width) +
      (isRoundedDesign() ? 0 : 8);

    const widthPercent =
      likes + dislikes > 0 ? (likes / (likes + dislikes)) * 100 : 50;

    var likePercentage = parseFloat(widthPercent.toFixed(1));
    const dislikePercentage = (100 - likePercentage).toLocaleString();
    likePercentage = likePercentage.toLocaleString();

    if (extConfig.showTooltipPercentage) {
      var tooltipInnerHTML;
      switch (extConfig.tooltipPercentageMode) {
        case "dash_dislike":
          tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}&nbsp;&nbsp;-&nbsp;&nbsp;${dislikePercentage}%`;
          break;
        case "both":
          tooltipInnerHTML = `${likePercentage}%&nbsp;/&nbsp;${dislikePercentage}%`;
          break;
        case "only_like":
          tooltipInnerHTML = `${likePercentage}%`;
          break;
        case "only_dislike":
          tooltipInnerHTML = `${dislikePercentage}%`;
          break;
        default: // dash_like
          tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}&nbsp;&nbsp;-&nbsp;&nbsp;${likePercentage}%`;
      }
    } else {
      tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}`;
    }

    if (!isShorts()) {
      if (!rateBar && !isMobile()) {
        let colorLikeStyle = "";
        let colorDislikeStyle = "";
        if (extConfig.coloredBar) {
          colorLikeStyle = "; background-color: " + getColorFromTheme(true);
          colorDislikeStyle = "; background-color: " + getColorFromTheme(false);
        }
        let actions =
          isNewDesign() && getButtons().id === "top-level-buttons-computed"
            ? getButtons()
            : document.getElementById("menu-container");
        (
          actions ||
          document.querySelector("ytm-slim-video-action-bar-renderer")
        ).insertAdjacentHTML(
          "beforeend",
          `
              <div class="ryd-tooltip ryd-tooltip-${isNewDesign() ? "new" : "old"}-design" style="width: ${widthPx}px">
              <div class="ryd-tooltip-bar-container">
                <div
                    id="ryd-bar-container"
                    style="width: 100%; height: 2px;${colorDislikeStyle}"
                    >
                    <div
                      id="ryd-bar"
                      style="width: ${widthPercent}%; height: 100%${colorLikeStyle}"
                      ></div>
                </div>
              </div>
              <tp-yt-paper-tooltip position="top" id="ryd-dislike-tooltip" class="style-scope ytd-sentiment-bar-renderer" role="tooltip" tabindex="-1">
                <!--css-build:shady-->${tooltipInnerHTML}
              </tp-yt-paper-tooltip>
              </div>
      		`,
        );

        if (isNewDesign()) {
          // Add border between info and comments
          let descriptionAndActionsElement = document.getElementById("top-row");
          descriptionAndActionsElement.style.borderBottom =
            "1px solid var(--yt-spec-10-percent-layer)";
          descriptionAndActionsElement.style.paddingBottom = "10px";

          // Fix like/dislike ratio bar offset in new UI
          document.getElementById("actions-inner").style.width = "revert";
          if (isRoundedDesign()) {
            document.getElementById("actions").style.flexDirection =
              "row-reverse";
          }
        }
      } else {
        document.querySelector(`.ryd-tooltip`).style.width = widthPx + "px";
        document.getElementById("ryd-bar").style.width = widthPercent + "%";
        document.querySelector("#ryd-dislike-tooltip > #tooltip").innerHTML =
          tooltipInnerHTML;
        if (extConfig.coloredBar) {
          document.getElementById("ryd-bar-container").style.backgroundColor =
            getColorFromTheme(false);
          document.getElementById("ryd-bar").style.backgroundColor =
            getColorFromTheme(true);
        }
      }
    }
  } else {
    console.log("removing bar");
    if (rateBar) {
      rateBar.parentNode.removeChild(rateBar);
    }
  }
}



;// CONCATENATED MODULE: ./Extensions/combined/src/state.js




const LIKED_STATE = "LIKED_STATE";
const DISLIKED_STATE = "DISLIKED_STATE";
const NEUTRAL_STATE = "NEUTRAL_STATE";

let state_extConfig = {
  disableVoteSubmission: false,
  disableLogging: false,
  coloredThumbs: false,
  coloredBar: false,
  colorTheme: "classic",
  numberDisplayFormat: "compactShort",
  showTooltipPercentage: false,
  tooltipPercentageMode: "dash_like",
  numberDisplayReformatLikes: false,
  hidePremiumTeaser: false,
  selectors: {
    dislikeTextContainer: [],
    likeTextContainer: [],
    buttons: {
      shorts: {
        mobile: [],
        desktop: [],
      },
      regular: {
        mobile: [],
        desktopMenu: [],
        desktopNoMenu: [],
      },
      likeButton: {
        segmented: [],
        segmentedGetButtons: [],
        notSegmented: [],
      },
      dislikeButton: {
        segmented: [],
        segmentedGetButtons: [],
        notSegmented: [],
      },
    },
    menuContainer: [],
    roundedDesign: [],
  },
};

let storedData = {
  likes: 0,
  dislikes: 0,
  previousState: NEUTRAL_STATE,
};

function state_isMobile() {
  return location.hostname == "m.youtube.com";
}

function state_isShorts() {
  return location.pathname.startsWith("/shorts");
}

function state_isNewDesign() {
  return document.getElementById("comment-teaser") !== null;
}

function state_isRoundedDesign() {
  return querySelector(state_extConfig.selectors.roundedDesign) !== null;
}

let shortsObserver = null;

if (state_isShorts() && !shortsObserver) {
  console.log("Initializing shorts mutation observer");
  shortsObserver = createObserver(
    {
      attributes: true,
    },
    (mutationList) => {
      mutationList.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          mutation.target.nodeName === "TP-YT-PAPER-BUTTON" &&
          mutation.target.id === "button"
        ) {
          // console.log('Short thumb button status changed');
          if (mutation.target.getAttribute("aria-pressed") === "true") {
            mutation.target.style.color =
              mutation.target.parentElement.parentElement.id === "like-button"
                ? utils_getColorFromTheme(true)
                : utils_getColorFromTheme(false);
          } else {
            mutation.target.style.color = "unset";
          }
          return;
        }
        console.log("Unexpected mutation observer event: " + mutation.target + mutation.type);
      });
    },
  );
}

function state_isLikesDisabled() {
  // return true if the like button's text doesn't contain any number
  if (state_isMobile()) {
    return /^\D*$/.test(getButtons().children[0].querySelector(".button-renderer-text").innerText);
  }
  return /^\D*$/.test(getLikeTextContainer().innerText);
}

function isVideoLiked() {
  if (state_isMobile()) {
    return getLikeButton().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    getLikeButton().classList.contains("style-default-active") ||
    getLikeButton().querySelector("button")?.getAttribute("aria-pressed") === "true"
  );
}

function isVideoDisliked() {
  if (state_isMobile()) {
    return getDislikeButton().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    getDislikeButton().classList.contains("style-default-active") ||
    getDislikeButton().querySelector("button")?.getAttribute("aria-pressed") === "true"
  );
}

function getState(storedData) {
  if (isVideoLiked()) {
    return { current: LIKED_STATE, previous: storedData.previousState };
  }
  if (isVideoDisliked()) {
    return { current: DISLIKED_STATE, previous: storedData.previousState };
  }
  return { current: NEUTRAL_STATE, previous: storedData.previousState };
}

//---   Sets The Likes And Dislikes Values   ---//
function setLikes(likesCount) {
  console.log(`SET likes ${likesCount}`);
  getLikeTextContainer().innerText = likesCount;
}

function setDislikes(dislikesCount) {
  console.log(`SET dislikes ${dislikesCount}`);

  const _container = getDislikeTextContainer();
  _container?.removeAttribute("is-empty");

  let _dislikeText;
  if (!state_isLikesDisabled()) {
    if (state_isMobile()) {
      getButtons().children[1].querySelector(".button-renderer-text").innerText = dislikesCount;
      return;
    }
    _dislikeText = dislikesCount;
  } else {
    console.log("likes count disabled by creator");
    if (state_isMobile()) {
      getButtons().children[1].querySelector(".button-renderer-text").innerText = localize("TextLikesDisabled");
      return;
    }
    _dislikeText = localize("TextLikesDisabled");
  }

  if (_dislikeText != null && _container?.innerText !== _dislikeText) {
    _container.innerText = _dislikeText;
  }
}

function getLikeCountFromButton() {
  try {
    if (state_isShorts()) {
      //Youtube Shorts don't work with this query. It's not necessary; we can skip it and still see the results.
      //It should be possible to fix this function, but it's not critical to showing the dislike count.
      return false;
    }

    let likeButton =
      getLikeButton().querySelector("yt-formatted-string#text") ?? getLikeButton().querySelector("button");

    let likesStr = likeButton.getAttribute("aria-label").replace(/\D/g, "");
    return likesStr.length > 0 ? parseInt(likesStr) : false;
  } catch {
    return false;
  }
}

function processResponse(response, storedData) {
  const formattedDislike = numberFormat(response.dislikes);
  setDislikes(formattedDislike);
  if (state_extConfig.numberDisplayReformatLikes === true) {
    const nativeLikes = getLikeCountFromButton();
    if (nativeLikes !== false) {
      setLikes(numberFormat(nativeLikes));
    }
  }
  storedData.dislikes = parseInt(response.dislikes);
  storedData.likes = getLikeCountFromButton() || parseInt(response.likes);
  createRateBar(storedData.likes, storedData.dislikes);
  if (state_extConfig.coloredThumbs === true) {
    if (state_isShorts()) {
      // for shorts, leave deactivated buttons in default color
      let shortLikeButton = getLikeButton().querySelector("tp-yt-paper-button#button");
      let shortDislikeButton = getDislikeButton().querySelector("tp-yt-paper-button#button");
      if (shortLikeButton.getAttribute("aria-pressed") === "true") {
        shortLikeButton.style.color = getColorFromTheme(true);
      }
      if (shortDislikeButton.getAttribute("aria-pressed") === "true") {
        shortDislikeButton.style.color = getColorFromTheme(false);
      }
      shortsObserver.observe(shortLikeButton);
      shortsObserver.observe(shortDislikeButton);
    } else {
      getLikeButton().style.color = getColorFromTheme(true);
      getDislikeButton().style.color = getColorFromTheme(false);
    }
  }
  //Temporary disabling this - it breaks all places where getButtons()[1] is used
  // createStarRating(response.rating, isMobile());
}

// Tells the user if the API is down
function displayError(error) {
  getDislikeTextContainer().innerText = localize("textTempUnavailable");
}

async function setState(storedData) {
  storedData.previousState = isVideoDisliked() ? DISLIKED_STATE : isVideoLiked() ? LIKED_STATE : NEUTRAL_STATE;
  let statsSet = false;
  console.log("Video is loaded. Adding buttons...");

  let videoId = getVideoId(window.location.href);
  let likeCount = getLikeCountFromButton() || null;

  let response = await fetch(getApiEndpoint(`/votes?videoId=${videoId}&likeCount=${likeCount || ""}`), {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  })
    .then((response) => {
      if (!response.ok) displayError(response.error);
      return response;
    })
    .then((response) => response.json())
    .catch(displayError);
  console.log("response from api:");
  console.log(JSON.stringify(response));
  if (response !== undefined && !("traceId" in response) && !statsSet) {
    processResponse(response, storedData);
  }
}

async function setInitialState() {
  await setState(storedData);
}

async function initExtConfig() {
  initializeDisableVoteSubmission();
  initializeDisableLogging();
  initializeColoredThumbs();
  initializeColoredBar();
  initializeColorTheme();
  initializeNumberDisplayFormat();
  initializeTooltipPercentage();
  initializeTooltipPercentageMode();
  initializeNumberDisplayReformatLikes();
  initializeHidePremiumTeaser();
  await initializeSelectors();
}

async function initializeSelectors() {
  let result = await fetch(getApiEndpoint("/configs/selectors"), {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  })
    .then((response) => response.json())
    .catch((error) => {
      console.error("Error fetching selectors:", error);
    });
  state_extConfig.selectors = result ?? state_extConfig.selectors;
  console.log(result);
}

function initializeDisableVoteSubmission() {
  getBrowser().storage.sync.get(["disableVoteSubmission"], (res) => {
    if (res.disableVoteSubmission === undefined) {
      getBrowser().storage.sync.set({ disableVoteSubmission: false });
    } else {
      state_extConfig.disableVoteSubmission = res.disableVoteSubmission;
    }
  });
}

function initializeDisableLogging() {
  getBrowser().storage.sync.get(["disableLogging"], (res) => {
    if (res.disableLogging === undefined) {
      getBrowser().storage.sync.set({ disableLogging: true });
      state_extConfig.disableLogging = true;
    } else {
      state_extConfig.disableLogging = res.disableLogging;
    }
    // Initialize console methods based on logging config
    initializeLogging();
  });
}

function initializeColoredThumbs() {
  getBrowser().storage.sync.get(["coloredThumbs"], (res) => {
    if (res.coloredThumbs === undefined) {
      getBrowser().storage.sync.set({ coloredThumbs: false });
    } else {
      state_extConfig.coloredThumbs = res.coloredThumbs;
    }
  });
}

function initializeColoredBar() {
  getBrowser().storage.sync.get(["coloredBar"], (res) => {
    if (res.coloredBar === undefined) {
      getBrowser().storage.sync.set({ coloredBar: false });
    } else {
      state_extConfig.coloredBar = res.coloredBar;
    }
  });
}

function initializeColorTheme() {
  getBrowser().storage.sync.get(["colorTheme"], (res) => {
    if (res.colorTheme === undefined) {
      getBrowser().storage.sync.set({ colorTheme: false });
    } else {
      state_extConfig.colorTheme = res.colorTheme;
    }
  });
}

function initializeNumberDisplayFormat() {
  getBrowser().storage.sync.get(["numberDisplayFormat"], (res) => {
    if (res.numberDisplayFormat === undefined) {
      getBrowser().storage.sync.set({ numberDisplayFormat: "compactShort" });
    } else {
      state_extConfig.numberDisplayFormat = res.numberDisplayFormat;
    }
  });
}

function initializeTooltipPercentage() {
  getBrowser().storage.sync.get(["showTooltipPercentage"], (res) => {
    if (res.showTooltipPercentage === undefined) {
      getBrowser().storage.sync.set({ showTooltipPercentage: false });
    } else {
      state_extConfig.showTooltipPercentage = res.showTooltipPercentage;
    }
  });
}

function initializeTooltipPercentageMode() {
  getBrowser().storage.sync.get(["tooltipPercentageMode"], (res) => {
    if (res.tooltipPercentageMode === undefined) {
      getBrowser().storage.sync.set({ tooltipPercentageMode: "dash_like" });
    } else {
      state_extConfig.tooltipPercentageMode = res.tooltipPercentageMode;
    }
  });
}

function initializeNumberDisplayReformatLikes() {
  getBrowser().storage.sync.get(["numberDisplayReformatLikes"], (res) => {
    if (res.numberDisplayReformatLikes === undefined) {
      getBrowser().storage.sync.set({ numberDisplayReformatLikes: false });
    } else {
      state_extConfig.numberDisplayReformatLikes = res.numberDisplayReformatLikes;
    }
  });
}

function initializeHidePremiumTeaser() {
  getBrowser().storage.sync.get(["hidePremiumTeaser"], (res) => {
    if (res.hidePremiumTeaser === undefined) {
      getBrowser().storage.sync.set({ hidePremiumTeaser: false });
      state_extConfig.hidePremiumTeaser = false;
    } else {
      state_extConfig.hidePremiumTeaser = res.hidePremiumTeaser === true;
    }
  });
}



;// CONCATENATED MODULE: ./Extensions/combined/src/utils.js


function utils_numberFormat(numberState) {
  return getNumberFormatter(extConfig.numberDisplayFormat).format(numberState);
}

function getNumberFormatter(optionSelect) {
  let userLocales;
  if (document.documentElement.lang) {
    userLocales = document.documentElement.lang;
  } else if (navigator.language) {
    userLocales = navigator.language;
  } else {
    try {
      userLocales = new URL(
        Array.from(document.querySelectorAll("head > link[rel='search']"))
          ?.find((n) => n?.getAttribute("href")?.includes("?locale="))
          ?.getAttribute("href"),
      )?.searchParams?.get("locale");
    } catch {
      console.log("Cannot find browser locale. Use en as default for number formatting.");
      userLocales = "en";
    }
  }

  let formatterNotation;
  let formatterCompactDisplay;
  switch (optionSelect) {
    case "compactLong":
      formatterNotation = "compact";
      formatterCompactDisplay = "long";
      break;
    case "standard":
      formatterNotation = "standard";
      formatterCompactDisplay = "short";
      break;
    case "compactShort":
    default:
      formatterNotation = "compact";
      formatterCompactDisplay = "short";
  }

  return Intl.NumberFormat(userLocales, {
    notation: formatterNotation,
    compactDisplay: formatterCompactDisplay,
  });
}

function utils_localize(localeString, substitutions) {
  try {
    if (typeof chrome !== "undefined" && chrome?.i18n?.getMessage) {
      const args = substitutions === undefined ? [localeString] : [localeString, substitutions];
      const message = chrome.i18n.getMessage(...args);
      if (message) {
        return message;
      }
    }
  } catch (error) {
    console.warn("Localization lookup failed for", localeString, error);
  }

  if (Array.isArray(substitutions)) {
    return substitutions.join(" ");
  }

  if (substitutions != null) {
    return `${substitutions}`;
  }

  return localeString;
}

function utils_getBrowser() {
  if (typeof chrome !== "undefined" && typeof chrome.runtime !== "undefined") {
    return chrome;
  } else if (typeof browser !== "undefined" && typeof browser.runtime !== "undefined") {
    return browser;
  } else {
    console.log("browser is not supported");
    return false;
  }
}

function utils_getVideoId(url) {
  const urlObject = new URL(url);
  const pathname = urlObject.pathname;
  if (pathname.startsWith("/clip")) {
    return (document.querySelector("meta[itemprop='videoId']") || document.querySelector("meta[itemprop='identifier']"))
      .content;
  } else {
    if (pathname.startsWith("/shorts")) {
      return pathname.slice(8);
    }
    return urlObject.searchParams.get("v");
  }
}

function utils_isInViewport(element) {
  const rect = element.getBoundingClientRect();
  const height = innerHeight || document.documentElement.clientHeight;
  const width = innerWidth || document.documentElement.clientWidth;
  return (
    // When short (channel) is ignored, the element (like/dislike AND short itself) is
    // hidden with a 0 DOMRect. In this case, consider it outside of Viewport
    !(rect.top == 0 && rect.left == 0 && rect.bottom == 0 && rect.right == 0) &&
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <= height &&
    rect.right <= width
  );
}

function isShortsLoaded(videoId) {
  if (!videoId) return false;

  // Find all reel containers
  const reelContainers = document.querySelectorAll(".reel-video-in-sequence-new");

  for (const container of reelContainers) {
    // Check if this container's thumbnail matches our video ID
    const thumbnail = container.querySelector(".reel-video-in-sequence-thumbnail");
    if (thumbnail) {
      const bgImage = thumbnail.style.backgroundImage;
      // YouTube thumbnail URLs contain the video ID in the format: /vi/VIDEO_ID/
      if ((bgImage && bgImage.includes(`/${videoId}/`)) || (!bgImage && utils_isInViewport(container))) {
        // Check if this container has the renderer with visible experiment-overlay
        const renderer = container.querySelector("ytd-reel-video-renderer");
        if (renderer) {
          const experimentOverlay = renderer.querySelector("#experiment-overlay");
          if (
            experimentOverlay &&
            !experimentOverlay.hidden &&
            window.getComputedStyle(experimentOverlay).display !== "none" &&
            experimentOverlay.hasChildNodes()
          ) {
            return true;
          }
        }
      }
    }
  }

  return false;
}

function isVideoLoaded() {
  const videoId = utils_getVideoId(window.location.href);

  // Check if this is a Shorts URL
  if (isShorts()) {
    return isShortsLoaded(videoId);
  }

  // Regular video checks
  return (
    // desktop: spring 2024 UI
    document.querySelector(`ytd-watch-grid[video-id='${videoId}']`) !== null ||
    // desktop: older UI
    document.querySelector(`ytd-watch-flexy[video-id='${videoId}']`) !== null ||
    // mobile: no video-id attribute
    document.querySelector('#player[loading="false"]:not([hidden])') !== null
  );
}

const originalConsole = {
  log: console.log.bind(console),
  debug: console.debug.bind(console),
  info: console.info.bind(console),
  warn: console.warn.bind(console),
  error: console.error.bind(console),
};

function utils_initializeLogging() {
  if (extConfig.disableLogging) {
    console.log = () => {};
    console.debug = () => {};
  } else {
    console.log = originalConsole.log;
    console.debug = originalConsole.debug;
  }
}

function utils_getColorFromTheme(voteIsLike) {
  let colorString;
  switch (state_extConfig.colorTheme) {
    case "accessible":
      if (voteIsLike === true) {
        colorString = "dodgerblue";
      } else {
        colorString = "gold";
      }
      break;
    case "neon":
      if (voteIsLike === true) {
        colorString = "aqua";
      } else {
        colorString = "magenta";
      }
      break;
    case "classic":
    default:
      if (voteIsLike === true) {
        colorString = "lime";
      } else {
        colorString = "red";
      }
  }
  return colorString;
}

function utils_querySelector(selectors, element) {
  let result;
  for (const selector of selectors) {
    result = (element ?? document).querySelector(selector);
    if (result !== null) {
      return result;
    }
  }
}

function utils_querySelectorAll(selectors) {
  let result;
  for (const selector of selectors) {
    result = document.querySelectorAll(selector);
    if (result.length !== 0) {
      return result;
    }
  }
  return result;
}

function createObserver(options, callback) {
  const observerWrapper = new Object();
  observerWrapper.options = options;
  observerWrapper.observer = new MutationObserver(callback);
  observerWrapper.observe = function (element) {
    this.observer.observe(element, this.options);
  };
  observerWrapper.disconnect = function () {
    this.observer.disconnect();
  };
  return observerWrapper;
}



;// CONCATENATED MODULE: ./Extensions/combined/src/changelog/index.js



const PATREON_JOIN_URL = "https://www.patreon.com/join/returnyoutubedislike/checkout?rid=8008649";
const SUPPORT_DOC_URL = config.links?.help ?? "https://returnyoutubedislike.com/help";
const COMMUNITY_URL = config.links?.discord ?? "https://discord.gg/mYnESY4Md5";

function initChangelogPage() {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup);
  } else {
    setup();
  }
}

function setup() {
  applyLocaleMetadata();
  localizeHtmlPage();
  decorateScreenshotPlaceholders();
  bindActions();
}

function applyLocaleMetadata() {
  try {
    const browserLocale = chrome?.i18n?.getMessage?.("@@ui_locale");
    if (browserLocale) {
      document.documentElement.lang = browserLocale;
    }
  } catch (error) {
    console.debug("Unable to resolve UI locale", error);
  }
}

function localizeHtmlPage() {
  const elements = document.getElementsByTagName("html");
  for (let index = 0; index < elements.length; index += 1) {
    const element = elements[index];
    const original = element.innerHTML.toString();
    const localized = original.replace(/__MSG_(\w+)__/g, (match, key) => {
      return key ? utils_localize(key) : "";
    });

    if (localized !== original) {
      element.innerHTML = localized;
    }
  }
}

function decorateScreenshotPlaceholders() {
  document.querySelectorAll("[data-screenshot]").forEach((wrapper) => {
    const type = wrapper.getAttribute("data-screenshot");
    const labelKey = getPlaceholderLabelKey(type);
    if (!labelKey) return;

    const placeholder = wrapper.querySelector(".ryd-feature-card__placeholder");
    if (!placeholder) return;

    const label = utils_localize(labelKey);
    placeholder.setAttribute("role", "img");
    placeholder.setAttribute("aria-label", label);
    placeholder.title = label;
  });
}

function getPlaceholderLabelKey(type) {
  switch (type) {
    case "timeline":
      return "changelog_screenshot_label_timeline";
    case "map":
      return "changelog_screenshot_label_map";
    case "teaser":
      return "changelog_screenshot_label_teaser";
    default:
      return null;
  }
}

function bindActions() {
  const browser = utils_getBrowser();

  const upgradeButton = document.getElementById("ryd-changelog-upgrade");
  if (upgradeButton) {
    upgradeButton.addEventListener("click", (event) => {
      event.preventDefault();
      openExternal(PATREON_JOIN_URL, browser);
    });
  }

  const supportButton = document.getElementById("ryd-changelog-support");
  if (supportButton) {
    supportButton.addEventListener("click", (event) => {
      event.preventDefault();
      openExternal(SUPPORT_DOC_URL, browser);
    });
  }

  const contactButton = document.getElementById("ryd-changelog-contact");
  if (contactButton) {
    contactButton.addEventListener("click", (event) => {
      event.preventDefault();
      openExternal(COMMUNITY_URL, browser);
    });
  }
}

function openExternal(url, browser) {
  if (!url) return;

  try {
    if (browser && browser.tabs && typeof browser.tabs.create === "function") {
      browser.tabs.create({ url });
      return;
    }
  } catch (error) {
    console.debug("tabs.create unavailable, falling back", error);
  }

  try {
    window.open(url, "_blank", "noopener");
  } catch (error) {
    console.warn("Failed to open external url", url, error);
  }
}

;// CONCATENATED MODULE: ./Extensions/combined/ryd.changelog.js


initChangelogPage();

/******/ })()
;
//# sourceMappingURL=data:application/json;charset=utf-8;base64,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QixLQUFLO0FBQ2pDO0FBQ0E7QUFDQSxJQUFJO0FBQ0o7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBLElBQUk7QUFDSjtBQUNBO0FBQ0E7OztBQzFIb0Q7QUFDcEQ7QUFDQSxpQkFBaUIiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9yZXR1cm4teW91dHViZS1kaXNsaWtlLy4vRXh0ZW5zaW9ucy9jb21iaW5lZC9zcmMvY29uZmlnLmpzIiwid2VicGFjazovL3JldHVybi15b3V0dWJlLWRpc2xpa2UvLi9FeHRlbnNpb25zL2NvbWJpbmVkL3NyYy9idXR0b25zLmpzIiwid2VicGFjazovL3JldHVybi15b3V0dWJlLWRpc2xpa2UvLi9FeHRlbnNpb25zL2NvbWJpbmVkL3NyYy9iYXIuanMiLCJ3ZWJwYWNrOi8vcmV0dXJuLXlvdXR1YmUtZGlzbGlrZS8uL0V4dGVuc2lvbnMvY29tYmluZWQvc3JjL3N0YXRlLmpzIiwid2VicGFjazovL3JldHVybi15b3V0dWJlLWRpc2xpa2UvLi9FeHRlbnNpb25zL2NvbWJpbmVkL3NyYy91dGlscy5qcyIsIndlYnBhY2s6Ly9yZXR1cm4teW91dHViZS1kaXNsaWtlLy4vRXh0ZW5zaW9ucy9jb21iaW5lZC9zcmMvY2hhbmdlbG9nL2luZGV4LmpzIiwid2VicGFjazovL3JldHVybi15b3V0dWJlLWRpc2xpa2UvLi9FeHRlbnNpb25zL2NvbWJpbmVkL3J5ZC5jaGFuZ2Vsb2cuanMiXSwic291cmNlc0NvbnRlbnQiOlsiY29uc3QgREVWX0FQSV9VUkwgPSBcImh0dHBzOi8vcmV0dXJueW91dHViZWRpc2xpa2VhcGkuY29tXCI7XHJcbmNvbnN0IFBST0RfQVBJX1VSTCA9IFwiaHR0cHM6Ly9yZXR1cm55b3V0dWJlZGlzbGlrZWFwaS5jb21cIjtcclxuXHJcbmNvbnN0IHJ1bnRpbWUgPSB0eXBlb2YgY2hyb21lICE9PSBcInVuZGVmaW5lZFwiID8gY2hyb21lLnJ1bnRpbWUgOiBudWxsO1xyXG5jb25zdCBtYW5pZmVzdCA9IHR5cGVvZiBydW50aW1lPy5nZXRNYW5pZmVzdCA9PT0gXCJmdW5jdGlvblwiID8gcnVudGltZS5nZXRNYW5pZmVzdCgpIDogbnVsbDtcclxuY29uc3QgaXNEZXZlbG9wbWVudCA9ICFtYW5pZmVzdCB8fCAhKFwidXBkYXRlX3VybFwiIGluIG1hbmlmZXN0KTtcclxuXHJcbmNvbnN0IGV4dGVuc2lvbkNoYW5nZWxvZ1VybCA9XHJcbiAgcnVudGltZSAmJiB0eXBlb2YgcnVudGltZS5nZXRVUkwgPT09IFwiZnVuY3Rpb25cIlxyXG4gICAgPyBydW50aW1lLmdldFVSTChcImNoYW5nZWxvZy80L2NoYW5nZWxvZ180LjAuaHRtbFwiKVxyXG4gICAgOiBcImh0dHBzOi8vcmV0dXJueW91dHViZWRpc2xpa2UuY29tL2NoYW5nZWxvZy80L2NoYW5nZWxvZ180LjAuaHRtbFwiO1xyXG5cclxuY29uc3QgY29uZmlnID0ge1xyXG4gIGFwaVVybDogaXNEZXZlbG9wbWVudCA/IERFVl9BUElfVVJMIDogUFJPRF9BUElfVVJMLFxyXG5cclxuICB2b3RlRGlzYWJsZWRJY29uTmFtZTogXCJpY29uX2hvbGQxMjgucG5nXCIsXHJcbiAgZGVmYXVsdEljb25OYW1lOiBcImljb24xMjgucG5nXCIsXHJcblxyXG4gIGxpbmtzOiB7XHJcbiAgICB3ZWJzaXRlOiBcImh0dHBzOi8vcmV0dXJueW91dHViZWRpc2xpa2UuY29tXCIsXHJcbiAgICBnaXRodWI6IFwiaHR0cHM6Ly9naXRodWIuY29tL0FuYXJpb3MvcmV0dXJuLXlvdXR1YmUtZGlzbGlrZVwiLFxyXG4gICAgZGlzY29yZDogXCJodHRwczovL2Rpc2NvcmQuZ2cvbVluRVNZNE1kNVwiLFxyXG4gICAgZG9uYXRlOiBcImh0dHBzOi8vcmV0dXJueW91dHViZWRpc2xpa2UuY29tL2RvbmF0ZVwiLFxyXG4gICAgZmFxOiBcImh0dHBzOi8vcmV0dXJueW91dHViZWRpc2xpa2UuY29tL2ZhcVwiLFxyXG4gICAgaGVscDogXCJodHRwczovL3JldHVybnlvdXR1YmVkaXNsaWtlLmNvbS9oZWxwXCIsXHJcbiAgICBjaGFuZ2Vsb2c6IGV4dGVuc2lvbkNoYW5nZWxvZ1VybCxcclxuICB9LFxyXG5cclxuICBkZWZhdWx0RXh0Q29uZmlnOiB7XHJcbiAgICBkaXNhYmxlVm90ZVN1Ym1pc3Npb246IGZhbHNlLFxyXG4gICAgZGlzYWJsZUxvZ2dpbmc6IHRydWUsXHJcbiAgICBjb2xvcmVkVGh1bWJzOiBmYWxzZSxcclxuICAgIGNvbG9yZWRCYXI6IGZhbHNlLFxyXG4gICAgY29sb3JUaGVtZTogXCJjbGFzc2ljXCIsXHJcbiAgICBudW1iZXJEaXNwbGF5Rm9ybWF0OiBcImNvbXBhY3RTaG9ydFwiLFxyXG4gICAgbnVtYmVyRGlzcGxheVJlZm9ybWF0TGlrZXM6IGZhbHNlLFxyXG4gICAgaGlkZVByZW1pdW1UZWFzZXI6IGZhbHNlLFxyXG4gIH0sXHJcbn07XHJcblxyXG5mdW5jdGlvbiBnZXRBcGlVcmwoKSB7XHJcbiAgcmV0dXJuIGNvbmZpZy5hcGlVcmw7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGdldEFwaUVuZHBvaW50KGVuZHBvaW50KSB7XHJcbiAgcmV0dXJuIGAke2NvbmZpZy5hcGlVcmx9JHtlbmRwb2ludC5zdGFydHNXaXRoKFwiL1wiKSA/IFwiXCIgOiBcIi9cIn0ke2VuZHBvaW50fWA7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGdldENoYW5nZWxvZ1VybCgpIHtcclxuICByZXR1cm4gY29uZmlnLmxpbmtzPy5jaGFuZ2Vsb2cgPz8gZXh0ZW5zaW9uQ2hhbmdlbG9nVXJsO1xyXG59XHJcblxyXG5leHBvcnQgeyBjb25maWcsIGdldEFwaVVybCwgZ2V0QXBpRW5kcG9pbnQsIGdldENoYW5nZWxvZ1VybCB9O1xyXG4iLCJpbXBvcnQgeyBpc01vYmlsZSwgaXNTaG9ydHMsIGV4dENvbmZpZyB9IGZyb20gXCIuL3N0YXRlXCI7XHJcbmltcG9ydCB7IGlzSW5WaWV3cG9ydCwgcXVlcnlTZWxlY3RvciwgcXVlcnlTZWxlY3RvckFsbCB9IGZyb20gXCIuL3V0aWxzXCI7XHJcblxyXG5mdW5jdGlvbiBnZXRCdXR0b25zKCkge1xyXG4gIC8vLS0tICAgSWYgV2F0Y2hpbmcgWW91dHViZSBTaG9ydHM6ICAgLS0tLy9cclxuICBpZiAoaXNTaG9ydHMoKSkge1xyXG4gICAgbGV0IGVsZW1lbnRzID0gaXNNb2JpbGUoKVxyXG4gICAgICA/IHF1ZXJ5U2VsZWN0b3JBbGwoZXh0Q29uZmlnLnNlbGVjdG9ycy5idXR0b25zLnNob3J0cy5tb2JpbGUpXHJcbiAgICAgIDogcXVlcnlTZWxlY3RvckFsbChleHRDb25maWcuc2VsZWN0b3JzLmJ1dHRvbnMuc2hvcnRzLmRlc2t0b3ApO1xyXG5cclxuICAgIGZvciAobGV0IGVsZW1lbnQgb2YgZWxlbWVudHMpIHtcclxuICAgICAgLy9Zb3VUdWJlIFNob3J0cyBjYW4gaGF2ZSBtdWx0aXBsZSBsaWtlL2Rpc2xpa2UgYnV0dG9ucyB3aGVuIHNjcm9sbGluZyB0aHJvdWdoIHZpZGVvc1xyXG4gICAgICAvL0hvd2V2ZXIsIG9ubHkgb25lIG9mIHRoZW0gc2hvdWxkIGJlIHZpc2libGUgKG5vIG1hdHRlciBob3cgeW91IHpvb20pXHJcbiAgICAgIGlmIChpc0luVmlld3BvcnQoZWxlbWVudCkpIHtcclxuICAgICAgICByZXR1cm4gZWxlbWVudDtcclxuICAgICAgfVxyXG4gICAgfVxyXG4gIH1cclxuICAvLy0tLSAgIElmIFdhdGNoaW5nIE9uIE1vYmlsZTogICAtLS0vL1xyXG4gIGlmIChpc01vYmlsZSgpKSB7XHJcbiAgICByZXR1cm4gZG9jdW1lbnQucXVlcnlTZWxlY3RvcihleHRDb25maWcuc2VsZWN0b3JzLmJ1dHRvbnMucmVndWxhci5tb2JpbGUpO1xyXG4gIH1cclxuICAvLy0tLSAgIElmIE1lbnUgRWxlbWVudCBJcyBEaXNwbGF5ZWQ6ICAgLS0tLy9cclxuICBpZiAocXVlcnlTZWxlY3RvcihleHRDb25maWcuc2VsZWN0b3JzLm1lbnVDb250YWluZXIpPy5vZmZzZXRQYXJlbnQgPT09IG51bGwpIHtcclxuICAgIHJldHVybiBxdWVyeVNlbGVjdG9yKGV4dENvbmZpZy5zZWxlY3RvcnMuYnV0dG9ucy5yZWd1bGFyLmRlc2t0b3BNZW51KTtcclxuICAgIC8vLS0tICAgSWYgTWVudSBFbGVtZW50IElzbid0IERpc3BsYXllZDogICAtLS0vL1xyXG4gIH0gZWxzZSB7XHJcbiAgICByZXR1cm4gcXVlcnlTZWxlY3RvcihleHRDb25maWcuc2VsZWN0b3JzLmJ1dHRvbnMucmVndWxhci5kZXNrdG9wTm9NZW51KTtcclxuICB9XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGdldExpa2VCdXR0b24oKSB7XHJcbiAgcmV0dXJuIGdldEJ1dHRvbnMoKS5jaGlsZHJlblswXS50YWdOYW1lID09PVxyXG4gICAgXCJZVEQtU0VHTUVOVEVELUxJS0UtRElTTElLRS1CVVRUT04tUkVOREVSRVJcIlxyXG4gICAgPyBxdWVyeVNlbGVjdG9yKGV4dENvbmZpZy5zZWxlY3RvcnMuYnV0dG9ucy5saWtlQnV0dG9uLnNlZ21lbnRlZCkgPz9cclxuICAgICAgICBxdWVyeVNlbGVjdG9yKFxyXG4gICAgICAgICAgZXh0Q29uZmlnLnNlbGVjdG9ycy5idXR0b25zLmxpa2VCdXR0b24uc2VnbWVudGVkR2V0QnV0dG9ucyxcclxuICAgICAgICAgIGdldEJ1dHRvbnMoKSxcclxuICAgICAgICApXHJcbiAgICA6IHF1ZXJ5U2VsZWN0b3IoXHJcbiAgICAgICAgZXh0Q29uZmlnLnNlbGVjdG9ycy5idXR0b25zLmxpa2VCdXR0b24ubm90U2VnbWVudGVkLFxyXG4gICAgICAgIGdldEJ1dHRvbnMoKSxcclxuICAgICAgKTtcclxufVxyXG5cclxuZnVuY3Rpb24gZ2V0TGlrZVRleHRDb250YWluZXIoKSB7XHJcbiAgcmV0dXJuIHF1ZXJ5U2VsZWN0b3IoZXh0Q29uZmlnLnNlbGVjdG9ycy5saWtlVGV4dENvbnRhaW5lciwgZ2V0TGlrZUJ1dHRvbigpKTtcclxufVxyXG5cclxuZnVuY3Rpb24gZ2V0RGlzbGlrZUJ1dHRvbigpIHtcclxuICByZXR1cm4gZ2V0QnV0dG9ucygpLmNoaWxkcmVuWzBdLnRhZ05hbWUgPT09XHJcbiAgICBcIllURC1TRUdNRU5URUQtTElLRS1ESVNMSUtFLUJVVFRPTi1SRU5ERVJFUlwiXHJcbiAgICA/IHF1ZXJ5U2VsZWN0b3IoZXh0Q29uZmlnLnNlbGVjdG9ycy5idXR0b25zLmRpc2xpa2VCdXR0b24uc2VnbWVudGVkKSA/P1xyXG4gICAgICAgIHF1ZXJ5U2VsZWN0b3IoXHJcbiAgICAgICAgICBleHRDb25maWcuc2VsZWN0b3JzLmJ1dHRvbnMuZGlzbGlrZUJ1dHRvbi5zZWdtZW50ZWRHZXRCdXR0b25zLFxyXG4gICAgICAgICAgZ2V0QnV0dG9ucygpLFxyXG4gICAgICAgIClcclxuICAgIDogaXNTaG9ydHMoKVxyXG4gICAgICA/IHF1ZXJ5U2VsZWN0b3IoW1wiI2Rpc2xpa2UtYnV0dG9uXCJdLCBnZXRCdXR0b25zKCkpXHJcbiAgICAgIDogcXVlcnlTZWxlY3RvcihcclxuICAgICAgICAgIGV4dENvbmZpZy5zZWxlY3RvcnMuYnV0dG9ucy5kaXNsaWtlQnV0dG9uLm5vdFNlZ21lbnRlZCxcclxuICAgICAgICAgIGdldEJ1dHRvbnMoKSxcclxuICAgICAgICApO1xyXG59XHJcblxyXG5mdW5jdGlvbiBjcmVhdGVEaXNsaWtlVGV4dENvbnRhaW5lcigpIHtcclxuICBjb25zdCB0ZXh0Tm9kZUNsb25lID0gKFxyXG4gICAgZ2V0TGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXHJcbiAgICAgIFwiLnl0LXNwZWMtYnV0dG9uLXNoYXBlLW5leHRfX2J1dHRvbi10ZXh0LWNvbnRlbnRcIixcclxuICAgICkgfHxcclxuICAgIGdldExpa2VCdXR0b24oKS5xdWVyeVNlbGVjdG9yKFwiYnV0dG9uID4gZGl2W2NsYXNzKj0nY2JveCddXCIpIHx8XHJcbiAgICAoXHJcbiAgICAgIGdldExpa2VCdXR0b24oKS5xdWVyeVNlbGVjdG9yKCdkaXYgPiBzcGFuW3JvbGU9XCJ0ZXh0XCJdJykgfHxcclxuICAgICAgZG9jdW1lbnQucXVlcnlTZWxlY3RvcihcclxuICAgICAgICAnYnV0dG9uID4gZGl2Lnl0LXNwZWMtYnV0dG9uLXNoYXBlLW5leHRfX2J1dHRvbi10ZXh0LWNvbnRlbnQgPiBzcGFuW3JvbGU9XCJ0ZXh0XCJdJyxcclxuICAgICAgKVxyXG4gICAgKS5wYXJlbnROb2RlXHJcbiAgKS5jbG9uZU5vZGUodHJ1ZSk7XHJcbiAgY29uc3QgaW5zZXJ0UHJlQ2hpbGQgPSBnZXREaXNsaWtlQnV0dG9uKCkucXVlcnlTZWxlY3RvcihcImJ1dHRvblwiKTtcclxuICBpbnNlcnRQcmVDaGlsZC5pbnNlcnRCZWZvcmUodGV4dE5vZGVDbG9uZSwgbnVsbCk7XHJcbiAgZ2V0RGlzbGlrZUJ1dHRvbigpXHJcbiAgICAucXVlcnlTZWxlY3RvcihcImJ1dHRvblwiKVxyXG4gICAgLmNsYXNzTGlzdC5yZW1vdmUoXCJ5dC1zcGVjLWJ1dHRvbi1zaGFwZS1uZXh0LS1pY29uLWJ1dHRvblwiKTtcclxuICBnZXREaXNsaWtlQnV0dG9uKClcclxuICAgIC5xdWVyeVNlbGVjdG9yKFwiYnV0dG9uXCIpXHJcbiAgICAuY2xhc3NMaXN0LmFkZChcInl0LXNwZWMtYnV0dG9uLXNoYXBlLW5leHQtLWljb24tbGVhZGluZ1wiKTtcclxuICBpZiAodGV4dE5vZGVDbG9uZS5xdWVyeVNlbGVjdG9yKFwic3Bhbltyb2xlPSd0ZXh0J11cIikgPT09IG51bGwpIHtcclxuICAgIGNvbnN0IHNwYW4gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KFwic3BhblwiKTtcclxuICAgIHNwYW4uc2V0QXR0cmlidXRlKFwicm9sZVwiLCBcInRleHRcIik7XHJcbiAgICB3aGlsZSAodGV4dE5vZGVDbG9uZS5maXJzdENoaWxkKSB7XHJcbiAgICAgIHRleHROb2RlQ2xvbmUucmVtb3ZlQ2hpbGQodGV4dE5vZGVDbG9uZS5maXJzdENoaWxkKTtcclxuICAgIH1cclxuICAgIHRleHROb2RlQ2xvbmUuYXBwZW5kQ2hpbGQoc3Bhbik7XHJcbiAgfVxyXG4gIHRleHROb2RlQ2xvbmUuaW5uZXJUZXh0ID0gXCJcIjtcclxuICByZXR1cm4gdGV4dE5vZGVDbG9uZTtcclxufVxyXG5cclxuZnVuY3Rpb24gZ2V0RGlzbGlrZVRleHRDb250YWluZXIoKSB7XHJcbiAgbGV0IHJlc3VsdDtcclxuICBmb3IgKGNvbnN0IHNlbGVjdG9yIG9mIGV4dENvbmZpZy5zZWxlY3RvcnMuZGlzbGlrZVRleHRDb250YWluZXIpIHtcclxuICAgIHJlc3VsdCA9IGdldERpc2xpa2VCdXR0b24oKS5xdWVyeVNlbGVjdG9yKHNlbGVjdG9yKTtcclxuICAgIGlmIChyZXN1bHQgIT09IG51bGwpIHtcclxuICAgICAgYnJlYWs7XHJcbiAgICB9XHJcbiAgfVxyXG4gIGlmIChyZXN1bHQgPT0gbnVsbCkge1xyXG4gICAgcmVzdWx0ID0gY3JlYXRlRGlzbGlrZVRleHRDb250YWluZXIoKTtcclxuICB9XHJcbiAgcmV0dXJuIHJlc3VsdDtcclxufVxyXG5cclxuZnVuY3Rpb24gY2hlY2tGb3JTaWduSW5CdXR0b24oKSB7XHJcbiAgaWYgKFxyXG4gICAgZG9jdW1lbnQucXVlcnlTZWxlY3RvcihcclxuICAgICAgXCJhW2hyZWZePSdodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20vU2VydmljZUxvZ2luJ11cIixcclxuICAgIClcclxuICApIHtcclxuICAgIHJldHVybiB0cnVlO1xyXG4gIH0gZWxzZSB7XHJcbiAgICByZXR1cm4gZmFsc2U7XHJcbiAgfVxyXG59XHJcblxyXG5leHBvcnQge1xyXG4gIGdldEJ1dHRvbnMsXHJcbiAgZ2V0TGlrZUJ1dHRvbixcclxuICBnZXREaXNsaWtlQnV0dG9uLFxyXG4gIGdldExpa2VUZXh0Q29udGFpbmVyLFxyXG4gIGdldERpc2xpa2VUZXh0Q29udGFpbmVyLFxyXG4gIGNoZWNrRm9yU2lnbkluQnV0dG9uLFxyXG59O1xyXG4iLCJpbXBvcnQgeyBnZXRCdXR0b25zLCBnZXREaXNsaWtlQnV0dG9uLCBnZXRMaWtlQnV0dG9uIH0gZnJvbSBcIi4vYnV0dG9uc1wiO1xyXG5pbXBvcnQge1xyXG4gIGV4dENvbmZpZyxcclxuICBpc01vYmlsZSxcclxuICBpc0xpa2VzRGlzYWJsZWQsXHJcbiAgaXNOZXdEZXNpZ24sXHJcbiAgaXNSb3VuZGVkRGVzaWduLFxyXG4gIGlzU2hvcnRzLFxyXG59IGZyb20gXCIuL3N0YXRlXCI7XHJcbmltcG9ydCB7IGdldENvbG9yRnJvbVRoZW1lLCBpc0luVmlld3BvcnQgfSBmcm9tIFwiLi91dGlsc1wiO1xyXG5cclxuZnVuY3Rpb24gY3JlYXRlUmF0ZUJhcihsaWtlcywgZGlzbGlrZXMpIHtcclxuICBsZXQgcmF0ZUJhciA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwicnlkLWJhci1jb250YWluZXJcIik7XHJcbiAgaWYgKCFpc0xpa2VzRGlzYWJsZWQoKSkge1xyXG4gICAgLy8gc29tZXRpbWVzIHJhdGUgYmFyIGlzIGhpZGRlblxyXG4gICAgaWYgKHJhdGVCYXIgJiYgIWlzSW5WaWV3cG9ydChyYXRlQmFyKSkge1xyXG4gICAgICByYXRlQmFyLnJlbW92ZSgpO1xyXG4gICAgICByYXRlQmFyID0gbnVsbDtcclxuICAgIH1cclxuXHJcbiAgICBjb25zdCB3aWR0aFB4ID1cclxuICAgICAgcGFyc2VGbG9hdCh3aW5kb3cuZ2V0Q29tcHV0ZWRTdHlsZShnZXRMaWtlQnV0dG9uKCkpLndpZHRoKSArXHJcbiAgICAgIHBhcnNlRmxvYXQod2luZG93LmdldENvbXB1dGVkU3R5bGUoZ2V0RGlzbGlrZUJ1dHRvbigpKS53aWR0aCkgK1xyXG4gICAgICAoaXNSb3VuZGVkRGVzaWduKCkgPyAwIDogOCk7XHJcblxyXG4gICAgY29uc3Qgd2lkdGhQZXJjZW50ID1cclxuICAgICAgbGlrZXMgKyBkaXNsaWtlcyA+IDAgPyAobGlrZXMgLyAobGlrZXMgKyBkaXNsaWtlcykpICogMTAwIDogNTA7XHJcblxyXG4gICAgdmFyIGxpa2VQZXJjZW50YWdlID0gcGFyc2VGbG9hdCh3aWR0aFBlcmNlbnQudG9GaXhlZCgxKSk7XHJcbiAgICBjb25zdCBkaXNsaWtlUGVyY2VudGFnZSA9ICgxMDAgLSBsaWtlUGVyY2VudGFnZSkudG9Mb2NhbGVTdHJpbmcoKTtcclxuICAgIGxpa2VQZXJjZW50YWdlID0gbGlrZVBlcmNlbnRhZ2UudG9Mb2NhbGVTdHJpbmcoKTtcclxuXHJcbiAgICBpZiAoZXh0Q29uZmlnLnNob3dUb29sdGlwUGVyY2VudGFnZSkge1xyXG4gICAgICB2YXIgdG9vbHRpcElubmVySFRNTDtcclxuICAgICAgc3dpdGNoIChleHRDb25maWcudG9vbHRpcFBlcmNlbnRhZ2VNb2RlKSB7XHJcbiAgICAgICAgY2FzZSBcImRhc2hfZGlzbGlrZVwiOlxyXG4gICAgICAgICAgdG9vbHRpcElubmVySFRNTCA9IGAke2xpa2VzLnRvTG9jYWxlU3RyaW5nKCl9Jm5ic3A7LyZuYnNwOyR7ZGlzbGlrZXMudG9Mb2NhbGVTdHJpbmcoKX0mbmJzcDsmbmJzcDstJm5ic3A7Jm5ic3A7JHtkaXNsaWtlUGVyY2VudGFnZX0lYDtcclxuICAgICAgICAgIGJyZWFrO1xyXG4gICAgICAgIGNhc2UgXCJib3RoXCI6XHJcbiAgICAgICAgICB0b29sdGlwSW5uZXJIVE1MID0gYCR7bGlrZVBlcmNlbnRhZ2V9JSZuYnNwOy8mbmJzcDske2Rpc2xpa2VQZXJjZW50YWdlfSVgO1xyXG4gICAgICAgICAgYnJlYWs7XHJcbiAgICAgICAgY2FzZSBcIm9ubHlfbGlrZVwiOlxyXG4gICAgICAgICAgdG9vbHRpcElubmVySFRNTCA9IGAke2xpa2VQZXJjZW50YWdlfSVgO1xyXG4gICAgICAgICAgYnJlYWs7XHJcbiAgICAgICAgY2FzZSBcIm9ubHlfZGlzbGlrZVwiOlxyXG4gICAgICAgICAgdG9vbHRpcElubmVySFRNTCA9IGAke2Rpc2xpa2VQZXJjZW50YWdlfSVgO1xyXG4gICAgICAgICAgYnJlYWs7XHJcbiAgICAgICAgZGVmYXVsdDogLy8gZGFzaF9saWtlXHJcbiAgICAgICAgICB0b29sdGlwSW5uZXJIVE1MID0gYCR7bGlrZXMudG9Mb2NhbGVTdHJpbmcoKX0mbmJzcDsvJm5ic3A7JHtkaXNsaWtlcy50b0xvY2FsZVN0cmluZygpfSZuYnNwOyZuYnNwOy0mbmJzcDsmbmJzcDske2xpa2VQZXJjZW50YWdlfSVgO1xyXG4gICAgICB9XHJcbiAgICB9IGVsc2Uge1xyXG4gICAgICB0b29sdGlwSW5uZXJIVE1MID0gYCR7bGlrZXMudG9Mb2NhbGVTdHJpbmcoKX0mbmJzcDsvJm5ic3A7JHtkaXNsaWtlcy50b0xvY2FsZVN0cmluZygpfWA7XHJcbiAgICB9XHJcblxyXG4gICAgaWYgKCFpc1Nob3J0cygpKSB7XHJcbiAgICAgIGlmICghcmF0ZUJhciAmJiAhaXNNb2JpbGUoKSkge1xyXG4gICAgICAgIGxldCBjb2xvckxpa2VTdHlsZSA9IFwiXCI7XHJcbiAgICAgICAgbGV0IGNvbG9yRGlzbGlrZVN0eWxlID0gXCJcIjtcclxuICAgICAgICBpZiAoZXh0Q29uZmlnLmNvbG9yZWRCYXIpIHtcclxuICAgICAgICAgIGNvbG9yTGlrZVN0eWxlID0gXCI7IGJhY2tncm91bmQtY29sb3I6IFwiICsgZ2V0Q29sb3JGcm9tVGhlbWUodHJ1ZSk7XHJcbiAgICAgICAgICBjb2xvckRpc2xpa2VTdHlsZSA9IFwiOyBiYWNrZ3JvdW5kLWNvbG9yOiBcIiArIGdldENvbG9yRnJvbVRoZW1lKGZhbHNlKTtcclxuICAgICAgICB9XHJcbiAgICAgICAgbGV0IGFjdGlvbnMgPVxyXG4gICAgICAgICAgaXNOZXdEZXNpZ24oKSAmJiBnZXRCdXR0b25zKCkuaWQgPT09IFwidG9wLWxldmVsLWJ1dHRvbnMtY29tcHV0ZWRcIlxyXG4gICAgICAgICAgICA/IGdldEJ1dHRvbnMoKVxyXG4gICAgICAgICAgICA6IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwibWVudS1jb250YWluZXJcIik7XHJcbiAgICAgICAgKFxyXG4gICAgICAgICAgYWN0aW9ucyB8fFxyXG4gICAgICAgICAgZG9jdW1lbnQucXVlcnlTZWxlY3RvcihcInl0bS1zbGltLXZpZGVvLWFjdGlvbi1iYXItcmVuZGVyZXJcIilcclxuICAgICAgICApLmluc2VydEFkamFjZW50SFRNTChcclxuICAgICAgICAgIFwiYmVmb3JlZW5kXCIsXHJcbiAgICAgICAgICBgXHJcbiAgICAgICAgICAgICAgPGRpdiBjbGFzcz1cInJ5ZC10b29sdGlwIHJ5ZC10b29sdGlwLSR7aXNOZXdEZXNpZ24oKSA/IFwibmV3XCIgOiBcIm9sZFwifS1kZXNpZ25cIiBzdHlsZT1cIndpZHRoOiAke3dpZHRoUHh9cHhcIj5cclxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzPVwicnlkLXRvb2x0aXAtYmFyLWNvbnRhaW5lclwiPlxyXG4gICAgICAgICAgICAgICAgPGRpdlxyXG4gICAgICAgICAgICAgICAgICAgIGlkPVwicnlkLWJhci1jb250YWluZXJcIlxyXG4gICAgICAgICAgICAgICAgICAgIHN0eWxlPVwid2lkdGg6IDEwMCU7IGhlaWdodDogMnB4OyR7Y29sb3JEaXNsaWtlU3R5bGV9XCJcclxuICAgICAgICAgICAgICAgICAgICA+XHJcbiAgICAgICAgICAgICAgICAgICAgPGRpdlxyXG4gICAgICAgICAgICAgICAgICAgICAgaWQ9XCJyeWQtYmFyXCJcclxuICAgICAgICAgICAgICAgICAgICAgIHN0eWxlPVwid2lkdGg6ICR7d2lkdGhQZXJjZW50fSU7IGhlaWdodDogMTAwJSR7Y29sb3JMaWtlU3R5bGV9XCJcclxuICAgICAgICAgICAgICAgICAgICAgID48L2Rpdj5cclxuICAgICAgICAgICAgICAgIDwvZGl2PlxyXG4gICAgICAgICAgICAgIDwvZGl2PlxyXG4gICAgICAgICAgICAgIDx0cC15dC1wYXBlci10b29sdGlwIHBvc2l0aW9uPVwidG9wXCIgaWQ9XCJyeWQtZGlzbGlrZS10b29sdGlwXCIgY2xhc3M9XCJzdHlsZS1zY29wZSB5dGQtc2VudGltZW50LWJhci1yZW5kZXJlclwiIHJvbGU9XCJ0b29sdGlwXCIgdGFiaW5kZXg9XCItMVwiPlxyXG4gICAgICAgICAgICAgICAgPCEtLWNzcy1idWlsZDpzaGFkeS0tPiR7dG9vbHRpcElubmVySFRNTH1cclxuICAgICAgICAgICAgICA8L3RwLXl0LXBhcGVyLXRvb2x0aXA+XHJcbiAgICAgICAgICAgICAgPC9kaXY+XHJcbiAgICAgIFx0XHRgLFxyXG4gICAgICAgICk7XHJcblxyXG4gICAgICAgIGlmIChpc05ld0Rlc2lnbigpKSB7XHJcbiAgICAgICAgICAvLyBBZGQgYm9yZGVyIGJldHdlZW4gaW5mbyBhbmQgY29tbWVudHNcclxuICAgICAgICAgIGxldCBkZXNjcmlwdGlvbkFuZEFjdGlvbnNFbGVtZW50ID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoXCJ0b3Atcm93XCIpO1xyXG4gICAgICAgICAgZGVzY3JpcHRpb25BbmRBY3Rpb25zRWxlbWVudC5zdHlsZS5ib3JkZXJCb3R0b20gPVxyXG4gICAgICAgICAgICBcIjFweCBzb2xpZCB2YXIoLS15dC1zcGVjLTEwLXBlcmNlbnQtbGF5ZXIpXCI7XHJcbiAgICAgICAgICBkZXNjcmlwdGlvbkFuZEFjdGlvbnNFbGVtZW50LnN0eWxlLnBhZGRpbmdCb3R0b20gPSBcIjEwcHhcIjtcclxuXHJcbiAgICAgICAgICAvLyBGaXggbGlrZS9kaXNsaWtlIHJhdGlvIGJhciBvZmZzZXQgaW4gbmV3IFVJXHJcbiAgICAgICAgICBkb2N1bWVudC5nZXRFbGVtZW50QnlJZChcImFjdGlvbnMtaW5uZXJcIikuc3R5bGUud2lkdGggPSBcInJldmVydFwiO1xyXG4gICAgICAgICAgaWYgKGlzUm91bmRlZERlc2lnbigpKSB7XHJcbiAgICAgICAgICAgIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwiYWN0aW9uc1wiKS5zdHlsZS5mbGV4RGlyZWN0aW9uID1cclxuICAgICAgICAgICAgICBcInJvdy1yZXZlcnNlXCI7XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgfVxyXG4gICAgICB9IGVsc2Uge1xyXG4gICAgICAgIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoYC5yeWQtdG9vbHRpcGApLnN0eWxlLndpZHRoID0gd2lkdGhQeCArIFwicHhcIjtcclxuICAgICAgICBkb2N1bWVudC5nZXRFbGVtZW50QnlJZChcInJ5ZC1iYXJcIikuc3R5bGUud2lkdGggPSB3aWR0aFBlcmNlbnQgKyBcIiVcIjtcclxuICAgICAgICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKFwiI3J5ZC1kaXNsaWtlLXRvb2x0aXAgPiAjdG9vbHRpcFwiKS5pbm5lckhUTUwgPVxyXG4gICAgICAgICAgdG9vbHRpcElubmVySFRNTDtcclxuICAgICAgICBpZiAoZXh0Q29uZmlnLmNvbG9yZWRCYXIpIHtcclxuICAgICAgICAgIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwicnlkLWJhci1jb250YWluZXJcIikuc3R5bGUuYmFja2dyb3VuZENvbG9yID1cclxuICAgICAgICAgICAgZ2V0Q29sb3JGcm9tVGhlbWUoZmFsc2UpO1xyXG4gICAgICAgICAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoXCJyeWQtYmFyXCIpLnN0eWxlLmJhY2tncm91bmRDb2xvciA9XHJcbiAgICAgICAgICAgIGdldENvbG9yRnJvbVRoZW1lKHRydWUpO1xyXG4gICAgICAgIH1cclxuICAgICAgfVxyXG4gICAgfVxyXG4gIH0gZWxzZSB7XHJcbiAgICBjb25zb2xlLmxvZyhcInJlbW92aW5nIGJhclwiKTtcclxuICAgIGlmIChyYXRlQmFyKSB7XHJcbiAgICAgIHJhdGVCYXIucGFyZW50Tm9kZS5yZW1vdmVDaGlsZChyYXRlQmFyKTtcclxuICAgIH1cclxuICB9XHJcbn1cclxuXHJcbmV4cG9ydCB7IGNyZWF0ZVJhdGVCYXIgfTtcclxuIiwiaW1wb3J0IHsgZ2V0TGlrZUJ1dHRvbiwgZ2V0RGlzbGlrZUJ1dHRvbiwgZ2V0QnV0dG9ucywgZ2V0TGlrZVRleHRDb250YWluZXIsIGdldERpc2xpa2VUZXh0Q29udGFpbmVyIH0gZnJvbSBcIi4vYnV0dG9uc1wiO1xyXG5pbXBvcnQgeyBjcmVhdGVSYXRlQmFyIH0gZnJvbSBcIi4vYmFyXCI7XHJcbmltcG9ydCB7XHJcbiAgZ2V0QnJvd3NlcixcclxuICBnZXRWaWRlb0lkLFxyXG4gIGluaXRpYWxpemVMb2dnaW5nLFxyXG4gIG51bWJlckZvcm1hdCxcclxuICBnZXRDb2xvckZyb21UaGVtZSxcclxuICBxdWVyeVNlbGVjdG9yLFxyXG4gIGxvY2FsaXplLFxyXG4gIGNyZWF0ZU9ic2VydmVyLFxyXG59IGZyb20gXCIuL3V0aWxzXCI7XHJcbmltcG9ydCB7IGNvbmZpZywgZ2V0QXBpRW5kcG9pbnQsIERFVl9BUElfVVJMLCBQUk9EX0FQSV9VUkwsIGlzRGV2ZWxvcG1lbnQgfSBmcm9tIFwiLi9jb25maWdcIjtcclxuY29uc3QgTElLRURfU1RBVEUgPSBcIkxJS0VEX1NUQVRFXCI7XHJcbmNvbnN0IERJU0xJS0VEX1NUQVRFID0gXCJESVNMSUtFRF9TVEFURVwiO1xyXG5jb25zdCBORVVUUkFMX1NUQVRFID0gXCJORVVUUkFMX1NUQVRFXCI7XHJcblxyXG5sZXQgZXh0Q29uZmlnID0ge1xyXG4gIGRpc2FibGVWb3RlU3VibWlzc2lvbjogZmFsc2UsXHJcbiAgZGlzYWJsZUxvZ2dpbmc6IGZhbHNlLFxyXG4gIGNvbG9yZWRUaHVtYnM6IGZhbHNlLFxyXG4gIGNvbG9yZWRCYXI6IGZhbHNlLFxyXG4gIGNvbG9yVGhlbWU6IFwiY2xhc3NpY1wiLFxyXG4gIG51bWJlckRpc3BsYXlGb3JtYXQ6IFwiY29tcGFjdFNob3J0XCIsXHJcbiAgc2hvd1Rvb2x0aXBQZXJjZW50YWdlOiBmYWxzZSxcclxuICB0b29sdGlwUGVyY2VudGFnZU1vZGU6IFwiZGFzaF9saWtlXCIsXHJcbiAgbnVtYmVyRGlzcGxheVJlZm9ybWF0TGlrZXM6IGZhbHNlLFxyXG4gIGhpZGVQcmVtaXVtVGVhc2VyOiBmYWxzZSxcclxuICBzZWxlY3RvcnM6IHtcclxuICAgIGRpc2xpa2VUZXh0Q29udGFpbmVyOiBbXSxcclxuICAgIGxpa2VUZXh0Q29udGFpbmVyOiBbXSxcclxuICAgIGJ1dHRvbnM6IHtcclxuICAgICAgc2hvcnRzOiB7XHJcbiAgICAgICAgbW9iaWxlOiBbXSxcclxuICAgICAgICBkZXNrdG9wOiBbXSxcclxuICAgICAgfSxcclxuICAgICAgcmVndWxhcjoge1xyXG4gICAgICAgIG1vYmlsZTogW10sXHJcbiAgICAgICAgZGVza3RvcE1lbnU6IFtdLFxyXG4gICAgICAgIGRlc2t0b3BOb01lbnU6IFtdLFxyXG4gICAgICB9LFxyXG4gICAgICBsaWtlQnV0dG9uOiB7XHJcbiAgICAgICAgc2VnbWVudGVkOiBbXSxcclxuICAgICAgICBzZWdtZW50ZWRHZXRCdXR0b25zOiBbXSxcclxuICAgICAgICBub3RTZWdtZW50ZWQ6IFtdLFxyXG4gICAgICB9LFxyXG4gICAgICBkaXNsaWtlQnV0dG9uOiB7XHJcbiAgICAgICAgc2VnbWVudGVkOiBbXSxcclxuICAgICAgICBzZWdtZW50ZWRHZXRCdXR0b25zOiBbXSxcclxuICAgICAgICBub3RTZWdtZW50ZWQ6IFtdLFxyXG4gICAgICB9LFxyXG4gICAgfSxcclxuICAgIG1lbnVDb250YWluZXI6IFtdLFxyXG4gICAgcm91bmRlZERlc2lnbjogW10sXHJcbiAgfSxcclxufTtcclxuXHJcbmxldCBzdG9yZWREYXRhID0ge1xyXG4gIGxpa2VzOiAwLFxyXG4gIGRpc2xpa2VzOiAwLFxyXG4gIHByZXZpb3VzU3RhdGU6IE5FVVRSQUxfU1RBVEUsXHJcbn07XHJcblxyXG5mdW5jdGlvbiBpc01vYmlsZSgpIHtcclxuICByZXR1cm4gbG9jYXRpb24uaG9zdG5hbWUgPT0gXCJtLnlvdXR1YmUuY29tXCI7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGlzU2hvcnRzKCkge1xyXG4gIHJldHVybiBsb2NhdGlvbi5wYXRobmFtZS5zdGFydHNXaXRoKFwiL3Nob3J0c1wiKTtcclxufVxyXG5cclxuZnVuY3Rpb24gaXNOZXdEZXNpZ24oKSB7XHJcbiAgcmV0dXJuIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwiY29tbWVudC10ZWFzZXJcIikgIT09IG51bGw7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGlzUm91bmRlZERlc2lnbigpIHtcclxuICByZXR1cm4gcXVlcnlTZWxlY3RvcihleHRDb25maWcuc2VsZWN0b3JzLnJvdW5kZWREZXNpZ24pICE9PSBudWxsO1xyXG59XHJcblxyXG5sZXQgc2hvcnRzT2JzZXJ2ZXIgPSBudWxsO1xyXG5cclxuaWYgKGlzU2hvcnRzKCkgJiYgIXNob3J0c09ic2VydmVyKSB7XHJcbiAgY29uc29sZS5sb2coXCJJbml0aWFsaXppbmcgc2hvcnRzIG11dGF0aW9uIG9ic2VydmVyXCIpO1xyXG4gIHNob3J0c09ic2VydmVyID0gY3JlYXRlT2JzZXJ2ZXIoXHJcbiAgICB7XHJcbiAgICAgIGF0dHJpYnV0ZXM6IHRydWUsXHJcbiAgICB9LFxyXG4gICAgKG11dGF0aW9uTGlzdCkgPT4ge1xyXG4gICAgICBtdXRhdGlvbkxpc3QuZm9yRWFjaCgobXV0YXRpb24pID0+IHtcclxuICAgICAgICBpZiAoXHJcbiAgICAgICAgICBtdXRhdGlvbi50eXBlID09PSBcImF0dHJpYnV0ZXNcIiAmJlxyXG4gICAgICAgICAgbXV0YXRpb24udGFyZ2V0Lm5vZGVOYW1lID09PSBcIlRQLVlULVBBUEVSLUJVVFRPTlwiICYmXHJcbiAgICAgICAgICBtdXRhdGlvbi50YXJnZXQuaWQgPT09IFwiYnV0dG9uXCJcclxuICAgICAgICApIHtcclxuICAgICAgICAgIC8vIGNvbnNvbGUubG9nKCdTaG9ydCB0aHVtYiBidXR0b24gc3RhdHVzIGNoYW5nZWQnKTtcclxuICAgICAgICAgIGlmIChtdXRhdGlvbi50YXJnZXQuZ2V0QXR0cmlidXRlKFwiYXJpYS1wcmVzc2VkXCIpID09PSBcInRydWVcIikge1xyXG4gICAgICAgICAgICBtdXRhdGlvbi50YXJnZXQuc3R5bGUuY29sb3IgPVxyXG4gICAgICAgICAgICAgIG11dGF0aW9uLnRhcmdldC5wYXJlbnRFbGVtZW50LnBhcmVudEVsZW1lbnQuaWQgPT09IFwibGlrZS1idXR0b25cIlxyXG4gICAgICAgICAgICAgICAgPyBnZXRDb2xvckZyb21UaGVtZSh0cnVlKVxyXG4gICAgICAgICAgICAgICAgOiBnZXRDb2xvckZyb21UaGVtZShmYWxzZSk7XHJcbiAgICAgICAgICB9IGVsc2Uge1xyXG4gICAgICAgICAgICBtdXRhdGlvbi50YXJnZXQuc3R5bGUuY29sb3IgPSBcInVuc2V0XCI7XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgICByZXR1cm47XHJcbiAgICAgICAgfVxyXG4gICAgICAgIGNvbnNvbGUubG9nKFwiVW5leHBlY3RlZCBtdXRhdGlvbiBvYnNlcnZlciBldmVudDogXCIgKyBtdXRhdGlvbi50YXJnZXQgKyBtdXRhdGlvbi50eXBlKTtcclxuICAgICAgfSk7XHJcbiAgICB9LFxyXG4gICk7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGlzTGlrZXNEaXNhYmxlZCgpIHtcclxuICAvLyByZXR1cm4gdHJ1ZSBpZiB0aGUgbGlrZSBidXR0b24ncyB0ZXh0IGRvZXNuJ3QgY29udGFpbiBhbnkgbnVtYmVyXHJcbiAgaWYgKGlzTW9iaWxlKCkpIHtcclxuICAgIHJldHVybiAvXlxcRCokLy50ZXN0KGdldEJ1dHRvbnMoKS5jaGlsZHJlblswXS5xdWVyeVNlbGVjdG9yKFwiLmJ1dHRvbi1yZW5kZXJlci10ZXh0XCIpLmlubmVyVGV4dCk7XHJcbiAgfVxyXG4gIHJldHVybiAvXlxcRCokLy50ZXN0KGdldExpa2VUZXh0Q29udGFpbmVyKCkuaW5uZXJUZXh0KTtcclxufVxyXG5cclxuZnVuY3Rpb24gaXNWaWRlb0xpa2VkKCkge1xyXG4gIGlmIChpc01vYmlsZSgpKSB7XHJcbiAgICByZXR1cm4gZ2V0TGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJidXR0b25cIikuZ2V0QXR0cmlidXRlKFwiYXJpYS1sYWJlbFwiKSA9PT0gXCJ0cnVlXCI7XHJcbiAgfVxyXG4gIHJldHVybiAoXHJcbiAgICBnZXRMaWtlQnV0dG9uKCkuY2xhc3NMaXN0LmNvbnRhaW5zKFwic3R5bGUtZGVmYXVsdC1hY3RpdmVcIikgfHxcclxuICAgIGdldExpa2VCdXR0b24oKS5xdWVyeVNlbGVjdG9yKFwiYnV0dG9uXCIpPy5nZXRBdHRyaWJ1dGUoXCJhcmlhLXByZXNzZWRcIikgPT09IFwidHJ1ZVwiXHJcbiAgKTtcclxufVxyXG5cclxuZnVuY3Rpb24gaXNWaWRlb0Rpc2xpa2VkKCkge1xyXG4gIGlmIChpc01vYmlsZSgpKSB7XHJcbiAgICByZXR1cm4gZ2V0RGlzbGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJidXR0b25cIikuZ2V0QXR0cmlidXRlKFwiYXJpYS1sYWJlbFwiKSA9PT0gXCJ0cnVlXCI7XHJcbiAgfVxyXG4gIHJldHVybiAoXHJcbiAgICBnZXREaXNsaWtlQnV0dG9uKCkuY2xhc3NMaXN0LmNvbnRhaW5zKFwic3R5bGUtZGVmYXVsdC1hY3RpdmVcIikgfHxcclxuICAgIGdldERpc2xpa2VCdXR0b24oKS5xdWVyeVNlbGVjdG9yKFwiYnV0dG9uXCIpPy5nZXRBdHRyaWJ1dGUoXCJhcmlhLXByZXNzZWRcIikgPT09IFwidHJ1ZVwiXHJcbiAgKTtcclxufVxyXG5cclxuZnVuY3Rpb24gZ2V0U3RhdGUoc3RvcmVkRGF0YSkge1xyXG4gIGlmIChpc1ZpZGVvTGlrZWQoKSkge1xyXG4gICAgcmV0dXJuIHsgY3VycmVudDogTElLRURfU1RBVEUsIHByZXZpb3VzOiBzdG9yZWREYXRhLnByZXZpb3VzU3RhdGUgfTtcclxuICB9XHJcbiAgaWYgKGlzVmlkZW9EaXNsaWtlZCgpKSB7XHJcbiAgICByZXR1cm4geyBjdXJyZW50OiBESVNMSUtFRF9TVEFURSwgcHJldmlvdXM6IHN0b3JlZERhdGEucHJldmlvdXNTdGF0ZSB9O1xyXG4gIH1cclxuICByZXR1cm4geyBjdXJyZW50OiBORVVUUkFMX1NUQVRFLCBwcmV2aW91czogc3RvcmVkRGF0YS5wcmV2aW91c1N0YXRlIH07XHJcbn1cclxuXHJcbi8vLS0tICAgU2V0cyBUaGUgTGlrZXMgQW5kIERpc2xpa2VzIFZhbHVlcyAgIC0tLS8vXHJcbmZ1bmN0aW9uIHNldExpa2VzKGxpa2VzQ291bnQpIHtcclxuICBjb25zb2xlLmxvZyhgU0VUIGxpa2VzICR7bGlrZXNDb3VudH1gKTtcclxuICBnZXRMaWtlVGV4dENvbnRhaW5lcigpLmlubmVyVGV4dCA9IGxpa2VzQ291bnQ7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIHNldERpc2xpa2VzKGRpc2xpa2VzQ291bnQpIHtcclxuICBjb25zb2xlLmxvZyhgU0VUIGRpc2xpa2VzICR7ZGlzbGlrZXNDb3VudH1gKTtcclxuXHJcbiAgY29uc3QgX2NvbnRhaW5lciA9IGdldERpc2xpa2VUZXh0Q29udGFpbmVyKCk7XHJcbiAgX2NvbnRhaW5lcj8ucmVtb3ZlQXR0cmlidXRlKFwiaXMtZW1wdHlcIik7XHJcblxyXG4gIGxldCBfZGlzbGlrZVRleHQ7XHJcbiAgaWYgKCFpc0xpa2VzRGlzYWJsZWQoKSkge1xyXG4gICAgaWYgKGlzTW9iaWxlKCkpIHtcclxuICAgICAgZ2V0QnV0dG9ucygpLmNoaWxkcmVuWzFdLnF1ZXJ5U2VsZWN0b3IoXCIuYnV0dG9uLXJlbmRlcmVyLXRleHRcIikuaW5uZXJUZXh0ID0gZGlzbGlrZXNDb3VudDtcclxuICAgICAgcmV0dXJuO1xyXG4gICAgfVxyXG4gICAgX2Rpc2xpa2VUZXh0ID0gZGlzbGlrZXNDb3VudDtcclxuICB9IGVsc2Uge1xyXG4gICAgY29uc29sZS5sb2coXCJsaWtlcyBjb3VudCBkaXNhYmxlZCBieSBjcmVhdG9yXCIpO1xyXG4gICAgaWYgKGlzTW9iaWxlKCkpIHtcclxuICAgICAgZ2V0QnV0dG9ucygpLmNoaWxkcmVuWzFdLnF1ZXJ5U2VsZWN0b3IoXCIuYnV0dG9uLXJlbmRlcmVyLXRleHRcIikuaW5uZXJUZXh0ID0gbG9jYWxpemUoXCJUZXh0TGlrZXNEaXNhYmxlZFwiKTtcclxuICAgICAgcmV0dXJuO1xyXG4gICAgfVxyXG4gICAgX2Rpc2xpa2VUZXh0ID0gbG9jYWxpemUoXCJUZXh0TGlrZXNEaXNhYmxlZFwiKTtcclxuICB9XHJcblxyXG4gIGlmIChfZGlzbGlrZVRleHQgIT0gbnVsbCAmJiBfY29udGFpbmVyPy5pbm5lclRleHQgIT09IF9kaXNsaWtlVGV4dCkge1xyXG4gICAgX2NvbnRhaW5lci5pbm5lclRleHQgPSBfZGlzbGlrZVRleHQ7XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBnZXRMaWtlQ291bnRGcm9tQnV0dG9uKCkge1xyXG4gIHRyeSB7XHJcbiAgICBpZiAoaXNTaG9ydHMoKSkge1xyXG4gICAgICAvL1lvdXR1YmUgU2hvcnRzIGRvbid0IHdvcmsgd2l0aCB0aGlzIHF1ZXJ5LiBJdCdzIG5vdCBuZWNlc3Nhcnk7IHdlIGNhbiBza2lwIGl0IGFuZCBzdGlsbCBzZWUgdGhlIHJlc3VsdHMuXHJcbiAgICAgIC8vSXQgc2hvdWxkIGJlIHBvc3NpYmxlIHRvIGZpeCB0aGlzIGZ1bmN0aW9uLCBidXQgaXQncyBub3QgY3JpdGljYWwgdG8gc2hvd2luZyB0aGUgZGlzbGlrZSBjb3VudC5cclxuICAgICAgcmV0dXJuIGZhbHNlO1xyXG4gICAgfVxyXG5cclxuICAgIGxldCBsaWtlQnV0dG9uID1cclxuICAgICAgZ2V0TGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJ5dC1mb3JtYXR0ZWQtc3RyaW5nI3RleHRcIikgPz8gZ2V0TGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJidXR0b25cIik7XHJcblxyXG4gICAgbGV0IGxpa2VzU3RyID0gbGlrZUJ1dHRvbi5nZXRBdHRyaWJ1dGUoXCJhcmlhLWxhYmVsXCIpLnJlcGxhY2UoL1xcRC9nLCBcIlwiKTtcclxuICAgIHJldHVybiBsaWtlc1N0ci5sZW5ndGggPiAwID8gcGFyc2VJbnQobGlrZXNTdHIpIDogZmFsc2U7XHJcbiAgfSBjYXRjaCB7XHJcbiAgICByZXR1cm4gZmFsc2U7XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBwcm9jZXNzUmVzcG9uc2UocmVzcG9uc2UsIHN0b3JlZERhdGEpIHtcclxuICBjb25zdCBmb3JtYXR0ZWREaXNsaWtlID0gbnVtYmVyRm9ybWF0KHJlc3BvbnNlLmRpc2xpa2VzKTtcclxuICBzZXREaXNsaWtlcyhmb3JtYXR0ZWREaXNsaWtlKTtcclxuICBpZiAoZXh0Q29uZmlnLm51bWJlckRpc3BsYXlSZWZvcm1hdExpa2VzID09PSB0cnVlKSB7XHJcbiAgICBjb25zdCBuYXRpdmVMaWtlcyA9IGdldExpa2VDb3VudEZyb21CdXR0b24oKTtcclxuICAgIGlmIChuYXRpdmVMaWtlcyAhPT0gZmFsc2UpIHtcclxuICAgICAgc2V0TGlrZXMobnVtYmVyRm9ybWF0KG5hdGl2ZUxpa2VzKSk7XHJcbiAgICB9XHJcbiAgfVxyXG4gIHN0b3JlZERhdGEuZGlzbGlrZXMgPSBwYXJzZUludChyZXNwb25zZS5kaXNsaWtlcyk7XHJcbiAgc3RvcmVkRGF0YS5saWtlcyA9IGdldExpa2VDb3VudEZyb21CdXR0b24oKSB8fCBwYXJzZUludChyZXNwb25zZS5saWtlcyk7XHJcbiAgY3JlYXRlUmF0ZUJhcihzdG9yZWREYXRhLmxpa2VzLCBzdG9yZWREYXRhLmRpc2xpa2VzKTtcclxuICBpZiAoZXh0Q29uZmlnLmNvbG9yZWRUaHVtYnMgPT09IHRydWUpIHtcclxuICAgIGlmIChpc1Nob3J0cygpKSB7XHJcbiAgICAgIC8vIGZvciBzaG9ydHMsIGxlYXZlIGRlYWN0aXZhdGVkIGJ1dHRvbnMgaW4gZGVmYXVsdCBjb2xvclxyXG4gICAgICBsZXQgc2hvcnRMaWtlQnV0dG9uID0gZ2V0TGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJ0cC15dC1wYXBlci1idXR0b24jYnV0dG9uXCIpO1xyXG4gICAgICBsZXQgc2hvcnREaXNsaWtlQnV0dG9uID0gZ2V0RGlzbGlrZUJ1dHRvbigpLnF1ZXJ5U2VsZWN0b3IoXCJ0cC15dC1wYXBlci1idXR0b24jYnV0dG9uXCIpO1xyXG4gICAgICBpZiAoc2hvcnRMaWtlQnV0dG9uLmdldEF0dHJpYnV0ZShcImFyaWEtcHJlc3NlZFwiKSA9PT0gXCJ0cnVlXCIpIHtcclxuICAgICAgICBzaG9ydExpa2VCdXR0b24uc3R5bGUuY29sb3IgPSBnZXRDb2xvckZyb21UaGVtZSh0cnVlKTtcclxuICAgICAgfVxyXG4gICAgICBpZiAoc2hvcnREaXNsaWtlQnV0dG9uLmdldEF0dHJpYnV0ZShcImFyaWEtcHJlc3NlZFwiKSA9PT0gXCJ0cnVlXCIpIHtcclxuICAgICAgICBzaG9ydERpc2xpa2VCdXR0b24uc3R5bGUuY29sb3IgPSBnZXRDb2xvckZyb21UaGVtZShmYWxzZSk7XHJcbiAgICAgIH1cclxuICAgICAgc2hvcnRzT2JzZXJ2ZXIub2JzZXJ2ZShzaG9ydExpa2VCdXR0b24pO1xyXG4gICAgICBzaG9ydHNPYnNlcnZlci5vYnNlcnZlKHNob3J0RGlzbGlrZUJ1dHRvbik7XHJcbiAgICB9IGVsc2Uge1xyXG4gICAgICBnZXRMaWtlQnV0dG9uKCkuc3R5bGUuY29sb3IgPSBnZXRDb2xvckZyb21UaGVtZSh0cnVlKTtcclxuICAgICAgZ2V0RGlzbGlrZUJ1dHRvbigpLnN0eWxlLmNvbG9yID0gZ2V0Q29sb3JGcm9tVGhlbWUoZmFsc2UpO1xyXG4gICAgfVxyXG4gIH1cclxuICAvL1RlbXBvcmFyeSBkaXNhYmxpbmcgdGhpcyAtIGl0IGJyZWFrcyBhbGwgcGxhY2VzIHdoZXJlIGdldEJ1dHRvbnMoKVsxXSBpcyB1c2VkXHJcbiAgLy8gY3JlYXRlU3RhclJhdGluZyhyZXNwb25zZS5yYXRpbmcsIGlzTW9iaWxlKCkpO1xyXG59XHJcblxyXG4vLyBUZWxscyB0aGUgdXNlciBpZiB0aGUgQVBJIGlzIGRvd25cclxuZnVuY3Rpb24gZGlzcGxheUVycm9yKGVycm9yKSB7XHJcbiAgZ2V0RGlzbGlrZVRleHRDb250YWluZXIoKS5pbm5lclRleHQgPSBsb2NhbGl6ZShcInRleHRUZW1wVW5hdmFpbGFibGVcIik7XHJcbn1cclxuXHJcbmFzeW5jIGZ1bmN0aW9uIHNldFN0YXRlKHN0b3JlZERhdGEpIHtcclxuICBzdG9yZWREYXRhLnByZXZpb3VzU3RhdGUgPSBpc1ZpZGVvRGlzbGlrZWQoKSA/IERJU0xJS0VEX1NUQVRFIDogaXNWaWRlb0xpa2VkKCkgPyBMSUtFRF9TVEFURSA6IE5FVVRSQUxfU1RBVEU7XHJcbiAgbGV0IHN0YXRzU2V0ID0gZmFsc2U7XHJcbiAgY29uc29sZS5sb2coXCJWaWRlbyBpcyBsb2FkZWQuIEFkZGluZyBidXR0b25zLi4uXCIpO1xyXG5cclxuICBsZXQgdmlkZW9JZCA9IGdldFZpZGVvSWQod2luZG93LmxvY2F0aW9uLmhyZWYpO1xyXG4gIGxldCBsaWtlQ291bnQgPSBnZXRMaWtlQ291bnRGcm9tQnV0dG9uKCkgfHwgbnVsbDtcclxuXHJcbiAgbGV0IHJlc3BvbnNlID0gYXdhaXQgZmV0Y2goZ2V0QXBpRW5kcG9pbnQoYC92b3Rlcz92aWRlb0lkPSR7dmlkZW9JZH0mbGlrZUNvdW50PSR7bGlrZUNvdW50IHx8IFwiXCJ9YCksIHtcclxuICAgIG1ldGhvZDogXCJHRVRcIixcclxuICAgIGhlYWRlcnM6IHtcclxuICAgICAgQWNjZXB0OiBcImFwcGxpY2F0aW9uL2pzb25cIixcclxuICAgIH0sXHJcbiAgfSlcclxuICAgIC50aGVuKChyZXNwb25zZSkgPT4ge1xyXG4gICAgICBpZiAoIXJlc3BvbnNlLm9rKSBkaXNwbGF5RXJyb3IocmVzcG9uc2UuZXJyb3IpO1xyXG4gICAgICByZXR1cm4gcmVzcG9uc2U7XHJcbiAgICB9KVxyXG4gICAgLnRoZW4oKHJlc3BvbnNlKSA9PiByZXNwb25zZS5qc29uKCkpXHJcbiAgICAuY2F0Y2goZGlzcGxheUVycm9yKTtcclxuICBjb25zb2xlLmxvZyhcInJlc3BvbnNlIGZyb20gYXBpOlwiKTtcclxuICBjb25zb2xlLmxvZyhKU09OLnN0cmluZ2lmeShyZXNwb25zZSkpO1xyXG4gIGlmIChyZXNwb25zZSAhPT0gdW5kZWZpbmVkICYmICEoXCJ0cmFjZUlkXCIgaW4gcmVzcG9uc2UpICYmICFzdGF0c1NldCkge1xyXG4gICAgcHJvY2Vzc1Jlc3BvbnNlKHJlc3BvbnNlLCBzdG9yZWREYXRhKTtcclxuICB9XHJcbn1cclxuXHJcbmFzeW5jIGZ1bmN0aW9uIHNldEluaXRpYWxTdGF0ZSgpIHtcclxuICBhd2FpdCBzZXRTdGF0ZShzdG9yZWREYXRhKTtcclxufVxyXG5cclxuYXN5bmMgZnVuY3Rpb24gaW5pdEV4dENvbmZpZygpIHtcclxuICBpbml0aWFsaXplRGlzYWJsZVZvdGVTdWJtaXNzaW9uKCk7XHJcbiAgaW5pdGlhbGl6ZURpc2FibGVMb2dnaW5nKCk7XHJcbiAgaW5pdGlhbGl6ZUNvbG9yZWRUaHVtYnMoKTtcclxuICBpbml0aWFsaXplQ29sb3JlZEJhcigpO1xyXG4gIGluaXRpYWxpemVDb2xvclRoZW1lKCk7XHJcbiAgaW5pdGlhbGl6ZU51bWJlckRpc3BsYXlGb3JtYXQoKTtcclxuICBpbml0aWFsaXplVG9vbHRpcFBlcmNlbnRhZ2UoKTtcclxuICBpbml0aWFsaXplVG9vbHRpcFBlcmNlbnRhZ2VNb2RlKCk7XHJcbiAgaW5pdGlhbGl6ZU51bWJlckRpc3BsYXlSZWZvcm1hdExpa2VzKCk7XHJcbiAgaW5pdGlhbGl6ZUhpZGVQcmVtaXVtVGVhc2VyKCk7XHJcbiAgYXdhaXQgaW5pdGlhbGl6ZVNlbGVjdG9ycygpO1xyXG59XHJcblxyXG5hc3luYyBmdW5jdGlvbiBpbml0aWFsaXplU2VsZWN0b3JzKCkge1xyXG4gIGxldCByZXN1bHQgPSBhd2FpdCBmZXRjaChnZXRBcGlFbmRwb2ludChcIi9jb25maWdzL3NlbGVjdG9yc1wiKSwge1xyXG4gICAgbWV0aG9kOiBcIkdFVFwiLFxyXG4gICAgaGVhZGVyczoge1xyXG4gICAgICBBY2NlcHQ6IFwiYXBwbGljYXRpb24vanNvblwiLFxyXG4gICAgfSxcclxuICB9KVxyXG4gICAgLnRoZW4oKHJlc3BvbnNlKSA9PiByZXNwb25zZS5qc29uKCkpXHJcbiAgICAuY2F0Y2goKGVycm9yKSA9PiB7XHJcbiAgICAgIGNvbnNvbGUuZXJyb3IoXCJFcnJvciBmZXRjaGluZyBzZWxlY3RvcnM6XCIsIGVycm9yKTtcclxuICAgIH0pO1xyXG4gIGV4dENvbmZpZy5zZWxlY3RvcnMgPSByZXN1bHQgPz8gZXh0Q29uZmlnLnNlbGVjdG9ycztcclxuICBjb25zb2xlLmxvZyhyZXN1bHQpO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplRGlzYWJsZVZvdGVTdWJtaXNzaW9uKCkge1xyXG4gIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuZ2V0KFtcImRpc2FibGVWb3RlU3VibWlzc2lvblwiXSwgKHJlcykgPT4ge1xyXG4gICAgaWYgKHJlcy5kaXNhYmxlVm90ZVN1Ym1pc3Npb24gPT09IHVuZGVmaW5lZCkge1xyXG4gICAgICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLnNldCh7IGRpc2FibGVWb3RlU3VibWlzc2lvbjogZmFsc2UgfSk7XHJcbiAgICB9IGVsc2Uge1xyXG4gICAgICBleHRDb25maWcuZGlzYWJsZVZvdGVTdWJtaXNzaW9uID0gcmVzLmRpc2FibGVWb3RlU3VibWlzc2lvbjtcclxuICAgIH1cclxuICB9KTtcclxufVxyXG5cclxuZnVuY3Rpb24gaW5pdGlhbGl6ZURpc2FibGVMb2dnaW5nKCkge1xyXG4gIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuZ2V0KFtcImRpc2FibGVMb2dnaW5nXCJdLCAocmVzKSA9PiB7XHJcbiAgICBpZiAocmVzLmRpc2FibGVMb2dnaW5nID09PSB1bmRlZmluZWQpIHtcclxuICAgICAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5zZXQoeyBkaXNhYmxlTG9nZ2luZzogdHJ1ZSB9KTtcclxuICAgICAgZXh0Q29uZmlnLmRpc2FibGVMb2dnaW5nID0gdHJ1ZTtcclxuICAgIH0gZWxzZSB7XHJcbiAgICAgIGV4dENvbmZpZy5kaXNhYmxlTG9nZ2luZyA9IHJlcy5kaXNhYmxlTG9nZ2luZztcclxuICAgIH1cclxuICAgIC8vIEluaXRpYWxpemUgY29uc29sZSBtZXRob2RzIGJhc2VkIG9uIGxvZ2dpbmcgY29uZmlnXHJcbiAgICBpbml0aWFsaXplTG9nZ2luZygpO1xyXG4gIH0pO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplQ29sb3JlZFRodW1icygpIHtcclxuICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLmdldChbXCJjb2xvcmVkVGh1bWJzXCJdLCAocmVzKSA9PiB7XHJcbiAgICBpZiAocmVzLmNvbG9yZWRUaHVtYnMgPT09IHVuZGVmaW5lZCkge1xyXG4gICAgICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLnNldCh7IGNvbG9yZWRUaHVtYnM6IGZhbHNlIH0pO1xyXG4gICAgfSBlbHNlIHtcclxuICAgICAgZXh0Q29uZmlnLmNvbG9yZWRUaHVtYnMgPSByZXMuY29sb3JlZFRodW1icztcclxuICAgIH1cclxuICB9KTtcclxufVxyXG5cclxuZnVuY3Rpb24gaW5pdGlhbGl6ZUNvbG9yZWRCYXIoKSB7XHJcbiAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5nZXQoW1wiY29sb3JlZEJhclwiXSwgKHJlcykgPT4ge1xyXG4gICAgaWYgKHJlcy5jb2xvcmVkQmFyID09PSB1bmRlZmluZWQpIHtcclxuICAgICAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5zZXQoeyBjb2xvcmVkQmFyOiBmYWxzZSB9KTtcclxuICAgIH0gZWxzZSB7XHJcbiAgICAgIGV4dENvbmZpZy5jb2xvcmVkQmFyID0gcmVzLmNvbG9yZWRCYXI7XHJcbiAgICB9XHJcbiAgfSk7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGluaXRpYWxpemVDb2xvclRoZW1lKCkge1xyXG4gIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuZ2V0KFtcImNvbG9yVGhlbWVcIl0sIChyZXMpID0+IHtcclxuICAgIGlmIChyZXMuY29sb3JUaGVtZSA9PT0gdW5kZWZpbmVkKSB7XHJcbiAgICAgIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuc2V0KHsgY29sb3JUaGVtZTogZmFsc2UgfSk7XHJcbiAgICB9IGVsc2Uge1xyXG4gICAgICBleHRDb25maWcuY29sb3JUaGVtZSA9IHJlcy5jb2xvclRoZW1lO1xyXG4gICAgfVxyXG4gIH0pO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplTnVtYmVyRGlzcGxheUZvcm1hdCgpIHtcclxuICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLmdldChbXCJudW1iZXJEaXNwbGF5Rm9ybWF0XCJdLCAocmVzKSA9PiB7XHJcbiAgICBpZiAocmVzLm51bWJlckRpc3BsYXlGb3JtYXQgPT09IHVuZGVmaW5lZCkge1xyXG4gICAgICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLnNldCh7IG51bWJlckRpc3BsYXlGb3JtYXQ6IFwiY29tcGFjdFNob3J0XCIgfSk7XHJcbiAgICB9IGVsc2Uge1xyXG4gICAgICBleHRDb25maWcubnVtYmVyRGlzcGxheUZvcm1hdCA9IHJlcy5udW1iZXJEaXNwbGF5Rm9ybWF0O1xyXG4gICAgfVxyXG4gIH0pO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplVG9vbHRpcFBlcmNlbnRhZ2UoKSB7XHJcbiAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5nZXQoW1wic2hvd1Rvb2x0aXBQZXJjZW50YWdlXCJdLCAocmVzKSA9PiB7XHJcbiAgICBpZiAocmVzLnNob3dUb29sdGlwUGVyY2VudGFnZSA9PT0gdW5kZWZpbmVkKSB7XHJcbiAgICAgIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuc2V0KHsgc2hvd1Rvb2x0aXBQZXJjZW50YWdlOiBmYWxzZSB9KTtcclxuICAgIH0gZWxzZSB7XHJcbiAgICAgIGV4dENvbmZpZy5zaG93VG9vbHRpcFBlcmNlbnRhZ2UgPSByZXMuc2hvd1Rvb2x0aXBQZXJjZW50YWdlO1xyXG4gICAgfVxyXG4gIH0pO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplVG9vbHRpcFBlcmNlbnRhZ2VNb2RlKCkge1xyXG4gIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuZ2V0KFtcInRvb2x0aXBQZXJjZW50YWdlTW9kZVwiXSwgKHJlcykgPT4ge1xyXG4gICAgaWYgKHJlcy50b29sdGlwUGVyY2VudGFnZU1vZGUgPT09IHVuZGVmaW5lZCkge1xyXG4gICAgICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLnNldCh7IHRvb2x0aXBQZXJjZW50YWdlTW9kZTogXCJkYXNoX2xpa2VcIiB9KTtcclxuICAgIH0gZWxzZSB7XHJcbiAgICAgIGV4dENvbmZpZy50b29sdGlwUGVyY2VudGFnZU1vZGUgPSByZXMudG9vbHRpcFBlcmNlbnRhZ2VNb2RlO1xyXG4gICAgfVxyXG4gIH0pO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpbml0aWFsaXplTnVtYmVyRGlzcGxheVJlZm9ybWF0TGlrZXMoKSB7XHJcbiAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5nZXQoW1wibnVtYmVyRGlzcGxheVJlZm9ybWF0TGlrZXNcIl0sIChyZXMpID0+IHtcclxuICAgIGlmIChyZXMubnVtYmVyRGlzcGxheVJlZm9ybWF0TGlrZXMgPT09IHVuZGVmaW5lZCkge1xyXG4gICAgICBnZXRCcm93c2VyKCkuc3RvcmFnZS5zeW5jLnNldCh7IG51bWJlckRpc3BsYXlSZWZvcm1hdExpa2VzOiBmYWxzZSB9KTtcclxuICAgIH0gZWxzZSB7XHJcbiAgICAgIGV4dENvbmZpZy5udW1iZXJEaXNwbGF5UmVmb3JtYXRMaWtlcyA9IHJlcy5udW1iZXJEaXNwbGF5UmVmb3JtYXRMaWtlcztcclxuICAgIH1cclxuICB9KTtcclxufVxyXG5cclxuZnVuY3Rpb24gaW5pdGlhbGl6ZUhpZGVQcmVtaXVtVGVhc2VyKCkge1xyXG4gIGdldEJyb3dzZXIoKS5zdG9yYWdlLnN5bmMuZ2V0KFtcImhpZGVQcmVtaXVtVGVhc2VyXCJdLCAocmVzKSA9PiB7XHJcbiAgICBpZiAocmVzLmhpZGVQcmVtaXVtVGVhc2VyID09PSB1bmRlZmluZWQpIHtcclxuICAgICAgZ2V0QnJvd3NlcigpLnN0b3JhZ2Uuc3luYy5zZXQoeyBoaWRlUHJlbWl1bVRlYXNlcjogZmFsc2UgfSk7XHJcbiAgICAgIGV4dENvbmZpZy5oaWRlUHJlbWl1bVRlYXNlciA9IGZhbHNlO1xyXG4gICAgfSBlbHNlIHtcclxuICAgICAgZXh0Q29uZmlnLmhpZGVQcmVtaXVtVGVhc2VyID0gcmVzLmhpZGVQcmVtaXVtVGVhc2VyID09PSB0cnVlO1xyXG4gICAgfVxyXG4gIH0pO1xyXG59XHJcblxyXG5leHBvcnQge1xyXG4gIGlzTW9iaWxlLFxyXG4gIGlzU2hvcnRzLFxyXG4gIGlzVmlkZW9EaXNsaWtlZCxcclxuICBpc1ZpZGVvTGlrZWQsXHJcbiAgaXNOZXdEZXNpZ24sXHJcbiAgaXNSb3VuZGVkRGVzaWduLFxyXG4gIGdldFN0YXRlLFxyXG4gIHNldFN0YXRlLFxyXG4gIHNldEluaXRpYWxTdGF0ZSxcclxuICBzZXRMaWtlcyxcclxuICBzZXREaXNsaWtlcyxcclxuICBnZXRMaWtlQ291bnRGcm9tQnV0dG9uLFxyXG4gIExJS0VEX1NUQVRFLFxyXG4gIERJU0xJS0VEX1NUQVRFLFxyXG4gIE5FVVRSQUxfU1RBVEUsXHJcbiAgZXh0Q29uZmlnLFxyXG4gIGluaXRFeHRDb25maWcsXHJcbiAgc3RvcmVkRGF0YSxcclxuICBpc0xpa2VzRGlzYWJsZWQsXHJcbn07XHJcbiIsImltcG9ydCB7IGV4dENvbmZpZywgaXNTaG9ydHMgfSBmcm9tIFwiLi9zdGF0ZVwiO1xyXG5cclxuZnVuY3Rpb24gbnVtYmVyRm9ybWF0KG51bWJlclN0YXRlKSB7XHJcbiAgcmV0dXJuIGdldE51bWJlckZvcm1hdHRlcihleHRDb25maWcubnVtYmVyRGlzcGxheUZvcm1hdCkuZm9ybWF0KG51bWJlclN0YXRlKTtcclxufVxyXG5cclxuZnVuY3Rpb24gZ2V0TnVtYmVyRm9ybWF0dGVyKG9wdGlvblNlbGVjdCkge1xyXG4gIGxldCB1c2VyTG9jYWxlcztcclxuICBpZiAoZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50LmxhbmcpIHtcclxuICAgIHVzZXJMb2NhbGVzID0gZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50Lmxhbmc7XHJcbiAgfSBlbHNlIGlmIChuYXZpZ2F0b3IubGFuZ3VhZ2UpIHtcclxuICAgIHVzZXJMb2NhbGVzID0gbmF2aWdhdG9yLmxhbmd1YWdlO1xyXG4gIH0gZWxzZSB7XHJcbiAgICB0cnkge1xyXG4gICAgICB1c2VyTG9jYWxlcyA9IG5ldyBVUkwoXHJcbiAgICAgICAgQXJyYXkuZnJvbShkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKFwiaGVhZCA+IGxpbmtbcmVsPSdzZWFyY2gnXVwiKSlcclxuICAgICAgICAgID8uZmluZCgobikgPT4gbj8uZ2V0QXR0cmlidXRlKFwiaHJlZlwiKT8uaW5jbHVkZXMoXCI/bG9jYWxlPVwiKSlcclxuICAgICAgICAgID8uZ2V0QXR0cmlidXRlKFwiaHJlZlwiKSxcclxuICAgICAgKT8uc2VhcmNoUGFyYW1zPy5nZXQoXCJsb2NhbGVcIik7XHJcbiAgICB9IGNhdGNoIHtcclxuICAgICAgY29uc29sZS5sb2coXCJDYW5ub3QgZmluZCBicm93c2VyIGxvY2FsZS4gVXNlIGVuIGFzIGRlZmF1bHQgZm9yIG51bWJlciBmb3JtYXR0aW5nLlwiKTtcclxuICAgICAgdXNlckxvY2FsZXMgPSBcImVuXCI7XHJcbiAgICB9XHJcbiAgfVxyXG5cclxuICBsZXQgZm9ybWF0dGVyTm90YXRpb247XHJcbiAgbGV0IGZvcm1hdHRlckNvbXBhY3REaXNwbGF5O1xyXG4gIHN3aXRjaCAob3B0aW9uU2VsZWN0KSB7XHJcbiAgICBjYXNlIFwiY29tcGFjdExvbmdcIjpcclxuICAgICAgZm9ybWF0dGVyTm90YXRpb24gPSBcImNvbXBhY3RcIjtcclxuICAgICAgZm9ybWF0dGVyQ29tcGFjdERpc3BsYXkgPSBcImxvbmdcIjtcclxuICAgICAgYnJlYWs7XHJcbiAgICBjYXNlIFwic3RhbmRhcmRcIjpcclxuICAgICAgZm9ybWF0dGVyTm90YXRpb24gPSBcInN0YW5kYXJkXCI7XHJcbiAgICAgIGZvcm1hdHRlckNvbXBhY3REaXNwbGF5ID0gXCJzaG9ydFwiO1xyXG4gICAgICBicmVhaztcclxuICAgIGNhc2UgXCJjb21wYWN0U2hvcnRcIjpcclxuICAgIGRlZmF1bHQ6XHJcbiAgICAgIGZvcm1hdHRlck5vdGF0aW9uID0gXCJjb21wYWN0XCI7XHJcbiAgICAgIGZvcm1hdHRlckNvbXBhY3REaXNwbGF5ID0gXCJzaG9ydFwiO1xyXG4gIH1cclxuXHJcbiAgcmV0dXJuIEludGwuTnVtYmVyRm9ybWF0KHVzZXJMb2NhbGVzLCB7XHJcbiAgICBub3RhdGlvbjogZm9ybWF0dGVyTm90YXRpb24sXHJcbiAgICBjb21wYWN0RGlzcGxheTogZm9ybWF0dGVyQ29tcGFjdERpc3BsYXksXHJcbiAgfSk7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGxvY2FsaXplKGxvY2FsZVN0cmluZywgc3Vic3RpdHV0aW9ucykge1xyXG4gIHRyeSB7XHJcbiAgICBpZiAodHlwZW9mIGNocm9tZSAhPT0gXCJ1bmRlZmluZWRcIiAmJiBjaHJvbWU/LmkxOG4/LmdldE1lc3NhZ2UpIHtcclxuICAgICAgY29uc3QgYXJncyA9IHN1YnN0aXR1dGlvbnMgPT09IHVuZGVmaW5lZCA/IFtsb2NhbGVTdHJpbmddIDogW2xvY2FsZVN0cmluZywgc3Vic3RpdHV0aW9uc107XHJcbiAgICAgIGNvbnN0IG1lc3NhZ2UgPSBjaHJvbWUuaTE4bi5nZXRNZXNzYWdlKC4uLmFyZ3MpO1xyXG4gICAgICBpZiAobWVzc2FnZSkge1xyXG4gICAgICAgIHJldHVybiBtZXNzYWdlO1xyXG4gICAgICB9XHJcbiAgICB9XHJcbiAgfSBjYXRjaCAoZXJyb3IpIHtcclxuICAgIGNvbnNvbGUud2FybihcIkxvY2FsaXphdGlvbiBsb29rdXAgZmFpbGVkIGZvclwiLCBsb2NhbGVTdHJpbmcsIGVycm9yKTtcclxuICB9XHJcblxyXG4gIGlmIChBcnJheS5pc0FycmF5KHN1YnN0aXR1dGlvbnMpKSB7XHJcbiAgICByZXR1cm4gc3Vic3RpdHV0aW9ucy5qb2luKFwiIFwiKTtcclxuICB9XHJcblxyXG4gIGlmIChzdWJzdGl0dXRpb25zICE9IG51bGwpIHtcclxuICAgIHJldHVybiBgJHtzdWJzdGl0dXRpb25zfWA7XHJcbiAgfVxyXG5cclxuICByZXR1cm4gbG9jYWxlU3RyaW5nO1xyXG59XHJcblxyXG5mdW5jdGlvbiBnZXRCcm93c2VyKCkge1xyXG4gIGlmICh0eXBlb2YgY2hyb21lICE9PSBcInVuZGVmaW5lZFwiICYmIHR5cGVvZiBjaHJvbWUucnVudGltZSAhPT0gXCJ1bmRlZmluZWRcIikge1xyXG4gICAgcmV0dXJuIGNocm9tZTtcclxuICB9IGVsc2UgaWYgKHR5cGVvZiBicm93c2VyICE9PSBcInVuZGVmaW5lZFwiICYmIHR5cGVvZiBicm93c2VyLnJ1bnRpbWUgIT09IFwidW5kZWZpbmVkXCIpIHtcclxuICAgIHJldHVybiBicm93c2VyO1xyXG4gIH0gZWxzZSB7XHJcbiAgICBjb25zb2xlLmxvZyhcImJyb3dzZXIgaXMgbm90IHN1cHBvcnRlZFwiKTtcclxuICAgIHJldHVybiBmYWxzZTtcclxuICB9XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGdldFZpZGVvSWQodXJsKSB7XHJcbiAgY29uc3QgdXJsT2JqZWN0ID0gbmV3IFVSTCh1cmwpO1xyXG4gIGNvbnN0IHBhdGhuYW1lID0gdXJsT2JqZWN0LnBhdGhuYW1lO1xyXG4gIGlmIChwYXRobmFtZS5zdGFydHNXaXRoKFwiL2NsaXBcIikpIHtcclxuICAgIHJldHVybiAoZG9jdW1lbnQucXVlcnlTZWxlY3RvcihcIm1ldGFbaXRlbXByb3A9J3ZpZGVvSWQnXVwiKSB8fCBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKFwibWV0YVtpdGVtcHJvcD0naWRlbnRpZmllciddXCIpKVxyXG4gICAgICAuY29udGVudDtcclxuICB9IGVsc2Uge1xyXG4gICAgaWYgKHBhdGhuYW1lLnN0YXJ0c1dpdGgoXCIvc2hvcnRzXCIpKSB7XHJcbiAgICAgIHJldHVybiBwYXRobmFtZS5zbGljZSg4KTtcclxuICAgIH1cclxuICAgIHJldHVybiB1cmxPYmplY3Quc2VhcmNoUGFyYW1zLmdldChcInZcIik7XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBpc0luVmlld3BvcnQoZWxlbWVudCkge1xyXG4gIGNvbnN0IHJlY3QgPSBlbGVtZW50LmdldEJvdW5kaW5nQ2xpZW50UmVjdCgpO1xyXG4gIGNvbnN0IGhlaWdodCA9IGlubmVySGVpZ2h0IHx8IGRvY3VtZW50LmRvY3VtZW50RWxlbWVudC5jbGllbnRIZWlnaHQ7XHJcbiAgY29uc3Qgd2lkdGggPSBpbm5lcldpZHRoIHx8IGRvY3VtZW50LmRvY3VtZW50RWxlbWVudC5jbGllbnRXaWR0aDtcclxuICByZXR1cm4gKFxyXG4gICAgLy8gV2hlbiBzaG9ydCAoY2hhbm5lbCkgaXMgaWdub3JlZCwgdGhlIGVsZW1lbnQgKGxpa2UvZGlzbGlrZSBBTkQgc2hvcnQgaXRzZWxmKSBpc1xyXG4gICAgLy8gaGlkZGVuIHdpdGggYSAwIERPTVJlY3QuIEluIHRoaXMgY2FzZSwgY29uc2lkZXIgaXQgb3V0c2lkZSBvZiBWaWV3cG9ydFxyXG4gICAgIShyZWN0LnRvcCA9PSAwICYmIHJlY3QubGVmdCA9PSAwICYmIHJlY3QuYm90dG9tID09IDAgJiYgcmVjdC5yaWdodCA9PSAwKSAmJlxyXG4gICAgcmVjdC50b3AgPj0gMCAmJlxyXG4gICAgcmVjdC5sZWZ0ID49IDAgJiZcclxuICAgIHJlY3QuYm90dG9tIDw9IGhlaWdodCAmJlxyXG4gICAgcmVjdC5yaWdodCA8PSB3aWR0aFxyXG4gICk7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGlzU2hvcnRzTG9hZGVkKHZpZGVvSWQpIHtcclxuICBpZiAoIXZpZGVvSWQpIHJldHVybiBmYWxzZTtcclxuXHJcbiAgLy8gRmluZCBhbGwgcmVlbCBjb250YWluZXJzXHJcbiAgY29uc3QgcmVlbENvbnRhaW5lcnMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKFwiLnJlZWwtdmlkZW8taW4tc2VxdWVuY2UtbmV3XCIpO1xyXG5cclxuICBmb3IgKGNvbnN0IGNvbnRhaW5lciBvZiByZWVsQ29udGFpbmVycykge1xyXG4gICAgLy8gQ2hlY2sgaWYgdGhpcyBjb250YWluZXIncyB0aHVtYm5haWwgbWF0Y2hlcyBvdXIgdmlkZW8gSURcclxuICAgIGNvbnN0IHRodW1ibmFpbCA9IGNvbnRhaW5lci5xdWVyeVNlbGVjdG9yKFwiLnJlZWwtdmlkZW8taW4tc2VxdWVuY2UtdGh1bWJuYWlsXCIpO1xyXG4gICAgaWYgKHRodW1ibmFpbCkge1xyXG4gICAgICBjb25zdCBiZ0ltYWdlID0gdGh1bWJuYWlsLnN0eWxlLmJhY2tncm91bmRJbWFnZTtcclxuICAgICAgLy8gWW91VHViZSB0aHVtYm5haWwgVVJMcyBjb250YWluIHRoZSB2aWRlbyBJRCBpbiB0aGUgZm9ybWF0OiAvdmkvVklERU9fSUQvXHJcbiAgICAgIGlmICgoYmdJbWFnZSAmJiBiZ0ltYWdlLmluY2x1ZGVzKGAvJHt2aWRlb0lkfS9gKSkgfHwgKCFiZ0ltYWdlICYmIGlzSW5WaWV3cG9ydChjb250YWluZXIpKSkge1xyXG4gICAgICAgIC8vIENoZWNrIGlmIHRoaXMgY29udGFpbmVyIGhhcyB0aGUgcmVuZGVyZXIgd2l0aCB2aXNpYmxlIGV4cGVyaW1lbnQtb3ZlcmxheVxyXG4gICAgICAgIGNvbnN0IHJlbmRlcmVyID0gY29udGFpbmVyLnF1ZXJ5U2VsZWN0b3IoXCJ5dGQtcmVlbC12aWRlby1yZW5kZXJlclwiKTtcclxuICAgICAgICBpZiAocmVuZGVyZXIpIHtcclxuICAgICAgICAgIGNvbnN0IGV4cGVyaW1lbnRPdmVybGF5ID0gcmVuZGVyZXIucXVlcnlTZWxlY3RvcihcIiNleHBlcmltZW50LW92ZXJsYXlcIik7XHJcbiAgICAgICAgICBpZiAoXHJcbiAgICAgICAgICAgIGV4cGVyaW1lbnRPdmVybGF5ICYmXHJcbiAgICAgICAgICAgICFleHBlcmltZW50T3ZlcmxheS5oaWRkZW4gJiZcclxuICAgICAgICAgICAgd2luZG93LmdldENvbXB1dGVkU3R5bGUoZXhwZXJpbWVudE92ZXJsYXkpLmRpc3BsYXkgIT09IFwibm9uZVwiICYmXHJcbiAgICAgICAgICAgIGV4cGVyaW1lbnRPdmVybGF5Lmhhc0NoaWxkTm9kZXMoKVxyXG4gICAgICAgICAgKSB7XHJcbiAgICAgICAgICAgIHJldHVybiB0cnVlO1xyXG4gICAgICAgICAgfVxyXG4gICAgICAgIH1cclxuICAgICAgfVxyXG4gICAgfVxyXG4gIH1cclxuXHJcbiAgcmV0dXJuIGZhbHNlO1xyXG59XHJcblxyXG5mdW5jdGlvbiBpc1ZpZGVvTG9hZGVkKCkge1xyXG4gIGNvbnN0IHZpZGVvSWQgPSBnZXRWaWRlb0lkKHdpbmRvdy5sb2NhdGlvbi5ocmVmKTtcclxuXHJcbiAgLy8gQ2hlY2sgaWYgdGhpcyBpcyBhIFNob3J0cyBVUkxcclxuICBpZiAoaXNTaG9ydHMoKSkge1xyXG4gICAgcmV0dXJuIGlzU2hvcnRzTG9hZGVkKHZpZGVvSWQpO1xyXG4gIH1cclxuXHJcbiAgLy8gUmVndWxhciB2aWRlbyBjaGVja3NcclxuICByZXR1cm4gKFxyXG4gICAgLy8gZGVza3RvcDogc3ByaW5nIDIwMjQgVUlcclxuICAgIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoYHl0ZC13YXRjaC1ncmlkW3ZpZGVvLWlkPScke3ZpZGVvSWR9J11gKSAhPT0gbnVsbCB8fFxyXG4gICAgLy8gZGVza3RvcDogb2xkZXIgVUlcclxuICAgIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoYHl0ZC13YXRjaC1mbGV4eVt2aWRlby1pZD0nJHt2aWRlb0lkfSddYCkgIT09IG51bGwgfHxcclxuICAgIC8vIG1vYmlsZTogbm8gdmlkZW8taWQgYXR0cmlidXRlXHJcbiAgICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKCcjcGxheWVyW2xvYWRpbmc9XCJmYWxzZVwiXTpub3QoW2hpZGRlbl0pJykgIT09IG51bGxcclxuICApO1xyXG59XHJcblxyXG5jb25zdCBvcmlnaW5hbENvbnNvbGUgPSB7XHJcbiAgbG9nOiBjb25zb2xlLmxvZy5iaW5kKGNvbnNvbGUpLFxyXG4gIGRlYnVnOiBjb25zb2xlLmRlYnVnLmJpbmQoY29uc29sZSksXHJcbiAgaW5mbzogY29uc29sZS5pbmZvLmJpbmQoY29uc29sZSksXHJcbiAgd2FybjogY29uc29sZS53YXJuLmJpbmQoY29uc29sZSksXHJcbiAgZXJyb3I6IGNvbnNvbGUuZXJyb3IuYmluZChjb25zb2xlKSxcclxufTtcclxuXHJcbmZ1bmN0aW9uIGluaXRpYWxpemVMb2dnaW5nKCkge1xyXG4gIGlmIChleHRDb25maWcuZGlzYWJsZUxvZ2dpbmcpIHtcclxuICAgIGNvbnNvbGUubG9nID0gKCkgPT4ge307XHJcbiAgICBjb25zb2xlLmRlYnVnID0gKCkgPT4ge307XHJcbiAgfSBlbHNlIHtcclxuICAgIGNvbnNvbGUubG9nID0gb3JpZ2luYWxDb25zb2xlLmxvZztcclxuICAgIGNvbnNvbGUuZGVidWcgPSBvcmlnaW5hbENvbnNvbGUuZGVidWc7XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBnZXRDb2xvckZyb21UaGVtZSh2b3RlSXNMaWtlKSB7XHJcbiAgbGV0IGNvbG9yU3RyaW5nO1xyXG4gIHN3aXRjaCAoZXh0Q29uZmlnLmNvbG9yVGhlbWUpIHtcclxuICAgIGNhc2UgXCJhY2Nlc3NpYmxlXCI6XHJcbiAgICAgIGlmICh2b3RlSXNMaWtlID09PSB0cnVlKSB7XHJcbiAgICAgICAgY29sb3JTdHJpbmcgPSBcImRvZGdlcmJsdWVcIjtcclxuICAgICAgfSBlbHNlIHtcclxuICAgICAgICBjb2xvclN0cmluZyA9IFwiZ29sZFwiO1xyXG4gICAgICB9XHJcbiAgICAgIGJyZWFrO1xyXG4gICAgY2FzZSBcIm5lb25cIjpcclxuICAgICAgaWYgKHZvdGVJc0xpa2UgPT09IHRydWUpIHtcclxuICAgICAgICBjb2xvclN0cmluZyA9IFwiYXF1YVwiO1xyXG4gICAgICB9IGVsc2Uge1xyXG4gICAgICAgIGNvbG9yU3RyaW5nID0gXCJtYWdlbnRhXCI7XHJcbiAgICAgIH1cclxuICAgICAgYnJlYWs7XHJcbiAgICBjYXNlIFwiY2xhc3NpY1wiOlxyXG4gICAgZGVmYXVsdDpcclxuICAgICAgaWYgKHZvdGVJc0xpa2UgPT09IHRydWUpIHtcclxuICAgICAgICBjb2xvclN0cmluZyA9IFwibGltZVwiO1xyXG4gICAgICB9IGVsc2Uge1xyXG4gICAgICAgIGNvbG9yU3RyaW5nID0gXCJyZWRcIjtcclxuICAgICAgfVxyXG4gIH1cclxuICByZXR1cm4gY29sb3JTdHJpbmc7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIHF1ZXJ5U2VsZWN0b3Ioc2VsZWN0b3JzLCBlbGVtZW50KSB7XHJcbiAgbGV0IHJlc3VsdDtcclxuICBmb3IgKGNvbnN0IHNlbGVjdG9yIG9mIHNlbGVjdG9ycykge1xyXG4gICAgcmVzdWx0ID0gKGVsZW1lbnQgPz8gZG9jdW1lbnQpLnF1ZXJ5U2VsZWN0b3Ioc2VsZWN0b3IpO1xyXG4gICAgaWYgKHJlc3VsdCAhPT0gbnVsbCkge1xyXG4gICAgICByZXR1cm4gcmVzdWx0O1xyXG4gICAgfVxyXG4gIH1cclxufVxyXG5cclxuZnVuY3Rpb24gcXVlcnlTZWxlY3RvckFsbChzZWxlY3RvcnMpIHtcclxuICBsZXQgcmVzdWx0O1xyXG4gIGZvciAoY29uc3Qgc2VsZWN0b3Igb2Ygc2VsZWN0b3JzKSB7XHJcbiAgICByZXN1bHQgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKHNlbGVjdG9yKTtcclxuICAgIGlmIChyZXN1bHQubGVuZ3RoICE9PSAwKSB7XHJcbiAgICAgIHJldHVybiByZXN1bHQ7XHJcbiAgICB9XHJcbiAgfVxyXG4gIHJldHVybiByZXN1bHQ7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGNyZWF0ZU9ic2VydmVyKG9wdGlvbnMsIGNhbGxiYWNrKSB7XHJcbiAgY29uc3Qgb2JzZXJ2ZXJXcmFwcGVyID0gbmV3IE9iamVjdCgpO1xyXG4gIG9ic2VydmVyV3JhcHBlci5vcHRpb25zID0gb3B0aW9ucztcclxuICBvYnNlcnZlcldyYXBwZXIub2JzZXJ2ZXIgPSBuZXcgTXV0YXRpb25PYnNlcnZlcihjYWxsYmFjayk7XHJcbiAgb2JzZXJ2ZXJXcmFwcGVyLm9ic2VydmUgPSBmdW5jdGlvbiAoZWxlbWVudCkge1xyXG4gICAgdGhpcy5vYnNlcnZlci5vYnNlcnZlKGVsZW1lbnQsIHRoaXMub3B0aW9ucyk7XHJcbiAgfTtcclxuICBvYnNlcnZlcldyYXBwZXIuZGlzY29ubmVjdCA9IGZ1bmN0aW9uICgpIHtcclxuICAgIHRoaXMub2JzZXJ2ZXIuZGlzY29ubmVjdCgpO1xyXG4gIH07XHJcbiAgcmV0dXJuIG9ic2VydmVyV3JhcHBlcjtcclxufVxyXG5cclxuZXhwb3J0IHtcclxuICBudW1iZXJGb3JtYXQsXHJcbiAgZ2V0TnVtYmVyRm9ybWF0dGVyLFxyXG4gIGdldEJyb3dzZXIsXHJcbiAgZ2V0VmlkZW9JZCxcclxuICBpc0luVmlld3BvcnQsXHJcbiAgaXNWaWRlb0xvYWRlZCxcclxuICBpbml0aWFsaXplTG9nZ2luZyxcclxuICBnZXRDb2xvckZyb21UaGVtZSxcclxuICBsb2NhbGl6ZSxcclxuICBxdWVyeVNlbGVjdG9yLFxyXG4gIHF1ZXJ5U2VsZWN0b3JBbGwsXHJcbiAgY3JlYXRlT2JzZXJ2ZXIsXHJcbn07XHJcbiIsImltcG9ydCB7IGNvbmZpZyB9IGZyb20gXCIuLi9jb25maWdcIjtcclxuaW1wb3J0IHsgZ2V0QnJvd3NlciwgbG9jYWxpemUgfSBmcm9tIFwiLi4vdXRpbHNcIjtcclxuXHJcbmNvbnN0IFBBVFJFT05fSk9JTl9VUkwgPSBcImh0dHBzOi8vd3d3LnBhdHJlb24uY29tL2pvaW4vcmV0dXJueW91dHViZWRpc2xpa2UvY2hlY2tvdXQ/cmlkPTgwMDg2NDlcIjtcclxuY29uc3QgU1VQUE9SVF9ET0NfVVJMID0gY29uZmlnLmxpbmtzPy5oZWxwID8/IFwiaHR0cHM6Ly9yZXR1cm55b3V0dWJlZGlzbGlrZS5jb20vaGVscFwiO1xyXG5jb25zdCBDT01NVU5JVFlfVVJMID0gY29uZmlnLmxpbmtzPy5kaXNjb3JkID8/IFwiaHR0cHM6Ly9kaXNjb3JkLmdnL21ZbkVTWTRNZDVcIjtcclxuXHJcbmV4cG9ydCBmdW5jdGlvbiBpbml0Q2hhbmdlbG9nUGFnZSgpIHtcclxuICBpZiAoZG9jdW1lbnQucmVhZHlTdGF0ZSA9PT0gXCJsb2FkaW5nXCIpIHtcclxuICAgIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoXCJET01Db250ZW50TG9hZGVkXCIsIHNldHVwKTtcclxuICB9IGVsc2Uge1xyXG4gICAgc2V0dXAoKTtcclxuICB9XHJcbn1cclxuXHJcbmZ1bmN0aW9uIHNldHVwKCkge1xyXG4gIGFwcGx5TG9jYWxlTWV0YWRhdGEoKTtcclxuICBsb2NhbGl6ZUh0bWxQYWdlKCk7XHJcbiAgZGVjb3JhdGVTY3JlZW5zaG90UGxhY2Vob2xkZXJzKCk7XHJcbiAgYmluZEFjdGlvbnMoKTtcclxufVxyXG5cclxuZnVuY3Rpb24gYXBwbHlMb2NhbGVNZXRhZGF0YSgpIHtcclxuICB0cnkge1xyXG4gICAgY29uc3QgYnJvd3NlckxvY2FsZSA9IGNocm9tZT8uaTE4bj8uZ2V0TWVzc2FnZT8uKFwiQEB1aV9sb2NhbGVcIik7XHJcbiAgICBpZiAoYnJvd3NlckxvY2FsZSkge1xyXG4gICAgICBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnQubGFuZyA9IGJyb3dzZXJMb2NhbGU7XHJcbiAgICB9XHJcbiAgfSBjYXRjaCAoZXJyb3IpIHtcclxuICAgIGNvbnNvbGUuZGVidWcoXCJVbmFibGUgdG8gcmVzb2x2ZSBVSSBsb2NhbGVcIiwgZXJyb3IpO1xyXG4gIH1cclxufVxyXG5cclxuZnVuY3Rpb24gbG9jYWxpemVIdG1sUGFnZSgpIHtcclxuICBjb25zdCBlbGVtZW50cyA9IGRvY3VtZW50LmdldEVsZW1lbnRzQnlUYWdOYW1lKFwiaHRtbFwiKTtcclxuICBmb3IgKGxldCBpbmRleCA9IDA7IGluZGV4IDwgZWxlbWVudHMubGVuZ3RoOyBpbmRleCArPSAxKSB7XHJcbiAgICBjb25zdCBlbGVtZW50ID0gZWxlbWVudHNbaW5kZXhdO1xyXG4gICAgY29uc3Qgb3JpZ2luYWwgPSBlbGVtZW50LmlubmVySFRNTC50b1N0cmluZygpO1xyXG4gICAgY29uc3QgbG9jYWxpemVkID0gb3JpZ2luYWwucmVwbGFjZSgvX19NU0dfKFxcdyspX18vZywgKG1hdGNoLCBrZXkpID0+IHtcclxuICAgICAgcmV0dXJuIGtleSA/IGxvY2FsaXplKGtleSkgOiBcIlwiO1xyXG4gICAgfSk7XHJcblxyXG4gICAgaWYgKGxvY2FsaXplZCAhPT0gb3JpZ2luYWwpIHtcclxuICAgICAgZWxlbWVudC5pbm5lckhUTUwgPSBsb2NhbGl6ZWQ7XHJcbiAgICB9XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBkZWNvcmF0ZVNjcmVlbnNob3RQbGFjZWhvbGRlcnMoKSB7XHJcbiAgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbChcIltkYXRhLXNjcmVlbnNob3RdXCIpLmZvckVhY2goKHdyYXBwZXIpID0+IHtcclxuICAgIGNvbnN0IHR5cGUgPSB3cmFwcGVyLmdldEF0dHJpYnV0ZShcImRhdGEtc2NyZWVuc2hvdFwiKTtcclxuICAgIGNvbnN0IGxhYmVsS2V5ID0gZ2V0UGxhY2Vob2xkZXJMYWJlbEtleSh0eXBlKTtcclxuICAgIGlmICghbGFiZWxLZXkpIHJldHVybjtcclxuXHJcbiAgICBjb25zdCBwbGFjZWhvbGRlciA9IHdyYXBwZXIucXVlcnlTZWxlY3RvcihcIi5yeWQtZmVhdHVyZS1jYXJkX19wbGFjZWhvbGRlclwiKTtcclxuICAgIGlmICghcGxhY2Vob2xkZXIpIHJldHVybjtcclxuXHJcbiAgICBjb25zdCBsYWJlbCA9IGxvY2FsaXplKGxhYmVsS2V5KTtcclxuICAgIHBsYWNlaG9sZGVyLnNldEF0dHJpYnV0ZShcInJvbGVcIiwgXCJpbWdcIik7XHJcbiAgICBwbGFjZWhvbGRlci5zZXRBdHRyaWJ1dGUoXCJhcmlhLWxhYmVsXCIsIGxhYmVsKTtcclxuICAgIHBsYWNlaG9sZGVyLnRpdGxlID0gbGFiZWw7XHJcbiAgfSk7XHJcbn1cclxuXHJcbmZ1bmN0aW9uIGdldFBsYWNlaG9sZGVyTGFiZWxLZXkodHlwZSkge1xyXG4gIHN3aXRjaCAodHlwZSkge1xyXG4gICAgY2FzZSBcInRpbWVsaW5lXCI6XHJcbiAgICAgIHJldHVybiBcImNoYW5nZWxvZ19zY3JlZW5zaG90X2xhYmVsX3RpbWVsaW5lXCI7XHJcbiAgICBjYXNlIFwibWFwXCI6XHJcbiAgICAgIHJldHVybiBcImNoYW5nZWxvZ19zY3JlZW5zaG90X2xhYmVsX21hcFwiO1xyXG4gICAgY2FzZSBcInRlYXNlclwiOlxyXG4gICAgICByZXR1cm4gXCJjaGFuZ2Vsb2dfc2NyZWVuc2hvdF9sYWJlbF90ZWFzZXJcIjtcclxuICAgIGRlZmF1bHQ6XHJcbiAgICAgIHJldHVybiBudWxsO1xyXG4gIH1cclxufVxyXG5cclxuZnVuY3Rpb24gYmluZEFjdGlvbnMoKSB7XHJcbiAgY29uc3QgYnJvd3NlciA9IGdldEJyb3dzZXIoKTtcclxuXHJcbiAgY29uc3QgdXBncmFkZUJ1dHRvbiA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwicnlkLWNoYW5nZWxvZy11cGdyYWRlXCIpO1xyXG4gIGlmICh1cGdyYWRlQnV0dG9uKSB7XHJcbiAgICB1cGdyYWRlQnV0dG9uLmFkZEV2ZW50TGlzdGVuZXIoXCJjbGlja1wiLCAoZXZlbnQpID0+IHtcclxuICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcclxuICAgICAgb3BlbkV4dGVybmFsKFBBVFJFT05fSk9JTl9VUkwsIGJyb3dzZXIpO1xyXG4gICAgfSk7XHJcbiAgfVxyXG5cclxuICBjb25zdCBzdXBwb3J0QnV0dG9uID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoXCJyeWQtY2hhbmdlbG9nLXN1cHBvcnRcIik7XHJcbiAgaWYgKHN1cHBvcnRCdXR0b24pIHtcclxuICAgIHN1cHBvcnRCdXR0b24uYWRkRXZlbnRMaXN0ZW5lcihcImNsaWNrXCIsIChldmVudCkgPT4ge1xyXG4gICAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpO1xyXG4gICAgICBvcGVuRXh0ZXJuYWwoU1VQUE9SVF9ET0NfVVJMLCBicm93c2VyKTtcclxuICAgIH0pO1xyXG4gIH1cclxuXHJcbiAgY29uc3QgY29udGFjdEJ1dHRvbiA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFwicnlkLWNoYW5nZWxvZy1jb250YWN0XCIpO1xyXG4gIGlmIChjb250YWN0QnV0dG9uKSB7XHJcbiAgICBjb250YWN0QnV0dG9uLmFkZEV2ZW50TGlzdGVuZXIoXCJjbGlja1wiLCAoZXZlbnQpID0+IHtcclxuICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKTtcclxuICAgICAgb3BlbkV4dGVybmFsKENPTU1VTklUWV9VUkwsIGJyb3dzZXIpO1xyXG4gICAgfSk7XHJcbiAgfVxyXG59XHJcblxyXG5mdW5jdGlvbiBvcGVuRXh0ZXJuYWwodXJsLCBicm93c2VyKSB7XHJcbiAgaWYgKCF1cmwpIHJldHVybjtcclxuXHJcbiAgdHJ5IHtcclxuICAgIGlmIChicm93c2VyICYmIGJyb3dzZXIudGFicyAmJiB0eXBlb2YgYnJvd3Nlci50YWJzLmNyZWF0ZSA9PT0gXCJmdW5jdGlvblwiKSB7XHJcbiAgICAgIGJyb3dzZXIudGFicy5jcmVhdGUoeyB1cmwgfSk7XHJcbiAgICAgIHJldHVybjtcclxuICAgIH1cclxuICB9IGNhdGNoIChlcnJvcikge1xyXG4gICAgY29uc29sZS5kZWJ1ZyhcInRhYnMuY3JlYXRlIHVuYXZhaWxhYmxlLCBmYWxsaW5nIGJhY2tcIiwgZXJyb3IpO1xyXG4gIH1cclxuXHJcbiAgdHJ5IHtcclxuICAgIHdpbmRvdy5vcGVuKHVybCwgXCJfYmxhbmtcIiwgXCJub29wZW5lclwiKTtcclxuICB9IGNhdGNoIChlcnJvcikge1xyXG4gICAgY29uc29sZS53YXJuKFwiRmFpbGVkIHRvIG9wZW4gZXh0ZXJuYWwgdXJsXCIsIHVybCwgZXJyb3IpO1xyXG4gIH1cclxufVxyXG4iLCJpbXBvcnQgeyBpbml0Q2hhbmdlbG9nUGFnZSB9IGZyb20gXCIuL3NyYy9jaGFuZ2Vsb2dcIjtcclxuXHJcbmluaXRDaGFuZ2Vsb2dQYWdlKCk7XHJcbiJdLCJuYW1lcyI6W10sInNvdXJjZVJvb3QiOiIifQ==