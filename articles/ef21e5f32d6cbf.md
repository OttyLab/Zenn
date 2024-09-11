---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「GeoJSONラインを追加」"
emoji: "〰"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: false
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「GeoJSONラインを追加」についての解説です。このサンプルではGeoJSONソースの使い方を例示しています。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。

以下が本サンプルのデモです。
@[codepen](https://codepen.io/OttyLab/pen/GRbeGqo)


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/geojson-line/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/geojson-line/)

基本的に同じコードですが、英語版はスタイルがMapbox Streets v12にアップグレードされているのでこちらを使用します。Mapbox Streets v11ではデフォルトのプロジェクションがWebメルカトルであるのに対し、Mapbox Streets v12ではGlobe（3D表示された地球）なので、印象がかなり異なります。

## HTML/CSS

まずHTMLを見ていきましょう。

以下は地図を表示するエレメントです。

```HTML
<div id="map"></div>
```

## Mapの作成

次にJavaScriptのコードを見ていきます。以下のコードはいつも通り、Mapオブジェクトを作成しています。`container`で地図を表示するHTMLエレメントのidを指定します。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/streets-v12',
  center: [-122.486052, 37.830348],
  zoom: 14
});
```

## loadイベント
ソースとレイヤーは、スタイルの読み込みが終わってから作成する必要があります（ソース・レイヤーはスタイルに管理される要素であるため）。そこで、`map.on('load', () => {/*ここ*/});`のように、スタイルのロード完了時に発火する`load`イベントのコールバック関数の中でソースおよびレイヤーの作成を行います。

## ソースの作成

今回は[GeoJSONソース](https://docs.mapbox.com/style-spec/reference/sources/#geojson)を読み込みます。LineStringなので、線分を表現しています。デモの中央辺りにある灰色の折れ線が該当する部分です。

```JavaScript
map.addSource('route', {
  'type': 'geojson',
  'data': {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': [
        [-122.483696, 37.833818],
        [-122.483482, 37.833174],
        ...中略
        [-122.492237, 37.833378],
        [-122.493782, 37.833683]
      ]
    }
  }
});
```

## レイヤーの作成

先ほど作成したソースを用いてレイヤーを作成します。元データはLineStringだったので、線分を表現する[Lineレイヤー](https://docs.mapbox.com/style-spec/reference/layers/#line)を作成します。

- [`line-join`](https://docs.mapbox.com/style-spec/reference/layers/#layout-line-line-join)は線分のつなぎ目の見た目を設定します。`round`を指定することで、つなぎ目が丸く滑らかになっています。
- [`line-cap`](https://docs.mapbox.com/style-spec/reference/layers/#layout-line-line-cap)はLineStringの端点の見た目を設定します。`round`を指定することで、端点が丸くなっています。

```JavaScript
map.addLayer({
  'id': 'route',
  'type': 'line',
  'source': 'route',
  'layout': {
    'line-join': 'round',
    'line-cap': 'round'
  },
  'paint': {
    'line-color': '#888',
    'line-width': 8
  }
});
```

# まとめ

GeoJSONを用いて簡単に線分を描けることがわかりました。
