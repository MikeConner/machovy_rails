jQuery.noConflict()(function($){
$(document).ready(function($) {
 /*INSTAGRAM PHOTOS FEEDS STARTS*/
   var clientId = 'baee48560b984845974f6b85a07bf7d9';  
      $(".instagram-photos").instagram({
        hash: 'hipster',
        show: 12,
        clientId: clientId
      });
/*INSTAGRAM PHOTOS FEEDS ENDS*/ 

/*FIT VIDEOS STARTS*/
   $("body").fitVids();
/*FIT VIDESO ENDS*/

/*RESPONSIVE MAIN NAVIGATION STARTS*/							
	var $menu_select = $("<select />");	
	$("<option />", {"selected": "selected", "value": "", "text": "Site Navigation"}).appendTo($menu_select);
	$menu_select.appendTo("#main-navigation");
	$("#main-navigation ul li a").each(function(){
		var menu_url = $(this).attr("href");
		var menu_text = $(this).text();
		if ($(this).parents("li").length == 2) { menu_text = '- ' + menu_text; }
		if ($(this).parents("li").length == 3) { menu_text = "-- " + menu_text; }
		if ($(this).parents("li").length > 3) { menu_text = "--- " + menu_text; }
		$("<option />", {"value": menu_url, "text": menu_text}).appendTo($menu_select)
	})
	field_id = "#main-navigation select";
	$(field_id).change(function()
	{
	   value = $(this).attr('value');
	   window.location = value;	
	});
/*RESPONSIVE MAIN NAVIGATION ENDS*/

/*AUDIO VIDEO PLAYER STARTS*/
 $('audio,video').mediaelementplayer();
/*AUDIO VIDEO PLAYER ENDS*/ 
	
/*CUSTOM TOOLTIP STARTS*/  
  $( '.tooltip' ).each( function() {
		$(this).css( 'marginLeft', '-' + Math.round( ($(this).outerWidth() / 2) ) + 'px' );
	});
	$( '#filterable a' ).hover( function() {	
		$(this).find( '.tooltip' ).stop().animate({ marginBottom: '20px', opacity: 0.90 }, 700, 'easeOutBounce');	
	}, function() {	
		$(this).find( '.tooltip' ).stop().animate({ marginBottom: 0, opacity: 0 }, 400, 'easeOutQuint');	
	});
/*CUSTOM TOOLTIP ENDS*/  
	
/*PORTFOLIO DETAILS PAGINATION STARTS*/  
	$( '.project-pagination li' ).hover( function() {	
		$(this).find( 'a.prev' ).stop().animate({ paddingRight: '60px', opacity: 1 }, 100);	
	}, function() {	
		$(this).find( 'a.prev' ).stop().animate({ paddingRight: 0}, 100);	
	});
	$( '.project-pagination li' ).hover( function() {	
		$(this).find( 'a.next' ).stop().animate({ paddingLeft: '40px', opacity: 1 }, 100);	
	}, function() {	
		$(this).find( 'a.next' ).stop().animate({ paddingLeft: 0}, 100);	
	});
	$( '.project-pagination li' ).hover( function() {	
		$(this).find( 'a.all-projects' ).stop().animate({ paddingLeft: '60px', opacity: 1 }, 100);	
	}, function() {	
		$(this).find( 'a.all-projects' ).stop().animate({ paddingLeft: 0}, 100);	
	});
/*PORTFOLIO DETAILS PAGINATION ENDS*/ 

/*PRETTYPHOTO JQUERY CODE STARTS*/ 	
 $("a[data-rel^='prettyPhoto']").prettyPhoto({overlay_gallery: false});
 /*PRETTYPHOTO JQUERY CODE ENDS*/ 
	
/*PORTFOLIO SLIDER STARTS*/ 	
if ( $( '.portfolio-flexslider' ).length && jQuery() ) {
$('.portfolio-flexslider').flexslider({ 
	animation:"slide",
	controlNav:false,  
	nextText:"&rsaquo;",
	prevText:"&lsaquo;",
	keyboardNav: false,  
	});
}
/*PORTFOLIO SLIDER ENDS*/ 

/*PORTFOLIO ITEM HOVER STARTS*/ 
 $('.portfolio-img').each(function() {
 $(this).hover(
	function() {$(this).stop().animate({ opacity: 0.5 }, 400); },
	function() { $(this).stop().animate({ opacity: 1.0 }, 400);})
});
 /*PORTFOLIO ITEM HOVER ENDS*/ 	 

/*GOOGLE MAP STARTS*/  
if ( $( '#map' ).length && jQuery() ) {
var $map = $('#map');
			$map.gMap({
			address: 'Level 13, 2 Elizabeth St, Melbourne Victoria 3000 Australia', 
			zoom: 18,
			markers: [{ 'address' : 'Level 13, 2 Elizabeth St, Melbourne Victoria 3000 Australia' }, ]	
			});
}
 /*GOOGLE MAP ENDS*/
 
 /*TEAM MEMBER STARTS*/
  function isScrolledIntoView(id)
	{
		var elem = "#" + id;
		var docViewTop = $(window).scrollTop();
		var docViewBottom = docViewTop + $(window).height();
	
		if ($(elem).length > 0){
			var elemTop = $(elem).offset().top;
			var elemBottom = elemTop + $(elem).height();
		}
		return ((elemBottom >= docViewTop) && (elemTop <= docViewBottom)
		  && (elemBottom <= docViewBottom) &&  (elemTop >= docViewTop) );
	}
	function sliding_horizontal_graph(id, speed){
		$("#" + id + " li span").each(function(i){
			var j = i + 1; 										  
			var cur_li = $("#" + id + " li:nth-child(" + j + ") span");
			var w = cur_li.attr("class");
			cur_li.animate({width: w + "%"}, speed);
		})
	}
	function graph_init(id, speed){
		$(window).scroll(function(){
			if (isScrolledIntoView(id)){
				sliding_horizontal_graph(id, speed);
			}
			else{
			}
		})
		if (isScrolledIntoView(id)){
			sliding_horizontal_graph(id, speed);
		}
	}
	graph_init("example-1", 1000);
/*TEAM MEMBER ENDS*/ 

/*ACCORDION STARTS*/ 
initAccordion();
function initAccordion() {
	jQuery('.accordion-item').each(function(i) {
		var item=jQuery(this);
		item.find('.accordion-content').slideUp(0);
		item.find('.accordion-switch').click(function() {
		 var displ = item.find('.accordion-content').css('display');
		 item.closest('ul').find('.accordion-switch').each(function() {
		  var li = jQuery(this).closest('li');
		  li.find('.accordion-content').slideUp(300);
		  jQuery(this).parent().removeClass("selected");
		 });
		 if (displ=="block") {
		  item.find('.accordion-content').slideUp(300) 
		  item.removeClass("selected");
		 } else {
		  item.find('.accordion-content').slideDown(300) 
		  item.addClass("selected");
		 }
		});
	});
}
/*ACCORDION ENDS*/ 	
	
/*INNER PAGE TABS STARTS*/ 
   var $fullTabs = $("#full-tabs");
   if (!$fullTabs.is('.ui-tabs')) {
           $('#full-tabs > ul > li > a').each(function () {
                $(this).after('<span class="glow"><br/></span>');
           });
           $fullTabs.tabs();
        }
/*INNER PAGE TABS ENDS*/ 		
 		
/*TOP PANEL SLIDE STARTS*/ 		
  $("#top-panel-wrapper #slideUp").toggle
	(
		function()
		{
			$('#top-panel-wrapper').animate({top:'0px'}, {queue:false,duration:500});
			$('#top-panel-wrapper  #slideUp').addClass('out');
		}
		,function()
		{
			$('#top-panel-wrapper').animate({top:'-70px'}, {queue:false,duration:500});
			$('#top-panel-wrapper #slideUp').removeClass('out');
		}
	);
/*TOP PANEL SLIDE ENDS*/
 	
 /*FLEX SLIDER HOEMPAGE STARTS*/ 
 if ( $( '.flexslider' ).length && jQuery() ) {
		$('.flexslider').flexslider({ 
		 animation:"fade",
			controlNav:false,
		 controlsContainer:"#home",
		 nextText:"&rsaquo;",
		 prevText:"&lsaquo;",
		 keyboardNav: true,  
		});
  }
 /*FLEX SLIDER HOEMPAGE ENDS*/  
 
/*PORTFOLIO JQUERY STARTS*/ 
	(function() {
		var $container = $('.portfolio-items');
		if( $container.length ) {
			var $itemsFilter = $('#filterable');	
			$('li', $container).each(function(i) {
				var $this = $(this);
				$this.addClass( $this.attr('data-categories') );
			});
			$(window).on('load', function() {
				$container.isotope({
					itemSelector : 'li',
					layoutMode   : 'fitRows'
				});
			});
			$itemsFilter.on('click', 'a', function(e) {
				var $this = $(this),
				currentOption = $this.attr('data-categories');
				$itemsFilter.find('a').removeClass('active');
				$this.addClass('active');
				if( currentOption ) {
					if( currentOption !== '*' ) currentOption = currentOption.replace(currentOption, '.' + currentOption)
					$container.isotope({ filter : currentOption });
				}
				e.preventDefault();
			});
			$itemsFilter.find('a').first().addClass('active');
		}
	})();
  /*PORTFOLIO JQUERY STARTS*/ 
 
   /*TABS MENU JQUERY STARTS*/ 
		(function() {
		var $tabsNav    = $('.tabs-nav'),
		$tabsNavLis = $tabsNav.children('li'),
		$tabContent = $('.tab-content');
		$tabContent.hide();
		$tabsNavLis.first().addClass('active').show();
		$tabContent.first().show();
		$tabsNavLis.on('click', function(e) {
		var $this = $(this);
		$tabsNavLis.removeClass('active');
		$this.addClass('active');
		$tabContent.hide();		
		$( $this.find('a').attr('href') ).fadeIn(700);
		e.preventDefault();
		});
	})();
  /*TABS MENU JQUERY ENDS*/ 	
	
   /*DRIBBBLE SHOTS JQUERY STARTS*/ 	
	 $.jribbble.getShotsByPlayerId('envato', function (playerShots) {
		var html = [];
		$.each(playerShots.shots, function (i, shot) {
			html.push('<li>');
			html.push('<a href="' + shot.url + '" target="_blank">');
			html.push('<img src="' + shot.image_teaser_url + '" ');
			html.push('alt="' + shot.title + '"></a></li>');
		});	
		$('.dribbble-photos').html(html.join(''));
	}, {page: 1, per_page: 12});	
 /*DRIBBBLE SHOTS JQUERY ENDS*/ 	
 
  /*FLICKR PHOTOS FEEDS JQUERY STARTS*/ 	
	$('.flickr-feeds').jflickrfeed({
		limit: 12,
		qstrings: {
			id: '52617155@N08'
		},
		itemTemplate: '<li><a href="{{image_b}}" target="_blank"><img src="{{image_s}}" alt="{{title}}" /></a></li>'
	});
  /*FLICKR PHOTOS FEEDS JQUERY ENDS*/ 

   /*TWITTER FEEDS JQUERY STARTS*/  
 if ( $( '.twitter-feeds' ).length && jQuery()) {
$(".twitter-feeds").tweet({
	 username: "trendywebstar",
	 join_text: null,
	 avatar_size: null,
	 count: 2,
	 auto_join_text_default: "we said,", 
	 auto_join_text_ed: "we",
	 auto_join_text_ing: "we were",
	 auto_join_text_reply: "we replied to",
	 auto_join_text_url: "we were checking out",
	 loading_text: "loading tweets..."
 });
 }
    /*TWITTER FEEDS JQUERY ENDS*/

   /*JQUERY HOVER EFFECT STARTS*/	
 	$(".team-content").hover(function(){
		$(this).find(".member-text").stop(true, true).animate({ opacity: 'show' }, 500);
	}, function() {
		$(this).find(".member-text").stop(true, true).animate({ opacity: 'hide' }, 500);		
	});
	
	$(".circle-item-one-fourth-content,.cube-item-one-third-content").hover(function(){
		$(this).find(".circle-item-one-fourth-text,.cube-item-one-third-text").stop(true, true).animate({ opacity: 'show' }, 500);
	}, function() {
		$(this).find(".circle-item-one-fourth-text,.cube-item-one-third-text").stop(true, true).animate({ opacity: 'hide' }, 500);		
	});
   /*JQUERY HOVER EFFECT ENDS*/		
	
    /*JQUERY HOVER OPACITY EFFECT STARTS*/	
  		$("ul#grid-portfolio li .item-hover").hover(function(){
		$(this).find(".portfolio-thumbnail,").stop(true, true).animate({ opacity: 'show' }, 500);
	}, function() {
		$(this).find(".portfolio-thumbnail").stop(true, true).animate({ opacity: 'hide' }, 500);		
	});
  /*JQUERY HOVER OPACITY EFFECT ENDS*/  
  
    /*JQUERY MAIN NANVIGATION STARTS*/
  if ( $( '#main-navigation' ).length && jQuery() ) {
        $('ul.main-menu').superfish({ 
            delay:       100,                            // one second delay on mouseout 
            animation:   {opacity:'show',height:'show'},  // fade-in and slide-down animation 
            speed:       'fast',                          // faster animation speed 
            autoArrows:  false                           // disable generation of arrow mark-up 
        });
}
/*JQUERY MAIN NANVIGATION ENDS*/

/*JQUERY CONTACT FORM STARTS*/
if ( $( '#contact-form' ).length && jQuery() ) {
$('form#contact-form').submit(function() {
function resetForm($form) {
    $form.find('input:text, input:password, input:file, select, textarea').val('');
    $form.find('input:radio, input:checkbox')
    .removeAttr('checked').removeAttr('selected');
}
$('form#contact-form .error-message').remove();
var hasError = false;
$('.requiredField').each(function() {
if(jQuery.trim($(this).val()) == '') {
 var labelText = $(this).prev('label').text();
 $(this).parent().append('<div class="error-message">You forgot to enter '+labelText+'</div>');
 $(this).addClass('inputError');
 hasError = true;
 } else if($(this).hasClass('email')) {
 var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
 if(!emailReg.test(jQuery.trim($(this).val()))) {
 var labelText = $(this).prev('label').text();
 $(this).parent().append('<div class="error-message">You entered an invalid '+labelText+'</div>');
 $(this).addClass('inputError');
 hasError = true;
 }
 }
});
if(!hasError) {
$('form#contact-form input.submit').fadeOut('normal', function() {
$(this).parent().append('');
});
var formInput = $(this).serialize();
$.post($(this).attr('action'),formInput, function(data){
$('#contact-form').prepend('<div><span class="success-message">Your email was successfully sent. We will contact you as soon as possible.</span></div>');
resetForm($('#contact-form'));
$('.success-message').fadeOut(5000);
 
});
}
return false;
});
}
/*JQUERY CONTACT FORM STARTS*/
}); 
});
/*JQUERY ENDS*/	
