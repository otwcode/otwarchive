
const SCROLL_DISTANCE_MINIMUM_FOR_HISTORY = 300;
const SCROLL_HISTORY_MAX_SIZE = 20;
const STORAGE_KEY_PREFIX = "scroll position history for ";

function getStorageKey() {
  return STORAGE_KEY_PREFIX + new URL(document.URL).pathname;
}

function getScrollHistory(return_default = true) {
  const scroll_history_json = window.localStorage.getItem(getStorageKey());
  var scroll_history = return_default ? {"index": 0, "list": [0]} : undefined;

  try {
    if (scroll_history_json !== null) {
      scroll_history = JSON.parse(
        scroll_history_json,
        // validate shape on load
        function (key, value) {
          // we only care about the root object
          if (key !== "") {
            return value;
          }

          if (
            value.list instanceof Array
            && value.index >= 0
            && value.index < value.list.length
          ) {
            return value;
          }

          return undefined;
        }
      );
    }
  } catch (e) {
    if (e instanceof SyntaxError) {
      // we can ignore this and return the default scroll_history
    } else {
      throw e;
    }
  }

  return scroll_history;
}

function saveScrollHistory(scroll_history) {
  try {
    window.localStorage.setItem(getStorageKey(), JSON.stringify(scroll_history));
  } catch (e) {
    // swallow quota exceeded errors to avoid breaking the page; we just break scroll history
    if (e instanceof DOMException && e.name === "QuotaExceededError") {
      console.error("localStorage quota exceeded; not saving scroll history", scroll_history)
      return;
    }
    throw e;
  }
}

function scrollToLastPosition() {
  const scroll_history = getScrollHistory(false);
  if (scroll_history !== undefined) {
    window.scrollTo({"top": scroll_history.list[scroll_history.index], behavior: "instant"});
  }
}

function initScrollHistory(scroll_to_last_position = false) {
  if (scroll_to_last_position) {
    scrollToLastPosition();
  }

  document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled = "true";

  document.addEventListener("scrollend", function() {
    if (document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled === undefined) {
      return;
    }

    const scrolling_element = document.scrollingElement;
    if (!scrolling_element) {
      return;
    }

    const new_position = scrolling_element.scrollTop;

    const scroll_history = getScrollHistory();
    const previous_position = scroll_history.list[scroll_history.index];

    if (Math.abs(new_position - previous_position) < SCROLL_DISTANCE_MINIMUM_FOR_HISTORY) {
      // If we haven't scrolled that far, don't save the position
      return;
    }

    // if we're at an index other than zero, we're saving new history,
    // so we gotta trash the old stuff.
    // this whole section will be a no-op if scroll_history.index === 0.
    for (var i = 0; i < scroll_history.index; i++) {
      scroll_history.list.shift();
    }
    scroll_history.index = 0;

    // add the current position to the list.
    // unshift() returns the new length of the array; if that's > max size,
    // pop something off the end.
    if (scroll_history.list.unshift(new_position) > SCROLL_HISTORY_MAX_SIZE) {
      scroll_history.list.pop();
    }

    saveScrollHistory(scroll_history);
  });

  const scroll_history_button = document.querySelector("#scroll_history_button button");
  scroll_history_button.innerText = scroll_history_button.dataset.onText;
}

function clearAllScrollHistory() {
    var to_remove = [];
    for (var i = 0; i < window.localStorage.length; i++) {
        if (window.localStorage.key(i).startsWith(STORAGE_KEY_PREFIX)) {
            to_remove.push(window.localStorage.key(i));
        }
    }
    for (var i = 0; i < to_remove.length; i++) {
        window.localStorage.removeItem(to_remove[i]);
    }
}

function deinitScrollHistory() {
  delete document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled;
  const scroll_history_button = document.querySelector("#scroll_history_button button");
  scroll_history_button.innerText = scroll_history_button.dataset.offText;
}

function scrollHistoryGoBack() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the end of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === scroll_history.list.length - 1) {
    return;
  }

  delete document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index + 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

function scrollHistoryGoForward() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the start of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === 0) {
    return;
  }

  delete document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index - 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

$j(document).ready(function() {
  try {
    const x = "__storage_test__";
    window.localStorage.setItem(x, x);
    window.localStorage.removeItem(x);
  } catch (e) {
    // localStorage is not available, nothing more to do
    delete document.querySelector("#scroll_history_button").dataset.scrollHistoryEnabled;
    return;
  }

  if (!("onscrollend" in window)) {
    // onscrollend event is not supported, nothing more to do
    return;
  }

  const dialog = document.getElementById("scroll_history_dialog");
  document.getElementById("scroll_history_enable_button").onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "yes"); initScrollHistory(false); };
  document.getElementById("scroll_history_disable_button").onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "no"); deinitScrollHistory(); };
  document.getElementById("scroll_history_clear_all_button").onclick = (e) => { dialog.close(); clearAllScrollHistory(); };
  document.getElementById("scroll_history_clear_this_button").onclick = (e) => { dialog.close(); window.localStorage.removeItem(getStorageKey()); };

  document.querySelector("#scroll_history_button button").onclick = function(e) { const dialog = document.getElementById("scroll_history_dialog"); dialog.showModal(); };
  document.querySelector("#scroll_history_button").classList.remove("hidden");

 if (window.localStorage.getItem("save scroll history?") === "yes") {
    initScrollHistory(true);
  }
});