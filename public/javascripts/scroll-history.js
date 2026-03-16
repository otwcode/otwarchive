
const SCROLL_DISTANCE_MINIMUM_FOR_HISTORY = 300;
const SCROLL_HISTORY_MAX_SIZE = 20;

function getScrollHistory(return_default = true) {
  const scroll_history_json = window.localStorage.getItem("scroll position history for " + new URL(document.URL).pathname);
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
    window.localStorage.setItem("scroll position history for " + new URL(document.URL).pathname, JSON.stringify(scroll_history));
  } catch (e) {
    // swallow quota exceeded errors to avoid breaking the page; we just break scroll history
    if (e instanceof DOMException && e.name === "QuotaExceededError") {
      console.error("localStorage quota exceeded; not saving scroll history", scroll_history)
      return;
    }
    throw e;
  }

}

function scrollHistoryPreferencePrompt() {
  try {
    window.localStorage.setItem("__storage_test_of_at_least_64_bytes__", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    window.localStorage.removeItem("__storage_test_of_at_least_64_bytes__");
  } catch (e) {
    // something wrong with localStorage, no point prompting if we can't even save the preference
    return;
  }

  const dialog = document.createElement("dialog");
  const dialog_p = document.createElement("p");
  const dialog_yes = document.createElement("button");
  const dialog_no = document.createElement("button");

  dialog_p.innerText = SCROLL_HISTORY_DIALOG_PROMPT;
  dialog.appendChild(dialog_p);

  dialog_yes.innerText = SCROLL_HISTORY_DIALOG_YES;
  // this can throw if we somehow ran out of storage between the check at the top of this function and now, but that seems a reasonable case for an unhandled exception
  dialog_yes.onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "yes"); actuallyInitScrollHistory(); };
  dialog.appendChild(dialog_yes);

  dialog_no.innerText = SCROLL_HISTORY_DIALOG_NO;
  // this can throw, similar to above
  dialog_no.onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "no"); };
  dialog.appendChild(dialog_no);

  document.querySelector("body").appendChild(dialog);

  dialog.showModal();
}

function initScrollHistory() {
  const scroll_history = getScrollHistory(false);
  if (scroll_history !== undefined) {
    window.scrollTo({"top": scroll_history.list[scroll_history.index], behavior: "instant"});
  }

  document.addEventListener("scrollend", function() {
    if (document.querySelector("scrollhistory").dataset.scrollHistoryEnabled === undefined) {
      return;
    }

    const scroll_history = getScrollHistory();
    const previous_position = scroll_history.list[scroll_history.index];
    const new_position = document.scrollingElement?.scrollTop ?? 0;

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
}

function scrollHistoryGoBack() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the end of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === scroll_history.list.length - 1) {
    return;
  }

  delete document.querySelector("scrollhistory").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index + 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("scrollhistory").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

function scrollHistoryGoForward() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the start of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === 0) {
    return;
  }

  delete document.querySelector("scrollhistory").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index - 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("scrollhistory").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

$j(document).ready(function() {
  try {
    const x = "__storage_test__";
    window.localStorage.setItem(x, x);
    window.localStorage.removeItem(x);
  } catch (e) {
    // localStorage is not available, nothing more to do
    delete document.querySelector("scrollhistory").dataset.scrollHistoryEnabled;
    return;
  }

  if (!('onscrollend' in window)) {
    // onscrollend event is not supported, nothing more to do
    return;
  }

  const preference = window.localStorage.getItem("save scroll history?");

  if (preference === null && document.querySelector("#scrollhistory").dataset.scrollHistoryEnabled !== undefined) {
    // Prompt user for preference; this will call actuallyInitScrollHistory() if appropriate.
    scrollHistoryPreferencePrompt();
  } else if (preference === "yes") {
    initScrollHistory();
  } else {
    delete document.querySelector("#scrollhistory").dataset.scrollHistoryEnabled;
  }
});