// Phone menu toggle, knowledge base search and section highlight, and the trial request form (opens the visitor's mail app; nothing is sent from this site).
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

// Knowledge base: filter articles as you type, and highlight the section being read.
const q = document.getElementById("kb-q");
if (q) {
  const articles = [...document.querySelectorAll(".kb-body article")];
  const cats = [...document.querySelectorAll(".kb-cat")];
  const navLinks = new Map([...document.querySelectorAll(".kb-nav a")].map((a) => [a.getAttribute("href").slice(1), a]));
  q.addEventListener("input", () => {
    const words = q.value.toLowerCase().split(/\s+/).filter(Boolean);
    let shown = 0;
    for (const a of articles) {
      const hit = words.every((w) => a.textContent.toLowerCase().includes(w));
      a.hidden = !hit;
      navLinks.get(a.id)?.toggleAttribute("hidden", !hit);
      shown += hit;
    }
    for (const c of cats) {  // a category heading shows while any of its articles does
      let el = c.nextElementSibling, any = false;
      while (el && el.tagName === "ARTICLE") { any ||= !el.hidden; el = el.nextElementSibling; }
      c.hidden = !any;
    }
    document.querySelector(".kb-none").hidden = shown > 0;
  });
  const seen = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (!e.isIntersecting) continue;
      navLinks.forEach((a) => a.classList.remove("on"));
      navLinks.get(e.target.id)?.classList.add("on");
    }
  }, { rootMargin: "-90px 0px -70% 0px" });
  articles.forEach((a) => seen.observe(a));
}
