/* eslint no-unused-vars: 0 */
import Tribute from "src/decidim/vendor/tribute"


class Mentions {
  constructor(container, options = {}) {
    this.container = container;
    this.options = options;
    this.tribute = null;
    this.init();
  }

  init() {
    if (!this.container || this.container.closest(".editor")) {
      // Prevent initialization inside the editor
      return;
    }

    const noDataFoundMessage =
      this.container.getAttribute("data-noresults") || null;
    const noMatchTemplate = noDataFoundMessage
      ? () => `<li>${noDataFoundMessage}</li>`
      : null;

    this.tribute = new Tribute({
      trigger: "@",
      values: this.debounce(this.remoteSearch.bind(this), 250),
      positionMenu: true,
      menuContainer: null,
      allowSpaces: true,
      menuItemLimit: 5,
      fillAttr: "nickname",
      selectClass: "highlight",
      noMatchTemplate: noMatchTemplate,
      lookup: (item) => item.nickname + item.name,
      selectTemplate: (item) => (item
        ? item.original.nickname
        : null),
      menuItemTemplate: (item) =>
        `
        <img src="${item.original.avatarUrl}" alt="author-avatar">
        <strong>${item.original.nickname}</strong>
        <small>${item.original.name}</small>
      `,
      ...this.options.tribute
    });

    this.setupEvents(this.container);
    this.tribute.attach(this.container);
  }

  debounce(callback, wait) {
    let timeout = null;
    return (...args) => {
      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(() => {
        timeout = null;
        Reflect.apply(callback, this, args)
      }, wait);
    };
  }

  remoteSearch(text, cb) {
    const query = `{users(filter:{wildcard:"${text}"}){nickname,name,avatarUrl,__typename}}`;
    fetch(window.Decidim.config.get("api_path"), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query })
    }).
      then((response) => response.json()).
      then((data) => {
        const users = data?.data?.users || {};
        cb(users);
      }).
      catch(() => cb([])).
      finally(() => {
        const $parent = this.tribute.current?.element?.parentNode;

        if ($parent) {
          $parent.classList.add("is-active");
          const $tribute = $parent.querySelector(".tribute-container");
          $tribute?.removeAttribute("style");
        }
      });
  }

  setupEvents($mentionContainer) {
    $mentionContainer.addEventListener("focusin", (event) => {
      this.tribute.menuContainer = event.target.parentNode;
    });

    $mentionContainer.addEventListener("focusout", ({ target }) => {
      target.parentNode.classList.remove("is-active");
    });

    $mentionContainer.addEventListener("input", ({ target }) => {
      const $parent = target.parentNode;
      if (this.tribute.isActive) {
        const $tribute = document.querySelector(".tribute-container");
        $parent.append($tribute);

        $parent.classList.add("is-active");
      } else {
        $parent.classList.remove("is-active");
      }
    });
  }

  attachElement(element) {
    if (!element) {
      return;
    }

    this.tribute.attach(element);
    this.setupEvents(element);

    if (this.tribute.menu && !document.body.contains(this.tribute.menu)) {
      this.tribute.range.getDocument().body.appendChild(this.tribute.menu);
    }
  }
}

export default Mentions;
