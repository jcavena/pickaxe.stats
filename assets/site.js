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
    $('#stats').DataTable();
  }

  var pie = null;
  $('#graph_modal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget); 
    var chart_data = button.data('chart'); 
    var chart_name = button.data('name');
    
    console.log("name: " + chart_name);
    var modal = $(this);
    modal.find('.modal-title').text(chart_name);
    if (pie != null){
      pie.destroy();
    }
    pie = new d3pie("pieChart", {
      "size": {
        "canvasWidth": 590,
        "pieOuterRadius": "90%"
      },
      "data": {
        "sortOrder": "label-asc",
        "smallSegmentGrouping": {
          "enabled": true,
          "value": 1
        },
        "content": chart_data
      },
      "labels": {
        "outer": {
          "pieDistance": 42
        },
        "inner": {
          "hideWhenLessThanPercentage": 3
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

