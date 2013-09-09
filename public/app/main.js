// the plan is to have all custom JS that supports the main site function here
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
    if(typeof(markers) != "undefined"){map.removeLayer(markers);}    // clear all markers
    if(typeof(searchControl)!= "undefined"){map.removeControl(searchControl)}
    markers = new L.MarkerClusterGroup();
    var geoJsonLayer = L.geoJson(data, {onEachFeature: handleFeature });
    markers.on('clusterclick', onClusterClick);
    markers.addLayer(geoJsonLayer);
    map.addLayer(markers);

    searchControl = new L.Control.Search({layer: markers, propertyName: "PROVIDER CCN", circleLocation:true});
    searchControl.on('search_locationfound', function(e) {
      map.fitBounds(new L.LatLngBounds(new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng), new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng)))
      map.zoomOut(10)
      e.layer.openPopup()
    })
    map.addControl( searchControl );

    $("#map").hideLoading();

    if(fit_bounds == true){map.fitBounds(markers.getBounds());}
    

  })
}

function onFeatureClick(e){
  $("p.title[data-section-title=data]").effect("highlight")
  $("p.title[data-section-title=data]").first().click()
  props = e.target.feature.properties
  if(props["PROVIDER CCN"]){ label = "CCN_"+e.target.feature.properties["PROVIDER CCN"] }
  else if(props["PROVIDER NPI"]) { label = "NPI_"+e.target.feature.properties["PROVIDER NPI"] }
  else { label = "Unknown" }
  if(typeof(_gaq) != "undefined"){ _gaq.push(['_trackEvent', 'Map', 'Click (Feature)', label]); }

  if(props["PROVIDER CCN"]){ 
    // hospital
    features_clicked.push(e.target.feature)
    renderHospitalDetails()
  }
  else if(props["PROVIDER NPI"]) {
    id = props["PROVIDER NPI"]
    selector = "#feature_container #"+id
    if($('div#content').hasClass("large-12")){
      feature_stub_div_class = "large-4 columns"
    } else {
      feature_stub_div_class = ""
    }
    if($(selector).length === 0){
      feature_stub = "<div class='feature panel "+feature_stub_div_class+"' id='"+id+"'></div>"
      $("#feature_container").append(feature_stub)
      feature_content = ""
      feature_content += "<h4>"+props["PROVIDER NAME"]+"</h4>"
      feature_content += "<div class='feature_content'><a href='http://www.bloomapi.com/search#/npis/"+id+"' target='blank'>Visit BloomAPI for data about this provider from the CMS NPPES database</a><p>"
      feature_content += "</p></div></div>"
      $(selector).html(feature_content)
    }
  }
  else {} // do nothing
  
}

function onClusterClick(e){
  if(e.layer.getAllChildMarkers().length){label = e.layer.getAllChildMarkers().length + " children"}
  else{ label = "Unknown children"}
  if(typeof(_gaq) != "undefined"){ _gaq.push(['_trackEvent', 'Map', 'Click (Cluster)', label]); }
}

