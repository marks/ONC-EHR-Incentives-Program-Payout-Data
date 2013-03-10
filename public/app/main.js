// the plain is to have all custom JS that supports the main site function here
// document.ready calls will stay in layout.haml/page level code, for now

var map, markers; // for leaflet mapping
var features_clicked = [] // for comparison features

var incentiveTrueIcon = L.icon({
    // http://mapicons.nicolasmollet.com/markers/health-education/health/hospital/?custom_color=1aa12a
    iconUrl: PUBLIC_HOST+'/mapicons.nicolasmollet.com/hospital-building-green.png',
    iconSize: [32, 37],
    iconAnchor: [15, 37],
    popupAnchor: [2,-37]
});

var incentiveFalseIcon = L.icon({
    // http://mapicons.nicolasmollet.com/markers/health-education/health/hospital/?custom_color=ff0004
    iconUrl: PUBLIC_HOST+'/mapicons.nicolasmollet.com/hospital-building-red.png',
    iconSize: [32, 37],
    iconAnchor: [15, 37],
    popupAnchor: [2,-37]
});


function load_geojson_as_cluster(data_url,fit_bounds){
  $("#map").showLoading();
  $.getJSON(data_url, function(data){
    // clear all markers
    if(typeof(markers) != "undefined"){map.removeLayer(markers);}

    markers = new L.MarkerClusterGroup();
    var geoJsonLayer = L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        props = feature.properties
        popup = ""
        if(props["PROVIDER - ORG NAME"]){popup += "<strong>" + props["PROVIDER - ORG NAME"]+"</strong>"}
        if(props["PROVIDER NAME"]){popup += "<strong>" + props["PROVIDER NAME"]+"</strong>"}
        popup += "<br />"+props["PROVIDER  ADDRESS"]
        popup += "<br />"+props["PROVIDER CITY"]+", " + props["PROVIDER STATE"] + " " + props["PROVIDER ZIP 5 CD"]
        popup += "<br /><br /> Phone: " + props["PROVIDER PHONE NUM"]
        popup += "<br /><br /> NPI: " + "<a href='https://npiregistry.cms.hhs.gov/NPPESRegistry/DisplayProviderDetails.do?searchNpi=1114922341&city=&firstName=&orgName=&searchType=org&state=&npi="+props["PROVIDER NPI"]+"&orgDba=&lastName=&zip=' target=_blank>"+props["PROVIDER NPI"]+"</a>"
        if(props["PROVIDER CCN"]){ popup += " | CCN: <a href='http://www.qualitycheck.org/consumer/searchresults.aspx?nm="+props["PROVIDER CCN"]+"' target=_blank>" + props["PROVIDER CCN"] + "</a>"}
        popup += "<br /><br />Incentive Program Year(s): "
        if(props["PROGRAM YEAR"] != undefined){popup += "<span class='radius secondary label'>"+props["PROGRAM YEAR"]+"</span> "       }
        if(props["PROGRAM YEAR 2011"] == 2011){popup += "<span class='radius secondary label'>2011</span> "       }
        if(props["PROGRAM YEAR 2012"] == 2012){ popup += " <span class='radius secondary label'>2012</span>"       }
        if(props["PROGRAM YEAR 2011"] == 2011 || props["PROGRAM YEAR 2012"] == 2012){
          layer.setIcon(incentiveTrueIcon)
        }
        else {
          layer.setIcon(incentiveFalseIcon)
        }
        layer.bindPopup(popup)
        layer.on('click', onFeatureClick);
      }
    });
    markers.addLayer(geoJsonLayer);
    map.addLayer(markers);
    if(fit_bounds == true){map.fitBounds(markers.getBounds());}
    $("#map").hideLoading();
  })
}

function onFeatureClick(e){
  features_clicked.push(e.target.feature)
  constructComparisonTable()
}

function constructComparisonTable(){
  $("#comparison_tables").html("") // clear the comparison table div
  $.each(features_clicked, function(n,feature){
    provider_url = "/db/onc/ProvidersPaidByEHRProgram_Dec2012_HOSP_FINAL/find_by_ccn/"+feature.properties["PROVIDER CCN"]+".json"
    $.getJSON(provider_url, function(data){
      if(data == null){
        // do nothing
      } else {
        hcahps_props = data.hcahps
        table_selector = "#table-ccn"+hcahps_props.provider_number
        $("#comparison_tables").append("<table id='table-ccn"+hcahps_props.provider_number+"' class=''></table>")
        $(table_selector).html("<thead></thead><tbody></tbody>")
        $(table_selector+" thead").append("<tr><th>Measure</th><th data-sort-initial='true' data-type='numeric'>Values for: "+hcahps_props.hospital_name+"</th></tr>");
        $.each( hcahps_props, function(k, v){
          value = v
          key = k.split("_").join(" ")
          if(k.match(/percent/)){value = "<div class=progress><span class=meter style='width: "+value+"%'>&nbsp;"+value+"</span></div>"}
          else { v = 999; } // group non-percentile values together at the top/bottom of table depending on sort
          $(table_selector+" tbody").append("<tr><td>"+key+"</td><td data-value='"+v+"'>"+value+"</td></tr>")
        });
        $(table_selector).footable();
      }
    });
  })
}
