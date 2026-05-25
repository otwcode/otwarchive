// To be included only where needed:
// tag_wranglings/index, tags/wrangle, admin/spam

document.addEventListener("DOMContentLoaded", function() {

  function bindToggle(buttonId, container, checkboxName, state) {
    var button = document.querySelector(buttonId);
    if (!button) return;
    button.addEventListener("click", function() {
      document.querySelector(container)
        .querySelectorAll("input[type='checkbox'][name='" + checkboxName + "']")
        .forEach(function(checkbox) {
          checkbox.checked = state;
        });
    });
  }

  var toggles = [
    ["#wrangle_all_select",    "#wrangulator", "selected_tags[]", true ],
    ["#wrangle_all_deselect",  "#wrangulator", "selected_tags[]", false],
    ["#canonize_all_select",   "#wrangulator", "canonicals[]",    true ],
    ["#canonize_all_deselect", "#wrangulator", "canonicals[]",    false],
    ["#spam_all_select",       "#spam_works",  "spam[]",          true ],
    ["#spam_all_deselect",     "#spam_works",  "spam[]",          false],
    ["#ham_all_select",        "#spam_works",  "ham[]",           true ],
    ["#ham_all_deselect",      "#spam_works",  "ham[]",           false],
  ];

  toggles.forEach(function(t) {
    bindToggle(t[0], t[1], t[2], t[3]);
  });

});