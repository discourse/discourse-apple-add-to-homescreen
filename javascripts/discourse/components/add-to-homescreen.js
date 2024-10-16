import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import discourseLater from "discourse-common/lib/later";
import { bind } from "discourse-common/utils/decorators";
import I18n from "I18n";

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
    return I18n.t(themePrefix("pwa_text"), {
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
}
