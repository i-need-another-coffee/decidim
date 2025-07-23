const selectors = [
  "a[data-confirm]",
  "a[data-method]",
  "a[data-remote]:not([disabled])",
  "a[data-disable-with]",
  "a[data-disable]",
  "select[data-remote]",
  "input[data-remote]",
  "textarea[data-remote]",
  "form:not([data-turbo=true])",
  "form:not([data-turbo=true]) input[type=submit]",
  "form:not([data-turbo=true]) input[type=image]",
  "form:not([data-turbo=true]) button[type=submit]",
  "form:not([data-turbo=true]) button:not([type])",
  "input[type=submit][form]",
  "input[type=image][form]",
  "button[type=submit][form]",
  "button[form]:not([type])",
  "input[data-disable-with]:enabled",
  "button[data-disable-with]:enabled",
  "textarea[data-disable-with]:enabled",
  "input[data-disable]:enabled",
  "button[data-disable]:enabled",
  "textarea[data-disable]:enabled",
  "input[data-disable-with]:disabled",
  "button[data-disable-with]:disabled",
  "textarea[data-disable-with]:disabled",
  "input[data-disable]:disabled",
  "button[data-disable]:disabled",
  "textarea[data-disable]:disabled",
  "input[name][type=file]:not([disabled])",
  "a[data-disable-with]",
  "a[data-disable]",
  "button[data-remote][data-disable-with]",
  "button[data-remote][data-disable]"
];
// const buttonClickSelector = {
//   selector: "button[data-remote]:not([form]), button[data-confirm]:not([form])",
//   exclude: "form button"
// };

const RailsUjsReplacement = () => {
  selectors.forEach((selector) => {
    document.querySelectorAll(selector).forEach((element) => {
      console.error(`Rails-UJS tag: Found element matching selector: ${selector}`, element);
    });
  });
};

const AggregatedRailsUjsReplacement = () => {
  const elements = document.querySelectorAll(selectors.join(", "));
  if (elements.length > 0) {
    alert("Rails-UJS tag: Found element matching selector:");
  };
};

// document.addEventListener("turbo:load", RailsUjsReplacement);
// document.addEventListener("turbo:load", AggregatedRailsUjsReplacement);
