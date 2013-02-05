$(function() {
    $('ul.nav-pills > li').click(function (e) {
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
