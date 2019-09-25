SirTrevor.Blocks.RecentItems = (function(){

  return SirTrevor.Block.extend({
    type: "recent_items",

    title: function() { return "Recent Items"; },

    description: function() { return "Display a list of recent items"; },

    blockGroup: function() { return i18n.t("blocks:group:items") },

    icon_name: "rule",

    editorHTML: function() {
      return _.template(this.template, this)(this);
    },

    template: [
      '<div class="form resources-admin clearfix">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
      '</div>'
    ].join("\n"),
  });
})();
