export default class MoreLink {
  constructor() {
    let value_id = $("#document").data("document-id");
    let limitCharacters = 1200;
    let dl_children = $("#doc_"+value_id).find('dd');
    dl_children.each(function(i, item){
        let char_length = $(this).text().length;
        if (char_length > limitCharacters) {
           let displayedCharacters = $(this).text().substr(0,limitCharacters);
           let hiddenCharacters = $(this).text().substr(limitCharacters, char_length - limitCharacters );
           let html_ul_li =
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
  }
}
