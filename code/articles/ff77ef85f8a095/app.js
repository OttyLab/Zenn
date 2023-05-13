import { MapboxOverlay } from '@deck.gl/mapbox';
import { Tile3DLayer } from '@deck.gl/geo-layers';
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = YOUR_MAPBOX_PUBLIC_TOKEN;

const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/yochi/clhlrojci000601pv1rwebvoq',
  center: [139.7586677640881, 35.6736926988029],
  zoom: 14,
  pitch: 30,
  customAttribution: 'Data SIO, NOAA, U.S. Navy, NGA, GEBCO;Landsat / Copernicus',
});

export const overlay = new MapboxOverlay({
  interleaved: true,
  layers: [
    new Tile3DLayer({
      beforeId: 'road-label',
      id: 'tile-3d-layer',
      data: 'https://tile.googleapis.com/v1/3dtiles/root.json',
      loadOptions: {
        fetch: { headers: { 'X-GOOG-API-KEY': YOUR_GOOGLE_API_TOKEN } }
      },
    }),
  ]
});

map.addControl(overlay);
map.addControl(new mapboxgl.NavigationControl());
