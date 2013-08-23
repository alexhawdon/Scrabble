//Make jquery find case-insensitive
$.expr[":"].contains = $.expr.createPseudo(function(arg) {
    return function( elem ) {
        return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
    };
});

$("input#ulcsearch").on("keyup", function(){

  var searchstring = $(this).val();
  $("a.user-item").css({"display": "none"});
  $("a.user-item>div.pure-u-1>div.user-list-details").find(":contains(" + searchstring + ")").each(
    function(){
      $(this).closest("a.user-item").css({"display": "block"});
    });
});

$("a#sort-name, a#sort-rank").on("click", function(){
  $("a#sort-name, a#sort-rank").toggleClass("sorted");
  
  

  switch($(this).text()) {
    case "Name":
      $("#user-list > a").sort(function(a, b){ 
        return($(a).data("name").localeCompare($(b).data("name"))); 
        }).appendTo("#user-list");
      break;
    case "Average Score":
      $("#user-list > a").sort(function(a, b){
        return($(b).data("rank") - $(a).data("rank")); 
        }).appendTo("#user-list");
      break;
  }
  
});