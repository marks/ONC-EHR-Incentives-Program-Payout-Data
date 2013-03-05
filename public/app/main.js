// the plain is to have all custom JS that supports the main site function here
// document.ready calls will stay in layout.haml/page level code, for now

var map, markers, feature_last_clicked;

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
        popup += "<br /><br /> <a href=https://npiregistry.cms.hhs.gov/NPPESRegistry/NPIRegistryHome.do target=_blank>NPI</a>: " + props["PROVIDER NPI"]
        if(props["PROVIDER CCN"]){ popup += " | <a href=http://www.qualitycheck.org/consumer/searchQCR.aspx target=_blank>CCN</a>: " + props["PROVIDER CCN"]}
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
  feature_last_clicked = e.target.feature
}
