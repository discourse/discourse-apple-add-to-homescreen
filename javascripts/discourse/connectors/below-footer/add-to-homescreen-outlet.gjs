/* eslint-disable ember/no-classic-components, ember/require-tagless-components */
import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import AddToHomescreen from "../../components/add-to-homescreen";

@classNames("below-footer-outlet", "add-to-homescreen-outlet")
export default class AddToHomescreenOutlet extends Component {
  <template><AddToHomescreen /></template>
}
