import { isProbablyReaderable, Readability } from "@mozilla/readability";

function postStateChanged(value) {
    webkit.messageHandlers.readabilityMessageHandler.postMessage({Type: "StateChange", Value: value});
}

if(isProbablyReaderable(document)) {
    postStateChanged("Available")
} else {
    postStateChanged("Unavailable")
}

var documentClone = document.cloneNode(true);
const readabilityResult = new Readability(
    documentClone,
    __READABILITY_OPTION__
).parse();

webkit.messageHandlers.readabilityMessageHandler.postMessage({Type: "ContentParsed", Value: JSON.stringify(readabilityResult)});
