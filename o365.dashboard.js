function addTile(id, title, link, iconTitle) {
    var tile = 
        '<div style="width: 160px; height: 160px;" class="ms-tileview-tile-root">' +
            '<div id="_' + id + '" style="width: 150px; height: 150px;" aria-haspopup="true" class="ms-tileview-tile-content">' +
                '<a href="#">' +
                    '<div style="height:100%">' +
                        // '<img class="ms-tile-image" id="_tileImage' + id + '" src="/_layouts/15/images/256_icdocset.gif" style="width: 150px; height: 150px;">' +
                        '<i class="ms-Icon ms-Icon--' + iconTitle + ' tiles" title="' + iconTitle + '" aria-hidden="true"></i>' +
                        '<div id="_overlay' + id + '" style="width: 150px; height: 150px; top: 100px; left: 0px;" offy="100" class="ms-tileview-tile-detailsBox">' +
                            '<ul class="ms-noList ms-tileview-tile-detailsListMedium">' +
                                '<li collapsed="ms-tileview-tile-titleMedium ms-tileview-tile-titleMediumCollapsed" expanded="ms-tileview-tile-titleMedium ms-tileview-tile-titleMediumExpanded" class="ms-tileview-tile-titleMedium ms-tileview-tile-titleMediumCollapsed">' +
                                    '<div collapsed="ms-tileview-tile-titleTextMediumCollapsed" expanded="ms-tileview-tile-titleTextMediumExpanded" class="ms-tileview-tile-titleTextMediumCollapsed">'+ title +'</div>' +
                                '</li>' +
                                '<li title="'+ title +'" class="ms-tileview-tile-descriptionMedium"></li>' +
                            '</ul>' +
                        '</div>' +
                    '</div>' +
                '</a>' +
            '</div>' + 
        '</div>';
    // Attach tile to the DOM  
    $('#_summary').append(tile);
    $('#_'+ id).mouseover(function(e) {
        $('#_overlay'+ id).css('top', '0');
    });
    $('#_overlay'+ id).mouseout(function(e) {
        $('#_overlay'+ id).css('top', '100px');
    });
    $('#_overlay'+ id).click(function(e) {
        window.location.href = _spPageContextInfo.webAbsoluteUrl + '/' + link;
    });
}
function retrieveLateTasks() {
    var today = getToday();
    $.when(RestAPI.GetListItems('Tasks', _spPageContextInfo.siteAbsoluteUrl, "?$orderby=DueDate asc&$filter=DueDate le '" + today + "' and (Status eq 'In Progress' or Status eq 'Not Started' or Status eq 'Waiting on someone else')"))
    .done(function (data) {
        var lateTasks = data.d.results.length;
        addTile("_late", lateTasks + " Late tasks", "lists/Tasks", "Timer");
    })
    .fail(function (data) {
        console.log(data.responseText);
    })
}
function retrieveUpcomingTasks() {
    var today = getToday();
    $.when(RestAPI.GetListItems('Tasks', _spPageContextInfo.siteAbsoluteUrl, "?$orderby=StartDate asc&$filter=StartDate ge '" + today + "' and Status eq 'Not Started'"))
    .done(function (data) {
        var upcomingTasks = data.d.results.length;
        addTile("_upcoming", upcomingTasks + " Upcoming tasks", "lists/Tasks", "RecurringTask");
    })
    .fail(function (data) {
        console.log(data.responseText);
    })
}
function retrieveUpcomingEvents() {
    var today = getToday();
    $.when(RestAPI.GetFlexible(_spPageContextInfo.siteAbsoluteUrl, '/_vti_bin/ListData.svc/Calendar', "?$orderby=StartTime asc&$filter=StartTime ge datetime'" + today + "'"))
    .done(function (data) {
        var upcomingEvents = data.d.results.length;
        addTile("_upcomingEvents", upcomingEvents + " Upcoming events", "lists/Calendar", "Calendar");
    })
    .fail(function (data) {
        console.log(data.responseText);
    })
}

/* HELPERS */
function getToday() {
    var d = new Date(), year, month, day, hour, minute, second;
    year = d.getFullYear();

    month = (d.getMonth() + 1).toString().length == 1 ? '0' + (d.getMonth() + 1) : (d.getMonth() + 1);
    day = d.getDate().toString().length == 1 ? '0' + d.getDate() : d.getDate();
    hour = d.getHours().toString().length == 1 ? '0' + d.getHours() : d.getHours();
    minute = d.getMinutes().toString().length == 1 ? '0' + d.getMinutes() : d.getMinutes();
    second = d.getSeconds().toString().length == 1 ? '0' + d.getSeconds() : d.getSeconds();

    return year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':' + second;
}
/*
 * SharePoint REST API Callback
 */
var RestAPI = {
    /*
     * READ SPECIFIC ITEM operation
     * @param: listName -> the name of the list
     * @param: siteurl -> the site URL
     * @param: ODataQueryOperators -> example "?$filter=SiteUrl eq 'item'"
     */
    GetListItems: function (listName, siteurl, ODataQueryOperators) {
        var def = $.Deferred()
        var url = siteurl + "/_api/web/lists/getbytitle('" + listName + "')/items" + ODataQueryOperators;
        $.ajax({
            url: url,
            xhrFields: {
                withCredentials: true
            },
            method: "GET",
            headers: {
                'Accept': 'application/json; odata=verbose',
                //'Authorization': 'Bearer ' + token,
            },
            success: function (data) {
                def.resolve(data);
            },
            error: function (data) {
                def.reject(data);
            }
        });
        return def.promise();
    },
    /*
     * READ SPECIFIC ITEM operation
     * @param: siteurl -> the site URL
     * @param: relativeUrl -> the relative url "/_vti_bin/ListData.svc/Calendar"
     * @param: ODataQueryOperators -> example "?$filter=SiteUrl eq 'item'"
     */
    GetFlexible: function (siteurl, relativeUrl, ODataQueryOperators) {
        var def = $.Deferred()
        var url = siteurl + relativeUrl + ODataQueryOperators;
        $.ajax({
            url: url,
            xhrFields: {
                withCredentials: true
            },
            method: "GET",
            headers: {
                'Accept': 'application/json; odata=verbose',
                //'Authorization': 'Bearer ' + token,
            },
            success: function (data) {
                def.resolve(data);
            },
            error: function (data) {
                def.reject(data);
            }
        });
        return def.promise();
    }
}

$(document).ready(function() {
    retrieveLateTasks();
    retrieveUpcomingTasks();
    retrieveUpcomingEvents();
});

