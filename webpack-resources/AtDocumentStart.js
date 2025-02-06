/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 */

"use strict";
import { isProbablyReaderable, Readability } from "@mozilla/readability";

const DEBUG = false;

let readabilityResult = null;
let currentStyle = null;
let originalBodyStyle = null;

const themeColors = {
    light: { background: "#ffffff", color: "#15141a" },
    dark: { background: "#333333", color: "#fbfbfe" },
    sepia: { background: "#fff4de", color: "#15141a" }
};

const BLOCK_IMAGES_SELECTOR =
  ".content p > img:only-child, " +
  ".content p > a:only-child > img:only-child, " +
  ".content .wp-caption img, " +
  ".content figure img";

function debug(s) {
    if (!DEBUG) {
        return;
    }
    console.log(s);
}

function checkReadability() {
    setTimeout(function() {
        if (!isProbablyReaderable(document)) {
            postStateChangedToUnavailable();
            return;
        }

        if ((document.location.protocol === "http:" || document.location.protocol === "https:") &&
            document.location.pathname !== "/") {
            if (readabilityResult && readabilityResult.content) {
                postStateChangedToAvailable();
                postContentParsed(readabilityResult);
                return;
            }

            const uri = {
                spec: document.location.href,
                host: document.location.host,
                prePath: document.location.protocol + "//" + document.location.host,
                scheme: document.location.protocol.substr(0, document.location.protocol.indexOf(":")),
                pathBase: document.location.protocol + "//" + document.location.host + location.pathname.substr(0, location.pathname.lastIndexOf("/") + 1)
            };

            const docStr = new XMLSerializer().serializeToString(document);
            if (docStr.indexOf("<frameset ") > -1) {
                postStateChangedToUnavailable();
                return;
            }

            const DOMPurify = require('dompurify');
            const clean = DOMPurify.sanitize(docStr, { WHOLE_DOCUMENT: true });
            const doc = new DOMParser().parseFromString(clean, "text/html");
            const readability = new Readability(uri, doc, { debug: DEBUG });
            readabilityResult = readability.parse();

            if (!readabilityResult) {
                postStateChangedToUnavailable();
                return;
            }

            readabilityResult.title = escapeHTML(readabilityResult.title);
            readabilityResult.byline = escapeHTML(readabilityResult.byline);

            postStateChanged(readabilityResult !== null ? "Available" : "Unavailable");
            postContentParsed(readabilityResult);
            return;
        }

        postStateChangedToUnavailable();
    }, 100);
}

function postContentParsed(readabilityResult) {
    webkit.messageHandlers.readabilityMessageHandler.postMessage({
        Type: "ContentParsed",
        Value: JSON.stringify(readabilityResult)
    });
}

function postStateChangedToAvailable() {
    postStateChanged("Available");
}

function postStateChangedToUnavailable() {
    postStateChanged("Unavailable");
}

function postStateChanged(value) {
    if (!isCurrentPageReader()) {
        debug({ Type: "StateChange", Value: value });
        webkit.messageHandlers.readabilityMessageHandler.postMessage({
            Type: "StateChange",
            Value: value
        });
    }
}

function isCurrentPageReader() {
    return document.getElementById("reader-content") &&
           document.getElementById("reader-header") &&
           document.getElementById("reader-title") &&
           document.getElementById("reader-credits");
}

function readerize() {
    return readabilityResult;
}

function updateThemeColors() {
    if (currentStyle && currentStyle.theme && themeColors[currentStyle.theme]) {
        const colors = themeColors[currentStyle.theme];

        const readerContainer = document.getElementById("reader-container");
        if (readerContainer) {
            readerContainer.style.backgroundColor = colors.background;
            readerContainer.style.color = colors.color;
        }

        const overlay = document.getElementById("reader-overlay");
        if (overlay) {
            overlay.style.backgroundColor = colors.background;
            overlay.style.color = colors.color;
        }
        
        document.body.style.backgroundColor = colors.background;
        document.body.style.color = colors.color;
    }
}

function setStyle(style) {
    const readerRoot = document.getElementById("reader-container") || document.body;
    if (currentStyle && currentStyle.theme) {
        readerRoot.classList.remove(currentStyle.theme);
        document.documentElement.classList.remove(currentStyle.theme);
    }
    if (style && style.theme) {
        readerRoot.classList.add(style.theme);
        document.documentElement.classList.add(style.theme);
    }
    if (currentStyle && currentStyle.fontSize) {
        readerRoot.classList.remove("font-size" + currentStyle.fontSize);
    }
    if (style && style.fontSize) {
        readerRoot.classList.add("font-size" + style.fontSize);
    }
    currentStyle = style;
    updateThemeColors();
}

function setTheme(theme) {
    const readerRoot = document.getElementById("reader-container") || document.body;
    if (currentStyle && currentStyle.theme) {
        readerRoot.classList.remove(currentStyle.theme);
        document.documentElement.classList.remove(currentStyle.theme);
    }
    currentStyle = currentStyle || {};
    if (theme) {
        readerRoot.classList.add(theme);
        document.documentElement.classList.add(theme);
        currentStyle.theme = theme;
    }
    updateThemeColors();
}

function setFontSize(fontSize) {
    const readerRoot = document.getElementById("reader-container") || document.body;
    if (currentStyle && currentStyle.fontSize) {
        readerRoot.classList.remove("font-size" + currentStyle.fontSize);
    }
    currentStyle = currentStyle || {};
    if (fontSize) {
        readerRoot.classList.add("font-size" + fontSize);
        currentStyle.fontSize = fontSize;
    }
    updateThemeColors();
}

