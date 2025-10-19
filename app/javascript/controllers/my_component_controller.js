import { Controller } from "@hotwired/stimulus"
import { createElement } from "react";
import { createRoot } from "react-dom/client";
import { Button } from "shared-ui";

export default class extends Controller {
  static targets = ["input", "button"];

  connect() {
    this.root = createRoot(this.buttonTarget);
    this.inputTarget.addEventListener("input", this.render);
    this.render();
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this.render);
    this.root.unmount();
  }

  render = () => {
    const count = Number.parseInt(this.inputTarget.value);
    this.root.render(createElement(Button, { count, onChangeCount: this.handleChangeCount }));
  };

  handleChangeCount = (count) => {
    this.inputTarget.value = count;
    this.render();
  };
}
