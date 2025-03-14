import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import {
  COLOR_SCHEME_OVERRIDE_KEY,
  colorSchemeOverride,
} from "../lib/color-scheme-override";


export default class ColorSchemeToggler extends Component {
  @service keyValueStore;
  @service session;

  @tracked
  storedOverride = this.keyValueStore.getItem(COLOR_SCHEME_OVERRIDE_KEY);
  
  get toggleButtonIcon() {
    switch (this.OSMode) {
      case "dark":
        this.storedOverride === "light" ? document.body.classList.remove("dark"): document.body.classList.add("dark");
        return this.storedOverride === "light" ? "moon" : "sun";
      case "light":
        this.storedOverride === "dark" ? document.body.classList.add("dark"): document.body.classList.remove("dark");
        return this.storedOverride === "dark" ? "sun" : "moon";
    }
  }

  get OSMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  @action
  toggleScheme() {
    switch (this.OSMode) {
      case "light":
        if (this.keyValueStore.getItem(COLOR_SCHEME_OVERRIDE_KEY) === "dark") {
          this.keyValueStore.removeItem(COLOR_SCHEME_OVERRIDE_KEY);
          document.body.classList.remove("dark");
        } else {
          this.keyValueStore.setItem(COLOR_SCHEME_OVERRIDE_KEY, "dark");
          document.body.classList.add("dark");
        }
        break;
      case "dark":
        if (this.keyValueStore.getItem(COLOR_SCHEME_OVERRIDE_KEY) !== "light") {
          this.keyValueStore.setItem(COLOR_SCHEME_OVERRIDE_KEY, "light");
          document.body.classList.remove("light");
        } else {
          document.body.classList.add("dark");
          this.keyValueStore.removeItem(COLOR_SCHEME_OVERRIDE_KEY);
        }
        break;
    }

    this.storedOverride =
      this.keyValueStore.getItem(COLOR_SCHEME_OVERRIDE_KEY) || null;

    // currently only used to flip category logos back/forth
    this.session.set("colorSchemeOverride", this.storedOverride);

    colorSchemeOverride(this.storedOverride);
  }

  <template>
    <DButton
      @action={{this.toggleScheme}}
      @icon={{this.toggleButtonIcon}}
      @translatedTitle={{i18n (themePrefix "toggle_button_title")}}
      class="color-scheme-toggler btn-flat"
    />
  </template>
}
