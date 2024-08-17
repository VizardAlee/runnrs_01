import * as am4core from "@amcharts/amcharts4/core";
import * as am4charts from "@amcharts/amcharts4/charts";
import am4themes_animated from "@amcharts/amcharts4/themes/animated";
import { Chart, registerables } from 'chart.js';
import { LinearScale, TimeScale, TimeSeriesScale } from 'chart.js/auto';

am4core.useTheme(am4themes_animated);

Chart.register(LinearScale, TimeScale, TimeSeriesScale, ...registerables);

var chart = am4core.create("chartdiv", am4charts.XYChart);

// Add data
chart.data = JSON.parse(document.getElementById('chart-data').textContent);

// Create axes
var dateAxis = chart.xAxes.push(new am4charts.DateAxis());
dateAxis.renderer.minGridDistance = 50; // Adjust for better date label spacing

var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());

// Create series
var series = chart.series.push(new am4charts.LineSeries());
series.dataFields.valueY   
 = "income";
series.dataFields.dateX = "date";
series.tooltipText = "{valueY.value}";
series.strokeWidth = 2;
series.minBulletDistance = 15;

// Add cursor
chart.cursor = new am4charts.XYCursor();

// Add scrollbar
chart.scrollbarX = new am4core.Scrollbar();