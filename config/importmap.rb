# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Tailwind CSS imports
pin "tailwindcss", to: "tailwindcss/tailwind.css"
pin "tailwindcss/base", to: "tailwindcss/base.css"
pin "tailwindcss/components", to: "tailwindcss/components.css"
pin "tailwindcss/utilities", to: "tailwindcss/utilities.css"

pin "chartkick", to: "https://ga.jspm.io/npm:chartkick@5.0.1/dist/chartkick.js"
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.0.0/dist/chart.umd.js"

pin "@amcharts/amcharts4", to: "https://cdn.amcharts.com/lib/4/core.js"
pin "@amcharts/amcharts4/charts", to: "https://cdn.amcharts.com/lib/4/charts.js"
pin "@amcharts/amcharts4/themes/animated", to: "https://cdn.amcharts.com/lib/4/themes/animated.js"
