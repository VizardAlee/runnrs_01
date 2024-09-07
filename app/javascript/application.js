import "@hotwired/turbo-rails";
import "controllers";
import "chart.js/auto";
import "chartjs-adapter-moment";
import "toastr/build/toastr.min.js";

// Initialize Toastr options
document.addEventListener('DOMContentLoaded', function() {
  toastr.options = {
    closeButton: true,
    debug: false,
    newestOnTop: true,
    progressBar: true,
    positionClass: "toast-top-right",
    preventDuplicates: false,
    onclick: null,
    showDuration: "300",
    hideDuration: "1000",
    timeOut: "5000",
    extendedTimeOut: "1000",
    showEasing: "swing",
    hideEasing: "linear",
    showMethod: "fadeIn",
    hideMethod: "fadeOut"
  };
});
