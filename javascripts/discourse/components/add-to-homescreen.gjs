import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import HomeLogo from "discourse/components/header/home-logo";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import htmlSafe from "discourse/helpers/html-safe";
import { bind } from "discourse/lib/decorators";
import discourseLater from "discourse/lib/later";
import { i18n } from "discourse-i18n";

export default class AddToHomescreen extends Component {
  @service capabilities;
  @service currentUser;
  @service keyValueStore;
  @service site;

  @tracked hasHiddenPopup = this.keyValueStore.getItem("hasHiddenPopup");
  @tracked showPopupTimer = false;
  @tracked arrowUp = window.matchMedia("(orientation: landscape)").matches;
  @tracked animate = false;

  constructor() {
    super(...arguments);

    discourseLater(() => {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }

      this.showPopupTimer = true;
    }, settings.popup_timer);
  }

  get shouldRender() {
    const appleMobile = this.capabilities.isIOS || this.capabilities.isIpadOS;
    const isPWA = this.capabilities.isPwa;
    const isHub = this.capabilities.wasLaunchedFromDiscourseHub;

    if (
      this.currentUser &&
      this.showPopupTimer &&
      appleMobile &&
      !this.hasHiddenPopup &&
      !isPWA &&
      !isHub
    ) {
      discourseLater(() => {
        this.animate = true;
      }, 125);
      return true;
    }
  }

  get PWALabel() {
    return i18n(themePrefix("pwa_text"), {
      siteTitle: this.site.siteSettings.title,
    });
  }

  @action
  setup() {
    if (this.capabilities.isIpadOS) {
      this.arrowUp = true;
      return;
    }

    window
      .matchMedia("(orientation: landscape)")
      .addEventListener("change", this.handleOrientationChange);
  }

  @action
  teardown() {
    window
      .matchMedia("(orientation: landscape)")
      .removeEventListener("change", this.handleOrientationChange);
  }

  @action
  hidePopup() {
    this.keyValueStore.setItem("hasHiddenPopup", true);
    this.hasHiddenPopup = true;
  }

  @bind
  handleOrientationChange(event) {
    this.arrowUp = event.matches;
  }

  <template>
    {{#if this.shouldRender}}
      <DButton
        @action={{this.hidePopup}}
        @icon="xmark"
        class="add-to-homescreen-outlet__button btn-flat"
      />
      <div
        {{didInsert this.setup}}
        {{willDestroy this.teardown}}
        class={{concatClass
          "add-to-homescreen-outlet__content"
          (if this.animate "animate")
        }}
      >
        <HomeLogo />
        <span class="add-to-homescreen__description">
          {{htmlSafe this.PWALabel}}
          {{#if this.arrowUp}}
            {{icon "arrow-up"}}
          {{else}}
            {{icon "arrow-down"}}
          {{/if}}
        </span>
      </div>
    {{/if}}
  </template>
}
