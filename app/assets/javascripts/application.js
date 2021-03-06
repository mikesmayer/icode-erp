// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.

//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require kendo.web.min
//= require jquery.fancybox.pack
//= require jquery.tabify
//= require jquery.placeholder
//= require jquery.chromatable
//= require date
//= require jquery.forcenumeric
//= require dataTables/jquery.dataTables
//= require jquery.functions
//= require_self

// Success remove jquery.easyui.min.js

$(document).ready(function () {
    
    var window_height           = $(window).height() || 0;
    var ctn_width               = $(window).width() - 20 || 0; // It is for table width
    var tabify_height           = $(".class_tabify").height() || 0 ;
    var mainHeader_height       = $("#main_header").height() || 0;
    var mainFooter_height       = $("#main_footer").height() || 0;
    var menu_height             = $("#k_menu").height() || 0;
    var linking_height          = $("#linking").height() || 0;
    var searching_height        = $("#searching").height() || 0;
    var title_height            = $(".title_head").height() || 0;
    var button_height           = $(".icon_tag").height() || 0;
    var quick_tip               = $("#bottom_quick_tip").height() || 0;
    
    // Wrapper is calculate the height only available when without popup
    var wrapper_height           = window_height - mainHeader_height - mainFooter_height - menu_height - 25;
    var wrapper_quick_tip        = wrapper_height - quick_tip - 50;
    var content_height           = wrapper_height - title_height - button_height - 12;
    var tabify_content_height    = wrapper_height - tabify_height - button_height - 13;    
    var linking_content_height   = wrapper_height - linking_height - title_height - button_height - 13;
    var linking_tabify_height    = wrapper_height - linking_height - tabify_height - button_height - 13;   
    var searching_content_height = wrapper_height - searching_height - title_height - button_height - 13;

    // It is for normal page for without popup
    $("#main_wrapper").css({ 'height': wrapper_height }).addClass("page_wrapper"); 
    
    // It is Home Page
    $("#top_quick_tip").css({ 'height': wrapper_quick_tip }).addClass("page_wrapper");
    
    // It is for .content
    $(".content").css({ 'height': content_height }).addClass("page_wrapper");
    
    // It is Tabbing with tabify
    $(".tabify_content").css({ 'height': linking_tabify_height }).addClass("page_wrapper");
    
    // It is for .content with linking
    $(".linking_content").css({ 'height': linking_content_height }).addClass("page_wrapper");
    
    // It is for .content with searching
    $(".searching_content").css({ 'height': searching_content_height }).addClass("page_wrapper");
    
    // Normal Table for main screen, no linking
    $("#jgrid").chromatable({
        width:  ctn_width,
        height: content_height,
        scrolling: "yes"
    });
    
    // Normal Table with linking
    $("#jgrid_linking").chromatable({
        width:  ctn_width,
        height: linking_content_height,
        scrolling: "yes"
    });
    
    $("#jgrid_linking_tabify").chromatable({
        width:  ctn_width,
        height: linking_tabify_height,
        scrolling: "yes"
    });
    
    // Normal Table with search engine, reference for /price_controls
    $("#jgrid_searching").chromatable({
        width:  ctn_width,
        height: searching_content_height,
        scrolling: "yes"
    });
    
    // Here is Product Popup Module
    var popup_content_height    = window_height - title_height - button_height - 12;
    var popup_tab_height        = popup_content_height - 50;
    
    $("#treeview").kendoTreeView();
    $("#horizontal").css({ 'height': popup_content_height }).css({ 'margin': '0 auto' });   // It is for popup product page

    $('#jdatatable').dataTable({
        "sScrollY": content_height - 97,
        "sPaginationType": "full_numbers",  // "bPaginate": false,
        "bJQueryUI": true,
        "bProcessing": true,
        "oLanguage": {
                "sZeroRecords":  "No Record Found.",
                "sSearch": "Search All Columns:"
            }

     });
     
        //"bServerSide": true,
        //"sAjaxSource": $('#products').data('source'),
        // "bLengthChange": false,
        // "bFilter": true,
        // "bSort": false,
        // "bInfo": false,   //exp :showing 1 of 15 pages 
        //"bAutoWidth": true
        
        
     $('#linking_tabify_datatable').dataTable({
        "sScrollY":  linking_tabify_height - 97,
        "sPaginationType": "full_numbers",
        "bJQueryUI": true,
        "oLanguage": {
            "sZeroRecords":  "No Record Found.",
            "sSearch": "Search All Columns:"
        },
        "bInfo": false,   //exp :showing 1 of 15 pages 
        "bAutoWidth": true
     });
     
     $('#tabify_datatable').dataTable({
        "sScrollY": tabify_content_height - 97,
        
        "sPaginationType": "full_numbers",
        "bJQueryUI": true,
        
//        "bProcessing": true,
//        "bServerSide": true,
//        "sAjaxSource": $('#tabify_datatable').data('source'),
        
        "oLanguage": {
                "sZeroRecords":  "No Record Found.",
                "sSearch": "Search All Columns:"
        },
        "bInfo": false,   //exp :showing 1 of 15 pages 
        "bAutoWidth": true
     });
     
    // IFRAME
    $(".iframe_1600x900").fancybox({
        padding     : 5,
        maxWidth    : 1600,
        maxHeight   : 900,
        width       : "100%",
        height      : "100%",
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic',
        afterClose  : function() {location.reload();return false;}
    });
    
    $(".iframe_800x450").fancybox({
        padding     : 5,
        maxWidth    : 800,
        maxHeight   : 450,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic',
        afterClose  : function() {location.reload();return false;}
    });
    
    $(".iframe_800x600").fancybox({
        padding     : 5,
        maxWidth    : 800,
        maxHeight   : 600,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic',
        afterClose  : function() {location.reload();return false;}
    });
    
    $(".iframe_1024x800").fancybox({
        padding     : 5,
        maxWidth    : 1024,
        maxHeight   : 800,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic',
        afterClose  : function() {location.reload();return false;}
    });
    
    // IFRAME WITHOUT REFRESH
    $(".show_without_refresh_page_1600x900").fancybox({
        padding     : 5,
        maxWidth    : 1600,
        maxHeight   : 900,
        width       : "100%",
        height      : "100%",
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic'
    });
    
    $(".show_without_refresh_page_800x450").fancybox({
        padding     : 5,
        maxWidth    : 800,
        maxHeight   : 450,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic'
    });
    
    $(".show_without_refresh_page_800x600").fancybox({
        padding     : 5,
        maxWidth    : 800,
        maxHeight   : 600,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic'
    });
    
    $(".show_without_refresh_page_1024x800").fancybox({
        padding     : 5,
        maxWidth    : 1024,
        maxHeight   : 800,
        width       : '100%',
        height      : '100%',
        fitToView   : false,
        autoSize    : false,
        closeClick  : false,
        openEffect  : 'elastic',
        closeEffect : 'elastic'
    });

    // When it is popup...
    // We setting the time out because IE9 really damn high time speed, so we delay time to 0.1s
    setTimeout(function(){
            var window_height                   = $(window).height();
            var ctn_width                       = $(window).width() - 20; // It is for table width
            var popup_tabify_height             = $(".class_tabify").height();
            var title_height                    = $(".title_head").height();
            var button_height                   = $(".icon_tag").height();
            var table_detail_height             = $(".table_details").height();
            var qr_signature_height             = $(".qr_signature").height();
            
            var popup_content_height            = window_height - title_height - button_height - 12;
            var popup_tab_height                = popup_content_height - 50;
            var popup_form_table_height         = popup_content_height - table_detail_height - 15;
            var popup_tab_height_and_signature  = popup_content_height - qr_signature_height - 60;
            
            var popup_tabify_content_height     = window_height - popup_tabify_height - button_height - 12; 

            // It is for popup normal page
            $(".popup_content").css({ 'height': popup_content_height }).addClass("page_wrapper"); 
            $(".popup_form_table").css({ 'height': popup_form_table_height }).addClass("page_wrapper"); 
            $(".popup_tabify").css({ 'height': popup_tabify_content_height }).addClass("page_wrapper"); 
            
            // IMS - User Account
            $("#name_entry, #ims_purchase, #ims_sale, #ims_inventory, #ims_custom, #ims_housekeeping, #ims_product, #ims_account, #ims_report_1,#ims_report_2, #ims_report_3, #receipt_1, #receipt_2").height(popup_tab_height).addClass("page_wrapper");
            $(".quotation").height(popup_tab_height_and_signature).addClass("page_wrapper");
            
            // Popup Tabbing Table -- IMS
            $("#ims_purchase, #ims_sale, #ims_inventory, #ims_custom, #ims_housekeeping, #ims_product, #ims_report, #ims_account").chromatable({
                width:  $("#user_strip").width() - 50,
                height: popup_tab_height,
                scrolling: "yes"
            });
            
            // Popup Tabbing Table -- IMS
            $(".jgrid_popup").chromatable({
                width:  ctn_width,
                height: popup_form_table_height,
                scrolling: "yes"
            });
            
    }, 500);
});
