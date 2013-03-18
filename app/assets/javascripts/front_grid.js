// Front Grid
//-----------------------------------------

$(function() {
    $('ul.categories > li').click(function (e) {
        e.preventDefault();
        // If we weren't redirecting, this is all you need to handle the selection
        // This gets lost on the redirect, though, so has to be done in the views instead
//        $('ul.nav-pills > li').removeClass('active');
//        $(this).addClass('active');          

        // Filter the results              
		jQuery.ajax({url:"/category",
		             data: "category=" + $(this).children().first().attr('id'),
			         type: "GET",
			         // Don't need to do anything on success
		             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
		               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
		             async: false
		});
	});  	
});

function select_mobile_category(category) {
	jQuery.ajax({url:"/category",
     data: "category=" + category,
   type: "GET",
   // Don't need to do anything on success
     error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
       { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
     async: false
	});
	
	preventDefault();
}

function hide_machovy_banner() {
	jQuery.ajax({url:"/banner",
	             data: "hidden=true",
		         type: "PUT",
		         // Don't need to do anything on success
	             error: function(xhr, ajaxOptions, thrownError) //{ alert('Oh noes!') },
	               { alert('error code: ' + xhr.status + ' \n'+'error:\n' + thrownError ); },
	             async: false
	});

	$('.toggle').click(function () {
    	$("#machovy_banner").hide();
  	});
}