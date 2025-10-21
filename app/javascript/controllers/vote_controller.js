import { Controller } from "@hotwired/stimulus"
import { createElement } from "react";
import { createRoot } from "react-dom/client";
import { MyDoughnut } from "shared-ui";

export default class extends Controller {
  static targets = ["chart", "data"];

  connect() {
    this.chart = createRoot(this.chartTarget);
    this.render();
    this.element.addEventListener("summaries:change", this.render);
  }

  disconnect() {
    this.element.removeEventListener("summaries:change", this.render);
    this.chart.unmount();
  }

  render = () => {
    const data = JSON.parse(this.dataTarget.textContent);
    this.chart.render(createElement(MyDoughnut, { data }));
  };
}
