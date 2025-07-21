const m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;
const matches = function(element, selector) {
  if (selector.exclude) {
    return m.call(element, selector.selector) && !m.call(element, selector.exclude);
  } else {
    return m.call(element, selector);
  }
};

const delegate = (element, selector, eventType, handler) => element.addEventListener(eventType, (function(e) {
  let {target: target} = e;
  while (!!(target instanceof Element) && !matches(target, selector)) {
    target = target.parentNode;
  }
  if (target instanceof Element && handler.call(target, e, eventType, e.target) === false) {
    e.preventDefault();
    e.stopPropagation();
  }
}));

const linkClickSelector = "a[data-confirm], a[data-method], a[data-remote]:not([disabled]), a[data-disable-with], a[data-disable]";
const buttonClickSelector = {
  selector: "button[data-remote]:not([form]), button[data-confirm]:not([form])",
  exclude: "form button"
};
const inputChangeSelector = "select[data-remote], input[data-remote], textarea[data-remote]";
const formSubmitSelector = "form:not([data-turbo=true])";
const formInputClickSelector = "form:not([data-turbo=true]) input[type=submit], form:not([data-turbo=true]) input[type=image], form:not([data-turbo=true]) button[type=submit], form:not([data-turbo=true]) button:not([type]), input[type=submit][form], input[type=image][form], button[type=submit][form], button[form]:not([type])";
const formDisableSelector = "input[data-disable-with]:enabled, button[data-disable-with]:enabled, textarea[data-disable-with]:enabled, input[data-disable]:enabled, button[data-disable]:enabled, textarea[data-disable]:enabled";
const formEnableSelector = "input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled, input[data-disable]:disabled, button[data-disable]:disabled, textarea[data-disable]:disabled";
const fileInputSelector = "input[name][type=file]:not([disabled])";
const linkDisableSelector = "a[data-disable-with], a[data-disable]";
const buttonDisableSelector = "button[data-remote][data-disable-with], button[data-remote][data-disable]";

const genericDeprecatedHandler = (func, e, eventType, element) => {

  alert(`Decidim.railsUjsReplacement.${func} is deprecated. Please switch to turbo instead.`);

  console.error(`${func} fired ${eventType} on`, element);
  e.preventDefault();
  e.stopPropagation();
  e.stopImmediatePropagation();
}

const enableDeprecatedElement = (e, eventType, element) => {
  genericDeprecatedHandler("enableDeprecatedElement", e, eventType, element);
}

const preventDeprecatedInsignificantClick = (e, eventType, element) => {
  genericDeprecatedHandler("preventDeprecatedInsignificantClick", e, eventType, element);
}
const handleDeprecatedDisabledElement = (e, eventType, element) => {
  genericDeprecatedHandler("handleDeprecatedDisabledElement", e, eventType, element);
}
const handleDeprecatedConfirm = (e, eventType, element) => {
  genericDeprecatedHandler("handleDeprecatedConfirm", e, eventType, element);
}
const disableDeprecatedElement = (e, eventType, element) => {
  genericDeprecatedHandler("disableDeprecatedElement", e, eventType, element);
}

const handleDeprecatedRemote = (e, eventType, element) => {
  genericDeprecatedHandler("handleDeprecatedRemote", e, eventType, element);
}
const handleDeprecatedMethod = (e, eventType, element) => {
  genericDeprecatedHandler("handleDeprecatedMethod", e, eventType, element);
}
const formDeprecatedSubmitButtonClick = (e, eventType, element) => {
  genericDeprecatedHandler("formDeprecatedSubmitButtonClick", e, eventType, element);
}

class RailsUjsReplacement {

  constructor() {}

  static start() {
    (new RailsUjsReplacement()).start();
  }
  start() {

    // delegate(document, linkDisableSelector, "ajax:complete", enableDeprecatedElement);
    // delegate(document, linkDisableSelector, "ajax:stopped", enableDeprecatedElement);
    // delegate(document, buttonDisableSelector, "ajax:complete", enableDeprecatedElement);
    // delegate(document, buttonDisableSelector, "ajax:stopped", enableDeprecatedElement);
    delegate(document, linkClickSelector, "click", preventDeprecatedInsignificantClick);
    // delegate(document, linkClickSelector, "click", handleDeprecatedDisabledElement);
    // delegate(document, linkClickSelector, "click", handleDeprecatedConfirm);
    // delegate(document, linkClickSelector, "click", disableDeprecatedElement);
    // delegate(document, linkClickSelector, "click", handleDeprecatedRemote);
    // delegate(document, linkClickSelector, "click", handleDeprecatedMethod);
    // delegate(document, buttonClickSelector, "click", preventDeprecatedInsignificantClick);
    // delegate(document, buttonClickSelector, "click", handleDeprecatedDisabledElement);
    // delegate(document, buttonClickSelector, "click", handleDeprecatedConfirm);
    // delegate(document, buttonClickSelector, "click", disableDeprecatedElement);
    // delegate(document, buttonClickSelector, "click", handleDeprecatedRemote);
    // delegate(document, inputChangeSelector, "change", handleDeprecatedDisabledElement);
    // delegate(document, inputChangeSelector, "change", handleDeprecatedConfirm);
    // delegate(document, inputChangeSelector, "change", handleDeprecatedRemote);
    // delegate(document, formSubmitSelector, "submit", handleDeprecatedDisabledElement);
    // delegate(document, formSubmitSelector, "submit", handleDeprecatedConfirm);
    // delegate(document, formSubmitSelector, "submit", handleDeprecatedRemote);
    // delegate(document, formSubmitSelector, "submit", (e => setTimeout((() => disableDeprecatedElement(e)), 13)));
    // delegate(document, formSubmitSelector, "ajax:send", disableDeprecatedElement);
    // delegate(document, formSubmitSelector, "ajax:complete", enableDeprecatedElement);
    // delegate(document, formInputClickSelector, "click", preventDeprecatedInsignificantClick);
    // delegate(document, formInputClickSelector, "click", handleDeprecatedDisabledElement);
    // delegate(document, formInputClickSelector, "click", handleDeprecatedConfirm);
    // delegate(document, formInputClickSelector, "click", formDeprecatedSubmitButtonClick);

  }
};

document.addEventListener("turbo:load", () => { RailsUjsReplacement.start();});