function renderHospitalDetails(){
  $("#feature_container").html("")
  $.each(features_clicked, function(n,feature){
    provider_url = "/db/cms_incentives/EH/find_by_bson_id/"+feature.id+".json"
    $.getJSON(provider_url, function(props){
      if(props != null){
        id = props["PROVIDER CCN"]
        selector = "#feature_container #"+id
        if($(selector).length === 0){
          if($('div#content').hasClass("large-12")){
            feature_stub_div_class = "large-4 columns"
          } else {
            feature_stub_div_class = ""
          }
          feature_stub = "<div class='feature panel "+feature_stub_div_class+"' id='"+id+"'></div>"

          $("#feature_container").append(feature_stub)

          if(props["PROVIDER - ORG NAME"]){
            title = props["PROVIDER - ORG NAME"]
          }
          else if(props["general"]){
            title = props["general"]["hospital_name"]
          } else {
            title = "Unknown"
          }


          feature_content = "<a href=# onclick=toggle('"+id+"','.feature_content') title='show/hide details' class='toggler'><i class='foundicon-general-plus'></i></a>"
          feature_content += "<h4>"+title+"</h4>"
          feature_content += "<div class='feature_content' style='display:none'><p>"
          
          $.each( props, function(k, v){
            key = formatKey(k)
            if(v.length === 0){
              // do nothing
            }
            else if(typeof(v) === "object"){
              feature_content += "<hr />"
              if(k == "hc_hais"){
                feature_content += "</p>"+renderHcHaisObject(v)+"<p>"
              } else if (k == "hcahps"){
                feature_content += "</p>"+renderHcahpsObject(v)+"<p>"
              } 
              else {
                feature_content += "</p><h6>"+key+"</h6><p>"
                $.each(v, function(k2,v2){
                  key2 = formatKey(k2)
                  feature_content += "<u>"+key2+":</u> "+v2+"<br />"
                })                
              }
            } 
            else {
              feature_content += "<u>"+key+":</u> "+v+"<br />"
            }

          });

          feature_content += "</p></div></div>"
          $(selector).html(feature_content)

        } else {
          // do nothing
        }
      }
      
      // if(data == null || data.hcahps == undefined){
      //   // do nothing
      // } else {
      //   hcahps_props = data.hcahps
      //   table_selector = "#table-ccn"+hcahps_props.provider_number
      //   $("#comparison_tables").append("<table id='table-ccn"+hcahps_props.provider_number+"' class=''></table>")
      //   $(table_selector).html("<thead></thead><tbody></tbody>")
      //   $(table_selector+" thead").append("<tr><th>Measure</th><th data-sort-initial='true' data-type='numeric'>Values for: "+hcahps_props.hospital_name+"</th></tr>");
      //   $.each( hcahps_props, function(k, v){
      //     value = v
      //     key = k.split("_").join(" ")
      //     if(k.match(/percent/)){value = "<div class=progress><span class=meter style='width: "+value+"%'>&nbsp;"+value+"</span></div>"}
      //     else { v = 999; } // group non-percentile values together at the top/bottom of table depending on sort
      //     $(table_selector+" tbody").append("<tr><td>"+key+"</td><td data-value='"+v+"'>"+value+"</td></tr>")
      //   });
      //   $(table_selector).footable();
      // }
      // selector = data._id
      // feature_html = "<section><p class='title' data-section-title=''><a href='#'>Section 1</a></p>"
      // feature_html += ""
      // feature_html += "</section>"
   
    });
  })
}

function toggle_column_mode(){
  $('div#side_section').toggleClass('large-5')
  $('div#side_section .feature').toggleClass("columns large-4")
  $('div#content').toggleClass('large-9').toggleClass('large-12')
}

function handleFeature(feature, layer){
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
  else if(props.general){
    if(props.general["address_1"] && props.general["city"] && props.general["state"] && props.general["zip_code"]){
      popup += "<br />"+props.general["address_1"]
      popup += "<br />"+props.general["city"]+", " + props.general["state"] + " " + props.general["zip_code"]
    }
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

  layer.bindPopup(popup)
  layer.on('click', onFeatureClick);
}

function renderHcHaisObject(obj){
  html = "<h6><a href='https://data.medicare.gov/Hospital-Compare/Healthcare-Associated-Infections/ihvx-zkyp' target='blank'>Hospital Associated Infections (from CMS Hospital Compare/CDC)</a></h6>"
  html += "<ul class='side-nav'>"
  $.each(obj, function(k,hai){
    if(hai.score != undefined){
      html += "<li><a href='http://www.cdc.gov/HAI/infectionTypes.html' target='blank'>"+hai.measure+"</a>"
      html += "<ul class=''><li>Score: "+hai.score+"</li><li>Footnote: "+hai.footnote+"</li><li>Source: "+formatSource(hai._source)+"</li><li>Data last refreshed at: "+hai._updated_at+"</li></ul>"
      html += "</li>"      
    }
  })
  html += "</ul>"
  return html
}

function renderHcahpsObject(obj){
  html = "<h6><a href='http://www.hcahpsonline.org/home.aspx' target='blank'>Patient Experience Surveys (HCAHPS via CMS Hospital Compare</a></h6>"
  html += "<ul class='side-nav'>"
  $.each(obj, function(k,v){
    key = formatKey(k)
    html += "<li><u>"+key+":</u> "+v+"</li>"
  })                
  html += "</ul>"
  return html
}

function formatKey(input){
  string = String(input)
  return string.toLowerCase().split("_").join(" ")
}

function formatSource(input){
  string = String(input)
  return string.split("/")[2]
}

function toggle(input,what_to_toggle){
  str = String(input)
  $("#"+str+" "+what_to_toggle).toggle('blind')
  if($("#"+str+" .toggler i").hasClass("foundicon-general-minus")){
    $("#"+str+" .toggler i").toggleClass("foundicon-general-minus")
    $("#"+str+" .toggler i").toggleClass("foundicon-general-plus")
  } else {
    $("#"+str+" .toggler i").toggleClass("foundicon-general-minus")
    $("#"+str+" .toggler i").toggleClass("foundicon-general-plus")
  }
}