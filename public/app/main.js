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

    searchControl = new L.Control.Search({layer: markers, propertyName: "name", circleLocation:true});
    searchControl.on('search_locationfound', function(e) {
      map.fitBounds(new L.LatLngBounds(new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng), new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng)))
      map.zoomOut(3)
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
  else if(props["PROVIDER NPI"]) { label = "NPI_"+e.target.feature.properties.npi }
  else { label = "Unknown" }
  if(typeof(_gaq) != "undefined"){ _gaq.push(['_trackEvent', 'Map', 'Click (Feature)', label]); }

  if(props["PROVIDER CCN"]){ 
    // hospital
    features_clicked.push(e.target.feature)
    renderHospitalDetails()
  }
  else if(props.npi) {
    id = props.npi
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
      feature_content += "<h4>"+props.name+"</h4>"
      feature_content += "<div class='feature_content'><p><a href='http://www.bloomapi.com/search#/npis/"+id+"' target='blank'>Visit BloomAPI for data about this provider from the CMS NPPES database</a></p>"
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
        id = props.id
        selector = "#feature_container #"+id
        if($(selector).length === 0){
          if($('div#content').hasClass("large-12")){
            feature_stub_div_class = "large-4 columns"
          } else {
            feature_stub_div_class = ""
          }
          feature_stub = "<div class='feature panel "+feature_stub_div_class+"' id='"+id+"'></div>"

          $("#feature_container").append(feature_stub)

          feature_content = "<a href=# onclick=toggle('"+id+"','.feature_content') title='show/hide details' class='toggler'><i class='foundicon-general-plus'></i></a>"
          feature_content += "<h4>"+props.name+"</h4>"
          feature_content += "<div class='feature_content' style='display:none'><p>"
          
          key_value_content = ""
          object_content = ""
          $.each( props, function(k, v){
            key = formatKey(k)
            if(v == null || v.length === 0){ /* do nothing */ }
            else if(typeof(v) === "object"){
              if(k == "hc_hais"){
                object_content += "</p>"+renderHcHaisObject(v)+"<p>"
              } else if (k == "hc_hacs"){
                object_content += "</p>"+renderHcHacsObject(v)+"<p>"
              } else if (k == "hcahps"){
                // feature_content += "</p>"+renderHcahpsObject(v)+"<p>"
                object_content += "</p><h6><a href='http://www.hcahpsonline.org/home.aspx' target='blank'>Patient Experience Surveys (HCAHPS via CMS Hospital Compare</a></h6><p>"
                object_content += renderKeyValueObject(v)
              } else if (k == "ahrq_m"){
                object_content += "</p><h6><a href='https://data.medicare.gov/Hospital-Compare/Agency-For-Healthcare-Research-And-Quality-Measure/vs3q-rxc5' target='blank'>Agency for Healthcare Research and Quality Measues</a></h6><p>"
                object_content += renderKeyValueObject(v)
              } else if (k == "address"){
                object_content += "</p><h6>Address</h6><p>"
                object_content += renderKeyValueObject(v,false) 
              } else if (k == "geo"){
                object_content += "</p><h6>Geocoding</h6><p>"
                object_content += "<u>source:</u> "+v._source+"<br />"
                object_content += "<u>updated at:</u> "+v._updated_at+"<br />"
              }
              else {
                object_content += "</p><h6>"+key+"</h6><p>"
                object_content += renderKeyValueObject(v)
              }
              object_content += "<hr />"
            } 
            else {
              key_value_content += "<u>"+key+":</u> "+v+"<br />"
            }

          });

          feature_content+= key_value_content + object_content

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
  if(props.incentives_received){
    if(props["incentives_received"]["year_2011"] == true){layer.setIcon(incentiveTrueIcon) }
    else if(props["incentives_received"]["year_2012"] == true){layer.setIcon(incentiveTrueIcon) }
    else if(props["incentives_received"]["year_2013"] == true){layer.setIcon(incentiveTrueIcon) }    
    else {layer.setIcon(incentiveFalseIcon)}
  }
  else {layer.setIcon(incentiveFalseIcon)}

  // set up pop up text. ALWAYS give preference to incentive received dataset but fall back on general info dataset
  // TODO - this needs some major refactoring / DRYing
  popup = ""

  // provider name
  popup += "<strong>" + props.name + "</strong>"

  if(props.address){
    popup += "<br />"+props.address["address"]
    popup += "<br />"+props.address["city"]+", " + props.address["state"] + " " + props.address["zip"]
  }
  
  if(props.general){
    popup += "<br /><br />Hosp. Name: "+props.general["hospital_name"]
    popup += "<br />Hosp. Owner: "+props.general["hospital_owner"]
    popup += "<br />Hosp. Type: "+props.general["hospital_type"]
  }

  // phone number
  if(props.phone_number){popup += "<br /><br /> Phone: " + props.phone_number}

  // other attributes (NPI, CCN, Incentive Program Years)
  if(props["PROVIDER CCN"]){ popup += "<br /><br /> CCN: <a href='http://www.medicare.gov/hospitalcompare/profile.html#profTab=0&ID="+props["PROVIDER CCN"]+"' target='blank'>"+props["PROVIDER CCN"]+"</a>"}
  if(props.npi){popup += "<br />NPI: " + "<a href='http://www.bloomapi.com/search#/npis/"+props.npi+"' target=_blank>"+props.npi+"</a>"}
  if(props.jc_id){popup+= "<br />Joint Commisison ID: <a target='blank' href='http://www.qualitycheck.org/consumer/searchresults.aspx?nm="+props.jc_id+"'>"+props.jc_id+"</a>"}
  popup += "<br /><br />Incentive Program Year(s), if any: "
  if(props["incentives_received"]["year_2011"] === true){popup += "<span class='radius secondary label'>2011</span> " }
  if(props["incentives_received"]["year_2012"] === true){ popup += " <span class='radius secondary label'>2012</span>" }
  if(props["incentives_received"]["year_2013"] === true){ popup += " <span class='radius secondary label'>2013</span>" }

  layer.bindPopup(popup)
  layer.on('click', onFeatureClick);
}

function renderHcHaisObject(obj){
  html = "<h6><a href='http://www.medicare.gov/hospitalcompare/Data/Healthcare-Associated-Infections.html' target='blank'>Hospital Associated Infections (from CMS Hospital Compare/CDC)</a></h6>"
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

function renderHcHacsObject(obj){
  html = "<h6><a href='http://www.medicare.gov/hospitalcompare/Data/Hospital-Acquired-Conditions.html' target='blank'>Hospital Acquired Condition (from CMS Hospital Compare/CDC)</a></h6>"
  html += "<ul class='side-nav'>"
  $.each(obj, function(k,hac){
    if(hac.rate_per_1_000_discharges_ != undefined){
      html += "<li>"+hac.measure+""
      html += "<ul class=''><li>Rate per 1,000: "+hac.rate_per_1_000_discharges_+"</li><li>Source: "+formatSource(hac._source)+"</li><li>Data last refreshed at: "+hac._updated_at+"</li></ul>"
      html += "</li>"      
    }
  })
  html += "</ul>"
  return html
}

function renderKeyValueObject(obj,exclude_duplicate_fields){
  if(typeof(exclude_duplicate_fields) == "undefined"){exclude_duplicate_fields = true}
  html = ""
  $.each(obj, function(k,v){
    if(exclude_duplicate_fields){
      if($.inArray(k, ["provider_number","address_1","address_2","zip_code","phone_number","state","city","county_name","hospital_name"]) != -1 ){return true}
    }
    key = formatKey(k)
    html += "<u>"+key+":</u> "+v+"<br />"
  })       
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