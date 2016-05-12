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

});

(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-3878658-17', 'auto');
ga('send', 'pageview');

