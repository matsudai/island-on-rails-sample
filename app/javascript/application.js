// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.dispatch_event = function () {
  const name = this.getAttribute("event-name");
  const detail = JSON.parse(this.getAttribute("event-detail") || "{}");

  const event = new CustomEvent(name, { detail, bubbles: true });
  this.targetElements.forEach((target) => target.dispatchEvent(event));
};
