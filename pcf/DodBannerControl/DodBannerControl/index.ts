import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class DodBannerControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {

    private _container!: HTMLDivElement;
    private _bannerRoot: HTMLDivElement | null = null;
    private _clickListeners: { el: Element; fn: EventListener }[] = [];
    private _rendered = false;

    private static readonly COOKIE_NAME = "Accepted";
    private static readonly DEFAULT_EXPIRY_DAYS = 30;
    private static readonly DEFAULT_CONSENT_TEXT =
        "WARNING: This is a U.S. Government computer system, which may be accessed " +
        "and used only for authorized Government business by authorized personnel. " +
        "Unauthorized access or use of this computer system may subject violators to " +
        "criminal, civil, and/or administrative action. All information on this system " +
        "may be intercepted, recorded, read, copied, and disclosed by and to authorized " +
        "personnel for official purposes, including criminal investigations. Such " +
        "information includes sensitive data encrypted to comply with confidentiality " +
        "and privacy requirements. Access or use of this computer system by any person, " +
        "whether authorized or unauthorized, constitutes consent to these terms. " +
        "There is no right of privacy in this system.";

    constructor() { /* empty */ }

    // ── Cookie helpers ────────────────────────────────────────────────────────

    private setCookie(name: string, value: string, days: number): void {
        const expiry = new Date();
        expiry.setTime(expiry.getTime() + days * 24 * 60 * 60 * 1000);
        document.cookie =
            name + "=" + value +
            ";expires=" + expiry.toUTCString() +
            ";path=/;SameSite=Lax";
    }

    private getCookie(name: string): string {
        const prefix = name + "=";
        for (const part of decodeURIComponent(document.cookie).split(";")) {
            const c = part.trimStart();
            if (c.indexOf(prefix) === 0) return c.substring(prefix.length);
        }
        return "";
    }

    // ── Animation helpers ─────────────────────────────────────────────────────

    private fadeIn(el: HTMLElement, duration: number): void {
        el.style.opacity = "0";
        el.style.display = "block";
        let start: number | null = null;
        const step = (ts: number) => {
            if (!start) start = ts;
            const p = Math.min((ts - start) / duration, 1);
            el.style.opacity = String(p);
            if (p < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
    }

    private fadeOut(el: HTMLElement, duration: number): void {
        let start: number | null = null;
        const step = (ts: number) => {
            if (!start) start = ts;
            const p = Math.min((ts - start) / duration, 1);
            el.style.opacity = String(1 - p);
            if (p < 1) {
                requestAnimationFrame(step);
            } else {
                el.style.display = "none";
                el.style.opacity = "";
            }
        };
        requestAnimationFrame(step);
    }

    // ── Banner rendering ──────────────────────────────────────────────────────

    private buildModal(consentText: string): void {
        if (document.getElementById("cookieConsent")) return;

        const text = (consentText && consentText.trim())
            ? consentText
            : DodBannerControl.DEFAULT_CONSENT_TEXT;

        const closeBtn = document.createElement("a");
        closeBtn.id = "closeCookieConsent";
        closeBtn.textContent = "\u2715";

        const p = document.createElement("p");
        p.textContent = text;  // textContent prevents XSS

        const okBtn = document.createElement("a");
        okBtn.className = "cookieConsentOK";
        okBtn.textContent = "I Acknowledge";

        const modal = document.createElement("div");
        modal.id = "cookieConsent";
        modal.appendChild(closeBtn);
        modal.appendChild(p);
        modal.appendChild(okBtn);

        const overlay = document.createElement("div");
        overlay.className = "consentBackground";

        this._bannerRoot = document.createElement("div");
        this._bannerRoot.setAttribute("data-dodbl-pcf", "1");
        this._bannerRoot.appendChild(modal);
        this._bannerRoot.appendChild(overlay);

        document.body.appendChild(this._bannerRoot);
    }

    private showBanner(expiryDays: number): void {
        if (this.getCookie(DodBannerControl.COOKIE_NAME) !== "") return;

        const modal = document.getElementById("cookieConsent") as HTMLElement | null;
        const bg = document.querySelector(".consentBackground") as HTMLElement | null;
        if (!modal || !bg) return;

        setTimeout(() => {
            this.fadeIn(modal, 200);
            bg.style.display = "block";
        }, 800);

        const dismiss = () => {
            this.setCookie(DodBannerControl.COOKIE_NAME, "Yes", expiryDays);
            this.fadeOut(modal, 200);
            bg.style.display = "none";
        };

        document.querySelectorAll("#closeCookieConsent, .cookieConsentOK").forEach(el => {
            const handler: EventListener = () => dismiss();
            el.addEventListener("click", handler);
            this._clickListeners.push({ el, fn: handler });
        });
    }

    // ── Classification bar ────────────────────────────────────────────────────

    private getClassificationColor(bannerType: string): string {
        const bt = bannerType.toUpperCase();
        if (bt.startsWith("CU")) return "#5a04b0";  // CUI
        if (bt.startsWith("U"))  return "#5cb85c";  // UNCLASSIFIED
        if (bt.startsWith("CO")) return "#286090";  // CONFIDENTIAL
        if (bt.startsWith("S"))  return "#d9534f";  // SECRET
        if (bt.startsWith("T"))  return "#f0ad4e";  // TOP SECRET
        return "#5e5e5e";                            // default / unknown
    }

    private clearBar(): void {
        if (!this._container.hasAttribute("data-dodbl-bar")) return;
        this._container.removeAttribute("data-dodbl-bar");
        this._container.textContent = "";
        this._container.style.backgroundColor = "";
        this._container.style.color = "";
        this._container.style.fontWeight = "";
        this._container.style.fontFamily = "";
        this._container.style.fontSize = "";
        this._container.style.display = "";
        this._container.style.height = "";
        this._container.style.boxSizing = "";
        this._container.style.alignItems = "";
        this._container.style.justifyContent = "";
        this._container.style.letterSpacing = "";
        this._container.style.textShadow = "";
    }

    private renderClassificationBar(bannerType: string): void {
        this.clearBar();
        const color = this.getClassificationColor(bannerType);
        this._container.setAttribute("data-dodbl-bar", "1");
        this._container.textContent = bannerType.toUpperCase();
        this._container.style.backgroundColor = color;
        this._container.style.color = "#fff";
        this._container.style.fontWeight = "bold";
        this._container.style.fontFamily = '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif';
        this._container.style.fontSize = "14px";
        this._container.style.display = "flex";
        // Use explicit pixel height from parent when available so the bar fills
        // the allocated space in both the test harness and Canvas App runtime.
        // Fall back to "100%" for environments where offsetHeight is not yet set.
        const parentHeight = this._container.parentElement?.offsetHeight ?? 0;
        this._container.style.height = parentHeight > 0 ? `${parentHeight}px` : "100%";
        this._container.style.boxSizing = "border-box";
        this._container.style.alignItems = "center";
        this._container.style.justifyContent = "center";
        this._container.style.letterSpacing = "0.06em";
        this._container.style.textShadow = "1px 1px 0 rgba(0,0,0,.3)";
    }

    private renderBanner(context: ComponentFramework.Context<IInputs>): void {
        const enabled = context.parameters.bannerEnabled.raw;
        if (enabled === false || enabled === null) return;

        const bannerType = ((context.parameters.bannerType.raw) || "DoD").trim();
        const expiry = context.parameters.consentExpiryDays.raw;
        const expiryDays = (expiry !== null && expiry !== undefined && !isNaN(expiry) && expiry >= 0)
            ? expiry
            : DodBannerControl.DEFAULT_EXPIRY_DAYS;
        const consentText = context.parameters.consentText.raw || "";

        if (bannerType === "DoD") {
            // Consent modal: clear any classification bar, hide container, render full-page overlay
            this.clearBar();
            this._container.style.display = "none";
            this.buildModal(consentText);
            this.showBanner(expiryDays);
        } else {
            // Classification bar: show the PCF container and render colored bar inside it
            this._container.style.display = "block";
            this.renderClassificationBar(bannerType);
        }
    }

    // ── PCF lifecycle ─────────────────────────────────────────────────────────

    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._container = container;
        this._rendered = true;
        this.renderBanner(context);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): void {
        if (!this._rendered) return;
        const bannerType = ((context.parameters.bannerType.raw) || "DoD").trim();
        if (bannerType === "DoD") {
            // Re-show consent modal only if cookie not yet set
            if (this.getCookie(DodBannerControl.COOKIE_NAME) === "") {
                this.renderBanner(context);
            }
        } else {
            // Always re-render classification bar (bannerType may have changed)
            this.renderBanner(context);
        }
    }

    public getOutputs(): IOutputs {
        return {};
    }

    public destroy(): void {
        this._clickListeners.forEach(({ el, fn }) => el.removeEventListener("click", fn));
        this._clickListeners = [];
        if (this._bannerRoot && this._bannerRoot.parentNode) {
            this._bannerRoot.parentNode.removeChild(this._bannerRoot);
        }
        this.clearBar();
    }
}
