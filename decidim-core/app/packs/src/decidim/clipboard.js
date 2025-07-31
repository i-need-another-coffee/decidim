import select from "select";

/**
 * This provides functionality to add clipboard copy functionality to buttons
 * on the page. The element to be copied from has to be defined for the button
 * using a `data` attribute and the target element has to be a form input.
 *
 * Usage:
 *   1. Create the button:
 *     <button class="button"
 *      data-clipboard-copy="#target-input-element"
 *      data-clipboard-copy-label="Copied!"
 *      data-clipboard-copy-message="The text was successfully copied to clipboard."
 *      aria-label="Copy the text to clipboard">
 *        <%= icon "clipboard", role: "presentation", "aria-hidden": true %>
 *        Copy to clipboard
 *    </button>
 *
 *   2. Make sure the target element exists on the page:
 *     <input id="target-input-element" type="text" value="This text will be copied.">
 *
 * Options through data attributes:
 * - `data-clipboard-copy` = The jQuery selector for the target input element
 *   where text will be copied from. If this element does not contain any visible text (for instance is an image),
 *   the selector indicated in here will be used to place the confirmation message.
 * - `data-clipboard-content` = The text that will be copied. If empty or not present, the target input element will be used.
 * - `data-clipboard-copy-label` = The label that will be shown in the button
 *   after a succesful copy.
 * - `data-clipboard-copy-message` = The text that will be announced to screen
 *   readers after a successful copy.
 */

// How long the "copied" text is shown in the copy element after successful
// copy.
const CLIPBOARD_COPY_TIMEOUT = 5000;


class ClipboardCopy {
  constructor(button) {
    this.button = button;
    this.timeoutId = null;
    this.initialize();
  }

  initialize() {
    const dataset = this.button.dataset;
    this.targetSelector = dataset.clipboardCopy;
    this.content = dataset.clipboardContent || "";
    this.label = dataset.clipboardCopyLabel;
    this.message = dataset.clipboardCopyMessage;
    this.originalLabel = dataset.clipboardCopyLabelOriginal;
    this.input = this.targetSelector
      ? document.querySelector(this.targetSelector)
      : null;
  }

  copyToClipboard() {
    const selectedText = this.getSelectedText();
    if (!selectedText) {
      return;
    }

    this.createTemporaryElement(selectedText);
    this.showCopiedLabel();
    this.showScreenReaderMessage();

  }


  getSelectedText() {
    if (this.content) {
      return this.content;
    }

    if (!this.input || !(/(input|textarea|select)/i).test(this.input.tagName)) {
      return null;
    }

    return select(this.input);
  }

  createTemporaryElement(text) {
    const temp = document.createElement("textarea");
    temp.value = text;
    temp.style.width = "1px";
    temp.style.height = "1px";
    document.body.appendChild(temp);
    temp.select();

    try {
      if (!document.execCommand("copy")) {
        return;
      }
    } finally {
      document.body.removeChild(temp);
      this.button.focus();
    }
  }

  showCopiedLabel() {
    if (!this.label) {
      return;
    }

    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }

    if (!this.originalLabel) {
      this.button.dataset.clipboardCopyLabelOriginal = this.button.innerHTML;
    }

    this.button.innerHTML = this.label;

    this.timeoutId = setTimeout(() => {
      this.button.innerHTML = this.button.dataset.clipboardCopyLabelOriginal;

      Reflect.deleteProperty(this.button.dataset, "clipboardCopyLabelOriginal");
      Reflect.deleteProperty(this, "timeoutId");
    }, CLIPBOARD_COPY_TIMEOUT);

    this.button.dataset.clipboardCopyLabelTimeout = this.timeoutId;
  }

  showScreenReaderMessage() {
    if (!this.message) {
      return;
    }

    let msg = document.createElement("div");
    msg.setAttribute("role", "alert");
    msg.setAttribute("aria-live", "assertive");
    msg.setAttribute("aria-atomic", "true");
    msg.className = "sr-only";
    this.button.appendChild(msg);
    this.button.dataset.clipboardMessageElement = msg;

    msg.innerHTML = `${this.message}&nbsp;`;
  }
}

document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-clipboard-copy]").forEach((button) => {
    const instance = new ClipboardCopy(button);

    button.addEventListener("click", () => instance.copyToClipboard());
  });
});
