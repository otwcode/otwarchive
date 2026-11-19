// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
/*jshint esversion: 6 */

import * as Lexxy from "lexxy";

Lexxy.configure({
    default: {
        highlight: {
            permit: { // TODO: I don't know if this works either
                color: [], // update: it doesn't
                "background-color": []
            }
        },
        markdown: false,
        attachments: false
    }
});

// An EditingField is constructed upon divs with both post and comment classes and with the elements under those divs
// such as HTML and RTE editors, their respective notes and links to switch between those editors. A page can have more
// than one EditingField, each having their own HTML and RTE editors, and each commenting to different commentables.
class EditingField {
    constructor(comment_field) {
        this.comment_field = comment_field;
        this.rte = null; // TODO: this probably is supposed to be temporary and need to be replaced with error handling of rte not loading properly
        // let's keep it this way for now
        // TODO: also add tests for RTE not loading properly for any reason, maybe JS being disabled?
        // update: tried and decided not test js-disabled, js is what removes class hidden's anyway which's hard to test
        this.html_editor = comment_field.querySelector("textarea.comment_form");
        this.html_link = comment_field.querySelector(".html-link");
        this.rtf_link = comment_field.querySelector(".rtf-link");
        this.html_notes = comment_field.querySelector(".html-notes");
        this.rtf_notes = comment_field.querySelector(".rtf-notes");

        this.getReady();
    }

    // Method to call when Rich Text button is pressed. It makes the Rich Text button selected, copies HTML editor's
    // value to RTE, hides HTML and its notes and reveals RTE and its notes.
    switchToRTE() {
        this.rtf_link.classList.add("current");
        this.html_link.classList.remove("current");

        this.rte.value = this.html_editor.value;

        this.html_editor.classList.add("hidden");
        this.rte.classList.remove("hidden");

        this.html_notes.classList.add("hidden");
        this.rtf_notes.classList.remove("hidden");
    }

    // Method to call when HTML button is pressed. It makes the HTML button selected, copies RTE's value to HTML via
    // another method, hides RTE and its notes and reveals HTML and its notes.
    switchToHTML() {
        this.html_link.classList.add("current");
        this.rtf_link.classList.remove("current");

        this.copyContentToHTML();

        this.html_editor.classList.remove("hidden");
        this.rte.classList.add("hidden");

        this.html_notes.classList.remove("hidden");
        this.rtf_notes.classList.add("hidden");
    }

    // Because Lexxy keeps <p><br></p> in its content even when it's empty, when it has a custom class for being empty
    // set HTML editor's value to null, otherwise copy RTE's content to it normally
    copyContentToHTML() {
        if(!this.rte.classList.contains("lexxy-editor--empty")) {
            this.html_editor.value = this.rte.value;
        } else {
            this.html_editor.value = null;
        }
    }

    // Get the field ready for Lexxy initialization: unhide switch, make HTML current, set events for buttons Submit,
    // Update, Rich Text and HTML.
    getReady() {
        this.comment_field.querySelector(".rtf-html-switch").classList.remove('hidden');
        this.html_link.classList.add("current");

        // Validations, currently only for presence. Adds a warning when lexxy is empty and RTE is being used, not HTML.
        this.comment_field.querySelector("input[type=submit]").onclick = () => {
            if(this.rte.classList.contains("lexxy-editor--empty") && this.rtf_link.classList.contains("current")) {
                let validation_messages = this.comment_field.querySelector("#lexxy_validation");
                this.rte.setCustomValidity(validation_messages.dataset.commenttooshort);
            } else {
                this.rte.setCustomValidity("");
            }
            this.rte.reportValidity();
        };

        // Fix for editing comments, it doesn't save the correct content without copying RTE's content to HTML editor.
        const update_button = this.comment_field.querySelector("input[value=Update]");
        if(update_button) {
            update_button.onclick = () => {
                this.copyContentToHTML();
            };
        }

        this.rtf_link.onclick = (e) => {
            e.preventDefault(); // so page scroll position don't reset
            if(!this.rtf_link.classList.contains("current")) {
                if (this.rte) {
                    this.switchToRTE();
                } else {
                    this.initializeLexxy();
                }
            }
        };

        this.html_link.onclick = (e) => {
            e.preventDefault(); // so page scroll position don't reset
            if(!this.html_link.classList.contains("current")) {
                this.switchToHTML();
            }
        };
    }

    // Try to create an element for Lexxy, if and when Lexxy initializes customize Lexxy the way we want.
    initializeLexxy() {
        let node = document.createRange().createContextualFragment("<lexxy-editor></lexxy-editor>");
        this.comment_field.querySelector("#lexxy_parent").appendChild(node);

        this.comment_field.addEventListener("lexxy:initialize", () => {
            this.rte = this.comment_field.querySelector("lexxy-editor");

            // add userstuff class to content to make it as WYSIWYG as possible
            this.rte.querySelector(".lexxy-editor__content").classList.add("userstuff");

            let attributes = this.comment_field.querySelector("#lexxy_attributes");
            this.rte.setAttribute("class", attributes.dataset.class); // character counter
            this.rte.setAttribute("title", attributes.dataset.title); // hover and screen readers
            this.rte.setAttribute("name", attributes.dataset.name); // so form knows this is for comment content
            this.rte.setAttribute("aria-labelledby", attributes.dataset.labelledby);

            this.rte.querySelector("lexxy-toolbar").setAttribute("aria-label", attributes.dataset.toolbarlabel);
            this.rte.querySelector(".lexxy-editor__content").setAttribute("aria-label", attributes.dataset.editorlabel);

            let selectors = "button[name=\"highlight\"], " +
                "button[name=\"code\"], " +
                "lexxy-code-language-picker";
            if(this.rte.querySelectorAll(selectors).length > 0) { // remove all the menus we don't want
                this.rte.querySelectorAll(selectors).forEach((elem) => elem.parentNode.removeChild(elem)); // for IE

                this.switchToRTE();
            }
        });
    }
}

// If exists, for the "main" commenting field of the page (e.g. a comment for the work) create an EditingField. For all
// the other commenting fields (e.g. reply to or edit of a comment) that might be added after the initial page load
// create an observer on DOM to catch when they are added and create EditingFields for each.
document.addEventListener("DOMContentLoaded", () => {
    let main_comment = document.querySelector("div.post.comment");
    if(main_comment !== null) {
        new EditingField(main_comment);
    }

    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Callback function to execute when mutations are observed
    const callback = (mutationList) => {
        for (const mutation of mutationList) {
            for (const addedNode of mutation.addedNodes) {
                if (addedNode.classList != null && addedNode.matches("div.post.comment")) {
                    new EditingField(addedNode);
                }
            }
        }
    };

    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    observer.observe(document, config);
});
