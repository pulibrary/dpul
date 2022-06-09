$(document).ready(function() {
    var value_id = $("#document").data("document-id");
    var limitCharacters = 1200;
    var dl_children = $("#doc_"+value_id).find('dd');
    dl_children.each(function(i, item){
        var char_length = $(this).text().length;
        if (char_length > limitCharacters) {
           var displayedCharacters = $(this).text().substr(0,limitCharacters);
           var hiddenCharacters = $(this).text().substr(limitCharacters, char_length - limitCharacters );
           var html_ul_li =
           displayedCharacters +
           '<span class="morecontent">' + hiddenCharacters +
           '</span>&nbsp;&nbsp;<span><a href="" class="morelink">' + " ... Less" + '</a></span>';
           $(this).html(html_ul_li);
           $(".morecontent span").hide();
        }
    })

     $(".morelink").click(function(){
        if($(this).hasClass("less")) {
            $(this).removeClass("less");
            $(this).html(" ... Less");
        } else {
            $(this).addClass("less");
            $(this).html(" ... More");
        }
        $(this).parent().prev().toggle();
        $(this).prev().toggle();
        return false;
    })
});
