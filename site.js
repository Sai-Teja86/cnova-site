// Phone menu toggle, and the trial request form (opens the visitor's mail app; nothing is sent from this site).
const header = document.querySelector(".top");
const btn = document.querySelector(".menu-btn");
btn?.addEventListener("click", () => {
  const open = header.classList.toggle("open");
  btn.setAttribute("aria-expanded", String(open));
});

const form = document.getElementById("trial");
form?.addEventListener("submit", (e) => {
  e.preventDefault();
  const f = new FormData(form);
  const lines = [
    `Name: ${f.get("name")}`,
    `Company: ${f.get("company")}`,
    `Work email: ${f.get("email")}`,
    `Servers and devices to manage: ${f.get("size")}`,
    "",
    String(f.get("message") || ""),
  ];
  const to = form.dataset.to;
  location.href = `mailto:${to}?subject=${encodeURIComponent("Vaultgate trial: " + f.get("company"))}&body=${encodeURIComponent(lines.join("\n"))}`;
});
