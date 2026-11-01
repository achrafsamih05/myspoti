# Myspoti iOS — Public Distribution Website

This directory contains the public download portal and sideloading documentation for **Myspoti iOS**, deployed to GitHub Pages at:

🔗 **`https://achrafsamih05.github.io/myspoti/`**

---

## 1. Directory Structure

```text
distribution/
├── index.html            # Main landing page (Hero, Download, Sideloading Guide, FAQ, Footer)
├── styles.css            # Dark AMOLED design system with native iOS aesthetic
├── script.js             # Dynamic GitHub Releases resolver, tab switcher, FAQ accordion, clipboard
├── INSTALLATION.md       # Standalone Markdown guide for sideloading unsigned IPAs
├── RELEASE_PROCEDURE.md  # Step-by-step guide for publishing GitHub Releases
└── README.md             # Documentation for this distribution directory
```

---

## 2. Key Features

- **True Dark AMOLED Palette**: Built with deep black (`#050507`), high-contrast typography, and emerald accents.
- **Dynamic Release Resolution**: Queries GitHub API (`/repos/achrafsamih05/myspoti/releases/latest`) to dynamically display the latest version tag, download URL, release date, file size, and SHA-256 checksum. Gracefully falls back to hardcoded defaults if offline or rate-limited.
- **Unsigned Binary Notice**: Transparently informs users that the distributed IPA is unsigned and requires personal code signing via a free Apple ID.
- **Step-by-Step Sideloading Guides**: Detailed walkthroughs for **Sideloadly** (Windows 11), **AltStore Classic**, and **SideStore** (on-device Wi-Fi renewal).
- **Interactive Elements**: Tabbed installation switcher, 1-click SHA-256 copy button with visual feedback, accessible FAQ accordions.
- **Legal Compliance & GPL-3.0**: Retains full attribution to the upstream project ([kota-zo/myspoti](https://github.com/kota-zo/myspoti)) and includes explicit non-affiliation disclaimers regarding Spotify AB and Apple Inc.

---

## 3. Local Testing

You can preview the distribution website locally without installing extra dependencies:

### Using Python
```powershell
python -m http.server -d distribution 8080
```
Open [http://localhost:8080](http://localhost:8080) in your web browser.

### Using Node.js / npx
```powershell
npx serve distribution
```

---

## 4. Continuous Deployment via GitHub Actions

This directory is deployed to GitHub Pages automatically via [`.github/workflows/deploy-distribution.yml`](../.github/workflows/deploy-distribution.yml):
- Triggers on any push modifying `distribution/**` or the workflow file itself.
- Supports manual deployment via `workflow_dispatch`.
- Employs official `actions/upload-pages-artifact` and `actions/deploy-pages`.
