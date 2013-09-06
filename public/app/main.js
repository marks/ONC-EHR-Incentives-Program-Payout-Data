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
        // set icon (green or red) depending on incentive receive status
        if(props["PROGRAM YEAR 2011"] == "TRUE"){layer.setIcon(incentiveTrueIcon) }
        else if(props["PROGRAM YEAR 2012"] == "TRUE"){layer.setIcon(incentiveTrueIcon) }
        else if(props["PROGRAM YEAR 2013"] == "TRUE"){layer.setIcon(incentiveTrueIcon) }
        else {layer.setIcon(incentiveFalseIcon)}

        // set up pop up text. ALWAYS give preference to incentive received dataset but fall back on general info dataset
        // TODO - this needs some major refactoring / DRYing
        popup = ""

        // provider name
        if(props["PROVIDER - ORG NAME"]){popup += "<strong>" + props["PROVIDER - ORG NAME"]+"</strong>"} // incentive dataset
        else if(props["PROVIDER NAME"]){popup += "<strong>" + props["PROVIDER NAME"]+"</strong>"} // incentive
        else if(props.general["hospital_name"]){popup += "<strong>" + props.general["hospital_name"]+"</strong>"}

        // provider address
        if(props["PROVIDER  ADDRESS"] && props["PROVIDER CITY"] && props["PROVIDER STATE"] && props["PROVIDER ZIP 5 CD"]){
          popup += "<br />"+props["PROVIDER  ADDRESS"]
          popup += "<br />"+props["PROVIDER CITY"]+", " + props["PROVIDER STATE"] + " " + props["PROVIDER ZIP 5 CD"]
        }
        else if(props.general["address_1"] && props.general["city"] && props.general["state"] && props.general["zip_code"]){
          popup += "<br />"+props.general["address_1"]
          popup += "<br />"+props.general["city"]+", " + props.general["state"] + " " + props.general["zip_code"]
        }
        
        // general hospital info
        if(props.general){
          if(props.general["hospital_name"]){
            popup += "<br /><br />Hosp. Name: "+props.general["hospital_name"]
          }
          if(props.general["hospital_owner"]){
            popup += "<br />Hosp. Owner: "+props.general["hospital_owner"]
          }        
          if(props.general["hospital_type"]){
            popup += "<br />Hosp. Type: "+props.general["hospital_type"]
          }          
        }

        // phone number
        if(props["PROVIDER PHONE NUM"]){popup += "<br /><br /> Phone: " + props["PROVIDER PHONE NUM"]}
        else if(props.general && props.general["phone_number"]){popup += "<br /><br /> Phone: " + props.general["phone_number"]}

        // other attributes (NPI, CCN, Incentive Program Years)
        if(props["PROVIDER CCN"]){ popup += "<br /><br /> CCN: <a href='http://www.medicare.gov/hospitalcompare/profile.html#profTab=0&ID="+props["PROVIDER CCN"]+"' target='blank'>"+props["PROVIDER CCN"]+"</a>"}
        if(props["PROVIDER NPI"]){popup += "<br />NPI: " + "<a href='https://npiregistry.cms.hhs.gov/NPPESRegistry/DisplayProviderDetails.do?searchNpi=1114922341&city=&firstName=&orgName=&searchType=org&state=&npi="+props["PROVIDER NPI"]+"&orgDba=&lastName=&zip=' target=_blank>"+props["PROVIDER NPI"]+"</a>"}
        if(props["jc"]){if(props["jc"]["org_id"]){popup+= "<br />Joint Commisison ID: <a target='blank' href='http://www.qualitycheck.org/consumer/searchresults.aspx?nm="+props["jc"]["org_id"]+"'>"+props["jc"]["org_id"]+"</a>"}}
        popup += "<br /><br />Incentive Program Year(s), if any: "
        if(props["PROGRAM YEAR 2011"] == "TRUE"){popup += "<span class='radius secondary label'>2011</span> " }
        if(props["PROGRAM YEAR 2012"] == "TRUE"){ popup += " <span class='radius secondary label'>2012</span>" }
        if(props["PROGRAM YEAR 2013"] == "TRUE"){ popup += " <span class='radius secondary label'>2013</span>" }

        // HCAHPS data
        popup += "<br /><br />"
        if(props.has_hcahps == true){
          popup += "<span class='radius secondary label green'>HCAHPS data available</span>"
        } else {
          popup += "<span class='radius secondary label red'>no HCAHPS data available</span>"
        }


        layer.bindPopup(popup)
        layer.on('click', onFeatureClick);
      }
    });
    markers.on('clusterclick', onClusterClick);
    markers.addLayer(geoJsonLayer);
    map.addLayer(markers);
    if(fit_bounds == true){map.fitBounds(markers.getBounds());}
    $("#map").hideLoading();
  })
}

function onFeatureClick(e){
  props = e.target.feature.properties
  console.log(props)
  if(props["PROVIDER CCN"]){ label = "CCN_"+e.target.feature.properties["PROVIDER CCN"] }
  else if(props["PROVIDER NPI"]) { label = "NPI_"+e.target.feature.properties["PROVIDER NPI"] }
  else { label = "Unknown" }
  if(typeof(_gaq) != "undefined"){ _gaq.push(['_trackEvent', 'Map', 'Click (Feature)', label]); }

  features_clicked.push(e.target.feature)
  constructComparisonTable()
}

function onClusterClick(e){
  if(e.layer.getAllChildMarkers().length){label = e.layer.getAllChildMarkers().length + " children"}
  else{ label = "Unknown children"}
  if(typeof(_gaq) != "undefined"){ _gaq.push(['_trackEvent', 'Map', 'Click (Cluster)', label]); }
}

function constructComparisonTable(){
  $("#comparison_tables").html("") // clear the comparison table div
  $.each(features_clicked, function(n,feature){
    provider_url = "/db/cms_incentives/EH/find_by_ccn/"+feature.properties["PROVIDER CCN"]+".json"
    $.getJSON(provider_url, function(data){
      if(data == null || data.hcahps == undefined){
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
