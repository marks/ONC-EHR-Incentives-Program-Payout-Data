// the plain is to have all custom JS that supports the main site function here
// document.ready calls will stay in layout.haml/page level code, for now

// for leaflet mapping
var map, markers;

// for additional features
var features_clicked = []
var hcahps_endpt = "http://data.medicare.gov/resource/rj76-22dk.json?" // https://data.medicare.gov/dataset/Survey-of-Patients-Hospital-Experiences-HCAHPS-/rj76-22dk

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
  clicked_feature = $(features_clicked).last()
  // hcahps_url = hcahps_endpt+"&provider_number="+clicked_feature[0].properties["PROVIDER CCN"]
  // console.log(hcahps_url)
  // $.getJSON(hcahps_url, function(data){
  //   console.log(data)
  // })
}

