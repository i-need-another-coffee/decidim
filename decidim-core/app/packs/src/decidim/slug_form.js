document.addEventListener("turbo:load", () => {
  const wrapper = document.querySelector(".slug");

  if (wrapper) {
    alert("slug");
  } else {
    return;
  }

  const input = wrapper.querySelector("input");
  const target = wrapper.querySelector("span.slug-url-value");

  if (!input || !target) {
    return;
  }

  input.addEventListener("keyup", (event) => {
    target.innerHTML = event.target.value;
  });
});
