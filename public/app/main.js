// the plan is to have all custom JS that supports the main site function here
// document.ready calls will stay in layout.haml/page level code, for now

var map, markers; // for leaflet mapping
var hospitals_clicked = [] // for comparison features

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

var years_of_incentives = ['2011', '2012', '2013'];


function load_geojson_as_cluster(data_url,fit_bounds){
  $("#map").showLoading();
  $.getJSON(data_url, function(data){
    if(typeof(markers) != "undefined"){map.removeLayer(markers);}    // clear all markers
    if(typeof(searchControl)!= "undefined"){map.removeControl(searchControl)}
    markers = new L.MarkerClusterGroup({maxClusterRadius:30})
    var geoJsonLayer = L.geoJson(data, {onEachFeature: handleGeoJSONFeature, filter: filterGeoJSON});
    markers.on('clusterclick', onClusterClick);
    markers.addLayer(geoJsonLayer);
    map.addLayer(markers);
    searchControl = new L.Control.Search({layer: markers, propertyName: "name", circleLocation:true});
    searchControl.on('search_locationfound', function(e) {
      map.fitBounds(new L.LatLngBounds(new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng), new L.LatLng(e.layer.getLatLng().lat, e.layer.getLatLng().lng)))
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
    hospitals_clicked.push(e.target.feature.id)
    renderHospitalComparison()
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
      feature_content += "<div class='feature_content'><p><a href='"+linkForNPI(id)+"' target='blank'>Visit BloomAPI for data about this provider from the CMS NPPES database</a></p>"
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

function clearHospitalComparison(){
  hospitals_clicked = [];
  renderHospitalComparison();  
}

function addRandomHospitalToComparison(){
  hospitals_clicked.push("random")
  renderHospitalComparison();  
}

function renderHospitalComparison(){
  $("#feature_container").html("")
  $.each(hospitals_clicked, function(n,feature_id){
    provider_url = "/db/cms_incentives/EH/find_by_bson_id/"+feature_id+".json"
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
          
          // handle root key value content
          key_value_content = ""
          key_value_content += "<ul class=filterable>"
          key_value_content += "<li><u>CMS ID (CCN):</u> <a href='"+linkForCCN(props["PROVIDER CCN"])+"'>"+props["PROVIDER CCN"]+"</a></li>"
          if(props.npi){key_value_content += "<li><u>NPI:</u> <a href='"+linkForNPI(props.npi)+"'>"+props.npi+"</a></li>"}
          if(props.jc_id){key_value_content += "<li><u>Joint Commission ID:</u> <a href='"+linkForJC(props.jc_id)+"'>"+props.jc_id+"</a></li>"}
          key_value_content += "</ul>"

          // handle content stored in nested objects
          object_content = ""
          $.each( props, function(k, v){
            key = formatKey(k)
            if(v == null){ /* do nothing */ }
            else if(typeof(v) === "object"){
              switch(k){
              case 'incentives_received':
                object_content += "</p><h6>EHR Incentives Received</h6><p>"
                // this can be refactored
                $.each(years_of_incentives, function( index, year ) {
                  if(v['year_'+year] === true){
                    object_content += "<span class='radius secondary label'>"+year
                    if(v['year_'+year+'_amt'] != null){
                      object_content += " ($"+v['year_'+year+'_amt']+")"
                    }  
                    object_content += "</span>"
                  }
                })
                if(v.year_2011 === false && v.year_2012 === false && v.year_2013 == false){object_content += "None"}
                object_content += "<br /><em class='small'><a href='http://socialhealthinsights.com/2013/09/visualizing-meaningful-use-attestation-data-by-ehr-and-technology-vendor/' target='blank'>Interested in which vendors are supporting eligible hospitals and providers? This blog post includes analysis and a link to an interactive visualization of vendor stats.</a></em>"
                break;
              case 'geo':
                // do nothing
                break;
              case 'hc_hais':
                object_content += renderHcHaisObject(v)
                break;
              case 'hc_hacs':
                object_content += renderHcHacsObject(v)
                break;
              case 'ahrq_m':
                object_content += "<h6><a href='https://data.medicare.gov/Hospital-Compare/Agency-For-Healthcare-Research-And-Quality-Measure/vs3q-rxc5' target='blank'>Agency for Healthcare Research and Quality Measues</a></h6>"
                object_content += "<p><br /><a class='compare-national-average' target='blank' href='https://data.medicare.gov/Hospital-Compare/Agency-For-Healthcare-Research-And-Quality-Nationa/sdhm-um6i'>See National Averages</a></p>"
                object_content += renderKeyValueObject(v)
                break;
              case 'ooc':
                object_content += "<h6><a href='https://data.medicare.gov/Hospital-Compare/Hospital-Outcome-Of-Care-Measures/rcw8-6swd' target='blank'>Outcome Of Care Measures (provider data)</a></h6>"
                object_content += "<p><br /><a target='blank' href='https://data.medicare.gov/Hospital-Compare/Hospital-Outcome-Of-Care-Measures-National-Average/i2h8-79qx'>See National Averages</a></p>"
                object_content += renderKeyValueObject(v)
                break;
              case 'general':
                object_content += "<h6>General Information</h6>"
                object_content += formatGeneralHospitalInformation(v)
                break;
              case 'address':
                object_content += "</p><h6>Address</h6><ul class='filterable'><p>"
                object_content += formatAddress(v)
                object_content += "</ul><p>"
                break;
              case 'hcahps':
                object_content += "</p><h6><a href='http://www.hcahpsonline.org/home.aspx' target='blank'>Patient Experience Surveys (HCAHPS via CMS Hospital Compare</a></h6>"
                object_content += "<p><br /><a target='blank' href='https://data.medicare.gov/Hospital-Compare/Survey-of-Patients-Hospital-Experiences-HCAHPS-Nat/89u8-shx4'>See National Averages</a></p>"
                object_content += renderHcahpsObject(v)
                break;
              case 'cms255210':
                object_content += "</p><h6><a href='http://www.cms.gov/Research-Statistics-Data-and-Systems/Files-for-Order/CostReports/Hospital-2010-form.html' target='blank'>Hospital Form 2552-10 (Cost Report Data Files via CMS)</a></h6>"
                object_content += renderCms255210Object(v)
                break;
              default:
                object_content += "</p><h6>"+key+"</h6><p>"
                object_content += renderKeyValueObject(v)
                break;
              }
            object_content += "<hr />"
            } 
            else {
              // do nothing
            }

          });

          feature_content+= key_value_content + object_content

          feature_content += "</p></div></div>"
          $(selector).html(feature_content)

        } else {
          // do nothing
        }
      }
      
      // old way of visualizing HCAHPS.. consider bring it back
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

function handleGeoJSONFeature(feature, layer){
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
    popup += "<br />"+formatAddress(props.address)
  }
  
  if(props.general){
    popup += "<br /><br />"+formatGeneralHospitalInformation(props.general)
  }

  // phone number
  if(props.phone_number){popup += "<br /><u>Phone:</u> " + props.phone_number}

  // other attributes (NPI, CCN, Incentive Program Years)
  if(props["PROVIDER CCN"]){ popup += "<br /><br /> <u>CCN:</u> <a href='"+linkForCCN(props["PROVIDER CCN"])+"' target='blank'>"+props["PROVIDER CCN"]+"</a>"}
  if(props.npi){popup += "<br /><u>NPI:</u> " + "<a href='"+linkForNPI(props.npi)+"' target=_blank>"+props.npi+"</a>"}
  if(props.jc_id){popup+= "<br /><u>Joint Commisison ID:</u> <a target='blank' href='"+linkForJC(props.jc_id)+"'>"+props.jc_id+"</a>"}
  popup += "<br /><br />Incentive Program Year(s), if any: "

  // this can be refactored
  $.each(years_of_incentives, function( index, year ) {
    if(props["incentives_received"]["year_"+year] === true){
      popup += "<span class='radius secondary label'>"+year
      if(props["incentives_received"]["year_"+year+"_amt"] != null){
        popup += " ($"+props["incentives_received"]["year_"+year+"_amt"]+")"
      }
      popup += "</span>"
    }
  });

  layer.bindPopup(popup)
  layer.on('click', onFeatureClick);
}

function renderHcHaisObject(array_in){
  html = "<h6><a href='http://www.medicare.gov/hospitalcompare/Data/Healthcare-Associated-Infections.html' target='blank'>Hospital Associated Infections (from CMS Hospital Compare/CDC)</a></h6>"
  html += "<p><br /><a target='blank' href='https://data.medicare.gov/Hospital-Compare/Healthcare-Associated-Infections-National/6kcz-q57c'>See National Averages</a></p>"
  if(array_in.length === 0){
    html += "<p>None</p>"
  } else {
    html += "<ul class='filterable'>"
    $.each(array_in, function(k,hai){
      if(hai.score != undefined){
        html += "<li><a href='http://www.cdc.gov/HAI/infectionTypes.html' target='blank'>"+hai.measure+"</a>"
        html += "<ul class=''><li>Score: "+hai.score+"</li>"
        if(hai.footnote != null){html += "<li>Footnote: "+hai.footnote+"</li>"}
        html += "<li>Source: "+formatSource(hai._source)+"</li><li>Data last refreshed at: "+hai._updated_at+"</li></ul>"
        html += "</li>"      
      }
    })
    html += "</ul>"    
  }
  return html
}

function renderHcHacsObject(array_in){
  html = "<h6><a href='http://www.medicare.gov/hospitalcompare/Data/Hospital-Acquired-Conditions.html' target='blank'>Hospital Acquired Condition (from CMS Hospital Compare/CDC)</a></h6>"
  html += "<p><br /><a target='blank' href='https://data.medicare.gov/Hospital-Compare/Hospital-Acquired-Condition-National-Measures/zqjn-m8m8'>See National Averages</a></p>"
  if(array_in.length === 0){
    html += "<p>None</p>"
  } else {
    html += "<ul class='filterable'>"
    $.each(array_in, function(k,hac){
      if(hac.rate_per_1_000_discharges_ != undefined){
        html += "<li>"+hac.measure+""
        html += "<ul class=''><li>Rate per 1,000: "+hac.rate_per_1_000_discharges_+"</li><li>Source: "+formatSource(hac._source)+"</li><li>Data last refreshed at: "+hac._updated_at+"</li></ul>"
        html += "</li>"      
      }
    })
  }
  html += "</ul>"
  return html
}

function renderKeyValueObject(obj){
  html = "<ul class='filterable'>"
  array = $.map(obj, function(k,v){
    key = formatKey(k)
    value = formatKey(v)
    return "<li><u>"+value+":</u> "+key+"</li>"
  })    
  if(array.length === 0){
    array.push("<li>None</li>")
  }
  html += array.join("")+"</ul>"   
  return html         
}

function renderHcahpsObject(obj){
  html = "<ul class='filterable'>"
  array = $.map(obj, function(k,v){
    key = formatKey(k)
    value = formatKey(v)
    return "<li><u>"+key+":</u> "+value+"</li>"
  })    
  if(array.length === 0){
    array.push("<li>None</li>")
  }
  html += array.join("")+"</ul>"   
  return html         
}

function renderCms255210Object(obj){
  html = "<ul class='filterable'>"
  $.each(obj, function(year,values){
    html += "<li><u>"+year+":</u> "
    if(values === null){
      html += "N/A"
    } else {
      html += "<ul>"
      $.each(values, function(k,v){
        key = formatKey(k)
        value = formatKey(v)
        html += "<li>"+key+": "+value+"</li>"
      })    
      html += "</ul>"

    }
    html += "</li>"
  })    
  html += "</ul>"
  return html         
}


function formatKey(input){
  if(input === null){
    string = "N/A"
  } else {
    string = String(input).toLowerCase().split("_").join(" ")    
  }
  return string
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
  $('.filterable_input').fastLiveFilter('.filterable');
}

function formatAddress(obj){
  html = ""
  html += obj["address"]
  html += "<br />"+obj["city"]+", " + obj["state"] + " " + obj["zip"]
  return html
}

function formatGeneralHospitalInformation(obj){
  html = "<ul class=filterable>"
  // html += "<li><u>Hosp. Name:</u> "+obj["hospital_name"]+"</li>"
  html += "<li><u>Hosp. Owner:</u> "+obj["hospital_owner"]+"</li>"
  html += "<li><u>Hosp. Type:</u> "+obj["hospital_type"]+"</li>"
  html += "</ul>"
  return html;
}

function linkForNPI(npi){
  return "http://www.bloomapi.com/search#/npis/"+npi;
}

function linkForCCN(ccn){
  return "http://www.medicare.gov/hospitalcompare/profile.html#profTab=0&ID="+ccn;
}

function linkForJC(jc_id){
  return "http://www.qualitycheck.org/consumer/searchresults.aspx?nm="+jc_id;
}

function currency_str_to_float(x){
  if(typeof(x) == "number"){
    return x;
  } else {
    return parseFloat(x.replace(/(,|\$)/g,""))
  }
}

function filterGeoJSON(feature, layer){
  // start by assuming we want to include the feature
  var show = true; 

  // Year switches
  if($('input[name=switch-paid-2013]:checked').val() == "true" && feature.properties.incentives_received["year_2013"] == true){
    show = true;
  }
  else if($('input[name=switch-paid-2012]:checked').val() == "true" && feature.properties.incentives_received["year_2012"] == true){
    show = true;
  }
  else if($('input[name=switch-paid-2011]:checked').val() == "true" && feature.properties.incentives_received["year_2011"] == true){
    show = true;
  }
  else if($('input[name=switch-paid-never]:checked').val() == "true" && feature.properties.incentives_received["year_2013"] == false && feature.properties.incentives_received["year_2012"] == false && feature.properties.incentives_received["year_2011"] == false){
    show = true;
  } else {
    show = false;
  }

  // Payment min/max filter (only run if the check boxes are )
  if(show == true){
    pmt_min = currency_str_to_float($('input[name=filter-calc-payment-min]').val())
    pmt_max = currency_str_to_float($('input[name=filter-calc-payment-max]').val())
    if(!isNaN(pmt_min) && !isNaN(pmt_max)){
      // create array of show values
      show_pmt_array = $.map(years_of_incentives, function( year, index ) {
        pmt = currency_str_to_float(feature.properties.incentives_received['year_'+year+'_amt'])
        if(pmt < pmt_min || pmt > pmt_max){
          return false;
        } else {
          return true;
        }
      });
      // check if any of the array values are true
      // set show to true if any of them are true
      show = show_pmt_array.some(function ( val ) {
         return val === true;
      });
    }
  }

  return show;
}
