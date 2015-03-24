(function() {
    var isOpen = false,
        height = $(window).height();
    $('.menu-button').click(function(){
        $('.menu-wrap').toggle("slide");
        if (isOpen) {
            isOpen = false;
            $('body').removeClass('menu_open');
        } else {
            isOpen = true;
            $('body').addClass('menu_open');
            $('.menu-side ul').css('height',height + 'px');
        }
    });
})();