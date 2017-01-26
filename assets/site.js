$(document).ready(function(){
  $(".head-skins").skinPreview({
    scale: 4, 
    head: true
  });
  $(".scale-1").skinPreview({scale: 1});
  $(".scale-2").skinPreview({scale: 2});
  $(".scale-3").skinPreview({scale: 3});
  $(".scale-4").skinPreview({scale: 4});
  $(".scale-5").skinPreview({scale: 5});
  $(".scale-6").skinPreview({scale: 6});

  if ($('#stats').length > 0) {
    $('#stats').DataTable({
      fixedHeader: true,
      "order": [[ 2, "desc" ]]
    });
  }

  var chart = null;
  $('#graph_modal').on('shown.bs.modal', function (event) {
    //this needs to run on 'shown' and not 'show' so the window is visible prior to rendering the chart.
    var button = $(event.relatedTarget); 
    var chart_data = button.data('chart'); 
    var chart_name = button.data('name');
    var chart_type = button.data('chart-type');
    var chart_inner_radius = "0";
    var chart_sort_order = "label-asc";
    var hide_label_percentage_min = 3;

    if (chart_type == 'donut') {
      chart_inner_radius = 100 - parseInt(button.parent().data('sort'));
      if (chart_inner_radius > 0){
        chart_inner_radius += '%';
      }

      chart_sort_order = "none";
      hide_label_percentage_min = 100;
    }

    $('.modal-title').text(chart_name);
    if (chart != null){
      chart.destroy();
    }
    chart = new d3pie("pieChart", {
      "size": {
        "canvasWidth": 590,
        "pieOuterRadius": "75%",
        "pieInnerRadius": chart_inner_radius
      },
      "data": {
        "sortOrder": chart_sort_order,
        "content": chart_data
      },
      "labels": {
        "outer": {
          "pieDistance": 45
        },
        "inner": {
          "hideWhenLessThanPercentage": hide_label_percentage_min
        },
        "mainLabel": {
          "fontSize": 11
        },
        "percentage": {
          "color": "#ffffff",
          "decimalPlaces": 0
        },
        "value": {
          "color": "#adadad",
          "fontSize": 11
        },
        "lines": {
          "enabled": true
        },
        "truncation": {
          "enabled": true
        }
      },
      "effects": {
        "pullOutSegmentOnClick": {
          "effect": "linear",
          "speed": 400,
          "size": 8
        }
      },
      "misc": {
        "gradient": {
          "enabled": true,
          "percentage": 100
        }
      }
    });
  });



});



/* GOOGLE TRACKING */
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-3878658-17', 'auto');
ga('send', 'pageview');

