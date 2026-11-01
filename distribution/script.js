/**
 * Myspoti iOS — Distribution Website Client Scripts
 * Handles dynamic GitHub Release resolution, installation tab switching,
 * FAQ accordions, and clipboard copy operations.
 */

document.addEventListener('DOMContentLoaded', () => {
  initTabs();
  initFAQ();
  initCopyButton();
  fetchLatestRelease();
});

/* --------------------------------------------------------------------------
   Installation Guide Tab Switching
   -------------------------------------------------------------------------- */
function initTabs() {
  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabContents = document.querySelectorAll('.tab-content');

  tabButtons.forEach(button => {
    button.addEventListener('click', () => {
      const targetId = button.getAttribute('data-tab');

      // Update button active state
      tabButtons.forEach(btn => btn.classList.remove('active'));
      button.classList.add('active');

      // Update content visibility
      tabContents.forEach(content => {
        if (content.id === targetId) {
          content.classList.add('active');
        } else {
          content.classList.remove('active');
        }
      });
    });
  });
}

/* --------------------------------------------------------------------------
   FAQ Accordion
   -------------------------------------------------------------------------- */
function initFAQ() {
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    if (!questionBtn) return;

    questionBtn.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      // Optional: close other open items for cleaner accordion
      faqItems.forEach(otherItem => {
        if (otherItem !== item) {
          otherItem.classList.remove('active');
          const otherBtn = otherItem.querySelector('.faq-question');
          if (otherBtn) otherBtn.setAttribute('aria-expanded', 'false');
        }
      });

      if (isActive) {
        item.classList.remove('active');
        questionBtn.setAttribute('aria-expanded', 'false');
      } else {
        item.classList.add('active');
        questionBtn.setAttribute('aria-expanded', 'true');
      }
    });
  });
}

/* --------------------------------------------------------------------------
   SHA-256 Copy to Clipboard
   -------------------------------------------------------------------------- */
function initCopyButton() {
  const copyBtn = document.getElementById('copy-checksum-btn');
  const checksumText = document.getElementById('checksum-value');

  if (!copyBtn || !checksumText) return;

  copyBtn.addEventListener('click', async () => {
    const textToCopy = checksumText.textContent.trim();
    if (!textToCopy) return;

    try {
      await navigator.clipboard.writeText(textToCopy);
      const originalHTML = copyBtn.innerHTML;
      copyBtn.innerHTML = `
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg> Copied!
      `;
      copyBtn.style.color = '#34d399';

      setTimeout(() => {
        copyBtn.innerHTML = originalHTML;
        copyBtn.style.color = '';
      }, 2000);
    } catch (err) {
      console.warn('Clipboard write failed:', err);
    }
  });
}

/* --------------------------------------------------------------------------
   GitHub Release Dynamic Metadata Fetching
   -------------------------------------------------------------------------- */
async function fetchLatestRelease() {
  const repoOwner = 'achrafsamih05';
  const repoName = 'myspoti';
  const apiEndpoint = `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;

  const versionEl = document.getElementById('release-version');
  const dateEl = document.getElementById('release-date');
  const sizeEl = document.getElementById('release-size');
  const downloadBtn = document.getElementById('download-ipa-btn');
  const checksumVal = document.getElementById('checksum-value');
  const releasePageLink = document.getElementById('release-page-link');

  try {
    const response = await fetch(apiEndpoint, {
      headers: { 'Accept': 'application/vnd.github.v3+json' }
    });

    if (!response.ok) {
      // Fallback: Release may not be published yet or GitHub API rate limit reached
      console.info(`GitHub release API returned status ${response.status}. Using default metadata.`);
      return;
    }

    const releaseData = await response.json();

    // 1. Update Version
    if (releaseData.tag_name && versionEl) {
      versionEl.textContent = releaseData.tag_name;
    }

    // 2. Update Published Date
    if (releaseData.published_at && dateEl) {
      const pubDate = new Date(releaseData.published_at);
      dateEl.textContent = pubDate.toLocaleDateString(undefined, {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    }

    // 3. Update Release Page Link
    if (releaseData.html_url && releasePageLink) {
      releasePageLink.href = releaseData.html_url;
    }

    // 4. Find IPA Asset & Checksum Asset
    if (Array.isArray(releaseData.assets)) {
      const ipaAsset = releaseData.assets.find(a => a.name.endsWith('.ipa'));
      if (ipaAsset) {
        if (downloadBtn) {
          downloadBtn.href = ipaAsset.browser_download_url;
        }
        if (sizeEl && ipaAsset.size) {
          const mbSize = (ipaAsset.size / (1024 * 1024)).toFixed(1);
          sizeEl.textContent = `~${mbSize} MB`;
        }
      }

      // Check for SHA256SUMS.txt
      const checksumAsset = releaseData.assets.find(a => a.name === 'SHA256SUMS.txt');
      if (checksumAsset && checksumVal) {
        fetchChecksumText(checksumAsset.browser_download_url, checksumVal);
      }
    }
  } catch (error) {
    console.debug('Failed to fetch release dynamically:', error);
  }
}

async function fetchChecksumText(url, targetElement) {
  try {
    const res = await fetch(url);
    if (!res.ok) return;
    const text = await res.text();
    // Parse standard sha256sum line: "<hash>  Myspoti.ipa"
    const match = text.match(/([a-fA-F0-9]{64})/);
    if (match && match[1]) {
      targetElement.textContent = match[1];
    }
  } catch {
    // Ignore, keep fallback
  }
}
