$(document).ready(function() {
    var value_id = $("#content").data("id");
    var limitCharacters = 300;
    var dl_children = $("#doc_"+value_id).find('ul');
    dl_children.each(function(i, item){
        var char_length = $(this).text().length;
        if (char_length > limitCharacters) {
           var displayedCharacters = $(this).text().substr(0,limitCharacters);
           var hiddenCharacters = $(this).text().substr(limitCharacters, char_length - limitCharacters );
           var html_ul_li =
           displayedCharacters +
           '<span class="morecontent">' + hiddenCharacters + 
           '</span>&nbsp;&nbsp;<span><a href="" class="morelink">' + " ... More" + '</a></span>';
           $(this).html(html_ul_li);
           $(".morecontent span").hide();
        }
    })

     $(".morelink").click(function(){
        if($(this).hasClass("less")) {
            $(this).removeClass("less");
            $(this).html(" ... More");
        } else {
            $(this).addClass("less");
            $(this).html(" ... Less");
        }
        $(this).parent().prev().toggle();
        $(this).prev().toggle();
        return false;
    })
});