function updateImageMargins() {
    const readerRoot = document.getElementById("reader-container") || document.body;
    const contentElement = readerRoot.querySelector("#reader-content");
    if (!contentElement) {
        return;
    }

    const windowWidth = window.innerWidth;
    const contentWidth = contentElement.offsetWidth;
    const maxWidthStyle = windowWidth + "px !important";

    const setImageMargins = function(img) {
        if (!img._originalWidth) {
            img._originalWidth = img.offsetWidth;
        }
        let imgWidth = img._originalWidth;
        if (imgWidth < contentWidth && imgWidth > windowWidth * 0.55) {
            imgWidth = windowWidth;
        }
        const sideMargin = Math.max((contentWidth - windowWidth) / 2, (contentWidth - imgWidth) / 2);
        const imageStyle = sideMargin + "px !important";
        const widthStyle = imgWidth + "px !important";
        const cssText =
            "max-width: " + maxWidthStyle + ";" +
            "width: " + widthStyle + ";" +
            "margin-left: " + imageStyle + ";" +
            "margin-right: " + imageStyle + ";";
        img.style.cssText = cssText;
    };

    const imgs = contentElement.querySelectorAll(BLOCK_IMAGES_SELECTOR);
    for (let i = imgs.length; --i >= 0;) {
        const img = imgs[i];
        if (img.width > 0) {
            setImageMargins(img);
        } else {
            img.onload = function() {
                setImageMargins(img);
            };
        }
    }
}

function configureReader() {
    const readerRoot = document.getElementById("reader-container");
    if (!readerRoot) {
        return;
    }
    const dataStyle = readerRoot.getAttribute("data-readerstyle");
    if (!dataStyle) {
        return;
    }
    const style = JSON.parse(dataStyle);
    setStyle(style);
    updateImageMargins();
}

function escapeHTML(string) {
    if (typeof(string) !== 'string') { return ''; }
    return string
        .replace(/\&/g, "&amp;")
        .replace(/\</g, "&lt;")
        .replace(/\>/g, "&gt;")
        .replace(/\"/g, "&quot;")
        .replace(/\'/g, "&#039;");
}

function showReaderOverlay(readerHTML) {
    if (originalBodyStyle === null) {
        originalBodyStyle = document.body.getAttribute("style");
    }

    let originalContainer = document.getElementById('original-content');
    if (!originalContainer) {
        originalContainer = document.createElement('div');
        originalContainer.id = 'original-content';
        while (document.body.firstChild) {
            originalContainer.appendChild(document.body.firstChild);
        }
        document.body.appendChild(originalContainer);
    }
    originalContainer.style.display = 'none';

    let overlay = document.getElementById('reader-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'reader-overlay';
        Object.assign(overlay.style, {
            opacity: '0',
            transition: 'opacity 0.3s ease',
            top: '0',
            left: '0',
            width: '100%',
            height: '100%',
            overflow: 'auto'
        });
        document.body.appendChild(overlay);
    } else {
        overlay.style.opacity = '0';
    }

    const parser = new DOMParser();
    const doc = parser.parseFromString(readerHTML, "text/html");

    let styleContent = "";
    const styleEl = doc.head.querySelector("style");
    if (styleEl) {
        styleContent = styleEl.outerHTML;
        styleContent = styleContent.replace(/(^|\n)\s*body\s*\{/g, "$1#reader-container {")
            .replace(/(^|\n)\s*html\s*\{/g, "$1#reader-container {");
    }
    const bodyContent = doc.body.innerHTML;
    const dataReaderStyle = doc.body.getAttribute("data-readerstyle") || "";

    const container = document.createElement("div");
    container.id = "reader-container";
    if (dataReaderStyle) {
        container.setAttribute("data-readerstyle", dataReaderStyle);
    }
    container.innerHTML = styleContent + bodyContent;

    overlay.innerHTML = "";
    overlay.appendChild(container);

    configureReader();

    requestAnimationFrame(function() {
        updateThemeColors();
        overlay.style.opacity = "1";
    });
}

function hideReaderOverlay() {
    const overlay = document.getElementById('reader-overlay');
    if (overlay) {
        overlay.style.transition = 'opacity 0.3s ease';
        void overlay.offsetWidth;
        overlay.style.opacity = '0';
        overlay.addEventListener("transitionend", function(e) {
            if (overlay && overlay.parentNode) {
                overlay.parentNode.removeChild(overlay);
            }
        }, { once: true });
    }
    const originalContainer = document.getElementById('original-content');
    if (originalContainer) {
        originalContainer.style.display = '';
    }
    if (currentStyle && currentStyle.theme) {
        document.documentElement.classList.remove(currentStyle.theme);
    }
    if (originalBodyStyle !== null) {
        document.body.setAttribute("style", originalBodyStyle);
        originalBodyStyle = null;
    } else {
        document.body.removeAttribute("style");
    }
}

function isReaderMode() {
    return isCurrentPageReader();
}

Object.defineProperty(window, "__swift_readability__", {
    enumerable: false,
    configurable: false,
    writable: false,
    value: Object.freeze({
        checkReadability: checkReadability,
        setStyle: setStyle,
        setTheme: setTheme,
        setFontSize: setFontSize,
        configureReader: configureReader,
        showReaderOverlay: showReaderOverlay,
        hideReaderOverlay: hideReaderOverlay,
        isReaderMode: isReaderMode
    })
});

window.addEventListener("load", function(event) {
    configureReader();
});
