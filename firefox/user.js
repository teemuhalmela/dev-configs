user_pref("browser.contentblocking.category", "custom");
user_pref("browser.discovery.enabled", false);
user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
user_pref("browser.search.widget.inNavBar", false);
user_pref("browser.search.hiddenOneOffs", "Google,Bing,Amazon.com,eBay,Twitter,Wikipedia (en)");

// Do not recommend extensions
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false);

// Restore session on startup
user_pref("browser.startup.page", 3);
user_pref("browser.sessionstore.warnOnQuit", false);

// Disable askin these permissions
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.microphone", 2);

user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);

user_pref("signon.rememberSignons", false);
user_pref("media.autoplay.default", 5);
user_pref("xpinstall.whitelist.required", true);
user_pref("dom.disable_open_during_load", true);

user_pref("layout.spellcheckDefault", 0);

// Play DRM content
user_pref("media.eme.enabled", false);

user_pref("datareporting.healthreport.uploadEnabled", true);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

user_pref("browser.safebrowsing.malware.enabled", true);
user_pref("browser.safebrowsing.phishing.enabled", true);
user_pref("browser.safebrowsing.downloads.enabled", true);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", true);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", true);

user_pref("browser.formfill.enable", true);
user_pref("places.history.enabled", true);
user_pref("privacy.history.custom", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", false);

// Block all third party
user_pref("network.cookie.cookieBehavior", 1);

// Do not show highlights on empty tab
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
