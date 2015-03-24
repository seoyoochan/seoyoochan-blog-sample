// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require libs/moderniz.min
//= require libs/google_analytics
//= require libs/jstz.min
//= require libs/waves.min
//= require libs/menu
//= require libs/foundation.min
//= require libs/jquery.autosize.min
//= require libs/jquery.shiftenter
//= require redactor-rails
//= require jquery_nested_form
//= require turbolinks


$(document).ready(function(){
    var timeZone = jstz.determine(); // Timezone Setting
    var height = $(window).height();
    document.cookie = 'jstz_time_zone='+timeZone.name()+';';
    Waves.displayEffect();

    $('.autosize').autosize();
    $('.easy_submit').shiftenter({
        focusClass: 'shiftenter',             /* CSS class used on focus */
        inactiveClass: 'shiftenterInactive',  /* CSS class used when no focus */
        hint: '',
        metaKey: 'shift',
        pseudoPadding: '0'
    });
});

$(document).foundation();

$(function() {
    $('a[href*=#]:not([href=#])').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) {
                $('html,body').animate({
                    scrollTop: target.offset().top
                }, 1000);
                return false;
            }
        }
    });
});
