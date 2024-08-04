import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hasVariationsCheckbox", "hasVariationsHiddenField", "variationsSection", "quantitySection", "variationTypeSelect"]

  toggleVariations() {
    const hasVariations = this.hasVariationsCheckboxTarget.checked;
    this.hasVariationsHiddenFieldTarget.value = hasVariations ? '1' : '0'; // Update hidden field with '1' or '0'

    if (hasVariations) {
      this.variationsSectionTarget.style.display = "block";
      this.quantitySectionTarget.innerHTML = ""; // Clear the quantity section
    } else {
      this.variationsSectionTarget.style.display = "none";
      this.quantitySectionTarget.innerHTML = `
        <div class="field mb-4">
          <label for="product_quantity" class="block text-gray-700 text-sm font-bold mb-2">Quantity</label>
          <input type="number" name="product[quantity]" id="product_quantity" class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
        </div>

      `;
    }
  }

  showForm() {
    this.variationsSectionTarget.style.display = "none";
    this.quantitySectionTarget.innerHTML = `
    <div class="field mb-4">
        <label for="product_quantity" class="block text-gray-700 text-sm font-bold mb-2">Quantity</label>
        <input type="number" name="product[quantity]" id="product_quantity" class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
      </div>
    `;
    this.element.closest('[data-turbo-frame]').classList.remove('hidden'); // Show the Turbo Frame
  }

}
